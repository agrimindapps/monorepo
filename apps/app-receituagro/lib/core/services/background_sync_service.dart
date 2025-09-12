import 'dart:async';
import 'dart:developer' as developer;
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../features/analytics/analytics_service.dart';
import 'firestore_sync_service.dart';

/// Serviço de sincronização em background
class BackgroundSyncService {
  BackgroundSyncService({
    required this.syncService,
    required this.analytics,
    required this.storage,
  });

  final FirestoreSyncService syncService;
  final ReceitaAgroAnalyticsService analytics;
  final HiveStorageService storage;

  bool _isInitialized = false;
  Timer? _periodicTimer;
  Timer? _retryTimer;

  /// Inicializa o serviço de background sync
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Configurar sync periódico
      await _scheduleForegroundSync();

      // Configurar retry automático
      await _setupRetryMechanism();

      _isInitialized = true;

      await analytics.logEvent(ReceitaAgroAnalyticsEvent.featureUsed, parameters: {
        'feature_name': 'background_sync_initialized',
        'initialized_at': DateTime.now().toIso8601String(),
      });

    } catch (e) {
      await analytics.recordError(e, null, reason: 'background_sync_initialization_failed');
      rethrow;
    }
  }

  /// Configura sincronização periódica em foreground
  Future<void> _scheduleForegroundSync() async {
    const syncInterval = Duration(minutes: 5);

    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(syncInterval, (timer) async {
      await _performPeriodicSync();
    });

    await analytics.logEvent(ReceitaAgroAnalyticsEvent.featureUsed, parameters: {
      'feature_name': 'foreground_sync_scheduled',
      'interval_minutes': syncInterval.inMinutes.toString(),
    });
  }

  /// Configura mecanismo de retry
  Future<void> _setupRetryMechanism() async {
    // Escutar falhas de sync para retry automático
    syncService.syncStatusStream.listen((status) {
      if (status.state == SyncState.error) {
        _scheduleRetry();
      }
    });
  }

  /// Executa sync periódico em foreground
  Future<void> _performPeriodicSync() async {
    try {
      final startTime = DateTime.now();
      
      await analytics.logEvent(ReceitaAgroAnalyticsEvent.featureUsed, parameters: {
        'feature_name': 'sync_started',
        'sync_type': 'periodic',
        'timestamp': DateTime.now().toIso8601String(),
      });

      final result = await syncService.syncNow(force: false);
      final duration = DateTime.now().difference(startTime);

      if (result.success) {
        await analytics.logEvent(ReceitaAgroAnalyticsEvent.featureUsed, parameters: {
          'feature_name': 'sync_completed',
          'sync_type': 'periodic',
          'duration': duration.inMilliseconds.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        });
      } else {
        await analytics.logEvent(ReceitaAgroAnalyticsEvent.errorOccurred, parameters: {
          'error_type': 'sync_failed',
          'sync_type': 'periodic',
          'error': result.message ?? 'Unknown error',
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      await analytics.recordError(e, null, reason: 'periodic_sync_error');
    }
  }

  /// Agenda retry de sincronização
  void _scheduleRetry() {
    _retryTimer?.cancel();
    
    // Implementar exponential backoff
    const baseDelay = Duration(seconds: 30);
    _getRetryCount().then((retryCount) {
      final multiplier = (retryCount + 1).clamp(1, 8);
      final delay = Duration(seconds: baseDelay.inSeconds * multiplier);
      
      _retryTimer = Timer(delay, () async {
        await _performRetrySync(retryCount + 1);
      });

      analytics.logEvent(ReceitaAgroAnalyticsEvent.featureUsed, parameters: {
        'feature_name': 'sync_retry_scheduled',
        'retry_count': retryCount.toString(),
        'delay_seconds': delay.inSeconds.toString(),
      });
    });
  }

  /// Executa retry de sincronização
  Future<void> _performRetrySync(int retryCount) async {
    try {
      await analytics.logEvent(ReceitaAgroAnalyticsEvent.featureUsed, parameters: {
        'feature_name': 'sync_retry_started',
        'retry_count': retryCount.toString(),
      });

      final result = await syncService.syncNow(force: true);
      
      if (result.success) {
        // Reset retry count
        await _setRetryCount(0);
        
        await analytics.logEvent(ReceitaAgroAnalyticsEvent.featureUsed, parameters: {
          'feature_name': 'sync_retry_succeeded',
          'retry_count': retryCount.toString(),
          'operations_sent': result.operationsSent.toString(),
        });
      } else {
        // Incrementar retry count
        await _setRetryCount(retryCount);
        
        await analytics.logEvent(ReceitaAgroAnalyticsEvent.errorOccurred, parameters: {
          'error_type': 'sync_retry_failed',
          'retry_count': retryCount.toString(),
          'error': result.message ?? 'Unknown error',
        });
      }
    } catch (e) {
      await analytics.recordError(e, null, reason: 'sync_retry_error', additionalData: {
        'retry_count': retryCount.toString(),
      });
    }
  }

  /// Executa sincronização imediata
  Future<void> syncImmediately() async {
    try {
      await analytics.logEvent(ReceitaAgroAnalyticsEvent.featureUsed, parameters: {
        'feature_name': 'sync_immediate_started',
      });
      
      // Realizar sync imediatamente via syncService
      await syncService.syncNow(force: true);
    } catch (e) {
      await analytics.recordError(e, null, reason: 'immediate_sync_failed');
    }
  }

  /// Agenda sync em background quando há conectividade
  Future<void> scheduleConnectivityBasedSync() async {
    try {
      await analytics.logEvent(ReceitaAgroAnalyticsEvent.featureUsed, parameters: {
        'feature_name': 'sync_background_requested',
      });
      
      // Por enquanto, apenas perform sync imediato
      await syncImmediately();
    } catch (e) {
      await analytics.recordError(e, null, reason: 'connectivity_sync_schedule_failed');
    }
  }

  /// Cancela todas as tarefas de background
  Future<void> cancelBackgroundTasks() async {
    try {
      _periodicTimer?.cancel();
      _retryTimer?.cancel();
    } catch (e) {
      await analytics.recordError(e, null, reason: 'background_tasks_clear_failed');
    }
  }

  /// Obtém contador de retry
  Future<int> _getRetryCount() async {
    final value = await storage.get(key: 'sync_metadata_retry_count');
    return (value as int?) ?? 0;
  }

  /// Define contador de retry
  Future<void> _setRetryCount(int retryCount) async {
    await storage.put(key: 'sync_metadata_retry_count', data: retryCount);
  }

  /// Obtém configuração de retry
  Map<String, int> getRetryConfig() {
    return {
      'max_retries': 5,
      'base_delay_seconds': 30,
      'max_delay_seconds': 300,
    };
  }

  /// Obtém estatísticas de sincronização
  Map<String, dynamic> getSyncStats() {
    return {
      'is_initialized': _isInitialized,
      'has_periodic_timer': _periodicTimer?.isActive ?? false,
      'has_retry_timer': _retryTimer?.isActive ?? false,
      'last_sync_attempt': DateTime.now().toIso8601String(),
    };
  }

  /// Limpa recursos
  Future<void> dispose() async {
    _periodicTimer?.cancel();
    _retryTimer?.cancel();
    await cancelBackgroundTasks();
  }
}