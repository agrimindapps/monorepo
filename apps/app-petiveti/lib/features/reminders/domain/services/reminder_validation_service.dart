import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/reminder.dart';

/// Service responsible for validating reminder business rules
///
/// **SOLID Principles:**
/// - **Single Responsibility**: Only handles reminder validation logic
/// - **Open/Closed**: New validation rules can be added without modifying existing code
/// - **Dependency Inversion**: Use cases depend on this abstraction
class ReminderValidationService {
  /// Validates reminder title
  ///
  /// **Rules:**
  /// - Cannot be empty
  /// - Must have at least 3 characters
  /// - Must have at most 100 characters
  Either<Failure, void> validateTitle(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      return const Left(
        ValidationFailure(message: 'Título do lembrete é obrigatório'),
      );
    }
    if (trimmed.length < 3) {
      return const Left(
        ValidationFailure(message: 'Título deve ter pelo menos 3 caracteres'),
      );
    }
    if (trimmed.length > 100) {
      return const Left(
        ValidationFailure(message: 'Título deve ter no máximo 100 caracteres'),
      );
    }
    return const Right(null);
  }

  /// Validates reminder description
  ///
  /// **Rules:**
  /// - Cannot be empty
  /// - Must have at most 500 characters
  Either<Failure, void> validateDescription(String description) {
    final trimmed = description.trim();
    if (trimmed.isEmpty) {
      return const Left(
        ValidationFailure(message: 'Descrição é obrigatória'),
      );
    }
    if (trimmed.length > 500) {
      return const Left(
        ValidationFailure(message: 'Descrição deve ter no máximo 500 caracteres'),
      );
    }
    return const Right(null);
  }

  /// Validates animal ID
  ///
  /// **Rules:**
  /// - Cannot be empty
  Either<Failure, void> validateAnimalId(String animalId) {
    if (animalId.trim().isEmpty) {
      return const Left(
        ValidationFailure(message: 'Animal deve ser selecionado'),
      );
    }
    return const Right(null);
  }

  /// Validates scheduled date
  ///
  /// **Rules:**
  /// - Cannot be more than 1 day in the past
  /// - Cannot be more than 2 years in the future
  Either<Failure, void> validateScheduledDate(DateTime scheduledDate) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    
    if (scheduledDate.isBefore(yesterday)) {
      return const Left(
        ValidationFailure(message: 'Data do lembrete não pode ser no passado'),
      );
    }
    
    final twoYearsAhead = now.add(const Duration(days: 365 * 2));
    if (scheduledDate.isAfter(twoYearsAhead)) {
      return const Left(
        ValidationFailure(message: 'Data do lembrete não pode ser superior a 2 anos no futuro'),
      );
    }
    
    return const Right(null);
  }

  /// Validates recurring configuration
  ///
  /// **Rules:**
  /// - If recurring, interval must be > 0
  /// - Interval must be <= 365 days
  Either<Failure, void> validateRecurring(bool isRecurring, int? recurringDays) {
    if (!isRecurring) return const Right(null);
    
    if (recurringDays == null || recurringDays <= 0) {
      return const Left(
        ValidationFailure(
          message: 'Intervalo de recorrência deve ser maior que zero',
        ),
      );
    }
    
    if (recurringDays > 365) {
      return const Left(
        ValidationFailure(
          message: 'Intervalo de recorrência não pode exceder 365 dias',
        ),
      );
    }
    
    return const Right(null);
  }

  /// Validates snooze date
  ///
  /// **Rules:**
  /// - Must be in the future
  /// - Cannot be more than 30 days ahead
  Either<Failure, void> validateSnoozeDate(DateTime snoozeUntil) {
    final now = DateTime.now();
    
    if (snoozeUntil.isBefore(now)) {
      return const Left(
        ValidationFailure(message: 'Data de adiamento deve ser futura'),
      );
    }
    
    final maxSnooze = now.add(const Duration(days: 30));
    if (snoozeUntil.isAfter(maxSnooze)) {
      return const Left(
        ValidationFailure(message: 'Adiamento máximo é de 30 dias'),
      );
    }
    
    return const Right(null);
  }

  /// Validates reminder ID
  Either<Failure, void> validateId(String reminderId) {
    if (reminderId.trim().isEmpty) {
      return const Left(
        ValidationFailure(message: 'ID do lembrete é obrigatório'),
      );
    }
    return const Right(null);
  }

  /// Validates all fields required for adding a new reminder
  Either<Failure, void> validateForAdd(Reminder reminder) {
    // Validate title
    final titleValidation = validateTitle(reminder.title);
    if (titleValidation.isLeft()) return titleValidation;

    // Validate description
    final descValidation = validateDescription(reminder.description);
    if (descValidation.isLeft()) return descValidation;

    // Validate animal ID
    final animalValidation = validateAnimalId(reminder.animalId);
    if (animalValidation.isLeft()) return animalValidation;

    // Validate scheduled date
    final dateValidation = validateScheduledDate(reminder.scheduledDate);
    if (dateValidation.isLeft()) return dateValidation;

    // Validate recurring configuration
    final recurringValidation = validateRecurring(
      reminder.isRecurring,
      reminder.recurringDays,
    );
    if (recurringValidation.isLeft()) return recurringValidation;

    return const Right(null);
  }

  /// Validates all fields required for updating an existing reminder
  Either<Failure, void> validateForUpdate(Reminder reminder) {
    // Validate ID first
    final idValidation = validateId(reminder.id);
    if (idValidation.isLeft()) return idValidation;

    // Validate title
    final titleValidation = validateTitle(reminder.title);
    if (titleValidation.isLeft()) return titleValidation;

    // Validate description
    final descValidation = validateDescription(reminder.description);
    if (descValidation.isLeft()) return descValidation;

    // Validate recurring configuration
    final recurringValidation = validateRecurring(
      reminder.isRecurring,
      reminder.recurringDays,
    );
    if (recurringValidation.isLeft()) return recurringValidation;

    return const Right(null);
  }
}
