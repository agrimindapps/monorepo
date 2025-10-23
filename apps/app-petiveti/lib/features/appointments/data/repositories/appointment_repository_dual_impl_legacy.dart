import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/data/repositories/base_repository.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/logging/mixins/loggable_repository_mixin.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment_local_datasource.dart';
import '../datasources/appointment_remote_datasource.dart';
import '../models/appointment_model.dart';

class AppointmentRepositoryImpl extends BaseRepository
    with LoggableRepositoryMixin
    implements AppointmentRepository {
  final AppointmentLocalDataSource localDataSource;
  final AppointmentRemoteDataSource remoteDataSource;

  AppointmentRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required Connectivity connectivity,
  }) : super(connectivity);

  @override
  Future<Either<Failure, List<Appointment>>> getAppointments(String animalId) async {
    return executeWithSync<Appointment, AppointmentModel>(
      remoteOperation: () => remoteDataSource.getAppointments(animalId),
      localOperation: () => localDataSource.getAppointments(animalId),
      cacheOperation: (models) => localDataSource.cacheAppointments(models),
      toEntity: (model) => model.toEntity(),
    );
  }

  @override
  Future<Either<Failure, List<Appointment>>> getUpcomingAppointments(String animalId) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      final isConnected = !connectivityResult.contains(ConnectivityResult.none);

      if (isConnected) {
        try {
          final remoteAppointments = await remoteDataSource.getAppointments(animalId);
          await localDataSource.cacheAppointments(remoteAppointments);
          final upcomingAppointments = remoteAppointments
              .where((appointment) => appointment.toEntity().isUpcoming)
              .toList();
          
          return Right(upcomingAppointments.map((model) => model.toEntity()).toList());
        } catch (e) {
          final localAppointments = await localDataSource.getUpcomingAppointments(animalId);
          return Right(localAppointments.map((model) => model.toEntity()).toList());
        }
      } else {
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
      final localAppointment = await localDataSource.getAppointmentById(id);
      if (localAppointment != null) {
        return Right(localAppointment.toEntity());
      }
      final connectivityResult = await connectivity.checkConnectivity();
      final isConnected = !connectivityResult.contains(ConnectivityResult.none);

      if (isConnected) {
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
      await localDataSource.cacheAppointment(appointmentModel);
      final connectivityResult = await connectivity.checkConnectivity();
      final isConnected = !connectivityResult.contains(ConnectivityResult.none);

      if (isConnected) {
        try {
          final createdAppointment = await remoteDataSource.createAppointment(appointmentModel);
          await localDataSource.cacheAppointment(createdAppointment);
          return Right(createdAppointment.toEntity());
        } catch (e) {
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
      await localDataSource.updateAppointment(appointmentModel);
      final connectivityResult = await connectivity.checkConnectivity();
      final isConnected = !connectivityResult.contains(ConnectivityResult.none);

      if (isConnected) {
        try {
          final updatedAppointment = await remoteDataSource.updateAppointment(appointmentModel);
          await localDataSource.updateAppointment(updatedAppointment);
          return Right(updatedAppointment.toEntity());
        } catch (e) {
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
      await localDataSource.deleteAppointment(id);
      final connectivityResult = await connectivity.checkConnectivity();
      final isConnected = !connectivityResult.contains(ConnectivityResult.none);

      if (isConnected) {
        try {
          await remoteDataSource.deleteAppointment(id);
        } catch (e) {
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
      final connectivityResult = await connectivity.checkConnectivity();
      final isConnected = !connectivityResult.contains(ConnectivityResult.none);

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
          final localAppointments = await localDataSource.getAppointments(animalId);
          final filteredAppointments = localAppointments.where((appointment) {
            final appointmentDate = DateTime.fromMillisecondsSinceEpoch(appointment.dateTimestamp);
            return appointmentDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
                   appointmentDate.isBefore(endDate.add(const Duration(days: 1)));
          }).toList();
          
          return Right(filteredAppointments.map((model) => model.toEntity()).toList());
        }
      } else {
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
