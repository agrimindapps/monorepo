import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/reminder.dart';
import '../repositories/reminder_repository.dart';
import '../services/reminder_validation_service.dart';

/// Use case for adding a new reminder
///
/// **SOLID Principles Applied:**
/// - **Single Responsibility**: Only handles reminder addition flow
/// - **Dependency Inversion**: Depends on abstractions (repository, validation service)
///
/// **Dependencies:**
/// - ReminderRepository: For data persistence
/// - ReminderValidationService: For business rule validation
@lazySingleton
class AddReminder implements UseCase<void, Reminder> {
  final ReminderRepository _repository;
  final ReminderValidationService _validationService;

  AddReminder(this._repository, this._validationService);

  @override
  Future<Either<Failure, void>> call(Reminder reminder) async {
    // Validate reminder data
    final validationResult = _validationService.validateForAdd(reminder);

    if (validationResult.isLeft()) {
      return validationResult.fold(
        (failure) => Left(failure),
        (_) => throw StateError('Validation should not return Right'),
      );
    }

    // Add reminder
    return await _repository.addReminder(reminder);
  }
}
