import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment_local_datasource.dart';
import '../models/appointment_model.dart';

class AppointmentRepositoryLocalOnlyImpl implements AppointmentRepository {
  final AppointmentLocalDataSource localDataSource;

  AppointmentRepositoryLocalOnlyImpl({
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Appointment>>> getAppointments(String animalId) async {
    try {
      final appointmentModels = await localDataSource.getAppointments(animalId);
      final appointments = appointmentModels.map((model) => model.toEntity()).toList();
      return Right(appointments);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Appointment>>> getUpcomingAppointments(String animalId) async {
    try {
      final appointmentModels = await localDataSource.getUpcomingAppointments(animalId);
      final appointments = appointmentModels.map((model) => model.toEntity()).toList();
      return Right(appointments);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Appointment?>> getAppointmentById(String id) async {
    try {
      final appointmentModel = await localDataSource.getAppointmentById(id);
      final appointment = appointmentModel?.toEntity();
      return Right(appointment);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Appointment>> addAppointment(Appointment appointment) async {
    try {
      final newAppointment = appointment.id.isEmpty
          ? appointment.copyWith(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            )
          : appointment;

      final appointmentModel = AppointmentModel.fromEntity(newAppointment);
      await localDataSource.cacheAppointment(appointmentModel);
      return Right(newAppointment);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Appointment>> updateAppointment(Appointment appointment) async {
    try {
      final appointmentModel = AppointmentModel.fromEntity(appointment);
      await localDataSource.updateAppointment(appointmentModel);
      return Right(appointment);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAppointment(String id) async {
    try {
      await localDataSource.deleteAppointment(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Appointment>>> getAppointmentsByDateRange(
    String animalId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final appointmentModels = await localDataSource.getAppointments(animalId);
      final filteredModels = appointmentModels.where((appointment) {
        final appointmentDate = DateTime.fromMillisecondsSinceEpoch(appointment.dateTimestamp);
        return appointmentDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
               appointmentDate.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
      
      final appointments = filteredModels.map((model) => model.toEntity()).toList();
      return Right(appointments);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error: $e'));
    }
  }
}