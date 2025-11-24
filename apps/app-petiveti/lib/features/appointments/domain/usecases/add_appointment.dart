import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';
import '../services/appointment_validation_service.dart';

/// Use case for adding a new appointment
///
/// **SOLID Principles Applied:**
/// - **Single Responsibility**: Only handles appointment addition flow
/// - **Dependency Inversion**: Depends on abstractions (repository, validation service)
///
/// **Dependencies:**
/// - AppointmentRepository: For data persistence
/// - AppointmentValidationService: For business rule validation
class AddAppointment implements UseCase<Appointment, AddAppointmentParams> {
  final AppointmentRepository _repository;
  final AppointmentValidationService _validationService;

  AddAppointment(this._repository, this._validationService);

  @override
  Future<Either<Failure, Appointment>> call(AddAppointmentParams params) async {
    // Validate appointment data
    final validationResult = _validationService.validateForAdd(
      params.appointment,
    );

    if (validationResult.isLeft()) {
      return validationResult.fold(
        (failure) => Left(failure),
        (_) => throw StateError('Validation should not return Right'),
      );
    }

    // Add appointment
    return await _repository.addAppointment(params.appointment);
  }
}

class AddAppointmentParams {
  final Appointment appointment;

  AddAppointmentParams({required this.appointment});
}
