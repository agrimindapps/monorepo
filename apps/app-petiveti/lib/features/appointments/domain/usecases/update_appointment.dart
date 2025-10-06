import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';

class UpdateAppointment implements UseCase<Appointment, UpdateAppointmentParams> {
  final AppointmentRepository repository;

  UpdateAppointment(this.repository);

  @override
  Future<Either<Failure, Appointment>> call(UpdateAppointmentParams params) async {
    if (params.appointment.veterinarianName.isEmpty) {
      return const Left(ValidationFailure(message: 'Nome do veterinário é obrigatório'));
    }
    
    if (params.appointment.reason.isEmpty) {
      return const Left(ValidationFailure(message: 'Motivo da consulta é obrigatório'));
    }
    
    if (params.appointment.id.isEmpty) {
      return const Left(ValidationFailure(message: 'ID da consulta é obrigatório'));
    }
    final updatedAppointment = params.appointment.copyWith(
      updatedAt: DateTime.now(),
    );

    return await repository.updateAppointment(updatedAppointment);
  }
}

class UpdateAppointmentParams {
  final Appointment appointment;

  UpdateAppointmentParams({required this.appointment});
}