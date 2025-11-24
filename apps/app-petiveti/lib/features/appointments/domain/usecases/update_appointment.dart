import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';
import '../services/appointment_validation_service.dart';

/// Use case for updating an existing appointment
///
/// **SOLID Principles Applied:**
/// - **Single Responsibility**: Only handles appointment update flow
/// - **Dependency Inversion**: Depends on abstractions (repository, validation service)
///
/// **Dependencies:**
/// - AppointmentRepository: For data persistence
/// - AppointmentValidationService: For business rule validation
class UpdateAppointment
    implements UseCase<Appointment, UpdateAppointmentParams> {
  final AppointmentRepository _repository;
  final AppointmentValidationService _validationService;

  UpdateAppointment(this._repository, this._validationService);

  @override
  Future<Either<Failure, Appointment>> call(
      UpdateAppointmentParams params) async {
    // Validate appointment data
    final validationResult = _validationService.validateForUpdate(
      params.appointment,
    );

    if (validationResult.isLeft()) {
      return validationResult.fold(
        (failure) => Left(failure),
        (_) => throw StateError('Validation should not return Right'),
      );
    }

    // Update timestamp
    final updatedAppointment = params.appointment.copyWith(
      updatedAt: DateTime.now(),
    );

    // Update appointment
    return await _repository.updateAppointment(updatedAppointment);
  }
}

class UpdateAppointmentParams {
  final Appointment appointment;

  UpdateAppointmentParams({required this.appointment});
}
