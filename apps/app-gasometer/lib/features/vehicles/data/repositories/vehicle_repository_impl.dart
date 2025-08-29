import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/logging/entities/log_entry.dart';
import '../../../../core/logging/services/logging_service.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../datasources/vehicle_local_data_source.dart';
import '../datasources/vehicle_remote_data_source.dart';
import '../models/vehicle_model.dart';

@LazySingleton(as: VehicleRepository)
class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleLocalDataSource localDataSource;
  final VehicleRemoteDataSource remoteDataSource;
  final Connectivity connectivity;
  final AuthRepository authRepository;
  final LoggingService loggingService;

  VehicleRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivity,
    required this.authRepository,
    required this.loggingService,
  });

  Future<bool> get _isConnected async {
    final connectivityResults = await connectivity.checkConnectivity();
    return !connectivityResults.contains(ConnectivityResult.none);
  }

  Future<String?> _getCurrentUserId() async {
    final userResult = await authRepository.getCurrentUser();
    return userResult.fold(
      (failure) => null,
      (user) => user?.id,
    );
  }

  @override
  Future<Either<Failure, List<VehicleEntity>>> getAllVehicles() async {
    try {
      // OFFLINE FIRST: Sempre retorna dados locais primeiro
      final localVehicles = await localDataSource.getAllVehicles();
      final localEntities = localVehicles.map((model) => model.toEntity()).toList();
      
      // Sync em background se conectado (não bloqueia o retorno)
      unawaited(_syncInBackground());
      
      return Right(localEntities);
      
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// Sync em background sem bloquear a UI
  Future<void> _syncInBackground() async {
    try {
      final isConnected = await _isConnected;
      if (!isConnected) return;

      final userId = await _getCurrentUserId();
      if (userId == null) return;

      // Sync remoto sem aguardar
      unawaited(remoteDataSource.getAllVehicles(userId).then((remoteVehicles) async {
        // Atualizar cache local
        await localDataSource.clearAllVehicles();
        for (final vehicle in remoteVehicles) {
          await localDataSource.saveVehicle(vehicle);
        }
      }).catchError((Object error) {
        // Sync falhou, mas não afeta a funcionalidade local
        if (kDebugMode) {
          print('Background sync failed: $error');
        }
      }));
    } catch (e) {
      // Ignorar erros de sync em background
      if (kDebugMode) {
        print('Background sync error: $e');
      }
    }
  }

  @override
  Future<Either<Failure, VehicleEntity>> getVehicleById(String id) async {
    try {
      // OFFLINE FIRST: Buscar local primeiro
      final localVehicle = await localDataSource.getVehicleById(id);
      if (localVehicle != null) {
        // Sync em background se necessário
        unawaited(_syncVehicleInBackground(id));
        return Right(localVehicle.toEntity());
      }
      
      return const Left(VehicleNotFoundFailure('Vehicle not found'));
      
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// Sync de veículo específico em background
  Future<void> _syncVehicleInBackground(String vehicleId) async {
    try {
      final isConnected = await _isConnected;
      if (!isConnected) return;

      final userId = await _getCurrentUserId();
      if (userId == null) return;

      unawaited(remoteDataSource.getVehicleById(userId, vehicleId).then((remoteVehicle) async {
        if (remoteVehicle != null) {
          await localDataSource.saveVehicle(remoteVehicle);
        }
      }).catchError((Object error) {
        if (kDebugMode) {
          print('Background vehicle sync failed: $error');
        }
      }));
    } catch (e) {
      if (kDebugMode) {
        print('Background vehicle sync error: $e');
      }
    }
  }

  @override
  Future<Either<Failure, VehicleEntity>> addVehicle(VehicleEntity vehicle) async {
    await loggingService.logOperationStart(
      category: LogCategory.vehicles,
      operation: LogOperation.create,
      message: 'Starting vehicle creation: ${vehicle.name} (${vehicle.brand} ${vehicle.model})',
      metadata: {
        'vehicle_name': vehicle.name,
        'vehicle_brand': vehicle.brand,
        'vehicle_model': vehicle.model,
        'vehicle_year': vehicle.year.toString(),
      },
    );

    try {
      // Validation log
      await loggingService.logInfo(
        category: LogCategory.vehicles,
        message: 'Validating vehicle data',
        metadata: {'vehicle_id': vehicle.id},
      );

      final vehicleModel = VehicleModel.fromEntity(vehicle);
      
      // Local storage log
      await loggingService.logInfo(
        category: LogCategory.vehicles,
        message: 'Saving vehicle to local storage',
        metadata: {'vehicle_id': vehicle.id},
      );

      // Always save to local first
      await localDataSource.saveVehicle(vehicleModel);

      await loggingService.logInfo(
        category: LogCategory.vehicles,
        message: 'Vehicle saved to local storage successfully',
        metadata: {'vehicle_id': vehicle.id},
      );
      
      // Remote sync attempt
      final isConnected = await _isConnected;
      if (isConnected) {
        await loggingService.logInfo(
          category: LogCategory.vehicles,
          message: 'Connection available, attempting remote sync',
          metadata: {'vehicle_id': vehicle.id},
        );

        final userId = await _getCurrentUserId();
        if (userId != null) {
          try {
            await remoteDataSource.saveVehicle(userId, vehicleModel);
            
            await loggingService.logInfo(
              category: LogCategory.vehicles,
              message: 'Vehicle synced to remote storage successfully',
              metadata: {
                'vehicle_id': vehicle.id,
                'user_id': userId,
              },
            );
          } catch (e) {
            // Vehicle saved locally but failed to sync - that's ok
            await loggingService.logOperationWarning(
              category: LogCategory.vehicles,
              operation: LogOperation.sync,
              message: 'Failed to sync vehicle to remote storage',
              metadata: {
                'vehicle_id': vehicle.id,
                'user_id': userId,
                'error': e.toString(),
              },
            );
          }
        } else {
          await loggingService.logOperationWarning(
            category: LogCategory.vehicles,
            operation: LogOperation.sync,
            message: 'No authenticated user, skipping remote sync',
            metadata: {'vehicle_id': vehicle.id},
          );
        }
      } else {
        await loggingService.logInfo(
          category: LogCategory.vehicles,
          message: 'No connection available, vehicle saved offline',
          metadata: {'vehicle_id': vehicle.id},
        );
      }
      
      await loggingService.logOperationSuccess(
        category: LogCategory.vehicles,
        operation: LogOperation.create,
        message: 'Vehicle creation completed successfully',
        metadata: {
          'vehicle_id': vehicle.id,
          'vehicle_name': vehicle.name,
          'synced': isConnected && await _getCurrentUserId() != null,
        },
      );

      return Right(vehicleModel.toEntity());
      
    } on CacheException catch (e) {
      await loggingService.logOperationError(
        category: LogCategory.vehicles,
        operation: LogOperation.create,
        message: 'Cache error during vehicle creation',
        error: e,
        metadata: {'vehicle_id': vehicle.id},
      );
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      await loggingService.logOperationError(
        category: LogCategory.vehicles,
        operation: LogOperation.create,
        message: 'Server error during vehicle creation',
        error: e,
        metadata: {'vehicle_id': vehicle.id},
      );
      return Left(ServerFailure(e.message));
    } on ValidationException catch (e) {
      await loggingService.logOperationError(
        category: LogCategory.vehicles,
        operation: LogOperation.create,
        message: 'Validation error during vehicle creation',
        error: e,
        metadata: {'vehicle_id': vehicle.id},
      );
      return Left(ValidationFailure(e.message));
    } catch (e) {
      await loggingService.logOperationError(
        category: LogCategory.vehicles,
        operation: LogOperation.create,
        message: 'Unexpected error during vehicle creation',
        error: e,
        metadata: {'vehicle_id': vehicle.id},
      );
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, VehicleEntity>> updateVehicle(VehicleEntity vehicle) async {
    await loggingService.logOperationStart(
      category: LogCategory.vehicles,
      operation: LogOperation.update,
      message: 'Starting vehicle update: ${vehicle.name} (ID: ${vehicle.id})',
      metadata: {
        'vehicle_id': vehicle.id,
        'vehicle_name': vehicle.name,
      },
    );

    try {
      final vehicleModel = VehicleModel.fromEntity(vehicle);
      
      await loggingService.logInfo(
        category: LogCategory.vehicles,
        message: 'Updating vehicle in local storage',
        metadata: {'vehicle_id': vehicle.id},
      );

      // Always update local first
      await localDataSource.updateVehicle(vehicleModel);

      await loggingService.logInfo(
        category: LogCategory.vehicles,
        message: 'Vehicle updated in local storage successfully',
        metadata: {'vehicle_id': vehicle.id},
      );
      
      final isConnected = await _isConnected;
      if (isConnected) {
        final userId = await _getCurrentUserId();
        if (userId != null) {
          try {
            await remoteDataSource.updateVehicle(userId, vehicleModel);
            
            await loggingService.logInfo(
              category: LogCategory.vehicles,
              message: 'Vehicle update synced to remote storage',
              metadata: {
                'vehicle_id': vehicle.id,
                'user_id': userId,
              },
            );
          } catch (e) {
            await loggingService.logOperationWarning(
              category: LogCategory.vehicles,
              operation: LogOperation.sync,
              message: 'Failed to sync vehicle update to remote',
              metadata: {
                'vehicle_id': vehicle.id,
                'user_id': userId,
                'error': e.toString(),
              },
            );
          }
        }
      }
      
      await loggingService.logOperationSuccess(
        category: LogCategory.vehicles,
        operation: LogOperation.update,
        message: 'Vehicle update completed successfully',
        metadata: {'vehicle_id': vehicle.id},
      );

      return Right(vehicleModel.toEntity());
      
    } on CacheException catch (e) {
      await loggingService.logOperationError(
        category: LogCategory.vehicles,
        operation: LogOperation.update,
        message: 'Cache error during vehicle update',
        error: e,
        metadata: {'vehicle_id': vehicle.id},
      );
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      await loggingService.logOperationError(
        category: LogCategory.vehicles,
        operation: LogOperation.update,
        message: 'Server error during vehicle update',
        error: e,
        metadata: {'vehicle_id': vehicle.id},
      );
      return Left(ServerFailure(e.message));
    } on ValidationException catch (e) {
      await loggingService.logOperationError(
        category: LogCategory.vehicles,
        operation: LogOperation.update,
        message: 'Validation error during vehicle update',
        error: e,
        metadata: {'vehicle_id': vehicle.id},
      );
      return Left(ValidationFailure(e.message));
    } on VehicleNotFoundException catch (e) {
      await loggingService.logOperationError(
        category: LogCategory.vehicles,
        operation: LogOperation.update,
        message: 'Vehicle not found during update',
        error: e,
        metadata: {'vehicle_id': vehicle.id},
      );
      return Left(VehicleNotFoundFailure(e.message));
    } catch (e) {
      await loggingService.logOperationError(
        category: LogCategory.vehicles,
        operation: LogOperation.update,
        message: 'Unexpected error during vehicle update',
        error: e,
        metadata: {'vehicle_id': vehicle.id},
      );
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteVehicle(String id) async {
    await loggingService.logOperationStart(
      category: LogCategory.vehicles,
      operation: LogOperation.delete,
      message: 'Starting vehicle deletion (ID: $id)',
      metadata: {'vehicle_id': id},
    );

    try {
      await loggingService.logInfo(
        category: LogCategory.vehicles,
        message: 'Deleting vehicle from local storage',
        metadata: {'vehicle_id': id},
      );

      // Always delete from local first
      await localDataSource.deleteVehicle(id);

      await loggingService.logInfo(
        category: LogCategory.vehicles,
        message: 'Vehicle deleted from local storage successfully',
        metadata: {'vehicle_id': id},
      );
      
      final isConnected = await _isConnected;
      if (isConnected) {
        final userId = await _getCurrentUserId();
        if (userId != null) {
          try {
            await remoteDataSource.deleteVehicle(userId, id);
            
            await loggingService.logInfo(
              category: LogCategory.vehicles,
              message: 'Vehicle deletion synced to remote storage',
              metadata: {
                'vehicle_id': id,
                'user_id': userId,
              },
            );
          } catch (e) {
            await loggingService.logOperationWarning(
              category: LogCategory.vehicles,
              operation: LogOperation.sync,
              message: 'Failed to sync vehicle deletion to remote',
              metadata: {
                'vehicle_id': id,
                'user_id': userId,
                'error': e.toString(),
              },
            );
          }
        }
      }
      
      await loggingService.logOperationSuccess(
        category: LogCategory.vehicles,
        operation: LogOperation.delete,
        message: 'Vehicle deletion completed successfully',
        metadata: {'vehicle_id': id},
      );

      return const Right(unit);
      
    } on CacheException catch (e) {
      await loggingService.logOperationError(
        category: LogCategory.vehicles,
        operation: LogOperation.delete,
        message: 'Cache error during vehicle deletion',
        error: e,
        metadata: {'vehicle_id': id},
      );
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      await loggingService.logOperationError(
        category: LogCategory.vehicles,
        operation: LogOperation.delete,
        message: 'Server error during vehicle deletion',
        error: e,
        metadata: {'vehicle_id': id},
      );
      return Left(ServerFailure(e.message));
    } on VehicleNotFoundException catch (e) {
      await loggingService.logOperationError(
        category: LogCategory.vehicles,
        operation: LogOperation.delete,
        message: 'Vehicle not found during deletion',
        error: e,
        metadata: {'vehicle_id': id},
      );
      return Left(VehicleNotFoundFailure(e.message));
    } catch (e) {
      await loggingService.logOperationError(
        category: LogCategory.vehicles,
        operation: LogOperation.delete,
        message: 'Unexpected error during vehicle deletion',
        error: e,
        metadata: {'vehicle_id': id},
      );
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> syncVehicles() async {
    try {
      final isConnected = await _isConnected;
      if (!isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }
      
      final userId = await _getCurrentUserId();
      if (userId == null) {
        return const Left(AuthenticationFailure('User not authenticated'));
      }
      
      // Get all local vehicles
      final localVehicles = await localDataSource.getAllVehicles();
      
      // Sync to remote
      await remoteDataSource.syncVehicles(userId, localVehicles);
      
      return const Right(unit);
      
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on SyncException catch (e) {
      return Left(SyncFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<VehicleEntity>>> searchVehicles(String query) async {
    try {
      final vehicles = await getAllVehicles();
      
      return vehicles.fold(
        (failure) => Left(failure),
        (vehiclesList) {
          final filteredVehicles = vehiclesList.where((vehicle) {
            final searchQuery = query.toLowerCase();
            return vehicle.name.toLowerCase().contains(searchQuery) ||
                   vehicle.brand.toLowerCase().contains(searchQuery) ||
                   vehicle.model.toLowerCase().contains(searchQuery) ||
                   vehicle.year.toString().contains(searchQuery);
          }).toList();
          
          return Right(filteredVehicles);
        },
      );
      
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}