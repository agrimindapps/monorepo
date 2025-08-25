import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';

class AddAppointment implements UseCase<Appointment, AddAppointmentParams> {
  final AppointmentRepository repository;

  AddAppointment(this.repository);

  @override
  Future<Either<Failure, Appointment>> call(AddAppointmentParams params) async {
    // Validate appointment data
    if (params.appointment.veterinarianName.isEmpty) {
      return const Left(ValidationFailure(message: 'Nome do veterinário é obrigatório'));
    }
    
    if (params.appointment.reason.isEmpty) {
      return const Left(ValidationFailure(message: 'Motivo da consulta é obrigatório'));
    }
    
    if (params.appointment.animalId.isEmpty) {
      return const Left(ValidationFailure(message: 'Animal deve ser selecionado'));
    }

    return await repository.addAppointment(params.appointment);
  }
}

class AddAppointmentParams {
  final Appointment appointment;

  AddAppointmentParams({required this.appointment});
}