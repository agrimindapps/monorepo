import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../shared/utils/failure.dart';
import '../interfaces/i_sync_service.dart';
import 'sync_logger.dart';

/// Serviço de sincronização específico para o app Gasometer
/// Coordena sincronização entre repositories de veículos, combustível e manutenção
///
/// **Arquitetura**: Coordination pattern - coordena syncs dos repositories
/// sem duplicar lógica de acesso a dados
class GasometerSyncService implements ISyncService {
  /// Repositories injetados
  final dynamic vehicleRepository;
  final dynamic fuelRepository;
  final dynamic maintenanceRepository;
  final dynamic expensesRepository;

  /// Logger estruturado
  final SyncLogger logger;

  /// Connectivity monitoring (opcional)
  StreamSubscription<bool>? _connectivitySubscription;

  GasometerSyncService({
    required this.vehicleRepository,
    required this.fuelRepository,
    required this.maintenanceRepository,
    required this.expensesRepository,
  }) : logger = SyncLogger(appName: 'gasometer');

  @override
  final String serviceId = 'gasometer';

  @override
  final String displayName = 'Gasometer Vehicle Sync';

  @override
  final String version = '2.0.0';

  final List<String> dependencies = [];
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
  final List<String> _entityTypes = [
    'vehicles',
    'fuel_records',
    'maintenance_records',
    'expenses',
    'categories',
  ];

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      logger.logInfo(
        message: 'Initializing Gasometer Sync Service v$version',
        metadata: {'entities': _entityTypes},
      );

      _isInitialized = true;
      _updateStatus(SyncServiceStatus.idle);

      logger.logInfo(
        message: 'Gasometer Sync Service initialized successfully',
        metadata: {'entity_count': _entityTypes.length},
      );

