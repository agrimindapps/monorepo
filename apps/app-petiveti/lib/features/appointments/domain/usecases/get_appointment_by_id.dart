import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';
import '../services/appointment_validation_service.dart';

/// Use case for retrieving a specific appointment by ID
///
/// **SOLID Principles Applied:**
/// - **Single Responsibility**: Only handles single appointment retrieval flow
/// - **Dependency Inversion**: Depends on abstractions (repository, validation service)
///
/// **Dependencies:**
/// - AppointmentRepository: For data retrieval
/// - AppointmentValidationService: For ID validation
class GetAppointmentById
    implements UseCase<Appointment?, GetAppointmentByIdParams> {
  final AppointmentRepository _repository;
  final AppointmentValidationService _validationService;

  GetAppointmentById(this._repository, this._validationService);

  @override
  Future<Either<Failure, Appointment?>> call(
      GetAppointmentByIdParams params) async {
    // Validate appointment ID
    final validationResult = _validationService.validateId(params.id);

    if (validationResult.isLeft()) {
      return validationResult.fold(
        (failure) => Left(failure),
        (_) => throw StateError('Validation should not return Right'),
      );
    }

    // Get appointment
    return await _repository.getAppointmentById(params.id);
  }
}

class GetAppointmentByIdParams {
  final String id;

  GetAppointmentByIdParams({required this.id});
}
