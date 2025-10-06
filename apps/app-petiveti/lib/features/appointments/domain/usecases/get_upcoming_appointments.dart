import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';

class GetUpcomingAppointments implements UseCase<List<Appointment>, GetUpcomingAppointmentsParams> {
  final AppointmentRepository repository;

  GetUpcomingAppointments(this.repository);

  @override
  Future<Either<Failure, List<Appointment>>> call(GetUpcomingAppointmentsParams params) async {
    return await repository.getUpcomingAppointments(params.animalId);
  }
}

class GetUpcomingAppointmentsParams {
  final String animalId;

  GetUpcomingAppointmentsParams({required this.animalId});
}
