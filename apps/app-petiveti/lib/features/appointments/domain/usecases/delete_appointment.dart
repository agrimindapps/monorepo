import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../repositories/appointment_repository.dart';

class DeleteAppointment implements UseCase<void, DeleteAppointmentParams> {
  final AppointmentRepository repository;

  DeleteAppointment(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteAppointmentParams params) async {
    if (params.id.isEmpty) {
      return Left(ValidationFailure(message: 'ID da consulta é obrigatório'));
    }

    return await repository.deleteAppointment(params.id);
  }
}

class DeleteAppointmentParams {
  final String id;

  DeleteAppointmentParams({required this.id});
}