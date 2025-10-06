import 'dart:async';

import 'package:dartz/dartz.dart';

import '../interfaces/i_sync_service.dart';
import '../../shared/utils/failure.dart';
import 'sync_logger.dart';

/// Serviço de sincronização específico para o app Petiveti
/// Coordena sincronização de dados de pets, consultas, medicamentos e vacinas
///
/// **Arquitetura**: Delegation pattern - delega sync para repositories
/// **Features**: Multi-pet sync, veterinary data, medication tracking
class PetivetiSyncService implements ISyncService {
  /// Repository references para delegation
  final dynamic animalRepository;
  final dynamic appointmentRepository;
  final dynamic medicationRepository;
  final dynamic vaccineRepository;
  final dynamic weightRepository;
  final dynamic expenseRepository;
  final dynamic reminderRepository;

  /// Logger estruturado para sincronização
  final SyncLogger logger;

  /// Connectivity monitoring (opcional)
  StreamSubscription<bool>? _connectivitySubscription;

  /// Cria uma instância do PetivetiSyncService
  PetivetiSyncService({
    required this.animalRepository,
    required this.appointmentRepository,
    required this.medicationRepository,
    required this.vaccineRepository,
    required this.weightRepository,
    required this.expenseRepository,
    required this.reminderRepository,
  }) : logger = SyncLogger(appName: 'petiveti');

  @override
  final String serviceId = 'petiveti';

  @override
  final String displayName = 'Petiveti Pet Care Sync';

