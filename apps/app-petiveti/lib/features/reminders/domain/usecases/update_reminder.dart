import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/reminder.dart';
import '../repositories/reminder_repository.dart';
import '../services/reminder_validation_service.dart';

/// Use case for updating an existing reminder
///
/// **SOLID Principles Applied:**
/// - **Single Responsibility**: Only handles reminder update flow
/// - **Dependency Inversion**: Depends on abstractions (repository, validation service)
@lazySingleton
class UpdateReminder implements UseCase<void, Reminder> {
  final ReminderRepository _repository;
  final ReminderValidationService _validationService;

  UpdateReminder(this._repository, this._validationService);

  @override
  Future<Either<Failure, void>> call(Reminder reminder) async {
    // Validate reminder data
    final validationResult = _validationService.validateForUpdate(reminder);

    if (validationResult.isLeft()) {
      return validationResult.fold(
        (failure) => Left(failure),
        (_) => throw StateError('Validation should not return Right'),
      );
    }

    // Update reminder
    return await _repository.updateReminder(reminder);
  }
}

/// Use case for marking a reminder as completed
///
/// **SOLID Principles Applied:**
/// - **Single Responsibility**: Only handles reminder completion flow
/// - **Dependency Inversion**: Depends on repository abstraction
@lazySingleton
class CompleteReminder implements UseCase<void, String> {
  final ReminderRepository _repository;

  CompleteReminder(this._repository);

  @override
  Future<Either<Failure, void>> call(String reminderId) async {
    return await _repository.completeReminder(reminderId);
  }
}

class SnoozeReminderParams {
  final String reminderId;
  final DateTime snoozeUntil;

  SnoozeReminderParams({
    required this.reminderId,
    required this.snoozeUntil,
  });
}

/// Use case for snoozing a reminder to a later date
///
/// **SOLID Principles Applied:**
/// - **Single Responsibility**: Only handles reminder snooze flow
/// - **Dependency Inversion**: Depends on abstractions (repository, validation service)
@lazySingleton
class SnoozeReminder implements UseCase<void, SnoozeReminderParams> {
  final ReminderRepository _repository;
  final ReminderValidationService _validationService;

  SnoozeReminder(this._repository, this._validationService);

  @override
  Future<Either<Failure, void>> call(SnoozeReminderParams params) async {
    // Validate snooze date
    final validationResult =
        _validationService.validateSnoozeDate(params.snoozeUntil);

    if (validationResult.isLeft()) {
      return validationResult.fold(
        (failure) => Left(failure),
        (_) => throw StateError('Validation should not return Right'),
      );
    }

    // Snooze reminder
    return await _repository.snoozeReminder(
        params.reminderId, params.snoozeUntil);
  }
}
