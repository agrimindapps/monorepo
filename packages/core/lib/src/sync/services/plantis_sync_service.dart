import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../shared/utils/failure.dart';
import '../interfaces/i_sync_service.dart';
import 'sync_logger.dart';

/// Serviço de sincronização específico para o app Plantis
/// Coordena sincronização entre repositories existentes
///
/// **Arquitetura**: Delegation pattern - delega sync para repositories
/// ao invés de duplicar lógica de acesso a dados
class PlantisSyncService implements ISyncService {
  /// Repositories injetados
  final dynamic plantsRepository;
  final dynamic spacesRepository;
  final dynamic plantTasksRepository;
  final dynamic plantCommentsRepository;

  /// Logger estruturado
  final SyncLogger logger;

  /// Connectivity monitoring (opcional)
  StreamSubscription<bool>? _connectivitySubscription;

  PlantisSyncService({
    required this.plantsRepository,
    required this.spacesRepository,
    required this.plantTasksRepository,
    required this.plantCommentsRepository,
  }) : logger = SyncLogger(appName: 'plantis');

  @override
  final String serviceId = 'plantis';

  @override
  final String displayName = 'Plantis Plant Care Sync';

  @override
  final String version = '2.0.0';

  @override
  List<String> get dependencies => const [];
  bool _isInitialized = false;
  final bool _canSync = true;
  bool _hasPendingSync = false;
  DateTime? _lastSync;
  int _totalSyncs = 0;
  int _successfulSyncs = 0;
  int _failedSyncs = 0;
  int _totalItemsSynced = 0;
  final StreamController<SyncServiceStatus> _statusController =
      StreamController<SyncServiceStatus>.broadcast();
  final StreamController<ServiceProgress> _progressController =
      StreamController<ServiceProgress>.broadcast();

  SyncServiceStatus _currentStatus = SyncServiceStatus.uninitialized;
  final List<String> _entityTypes = ['plants', 'spaces', 'tasks', 'comments'];

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      logger.logInfo(
        message: 'Initializing Plantis Sync Service v$version',
        metadata: {'entities': _entityTypes},
      );

      _isInitialized = true;
      _updateStatus(SyncServiceStatus.idle);

      logger.logInfo(
        message: 'Plantis Sync Service initialized successfully',
        metadata: {'entity_count': _entityTypes.length},
      );

