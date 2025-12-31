import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/vaccine.dart';

/// Service responsible for validating vaccine-related business rules.
///
/// **SOLID Principles:**
/// - **Single Responsibility**: Only validates vaccine data
/// - **Open/Closed**: New validations can be added without modifying existing ones
/// - **Dependency Inversion**: Used by use cases through abstraction
class VaccineValidationService {
  /// Validates vaccine name
  ///
  /// **Rules:**
  /// - Cannot be empty
  /// - Must have at least 2 characters
  /// - Must have at most 100 characters
  Either<Failure, void> validateName(String name) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return const Left(
        ValidationFailure(message: 'Nome da vacina é obrigatório'),
      );
    }
    if (trimmedName.length < 2) {
      return const Left(
        ValidationFailure(message: 'Nome da vacina deve ter pelo menos 2 caracteres'),
      );
    }
    if (trimmedName.length > 100) {
      return const Left(
        ValidationFailure(message: 'Nome da vacina deve ter no máximo 100 caracteres'),
      );
    }
    return const Right(null);
  }

  /// Validates veterinarian name
  ///
  /// **Rules:**
  /// - Cannot be empty
  /// - Must have at least 2 characters
  /// - Must have at most 100 characters
  Either<Failure, void> validateVeterinarian(String veterinarian) {
    final trimmedName = veterinarian.trim();
    if (trimmedName.isEmpty) {
      return const Left(
        ValidationFailure(message: 'Nome do veterinário é obrigatório'),
      );
    }
    if (trimmedName.length < 2) {
      return const Left(
        ValidationFailure(message: 'Nome do veterinário deve ter pelo menos 2 caracteres'),
      );
    }
    if (trimmedName.length > 100) {
      return const Left(
        ValidationFailure(message: 'Nome do veterinário deve ter no máximo 100 caracteres'),
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

  /// Validates application date
  ///
  /// **Rules:**
  /// - Cannot be in the future
  /// - Cannot be more than 20 years in the past
  Either<Failure, void> validateApplicationDate(DateTime date) {
    final now = DateTime.now();
    
    if (date.isAfter(now)) {
      return const Left(
        ValidationFailure(message: 'Data de aplicação não pode ser no futuro'),
      );
    }
    
    final minDate = now.subtract(const Duration(days: 365 * 20));
    if (date.isBefore(minDate)) {
      return const Left(
        ValidationFailure(message: 'Data de aplicação inválida (muito antiga)'),
      );
    }
    
    return const Right(null);
  }

  /// Validates next due date
  ///
  /// **Rules:**
  /// - If provided, must be after application date
  /// - Cannot be more than 5 years in the future
  Either<Failure, void> validateNextDueDate(DateTime? nextDueDate, DateTime applicationDate) {
    if (nextDueDate == null) return const Right(null);
    
    if (nextDueDate.isBefore(applicationDate) || nextDueDate.isAtSameMomentAs(applicationDate)) {
      return const Left(
        ValidationFailure(message: 'Data da próxima dose deve ser posterior à data de aplicação'),
      );
    }
    
    final maxDate = DateTime.now().add(const Duration(days: 365 * 5));
    if (nextDueDate.isAfter(maxDate)) {
      return const Left(
        ValidationFailure(message: 'Data da próxima dose não pode ser superior a 5 anos'),
      );
    }
    
    return const Right(null);
  }

  /// Validates reminder date
  ///
  /// **Rules:**
  /// - If provided, must be in the future or today
  /// - If nextDueDate exists, reminder should be before or on nextDueDate
  Either<Failure, void> validateReminderDate(DateTime? reminderDate, DateTime? nextDueDate) {
    if (reminderDate == null) return const Right(null);
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final reminderDay = DateTime(reminderDate.year, reminderDate.month, reminderDate.day);
    
    if (reminderDay.isBefore(today)) {
      return const Left(
        ValidationFailure(message: 'Data do lembrete deve ser hoje ou no futuro'),
      );
    }
    
    if (nextDueDate != null && reminderDate.isAfter(nextDueDate)) {
      return const Left(
        ValidationFailure(message: 'Data do lembrete deve ser anterior ou igual à próxima dose'),
      );
    }
    
    return const Right(null);
  }

  /// Validates batch number
  ///
  /// **Rules:**
  /// - If provided, must have between 3 and 30 characters
  /// - Only alphanumeric characters, hyphens and dots allowed
  Either<Failure, void> validateBatch(String? batch) {
    if (batch == null || batch.trim().isEmpty) return const Right(null);
    
    final trimmedBatch = batch.trim();
    if (trimmedBatch.length < 3) {
      return const Left(
        ValidationFailure(message: 'Número do lote deve ter pelo menos 3 caracteres'),
      );
    }
    if (trimmedBatch.length > 30) {
      return const Left(
        ValidationFailure(message: 'Número do lote deve ter no máximo 30 caracteres'),
      );
    }
    
    // Allow alphanumeric, hyphens, dots and slashes
    final validPattern = RegExp(r'^[a-zA-Z0-9\-\.\/]+$');
    if (!validPattern.hasMatch(trimmedBatch)) {
      return const Left(
        ValidationFailure(message: 'Número do lote contém caracteres inválidos'),
      );
    }
    
    return const Right(null);
  }

  /// Validates manufacturer name
  ///
  /// **Rules:**
  /// - If provided, must have at most 100 characters
  Either<Failure, void> validateManufacturer(String? manufacturer) {
    if (manufacturer == null || manufacturer.trim().isEmpty) return const Right(null);
    
    if (manufacturer.trim().length > 100) {
      return const Left(
        ValidationFailure(message: 'Nome do fabricante deve ter no máximo 100 caracteres'),
      );
    }
    
    return const Right(null);
  }

  /// Validates dosage
  ///
  /// **Rules:**
  /// - If provided, must have at most 100 characters
  Either<Failure, void> validateDosage(String? dosage) {
    if (dosage == null || dosage.trim().isEmpty) return const Right(null);
    
    if (dosage.trim().length > 100) {
      return const Left(
        ValidationFailure(message: 'Dosagem deve ter no máximo 100 caracteres'),
      );
    }
    
    return const Right(null);
  }

  /// Validates notes
  ///
  /// **Rules:**
  /// - If provided, must have at most 500 characters
  Either<Failure, void> validateNotes(String? notes) {
    if (notes == null || notes.trim().isEmpty) return const Right(null);
    
    if (notes.trim().length > 500) {
      return const Left(
        ValidationFailure(message: 'Observações devem ter no máximo 500 caracteres'),
      );
    }
    
    return const Right(null);
  }

  /// Validates all fields for adding a new vaccine
  Either<Failure, void> validateForAdd(Vaccine vaccine) {
    // Required fields
    final nameValidation = validateName(vaccine.name);
    if (nameValidation.isLeft()) return nameValidation;

    final vetValidation = validateVeterinarian(vaccine.veterinarian);
    if (vetValidation.isLeft()) return vetValidation;

    final animalValidation = validateAnimalId(vaccine.animalId);
    if (animalValidation.isLeft()) return animalValidation;

    final dateValidation = validateApplicationDate(vaccine.date);
    if (dateValidation.isLeft()) return dateValidation;

    // Optional fields with validation
    final nextDueDateValidation = validateNextDueDate(vaccine.nextDueDate, vaccine.date);
    if (nextDueDateValidation.isLeft()) return nextDueDateValidation;

    final reminderValidation = validateReminderDate(vaccine.reminderDate, vaccine.nextDueDate);
    if (reminderValidation.isLeft()) return reminderValidation;

    final batchValidation = validateBatch(vaccine.batch);
    if (batchValidation.isLeft()) return batchValidation;

    final manufacturerValidation = validateManufacturer(vaccine.manufacturer);
    if (manufacturerValidation.isLeft()) return manufacturerValidation;

    final dosageValidation = validateDosage(vaccine.dosage);
    if (dosageValidation.isLeft()) return dosageValidation;

    final notesValidation = validateNotes(vaccine.notes);
    if (notesValidation.isLeft()) return notesValidation;

    return const Right(null);
  }

  /// Validates all fields for updating an existing vaccine
  Either<Failure, void> validateForUpdate(Vaccine vaccine) {
    // Validate ID for updates
    if (vaccine.id.trim().isEmpty) {
      return const Left(
        ValidationFailure(message: 'ID da vacina é obrigatório para atualização'),
      );
    }

    return validateForAdd(vaccine);
  }
}
