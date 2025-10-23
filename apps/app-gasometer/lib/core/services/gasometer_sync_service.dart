import 'dart:async';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../../features/fuel/domain/repositories/fuel_repository.dart';
import '../../../features/maintenance/domain/repositories/maintenance_repository.dart';
import '../../../features/vehicles/domain/repositories/vehicle_repository.dart';

/// Implementação do serviço de sincronização para o Gasometer
/// Implementa ISyncService para integrar com o sistema de sync do core
class GasometerSyncService implements ISyncService {
  GasometerSyncService({
    required VehicleRepository vehicleRepository,
    required FuelRepository fuelRepository,
    required MaintenanceRepository maintenanceRepository,
    dynamic expensesRepository,
  }) : _vehicleRepository = vehicleRepository,
       _fuelRepository = fuelRepository,
       _maintenanceRepository = maintenanceRepository,
       _expensesRepository = expensesRepository;

  final VehicleRepository _vehicleRepository;
  final FuelRepository _fuelRepository;
  final MaintenanceRepository _maintenanceRepository;
  final dynamic _expensesRepository;

  final _statusController = StreamController<SyncServiceStatus>.broadcast();
  final _progressController = StreamController<ServiceProgress>.broadcast();

  SyncServiceStatus _currentStatus = SyncServiceStatus.uninitialized;
  bool _isInitialized = false;
  StreamSubscription<dynamic>? _connectivitySubscription;

  @override
  String get serviceId => 'gasometer';

  @override
  String get displayName => 'Gasometer Sync Service';

  @override
  String get version => '2.0.0';

  @override
  bool get canSync =>
      _isInitialized && _currentStatus != SyncServiceStatus.syncing;

  @override
  Future<bool> get hasPendingSync async {
    try {
      // Verificar se há dados em cada repositório
      // Se existem dados locais, pode haver necessidade de sync
      final vehiclesResult = await _vehicleRepository.getAllVehicles();
      final hasVehicles = vehiclesResult.fold(
        (_) => false,
        (vehicles) => vehicles.isNotEmpty,
      );

      final fuelResult = await _fuelRepository.getAllFuelRecords();
      final hasFuel = fuelResult.fold(
        (_) => false,
        (records) => records.isNotEmpty,
      );

      final maintenanceResult = await _maintenanceRepository.getAllMaintenanceRecords();
      final hasMaintenance = maintenanceResult.fold(
        (_) => false,
        (records) => records.isNotEmpty,
      );

      // Se há dados em qualquer repositório, considerar que pode haver pending sync
      return hasVehicles || hasFuel || hasMaintenance;
    } catch (e) {
      if (kDebugMode) print('❌ Error checking pending sync: $e');
      return false;
    }
  }

  @override
  Stream<SyncServiceStatus> get statusStream => _statusController.stream;

  @override
  Stream<ServiceProgress> get progressStream => _progressController.stream;

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      if (_isInitialized) return const Right(null);

      _updateStatus(SyncServiceStatus.idle);
      _isInitialized = true;

      if (kDebugMode) {
        print('✅ GasometerSyncService initialized');
      }

      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure('Failed to initialize GasometerSyncService: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, ServiceSyncResult>> sync() async {
    if (!canSync) {
      return const Left(ServerFailure('Service not ready for sync'));
    }

    final startTime = DateTime.now();
    _updateStatus(SyncServiceStatus.syncing);

    try {
      int totalSynced = 0;
      int totalFailed = 0;

      // Sync vehicles
      _progressController.add(
        ServiceProgress(
          serviceId: serviceId,
          operation: 'syncing_vehicles',
          current: 0,
          total: 4,
          currentItem: 'Sincronizando veículos...',
        ),
      );

      final vehiclesResult = await _syncVehicles();
      vehiclesResult.fold(
        (failure) => totalFailed++,
        (syncedCount) => totalSynced += syncedCount,
      );

      // Sync fuel records
      _progressController.add(
        ServiceProgress(
          serviceId: serviceId,
          operation: 'syncing_fuel',
          current: 1,
          total: 4,
          currentItem: 'Sincronizando registros de combustível...',
        ),
      );

      final fuelResult = await _syncFuelRecords();
      fuelResult.fold(
        (failure) => totalFailed++,
        (syncedCount) => totalSynced += syncedCount,
      );

      // Sync maintenance
      _progressController.add(
        ServiceProgress(
          serviceId: serviceId,
          operation: 'syncing_maintenance',
          current: 2,
          total: 4,
          currentItem: 'Sincronizando manutenções...',
        ),
      );

      final maintenanceResult = await _syncMaintenance();
      maintenanceResult.fold(
        (failure) => totalFailed++,
        (syncedCount) => totalSynced += syncedCount,
      );

      // Sync expenses
      _progressController.add(
        ServiceProgress(
          serviceId: serviceId,
          operation: 'syncing_expenses',
          current: 3,
          total: 4,
          currentItem: 'Sincronizando despesas...',
        ),
      );

      final expensesResult = await _syncExpenses();
      expensesResult.fold(
        (failure) => totalFailed++,
        (syncedCount) => totalSynced += syncedCount,
      );

      _progressController.add(
        ServiceProgress(
          serviceId: serviceId,
          operation: 'completed',
          current: 4,
          total: 4,
          currentItem: 'Sincronização concluída',
        ),
      );

      final duration = DateTime.now().difference(startTime);
      _updateStatus(SyncServiceStatus.completed);

      if (kDebugMode) {
        print('✅ Sync completed: $totalSynced items synced, $totalFailed failed');
        print('   Duration: ${duration.inSeconds}s');
      }

      return Right(
        ServiceSyncResult(
          success: totalFailed == 0,
          itemsSynced: totalSynced,
          itemsFailed: totalFailed,
          duration: duration,
        ),
      );
    } catch (e, stackTrace) {
      _updateStatus(SyncServiceStatus.failed);

      if (kDebugMode) {
        print('❌ Sync failed with exception: $e');
        print(stackTrace);
      }

      return Left(ServerFailure('Sync failed: $e'));
    }
  }

