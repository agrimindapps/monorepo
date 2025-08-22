import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';

class GetAppointmentById implements UseCase<Appointment?, GetAppointmentByIdParams> {
  final AppointmentRepository repository;

  GetAppointmentById(this.repository);

  @override
  Future<Either<Failure, Appointment?>> call(GetAppointmentByIdParams params) async {
    return await repository.getAppointmentById(params.id);
  }
}

class GetAppointmentByIdParams {
  final String id;

  GetAppointmentByIdParams({required this.id});
}