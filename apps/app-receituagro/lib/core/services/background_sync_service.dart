import 'dart:async';
import 'dart:isolate';
import 'package:core/core.dart';
import 'package:workmanager/workmanager.dart';
import 'firestore_sync_service.dart';

/// Serviço de sincronização em background
class BackgroundSyncService {
  BackgroundSyncService({
    required this.syncService,
    required this.analytics,
    required this.storage,
  });

  final FirestoreSyncService syncService;
  final AnalyticsService analytics;
  final HiveStorageService storage;

  static const String _periodicSyncTask = 'PERIODIC_SYNC_TASK';
  static const String _immediateSync = 'IMMEDIATE_SYNC';
  static const String _retrySync = 'RETRY_SYNC';

  bool _isInitialized = false;
  Timer? _periodicTimer;
  Timer? _retryTimer;

  /// Inicializa o serviço de background sync
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Configurar WorkManager
      await _initializeWorkManager();

      // Configurar sync periódico
      await _scheduleForegroundSync();

      // Configurar retry automático
      await _setupRetryMechanism();

      _isInitialized = true;

      analytics.logEvent('background_sync_initialized', parameters: {
        'initialized_at': DateTime.now().toIso8601String(),
      });

    } catch (e) {
      analytics.logError('background_sync_initialization_failed', e, null);
      rethrow;
    }
  }

  /// Inicializa WorkManager para background tasks
  Future<void> _initializeWorkManager() async {
    await Workmanager().initialize(
      callbackDispatcher, // Top-level function
      isInDebugMode: false,
    );

    // Agendar sync periódico em background
    await Workmanager().registerPeriodicTask(
      'periodicSync',
      _periodicSyncTask,
      frequency: const Duration(minutes: 15), // Mínimo do Android
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
    );

    analytics.logEvent('workmanager_configured');
  }

  /// Configura sincronização periódica em foreground
  Future<void> _scheduleForegroundSync() async {
    const syncInterval = Duration(minutes: 5);

    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(syncInterval, (timer) async {
      await _performPeriodicSync();
    });

    analytics.logEvent('foreground_sync_scheduled', parameters: {
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
      final stats = await syncService.getStats();
      
      // Só sincronizar se houver operações pendentes ou não sincronizou recentemente
      if (stats.pendingOperations > 0 || 
          _shouldPerformPeriodicSync(stats.lastSyncTimestamp)) {
        
        analytics.logEvent('periodic_sync_started', parameters: {
          'pending_operations': stats.pendingOperations.toString(),
          'is_online': stats.isOnline.toString(),
        });

        final result = await syncService.syncNow();
        
        if (result.success) {
          analytics.logEvent('periodic_sync_completed', parameters: {
            'operations_sent': result.operationsSent.toString(),
            'operations_received': result.operationsReceived.toString(),
          });
        } else {
          analytics.logEvent('periodic_sync_failed', parameters: {
            'error': result.message ?? 'Unknown error',
          });
        }
      }
    } catch (e) {
      analytics.logError('periodic_sync_error', e, null);
    }
  }

  /// Verifica se deve executar sync periódico
  bool _shouldPerformPeriodicSync(DateTime? lastSync) {
    if (lastSync == null) return true;
    
    const minSyncInterval = Duration(minutes: 5);
    return DateTime.now().difference(lastSync) > minSyncInterval;
  }

  /// Agenda retry após falha
  void _scheduleRetry() {
    _retryTimer?.cancel();
    
    // Retry exponential backoff: 30s, 1m, 2m, 4m, 8m (max)
    const retryDelays = [
      Duration(seconds: 30),
      Duration(minutes: 1),
      Duration(minutes: 2),
      Duration(minutes: 4),
      Duration(minutes: 8),
    ];

    // Obter número de tentativas
    _getRetryCount().then((retryCount) {
      final delayIndex = retryCount.clamp(0, retryDelays.length - 1);
      final delay = retryDelays[delayIndex];

      _retryTimer = Timer(delay, () async {
        await _performRetrySync(retryCount + 1);
      });

      analytics.logEvent('sync_retry_scheduled', parameters: {
        'retry_count': retryCount.toString(),
        'delay_seconds': delay.inSeconds.toString(),
      });
    });
  }

  /// Executa retry de sincronização
  Future<void> _performRetrySync(int retryCount) async {
    try {
      analytics.logEvent('sync_retry_started', parameters: {
        'retry_count': retryCount.toString(),
      });

      final result = await syncService.syncNow(force: true);
      
      if (result.success) {
        // Reset retry count
        await _setRetryCount(0);
        
        analytics.logEvent('sync_retry_succeeded', parameters: {
          'retry_count': retryCount.toString(),
          'operations_sent': result.operationsSent.toString(),
        });
      } else {
        // Incrementar retry count
        await _setRetryCount(retryCount);
        
        analytics.logEvent('sync_retry_failed', parameters: {
          'retry_count': retryCount.toString(),
          'error': result.message ?? 'Unknown error',
        });
      }
    } catch (e) {
      analytics.logError('sync_retry_error', e, {
        'retry_count': retryCount.toString(),
      });
      
      await _setRetryCount(retryCount);
    }
  }

  /// Força sincronização imediata em background
  Future<void> forceSyncInBackground() async {
    try {
      await Workmanager().registerOneOffTask(
        'immediateSync${DateTime.now().millisecondsSinceEpoch}',
        _immediateSync,
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
      );

      analytics.logEvent('immediate_background_sync_scheduled');
    } catch (e) {
      analytics.logError('immediate_background_sync_failed', e, null);
    }
  }

  /// Agenda sync para quando a conectividade for restaurada
  Future<void> scheduleConnectivitySync() async {
    try {
      await Workmanager().registerOneOffTask(
        'connectivitySync${DateTime.now().millisecondsSinceEpoch}',
        _periodicSyncTask,
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
      );

      analytics.logEvent('connectivity_sync_scheduled');
    } catch (e) {
      analytics.logError('connectivity_sync_schedule_failed', e, null);
    }
  }

  /// Obtém contador de retry
  Future<int> _getRetryCount() async {
    final settingsBox = await storage.box('background_sync_settings');
    return settingsBox.get('retry_count', defaultValue: 0) as int;
  }

  /// Define contador de retry
  Future<void> _setRetryCount(int count) async {
    final settingsBox = await storage.box('background_sync_settings');
    await settingsBox.put('retry_count', count);
  }

  /// Limpa todas as tarefas em background
  Future<void> clearBackgroundTasks() async {
    try {
      await Workmanager().cancelAll();
      _periodicTimer?.cancel();
      _retryTimer?.cancel();

      analytics.logEvent('background_tasks_cleared');
    } catch (e) {
      analytics.logError('background_tasks_clear_failed', e, null);
    }
  }

  /// Reconfigura sync com novas configurações
  Future<void> reconfigureSync({
    Duration? foregroundInterval,
    Duration? backgroundInterval,
    bool? requiresBatteryNotLow,
    bool? requiresCharging,
  }) async {
    // Limpar configurações existentes
    await clearBackgroundTasks();

    // Reconfigurar com novos parâmetros
    if (backgroundInterval != null) {
      await Workmanager().registerPeriodicTask(
        'periodicSync',
        _periodicSyncTask,
        frequency: backgroundInterval,
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: requiresBatteryNotLow ?? true,
          requiresCharging: requiresCharging ?? false,
        ),
      );
    }

    if (foregroundInterval != null) {
      _periodicTimer?.cancel();
      _periodicTimer = Timer.periodic(foregroundInterval, (timer) async {
        await _performPeriodicSync();
      });
    }

    analytics.logEvent('sync_reconfigured', parameters: {
      'foreground_interval': foregroundInterval?.inMinutes.toString() ?? 'unchanged',
      'background_interval': backgroundInterval?.inMinutes.toString() ?? 'unchanged',
    });
  }

  /// Obtém estatísticas de background sync
  Future<BackgroundSyncStats> getStats() async {
    final settingsBox = await storage.box('background_sync_settings');
    
    return BackgroundSyncStats(
      isInitialized: _isInitialized,
      retryCount: await _getRetryCount(),
      lastPeriodicSync: _getTimestamp(settingsBox, 'last_periodic_sync'),
      lastBackgroundSync: _getTimestamp(settingsBox, 'last_background_sync'),
      totalBackgroundSyncs: settingsBox.get('total_background_syncs', defaultValue: 0) as int,
      totalFailedSyncs: settingsBox.get('total_failed_syncs', defaultValue: 0) as int,
    );
  }

  DateTime? _getTimestamp(Box box, String key) {
    final timestamp = box.get(key) as int?;
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  /// Registra estatística de sync
  Future<void> _recordSyncStat(String key, [bool increment = false]) async {
    final settingsBox = await storage.box('background_sync_settings');
    
    if (increment) {
      final current = settingsBox.get(key, defaultValue: 0) as int;
      await settingsBox.put(key, current + 1);
    } else {
      await settingsBox.put(key, DateTime.now().millisecondsSinceEpoch);
    }
  }

  /// Dispose dos recursos
  void dispose() {
    _periodicTimer?.cancel();
    _retryTimer?.cancel();
  }
}

