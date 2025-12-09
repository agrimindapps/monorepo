import 'dart:developer' as developer;

import 'package:core/core.dart';

import '../../../../database/repositories/fuel_supply_repository.dart';
import '../../../vehicles/domain/entities/vehicle_entity.dart';
import '../../../vehicles/domain/repositories/vehicle_repository.dart';
import '../../domain/entities/fuel_record_entity.dart';
import '../../domain/repositories/fuel_repository.dart';
import '../datasources/fuel_supply_local_datasource.dart';
import '../sync/fuel_supply_drift_sync_adapter.dart';

/// Implementação do repositório de combustível usando Drift
/// 
/// Padrão "Sync-on-Write": Sincroniza imediatamente com Firebase quando online,
/// seguindo o padrão do app-plantis. Background sync permanece como fallback.

class FuelRepositoryDriftImpl implements FuelRepository {
  const FuelRepositoryDriftImpl(
    this._dataSource,
    this._connectivityService,
    this._syncAdapter,
    this._vehicleRepository,
  );

  final FuelSupplyLocalDataSource _dataSource;
  final ConnectivityService _connectivityService;
  final FuelSupplyDriftSyncAdapter _syncAdapter;
  final VehicleRepository _vehicleRepository;

  String get _userId {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }

  // ========== CONVERSÕES ==========

  FuelRecordEntity _toEntity(FuelSupplyData data) {
    return FuelRecordEntity(
      id: data.id.toString(),
      vehicleId: data.vehicleId.toString(),
      fuelType: FuelType.values[data.fuelType],
      liters: data.liters,
      pricePerLiter: data.pricePerLiter,
      totalPrice: data.totalPrice,
      odometer: data.odometer,
      date: DateTime.fromMillisecondsSinceEpoch(data.date),
      gasStationName: data.gasStationName,
      fullTank: data.fullTank ?? true,
      notes: data.notes,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      lastSyncAt: data.lastSyncAt,
      isDirty: data.isDirty,
      isDeleted: data.isDeleted,
      version: data.version,
      userId: data.userId,
      moduleName: data.moduleName,
    );
  }

  // ========== CRUD BÁSICO ==========