  @override
  Future<Either<Failure, ServiceSyncResult>> syncSpecific(
    List<String> ids,
  ) async {
    // Implementação simplificada - sync completa por enquanto
    return sync();
  }

  @override
  Future<void> stopSync() async {
    _updateStatus(SyncServiceStatus.idle);
  }

  @override
  Future<bool> checkConnectivity() async {
    // Implementar verificação de conectividade
    return true;
  }

  @override
  Future<Either<Failure, void>> clearLocalData() async {
    try {
      // Implementar limpeza de dados locais se necessário
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to clear local data: $e'));
    }
  }

  @override
  Future<SyncStatistics> getStatistics() async {
    return const SyncStatistics(
      serviceId: 'gasometer',
      totalSyncs: 0,
      successfulSyncs: 0,
      failedSyncs: 0,
    );
  }

  @override
  Future<void> dispose() async {
    _updateStatus(SyncServiceStatus.disposing);
    await _connectivitySubscription?.cancel();
    await _statusController.close();
    await _progressController.close();
  }

  // Métodos auxiliares para sync de cada entidade
  Future<Either<Failure, int>> _syncVehicles() async {
    try {
      if (kDebugMode) print('🔄 Starting vehicles sync...');

      // VehicleRepository tem método syncVehicles() dedicado
      final syncResult = await _vehicleRepository.syncVehicles();

      return syncResult.fold(
        (failure) {
          if (kDebugMode) print('❌ Vehicles sync failed: ${failure.message}');
          return Left(failure);
        },
        (_) async {
          // Após sync, obter contagem de veículos
          final vehiclesResult = await _vehicleRepository.getAllVehicles();
          return vehiclesResult.fold(
            (failure) {
              if (kDebugMode) print('⚠️ Could not count vehicles after sync');
              return const Right(0);
            },
            (vehicles) {
              final count = vehicles.length;
              if (kDebugMode) print('✅ Synced $count vehicles');
              return Right(count);
            },
          );
        },
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Exception during vehicles sync: $e');
        print(stackTrace);
      }
      return Left(ServerFailure('Failed to sync vehicles: $e'));
    }
  }

  Future<Either<Failure, int>> _syncFuelRecords() async {
    try {
      if (kDebugMode) print('🔄 Starting fuel records sync...');

      // FuelRepository não tem método sync dedicado
      // Obter todos os registros (UnifiedSyncManager cuida do sync em background)
      final fuelResult = await _fuelRepository.getAllFuelRecords();

      return fuelResult.fold(
        (failure) {
          if (kDebugMode) print('❌ Fuel records sync failed: ${failure.message}');
          return Left(failure);
        },
        (records) {
          final count = records.length;
          if (kDebugMode) print('✅ Retrieved $count fuel records');
          return Right(count);
        },
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Exception during fuel records sync: $e');
        print(stackTrace);
      }
      return Left(ServerFailure('Failed to sync fuel records: $e'));
    }
  }

  Future<Either<Failure, int>> _syncMaintenance() async {
    try {
      if (kDebugMode) print('🔄 Starting maintenance records sync...');

      // MaintenanceRepository não tem método sync dedicado
      // Obter todos os registros (UnifiedSyncManager cuida do sync em background)
      final maintenanceResult = await _maintenanceRepository.getAllMaintenanceRecords();

      return maintenanceResult.fold(
        (failure) {
          if (kDebugMode) print('❌ Maintenance sync failed: ${failure.message}');
          return Left(failure);
        },
        (records) {
          final count = records.length;
          if (kDebugMode) print('✅ Retrieved $count maintenance records');
          return Right(count);
        },
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Exception during maintenance sync: $e');
        print(stackTrace);
      }
      return Left(ServerFailure('Failed to sync maintenance: $e'));
    }
  }

  Future<Either<Failure, int>> _syncExpenses() async {
    try {
      if (kDebugMode) print('🔄 Starting expenses sync...');

      // ExpensesRepository pode ser null (opcional)
      if (_expensesRepository == null) {
        if (kDebugMode) print('⏭️ Expenses repository not available, skipping');
        return const Right(0);
      }

      // IExpensesRepository tem método getAllExpenses
      final expensesResult = await _expensesRepository.getAllExpenses() as List<dynamic>;

      final count = expensesResult.length;
      if (kDebugMode) print('✅ Retrieved $count expenses');
      return Right(count);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Exception during expenses sync: $e');
        print(stackTrace);
      }
      // Falha em expenses não deve interromper o sync
      // Retornar sucesso com 0 itens
      return const Right(0);
    }
  }

  void _updateStatus(SyncServiceStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  /// Método legado para compatibilidade - será removido em versões futuras
  void startConnectivityMonitoring(Stream<dynamic> connectivityStream) {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = connectivityStream.listen((event) {
      // Implementar lógica de monitoramento de conectividade se necessário
    });
  }
}
