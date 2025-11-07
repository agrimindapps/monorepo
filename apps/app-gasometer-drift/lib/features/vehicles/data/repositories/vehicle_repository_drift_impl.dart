import 'dart:async';

import 'package:core/core.dart';
import 'package:drift/drift.dart' as drift;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

import '../../../../database/gasometer_database.dart';
import '../../../../database/repositories/vehicle_repository.dart'
    as drift_repo;
import '../../domain/entities/vehicle_entity.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../datasources/vehicle_local_datasource.dart';
import '../models/vehicle_model.dart';

/// VehicleRepository implementation using Drift
///
/// This implementation bridges the domain layer (Clean Architecture)
/// with the Drift data layer, converting between VehicleEntity and VehicleData.
@LazySingleton(as: VehicleRepository)
class VehicleRepositoryDriftImpl implements VehicleRepository {
  final VehicleLocalDataSource _datasource;

  VehicleRepositoryDriftImpl(this._datasource);

  /// Get current authenticated user ID
  String get _userId {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw UnknownFailure('No authenticated user');
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

      // Fetch the created vehicle
      final created = await _datasource.findById(id);
      if (created == null) {
        return const Left(CacheFailure('Failed to fetch created vehicle'));
      }

      return Right(_fromData(created));
    } catch (e) {
      return Left(CacheFailure('Failed to add vehicle: $e'));
    }
  }

  @override
  Future<Either<Failure, VehicleEntity>> updateVehicle(
    VehicleEntity vehicle,
  ) async {
    try {
      final vehicleId = int.tryParse(vehicle.id);
      if (vehicleId == null) {
        return const Left(ValidationFailure('Invalid vehicle ID'));
      }

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

      return Right(vehicle);
    } catch (e) {
      return Left(CacheFailure('Failed to update vehicle: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteVehicle(String id) async {
    try {
      final vehicleId = int.tryParse(id);
      if (vehicleId == null) {
        return const Left(ValidationFailure('Invalid vehicle ID'));
      }

      final success = await _datasource.deleteVehicle(vehicleId);
      if (!success) {
        return const Left(CacheFailure('Failed to delete vehicle'));
      }

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to delete vehicle: $e'));
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
