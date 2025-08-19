import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/maintenance_entity.dart';
import '../../domain/repositories/maintenance_repository.dart';
import '../datasources/maintenance_local_data_source.dart';
import '../datasources/maintenance_remote_data_source.dart';

@LazySingleton(as: MaintenanceRepository)
class MaintenanceRepositoryImpl implements MaintenanceRepository {
  final MaintenanceRemoteDataSource remoteDataSource;
  final MaintenanceLocalDataSource localDataSource;
  final Connectivity connectivity;

  MaintenanceRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivity,
  });

  Future<bool> get _isConnected async {
    final result = await connectivity.checkConnectivity();
    return result.contains(ConnectivityResult.wifi) || 
           result.contains(ConnectivityResult.mobile) ||
           result.contains(ConnectivityResult.ethernet);
  }

  @override
  Future<Either<Failure, List<MaintenanceEntity>>> getAllMaintenanceRecords() async {
    try {
      if (await _isConnected) {
        final remoteRecords = await remoteDataSource.getAllMaintenanceRecords();
        // Cache remote data locally
        for (final record in remoteRecords) {
          await localDataSource.addMaintenanceRecord(record);
        }
        return Right(remoteRecords);
      } else {
        final localRecords = await localDataSource.getAllMaintenanceRecords();
        return Right(localRecords);
      }
    } on ServerException catch (e) {
      // Fallback to local data on server error
      try {
        final localRecords = await localDataSource.getAllMaintenanceRecords();
        return Right(localRecords);
      } on CacheException {
        return Left(ServerFailure(e.message));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MaintenanceEntity>>> getMaintenanceRecordsByVehicle(String vehicleId) async {
    try {
      if (await _isConnected) {
        final remoteRecords = await remoteDataSource.getMaintenanceRecordsByVehicle(vehicleId);
        return Right(remoteRecords);
      } else {
        final localRecords = await localDataSource.getMaintenanceRecordsByVehicle(vehicleId);
        return Right(localRecords);
      }
    } on ServerException catch (e) {
      try {
        final localRecords = await localDataSource.getMaintenanceRecordsByVehicle(vehicleId);
        return Right(localRecords);
      } on CacheException {
        return Left(ServerFailure(e.message));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MaintenanceEntity?>> getMaintenanceRecordById(String id) async {
    try {
      if (await _isConnected) {
        final remoteRecord = await remoteDataSource.getMaintenanceRecordById(id);
        if (remoteRecord != null) {
          await localDataSource.addMaintenanceRecord(remoteRecord);
        }
        return Right(remoteRecord);
      } else {
        final localRecord = await localDataSource.getMaintenanceRecordById(id);
        return Right(localRecord);
      }
    } on ServerException catch (e) {
      try {
        final localRecord = await localDataSource.getMaintenanceRecordById(id);
        return Right(localRecord);
      } on CacheException {
        return Left(ServerFailure(e.message));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MaintenanceEntity>> addMaintenanceRecord(MaintenanceEntity maintenance) async {
    try {
      // Always save locally first
      final localRecord = await localDataSource.addMaintenanceRecord(maintenance);
      
      if (await _isConnected) {
        try {
          await remoteDataSource.addMaintenanceRecord(maintenance);
        } catch (e) {
          // Continue with local save if remote fails
        }
      }
      
      return Right(localRecord);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MaintenanceEntity>> updateMaintenanceRecord(MaintenanceEntity maintenance) async {
    try {
      // Always update locally first
      final localRecord = await localDataSource.updateMaintenanceRecord(maintenance);
      
      if (await _isConnected) {
        try {
          await remoteDataSource.updateMaintenanceRecord(maintenance);
        } catch (e) {
          // Continue with local update if remote fails
        }
      }
      
      return Right(localRecord);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteMaintenanceRecord(String id) async {
    try {
      // Delete locally first
      await localDataSource.deleteMaintenanceRecord(id);
      
      if (await _isConnected) {
        try {
          await remoteDataSource.deleteMaintenanceRecord(id);
        } catch (e) {
          // Continue with local deletion if remote fails
        }
      }
      
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MaintenanceEntity>>> searchMaintenanceRecords(String query) async {
    try {
      if (await _isConnected) {
        final remoteRecords = await remoteDataSource.searchMaintenanceRecords(query);
        return Right(remoteRecords);
      } else {
        final localRecords = await localDataSource.searchMaintenanceRecords(query);
        return Right(localRecords);
      }
    } on ServerException catch (e) {
      try {
        final localRecords = await localDataSource.searchMaintenanceRecords(query);
        return Right(localRecords);
      } on CacheException {
        return Left(ServerFailure(e.message));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<MaintenanceEntity>>> watchMaintenanceRecords() {
    try {
      return remoteDataSource.watchMaintenanceRecords()
          .map((records) => Right<Failure, List<MaintenanceEntity>>(records))
          .handleError((error) => Left<Failure, List<MaintenanceEntity>>(
                ServerFailure(error.toString()),
              ));
    } catch (e) {
      return Stream.value(Left(UnexpectedFailure(e.toString())));
    }
  }

  @override
  Stream<Either<Failure, List<MaintenanceEntity>>> watchMaintenanceRecordsByVehicle(String vehicleId) {
    try {
      return remoteDataSource.watchMaintenanceRecordsByVehicle(vehicleId)
          .map((records) => Right<Failure, List<MaintenanceEntity>>(records))
          .handleError((error) => Left<Failure, List<MaintenanceEntity>>(
                ServerFailure(error.toString()),
              ));
    } catch (e) {
      return Stream.value(Left(UnexpectedFailure(e.toString())));
    }
  }

  @override
  Future<Either<Failure, List<MaintenanceEntity>>> getMaintenanceRecordsByType(String vehicleId, MaintenanceType type) async {
    try {
      final records = await getMaintenanceRecordsByVehicle(vehicleId);
      return records.fold(
        (failure) => Left(failure),
        (recordsList) {
          final filteredRecords = recordsList.where((record) => record.type == type).toList();
          return Right(filteredRecords);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MaintenanceEntity>>> getMaintenanceRecordsByStatus(String vehicleId, MaintenanceStatus status) async {
    try {
      final records = await getMaintenanceRecordsByVehicle(vehicleId);
      return records.fold(
        (failure) => Left(failure),
        (recordsList) {
          final filteredRecords = recordsList.where((record) => record.status == status).toList();
          return Right(filteredRecords);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MaintenanceEntity>>> getMaintenanceRecordsByDateRange(String vehicleId, DateTime startDate, DateTime endDate) async {
    try {
      final records = await getMaintenanceRecordsByVehicle(vehicleId);
      return records.fold(
        (failure) => Left(failure),
        (recordsList) {
          final filteredRecords = recordsList.where((record) {
            return record.serviceDate.isAfter(startDate) && record.serviceDate.isBefore(endDate);
          }).toList();
          return Right(filteredRecords);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MaintenanceEntity>>> getUpcomingMaintenanceRecords(String vehicleId, {int days = 30}) async {
    try {
      final records = await getMaintenanceRecordsByVehicle(vehicleId);
      return records.fold(
        (failure) => Left(failure),
        (recordsList) {
          final cutoffDate = DateTime.now().add(Duration(days: days));
          final upcomingRecords = recordsList.where((record) {
            if (record.nextServiceDate == null) return false;
            return record.nextServiceDate!.isBefore(cutoffDate) && record.nextServiceDate!.isAfter(DateTime.now());
          }).toList();
          
          // Sort by next service date
          upcomingRecords.sort((a, b) => a.nextServiceDate!.compareTo(b.nextServiceDate!));
          
          return Right(upcomingRecords);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MaintenanceEntity>>> getOverdueMaintenanceRecords(String vehicleId) async {
    try {
      final records = await getMaintenanceRecordsByVehicle(vehicleId);
      return records.fold(
        (failure) => Left(failure),
        (recordsList) {
          final now = DateTime.now();
          final overdueRecords = recordsList.where((record) {
            if (record.nextServiceDate == null) return false;
            return record.nextServiceDate!.isBefore(now);
          }).toList();
          
          return Right(overdueRecords);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalMaintenanceCost(String vehicleId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      final records = await getMaintenanceRecordsByVehicle(vehicleId);
      return records.fold(
        (failure) => Left(failure),
        (recordsList) {
          var filteredRecords = recordsList;
          
          if (startDate != null && endDate != null) {
            filteredRecords = recordsList.where((record) {
              return record.serviceDate.isAfter(startDate) && record.serviceDate.isBefore(endDate);
            }).toList();
          }
          
          final totalCost = filteredRecords.fold(0.0, (sum, record) => sum + record.cost);
          return Right(totalCost);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getMaintenanceCountByType(String vehicleId) async {
    try {
      final records = await getMaintenanceRecordsByVehicle(vehicleId);
      return records.fold(
        (failure) => Left(failure),
        (recordsList) {
          final countByType = <String, int>{};
          
          for (final record in recordsList) {
            final typeName = record.type.displayName;
            countByType[typeName] = (countByType[typeName] ?? 0) + 1;
          }
          
          return Right(countByType);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getAverageMaintenanceCost(String vehicleId) async {
    try {
      final records = await getMaintenanceRecordsByVehicle(vehicleId);
      return records.fold(
        (failure) => Left(failure),
        (recordsList) {
          if (recordsList.isEmpty) return const Right(0.0);
          
          final totalCost = recordsList.fold(0.0, (sum, record) => sum + record.cost);
          final averageCost = totalCost / recordsList.length;
          
          return Right(averageCost);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MaintenanceEntity>>> getRecentMaintenanceRecords(String vehicleId, {int limit = 10}) async {
    try {
      final records = await getMaintenanceRecordsByVehicle(vehicleId);
      return records.fold(
        (failure) => Left(failure),
        (recordsList) {
          // Sort by service date (most recent first) and take limit
          recordsList.sort((a, b) => b.serviceDate.compareTo(a.serviceDate));
          final recentRecords = recordsList.take(limit).toList();
          
          return Right(recentRecords);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MaintenanceEntity?>> getLastMaintenanceRecord(String vehicleId) async {
    try {
      final recentRecords = await getRecentMaintenanceRecords(vehicleId, limit: 1);
      return recentRecords.fold(
        (failure) => Left(failure),
        (recordsList) {
          final lastRecord = recordsList.isNotEmpty ? recordsList.first : null;
          return Right(lastRecord);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}