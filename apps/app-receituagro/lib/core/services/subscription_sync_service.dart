import 'dart:async';
import 'package:core/core.dart';
import 'firestore_sync_service.dart';
import 'device_identity_service.dart';

/// Serviço de sincronização de assinaturas com RevenueCat
class SubscriptionSyncService {
  SubscriptionSyncService({
    required this.syncService,
    required this.premiumService,
    required this.deviceService,
    required this.analytics,
    required this.storage,
  });

  final FirestoreSyncService syncService;
  final PremiumService premiumService;
  final DeviceIdentityService deviceService;
  final AnalyticsService analytics;
  final HiveStorageService storage;

  final _subscriptionController = StreamController<SubscriptionSyncEvent>.broadcast();
  
  /// Stream de eventos de sincronização de assinatura
  Stream<SubscriptionSyncEvent> get syncEventStream => _subscriptionController.stream;

  /// Sincroniza status da assinatura com todos os dispositivos
  Future<void> syncSubscriptionStatus() async {
    try {
      analytics.logEvent('subscription_sync_started');

      // 1. Obter status atual do RevenueCat
      final currentStatus = await premiumService.getPremiumStatus();
      
      // 2. Obter informações do dispositivo
      final deviceInfo = await deviceService.getDeviceInfo();

      // 3. Preparar dados para sincronização
      final subscriptionData = await _prepareSubscriptionData(currentStatus, deviceInfo);

      // 4. Criar operação de sincronização
      final syncOperation = SyncOperation(
        id: 'subscription_${deviceInfo.uuid}',
        collection: 'user_subscription_status',
        operation: SyncOperationType.update,
        timestamp: DateTime.now(),
        data: subscriptionData,
      );

      // 5. Adicionar à queue de sincronização
      await syncService.queueOperation(syncOperation);

      // 6. Forçar sincronização imediata
      final result = await syncService.syncNow();

      if (result.success) {
        await _updateLocalSubscriptionStatus(subscriptionData);
        
        _subscriptionController.add(SubscriptionSyncEvent.success(
          deviceId: deviceInfo.uuid,
          subscriptionData: subscriptionData,
          syncedAt: DateTime.now(),
        ));

        analytics.logEvent('subscription_sync_completed', parameters: {
          'is_premium': currentStatus.isPremium.toString(),
          'subscription_type': currentStatus.productId ?? 'none',
          'operations_sent': result.operationsSent.toString(),
        });
      } else {
        throw Exception('Sync failed: ${result.message}');
      }

    } catch (e) {
      analytics.logError('subscription_sync_failed', e, null);
      
      _subscriptionController.add(SubscriptionSyncEvent.failed(
        error: e.toString(),
        failedAt: DateTime.now(),
      ));
      
      rethrow;
    }
  }

