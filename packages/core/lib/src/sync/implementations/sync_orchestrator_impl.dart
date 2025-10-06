import 'dart:async';
import 'dart:developer' as developer;

import 'package:dartz/dartz.dart';

import '../../shared/utils/failure.dart';
import '../interfaces/i_cache_manager.dart';
import '../interfaces/i_network_monitor.dart';
import '../interfaces/i_sync_orchestrator.dart';
import '../interfaces/i_sync_service.dart';

/// Implementação do orchestrador de sincronização
/// Substitui o UnifiedSyncManager monolítico seguindo SOLID principles
class SyncOrchestratorImpl implements ISyncOrchestrator {
  final ICacheManager _cacheManager;
  final INetworkMonitor _networkMonitor;

  // Estado interno
  final Map<String, ISyncService> _services = {};
  final Map<String, SyncServiceStatus> _serviceStatuses = {};
  final Map<String, Timer?> _serviceTimers = {};

  // Stream controllers
  final StreamController<SyncProgress> _progressController =
      StreamController<SyncProgress>.broadcast();
  final StreamController<SyncEvent> _eventController =
      StreamController<SyncEvent>.broadcast();

  // Estado de execução
  bool _isDisposed = false;
  bool _isSyncingAll = false;
  String? _currentSyncingService;

  SyncOrchestratorImpl({
    required ICacheManager cacheManager,
    required INetworkMonitor networkMonitor,
  }) : _cacheManager = cacheManager,
       _networkMonitor = networkMonitor {
    _setupNetworkListener();
  }

  @override
  Future<void> registerService(ISyncService service) async {
    if (_isDisposed) {
      throw StateError('Orchestrator has been disposed');
    }

    developer.log(
      'Registering sync service: ${service.serviceId}',
      name: 'SyncOrchestrator',
    );

    // Verificar se já existe
    if (_services.containsKey(service.serviceId)) {
      developer.log(
        'Service ${service.serviceId} already registered, replacing',
        name: 'SyncOrchestrator',
      );
    }

    // Registrar serviço
    _services[service.serviceId] = service;
    _serviceStatuses[service.serviceId] = SyncServiceStatus.idle;

    // Inicializar serviço se necessário
    try {
      final result = await service.initialize();
      if (result.isLeft()) {
        developer.log(
          'Failed to initialize service ${service.serviceId}: ${result.fold((f) => f.message, (_) => '')}',
          name: 'SyncOrchestrator',
        );
        _serviceStatuses[service.serviceId] = SyncServiceStatus.failed;
      }
    } catch (e) {
      developer.log(
        'Error initializing service ${service.serviceId}: $e',
        name: 'SyncOrchestrator',
      );
      _serviceStatuses[service.serviceId] = SyncServiceStatus.failed;
    }

    // Escutar status do serviço
    _listenToServiceStatus(service);

    _emitEvent(
      SyncEvent(
        serviceId: service.serviceId,
        type: SyncEventType.started,
        message: 'Service registered',
      ),
    );
  }

  @override
  Future<void> unregisterService(String serviceId) async {
    if (!_services.containsKey(serviceId)) {
      developer.log(
        'Service $serviceId not found for unregistration',
        name: 'SyncOrchestrator',
      );
      return;
    }

    developer.log(
      'Unregistering sync service: $serviceId',
      name: 'SyncOrchestrator',
    );

    // Parar timer se existir
    _serviceTimers[serviceId]?.cancel();
    _serviceTimers.remove(serviceId);

    // Dispose do serviço
    final service = _services[serviceId];
    if (service != null) {
      try {
        await service.dispose();
      } catch (e) {
        developer.log(
          'Error disposing service $serviceId: $e',
          name: 'SyncOrchestrator',
        );
      }
    }

    // Remover registros
    _services.remove(serviceId);
    _serviceStatuses.remove(serviceId);

    _emitEvent(
      SyncEvent(
        serviceId: serviceId,
        type: SyncEventType.cancelled,
        message: 'Service unregistered',
      ),
    );
  }

