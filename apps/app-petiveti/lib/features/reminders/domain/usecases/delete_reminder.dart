import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../repositories/reminder_repository.dart';
import '../services/reminder_validation_service.dart';

/// Use case for deleting a reminder
///
/// **SOLID Principles Applied:**
/// - **Single Responsibility**: Only handles reminder deletion flow
/// - **Dependency Inversion**: Depends on abstractions (repository, validation service)
///
/// **Dependencies:**
/// - ReminderRepository: For data deletion
/// - ReminderValidationService: For ID validation
@lazySingleton
class DeleteReminder implements UseCase<void, String> {
  final ReminderRepository _repository;
  final ReminderValidationService _validationService;

  DeleteReminder(this._repository, this._validationService);

  @override
  Future<Either<Failure, void>> call(String reminderId) async {
    // Validate reminder ID
    final validationResult = _validationService.validateId(reminderId);

    if (validationResult.isLeft()) {
      return validationResult.fold(
        (failure) => Left(failure),
        (_) => throw StateError('Validation should not return Right'),
      );
    }

    // Delete reminder
    return await _repository.deleteReminder(reminderId);
  }
}
