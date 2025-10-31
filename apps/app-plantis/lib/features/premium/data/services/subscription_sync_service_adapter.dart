import 'dart:async';
import 'package:core/core.dart';
import 'package:core/src/services/subscription/advanced/advanced_subscription_sync_service.dart';
import 'package:flutter/foundation.dart';

/// Adapter para manter compatibilidade com SubscriptionSyncService customizado
///
/// Wrappea AdvancedSubscriptionSyncService (Core) e expõe a interface original
/// do Plantis, preservando todas as features específicas:
/// - Plant limits (free: 5, premium: unlimited)
/// - Advanced notifications
/// - Data export
/// - Cloud backup
///
/// Este adapter elimina 1,085 linhas de código duplicado enquanto mantém
/// total compatibilidade com os 4 managers existentes (sync, features,
/// purchase, providers).
class SubscriptionSyncServiceAdapter {
  final AdvancedSubscriptionSyncService _advancedSync;
  final FirebaseFirestore _firestore;
  final IAuthRepository _authRepository;
  final IAnalyticsRepository _analytics;

  SubscriptionSyncServiceAdapter({
    required AdvancedSubscriptionSyncService advancedSync,
    FirebaseFirestore? firestore,
    required IAuthRepository authRepository,
    required IAnalyticsRepository analytics,
  }) : _advancedSync = advancedSync,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _authRepository = authRepository,
       _analytics = analytics;

  // ==================== Streams Controllers ====================

  final _syncEventsController =
      StreamController<PlantisSubscriptionSyncEvent>.broadcast();
  final _subscriptionController =
      StreamController<SubscriptionEntity?>.broadcast();

  StreamSubscription<SubscriptionEntity?>? _advancedSyncSubscription;

  /// Stream de eventos de sincronização (compatibilidade Plantis)
  Stream<PlantisSubscriptionSyncEvent> get syncEventsStream =>
      _syncEventsController.stream;

  /// Stream reativa da assinatura atual (compatibilidade Plantis)
  Stream<SubscriptionEntity?> get subscriptionStream =>
      _subscriptionController.stream;

  // ==================== Core Methods ====================

  /// Inicializa o adapter e conecta os streams
  Future<void> initialize() async {
    await _advancedSync.initialize();

    // Conecta stream do AdvancedSync ao stream do Plantis
    _advancedSyncSubscription = _advancedSync.subscriptionStream.listen((
      subscription,
    ) async {
      _subscriptionController.add(subscription);

      // Processa features específicas do Plantis
      await _processPlantisFeatures(subscription);

      // Emite evento de sucesso
      _syncEventsController.add(
        PlantisSubscriptionSyncEvent.success(
          subscription: subscription,
          syncedAt: DateTime.now(),
          premiumFeaturesEnabled: _getPremiumFeaturesEnabled(subscription),
        ),
      );
    });
  }

  /// Sincroniza status da assinatura (compatibilidade com interface original)
  Future<void> syncSubscriptionStatus() async {
    try {
      await _analytics.logEvent('plantis_subscription_sync_started');
      await _advancedSync.forceSync();

      final subscription = await _advancedSync.subscriptionStream.first;

      await _analytics.logEvent(
        'plantis_subscription_sync_completed',
        parameters: {
          'is_premium': (subscription?.isActive ?? false).toString(),
          'subscription_type': subscription?.productId ?? 'none',
          'tier': subscription?.tier.name ?? 'free',
          'premium_features_count': _getPremiumFeaturesEnabled(
            subscription,
          ).length.toString(),
        },
      );
    } catch (e) {
      await _analytics.logEvent(
        'plantis_subscription_sync_failed',
        parameters: {'error': e.toString()},
      );

      _syncEventsController.add(
        PlantisSubscriptionSyncEvent.failed(
          error: e.toString(),
          failedAt: DateTime.now(),
          retryCount: 0,
        ),
      );
      rethrow;
    }
  }