/// Callback dispatcher para WorkManager (deve ser função global)
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Configurar logging para background task
      print('Background task started: $task');

      switch (task) {
        case BackgroundSyncService._periodicSyncTask:
          await _executePeriodicSync();
          break;
          
        case BackgroundSyncService._immediateSync:
          await _executeImmediateSync();
          break;
          
        case BackgroundSyncService._retrySync:
          await _executeRetrySync();
          break;
          
        default:
          print('Unknown background task: $task');
          return false;
      }

      print('Background task completed: $task');
      return true;
      
    } catch (e) {
      print('Background task failed: $task, error: $e');
      return false;
    }
  });
}

/// Executa sync periódico em background
Future<void> _executePeriodicSync() async {
  // Inicializar serviços necessários para background task
  // (implementação simplificada)
  try {
    // Aqui seria necessário inicializar uma instância mínima dos serviços
    // para executar sync em background
    
    // Por segurança, apenas registrar a tentativa
    print('Periodic background sync attempted');
    
    // TODO: Implementar sync real em background isolate
    
  } catch (e) {
    print('Periodic background sync failed: $e');
  }
}

/// Executa sync imediato em background
Future<void> _executeImmediateSync() async {
  try {
    print('Immediate background sync attempted');
    
    // TODO: Implementar sync imediato em background
    
  } catch (e) {
    print('Immediate background sync failed: $e');
  }
}

/// Executa retry de sync em background
Future<void> _executeRetrySync() async {
  try {
    print('Retry background sync attempted');
    
    // TODO: Implementar retry em background
    
  } catch (e) {
    print('Retry background sync failed: $e');
  }
}

/// Estatísticas de background sync
class BackgroundSyncStats {
  const BackgroundSyncStats({
    required this.isInitialized,
    required this.retryCount,
    this.lastPeriodicSync,
    this.lastBackgroundSync,
    required this.totalBackgroundSyncs,
    required this.totalFailedSyncs,
  });

  final bool isInitialized;
  final int retryCount;
  final DateTime? lastPeriodicSync;
  final DateTime? lastBackgroundSync;
  final int totalBackgroundSyncs;
  final int totalFailedSyncs;

  double get successRate {
    final total = totalBackgroundSyncs + totalFailedSyncs;
    return total > 0 ? totalBackgroundSyncs / total : 1.0;
  }
}