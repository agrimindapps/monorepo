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
import '../../domain/entities/fuel_record_entity.dart';
import '../../domain/repositories/fuel_repository.dart';
import '../datasources/fuel_local_data_source.dart';
import '../datasources/fuel_remote_data_source.dart';

@LazySingleton(as: FuelRepository)
class FuelRepositoryImpl implements FuelRepository {
  final FuelLocalDataSource localDataSource;
  final FuelRemoteDataSource remoteDataSource;
  final Connectivity connectivity;
  final AuthRepository authRepository;
  final LoggingService loggingService;

  FuelRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivity,
    required this.authRepository,
    required this.loggingService,
  });

  Future<bool> _isConnected() async {
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
  Future<Either<Failure, List<FuelRecordEntity>>> getAllFuelRecords() async {
    try {
      // OFFLINE FIRST: Sempre retorna dados locais primeiro
      final localRecords = await localDataSource.getAllFuelRecords();
      
      // Sync em background se conectado (não bloqueia o retorno)
      unawaited(_syncAllFuelRecordsInBackground());
      
      return Right(localRecords);
      
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  /// Sync em background sem bloquear a UI
  Future<void> _syncAllFuelRecordsInBackground() async {
    try {
      final isConnected = await _isConnected();
      if (!isConnected) return;

      final userId = await _getCurrentUserId();
      if (userId == null) return;

      // Sync remoto sem aguardar
      unawaited(remoteDataSource.getAllFuelRecords(userId).then((remoteRecords) async {
        // Atualizar cache local
        for (final record in remoteRecords) {
          await localDataSource.addFuelRecord(record);
        }
      }).catchError((Object error) {
        // Sync falhou, mas não afeta a funcionalidade local
        debugPrint('Background fuel sync failed: $error');
      }));
    } catch (e) {
      // Ignorar erros de sync em background
      debugPrint('Background fuel sync error: $e');
    }
  }

  @override
  Future<Either<Failure, List<FuelRecordEntity>>> getFuelRecordsByVehicle(String vehicleId) async {
    try {
      // OFFLINE FIRST: Sempre retorna dados locais primeiro
      final localRecords = await localDataSource.getFuelRecordsByVehicle(vehicleId);
      
      // Sync em background se conectado
      unawaited(_syncFuelRecordsByVehicleInBackground(vehicleId));
      
      return Right(localRecords);
      
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  /// Sync de registros por veículo em background
  Future<void> _syncFuelRecordsByVehicleInBackground(String vehicleId) async {
    try {
      final isConnected = await _isConnected();
      if (!isConnected) return;

      final userId = await _getCurrentUserId();
      if (userId == null) return;

      unawaited(remoteDataSource.getFuelRecordsByVehicle(userId, vehicleId).then((remoteRecords) async {
        for (final record in remoteRecords) {
          await localDataSource.addFuelRecord(record);
        }
      }).catchError((Object error) {
        debugPrint('Background fuel vehicle sync failed: $error');
      }));
    } catch (e) {
      debugPrint('Background fuel vehicle sync error: $e');
    }
  }

  @override
  Future<Either<Failure, FuelRecordEntity?>> getFuelRecordById(String id) async {
    try {
      final userId = await _getCurrentUserId();
      
      if (await _isConnected() && userId != null) {
        try {
          final remoteRecord = await remoteDataSource.getFuelRecordById(userId, id);
          
          if (remoteRecord != null) {
            // Cache record locally
            await localDataSource.addFuelRecord(remoteRecord);
          }
          
          return Right(remoteRecord);
        } catch (e) {
          final localRecord = await localDataSource.getFuelRecordById(id);
          return Right(localRecord);
        }
      } else {
        final localRecord = await localDataSource.getFuelRecordById(id);
        return Right(localRecord);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, FuelRecordEntity>> addFuelRecord(FuelRecordEntity fuelRecord) async {
    await loggingService.logOperationStart(
      category: LogCategory.fuel,
      operation: LogOperation.create,
      message: 'Starting fuel record creation for vehicle ${fuelRecord.vehicleId}',
      metadata: {
        'vehicle_id': fuelRecord.vehicleId,
        'fuel_type': fuelRecord.fuelType.toString(),
        'liters': fuelRecord.liters.toString(),
        'cost': fuelRecord.totalPrice.toString(),
        'odometer_reading': fuelRecord.odometer.toString(),
        'is_full_tank': fuelRecord.fullTank.toString(),
      },
    );

    try {
      final userId = await _getCurrentUserId();
      
      await loggingService.logInfo(
        category: LogCategory.fuel,
        message: 'Saving fuel record to local storage',
        metadata: {
          'fuel_id': fuelRecord.id,
          'vehicle_id': fuelRecord.vehicleId,
        },
      );

      // Always save locally first
      final localRecord = await localDataSource.addFuelRecord(fuelRecord);

      await loggingService.logInfo(
        category: LogCategory.fuel,
        message: 'Fuel record saved to local storage successfully',
        metadata: {
          'fuel_id': fuelRecord.id,
          'vehicle_id': fuelRecord.vehicleId,
        },
      );
      
      if (await _isConnected() && userId != null) {
        await loggingService.logInfo(
          category: LogCategory.fuel,
          message: 'Connection available, attempting remote sync',
          metadata: {
            'fuel_id': fuelRecord.id,
            'vehicle_id': fuelRecord.vehicleId,
            'user_id': userId,
          },
        );

        try {
          // Then sync to remote
          final remoteRecord = await remoteDataSource.addFuelRecord(userId, fuelRecord);
          
          await loggingService.logOperationSuccess(
            category: LogCategory.fuel,
            operation: LogOperation.create,
            message: 'Fuel record created and synced successfully',
            metadata: {
              'fuel_id': fuelRecord.id,
              'vehicle_id': fuelRecord.vehicleId,
              'user_id': userId,
              'synced': true,
            },
          );

          return Right(remoteRecord);
        } catch (e) {
          // If remote fails, still return local success
          await loggingService.logOperationWarning(
            category: LogCategory.fuel,
            operation: LogOperation.sync,
            message: 'Failed to sync fuel record to remote, saved locally',
            metadata: {
              'fuel_id': fuelRecord.id,
              'vehicle_id': fuelRecord.vehicleId,
              'user_id': userId,
              'error': e.toString(),
            },
          );

          await loggingService.logOperationSuccess(
            category: LogCategory.fuel,
            operation: LogOperation.create,
            message: 'Fuel record created locally (remote sync failed)',
            metadata: {
              'fuel_id': fuelRecord.id,
              'vehicle_id': fuelRecord.vehicleId,
              'synced': false,
            },
          );

          return Right(localRecord);
        }
      } else {
        await loggingService.logOperationSuccess(
          category: LogCategory.fuel,
          operation: LogOperation.create,
          message: 'Fuel record created offline',
          metadata: {
            'fuel_id': fuelRecord.id,
            'vehicle_id': fuelRecord.vehicleId,
            'offline': true,
            'reason': userId == null ? 'no_user' : 'no_connection',
          },
        );

        return Right(localRecord);
      }
    } on ServerException catch (e) {
      await loggingService.logOperationError(
        category: LogCategory.fuel,
        operation: LogOperation.create,
        message: 'Server error during fuel record creation',
        error: e,
        metadata: {
          'fuel_id': fuelRecord.id,
          'vehicle_id': fuelRecord.vehicleId,
        },
      );
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      await loggingService.logOperationError(
        category: LogCategory.fuel,
        operation: LogOperation.create,
        message: 'Cache error during fuel record creation',
        error: e,
        metadata: {
          'fuel_id': fuelRecord.id,
          'vehicle_id': fuelRecord.vehicleId,
        },
      );
      return Left(CacheFailure(e.message));
    } catch (e) {
      await loggingService.logOperationError(
        category: LogCategory.fuel,
        operation: LogOperation.create,
        message: 'Unexpected error during fuel record creation',
        error: e,
        metadata: {
          'fuel_id': fuelRecord.id,
          'vehicle_id': fuelRecord.vehicleId,
        },
      );
      return Left(UnexpectedFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, FuelRecordEntity>> updateFuelRecord(FuelRecordEntity fuelRecord) async {
    try {
      final userId = await _getCurrentUserId();
      
      // Always update locally first
      final localRecord = await localDataSource.updateFuelRecord(fuelRecord);
      
      if (await _isConnected() && userId != null) {
        try {
          // Then sync to remote
          final remoteRecord = await remoteDataSource.updateFuelRecord(userId, fuelRecord);
          return Right(remoteRecord);
        } catch (e) {
          // If remote fails, still return local success
          return Right(localRecord);
        }
      } else {
        return Right(localRecord);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteFuelRecord(String id) async {
    try {
      final userId = await _getCurrentUserId();
      
      // Always delete locally first
      await localDataSource.deleteFuelRecord(id);
      
      if (await _isConnected() && userId != null) {
        try {
          // Then delete from remote
          await remoteDataSource.deleteFuelRecord(userId, id);
        } catch (e) {
          // If remote fails, still return success since local deletion worked
        }
      }
      
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<FuelRecordEntity>>> searchFuelRecords(String query) async {
    try {
      final userId = await _getCurrentUserId();
      
      if (await _isConnected() && userId != null) {
        try {
          final remoteResults = await remoteDataSource.searchFuelRecords(userId, query);
          return Right(remoteResults);
        } catch (e) {
          final localResults = await localDataSource.searchFuelRecords(query);
          return Right(localResults);
        }
      } else {
        final localResults = await localDataSource.searchFuelRecords(query);
        return Right(localResults);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Stream<Either<Failure, List<FuelRecordEntity>>> watchFuelRecords() async* {
    try {
      final userId = await _getCurrentUserId();
      
      if (await _isConnected() && userId != null) {
        yield* remoteDataSource.watchFuelRecords(userId)
            .map<Either<Failure, List<FuelRecordEntity>>>((records) => Right(records))
            .handleError((error) {
          // If remote stream fails, fallback to local
          return localDataSource.watchFuelRecords()
              .map<Either<Failure, List<FuelRecordEntity>>>((records) => Right(records));
        });
      } else {
        yield* localDataSource.watchFuelRecords()
            .map<Either<Failure, List<FuelRecordEntity>>>((records) => Right(records));
      }
    } catch (e) {
      yield Left(UnexpectedFailure('Erro ao observar registros: ${e.toString()}'));
    }
  }

  @override
  Stream<Either<Failure, List<FuelRecordEntity>>> watchFuelRecordsByVehicle(String vehicleId) async* {
    try {
      final userId = await _getCurrentUserId();
      
      if (await _isConnected() && userId != null) {
        yield* remoteDataSource.watchFuelRecordsByVehicle(userId, vehicleId)
            .map<Either<Failure, List<FuelRecordEntity>>>((records) => Right(records))
            .handleError((error) {
          return localDataSource.watchFuelRecordsByVehicle(vehicleId)
              .map<Either<Failure, List<FuelRecordEntity>>>((records) => Right(records));
        });
      } else {
        yield* localDataSource.watchFuelRecordsByVehicle(vehicleId)
            .map<Either<Failure, List<FuelRecordEntity>>>((records) => Right(records));
      }
    } catch (e) {
      yield Left(UnexpectedFailure('Erro ao observar registros por veículo: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, double>> getAverageConsumption(String vehicleId) async {
    try {
      final recordsResult = await getFuelRecordsByVehicle(vehicleId);
      
      return recordsResult.fold(
        (failure) => Left(failure),
        (records) {
          if (records.length < 2) {
            return const Right(0.0);
          }
          
          final recordsWithConsumption = records.where((record) => 
              record.consumption != null && record.consumption! > 0).toList();
          
          if (recordsWithConsumption.isEmpty) {
            return const Right(0.0);
          }
          
          final totalConsumption = recordsWithConsumption
              .map((r) => r.consumption!)
              .reduce((a, b) => a + b);
          
          final average = totalConsumption / recordsWithConsumption.length;
          return Right(average);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Erro ao calcular consumo médio: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalSpent(String vehicleId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      final recordsResult = await getFuelRecordsByVehicle(vehicleId);
      
      return recordsResult.fold(
        (failure) => Left(failure),
        (records) {
          var filteredRecords = records;
          
          if (startDate != null) {
            filteredRecords = filteredRecords.where((r) => 
                r.date.isAfter(startDate) || r.date.isAtSameMomentAs(startDate)).toList();
          }
          
          if (endDate != null) {
            filteredRecords = filteredRecords.where((r) => 
                r.date.isBefore(endDate) || r.date.isAtSameMomentAs(endDate)).toList();
          }
          
          final totalSpent = filteredRecords
              .map((r) => r.totalPrice)
              .fold(0.0, (a, b) => a + b);
          
          return Right(totalSpent);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Erro ao calcular total gasto: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<FuelRecordEntity>>> getRecentFuelRecords(String vehicleId, {int limit = 10}) async {
    try {
      final recordsResult = await getFuelRecordsByVehicle(vehicleId);
      
      return recordsResult.fold(
        (failure) => Left(failure),
        (records) {
          final sortedRecords = records..sort((a, b) => b.date.compareTo(a.date));
          final recentRecords = sortedRecords.take(limit).toList();
          return Right(recentRecords);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Erro ao buscar registros recentes: ${e.toString()}'));
    }
  }
}