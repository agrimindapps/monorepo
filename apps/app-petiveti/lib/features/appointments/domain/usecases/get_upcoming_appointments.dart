import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';

/// Use case for retrieving upcoming appointments for an animal
///
/// **SOLID Principles Applied:**
/// - **Single Responsibility**: Only handles upcoming appointment retrieval flow
/// - **Dependency Inversion**: Depends on repository abstraction
@lazySingleton
class GetUpcomingAppointments
    implements UseCase<List<Appointment>, GetUpcomingAppointmentsParams> {
  final AppointmentRepository _repository;

  GetUpcomingAppointments(this._repository);

  @override
  Future<Either<Failure, List<Appointment>>> call(
      GetUpcomingAppointmentsParams params) async {
    return await _repository.getUpcomingAppointments(params.animalId);
  }
}

class GetUpcomingAppointmentsParams {
  final String animalId;

  GetUpcomingAppointmentsParams({required this.animalId});
}