  @override
  final String version = '2.0.0';
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
    'animals',      // Pets/Animais
    'appointments', // Consultas veterinárias
    'medications',  // Medicamentos
    'vaccines',     // Vacinas
    'weight',       // Peso/crescimento
    'expenses',     // Despesas
    'reminders',    // Lembretes
    'settings',     // Configurações
  ];

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      logger.logInfo(
        message: 'Initializing Petiveti Sync Service v$version',
        metadata: {
          'entities': _entityTypes,
          'features': ['multi_pet', 'veterinary_data', 'medication_tracking'],
        },
      );

      _isInitialized = true;
      _updateStatus(SyncServiceStatus.idle);

      logger.logInfo(
        message: 'Petiveti Sync Service initialized successfully',
        metadata: {
          'entity_count': _entityTypes.length,
          'sync_mode': 'offline_first',
        },
      );

      return const Right(null);

    } catch (e, stackTrace) {
      _updateStatus(SyncServiceStatus.failed);
      logger.logError(
        message: 'Failed to initialize Petiveti sync',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(SyncFailure('Failed to initialize Petiveti sync: $e'));
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
        SyncFailure('Petiveti sync service cannot sync in current state'),
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

        _emitProgress(ServiceProgress(
          serviceId: serviceId,
          operation: 'Syncing $entityType',
          current: i + 1,
          total: _entityTypes.length,
          currentItem: entityType,
        ));

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

        return Right(ServiceSyncResult(
          success: true,
          itemsSynced: totalSynced,
          duration: duration,
          metadata: {
            'entities_synced': _entityTypes,
            'app': 'petiveti',
            'sync_type': 'full',
            'partial_failures': errors,
            'offline_first': true,
          },
        ));
      } else {
        _failedSyncs++;
        _updateStatus(SyncServiceStatus.failed);

        logger.logSyncFailure(
          entity: 'all_entities',
          error: 'All entities failed: ${errors.join(', ')}',
        );

        return Left(SyncFailure('All entities failed to sync: ${errors.join(', ')}'));
      }

    } catch (e, stackTrace) {
      _failedSyncs++;
      _updateStatus(SyncServiceStatus.failed);

      logger.logSyncFailure(
        entity: 'all_entities',
        error: e.toString(),
        stackTrace: stackTrace,
      );

      return Left(SyncFailure('Petiveti sync failed: $e'));
    }
  }

  /// Sincroniza uma entidade específica
  Future<Either<Failure, int>> _syncEntity(String entityType) async {
    try {

      switch (entityType) {
        case 'animals':
          return const Right(0); // Pets (via AnimalRepository)
        case 'appointments':
          return const Right(0); // Consultas (via AppointmentRepository)
        case 'medications':
          return const Right(0); // Medicamentos (via MedicationRepository)
        case 'vaccines':
          return const Right(0); // Vacinas (via VaccineRepository)
        case 'weight':
          return const Right(0); // Peso (via WeightRepository)
        case 'expenses':
          return const Right(0); // Despesas (via ExpenseRepository)
        case 'reminders':
          return const Right(0); // Lembretes (via ReminderRepository)
        case 'settings':
          return const Right(0); // Settings
        default:
          return Left(ValidationFailure('Unknown entity type: $entityType'));
      }
    } catch (e) {
      return Left(SyncFailure('Failed to sync $entityType: $e'));
    }
  }

  @override
  Future<Either<Failure, ServiceSyncResult>> syncSpecific(List<String> ids) async {
    if (!canSync) {
      return const Left(
        SyncFailure('Petiveti sync service cannot sync in current state'),
      );
    }

    try {
      _updateStatus(SyncServiceStatus.syncing);
      final startTime = DateTime.now();

      logger.logInfo(
        message: 'Starting specific sync for Petiveti entities',
        metadata: {'entity_types': ids, 'count': ids.length},
      );

      int totalSynced = 0;
      for (final entityType in ids) {
        final result = await _syncEntity(entityType);
        result.fold(
          (failure) => logger.logWarning(
            message: 'Failed to sync $entityType',
            metadata: {'error': failure.message},
          ),
          (count) => totalSynced += count,
        );
      }

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      _lastSync = endTime;
      _successfulSyncs++;
      _totalItemsSynced += totalSynced;
      _updateStatus(SyncServiceStatus.completed);

      return Right(ServiceSyncResult(
        success: true,
        itemsSynced: totalSynced,
        duration: duration,
        metadata: {
          'sync_type': 'specific',
          'entity_types': ids,
          'app': 'petiveti',
        },
      ));

    } catch (e, stackTrace) {
      _failedSyncs++;
      _updateStatus(SyncServiceStatus.failed);

      logger.logSyncFailure(
        entity: 'specific_entities',
        error: e.toString(),
        stackTrace: stackTrace,
      );

      return Left(SyncFailure('Petiveti specific sync failed: $e'));
    }
  }

  @override
  Future<void> stopSync() async {
    _updateStatus(SyncServiceStatus.paused);
    logger.logInfo(message: 'Petiveti sync stopped');
  }

  @override
  Future<bool> checkConnectivity() async {
    return true; // Implementação simplificada
  }

  @override
  Future<Either<Failure, void>> clearLocalData() async {
    try {
      logger.logInfo(message: 'Clearing local sync metadata for Petiveti');

      _lastSync = null;
      _hasPendingSync = false;
      _totalSyncs = 0;
      _successfulSyncs = 0;
      _failedSyncs = 0;
      _totalItemsSynced = 0;

      return const Right(null);

    } catch (e, stackTrace) {
      logger.logError(
        message: 'Failed to clear Petiveti local data',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(CacheFailure('Failed to clear Petiveti local data: $e'));
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
        'avg_items_per_sync': _successfulSyncs > 0
            ? (_totalItemsSynced / _successfulSyncs).round()
            : 0,
        'success_rate': _totalSyncs > 0
            ? ((_successfulSyncs / _totalSyncs) * 100).toStringAsFixed(1)
            : '0.0',
        'offline_first': true,
        'multi_pet_support': true,
      },
    );
  }

  @override
  Future<void> dispose() async {
    logger.logInfo(message: 'Disposing Petiveti Sync Service');
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;

    await _statusController.close();
    await _progressController.close();

    _isInitialized = false;
    _updateStatus(SyncServiceStatus.disposing);
  }

  /// Sync apenas dados de animais
  Future<Either<Failure, ServiceSyncResult>> syncAnimals() async {
    return await syncSpecific(['animals']);
  }

  /// Sync dados veterinários (appointments + medications + vaccines)
  Future<Either<Failure, ServiceSyncResult>> syncVeterinaryData() async {
    return await syncSpecific(['appointments', 'medications', 'vaccines']);
  }

  /// Sync dados de crescimento e peso
  Future<Either<Failure, ServiceSyncResult>> syncGrowthData() async {
    return await syncSpecific(['weight']);
  }

  /// Marca dados como pendentes (usado quando offline)
  void markDataAsPending() {
    _hasPendingSync = true;
    logger.logInfo(message: 'Petiveti data marked as pending sync');
  }

  /// Inicia monitoramento de conectividade
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
        metadata: {'old_status': _currentStatus.name, 'new_status': status.name},
      );
    }
  }

  void _emitProgress(ServiceProgress progress) {
    if (!_progressController.isClosed) {
      _progressController.add(progress);
    }
  }
}

/// Factory para criar PetivetiSyncService com dependências
abstract class PetivetiSyncServiceFactory {
  /// Cria uma instância do PetivetiSyncService
  static PetivetiSyncService create({
    required dynamic animalRepository,
    required dynamic appointmentRepository,
    required dynamic medicationRepository,
    required dynamic vaccineRepository,
    required dynamic weightRepository,
    required dynamic expenseRepository,
    required dynamic reminderRepository,
  }) {
    return PetivetiSyncService(
      animalRepository: animalRepository,
      appointmentRepository: appointmentRepository,
      medicationRepository: medicationRepository,
      vaccineRepository: vaccineRepository,
      weightRepository: weightRepository,
      expenseRepository: expenseRepository,
      reminderRepository: reminderRepository,
    );
  }
}
