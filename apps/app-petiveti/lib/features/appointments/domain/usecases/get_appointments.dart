import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';

/// Use case for retrieving all appointments for an animal
///
/// **SOLID Principles Applied:**
/// - **Single Responsibility**: Only handles appointment retrieval flow
/// - **Dependency Inversion**: Depends on repository abstraction
@lazySingleton
class GetAppointments
    implements UseCase<List<Appointment>, GetAppointmentsParams> {
  final AppointmentRepository _repository;

  GetAppointments(this._repository);

  @override
  Future<Either<Failure, List<Appointment>>> call(
      GetAppointmentsParams params) async {
    return await _repository.getAppointments(params.animalId);
  }
}

class GetAppointmentsParams {
  final String animalId;

  GetAppointmentsParams({required this.animalId});
}
