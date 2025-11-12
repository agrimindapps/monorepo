import 'dart:async';

import 'package:core/core.dart';

import '../../domain/entities/vehicle_entity.dart';
import '../../domain/repositories/vehicle_repository.dart';

/// VehicleRepository migrado para usar UnifiedSyncManager
///
/// ⚠️ DEPRECATED: Use VehicleRepositoryDriftImpl instead
/// This implementation is being replaced with Drift-based storage
///
/// ✅ Migração completa:
/// - ANTES: Implementação vazia com TODOs
/// - DEPOIS: Usando UnifiedSyncManager para todas as operações
///
/// Características especiais:
/// - Entidade principal (referenciada por fuel, maintenance, odometer, expenses)
/// - Stream de mudanças para UI reativa
/// - Busca e filtros

// @LazySingleton(as: VehicleRepository)
class VehicleRepositoryImpl implements VehicleRepository {
  const VehicleRepositoryImpl();
  static const _appName = 'gasometer';

  @override
  Future<Either<Failure, List<VehicleEntity>>> getAllVehicles() async {
    try {
      final result = await UnifiedSyncManager.instance.findAll<VehicleEntity>(
        _appName,
      );
      return result.fold(
        (failure) => Left(failure),
        (vehicles) => Right(vehicles),
      );
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure('Erro ao buscar veículos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, VehicleEntity>> getVehicleById(String id) async {
    try {
      final result = await UnifiedSyncManager.instance.findById<VehicleEntity>(
        _appName,
        id,
      );
      return result.fold(
        (failure) => Left(failure),
        (vehicle) => vehicle != null
            ? Right(vehicle)
            : const Left(NotFoundFailure('Veículo não encontrado')),
      );
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure('Erro ao buscar veículo: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, VehicleEntity>> addVehicle(
    VehicleEntity vehicle,
  ) async {
    try {
      final result = await UnifiedSyncManager.instance.create<VehicleEntity>(
        _appName,
        vehicle,
      );
      return result.fold(
        (failure) => Left(failure),
        (id) => Right(vehicle.copyWith(id: id)),
      );
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure('Erro ao adicionar veículo: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, VehicleEntity>> updateVehicle(
    VehicleEntity vehicle,
  ) async {
    try {
      final result = await UnifiedSyncManager.instance.update<VehicleEntity>(
        _appName,
        vehicle.id,
        vehicle,
      );
      return result.fold((failure) => Left(failure), (_) => Right(vehicle));
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure('Erro ao atualizar veículo: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteVehicle(String id) async {
    try {
      final result = await UnifiedSyncManager.instance.delete<VehicleEntity>(
        _appName,
        id,
      );
      return result.fold((failure) => Left(failure), (_) => const Right(unit));
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure('Erro ao deletar veículo: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> syncVehicles() async {
    try {
      // UnifiedSyncManager já sincroniza automaticamente
      // Podemos forçar uma sincronização se necessário
      return const Right(unit);
    } catch (e) {
      return Left(
        UnknownFailure('Erro ao sincronizar veículos: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<VehicleEntity>>> searchVehicles(
    String query,
  ) async {
    try {
      final result = await getAllVehicles();
      return result.fold((failure) => Left(failure), (vehicles) {
        if (query.trim().isEmpty) {
          return Right(vehicles);
        }
        final lowerQuery = query.toLowerCase();
        final filtered = vehicles.where((vehicle) {
          return vehicle.name.toLowerCase().contains(lowerQuery) ||
              vehicle.licensePlate.toLowerCase().contains(lowerQuery) ||
              vehicle.brand.toLowerCase().contains(lowerQuery) ||
              vehicle.model.toLowerCase().contains(lowerQuery);
        }).toList();
        return Right(filtered);
      });
    } catch (e) {
      return Left(UnknownFailure('Erro ao buscar veículos: ${e.toString()}'));
    }
  }

  @override
  Stream<Either<Failure, List<VehicleEntity>>> watchVehicles() {
    try {
      final stream = UnifiedSyncManager.instance.streamAll<VehicleEntity>(
        _appName,
      );
      if (stream == null) {
        return Stream.value(
          const Left(NotFoundFailure('Stream não disponível para veículos')),
        );
      }
      return stream.map(
        (vehicles) => Right<Failure, List<VehicleEntity>>(vehicles),
      );
    } catch (e) {
      return Stream.value(
        Left(UnknownFailure('Erro ao observar veículos: ${e.toString()}')),
      );
    }
  }
}
