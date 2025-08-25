import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment_local_datasource.dart';
import '../datasources/appointment_remote_datasource.dart';
import '../models/appointment_model.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentLocalDataSource localDataSource;
  final AppointmentRemoteDataSource remoteDataSource;
  final Connectivity connectivity;

  AppointmentRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivity,
  });

  @override
  Future<Either<Failure, List<Appointment>>> getAppointments(String animalId) async {
    try {
      // Try to get data from remote first if connected
      final connectivityResult = await connectivity.checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        try {
          final remoteAppointments = await remoteDataSource.getAppointments(animalId);
          await localDataSource.cacheAppointments(remoteAppointments);
          return Right(remoteAppointments.map((model) => model.toEntity()).toList());
        } catch (e) {
          // If remote fails, fallback to local data
          final localAppointments = await localDataSource.getAppointments(animalId);
          return Right(localAppointments.map((model) => model.toEntity()).toList());
        }
      } else {
        // If not connected, get from local cache
        final localAppointments = await localDataSource.getAppointments(animalId);
        return Right(localAppointments.map((model) => model.toEntity()).toList());
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Appointment>>> getUpcomingAppointments(String animalId) async {
    try {
      // Try to get data from remote first if connected
      final connectivityResult = await connectivity.checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        try {
          final remoteAppointments = await remoteDataSource.getAppointments(animalId);
          await localDataSource.cacheAppointments(remoteAppointments);
          
          // Filter upcoming appointments locally
          final upcomingAppointments = remoteAppointments
              .where((appointment) => appointment.toEntity().isUpcoming)
              .toList();
          
          return Right(upcomingAppointments.map((model) => model.toEntity()).toList());
        } catch (e) {
          // If remote fails, fallback to local data
          final localAppointments = await localDataSource.getUpcomingAppointments(animalId);
          return Right(localAppointments.map((model) => model.toEntity()).toList());
        }
      } else {
        // If not connected, get from local cache
        final localAppointments = await localDataSource.getUpcomingAppointments(animalId);
        return Right(localAppointments.map((model) => model.toEntity()).toList());
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Appointment?>> getAppointmentById(String id) async {
    try {
      // First try local cache
      final localAppointment = await localDataSource.getAppointmentById(id);
      if (localAppointment != null) {
        return Right(localAppointment.toEntity());
      }

      // If not found locally and connected, try remote
      final connectivityResult = await connectivity.checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        // Note: We'd need to implement getAppointmentById in remote datasource
        // For now, we'll return null if not found locally
        return const Right(null);
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Appointment>> addAppointment(Appointment appointment) async {
    try {
      final appointmentModel = AppointmentModel.fromEntity(appointment);
      
      // Always cache locally first
      await localDataSource.cacheAppointment(appointmentModel);

      // Try to sync with remote if connected
      final connectivityResult = await connectivity.checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        try {
          final createdAppointment = await remoteDataSource.createAppointment(appointmentModel);
          await localDataSource.cacheAppointment(createdAppointment);
          return Right(createdAppointment.toEntity());
        } catch (e) {
          // If remote fails, return local version
          return Right(appointmentModel.toEntity());
        }
      } else {
        return Right(appointmentModel.toEntity());
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Appointment>> updateAppointment(Appointment appointment) async {
    try {
      final appointmentModel = AppointmentModel.fromEntity(appointment);
      
      // Always update locally first
      await localDataSource.updateAppointment(appointmentModel);

      // Try to sync with remote if connected
      final connectivityResult = await connectivity.checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        try {
          final updatedAppointment = await remoteDataSource.updateAppointment(appointmentModel);
          await localDataSource.updateAppointment(updatedAppointment);
          return Right(updatedAppointment.toEntity());
        } catch (e) {
          // If remote fails, return local version
          return Right(appointmentModel.toEntity());
        }
      } else {
        return Right(appointmentModel.toEntity());
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAppointment(String id) async {
    try {
      // Always delete locally first
      await localDataSource.deleteAppointment(id);

      // Try to sync with remote if connected
      final connectivityResult = await connectivity.checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        try {
          await remoteDataSource.deleteAppointment(id);
        } catch (e) {
          // If remote fails, we've already deleted locally
          // This will be synced later when connection is restored
        }
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Appointment>>> getAppointmentsByDateRange(
    String animalId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // Try to get data from remote first if connected
      final connectivityResult = await connectivity.checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        try {
          final remoteAppointments = await remoteDataSource.getAppointmentsByDateRange(
            animalId,
            startDate,
            endDate,
          );
          await localDataSource.cacheAppointments(remoteAppointments);
          return Right(remoteAppointments.map((model) => model.toEntity()).toList());
        } catch (e) {
          // If remote fails, fallback to local data
          final localAppointments = await localDataSource.getAppointments(animalId);
          final filteredAppointments = localAppointments.where((appointment) {
            final appointmentDate = DateTime.fromMillisecondsSinceEpoch(appointment.dateTimestamp);
            return appointmentDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
                   appointmentDate.isBefore(endDate.add(const Duration(days: 1)));
          }).toList();
          
          return Right(filteredAppointments.map((model) => model.toEntity()).toList());
        }
      } else {
        // If not connected, filter local data
        final localAppointments = await localDataSource.getAppointments(animalId);
        final filteredAppointments = localAppointments.where((appointment) {
          final appointmentDate = DateTime.fromMillisecondsSinceEpoch(appointment.dateTimestamp);
          return appointmentDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
                 appointmentDate.isBefore(endDate.add(const Duration(days: 1)));
        }).toList();
        
        return Right(filteredAppointments.map((model) => model.toEntity()).toList());
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }
}