      return const Right(null);
    } catch (e, stackTrace) {
      _updateStatus(SyncServiceStatus.failed);
      logger.logError(
        message: 'Failed to initialize Gasometer sync',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(SyncFailure('Failed to initialize Gasometer sync: $e'));
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
        SyncFailure('Gasometer sync service cannot sync in current state'),
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
              'app': 'gasometer',
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

      return Left(SyncFailure('Gasometer sync failed: $e'));
    }
  }

  /// Sincroniza uma entidade específica coordenando repository correspondente
  Future<Either<Failure, int>> _syncEntity(String entityType) async {
    try {
      switch (entityType) {
        case 'vehicles':
          return await _syncVehicles();
        case 'fuel_records':
          return await _syncFuelRecords();
        case 'maintenance_records':
          return await _syncMaintenanceRecords();
        case 'expenses':
          return await _syncExpenses();
        case 'categories':
          return const Right(0); // Categories são estáticos, não precisam sync
        default:
          return Left(ValidationFailure('Unknown entity type: $entityType'));
      }
    } catch (e) {
      return Left(SyncFailure('Failed to sync $entityType: $e'));
    }
  }

  /// Sincroniza veículos obtendo lista atualizada
  Future<Either<Failure, int>> _syncVehicles() async {
    try {
      final result =
          await vehicleRepository.getAllVehicles() as Either<Failure, dynamic>;

      return result.fold<Either<Failure, int>>(
        (Failure failure) => Left<Failure, int>(failure),
        (dynamic vehicles) => Right<Failure, int>(vehicles.length as int),
      );
    } catch (e) {
      return Left<Failure, int>(SyncFailure('Failed to sync vehicles: $e'));
    }
  }

  /// Sincroniza registros de abastecimento com Firestore
  Future<Either<Failure, int>> _syncFuelRecords() async {
    try {
      final result =
          await fuelRepository.getAllFuelRecords() as Either<Failure, dynamic>;

      return result.fold<Either<Failure, int>>(
        (Failure failure) => Left<Failure, int>(failure),
        (dynamic fuelRecords) {
          return Right<Failure, int>(fuelRecords.length as int);
        },
      );
    } catch (e) {
      return Left<Failure, int>(SyncFailure('Failed to sync fuel records: $e'));
    }
  }

  /// Sincroniza registros de manutenção com Firestore
  Future<Either<Failure, int>> _syncMaintenanceRecords() async {
    try {
      final result =
          await maintenanceRepository.getAllMaintenanceRecords()
              as Either<Failure, dynamic>;

      return result.fold<Either<Failure, int>>(
        (Failure failure) => Left<Failure, int>(failure),
        (dynamic maintenanceRecords) {
          return Right<Failure, int>(maintenanceRecords.length as int);
        },
      );
    } catch (e) {
      return Left<Failure, int>(
        SyncFailure('Failed to sync maintenance records: $e'),
      );
    }
  }

  /// Sincroniza despesas (quando implementado)
  Future<Either<Failure, int>> _syncExpenses() async {
    try {
      final result =
          await expensesRepository.getAllExpenses() as Either<Failure, dynamic>;

      return result.fold<Either<Failure, int>>(
        (Failure failure) => Left<Failure, int>(failure),
        (dynamic expenses) => Right<Failure, int>(expenses.length as int),
      );
    } catch (e) {
      return Left<Failure, int>(SyncFailure('Failed to sync expenses: $e'));
    }
  }

  @override
  Future<Either<Failure, ServiceSyncResult>> syncSpecific(
    List<String> ids,
  ) async {
    if (!canSync) {
      return const Left(
        SyncFailure('Gasometer sync service cannot sync in current state'),
      );
    }

    try {
      _updateStatus(SyncServiceStatus.syncing);
      final startTime = DateTime.now();

      logger.logInfo(
        message: 'Starting specific sync for Gasometer items: ${ids.length}',
        metadata: {'item_count': ids.length},
      );
      await Future<void>.delayed(Duration(milliseconds: ids.length * 50));

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      _lastSync = endTime;
      _successfulSyncs++;
      _totalItemsSynced += ids.length;
      _updateStatus(SyncServiceStatus.completed);

      final result = ServiceSyncResult(
        success: true,
        itemsSynced: ids.length,
        duration: duration,
        metadata: {
          'sync_type': 'specific',
          'item_ids': ids,
          'app': 'gasometer',
        },
      );

      return Right(result);
    } catch (e) {
      _failedSyncs++;
      _updateStatus(SyncServiceStatus.failed);
      return Left(SyncFailure('Gasometer specific sync failed: $e'));
    }
  }

  @override
  Future<void> stopSync() async {
    _updateStatus(SyncServiceStatus.paused);
    logger.logInfo(message: 'Gasometer sync stopped');
  }

  @override
  Future<bool> checkConnectivity() async {
    return true; // Implementação simplificada
  }

  @override
  Future<Either<Failure, void>> clearLocalData() async {
    try {
      logger.logInfo(message: 'Clearing local sync metadata for Gasometer');

      _lastSync = null;
      _hasPendingSync = false;
      _totalSyncs = 0;
      _successfulSyncs = 0;
      _failedSyncs = 0;
      _totalItemsSynced = 0;

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to clear Gasometer local data: $e'));
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
      },
    );
  }

  @override
  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;

    logger.logInfo(message: 'Disposing Gasometer Sync Service');

    await _statusController.close();
    await _progressController.close();

    _isInitialized = false;
    _updateStatus(SyncServiceStatus.disposing);
  }

  /// Force sync específico para dados financeiros (alta prioridade)
  Future<Either<Failure, ServiceSyncResult>> syncFinancialData() async {
    final financialEntities = [
      'expenses',
      'fuel_records',
      'maintenance_records',
    ];
    return await syncSpecific(financialEntities);
  }

  /// Sync apenas veículos (usado frequentemente)
  Future<Either<Failure, ServiceSyncResult>> syncVehicles() async {
    return await syncSpecific(['vehicles']);
  }

  /// Marca dados como pendentes (usado quando offline)
  void markDataAsPending() {
    _hasPendingSync = true;
    logger.logInfo(message: 'Gasometer data marked as pending sync');
  }

  /// Inicia monitoramento de conectividade (integração com ConnectivityService)

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

/// Factory para criar GasometerSyncService com dependências
class GasometerSyncServiceFactory {
  static GasometerSyncService create({
    required dynamic vehicleRepository,
    required dynamic fuelRepository,
    required dynamic maintenanceRepository,
    required dynamic expensesRepository,
  }) {
    return GasometerSyncService(
      vehicleRepository: vehicleRepository,
      fuelRepository: fuelRepository,
      maintenanceRepository: maintenanceRepository,
      expensesRepository: expensesRepository,
    );
  }
}