  /// Processa webhooks do RevenueCat (mantém compatibilidade)
  Future<void> processRevenueCatWebhook(
    Map<String, dynamic> webhookData,
  ) async {
    try {
      final eventType = webhookData['event']?['type'] as String?;
      final userId = webhookData['event']?['app_user_id'] as String?;

      if (eventType == null || userId == null) {
        throw ArgumentError('Webhook inválido: missing event type or user ID');
      }

      await _analytics.logEvent(
        'plantis_revenuecat_webhook_received',
        parameters: {'event_type': eventType, 'user_id': userId},
      );

      // Mapeia evento para Plantis event type
      switch (eventType) {
        case 'INITIAL_PURCHASE':
          _syncEventsController.add(
            PlantisSubscriptionSyncEvent.purchased(
              productId: webhookData['event']?['product_id'] as String?,
              purchasedAt: DateTime.now(),
            ),
          );
          break;
        case 'RENEWAL':
          _syncEventsController.add(
            PlantisSubscriptionSyncEvent.renewed(renewedAt: DateTime.now()),
          );
          break;
        case 'CANCELLATION':
          _syncEventsController.add(
            PlantisSubscriptionSyncEvent.cancelled(cancelledAt: DateTime.now()),
          );
          break;
        case 'UNCANCELLATION':
          _syncEventsController.add(
            PlantisSubscriptionSyncEvent.reactivated(
              reactivatedAt: DateTime.now(),
            ),
          );
          break;
        case 'EXPIRATION':
          _syncEventsController.add(
            PlantisSubscriptionSyncEvent.expired(expiredAt: DateTime.now()),
          );
          break;
        case 'BILLING_ISSUE':
          _syncEventsController.add(
            PlantisSubscriptionSyncEvent.billingIssue(),
          );
          break;
        default:
          await _analytics.logEvent(
            'plantis_unhandled_webhook_event',
            parameters: {'event_type': eventType},
          );
      }

      // Força sync após webhook
      await syncSubscriptionStatus();
    } catch (e) {
      await _analytics.logEvent(
        'plantis_webhook_processing_failed',
        parameters: {
          'webhook_data': webhookData.toString(),
          'error': e.toString(),
        },
      );
      rethrow;
    }
  }

  /// Stream em tempo real da assinatura (mantém compatibilidade)
  Stream<SubscriptionEntity?> getRealtimeSubscriptionStream() {
    return _advancedSync.subscriptionStream;
  }

  /// Log de evento de compra (mantém compatibilidade)
  Future<void> logPurchaseEvent({
    required String productId,
    required String purchaseToken,
    String? transactionId,
  }) async {
    await _analytics.logEvent(
      'plantis_premium_purchase',
      parameters: {
        'product_id': productId,
        'purchase_token': purchaseToken,
        if (transactionId != null) 'transaction_id': transactionId,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      },
    );
  }

  /// Dispose de recursos
  void dispose() {
    _advancedSyncSubscription?.cancel();
    _syncEventsController.close();
    _subscriptionController.close();
    _advancedSync.dispose();
  }

  // ==================== Plantis-Specific Features ====================

  /// Processa features específicas do Plantis
  Future<void> _processPlantisFeatures(SubscriptionEntity? subscription) async {
    try {
      final currentUser = await _getCurrentUser();
      if (currentUser == null) return;

      final isPremium = subscription?.isActive ?? false;

      // 1. Plant Limits
      await _updatePlantLimits(currentUser.id, isPremium);

      // 2. Premium Features
      await _updatePremiumFeatures(currentUser.id, isPremium, subscription);

      // 3. Advanced Notifications
      if (isPremium) {
        await _enableAdvancedNotifications(currentUser.id);
      } else {
        await _disableAdvancedNotifications(currentUser.id);
      }

      // 4. Cloud Backup
      await _configurePlantisCloudBackup(
        userId: currentUser.id,
        enabled: isPremium,
        autoBackup: isPremium,
      );

      await _analytics.logEvent(
        'plantis_features_processed',
        parameters: {
          'user_id': currentUser.id,
          'is_premium': isPremium.toString(),
          'plant_limit': (isPremium ? 'unlimited' : '5'),
        },
      );
    } catch (e) {
      debugPrint('[PlantisAdapter] Erro ao processar features: $e');
      await _analytics.logEvent(
        'plantis_features_processing_failed',
        parameters: {'error': e.toString()},
      );
    }
  }