      return const Right(null);
    } catch (e, stackTrace) {
      _updateStatus(SyncServiceStatus.failed);
      logger.logError(
        message: 'Failed to initialize Plantis sync',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(SyncFailure('Failed to initialize Plantis sync: $e'));
    }
  }

  @override
  bool get canSync => _isInitialized && _canSync;

  @override
  Future<bool> get hasPendingSync async => _hasPendingSync;

  @override
  Stream<SyncServiceStatus> get statusStream => _statusController.stream;

  @override
  Stream<ServiceProgress> get progressStream => _progressController.stream;

  @override
  Future<Either<Failure, ServiceSyncResult>> sync() async {
    if (!canSync) {
      return const Left(
        SyncFailure('Plantis sync service cannot sync in current state'),
      );
    }

    try {
      _updateStatus(SyncServiceStatus.syncing);
      _hasPendingSync = false;
      _totalSyncs++;

      final startTime = DateTime.now();
      logger.logSyncStart(entity: 'all_entities');

      int totalSynced = 0;
      final errors = <String>[];
      for (int i = 0; i < _entityTypes.length; i++) {
        final entityType = _entityTypes[i];

        _emitProgress(
          ServiceProgress(
            serviceId: serviceId,
            operation: 'Syncing $entityType',
            current: i + 1,
            total: _entityTypes.length,
            currentItem: entityType,
          ),
        );
        final syncResult = await _syncEntity(entityType);

        syncResult.fold(
          (failure) {
            errors.add('$entityType: ${failure.message}');
            logger.logWarning(
              message: 'Partial sync failure for $entityType',
              metadata: {'error': failure.message},
            );
          },
          (itemCount) {
            totalSynced += itemCount;
            logger.logInfo(
              message: 'Synced $itemCount items for $entityType',
              metadata: {'entity': entityType, 'count': itemCount},
            );
          },
        );
      }

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      _lastSync = endTime;
      _totalItemsSynced += totalSynced;
      if (errors.isEmpty || totalSynced > 0) {
        _successfulSyncs++;
        _updateStatus(SyncServiceStatus.completed);

        logger.logSyncSuccess(
          entity: 'all_entities',
          duration: duration,
          itemsSynced: totalSynced,
          metadata: {
            'entities_synced': _entityTypes,
            'partial_failures': errors.length,
          },
        );

        return Right(
          ServiceSyncResult(
            success: true,
            itemsSynced: totalSynced,
            duration: duration,
            metadata: {
              'entities_synced': _entityTypes,
              'app': 'plantis',
              'sync_type': 'full',
              'partial_failures': errors,
            },
          ),
        );
      } else {
        _failedSyncs++;
        _updateStatus(SyncServiceStatus.failed);

        logger.logSyncFailure(
          entity: 'all_entities',
          error: 'All entities failed: ${errors.join(', ')}',
        );

        return Left(
          SyncFailure('All entities failed to sync: ${errors.join(', ')}'),
        );
      }
    } catch (e, stackTrace) {
      _failedSyncs++;
      _updateStatus(SyncServiceStatus.failed);

      logger.logSyncFailure(
        entity: 'all_entities',
        error: e.toString(),
        stackTrace: stackTrace,
      );

      return Left(SyncFailure('Plantis sync failed: $e'));
    }
  }

  /// Sincroniza uma entidade específica delegando para o repository correspondente
  Future<Either<Failure, int>> _syncEntity(String entityType) async {
    try {
      switch (entityType) {
        case 'plants':
          return await _syncPlants();
        case 'spaces':
          return await _syncSpaces();
        case 'tasks':
          return await _syncTasks();
        case 'comments':
          return await _syncComments();
        default:
          return Left(ValidationFailure('Unknown entity type: $entityType'));
      }
    } catch (e) {
      return Left(SyncFailure('Failed to sync $entityType: $e'));
    }
  }

  /// Sincroniza plantas delegando para PlantsRepository.syncPendingChanges()
  Future<Either<Failure, int>> _syncPlants() async {
    try {
      final result =
          await plantsRepository.syncPendingChanges() as Either<Failure, void>;

      return await result.fold(
        (Failure failure) async => Left<Failure, int>(failure),
        (_) async {
          final plantsResult =
              await plantsRepository.getPlants()
                  as Either<Failure, List<dynamic>>;
          return plantsResult.fold(
            (Failure failure) => const Right<Failure, int>(0),
            (List<dynamic> plants) => Right<Failure, int>(plants.length),
          );
        },
      );
    } catch (e) {
      return Left<Failure, int>(SyncFailure('Failed to sync plants: $e'));
    }
  }

  /// Sincroniza espaços delegando para SpacesRepository
  Future<Either<Failure, int>> _syncSpaces() async {
    try {
      final result =
          await spacesRepository.syncPendingChanges() as Either<Failure, void>;

      return await result.fold(
        (Failure failure) async => Left<Failure, int>(failure),
        (_) async {
          final spacesResult =
              await spacesRepository.getSpaces()
                  as Either<Failure, List<dynamic>>;
          return spacesResult.fold(
            (Failure failure) => const Right<Failure, int>(0),
            (List<dynamic> spaces) => Right<Failure, int>(spaces.length),
          );
        },
      );
    } catch (e) {
      return Left<Failure, int>(SyncFailure('Failed to sync spaces: $e'));
    }
  }

  /// Sincroniza tarefas delegando para PlantTasksRepository
  Future<Either<Failure, int>> _syncTasks() async {
    try {
      final result =
          await plantTasksRepository.syncPendingChanges()
              as Either<Failure, void>;

      return result.fold(
        (Failure failure) => Left<Failure, int>(failure),
        (_) => const Right<Failure, int>(
          0,
        ), // Contagem de tasks não disponível facilmente
      );
    } catch (e) {
      return Left<Failure, int>(SyncFailure('Failed to sync tasks: $e'));
    }
  }

  /// Sincroniza comentários delegando para PlantCommentsRepository
  Future<Either<Failure, int>> _syncComments() async {
    try {
      final result =
          await plantCommentsRepository.syncPendingChanges()
              as Either<Failure, void>;

      return result.fold(
        (Failure failure) => Left<Failure, int>(failure),
        (_) => const Right<Failure, int>(
          0,
        ), // Contagem de comments não disponível facilmente
      );
    } catch (e) {
      return Left<Failure, int>(SyncFailure('Failed to sync comments: $e'));
    }
  }

  @override
  Future<Either<Failure, ServiceSyncResult>> syncSpecific(
    List<String> ids,
  ) async {
    if (!canSync) {
      return const Left(
        SyncFailure('Plantis sync service cannot sync in current state'),
      );
    }

    try {
      _updateStatus(SyncServiceStatus.syncing);

      logger.logInfo(
        message: 'Starting specific sync for Plantis items',
        metadata: {'item_count': ids.length, 'item_ids': ids},
      );
      return await sync();
    } catch (e, stackTrace) {
      _failedSyncs++;
      _updateStatus(SyncServiceStatus.failed);

      logger.logSyncFailure(
        entity: 'specific_items',
        error: e.toString(),
        stackTrace: stackTrace,
      );

      return Left(SyncFailure('Plantis specific sync failed: $e'));
    }
  }

  @override
  Future<void> stopSync() async {
    _updateStatus(SyncServiceStatus.paused);
    logger.logInfo(message: 'Plantis sync stopped');
  }

  @override
  Future<bool> checkConnectivity() async {
    return true;
  }

  @override
  Future<Either<Failure, void>> clearLocalData() async {
    try {
      logger.logInfo(message: 'Clearing local sync metadata for Plantis');

      _lastSync = null;
      _hasPendingSync = false;
      _totalSyncs = 0;
      _successfulSyncs = 0;
      _failedSyncs = 0;
      _totalItemsSynced = 0;

      return const Right(null);
    } catch (e, stackTrace) {
      logger.logError(
        message: 'Failed to clear Plantis local data',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(CacheFailure('Failed to clear Plantis local data: $e'));
    }
  }

  @override
  Future<SyncStatistics> getStatistics() async {
    return SyncStatistics(
      serviceId: serviceId,
      totalSyncs: _totalSyncs,
      successfulSyncs: _successfulSyncs,
      failedSyncs: _failedSyncs,
      lastSyncTime: _lastSync,
      totalItemsSynced: _totalItemsSynced,
      metadata: {
        'entity_types': _entityTypes,
        'avg_items_per_sync':
            _successfulSyncs > 0
                ? (_totalItemsSynced / _successfulSyncs).round()
                : 0,
        'success_rate':
            _totalSyncs > 0
                ? ((_successfulSyncs / _totalSyncs) * 100).toStringAsFixed(1)
                : '0.0',
      },
    );
  }

  @override
  Future<void> dispose() async {
    logger.logInfo(message: 'Disposing Plantis Sync Service');
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;

    await _statusController.close();
    await _progressController.close();

    _isInitialized = false;
    _updateStatus(SyncServiceStatus.disposing);
  }

  /// Inicia monitoramento de conectividade (integração com NetworkInfoAdapter)

  void startConnectivityMonitoring(Stream<bool> connectivityStream) {
    try {
      _connectivitySubscription?.cancel();
      _connectivitySubscription = connectivityStream.listen(
        (isConnected) {
          logger.logConnectivityChange(
            isConnected: isConnected,
            metadata: {'auto_sync_enabled': true},
          );

          if (isConnected && _hasPendingSync) {
            logger.logInfo(
              message: 'Connection restored - triggering auto-sync',
              metadata: {'pending_sync': true},
            );
            sync();
          }
        },
        onError: (Object error) {
          logger.logError(
            message: 'Connectivity monitoring error',
            error: error,
          );
        },
      );

      logger.logInfo(
        message: 'Connectivity monitoring started',
        metadata: {'service': serviceId},
      );
    } catch (e) {
      logger.logError(
        message: 'Failed to start connectivity monitoring',
        error: e,
      );
    }
  }

  /// Para monitoramento de conectividade
  void stopConnectivityMonitoring() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;

    logger.logInfo(
      message: 'Connectivity monitoring stopped',
      metadata: {'service': serviceId},
    );
  }

  void _updateStatus(SyncServiceStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;

      if (!_statusController.isClosed) {
        _statusController.add(status);
      }

      logger.logInfo(
        message: 'Sync status changed',
        metadata: {
          'old_status': _currentStatus.name,
          'new_status': status.name,
        },
      );
    }
  }

  void _emitProgress(ServiceProgress progress) {
    if (!_progressController.isClosed) {
      _progressController.add(progress);
    }
  }
}

/// Factory para criar PlantisSyncService com dependências
class PlantisSyncServiceFactory {
  static PlantisSyncService create({
    required dynamic plantsRepository,
    required dynamic spacesRepository,
    required dynamic plantTasksRepository,
    required dynamic plantCommentsRepository,
  }) {
    return PlantisSyncService(
      plantsRepository: plantsRepository,
      spacesRepository: spacesRepository,
      plantTasksRepository: plantTasksRepository,
      plantCommentsRepository: plantCommentsRepository,
    );
  }
}
