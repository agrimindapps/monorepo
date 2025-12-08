import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../shared/utils/failure.dart';
import '../interfaces/i_sync_service.dart';
import '../services/sync_logger.dart';
import '../throttling/sync_queue.dart';
import '../throttling/sync_throttler.dart';

/// Configuração de background sync para um service
class BackgroundSyncConfig {
  /// Intervalo de sync periódico
  final Duration syncInterval;

  /// Se requer WiFi para sync
  final bool requiresWifi;

  /// Se requer bateria carregando
  final bool requiresCharging;

  /// Nível mínimo de bateria (0-100)
  final int minimumBatteryLevel;

  /// Prioridade de sync
  final SyncPriority priority;

  /// Timeout para operação de sync
  final Duration? syncTimeout;

  /// Se o sync em background está habilitado
  final bool enabled;

  const BackgroundSyncConfig({
    this.syncInterval = const Duration(minutes: 30),
    this.requiresWifi = false,
    this.requiresCharging = false,
    this.minimumBatteryLevel = 20,
    this.priority = SyncPriority.normal,
    this.syncTimeout,
    this.enabled = true,
  });

  BackgroundSyncConfig copyWith({
    Duration? syncInterval,
    bool? requiresWifi,
    bool? requiresCharging,
    int? minimumBatteryLevel,
    SyncPriority? priority,
    Duration? syncTimeout,
    bool? enabled,
  }) {
    return BackgroundSyncConfig(
      syncInterval: syncInterval ?? this.syncInterval,
      requiresWifi: requiresWifi ?? this.requiresWifi,
      requiresCharging: requiresCharging ?? this.requiresCharging,
      minimumBatteryLevel: minimumBatteryLevel ?? this.minimumBatteryLevel,
      priority: priority ?? this.priority,
      syncTimeout: syncTimeout ?? this.syncTimeout,
      enabled: enabled ?? this.enabled,
    );
  }
}

/// Gerenciador de sincronização em background
/// Coordena sync periódico, throttling e queue management
class BackgroundSyncManager {
  /// Singleton instance
  static BackgroundSyncManager? _instance;
  static BackgroundSyncManager get instance =>
      _instance ??= BackgroundSyncManager._();

  BackgroundSyncManager._();

  /// Services registrados para background sync
  final Map<String, ISyncService> _services = {};

  /// Configurações de background sync por service
  final Map<String, BackgroundSyncConfig> _configs = {};

  /// Timers periódicos ativos
  final Map<String, Timer> _timers = {};

  /// Throttler para rate limiting
  late final SyncThrottler _throttler;

  /// Queue para gerenciar sync requests
  late final SyncQueue _queue;
  
  /// Subscription para eventos da queue
  StreamSubscription<SyncQueueEvent>? _queueSubscription;

  /// Logger
  final SyncLogger _logger = SyncLogger(appName: 'background_sync');

  /// Se está inicializado
  bool _isInitialized = false;

  /// Stream de eventos de background sync
  final StreamController<BackgroundSyncEvent> _eventController =
      StreamController<BackgroundSyncEvent>.broadcast();

  Stream<BackgroundSyncEvent> get events => _eventController.stream;

