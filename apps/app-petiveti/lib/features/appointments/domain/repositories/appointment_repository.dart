import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/appointment.dart';

abstract class AppointmentRepository {
  Future<Either<Failure, List<Appointment>>> getAppointments(String animalId);
  Future<Either<Failure, List<Appointment>>> getUpcomingAppointments(String animalId);
  Future<Either<Failure, Appointment?>> getAppointmentById(String id);
  Future<Either<Failure, Appointment>> addAppointment(Appointment appointment);
  Future<Either<Failure, Appointment>> updateAppointment(Appointment appointment);
  Future<Either<Failure, void>> deleteAppointment(String id);
  Future<Either<Failure, List<Appointment>>> getAppointmentsByDateRange(
    String animalId,
    DateTime startDate,
    DateTime endDate,
  );
}