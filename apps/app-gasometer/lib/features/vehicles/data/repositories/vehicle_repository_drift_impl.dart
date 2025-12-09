import 'dart:async';
import 'dart:developer' as developer;

import 'package:core/core.dart';
import 'package:drift/drift.dart' as drift;

import '../../../../database/gasometer_database.dart';
import '../../../../database/repositories/vehicle_repository.dart'
    as drift_repo;
import '../../domain/entities/vehicle_entity.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../datasources/vehicle_local_datasource.dart';
import '../models/vehicle_model.dart';
import '../sync/vehicle_drift_sync_adapter.dart';

/// VehicleRepository implementation using Drift
///
/// Padrão "Sync-on-Write": Sincroniza imediatamente com Firebase quando online,
/// seguindo o padrão do app-plantis. Background sync permanece como fallback.

class VehicleRepositoryDriftImpl implements VehicleRepository {
  VehicleRepositoryDriftImpl(
    this._datasource,
    this._connectivityService,
    this._syncAdapter,
  );

  final VehicleLocalDataSource _datasource;
  final ConnectivityService _connectivityService;
  final VehicleDriftSyncAdapter _syncAdapter;

  /// Get current authenticated user ID
  String get _userId {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw const UnknownFailure('No authenticated user');
    }
    return user.uid;
  }

  @override
  Future<Either<Failure, List<VehicleEntity>>> getAllVehicles() async {
    try {
      final vehicles = await _datasource.getActiveVehicles(_userId);
      final entities = vehicles.map<VehicleEntity>(_fromData).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Failed to get vehicles: $e'));
    }
  }

  @override
  Future<Either<Failure, VehicleEntity>> getVehicleById(String id) async {
    try {
      final vehicleId = int.tryParse(id);
      if (vehicleId == null) {
        return const Left(ValidationFailure('Invalid vehicle ID'));
      }

      final success = await _datasource.findById(vehicleId);
      if (success == null) {
        return const Left(NotFoundFailure('Vehicle not found'));
      }

      return Right(_fromData(success));
    } catch (e) {
      return Left(CacheFailure('Failed to get vehicle: $e'));
    }
  }

  @override
  Future<Either<Failure, VehicleEntity>> addVehicle(
    VehicleEntity vehicle,
  ) async {
    try {
      developer.log(
        '🔵 VehicleRepository.addVehicle() - Starting',
        name: 'VehicleRepository',
      );

      // 1. Salvar localmente primeiro
      final id = await _datasource.addVehicle(
        userId: _userId,
        marca: vehicle.brand,
        modelo: vehicle.model,
        ano: vehicle.year,
        placa: vehicle.licensePlate,
        cor: vehicle.color,
        combustivel: vehicle.supportedFuels.isNotEmpty
            ? _fuelTypeToIndex(vehicle.supportedFuels.first)
            : 0,
        odometroInicial: vehicle.currentOdometer,
        renavan: vehicle.metadata['renavan']?.toString() ?? '',
        chassi: vehicle.metadata['chassi']?.toString() ?? '',
        odometroAtual: vehicle.currentOdometer,
        vendido: vehicle.metadata['vendido'] as bool? ?? false,
        valorVenda: (vehicle.metadata['valorVenda'] as num?)?.toDouble() ?? 0.0,
        foto: vehicle.photoUrl,
      );

      final created = await _datasource.findById(id);
      if (created == null) {
        return const Left(CacheFailure('Failed to fetch created vehicle'));
      }

      var entity = _fromData(created);
      developer.log(
        '✅ VehicleRepository.addVehicle() - Saved locally with id=$id',
        name: 'VehicleRepository',
      );

      // 2. Sync-on-Write: Se online, sincronizar imediatamente com Firebase
      final isOnlineResult = await _connectivityService.isOnline();
      final isOnline = isOnlineResult.fold((_) => false, (online) => online);

      if (isOnline) {
        developer.log(
          '🌐 VehicleRepository.addVehicle() - Online, syncing to Firebase...',
          name: 'VehicleRepository',
        );
        try {
          final pushResult = await _syncAdapter.pushDirtyRecords(_userId);
          
          pushResult.fold(
            (failure) {
              developer.log(
                '⚠️ VehicleRepository.addVehicle() - Sync failed: ${failure.message}. Will retry via background sync.',
                name: 'VehicleRepository',
              );
            },
            (result) {
              developer.log(
                '✅ VehicleRepository.addVehicle() - Synced to Firebase (${result.recordsPushed} pushed, ${result.recordsFailed} failed)',
                name: 'VehicleRepository',
              );
            },
          );
          
          // Reload entity com estado atualizado
          final refreshed = await _datasource.findById(id);
          if (refreshed != null) {
            entity = _fromData(refreshed);
          }
        } catch (e) {
          developer.log(
            '⚠️ VehicleRepository.addVehicle() - Sync error: $e. Will retry via background sync.',
            name: 'VehicleRepository',
          );
        }
      } else {
        developer.log(
          '📴 VehicleRepository.addVehicle() - Offline, will sync later via background sync',
          name: 'VehicleRepository',
        );
      }

      return Right(entity);
    } catch (e) {
      developer.log(
        '❌ VehicleRepository.addVehicle() - Error: $e',
        name: 'VehicleRepository',
      );
      return Left(CacheFailure('Failed to add vehicle: $e'));
    }
  }

  @override
  Future<Either<Failure, VehicleEntity>> updateVehicle(
    VehicleEntity vehicle,
  ) async {
    try {
      developer.log(
        '🔵 VehicleRepository.updateVehicle() - Starting for id=${vehicle.id}',
        name: 'VehicleRepository',
      );

      final vehicleId = int.tryParse(vehicle.id);
      if (vehicleId == null) {
        return const Left(ValidationFailure('Invalid vehicle ID'));
      }

      // 1. Atualizar localmente primeiro
      final updates = VehiclesCompanion(
        marca: drift.Value(vehicle.brand),
        modelo: drift.Value(vehicle.model),
        ano: drift.Value(vehicle.year),
        placa: drift.Value(vehicle.licensePlate),
        cor: drift.Value(vehicle.color),
        combustivel: drift.Value(
          vehicle.supportedFuels.isNotEmpty
              ? _fuelTypeToIndex(vehicle.supportedFuels.first)
              : 0,
        ),
        odometroInicial: drift.Value(
          vehicle.metadata['odometroInicial'] as double? ??
              vehicle.currentOdometer,
        ),
        renavan: drift.Value(vehicle.metadata['renavan']?.toString() ?? ''),
        chassi: drift.Value(vehicle.metadata['chassi']?.toString() ?? ''),
        odometroAtual: drift.Value(vehicle.currentOdometer),
        vendido: drift.Value(vehicle.metadata['vendido'] as bool? ?? false),
        valorVenda: drift.Value(
          (vehicle.metadata['valorVenda'] as num?)?.toDouble() ?? 0.0,
        ),
        foto: drift.Value(vehicle.photoUrl),
        updatedAt: drift.Value(DateTime.now()),
        isDirty: const drift.Value(true),
      );

      final success = await _datasource.updateVehicle(vehicleId, updates);
      if (!success) {
        return const Left(CacheFailure('Failed to update vehicle'));
      }

      var entity = vehicle;
      developer.log(
        '✅ VehicleRepository.updateVehicle() - Updated locally',
        name: 'VehicleRepository',
      );

      // 2. Sync-on-Write: Se online, sincronizar imediatamente
      final isOnlineResult = await _connectivityService.isOnline();
      final isOnline = isOnlineResult.fold((_) => false, (online) => online);

      if (isOnline) {
        developer.log(
          '🌐 VehicleRepository.updateVehicle() - Online, syncing to Firebase...',
          name: 'VehicleRepository',
        );
        try {
          final pushResult = await _syncAdapter.pushDirtyRecords(_userId);
          
          pushResult.fold(
            (failure) {
              developer.log(
                '⚠️ VehicleRepository.updateVehicle() - Sync failed: ${failure.message}',
                name: 'VehicleRepository',
              );
            },
            (result) {
              developer.log(
                '✅ VehicleRepository.updateVehicle() - Synced to Firebase',
                name: 'VehicleRepository',
              );
            },
          );
          
          // Reload entity com estado atualizado
          final refreshed = await _datasource.findById(vehicleId);
          if (refreshed != null) {
            entity = _fromData(refreshed);
          }
        } catch (e) {
          developer.log(
            '⚠️ VehicleRepository.updateVehicle() - Sync error: $e',
            name: 'VehicleRepository',
          );
        }
      }

      return Right(entity);
    } catch (e) {
      developer.log(
        '❌ VehicleRepository.updateVehicle() - Error: $e',
        name: 'VehicleRepository',
      );
      return Left(CacheFailure('Failed to update vehicle: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteVehicle(String id) async {
    try {
      developer.log(
        '🔵 VehicleRepository.deleteVehicle() - Starting for id=$id',
        name: 'VehicleRepository',
      );

      final vehicleId = int.tryParse(id);
      if (vehicleId == null) {
        return const Left(ValidationFailure('Invalid vehicle ID'));
      }

      // 1. Soft delete localmente primeiro
      final success = await _datasource.deleteVehicle(vehicleId);
      if (!success) {
        return const Left(CacheFailure('Failed to delete vehicle'));
      }

      developer.log(
        '✅ VehicleRepository.deleteVehicle() - Marked as deleted locally',
        name: 'VehicleRepository',
      );

      // 2. Sync-on-Write: Se online, sincronizar imediatamente
      final isOnlineResult = await _connectivityService.isOnline();
      final isOnline = isOnlineResult.fold((_) => false, (online) => online);

      if (isOnline) {
        developer.log(
          '🌐 VehicleRepository.deleteVehicle() - Online, syncing deletion to Firebase...',
          name: 'VehicleRepository',
        );
        try {
          final pushResult = await _syncAdapter.pushDirtyRecords(_userId);
          
          pushResult.fold(
            (failure) {
              developer.log(
                '⚠️ VehicleRepository.deleteVehicle() - Sync failed: ${failure.message}',
                name: 'VehicleRepository',
              );
            },
            (result) {
              developer.log(
                '✅ VehicleRepository.deleteVehicle() - Synced deletion to Firebase',
                name: 'VehicleRepository',
              );
            },
          );
        } catch (e) {
          developer.log(
            '⚠️ VehicleRepository.deleteVehicle() - Sync error: $e',
            name: 'VehicleRepository',
          );
        }
      }

      return const Right(unit);
    } catch (e) {
      developer.log(
        '❌ VehicleRepository.deleteVehicle() - Error: $e',
        name: 'VehicleRepository',
      );
      return Left(CacheFailure('Failed to delete vehicle: $e'));
    }
  }

  /// Atualiza o odômetro atual do veículo se o novo valor for maior
  /// 
  /// Deve ser chamado sempre que um novo registro com odômetro for criado/atualizado
  /// (abastecimento, despesa, manutenção, leitura de odômetro)
  @override
  Future<Either<Failure, Unit>> updateVehicleOdometer(String vehicleId, int newOdometer) async {
    try {
      developer.log(
        '🔵 VehicleRepository.updateVehicleOdometer() - vehicleId=$vehicleId, newOdometer=$newOdometer',
        name: 'VehicleRepository',
      );

      final vehicleIdInt = int.tryParse(vehicleId);
      if (vehicleIdInt == null) {
        return Left(CacheFailure('Invalid vehicle ID: $vehicleId'));
      }

      final vehicle = await _datasource.findById(vehicleIdInt);
      if (vehicle == null) {
        developer.log(
          '⚠️ VehicleRepository.updateVehicleOdometer() - Vehicle not found',
          name: 'VehicleRepository',
        );
        return const Left(NotFoundFailure('Vehicle not found'));
      }

      // Só atualiza se o novo odômetro for maior que o atual
      if (newOdometer <= vehicle.odometroAtual) {
        developer.log(
          '⏭️ VehicleRepository.updateVehicleOdometer() - Skipping (current=${vehicle.odometroAtual} >= new=$newOdometer)',
          name: 'VehicleRepository',
        );
        return const Right(unit);
      }

      // Atualiza o odômetro
      final updates = VehiclesCompanion(
        odometroAtual: drift.Value(newOdometer.toDouble()),
        updatedAt: drift.Value(DateTime.now()),
        isDirty: const drift.Value(true),
      );

      final success = await _datasource.updateVehicle(vehicleIdInt, updates);
      if (!success) {
        return const Left(CacheFailure('Failed to update vehicle odometer'));
      }

      developer.log(
        '✅ VehicleRepository.updateVehicleOdometer() - Updated from ${vehicle.odometroAtual} to $newOdometer',
        name: 'VehicleRepository',
      );

      // Sync-on-Write: Se online, sincronizar imediatamente
      final isOnlineResult = await _connectivityService.isOnline();
      final isOnline = isOnlineResult.fold((_) => false, (online) => online);

      if (isOnline) {
        try {
          await _syncAdapter.pushDirtyRecords(_userId);
        } catch (e) {
          developer.log(
            '⚠️ VehicleRepository.updateVehicleOdometer() - Sync error: $e',
            name: 'VehicleRepository',
          );
        }
      }

      return const Right(unit);
    } catch (e) {
      developer.log(
        '❌ VehicleRepository.updateVehicleOdometer() - Error: $e',
        name: 'VehicleRepository',
      );
      return Left(CacheFailure('Failed to update vehicle odometer: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> syncVehicles() async {
    // TODO: Implement sync with remote server when available
    // For now, return success as local data is already synced via Drift
    return const Right(unit);
  }

  @override
  Future<Either<Failure, List<VehicleEntity>>> searchVehicles(
    String query,
  ) async {
    try {
      // Search by brand or model
      final vehicles = await _datasource.getActiveVehicles(_userId);
      final filtered = vehicles.where((v) {
        final lowerQuery = query.toLowerCase();
        return v.marca.toLowerCase().contains(lowerQuery) ||
            v.modelo.toLowerCase().contains(lowerQuery) ||
            v.placa.toLowerCase().contains(lowerQuery);
      }).toList();

      final entities = filtered.map<VehicleEntity>(_fromData).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Failed to search vehicles: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<VehicleEntity>>> watchVehicles() {
    try {
      return _datasource
          .watchVehiclesByUserId(_userId)
          .map((vehicles) {
            final activeVehicles = vehicles
                .where((v) => !v.vendido && !v.isDeleted)
                .toList();
            final entities = activeVehicles
                .map<VehicleEntity>(_fromData)
                .toList();
            return Right<Failure, List<VehicleEntity>>(entities);
          })
          .handleError((Object error, StackTrace stackTrace) {
            return Left<Failure, List<VehicleEntity>>(
              CacheFailure('Stream error: $error'),
            );
          });
    } catch (e) {
      return Stream.value(Left(CacheFailure('Failed to watch vehicles: $e')));
    }
  }

  /// Convert VehicleData (Drift wrapper) to VehicleEntity (Domain)
  VehicleEntity _fromData(drift_repo.VehicleData data) {
    // Convert VehicleData to VehicleModel first, then to Entity
    final model = VehicleModel(
      id: data.id.toString(),
      userId: data.userId,
      marca: data.marca,
      modelo: data.modelo,
      ano: data.ano,
      placa: data.placa,
      cor: data.cor,
      combustivel: data.combustivel,
      odometroInicial: data.odometroInicial,
      renavan: data.renavan,
      chassi: data.chassi,
      odometroAtual: data.odometroAtual,
      vendido: data.vendido,
      valorVenda: data.valorVenda,
      foto: data.foto,
      createdAtMs: data.createdAt.millisecondsSinceEpoch,
      updatedAtMs: data.updatedAt?.millisecondsSinceEpoch,
      lastSyncAtMs: data.lastSyncAt?.millisecondsSinceEpoch,
      isDirty: data.isDirty,
      isDeleted: data.isDeleted,
      version: data.version,
      moduleName: data.moduleName,
    );

    return model.toEntity();
  }

  /// Convert FuelType enum to int index
  int _fuelTypeToIndex(FuelType fuel) {
    // Match the order in FuelType enum
    const fuelMap = {
      FuelType.gasoline: 0,
      FuelType.ethanol: 1,
      FuelType.diesel: 2,
      FuelType.gas: 3,
      FuelType.hybrid: 4,
      FuelType.electric: 5,
    };
    return fuelMap[fuel] ?? 0;
  }
}