  /// Inicializa o Background Sync Manager
  Future<Either<Failure, void>> initialize({
    Duration minSyncInterval = const Duration(minutes: 5),
    int maxQueueSize = 50,
  }) async {
    if (_isInitialized) {
      return const Right(null);
    }

    try {
      _logger.logInfo(
        message: 'Initializing Background Sync Manager',
        metadata: {
          'min_interval': minSyncInterval.inMinutes,
          'max_queue_size': maxQueueSize,
        },
      );
      _throttler = SyncThrottler(
        minInterval: minSyncInterval,
        maxBackoffInterval: const Duration(hours: 1),
        backoffMultiplier: 2.0,
        debounceDuration: const Duration(seconds: 2),
      );
      _queue = SyncQueue(maxQueueSize: maxQueueSize);
      _queueSubscription = _queue.events.listen(_handleQueueEvent);

      _isInitialized = true;

      _logger.logInfo(
        message: 'Background Sync Manager initialized successfully',
      );
      _eventController.add(BackgroundSyncEvent.initialized());

      return const Right(null);
    } catch (e, stackTrace) {
      _logger.logError(
        message: 'Failed to initialize Background Sync Manager',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(SyncFailure('Failed to initialize background sync: $e'));
    }
  }

  /// Registra um sync service para background sync
  void registerService(ISyncService service, {BackgroundSyncConfig? config}) {
    if (!_isInitialized) {
      throw StateError('BackgroundSyncManager not initialized');
    }

    _services[service.serviceId] = service;
    _configs[service.serviceId] = config ?? const BackgroundSyncConfig();

    _logger.logInfo(
      message: 'Service registered for background sync',
      metadata: {
        'service_id': service.serviceId,
        'interval': config?.syncInterval.inMinutes ?? 30,
        'enabled': config?.enabled ?? true,
      },
    );
    if (_configs[service.serviceId]!.enabled) {
      _startPeriodicSync(service.serviceId);
    }

    _eventController.add(
      BackgroundSyncEvent.serviceRegistered(service.serviceId),
    );
  }

  /// Remove registro de um service
  void unregisterService(String serviceId) {
    _stopPeriodicSync(serviceId);
    _services.remove(serviceId);
    _configs.remove(serviceId);

    _logger.logInfo(
      message: 'Service unregistered from background sync',
      metadata: {'service_id': serviceId},
    );

    _eventController.add(BackgroundSyncEvent.serviceUnregistered(serviceId));
  }

  /// Inicia sync periódico para um service
  void _startPeriodicSync(String serviceId) {
    final config = _configs[serviceId];
    if (config == null || !config.enabled) return;
    _stopPeriodicSync(serviceId);
    _timers[serviceId] = Timer.periodic(config.syncInterval, (_) {
      triggerSync(serviceId, priority: config.priority);
    });

    _logger.logInfo(
      message: 'Periodic sync started',
      metadata: {
        'service_id': serviceId,
        'interval': config.syncInterval.inMinutes,
      },
    );
  }

  /// Para sync periódico para um service
  void _stopPeriodicSync(String serviceId) {
    _timers[serviceId]?.cancel();
    _timers.remove(serviceId);
  }

  /// Dispara sync para um service (adiciona à queue)
  Future<void> triggerSync(
    String serviceId, {
    SyncPriority priority = SyncPriority.normal,
    bool force = false,
  }) async {
    final service = _services[serviceId];
    final config = _configs[serviceId];

    if (service == null || config == null) {
      _logger.logWarning(
        message: 'Cannot trigger sync: service not registered',
        metadata: {'service_id': serviceId},
      );
      return;
    }

    if (!config.enabled && !force) {
      _logger.logInfo(
        message: 'Sync skipped: disabled in config',
        metadata: {'service_id': serviceId},
      );
      return;
    }
    if (!force && !_throttler.canSync(serviceId)) {
      final timeUntilNext = _throttler.timeUntilNextSync(serviceId);
      _logger.logInfo(
        message: 'Sync throttled',
        metadata: {
          'service_id': serviceId,
          'time_until_next': timeUntilNext?.inMinutes,
        },
      );

      _eventController.add(
        BackgroundSyncEvent.syncThrottled(serviceId, timeUntilNext),
      );
      return;
    }
    final queueItem = SyncQueueItem(
      serviceId: serviceId,
      displayName: service.displayName,
      syncOperation: () async {
        _logger.logSyncStart(entity: serviceId);
        final result = await service.sync();

        result.fold(
          (failure) {
            _throttler.recordFailure(serviceId);
            _logger.logSyncFailure(entity: serviceId, error: failure.message);
          },
          (syncResult) {
            _throttler.recordSuccess(serviceId);
            _logger.logSyncSuccess(
              entity: serviceId,
              duration: syncResult.duration,
              itemsSynced: syncResult.itemsSynced,
            );
          },
        );

        return result;
      },
      priority: priority,
      timeout: config.syncTimeout,
    );

    final enqueued = _queue.enqueue(queueItem);

    if (enqueued) {
      _logger.logInfo(
        message: 'Sync enqueued',
        metadata: {
          'service_id': serviceId,
          'priority': priority.name,
          'queue_size': _queue.queueSize,
        },
      );
    }
  }

  /// Handle queue events
  void _handleQueueEvent(SyncQueueEvent event) {
    switch (event.type) {
      case SyncQueueEventType.itemStarted:
        _eventController.add(
          BackgroundSyncEvent.syncStarted(event.item!.serviceId),
        );
        break;

      case SyncQueueEventType.itemCompleted:
        _eventController.add(
          BackgroundSyncEvent.syncCompleted(
            event.item!.serviceId,
            event.result!,
          ),
        );
        break;

      case SyncQueueEventType.itemFailed:
        _eventController.add(
          BackgroundSyncEvent.syncFailed(event.item!.serviceId, event.failure!),
        );
        break;

      case SyncQueueEventType.queueFull:
        _logger.logWarning(
          message: 'Sync queue is full',
          metadata: {'service_id': event.item?.serviceId},
        );
        break;

      default:
        break;
    }
  }

  /// Atualiza configuração de um service
  void updateConfig(String serviceId, BackgroundSyncConfig config) {
    _configs[serviceId] = config;
    if (config.enabled) {
      _startPeriodicSync(serviceId);
    } else {
      _stopPeriodicSync(serviceId);
    }

    _logger.logInfo(
      message: 'Background sync config updated',
      metadata: {
        'service_id': serviceId,
        'enabled': config.enabled,
        'interval': config.syncInterval.inMinutes,
      },
    );

    _eventController.add(BackgroundSyncEvent.configUpdated(serviceId, config));
  }

  /// Pausa background sync para um service
  void pause(String serviceId) {
    _stopPeriodicSync(serviceId);
    _logger.logInfo(
      message: 'Background sync paused',
      metadata: {'service_id': serviceId},
    );
    _eventController.add(BackgroundSyncEvent.syncPaused(serviceId));
  }

  /// Resume background sync para um service
  void resume(String serviceId) {
    final config = _configs[serviceId];
    if (config != null && config.enabled) {
      _startPeriodicSync(serviceId);
      _logger.logInfo(
        message: 'Background sync resumed',
        metadata: {'service_id': serviceId},
      );
      _eventController.add(BackgroundSyncEvent.syncResumed(serviceId));
    }
  }

  /// Pausa todos os background syncs
  void pauseAll() {
    for (final serviceId in _services.keys) {
      pause(serviceId);
    }
  }

  /// Resume todos os background syncs
  void resumeAll() {
    for (final serviceId in _services.keys) {
      resume(serviceId);
    }
  }

  /// Obtém estatísticas de background sync
  BackgroundSyncStats getStats() {
    final serviceStats = <String, Map<String, dynamic>>{};

    for (final serviceId in _services.keys) {
      final throttlingStats = _throttler.getStats(serviceId);
      final config = _configs[serviceId];

      serviceStats[serviceId] = {
        'enabled': config?.enabled ?? false,
        'interval_minutes': config?.syncInterval.inMinutes ?? 0,
        'last_sync': throttlingStats.lastSync?.toIso8601String(),
        'failure_count': throttlingStats.failureCount,
        'can_sync_now': throttlingStats.canSyncNow,
        'time_until_next': throttlingStats.timeUntilNextSync?.inMinutes,
      };
    }

    return BackgroundSyncStats(
      isInitialized: _isInitialized,
      registeredServices: _services.length,
      activeTimers: _timers.length,
      queueStats: _queue.getStats(),
      serviceStats: serviceStats,
    );
  }

  /// Dispose resources
  Future<void> dispose() async {
    _logger.logInfo(message: 'Disposing Background Sync Manager');
    
    await _queueSubscription?.cancel();
    _queueSubscription = null;
    
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _throttler.dispose();
    await _queue.dispose();
    _services.clear();
    _configs.clear();

    await _eventController.close();

    _isInitialized = false;
  }
}

/// Evento de background sync
class BackgroundSyncEvent {
  final BackgroundSyncEventType type;
  final String? serviceId;
  final ServiceSyncResult? result;
  final Failure? failure;
  final Duration? timeUntilNext;
  final BackgroundSyncConfig? config;