  /// 1. PLANT LIMITS: Atualiza limites de plantas
  Future<void> _updatePlantLimits(String userId, bool isPremium) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'plantLimitOverride': isPremium ? -1 : 5, // -1 = ilimitado
        'isPremium': isPremium,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      debugPrint(
        '[PlantisAdapter] Plant limit updated: ${isPremium ? "unlimited" : "5"}',
      );
    } catch (e) {
      debugPrint('[PlantisAdapter] Erro ao atualizar plant limits: $e');
    }
  }

  /// 2. PREMIUM FEATURES: Habilita/desabilita features premium
  Future<void> _updatePremiumFeatures(
    String userId,
    bool isPremium,
    SubscriptionEntity? subscription,
  ) async {
    try {
      final features = {
        'canUseAdvancedReminders': isPremium,
        'canExportData': isPremium,
        'hasCloudBackup': isPremium,
        'hasUnlimitedPlants': isPremium,
        'premiumTier': isPremium
            ? (subscription?.tier.name ?? 'premium')
            : 'free',
        'featuresUpdatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('premium_features')
          .doc('current')
          .set(features, SetOptions(merge: true));

      debugPrint('[PlantisAdapter] Premium features updated: $features');
    } catch (e) {
      debugPrint('[PlantisAdapter] Erro ao atualizar premium features: $e');
    }
  }

  /// 3. ADVANCED NOTIFICATIONS: Habilita notificações avançadas
  Future<void> _enableAdvancedNotifications(String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('notifications')
          .set({
            'advancedEnabled': true,
            'customReminders': true,
            'multipleRemindersPerPlant': true,
            'weatherBasedNotifications': true,
            'enabledAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      debugPrint('[PlantisAdapter] Advanced notifications enabled');
    } catch (e) {
      debugPrint('[PlantisAdapter] Erro ao habilitar notificações: $e');
    }
  }

  /// 4. ADVANCED NOTIFICATIONS: Desabilita notificações avançadas
  Future<void> _disableAdvancedNotifications(String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('notifications')
          .set({
            'advancedEnabled': false,
            'customReminders': false,
            'multipleRemindersPerPlant': false,
            'weatherBasedNotifications': false,
            'disabledAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      debugPrint('[PlantisAdapter] Advanced notifications disabled');
    } catch (e) {
      debugPrint('[PlantisAdapter] Erro ao desabilitar notificações: $e');
    }
  }

  /// 5. CLOUD BACKUP: Configura backup em nuvem
  Future<void> _configurePlantisCloudBackup({
    required String userId,
    required bool enabled,
    required bool autoBackup,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('backup')
          .set({
            'cloudBackupEnabled': enabled,
            'autoBackup': autoBackup,
            'frequency': autoBackup ? 'daily' : 'manual',
            'lastConfiguredAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      debugPrint(
        '[PlantisAdapter] Cloud backup configured: enabled=$enabled, auto=$autoBackup',
      );
    } catch (e) {
      debugPrint('[PlantisAdapter] Erro ao configurar backup: $e');
    }
  }

  // ==================== Helper Methods ====================

  /// Obtém usuário atual
  Future<UserEntity?> _getCurrentUser() async {
    try {
      return await _authRepository.currentUser.first;
    } catch (e) {
      debugPrint('[PlantisAdapter] Erro ao obter usuário: $e');
      return null;
    }
  }

  /// Lista de features premium habilitadas
  List<String> _getPremiumFeaturesEnabled(SubscriptionEntity? subscription) {
    if (subscription?.isActive != true) return [];

    return [
      'unlimited_plants',
      'advanced_notifications',
      'data_export',
      'cloud_backup',
    ];
  }
}

// ==================== Events & Types (Mantém compatibilidade) ====================

/// Eventos de sincronização Plantis (mantém interface original)
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

/// Evento de sincronização Plantis (mantém interface original)
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

  factory PlantisSubscriptionSyncEvent.reactivated({DateTime? reactivatedAt}) =>
      PlantisSubscriptionSyncEvent._(
        type: PlantisSubscriptionSyncEventType.reactivated,
        reactivatedAt: reactivatedAt,
      );

  factory PlantisSubscriptionSyncEvent.expired({DateTime? expiredAt}) =>
      PlantisSubscriptionSyncEvent._(
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
