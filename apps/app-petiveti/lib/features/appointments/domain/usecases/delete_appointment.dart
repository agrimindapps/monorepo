import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../repositories/appointment_repository.dart';
import '../services/appointment_validation_service.dart';

/// Use case for deleting an appointment
///
/// **SOLID Principles Applied:**
/// - **Single Responsibility**: Only handles appointment deletion flow
/// - **Dependency Inversion**: Depends on abstractions (repository, validation service)
///
/// **Dependencies:**
/// - AppointmentRepository: For data persistence
/// - AppointmentValidationService: For ID validation
@lazySingleton
class DeleteAppointment implements UseCase<void, DeleteAppointmentParams> {
  final AppointmentRepository _repository;
  final AppointmentValidationService _validationService;

  DeleteAppointment(this._repository, this._validationService);

  @override
  Future<Either<Failure, void>> call(DeleteAppointmentParams params) async {
    // Validate appointment ID
    final validationResult = _validationService.validateId(params.id);

    if (validationResult.isLeft()) {
      return validationResult.fold(
        (failure) => Left(failure),
        (_) => throw StateError('Validation should not return Right'),
      );
    }

    // Delete appointment
    return await _repository.deleteAppointment(params.id);
  }
}

class DeleteAppointmentParams {
  final String id;

  DeleteAppointmentParams({required this.id});
}