  @override
  Future<Either<Failure, List<FuelRecordEntity>>> getAllFuelRecords() async {
    try {
      final dataList = await _dataSource.findAll();
      final entities = dataList.map(_toEntity).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FuelRecordEntity>>> getFuelRecordsByVehicle(
    String vehicleId,
  ) async {
    try {
      final vehicleIdInt = int.parse(vehicleId);
      final dataList = await _dataSource.findByVehicleId(vehicleIdInt);
      final entities = dataList.map(_toEntity).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FuelRecordEntity?>> getFuelRecordById(
    String id,
  ) async {
    try {
      final idInt = int.parse(id);
      final data = await _dataSource.findById(idInt);
      final entity = data != null ? _toEntity(data) : null;
      return Right(entity);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FuelRecordEntity>> addFuelRecord(
    FuelRecordEntity fuelRecord,
  ) async {
    try {
      developer.log(
        '🔵 FuelRepository.addFuelRecord() - Starting',
        name: 'FuelRepository',
      );

      // 1. Salvar localmente primeiro (sempre)
      final id = await _dataSource.create(
        userId: _userId,
        vehicleId: int.parse(fuelRecord.vehicleId),
        date: fuelRecord.date,
        odometer: fuelRecord.odometer,
        liters: fuelRecord.liters,
        pricePerLiter: fuelRecord.pricePerLiter,
        totalPrice: fuelRecord.totalPrice,
        fullTank: fuelRecord.fullTank,
        fuelType: fuelRecord.fuelType.index,
        gasStationName: fuelRecord.gasStationName,
        notes: fuelRecord.notes,
      );

      final created = await _dataSource.findById(id);
      if (created == null) {
        return const Left(CacheFailure('Failed to retrieve created record'));
      }

      var entity = _toEntity(created);
      developer.log(
        '✅ FuelRepository.addFuelRecord() - Saved locally with id=$id',
        name: 'FuelRepository',
      );

      // Atualizar odômetro do veículo
      await _vehicleRepository.updateVehicleOdometer(
        fuelRecord.vehicleId,
        fuelRecord.odometer.toInt(),
      );

      // 2. Sync-on-Write: Se online, sincronizar imediatamente com Firebase
      final isOnlineResult = await _connectivityService.isOnline();
      final isOnline = isOnlineResult.fold((_) => false, (online) => online);

      if (isOnline) {
        developer.log(
          '🌐 FuelRepository.addFuelRecord() - Online, syncing to Firebase...',
          name: 'FuelRepository',
        );
        try {
          // Push para Firebase usando o adapter
          final pushResult = await _syncAdapter.pushDirtyRecords(_userId);
          
          pushResult.fold(
            (failure) {
              developer.log(
                '⚠️ FuelRepository.addFuelRecord() - Sync failed: ${failure.message}. Will retry via background sync.',
                name: 'FuelRepository',
              );
            },
            (result) {
              developer.log(
                '✅ FuelRepository.addFuelRecord() - Synced to Firebase (${result.recordsPushed} pushed, ${result.recordsFailed} failed)',
                name: 'FuelRepository',
              );
            },
          );
          
          // Reload entity com estado atualizado (isDirty=false, firebaseId set)
          final refreshed = await _dataSource.findById(id);
          if (refreshed != null) {
            entity = _toEntity(refreshed);
          }
        } catch (e) {
          developer.log(
            '⚠️ FuelRepository.addFuelRecord() - Sync error: $e. Will retry via background sync.',
            name: 'FuelRepository',
          );
          // Falhou remoto, mas local já está salvo - retorna local
        }
      } else {
        developer.log(
          '📴 FuelRepository.addFuelRecord() - Offline, will sync later via background sync',
          name: 'FuelRepository',
        );
      }

      return Right(entity);
    } catch (e) {
      developer.log(
        '❌ FuelRepository.addFuelRecord() - Error: $e',
        name: 'FuelRepository',
      );
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FuelRecordEntity>> updateFuelRecord(
    FuelRecordEntity fuelRecord,
  ) async {
    try {
      developer.log(
        '🔵 FuelRepository.updateFuelRecord() - Starting for id=${fuelRecord.id}',
        name: 'FuelRepository',
      );

      // 1. Atualizar localmente primeiro
      final success = await _dataSource.update(
        id: int.parse(fuelRecord.id),
        userId: _userId,
        vehicleId: int.parse(fuelRecord.vehicleId),
        date: fuelRecord.date,
        odometer: fuelRecord.odometer,
        liters: fuelRecord.liters,
        pricePerLiter: fuelRecord.pricePerLiter,
        totalPrice: fuelRecord.totalPrice,
        fullTank: fuelRecord.fullTank,
        fuelType: fuelRecord.fuelType.index,
        gasStationName: fuelRecord.gasStationName,
        notes: fuelRecord.notes,
      );

      if (!success) {
        return const Left(CacheFailure('Failed to update fuel record'));
      }

      final updated = await _dataSource.findById(int.parse(fuelRecord.id));
      if (updated == null) {
        return const Left(CacheFailure('Failed to retrieve updated record'));
      }

      var entity = _toEntity(updated);
      developer.log(
        '✅ FuelRepository.updateFuelRecord() - Updated locally',
        name: 'FuelRepository',
      );

      // Atualizar odômetro do veículo
      await _vehicleRepository.updateVehicleOdometer(
        fuelRecord.vehicleId,
        fuelRecord.odometer.toInt(),
      );

      // 2. Sync-on-Write: Se online, sincronizar imediatamente
      final isOnlineResult = await _connectivityService.isOnline();
      final isOnline = isOnlineResult.fold((_) => false, (online) => online);

      if (isOnline) {
        developer.log(
          '🌐 FuelRepository.updateFuelRecord() - Online, syncing to Firebase...',
          name: 'FuelRepository',
        );
        try {
          final pushResult = await _syncAdapter.pushDirtyRecords(_userId);
          
          pushResult.fold(
            (failure) {
              developer.log(
                '⚠️ FuelRepository.updateFuelRecord() - Sync failed: ${failure.message}',
                name: 'FuelRepository',
              );
            },
            (result) {
              developer.log(
                '✅ FuelRepository.updateFuelRecord() - Synced to Firebase',
                name: 'FuelRepository',
              );
            },
          );
          
          // Reload entity com estado atualizado
          final refreshed = await _dataSource.findById(int.parse(fuelRecord.id));
          if (refreshed != null) {
            entity = _toEntity(refreshed);
          }
        } catch (e) {
          developer.log(
            '⚠️ FuelRepository.updateFuelRecord() - Sync error: $e',
            name: 'FuelRepository',
          );
        }
      }

      return Right(entity);
    } catch (e) {
      developer.log(
        '❌ FuelRepository.updateFuelRecord() - Error: $e',
        name: 'FuelRepository',
      );
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteFuelRecord(String id) async {
    try {
      developer.log(
        '🔵 FuelRepository.deleteFuelRecord() - Starting for id=$id',
        name: 'FuelRepository',
      );

      // 1. Soft delete localmente primeiro (marca isDeleted=true, isDirty=true)
      final idInt = int.parse(id);
      final success = await _dataSource.delete(idInt);

      if (!success) {
        return const Left(CacheFailure('Failed to delete fuel record'));
      }

      developer.log(
        '✅ FuelRepository.deleteFuelRecord() - Marked as deleted locally',
        name: 'FuelRepository',
      );

      // 2. Sync-on-Write: Se online, sincronizar imediatamente
      final isOnlineResult = await _connectivityService.isOnline();
      final isOnline = isOnlineResult.fold((_) => false, (online) => online);

      if (isOnline) {
        developer.log(
          '🌐 FuelRepository.deleteFuelRecord() - Online, syncing deletion to Firebase...',
          name: 'FuelRepository',
        );
        try {
          final pushResult = await _syncAdapter.pushDirtyRecords(_userId);
          
          pushResult.fold(
            (failure) {
              developer.log(
                '⚠️ FuelRepository.deleteFuelRecord() - Sync failed: ${failure.message}',
                name: 'FuelRepository',
              );
            },
            (result) {
              developer.log(
                '✅ FuelRepository.deleteFuelRecord() - Synced deletion to Firebase',
                name: 'FuelRepository',
              );
            },
          );
        } catch (e) {
          developer.log(
            '⚠️ FuelRepository.deleteFuelRecord() - Sync error: $e',
            name: 'FuelRepository',
          );
        }
      }

      return const Right(unit);
    } catch (e) {
      developer.log(
        '❌ FuelRepository.deleteFuelRecord() - Error: $e',
        name: 'FuelRepository',
      );
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FuelRecordEntity>>> searchFuelRecords(
    String query,
  ) async {
    try {
      // Por enquanto retorna todos e filtra localmente
      final dataList = await _dataSource.findAll();
      final entities = dataList.map(_toEntity).where((entity) {
        final matchesStation =
            entity.gasStationName?.toLowerCase().contains(
              query.toLowerCase(),
            ) ??
            false;
        final matchesNotes =
            entity.notes?.toLowerCase().contains(query.toLowerCase()) ?? false;
        return matchesStation || matchesNotes;
      }).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<FuelRecordEntity>>> watchFuelRecords() {
    try {
      return _dataSource
          .watchAll()
          .map((dataList) {
            final entities = dataList.map(_toEntity).toList();
            return Right<Failure, List<FuelRecordEntity>>(entities);
          })
          .handleError((Object error, StackTrace stackTrace) {
            return Left<Failure, List<FuelRecordEntity>>(
              CacheFailure(error.toString()),
            );
          });
    } catch (e) {
      return Stream.value(Left(CacheFailure(e.toString())));
    }
  }

  @override
  Stream<Either<Failure, List<FuelRecordEntity>>> watchFuelRecordsByVehicle(
    String vehicleId,
  ) {
    try {
      final vehicleIdInt = int.parse(vehicleId);
      return _dataSource
          .watchByVehicleId(vehicleIdInt)
          .map((dataList) {
            final entities = dataList.map(_toEntity).toList();
            return Right<Failure, List<FuelRecordEntity>>(entities);
          })
          .handleError((Object error, StackTrace stackTrace) {
            return Left<Failure, List<FuelRecordEntity>>(
              CacheFailure(error.toString()),
            );
          });
    } catch (e) {
      return Stream.value(Left(CacheFailure(e.toString())));
    }
  }

  @override
  Future<Either<Failure, double>> getAverageConsumption(
    String vehicleId,
  ) async {
    try {
      final vehicleIdInt = int.parse(vehicleId);
      // Buscar abastecimentos com tanque cheio
      final fullTanks = await _dataSource.findFullTankByVehicleId(vehicleIdInt);

      if (fullTanks.length < 2) {
        return const Right(0.0);
      }

      // Calcular consumo médio entre tanques cheios consecutivos
      double totalConsumption = 0.0;
      int validCalculations = 0;

      for (int i = 1; i < fullTanks.length; i++) {
        final current = fullTanks[i];
        final previous = fullTanks[i - 1];

        final distance = current.odometer - previous.odometer;
        if (distance > 0 && current.liters > 0) {
          final consumption = distance / current.liters;
          totalConsumption += consumption;
          validCalculations++;
        }
      }

      if (validCalculations == 0) {
        return const Right(0.0);
      }

      final averageConsumption = totalConsumption / validCalculations;
      return Right(averageConsumption);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalSpent(
    String vehicleId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final vehicleIdInt = int.parse(vehicleId);
      final total = await _dataSource.calculateTotalSpent(
        vehicleIdInt,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(total);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FuelRecordEntity>>> getRecentFuelRecords(
    String vehicleId, {
    int limit = 10,
  }) async {
    try {
      final vehicleIdInt = int.parse(vehicleId);
      final dataList = await _dataSource.findByVehicleId(
        vehicleIdInt,
        limit: limit,
      );
      final entities = dataList.map(_toEntity).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