  BackgroundSyncEvent._({
    required this.type,
    this.serviceId,
    this.result,
    this.failure,
    this.timeUntilNext,
    this.config,
  });

  factory BackgroundSyncEvent.initialized() =>
      BackgroundSyncEvent._(type: BackgroundSyncEventType.initialized);

  factory BackgroundSyncEvent.serviceRegistered(String serviceId) =>
      BackgroundSyncEvent._(
        type: BackgroundSyncEventType.serviceRegistered,
        serviceId: serviceId,
      );

  factory BackgroundSyncEvent.serviceUnregistered(String serviceId) =>
      BackgroundSyncEvent._(
        type: BackgroundSyncEventType.serviceUnregistered,
        serviceId: serviceId,
      );

  factory BackgroundSyncEvent.syncStarted(String serviceId) =>
      BackgroundSyncEvent._(
        type: BackgroundSyncEventType.syncStarted,
        serviceId: serviceId,
      );

  factory BackgroundSyncEvent.syncCompleted(
    String serviceId,
    ServiceSyncResult result,
  ) => BackgroundSyncEvent._(
    type: BackgroundSyncEventType.syncCompleted,
    serviceId: serviceId,
    result: result,
  );

  factory BackgroundSyncEvent.syncFailed(String serviceId, Failure failure) =>
      BackgroundSyncEvent._(
        type: BackgroundSyncEventType.syncFailed,
        serviceId: serviceId,
        failure: failure,
      );

