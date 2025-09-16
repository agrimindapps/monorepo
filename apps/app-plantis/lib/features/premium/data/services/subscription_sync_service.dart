import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

/// Serviço avançado para sincronizar assinaturas cross-device para o Plantis
/// Baseado no padrão do app-receituagro com melhorias específicas para plantas
class SubscriptionSyncService {
  final FirebaseFirestore _firestore;
  final IAuthRepository _authRepository;
  final ISubscriptionRepository _subscriptionRepository;
  final IAnalyticsRepository _analytics;

  SubscriptionSyncService({
    FirebaseFirestore? firestore,
    required IAuthRepository authRepository,
    required ISubscriptionRepository subscriptionRepository,
    required IAnalyticsRepository analytics,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _authRepository = authRepository,
       _subscriptionRepository = subscriptionRepository,
       _analytics = analytics;

  // Stream controllers para eventos em tempo real
  final _syncEventsController = StreamController<PlantisSubscriptionSyncEvent>.broadcast();
  final _subscriptionController = StreamController<SubscriptionEntity?>.broadcast();

  /// Stream de eventos de sincronização
  Stream<PlantisSubscriptionSyncEvent> get syncEventsStream => _syncEventsController.stream;

  /// Stream reativo da assinatura atual
  Stream<SubscriptionEntity?> get subscriptionStream => _subscriptionController.stream;

  // Estado interno
  Timer? _syncTimer;
  bool _isSyncing = false;
  final Map<String, int> _retryCount = {};
  static const int maxRetries = 3;

  /// Sincroniza status da assinatura cross-device com conflict resolution
  Future<void> syncSubscriptionStatus() async {
    if (_isSyncing) {
      debugPrint('[PlantisSync] Sincronização já em andamento');
      return;
    }

    try {
      _isSyncing = true;
      await _analytics.logEvent('plantis_subscription_sync_started');

      // 1. Obter status atual do RevenueCat
      final subscriptionResult = await _subscriptionRepository.getCurrentSubscription();

      await subscriptionResult.fold(
        (failure) async {
          await _handleSyncError('Erro ao obter assinatura do RevenueCat: ${failure.message}');
          throw Exception(failure.message);
        },
        (currentSubscription) async {
          // 2. Obter informações do usuário atual
          final currentUser = await _getCurrentUser();
          if (currentUser == null) {
            throw Exception('Usuário não autenticado');
          }

          // 3. Preparar dados para sincronização
          final subscriptionData = await _prepareSubscriptionData(currentSubscription, currentUser);

          // 4. Verificar conflitos com outros dispositivos
          final conflicts = await _checkDeviceConflicts(subscriptionData);

          if (conflicts.isNotEmpty) {
            await _resolveConflicts(conflicts, subscriptionData);
          }

          // 5. Sincronizar com Firebase
          await _saveToFirebase(subscriptionData);

          // 6. Processar features específicas do Plantis
          await _processPlantisFeatures(currentSubscription);

          // 7. Emitir evento de sucesso
          _syncEventsController.add(PlantisSubscriptionSyncEvent.success(
            subscription: currentSubscription,
            syncedAt: DateTime.now(),
            premiumFeaturesEnabled: _getPremiumFeaturesEnabled(currentSubscription),
          ));

          _subscriptionController.add(currentSubscription);

          await _analytics.logEvent('plantis_subscription_sync_completed', parameters: {
            'is_premium': (currentSubscription?.isActive ?? false).toString(),
            'subscription_type': currentSubscription?.productId ?? 'none',
            'tier': currentSubscription?.tier.name ?? 'free',
            'premium_features_count': _getPremiumFeaturesEnabled(currentSubscription).length.toString(),
          });
        },
      );

    } catch (e) {
      await _handleSyncError('Erro na sincronização: $e');
      rethrow;
    } finally {
      _isSyncing = false;
    }
  }

  /// Processa webhooks do RevenueCat para atualizações em tempo real
  Future<void> processRevenueCatWebhook(Map<String, dynamic> webhookData) async {
    try {
      final eventType = webhookData['event']?['type'] as String?;
      final userId = webhookData['event']?['app_user_id'] as String?;

      if (eventType == null || userId == null) {
        throw ArgumentError('Webhook inválido: missing event type or user ID');
      }

      await _analytics.logEvent('plantis_revenuecat_webhook_received', parameters: {
        'event_type': eventType,
        'user_id': userId,
      });

      // Processar diferentes tipos de eventos
      switch (eventType) {
        case 'INITIAL_PURCHASE':
          await _handleInitialPurchase(webhookData);
          break;
        case 'RENEWAL':
          await _handleRenewal(webhookData);
          break;
        case 'CANCELLATION':
          await _handleCancellation(webhookData);
          break;
        case 'UNCANCELLATION':
          await _handleUncancellation(webhookData);
          break;
        case 'EXPIRATION':
          await _handleExpiration(webhookData);
          break;
        case 'BILLING_ISSUE':
          await _handleBillingIssue(webhookData);
          break;
        case 'PRODUCT_CHANGE':
          await _handleProductChange(webhookData);
          break;
        default:
          await _analytics.logEvent('plantis_unhandled_webhook_event', parameters: {
            'event_type': eventType,
          });
      }

      // Sempre sincronizar após processar webhook
      await syncSubscriptionStatus();

    } catch (e) {
      await _analytics.logEvent('plantis_webhook_processing_failed', parameters: {
        'webhook_data': webhookData.toString(),
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// Prepara dados de assinatura para sincronização cross-device
  Future<Map<String, dynamic>> _prepareSubscriptionData(
    SubscriptionEntity? subscription,
    UserEntity user,
  ) async {
    final deviceId = await _getDeviceId();
    final now = DateTime.now();

    return {
      // Dados básicos da assinatura
      'userId': user.id,
      'deviceId': deviceId,
      'devicePlatform': defaultTargetPlatform.name,
      'appName': 'plantis',
      'appVersion': await _getAppVersion(),

      // Status da assinatura
      'isPremium': subscription?.isActive ?? false,
      'productId': subscription?.productId,
      'status': subscription?.status.name ?? 'free',
      'tier': subscription?.tier.name ?? 'free',
      'isActive': subscription?.isActive ?? false,
      'isInTrial': subscription?.isInTrial ?? false,
      'willRenew': subscription?.status == SubscriptionStatus.active,

      // Datas importantes
      'purchaseDate': subscription?.purchaseDate?.millisecondsSinceEpoch,
      'expirationDate': subscription?.expirationDate?.millisecondsSinceEpoch,
      'originalPurchaseDate': subscription?.originalPurchaseDate?.millisecondsSinceEpoch,
      'lastUpdated': now.millisecondsSinceEpoch,
      'lastSyncedAt': FieldValue.serverTimestamp(),

      // Metadados da loja
      'store': subscription?.store.name ?? 'unknown',
      'isSandbox': subscription?.isSandbox ?? false,

      // Features específicas do Plantis
      'premiumFeatures': _getPremiumFeaturesEnabled(subscription),
      'plantLimitOverride': subscription?.isActive == true ? -1 : 5, // Ilimitado para premium
      'canUseAdvancedReminders': subscription?.isActive ?? false,
      'canExportData': subscription?.isActive ?? false,
      'canUseCustomThemes': subscription?.isActive ?? false,
      'canBackupToCloud': subscription?.isActive ?? false,
      'canIdentifyPlants': subscription?.isActive ?? false,
      'canDiagnoseDiseases': subscription?.isActive ?? false,

      // Metadados de sincronização
      'syncVersion': await _getNextSyncVersion(user.id),
      'conflictResolutionStrategy': 'server_wins',
      'syncSource': 'mobile_app',
    };
  }

  /// Verifica conflitos entre dispositivos e resolve automaticamente
  Future<List<DeviceConflict>> _checkDeviceConflicts(Map<String, dynamic> currentData) async {
    try {
      final userId = currentData['userId'] as String;

      // Obter status de todos os dispositivos do usuário
      final deviceSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('devices')
          .get();

      final conflicts = <DeviceConflict>[];
      final currentDeviceId = currentData['deviceId'] as String;

      for (final doc in deviceSnapshot.docs) {
        final deviceData = doc.data();
        final deviceId = deviceData['deviceId'] as String?;

        if (deviceId != currentDeviceId && deviceId != null) {
          final conflict = _detectConflict(currentData, deviceData);
          if (conflict != null) {
            conflicts.add(conflict);
          }
        }
      }

      if (conflicts.isNotEmpty) {
        await _analytics.logEvent('plantis_device_conflicts_detected', parameters: {
          'conflict_count': conflicts.length.toString(),
          'device_count': deviceSnapshot.docs.length.toString(),
        });
      }

      return conflicts;
    } catch (e) {
      debugPrint('[PlantisSync] Erro ao verificar conflitos: $e');
      return [];
    }
  }

  /// Resolve conflitos automaticamente usando estratégia "server wins"
  Future<void> _resolveConflicts(List<DeviceConflict> conflicts, Map<String, dynamic> currentData) async {
    for (final conflict in conflicts) {
      try {
        await _analytics.logEvent('plantis_resolving_conflict', parameters: {
          'conflict_type': conflict.type.name,
          'device1': conflict.device1Id,
          'device2': conflict.device2Id,
        });

        // Para assinaturas, sempre usar dados mais recentes (timestamp mais alto)
        final resolution = _resolveConflict(conflict, currentData);

        // Aplicar resolução ao Firebase
        await _applyConflictResolution(resolution);

      } catch (e) {
        await _analytics.logEvent('plantis_conflict_resolution_failed', parameters: {
          'error': e.toString(),
        });
      }
    }
  }

  /// Salva dados sincronizados no Firebase com transação atomica
  Future<void> _saveToFirebase(Map<String, dynamic> subscriptionData) async {
    final userId = subscriptionData['userId'] as String;
    final deviceId = subscriptionData['deviceId'] as String;

    await _firestore.runTransaction((transaction) async {
      // 1. Salvar status atual na coleção principal
      final currentRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('subscriptions')
          .doc('current');

      transaction.set(currentRef, subscriptionData, SetOptions(merge: true));

      // 2. Salvar informações do dispositivo
      final deviceRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('devices')
          .doc(deviceId);

      transaction.set(deviceRef, {
        'deviceId': deviceId,
        'platform': subscriptionData['devicePlatform'],
        'lastSyncAt': FieldValue.serverTimestamp(),
        'subscriptionData': subscriptionData,
      }, SetOptions(merge: true));

      // 3. Adicionar ao histórico
      final historyRef = _firestore
          .collection('subscription_history')
          .doc();

      transaction.set(historyRef, {
        ...subscriptionData,
        'historyCreatedAt': FieldValue.serverTimestamp(),
        'eventType': 'sync',
      });
    });

    debugPrint('[PlantisSync] Dados salvos no Firebase com sucesso');
  }

  /// Processa features específicas do Plantis baseadas na assinatura
  Future<void> _processPlantisFeatures(SubscriptionEntity? subscription) async {
    try {
      final user = await _getCurrentUser();
      if (user == null) return;

      final isPremium = subscription?.isActive ?? false;

      // Configurar limites de plantas
      await _updatePlantLimits(user.id, isPremium);

      // Ativar/desativar funcionalidades premium
      await _updatePremiumFeatures(user.id, subscription);

      // Configurar notificações avançadas
      if (isPremium) {
        await _enableAdvancedNotifications(user.id);
      } else {
        await _disableAdvancedNotifications(user.id);
      }

      // Configurar backup em nuvem
      await _configurePlantisCloudBackup(user.id, isPremium);

      await _analytics.logEvent('plantis_features_processed', parameters: {
        'is_premium': isPremium.toString(),
        'features_enabled': _getPremiumFeaturesEnabled(subscription).length.toString(),
      });

    } catch (e) {
      debugPrint('[PlantisSync] Erro ao processar features: $e');
      await _analytics.logEvent('plantis_features_processing_failed', parameters: {
        'error': e.toString(),
      });
    }
  }

  /// Atualiza limites de plantas baseado no status premium
  Future<void> _updatePlantLimits(String userId, bool isPremium) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('plant_limits')
        .set({
          'maxPlants': isPremium ? -1 : 5, // -1 = ilimitado
          'canCreateCustomCategories': isPremium,
          'canImportPlantData': isPremium,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  /// Atualiza configurações de features premium específicas
  Future<void> _updatePremiumFeatures(String userId, SubscriptionEntity? subscription) async {
    final features = _getPremiumFeaturesEnabled(subscription);

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('premium_features')
        .set({
          'enabledFeatures': features,
          'canUseAdvancedReminders': features.contains('advanced_reminders'),
          'canExportData': features.contains('export_data'),
          'canUseCustomThemes': features.contains('custom_themes'),
          'canIdentifyPlants': features.contains('plant_identification'),
          'canDiagnoseDiseases': features.contains('disease_diagnosis'),
          'canAccessDetailedAnalytics': features.contains('detailed_analytics'),
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  /// Ativar notificações avançadas para usuários premium
  Future<void> _enableAdvancedNotifications(String userId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc('settings')
        .set({
          'canScheduleCustomReminders': true,
          'canUseWeatherBasedNotifications': true,
          'canReceivePlantHealthAlerts': true,
          'canUseCareCalendar': true,
          'maxCustomReminders': -1, // ilimitado
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  /// Desativar notificações avançadas para usuários gratuitos
  Future<void> _disableAdvancedNotifications(String userId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc('settings')
        .set({
          'canScheduleCustomReminders': false,
          'canUseWeatherBasedNotifications': false,
          'canReceivePlantHealthAlerts': false,
          'canUseCareCalendar': false,
          'maxCustomReminders': 3, // limitado
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  /// Configurar backup em nuvem para dados das plantas
  Future<void> _configurePlantisCloudBackup(String userId, bool isPremium) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('cloud_backup')
        .set({
          'enabled': isPremium,
          'canBackupPhotos': isPremium,
          'canBackupNotes': isPremium,
          'canBackupCareHistory': isPremium,
          'autoBackupEnabled': isPremium,
          'maxBackupSizeMB': isPremium ? 1000 : 10,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  /// Registra evento de compra para analytics específico do Plantis
  Future<void> logPurchaseEvent({
    required String productId,
    required double price,
    required String currency,
  }) async {
    try {
      final currentUser = await _getCurrentUser();
      if (currentUser == null) return;

      // Registrar evento no Firebase
      await _firestore.collection('purchase_events').add({
        'userId': currentUser.id,
        'productId': productId,
        'price': price,
        'currency': currency,
        'appName': 'plantis',
        'timestamp': FieldValue.serverTimestamp(),
        'platform': defaultTargetPlatform.name,
        'purchaseContext': 'plant_care_app',
        'expectedFeatures': _getExpectedFeaturesFromProduct(productId),
      });

      // Registrar no analytics
      await _analytics.logEvent('plantis_purchase_completed', parameters: {
        'product_id': productId,
        'price': price.toString(),
        'currency': currency,
        'platform': defaultTargetPlatform.name,
      });

    } catch (e) {
      debugPrint('[PlantisSync] Erro ao logar evento de compra: $e');
    }
  }

  // Webhook handlers para eventos do RevenueCat

  Future<void> _handleInitialPurchase(Map<String, dynamic> webhookData) async {
    final event = webhookData['event'] as Map<String, dynamic>;

    await _analytics.logEvent('plantis_initial_purchase', parameters: {
      'product_id': event['product_id']?.toString() ?? 'unknown',
      'store': event['store']?.toString() ?? 'unknown',
      'environment': event['environment']?.toString() ?? 'unknown',
    });

    _syncEventsController.add(PlantisSubscriptionSyncEvent.purchased(
      productId: event['product_id']?.toString(),
      purchasedAt: DateTime.now(),
    ));
  }

  Future<void> _handleRenewal(Map<String, dynamic> webhookData) async {
    final event = webhookData['event'] as Map<String, dynamic>;

    await _analytics.logEvent('plantis_subscription_renewal', parameters: {
      'product_id': event['product_id']?.toString() ?? 'unknown',
      'expiration_date': event['expiration_at_ms']?.toString() ?? 'unknown',
    });

    _syncEventsController.add(PlantisSubscriptionSyncEvent.renewed(
      expirationDate: _parseMilliseconds(event['expiration_at_ms']),
      renewedAt: DateTime.now(),
    ));
  }

  Future<void> _handleCancellation(Map<String, dynamic> webhookData) async {
    final event = webhookData['event'] as Map<String, dynamic>;

    await _analytics.logEvent('plantis_subscription_cancellation', parameters: {
      'cancel_reason': event['cancel_reason']?.toString() ?? 'unknown',
      'will_expire_at': event['expiration_at_ms']?.toString() ?? 'unknown',
    });

    _syncEventsController.add(PlantisSubscriptionSyncEvent.cancelled(
      reason: event['cancel_reason']?.toString(),
      expiresAt: _parseMilliseconds(event['expiration_at_ms']),
      cancelledAt: DateTime.now(),
    ));
  }

  Future<void> _handleUncancellation(Map<String, dynamic> webhookData) async {
    await _analytics.logEvent('plantis_subscription_uncancellation');

    _syncEventsController.add(PlantisSubscriptionSyncEvent.reactivated(
      reactivatedAt: DateTime.now(),
    ));
  }

  Future<void> _handleExpiration(Map<String, dynamic> webhookData) async {
    await _analytics.logEvent('plantis_subscription_expiration');

    _syncEventsController.add(PlantisSubscriptionSyncEvent.expired(
      expiredAt: DateTime.now(),
    ));
  }

  Future<void> _handleBillingIssue(Map<String, dynamic> webhookData) async {
    final event = webhookData['event'] as Map<String, dynamic>;

    await _analytics.logEvent('plantis_subscription_billing_issue', parameters: {
      'grace_period_expires': event['grace_period_expiration_at_ms']?.toString() ?? 'unknown',
    });

    _syncEventsController.add(PlantisSubscriptionSyncEvent.billingIssue(
      gracePeriodEnds: _parseMilliseconds(event['grace_period_expiration_at_ms']),
    ));
  }

  Future<void> _handleProductChange(Map<String, dynamic> webhookData) async {
    final event = webhookData['event'] as Map<String, dynamic>;

    await _analytics.logEvent('plantis_subscription_product_change', parameters: {
      'old_product': event['product_id']?.toString() ?? 'unknown',
      'new_product': event['new_product_id']?.toString() ?? 'unknown',
    });
  }

  // Utility methods

  Future<UserEntity?> _getCurrentUser() async {
    final userStream = _authRepository.currentUser.first;
    return await userStream;
  }

  /// Obtém lista de features premium habilitadas para o usuário
  List<String> _getPremiumFeaturesEnabled(SubscriptionEntity? subscription) {
    if (subscription?.isActive != true) return [];

    return [
      'unlimited_plants',
      'advanced_reminders',
      'export_data',
      'custom_themes',
      'cloud_backup',
      'detailed_analytics',
      'plant_identification',
      'disease_diagnosis',
      'weather_based_notifications',
      'care_calendar',
      'plant_health_alerts',
      'photo_backup',
      'care_history_backup',
      'custom_categories',
      'import_plant_data',
    ];
  }

  /// Obtém features esperadas baseadas no produto
  List<String> _getExpectedFeaturesFromProduct(String productId) {
    final id = productId.toLowerCase();

    if (id.contains('premium') || id.contains('monthly') || id.contains('yearly')) {
      return _getPremiumFeaturesEnabled(
        SubscriptionEntity(
          id: 'temp',
          userId: 'temp',
          productId: productId,
          status: SubscriptionStatus.active,
          tier: SubscriptionTier.premium,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        )
      );
    }

    return [];
  }

  /// Obtém próxima versão de sincronização
  Future<int> _getNextSyncVersion(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('sync_metadata')
          .doc('version')
          .get();

      final currentVersion = doc.data()?['version'] as int? ?? 0;
      final nextVersion = currentVersion + 1;

      // Atualizar a versão
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('sync_metadata')
          .doc('version')
          .set({'version': nextVersion, 'lastUpdated': FieldValue.serverTimestamp()});

      return nextVersion;
    } catch (e) {
      debugPrint('[PlantisSync] Erro ao obter versão de sincronização: $e');
      return DateTime.now().millisecondsSinceEpoch;
    }
  }

  /// Obtém ID único do dispositivo
  Future<String> _getDeviceId() async {
    // Implementação simplificada - em produção, usar device_info_plus
    return '${defaultTargetPlatform.name}_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Obtém versão da aplicação
  Future<String> _getAppVersion() async {
    // Implementação simplificada - em produção, usar package_info_plus
    return '1.0.0';
  }

  /// Detecta conflito entre dois estados de dispositivo
  DeviceConflict? _detectConflict(Map<String, dynamic> current, Map<String, dynamic> other) {
    final currentPremium = current['isPremium'] as bool? ?? false;
    final otherPremium = other['subscriptionData']?['isPremium'] as bool? ?? false;

    final currentProduct = current['productId'] as String?;
    final otherProduct = other['subscriptionData']?['productId'] as String?;

    if (currentPremium != otherPremium) {
      return DeviceConflict(
        device1Id: current['deviceId'] as String,
        device2Id: other['deviceId'] as String,
        type: ConflictType.premiumStatusMismatch,
        detectedAt: DateTime.now(),
        currentData: current,
        conflictingData: other,
      );
    }

    if (currentProduct != otherProduct) {
      return DeviceConflict(
        device1Id: current['deviceId'] as String,
        device2Id: other['deviceId'] as String,
        type: ConflictType.productMismatch,
        detectedAt: DateTime.now(),
        currentData: current,
        conflictingData: other,
      );
    }

    return null;
  }

  /// Resolve conflito específico usando timestamp mais recente
  ConflictResolution _resolveConflict(DeviceConflict conflict, Map<String, dynamic> currentData) {
    final currentTimestamp = currentData['lastUpdated'] as int? ?? 0;
    final conflictTimestamp = conflict.conflictingData['subscriptionData']?['lastUpdated'] as int? ?? 0;

    // Usar dados mais recentes
    final useCurrentData = currentTimestamp >= conflictTimestamp;

    return ConflictResolution(
      strategy: 'use_latest_timestamp',
      winningDeviceId: useCurrentData ? conflict.device1Id : conflict.device2Id,
      resolvedData: useCurrentData ? currentData : conflict.conflictingData['subscriptionData'],
      resolvedAt: DateTime.now(),
    );
  }

  /// Aplica resolução de conflito ao Firebase
  Future<void> _applyConflictResolution(ConflictResolution resolution) async {
    try {
      final data = resolution.resolvedData as Map<String, dynamic>;
      await _saveToFirebase(data);

      await _analytics.logEvent('plantis_conflict_resolved', parameters: {
        'strategy': resolution.strategy,
        'winning_device': resolution.winningDeviceId,
      });
    } catch (e) {
      debugPrint('[PlantisSync] Erro ao aplicar resolução: $e');
    }
  }

  /// Inicia sincronização automática
  void startAutoSync({Duration interval = const Duration(minutes: 15)}) {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(interval, (_) {
      syncSubscriptionStatus().catchError((Object e) {
        debugPrint('[PlantisSync] Erro na sincronização automática: $e');
      });
    });
  }

  /// Para sincronização automática
  void stopAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Trata erros de sincronização com retry logic
  Future<void> _handleSyncError(String error) async {
    final user = await _getCurrentUser();
    final deviceId = await _getDeviceId();
    final retryKey = '${user?.id}_$deviceId';

    _retryCount[retryKey] = (_retryCount[retryKey] ?? 0) + 1;

    _syncEventsController.add(PlantisSubscriptionSyncEvent.failed(
      error: error,
      failedAt: DateTime.now(),
      retryCount: _retryCount[retryKey]!,
    ));

    await _analytics.logEvent('plantis_sync_error', parameters: {
      'error': error,
      'retry_count': _retryCount[retryKey].toString(),
    });

    // Implementar retry exponencial
    if (_retryCount[retryKey]! < maxRetries) {
      final delay = Duration(seconds: pow(2, _retryCount[retryKey]!).toInt());
      Timer(delay, () => syncSubscriptionStatus());
    }
  }

  DateTime? _parseMilliseconds(dynamic milliseconds) {
    if (milliseconds == null) return null;
    if (milliseconds is int) {
      return DateTime.fromMillisecondsSinceEpoch(milliseconds);
    }
    if (milliseconds is String) {
      final parsed = int.tryParse(milliseconds);
      return parsed != null ? DateTime.fromMillisecondsSinceEpoch(parsed) : null;
    }
    return null;
  }

  /// Stream de assinatura em tempo real do Firebase
  Stream<SubscriptionEntity?> getRealtimeSubscriptionStream() {
    return _authRepository.currentUser.asyncExpand((user) {
      if (user == null) {
        return Stream.value(null);
      }

      return _firestore
          .collection('users')
          .doc(user.id)
          .collection('subscriptions')
          .doc('current')
          .snapshots()
          .map((snapshot) {
        if (!snapshot.exists || snapshot.data() == null) return null;

        final data = snapshot.data()!;
        final isPremium = data['isPremium'] as bool? ?? false;

        if (!isPremium) return null;

        return SubscriptionEntity(
          id: data['productId'] as String? ?? '',
          userId: user.id,
          productId: data['productId'] as String? ?? '',
          status: _parseSubscriptionStatus(data['status'] as String?),
          tier: _parseSubscriptionTier(data['tier'] as String?),
          expirationDate: data['expirationDate'] != null
              ? DateTime.fromMillisecondsSinceEpoch(data['expirationDate'] as int)
              : null,
          purchaseDate: data['purchaseDate'] != null
              ? DateTime.fromMillisecondsSinceEpoch(data['purchaseDate'] as int)
              : null,
          originalPurchaseDate: data['originalPurchaseDate'] != null
              ? DateTime.fromMillisecondsSinceEpoch(data['originalPurchaseDate'] as int)
              : null,
          store: _parseStore(data['store'] as String?),
          isInTrial: data['isInTrial'] as bool? ?? false,
          isSandbox: data['isSandbox'] as bool? ?? false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      });
    });
  }

  SubscriptionStatus _parseSubscriptionStatus(String? status) {
    switch (status) {
      case 'active':
        return SubscriptionStatus.active;
      case 'expired':
        return SubscriptionStatus.expired;
      case 'cancelled':
        return SubscriptionStatus.cancelled;
      case 'pending':
        return SubscriptionStatus.pending;
      default:
        return SubscriptionStatus.unknown;
    }
  }

  SubscriptionTier _parseSubscriptionTier(String? tier) {
    switch (tier) {
      case 'free':
        return SubscriptionTier.free;
      case 'premium':
        return SubscriptionTier.premium;
      case 'pro':
        return SubscriptionTier.pro;
      default:
        return SubscriptionTier.free;
    }
  }

  Store _parseStore(String? store) {
    switch (store) {
      case 'appStore':
        return Store.appStore;
      case 'playStore':
        return Store.playStore;
      case 'stripe':
        return Store.stripe;
      case 'promotional':
        return Store.promotional;
      default:
        return Store.unknown;
    }
  }

  /// Limpar recursos quando o serviço não for mais usado
  void dispose() {
    _syncTimer?.cancel();
    _syncEventsController.close();
    _subscriptionController.close();
  }
}

// =============================================================================
// MODELOS DE DADOS PARA EVENTOS E SINCRONIZAÇÃO
// =============================================================================

/// Tipos de eventos de sincronização específicos do Plantis
enum PlantisSubscriptionSyncEventType {
  success,
  failed,
  purchased,
  renewed,
  cancelled,
  reactivated,
  expired,
  billingIssue,
  featuresUpdated,
}

/// Eventos de sincronização específicos do Plantis
class PlantisSubscriptionSyncEvent {
  const PlantisSubscriptionSyncEvent._({
    required this.type,
    this.subscription,
    this.syncedAt,
    this.error,
    this.failedAt,
    this.retryCount,
    this.productId,
    this.purchasedAt,
    this.renewedAt,
    this.expirationDate,
    this.reason,
    this.expiresAt,
    this.cancelledAt,
    this.reactivatedAt,
    this.expiredAt,
    this.gracePeriodEnds,
    this.premiumFeaturesEnabled,
  });

  final PlantisSubscriptionSyncEventType type;
  final SubscriptionEntity? subscription;
  final DateTime? syncedAt;
  final String? error;
  final DateTime? failedAt;
  final int? retryCount;
  final String? productId;
  final DateTime? purchasedAt;
  final DateTime? renewedAt;
  final DateTime? expirationDate;
  final String? reason;
  final DateTime? expiresAt;
  final DateTime? cancelledAt;
  final DateTime? reactivatedAt;
  final DateTime? expiredAt;
  final DateTime? gracePeriodEnds;
  final List<String>? premiumFeaturesEnabled;

  factory PlantisSubscriptionSyncEvent.success({
    required SubscriptionEntity? subscription,
    required DateTime syncedAt,
    required List<String> premiumFeaturesEnabled,
  }) => PlantisSubscriptionSyncEvent._(
    type: PlantisSubscriptionSyncEventType.success,
    subscription: subscription,
    syncedAt: syncedAt,
    premiumFeaturesEnabled: premiumFeaturesEnabled,
  );

  factory PlantisSubscriptionSyncEvent.failed({
    required String error,
    required DateTime failedAt,
    required int retryCount,
  }) => PlantisSubscriptionSyncEvent._(
    type: PlantisSubscriptionSyncEventType.failed,
    error: error,
    failedAt: failedAt,
    retryCount: retryCount,
  );

  factory PlantisSubscriptionSyncEvent.purchased({
    String? productId,
    DateTime? purchasedAt,
  }) => PlantisSubscriptionSyncEvent._(
    type: PlantisSubscriptionSyncEventType.purchased,
    productId: productId,
    purchasedAt: purchasedAt,
  );

  factory PlantisSubscriptionSyncEvent.renewed({
    DateTime? expirationDate,
    DateTime? renewedAt,
  }) => PlantisSubscriptionSyncEvent._(
    type: PlantisSubscriptionSyncEventType.renewed,
    expirationDate: expirationDate,
    renewedAt: renewedAt,
  );

  factory PlantisSubscriptionSyncEvent.cancelled({
    String? reason,
    DateTime? expiresAt,
    DateTime? cancelledAt,
  }) => PlantisSubscriptionSyncEvent._(
    type: PlantisSubscriptionSyncEventType.cancelled,
    reason: reason,
    expiresAt: expiresAt,
    cancelledAt: cancelledAt,
  );

  factory PlantisSubscriptionSyncEvent.reactivated({
    DateTime? reactivatedAt,
  }) => PlantisSubscriptionSyncEvent._(
    type: PlantisSubscriptionSyncEventType.reactivated,
    reactivatedAt: reactivatedAt,
  );

  factory PlantisSubscriptionSyncEvent.expired({
    DateTime? expiredAt,
  }) => PlantisSubscriptionSyncEvent._(
    type: PlantisSubscriptionSyncEventType.expired,
    expiredAt: expiredAt,
  );

  factory PlantisSubscriptionSyncEvent.billingIssue({
    DateTime? gracePeriodEnds,
  }) => PlantisSubscriptionSyncEvent._(
    type: PlantisSubscriptionSyncEventType.billingIssue,
    gracePeriodEnds: gracePeriodEnds,
  );
}

/// Tipos de conflito entre dispositivos
enum ConflictType {
  premiumStatusMismatch,
  productMismatch,
  featuresMismatch,
  timestampMismatch,
}

/// Conflito entre dispositivos
class DeviceConflict {
  const DeviceConflict({
    required this.device1Id,
    required this.device2Id,
    required this.type,
    required this.detectedAt,
    required this.currentData,
    required this.conflictingData,
  });

  final String device1Id;
  final String device2Id;
  final ConflictType type;
  final DateTime detectedAt;
  final Map<String, dynamic> currentData;
  final Map<String, dynamic> conflictingData;
}

/// Resolução de conflito
class ConflictResolution {
  const ConflictResolution({
    required this.strategy,
    required this.winningDeviceId,
    required this.resolvedData,
    required this.resolvedAt,
  });

  final String strategy;
  final String winningDeviceId;
  final dynamic resolvedData;
  final DateTime resolvedAt;
}
