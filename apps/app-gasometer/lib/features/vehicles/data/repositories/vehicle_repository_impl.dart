import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../datasources/vehicle_local_data_source.dart';
import '../datasources/vehicle_remote_data_source.dart';
import '../models/vehicle_model.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

@LazySingleton(as: VehicleRepository)
class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleLocalDataSource localDataSource;
  final VehicleRemoteDataSource remoteDataSource;
  final Connectivity connectivity;
  final AuthRepository authRepository;

  VehicleRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivity,
    required this.authRepository,
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
      final isConnected = await _isConnected;
      
      if (isConnected) {
        // Try to get from remote first
        final userId = await _getCurrentUserId();
        if (userId != null) {
          try {
            final remoteVehicles = await remoteDataSource.getAllVehicles(userId);
            
            // Sync to local storage
            await localDataSource.clearAllVehicles();
            for (final vehicle in remoteVehicles) {
              await localDataSource.saveVehicle(vehicle);
            }
            
            return Right(remoteVehicles.map((model) => model.toEntity()).toList());
          } catch (e) {
            // Fallback to local if remote fails
            final localVehicles = await localDataSource.getAllVehicles();
            return Right(localVehicles.map((model) => model.toEntity()).toList());
          }
        }
      }
      
      // Get from local storage
      final localVehicles = await localDataSource.getAllVehicles();
      return Right(localVehicles.map((model) => model.toEntity()).toList());
      
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, VehicleEntity>> getVehicleById(String id) async {
    try {
      final isConnected = await _isConnected;
      
      if (isConnected) {
        final userId = await _getCurrentUserId();
        if (userId != null) {
          try {
            final remoteVehicle = await remoteDataSource.getVehicleById(userId, id);
            if (remoteVehicle != null) {
              // Update local cache
              await localDataSource.saveVehicle(remoteVehicle);
              return Right(remoteVehicle.toEntity());
            }
          } catch (e) {
            // Continue to local fallback
          }
        }
      }
      
      // Get from local storage
      final localVehicle = await localDataSource.getVehicleById(id);
      if (localVehicle != null) {
        return Right(localVehicle.toEntity());
      }
      
      return const Left(VehicleNotFoundFailure('Vehicle not found'));
      
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, VehicleEntity>> addVehicle(VehicleEntity vehicle) async {
    try {
      final vehicleModel = VehicleModel.fromEntity(vehicle);
      
      // Always save to local first
      await localDataSource.saveVehicle(vehicleModel);
      
      final isConnected = await _isConnected;
      if (isConnected) {
        final userId = await _getCurrentUserId();
        if (userId != null) {
          try {
            await remoteDataSource.saveVehicle(userId, vehicleModel);
          } catch (e) {
            // Vehicle saved locally but failed to sync - that's ok
            // TODO: Add to sync queue for later
          }
        }
      }
      
      return Right(vehicleModel.toEntity());
      
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, VehicleEntity>> updateVehicle(VehicleEntity vehicle) async {
    try {
      final vehicleModel = VehicleModel.fromEntity(vehicle);
      
      // Always update local first
      await localDataSource.updateVehicle(vehicleModel);
      
      final isConnected = await _isConnected;
      if (isConnected) {
        final userId = await _getCurrentUserId();
        if (userId != null) {
          try {
            await remoteDataSource.updateVehicle(userId, vehicleModel);
          } catch (e) {
            // Vehicle updated locally but failed to sync - that's ok
            // TODO: Add to sync queue for later
          }
        }
      }
      
      return Right(vehicleModel.toEntity());
      
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on VehicleNotFoundException catch (e) {
      return Left(VehicleNotFoundFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteVehicle(String id) async {
    try {
      // Always delete from local first
      await localDataSource.deleteVehicle(id);
      
      final isConnected = await _isConnected;
      if (isConnected) {
        final userId = await _getCurrentUserId();
        if (userId != null) {
          try {
            await remoteDataSource.deleteVehicle(userId, id);
          } catch (e) {
            // Vehicle deleted locally but failed to sync - that's ok
            // TODO: Add to sync queue for later
          }
        }
      }
      
      return const Right(unit);
      
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on VehicleNotFoundException catch (e) {
      return Left(VehicleNotFoundFailure(e.message));
    } catch (e) {
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