  @override
  Future<Either<Failure, void>> syncAll() async {
    if (_isDisposed) {
      return const Left(SyncFailure('Orchestrator has been disposed'));
    }

    if (_isSyncingAll) {
      return const Left(SyncFailure('Sync all already in progress'));
    }

    _isSyncingAll = true;

    try {
      developer.log(
        'Starting sync all for ${_services.length} services',
        name: 'SyncOrchestrator',
      );

      // Verificar conectividade
      if (!await _networkMonitor.isConnected()) {
        _isSyncingAll = false;
        return const Left(NetworkFailure('No network connectivity'));
      }

      final services = _services.values.where((s) => s.canSync).toList();
      if (services.isEmpty) {
        _isSyncingAll = false;
        return const Right(null);
      }

      // Executar sync de cada serviço
      for (int i = 0; i < services.length; i++) {
        final service = services[i];
        _currentSyncingService = service.serviceId;

        // Emitir progresso
        _emitProgress(
          SyncProgress(
            current: i + 1,
            total: services.length,
            serviceId: service.serviceId,
            operation: 'Syncing ${service.displayName}',
          ),
        );

        // Executar sync
        final result = await _syncSingleService(service);
        if (result.isLeft()) {
          // Log erro mas continua com outros serviços
          developer.log(
            'Sync failed for ${service.serviceId}: ${result.fold((f) => f.message, (_) => '')}',
            name: 'SyncOrchestrator',
          );
        }
      }

      _currentSyncingService = null;
      _isSyncingAll = false;

      developer.log('Sync all completed', name: 'SyncOrchestrator');

      return const Right(null);
    } catch (e) {
      _currentSyncingService = null;
      _isSyncingAll = false;

      developer.log('Error during sync all: $e', name: 'SyncOrchestrator');

      return Left(SyncFailure('Sync all failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> syncSpecific(String serviceId) async {
    if (_isDisposed) {
      return const Left(SyncFailure('Orchestrator has been disposed'));
    }

    final service = _services[serviceId];
    if (service == null) {
      return Left(NotFoundFailure('Service $serviceId not found'));
    }

    return await _syncSingleService(service);
  }

  Future<Either<Failure, void>> _syncSingleService(ISyncService service) async {
    try {
      // Verificar se pode fazer sync
      if (!service.canSync) {
        return Left(SyncFailure('Service ${service.serviceId} cannot sync'));
      }

      // Atualizar status
      _serviceStatuses[service.serviceId] = SyncServiceStatus.syncing;

      _emitEvent(
        SyncEvent(
          serviceId: service.serviceId,
          type: SyncEventType.started,
          message: 'Starting sync for ${service.displayName}',
        ),
      );

      // Executar sync
      final result = await service.sync();

      if (result.isRight()) {
        _serviceStatuses[service.serviceId] = SyncServiceStatus.completed;

        final syncResult = result.getOrElse(
          () => throw StateError('Invalid state'),
        );

        _emitEvent(
          SyncEvent(
            serviceId: service.serviceId,
            type: SyncEventType.completed,
            message: 'Sync completed: ${syncResult.itemsSynced} items',
            data: syncResult,
          ),
        );

        developer.log(
          'Sync completed for ${service.serviceId}: ${syncResult.itemsSynced} items',
          name: 'SyncOrchestrator',
        );

        return const Right(null);
      } else {
        _serviceStatuses[service.serviceId] = SyncServiceStatus.failed;

        final failure = result.fold(
          (f) => f,
          (_) => throw StateError('Invalid state'),
        );

        _emitEvent(
          SyncEvent(
            serviceId: service.serviceId,
            type: SyncEventType.failed,
            message: 'Sync failed: ${failure.message}',
            data: failure,
          ),
        );

        return Left(failure);
      }
    } catch (e) {
      _serviceStatuses[service.serviceId] = SyncServiceStatus.failed;

      _emitEvent(
        SyncEvent(
          serviceId: service.serviceId,
          type: SyncEventType.failed,
          message: 'Sync error: $e',
        ),
      );

      return Left(SyncFailure('Sync failed for ${service.serviceId}: $e'));
    }
  }

  @override
  List<String> get registeredServices => _services.keys.toList();

  @override
  bool isServiceRegistered(String serviceId) =>
      _services.containsKey(serviceId);

  @override
  Stream<SyncProgress> get progressStream => _progressController.stream;

  @override
  Stream<SyncEvent> get eventStream => _eventController.stream;

  @override
  SyncServiceStatus getServiceStatus(String serviceId) {
    return _serviceStatuses[serviceId] ?? SyncServiceStatus.uninitialized;
  }

  @override
  GlobalSyncStatus get globalStatus {
    return GlobalSyncStatus.fromServices(_serviceStatuses);
  }

  @override
  Future<Either<Failure, void>> clearAllData() async {
    if (_isDisposed) {
      return const Left(SyncFailure('Orchestrator has been disposed'));
    }

    try {
      // Limpar dados de todos os serviços
      for (final service in _services.values) {
        final result = await service.clearLocalData();
        if (result.isLeft()) {
          return result;
        }
      }

      // Limpar cache
      final cacheResult = await _cacheManager.clear();
      if (cacheResult.isLeft()) {
        return cacheResult;
      }

      developer.log('All data cleared successfully', name: 'SyncOrchestrator');

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to clear all data: $e'));
    }
  }

  @override
  Future<void> stopAllSync() async {
    _isSyncingAll = false;
    _currentSyncingService = null;

    // Parar sync de cada serviço
    for (final service in _services.values) {
      try {
        await service.stopSync();
        _serviceStatuses[service.serviceId] = SyncServiceStatus.idle;
      } catch (e) {
        developer.log(
          'Error stopping sync for ${service.serviceId}: $e',
          name: 'SyncOrchestrator',
        );
      }
    }

    _emitEvent(
      SyncEvent(
        serviceId: 'all',
        type: SyncEventType.cancelled,
        message: 'All syncs stopped',
      ),
    );
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;

    _isDisposed = true;

    developer.log('Disposing sync orchestrator', name: 'SyncOrchestrator');

    // Parar todas as sincronizações
    await stopAllSync();

    // Dispose de todos os serviços
    for (final service in _services.values) {
      try {
        await service.dispose();
      } catch (e) {
        developer.log(
          'Error disposing service ${service.serviceId}: $e',
          name: 'SyncOrchestrator',
        );
      }
    }

    // Cancel timers
    for (final timer in _serviceTimers.values) {
      timer?.cancel();
    }

    // Fechar streams
    await _progressController.close();
    await _eventController.close();

    // Limpar estado
    _services.clear();
    _serviceStatuses.clear();
    _serviceTimers.clear();
  }

  // Métodos privados

  void _setupNetworkListener() {
    _networkMonitor.connectivityStream.listen(
      (isConnected) {
        if (isConnected) {
          developer.log(
            'Network connected, checking for pending syncs',
            name: 'SyncOrchestrator',
          );
          _checkPendingSyncs();
        } else {
          developer.log(
            'Network disconnected, stopping syncs',
            name: 'SyncOrchestrator',
          );
          stopAllSync();
        }
      },
      onError: (error) {
        developer.log(
          'Network listener error: $error',
          name: 'SyncOrchestrator',
        );
      },
    );
  }

  void _listenToServiceStatus(ISyncService service) {
    service.statusStream.listen(
      (status) {
        _serviceStatuses[service.serviceId] = status;

        _emitEvent(
          SyncEvent(
            serviceId: service.serviceId,
            type: _mapStatusToEventType(status),
            message: 'Status changed to ${status.name}',
          ),
        );
      },
      onError: (error) {
        developer.log(
          'Service status listener error for ${service.serviceId}: $error',
          name: 'SyncOrchestrator',
        );
      },
    );
  }

  Future<void> _checkPendingSyncs() async {
    for (final service in _services.values) {
      try {
        if (await service.hasPendingSync && service.canSync) {
          developer.log(
            'Found pending sync for ${service.serviceId}, triggering sync',
            name: 'SyncOrchestrator',
          );
          // Trigger sync in background
          _syncSingleService(service);
        }
      } catch (e) {
        developer.log(
          'Error checking pending sync for ${service.serviceId}: $e',
          name: 'SyncOrchestrator',
        );
      }
    }
  }

  void _emitProgress(SyncProgress progress) {
    if (!_progressController.isClosed) {
      _progressController.add(progress);
    }
  }

  void _emitEvent(SyncEvent event) {
    if (!_eventController.isClosed) {
      _eventController.add(event);
    }
  }

  SyncEventType _mapStatusToEventType(SyncServiceStatus status) {
    switch (status) {
      case SyncServiceStatus.syncing:
        return SyncEventType.started;
      case SyncServiceStatus.completed:
        return SyncEventType.completed;
      case SyncServiceStatus.failed:
        return SyncEventType.failed;
      case SyncServiceStatus.paused:
        return SyncEventType.paused;
      default:
        return SyncEventType.progress;
    }
  }
}