  factory BackgroundSyncEvent.syncThrottled(
    String serviceId,
    Duration? timeUntilNext,
  ) => BackgroundSyncEvent._(
    type: BackgroundSyncEventType.syncThrottled,
    serviceId: serviceId,
    timeUntilNext: timeUntilNext,
  );

  factory BackgroundSyncEvent.syncPaused(String serviceId) =>
      BackgroundSyncEvent._(
        type: BackgroundSyncEventType.syncPaused,
        serviceId: serviceId,
      );

  factory BackgroundSyncEvent.syncResumed(String serviceId) =>
      BackgroundSyncEvent._(
        type: BackgroundSyncEventType.syncResumed,
        serviceId: serviceId,
      );

  factory BackgroundSyncEvent.configUpdated(
    String serviceId,
    BackgroundSyncConfig config,
  ) => BackgroundSyncEvent._(
    type: BackgroundSyncEventType.configUpdated,
    serviceId: serviceId,
    config: config,
  );
}

/// Tipos de eventos de background sync
enum BackgroundSyncEventType {
  initialized,
  serviceRegistered,
  serviceUnregistered,
  syncStarted,
  syncCompleted,
  syncFailed,
  syncThrottled,
  syncPaused,
  syncResumed,
  configUpdated,
}

/// Estatísticas de background sync
class BackgroundSyncStats {
  final bool isInitialized;
  final int registeredServices;
  final int activeTimers;
  final SyncQueueStats queueStats;
  final Map<String, Map<String, dynamic>> serviceStats;

  BackgroundSyncStats({
    required this.isInitialized,
    required this.registeredServices,
    required this.activeTimers,
    required this.queueStats,
    required this.serviceStats,
  });

  Map<String, dynamic> toJson() {
    return {
      'is_initialized': isInitialized,
      'registered_services': registeredServices,
      'active_timers': activeTimers,
      'queue': queueStats.toJson(),
      'services': serviceStats,
    };
  }

  @override
  String toString() {
    return 'BackgroundSyncStats(isInitialized: $isInitialized, '
        'registeredServices: $registeredServices, '
        'activeTimers: $activeTimers, '
        'queueSize: ${queueStats.queueSize})';
  }
}