  /// Processa webhook do RevenueCat
  Future<void> processRevenueCatWebhook(Map<String, dynamic> webhookData) async {
    try {
      final eventType = webhookData['event']?['type'] as String?;
      final userId = webhookData['event']?['app_user_id'] as String?;

      if (eventType == null || userId == null) {
        throw ArgumentError('Invalid webhook data: missing event type or user ID');
      }

      analytics.logEvent('revenuecat_webhook_received', parameters: {
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
          analytics.logEvent('unhandled_webhook_event', parameters: {
            'event_type': eventType,
          });
      }

      // Sempre sincronizar após processar webhook
      await syncSubscriptionStatus();

    } catch (e) {
      analytics.logError('webhook_processing_failed', e, {
        'webhook_data': webhookData.toString(),
      });
      rethrow;
    }
  }

  /// Prepara dados de assinatura para sincronização
  Future<Map<String, dynamic>> _prepareSubscriptionData(
    PremiumStatus status,
    DeviceInfo deviceInfo,
  ) async {
    return {
      'userId': status.userId,
      'deviceId': deviceInfo.uuid,
      'isPremium': status.isPremium,
      'productId': status.productId,
      'purchaseDate': status.purchaseDate?.millisecondsSinceEpoch,
      'expirationDate': status.expirationDate?.millisecondsSinceEpoch,
      'isActive': status.isActive,
      'willRenew': status.willRenew,
      'periodType': status.periodType,
      'store': status.store,
      'environment': status.environment,
      'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      'syncedFrom': deviceInfo.platform,
      'appVersion': deviceInfo.appVersion,
      
      // Metadados de sincronização
      'syncVersion': await _getNextSyncVersion(),
      'conflictResolutionStrategy': 'server_wins', // Servidor sempre ganha para assinaturas
    };
  }

  /// Atualiza status local da assinatura
  Future<void> _updateLocalSubscriptionStatus(Map<String, dynamic> subscriptionData) async {
    final subscriptionBox = await storage.openBox('subscription_sync_status');
    
    await subscriptionBox.put('current_status', subscriptionData);
    await subscriptionBox.put('last_sync', DateTime.now().millisecondsSinceEpoch);
  }

  /// Handlers para diferentes eventos de webhook

  Future<void> _handleInitialPurchase(Map<String, dynamic> webhookData) async {
    final event = webhookData['event'] as Map<String, dynamic>;
    
    analytics.logEvent('subscription_initial_purchase', parameters: {
      'product_id': event['product_id']?.toString() ?? 'unknown',
      'store': event['store']?.toString() ?? 'unknown',
      'environment': event['environment']?.toString() ?? 'unknown',
    });

    // Forçar atualização imediata do status premium
    await premiumService.refreshPremiumStatus();
  }

  Future<void> _handleRenewal(Map<String, dynamic> webhookData) async {
    final event = webhookData['event'] as Map<String, dynamic>;
    
    analytics.logEvent('subscription_renewal', parameters: {
      'product_id': event['product_id']?.toString() ?? 'unknown',
      'expiration_date': event['expiration_at_ms']?.toString() ?? 'unknown',
    });

    await premiumService.refreshPremiumStatus();
  }

  Future<void> _handleCancellation(Map<String, dynamic> webhookData) async {
    final event = webhookData['event'] as Map<String, dynamic>;
    
    analytics.logEvent('subscription_cancellation', parameters: {
      'cancel_reason': event['cancel_reason']?.toString() ?? 'unknown',
      'will_expire_at': event['expiration_at_ms']?.toString() ?? 'unknown',
    });

    await premiumService.refreshPremiumStatus();
    
    // Notificar cancelamento
    _subscriptionController.add(SubscriptionSyncEvent.cancelled(
      reason: event['cancel_reason']?.toString(),
      expiresAt: event['expiration_at_ms'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(event['expiration_at_ms'] as int)
          : null,
    ));
  }

  Future<void> _handleUncancellation(Map<String, dynamic> webhookData) async {
    analytics.logEvent('subscription_uncancellation');
    
    await premiumService.refreshPremiumStatus();
    
    _subscriptionController.add(SubscriptionSyncEvent.reactivated(
      reactivatedAt: DateTime.now(),
    ));
  }

  Future<void> _handleExpiration(Map<String, dynamic> webhookData) async {
    analytics.logEvent('subscription_expiration');
    
    await premiumService.refreshPremiumStatus();
    
    _subscriptionController.add(SubscriptionSyncEvent.expired(
      expiredAt: DateTime.now(),
    ));
  }

  Future<void> _handleBillingIssue(Map<String, dynamic> webhookData) async {
    final event = webhookData['event'] as Map<String, dynamic>;
    
    analytics.logEvent('subscription_billing_issue', parameters: {
      'grace_period_expires': event['grace_period_expiration_at_ms']?.toString() ?? 'unknown',
    });

    _subscriptionController.add(SubscriptionSyncEvent.billingIssue(
      gracePeriodEnds: event['grace_period_expiration_at_ms'] != null
          ? DateTime.fromMillisecondsSinceEpoch(event['grace_period_expiration_at_ms'] as int)
          : null,
    ));
  }

  Future<void> _handleProductChange(Map<String, dynamic> webhookData) async {
    final event = webhookData['event'] as Map<String, dynamic>;
    
    analytics.logEvent('subscription_product_change', parameters: {
      'old_product': event['product_id']?.toString() ?? 'unknown',
      'new_product': event['new_product_id']?.toString() ?? 'unknown',
    });

    await premiumService.refreshPremiumStatus();
  }

  /// Obtém próxima versão de sincronização
  Future<int> _getNextSyncVersion() async {
    final subscriptionBox = await storage.openBox('subscription_sync_status');
    final currentVersion = subscriptionBox.get('sync_version', defaultValue: 0) as int;
    final nextVersion = currentVersion + 1;
    
    await subscriptionBox.put('sync_version', nextVersion);
    return nextVersion;
  }

  /// Verifica se há conflitos de assinatura entre dispositivos
  Future<List<SubscriptionConflict>> checkSubscriptionConflicts() async {
    try {
      // Obter status de todos os dispositivos
      final deviceStatuses = await _getAllDeviceSubscriptionStatuses();
      
      final conflicts = <SubscriptionConflict>[];
      
      // Verificar inconsistências
      for (int i = 0; i < deviceStatuses.length; i++) {
        for (int j = i + 1; j < deviceStatuses.length; j++) {
          final status1 = deviceStatuses[i];
          final status2 = deviceStatuses[j];
          
          if (_hasSubscriptionConflict(status1, status2)) {
            conflicts.add(SubscriptionConflict(
              device1: status1,
              device2: status2,
              conflictType: _determineConflictType(status1, status2),
              detectedAt: DateTime.now(),
            ));
          }
        }
      }

      if (conflicts.isNotEmpty) {
        analytics.logEvent('subscription_conflicts_detected', parameters: {
          'conflict_count': conflicts.length.toString(),
        });
      }

      return conflicts;
      
    } catch (e) {
      analytics.logError('subscription_conflict_check_failed', e, null);
      return [];
    }
  }

  /// Resolve conflitos de assinatura automaticamente
  Future<void> resolveSubscriptionConflicts(List<SubscriptionConflict> conflicts) async {
    for (final conflict in conflicts) {
      try {
        // Para assinaturas, sempre usar dados do servidor/RevenueCat como fonte da verdade
        final resolution = await _resolveSubscriptionConflict(conflict);
        
        analytics.logEvent('subscription_conflict_resolved', parameters: {
          'conflict_type': conflict.conflictType.toString(),
          'resolution_strategy': resolution.strategy,
        });
        
      } catch (e) {
        analytics.logError('subscription_conflict_resolution_failed', e, {
          'conflict_type': conflict.conflictType.toString(),
        });
      }
    }
  }

  /// Resolve conflito específico de assinatura
  Future<SubscriptionConflictResolution> _resolveSubscriptionConflict(
    SubscriptionConflict conflict,
  ) async {
    // Para assinaturas, sempre priorizar dados mais recentes ou do RevenueCat
    final newerStatus = conflict.device1.lastUpdated.isAfter(conflict.device2.lastUpdated)
        ? conflict.device1
        : conflict.device2;

    // Aplicar resolução
    await _applySubscriptionResolution(newerStatus);

    return SubscriptionConflictResolution(
      strategy: 'use_newer_timestamp',
      appliedStatus: newerStatus,
      resolvedAt: DateTime.now(),
    );
  }

  Future<void> _applySubscriptionResolution(DeviceSubscriptionStatus status) async {
    // Atualizar status local
    await _updateLocalSubscriptionStatus(status.data);
    
    // Sincronizar com outros dispositivos
    await syncSubscriptionStatus();
  }

  /// Obtém status de assinatura de todos os dispositivos
  Future<List<DeviceSubscriptionStatus>> _getAllDeviceSubscriptionStatuses() async {
    // Esta função obteria dados de todos os dispositivos via Firestore
    // Por enquanto, retornar apenas status local
    final subscriptionBox = await storage.openBox('subscription_sync_status');
    final localStatus = subscriptionBox.get('current_status') as Map<String, dynamic>?;
    
    if (localStatus == null) return [];

    final deviceId = await deviceService.getDeviceUuid();
    
    return [
      DeviceSubscriptionStatus(
        deviceId: deviceId,
        data: localStatus,
        lastUpdated: DateTime.fromMillisecondsSinceEpoch(
          localStatus['lastUpdated'] as int? ?? DateTime.now().millisecondsSinceEpoch
        ),
      ),
    ];
  }

  /// Verifica se há conflito entre dois status de assinatura
  bool _hasSubscriptionConflict(
    DeviceSubscriptionStatus status1,
    DeviceSubscriptionStatus status2,
  ) {
    // Verificar se há diferenças significativas
    return status1.data['isPremium'] != status2.data['isPremium'] ||
           status1.data['productId'] != status2.data['productId'] ||
           status1.data['isActive'] != status2.data['isActive'];
  }

  /// Determina tipo de conflito
  SubscriptionConflictType _determineConflictType(
    DeviceSubscriptionStatus status1,
    DeviceSubscriptionStatus status2,
  ) {
    if (status1.data['isPremium'] != status2.data['isPremium']) {
      return SubscriptionConflictType.premiumStatusMismatch;
    }
    
    if (status1.data['productId'] != status2.data['productId']) {
      return SubscriptionConflictType.productMismatch;
    }
    
    if (status1.data['isActive'] != status2.data['isActive']) {
      return SubscriptionConflictType.activeStatusMismatch;
    }
    
    return SubscriptionConflictType.other;
  }

  /// Obtém estatísticas de sincronização de assinatura
  Future<SubscriptionSyncStats> getStats() async {
    final subscriptionBox = await storage.openBox('subscription_sync_status');
    
    return SubscriptionSyncStats(
      lastSyncTimestamp: _getTimestamp(subscriptionBox, 'last_sync'),
      totalSyncs: subscriptionBox.get('total_syncs', defaultValue: 0) as int,
      totalFailures: subscriptionBox.get('total_failures', defaultValue: 0) as int,
      lastConflictCheck: _getTimestamp(subscriptionBox, 'last_conflict_check'),
      conflictsResolved: subscriptionBox.get('conflicts_resolved', defaultValue: 0) as int,
    );
  }

  DateTime? _getTimestamp(Box box, String key) {
    final timestamp = box.get(key) as int?;
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  /// Dispose dos recursos
  void dispose() {
    _subscriptionController.close();
  }
}

// Modelos de dados para subscription sync

enum SubscriptionSyncEventType {
  success,
  failed,
  cancelled,
  reactivated,
  expired,
  billingIssue,
}

class SubscriptionSyncEvent {
  const SubscriptionSyncEvent._({
    required this.type,
    this.deviceId,
    this.subscriptionData,
    this.syncedAt,
    this.error,
    this.failedAt,
    this.reason,
    this.expiresAt,
    this.reactivatedAt,
    this.expiredAt,
    this.gracePeriodEnds,
  });

  final SubscriptionSyncEventType type;
  final String? deviceId;
  final Map<String, dynamic>? subscriptionData;
  final DateTime? syncedAt;
  final String? error;
  final DateTime? failedAt;
  final String? reason;
  final DateTime? expiresAt;
  final DateTime? reactivatedAt;
  final DateTime? expiredAt;
  final DateTime? gracePeriodEnds;

  factory SubscriptionSyncEvent.success({
    required String deviceId,
    required Map<String, dynamic> subscriptionData,
    required DateTime syncedAt,
  }) => SubscriptionSyncEvent._(
    type: SubscriptionSyncEventType.success,
    deviceId: deviceId,
    subscriptionData: subscriptionData,
    syncedAt: syncedAt,
  );

  factory SubscriptionSyncEvent.failed({
    required String error,
    required DateTime failedAt,
  }) => SubscriptionSyncEvent._(
    type: SubscriptionSyncEventType.failed,
    error: error,
    failedAt: failedAt,
  );

  factory SubscriptionSyncEvent.cancelled({
    String? reason,
    DateTime? expiresAt,
  }) => SubscriptionSyncEvent._(
    type: SubscriptionSyncEventType.cancelled,
    reason: reason,
    expiresAt: expiresAt,
  );

  factory SubscriptionSyncEvent.reactivated({
    required DateTime reactivatedAt,
  }) => SubscriptionSyncEvent._(
    type: SubscriptionSyncEventType.reactivated,
    reactivatedAt: reactivatedAt,
  );

  factory SubscriptionSyncEvent.expired({
    required DateTime expiredAt,
  }) => SubscriptionSyncEvent._(
    type: SubscriptionSyncEventType.expired,
    expiredAt: expiredAt,
  );

  factory SubscriptionSyncEvent.billingIssue({
    DateTime? gracePeriodEnds,
  }) => SubscriptionSyncEvent._(
    type: SubscriptionSyncEventType.billingIssue,
    gracePeriodEnds: gracePeriodEnds,
  );
}

enum SubscriptionConflictType {
  premiumStatusMismatch,
  productMismatch,
  activeStatusMismatch,
  other,
}

class DeviceSubscriptionStatus {
  const DeviceSubscriptionStatus({
    required this.deviceId,
    required this.data,
    required this.lastUpdated,
  });

  final String deviceId;
  final Map<String, dynamic> data;
  final DateTime lastUpdated;
}

class SubscriptionConflict {
  const SubscriptionConflict({
    required this.device1,
    required this.device2,
    required this.conflictType,
    required this.detectedAt,
  });

  final DeviceSubscriptionStatus device1;
  final DeviceSubscriptionStatus device2;
  final SubscriptionConflictType conflictType;
  final DateTime detectedAt;
}

class SubscriptionConflictResolution {
  const SubscriptionConflictResolution({
    required this.strategy,
    required this.appliedStatus,
    required this.resolvedAt,
  });

  final String strategy;
  final DeviceSubscriptionStatus appliedStatus;
  final DateTime resolvedAt;
}

class SubscriptionSyncStats {
  const SubscriptionSyncStats({
    this.lastSyncTimestamp,
    required this.totalSyncs,
    required this.totalFailures,
    this.lastConflictCheck,
    required this.conflictsResolved,
  });

  final DateTime? lastSyncTimestamp;
  final int totalSyncs;
  final int totalFailures;
  final DateTime? lastConflictCheck;
  final int conflictsResolved;

  double get successRate {
    final total = totalSyncs + totalFailures;
    return total > 0 ? totalSyncs / total : 1.0;
  }
}