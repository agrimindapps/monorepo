import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';

class GetAppointments implements UseCase<List<Appointment>, GetAppointmentsParams> {
  final AppointmentRepository repository;

  GetAppointments(this.repository);

  @override
  Future<Either<Failure, List<Appointment>>> call(GetAppointmentsParams params) async {
    return await repository.getAppointments(params.animalId);
  }
}

class GetAppointmentsParams {
  final String animalId;

  GetAppointmentsParams({required this.animalId});
}
