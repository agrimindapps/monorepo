import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/reminder.dart';

/// Service responsible for validating reminder business rules
///
/// **SOLID Principles:**
/// - **Single Responsibility**: Only handles reminder validation logic
/// - **Open/Closed**: New validation rules can be added without modifying existing code
/// - **Dependency Inversion**: Use cases depend on this abstraction
///
/// **Features:**
/// - Validates reminder title
/// - Validates scheduled date
/// - Validates recurring configuration
/// - Validates snooze date
/// - Validates reminder ID
/// - Composite validation for add/update operations
class ReminderValidationService {
  /// Validates reminder title
  ///
  /// Returns ValidationFailure if:
  /// - Title is empty or contains only whitespace
  Either<Failure, void> validateTitle(String title) {
    if (title.trim().isEmpty) {
      return const Left(
        ValidationFailure(message: 'Título do lembrete é obrigatório'),
      );
    }
    return const Right(null);
  }

  /// Validates scheduled date
  ///
  /// Returns ValidationFailure if:
  /// - Date is in the past (before yesterday)
  Either<Failure, void> validateScheduledDate(DateTime scheduledDate) {
    if (scheduledDate
        .isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return const Left(
        ValidationFailure(message: 'Data do lembrete não pode ser no passado'),
      );
    }
    return const Right(null);
  }

  /// Validates recurring configuration
  ///
  /// Returns ValidationFailure if:
  /// - Reminder is recurring but recurringDays is null or <= 0
  Either<Failure, void> validateRecurring(
      bool isRecurring, int? recurringDays) {
    if (isRecurring && (recurringDays == null || recurringDays <= 0)) {
      return const Left(
        ValidationFailure(
            message: 'Intervalo de recorrência deve ser maior que zero'),
      );
    }
    return const Right(null);
  }

  /// Validates snooze date
  ///
  /// Returns ValidationFailure if:
  /// - Snooze date is in the past
  Either<Failure, void> validateSnoozeDate(DateTime snoozeUntil) {
    if (snoozeUntil.isBefore(DateTime.now())) {
      return const Left(
        ValidationFailure(message: 'Data de adiamento deve ser futura'),
      );
    }
    return const Right(null);
  }

  /// Validates reminder ID
  ///
  /// Returns ValidationFailure if:
  /// - ID is empty or contains only whitespace
  Either<Failure, void> validateId(String reminderId) {
    if (reminderId.trim().isEmpty) {
      return const Left(
        ValidationFailure(message: 'ID do lembrete é obrigatório'),
      );
    }
    return const Right(null);
  }

  /// Validates all fields required for adding a new reminder
  ///
  /// Validates:
  /// - Title
  /// - Scheduled date
  /// - Recurring configuration
  ///
  /// Returns first validation failure encountered, or success if all validations pass
  Either<Failure, void> validateForAdd(Reminder reminder) {
    // Validate title
    final titleValidation = validateTitle(reminder.title);
    if (titleValidation.isLeft()) {
      return titleValidation;
    }

    // Validate scheduled date
    final dateValidation = validateScheduledDate(reminder.scheduledDate);
    if (dateValidation.isLeft()) {
      return dateValidation;
    }

    // Validate recurring configuration
    final recurringValidation = validateRecurring(
      reminder.isRecurring,
      reminder.recurringDays,
    );
    if (recurringValidation.isLeft()) {
      return recurringValidation;
    }

    return const Right(null);
  }

  /// Validates all fields required for updating an existing reminder
  ///
  /// Validates:
  /// - Title
  /// - Recurring configuration
  ///
  /// Note: Does not validate scheduled date for updates
  ///
  /// Returns first validation failure encountered, or success if all validations pass
  Either<Failure, void> validateForUpdate(Reminder reminder) {
    // Validate title
    final titleValidation = validateTitle(reminder.title);
    if (titleValidation.isLeft()) {
      return titleValidation;
    }

    // Validate recurring configuration
    final recurringValidation = validateRecurring(
      reminder.isRecurring,
      reminder.recurringDays,
    );
    if (recurringValidation.isLeft()) {
      return recurringValidation;
    }

    return const Right(null);
  }
}
