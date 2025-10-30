import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/medication.dart';

/// Service responsible for validating medication-related business rules.
///
/// **SOLID Principles:**
/// - **Single Responsibility**: Only validates medication data
/// - **Open/Closed**: New validations can be added without modifying existing ones
/// - **Dependency Inversion**: Used by use cases through abstraction
///
/// **Usage:**
/// ```dart
/// // In use cases
/// final validationResult = _validationService.validateForAdd(medication);
/// if (validationResult.isLeft()) return validationResult;
/// ```
@lazySingleton
class MedicationValidationService {
  /// Validates medication name
  ///
  /// **Rules:**
  /// - Cannot be empty
  /// - Cannot be only whitespace
  Either<Failure, void> validateName(String name) {
    if (name.trim().isEmpty) {
      return const Left(
        ValidationFailure(message: 'Nome do medicamento é obrigatório'),
      );
    }
    return const Right(null);
  }

  /// Validates medication dosage
  ///
  /// **Rules:**
  /// - Cannot be empty
  /// - Cannot be only whitespace
  Either<Failure, void> validateDosage(String dosage) {
    if (dosage.trim().isEmpty) {
      return const Left(
        ValidationFailure(message: 'Dosagem é obrigatória'),
      );
    }
    return const Right(null);
  }

  /// Validates medication frequency
  ///
  /// **Rules:**
  /// - Cannot be empty
  /// - Cannot be only whitespace
  Either<Failure, void> validateFrequency(String frequency) {
    if (frequency.trim().isEmpty) {
      return const Left(
        ValidationFailure(message: 'Frequência é obrigatória'),
      );
    }
    return const Right(null);
  }

  /// Validates animal ID
  ///
  /// **Rules:**
  /// - Cannot be empty
  /// - Cannot be only whitespace
  Either<Failure, void> validateAnimalId(String animalId) {
    if (animalId.trim().isEmpty) {
      return const Left(
        ValidationFailure(message: 'ID do animal é obrigatório'),
      );
    }
    return const Right(null);
  }

  /// Validates medication ID
  ///
  /// **Rules:**
  /// - Cannot be empty
  /// - Cannot be only whitespace
  Either<Failure, void> validateId(String id) {
    if (id.trim().isEmpty) {
      return const Left(
        ValidationFailure(message: 'ID do medicamento é obrigatório'),
      );
    }
    return const Right(null);
  }

  /// Validates start date
  ///
  /// **Rules:**
  /// - Cannot be null
  Either<Failure, void> validateStartDate(DateTime? startDate) {
    if (startDate == null) {
      return const Left(
        ValidationFailure(message: 'Data de início é obrigatória'),
      );
    }
    return const Right(null);
  }

  /// Validates end date
  ///
  /// **Rules:**
  /// - If provided, must be after start date
  Either<Failure, void> validateEndDate(
      DateTime? startDate, DateTime? endDate) {
    if (endDate != null && startDate != null && endDate.isBefore(startDate)) {
      return const Left(
        ValidationFailure(
          message: 'Data de término deve ser posterior à data de início',
        ),
      );
    }
    return const Right(null);
  }

  /// Validates discontinuation reason
  ///
  /// **Rules:**
  /// - Cannot be empty
  /// - Cannot be only whitespace
  Either<Failure, void> validateDiscontinuationReason(String reason) {
    if (reason.trim().isEmpty) {
      return const Left(
        ValidationFailure(message: 'Motivo da descontinuação é obrigatório'),
      );
    }
    return const Right(null);
  }

  /// Validates all fields for adding a new medication
  ///
  /// **Aggregates validations:**
  /// - Name
  /// - Dosage
  /// - Frequency
  /// - Animal ID
  /// - Start Date
  /// - End Date (if provided)
  Either<Failure, void> validateForAdd(Medication medication) {
    // Validate name
    final nameValidation = validateName(medication.name);
    if (nameValidation.isLeft()) return nameValidation;

    // Validate dosage
    final dosageValidation = validateDosage(medication.dosage);
    if (dosageValidation.isLeft()) return dosageValidation;

    // Validate frequency
    final frequencyValidation = validateFrequency(medication.frequency);
    if (frequencyValidation.isLeft()) return frequencyValidation;

    // Validate animal ID
    final animalIdValidation = validateAnimalId(medication.animalId);
    if (animalIdValidation.isLeft()) return animalIdValidation;

    // Validate start date
    final startDateValidation = validateStartDate(medication.startDate);
    if (startDateValidation.isLeft()) return startDateValidation;

    // Validate end date (if provided)
    final endDateValidation = validateEndDate(
      medication.startDate,
      medication.endDate,
    );
    if (endDateValidation.isLeft()) return endDateValidation;

    return const Right(null);
  }

  /// Validates all fields for updating an existing medication
  ///
  /// **Aggregates validations:**
  /// - ID (required for update)
  /// - Name
  /// - Dosage
  /// - Frequency
  /// - Animal ID
  /// - Start Date
  /// - End Date (if provided)
  Either<Failure, void> validateForUpdate(Medication medication) {
    // Validate ID
    final idValidation = validateId(medication.id);
    if (idValidation.isLeft()) return idValidation;

    // Validate name
    final nameValidation = validateName(medication.name);
    if (nameValidation.isLeft()) return nameValidation;

    // Validate dosage
    final dosageValidation = validateDosage(medication.dosage);
    if (dosageValidation.isLeft()) return dosageValidation;

    // Validate frequency
    final frequencyValidation = validateFrequency(medication.frequency);
    if (frequencyValidation.isLeft()) return frequencyValidation;

    // Validate animal ID
    final animalIdValidation = validateAnimalId(medication.animalId);
    if (animalIdValidation.isLeft()) return animalIdValidation;

    // Validate start date
    final startDateValidation = validateStartDate(medication.startDate);
    if (startDateValidation.isLeft()) return startDateValidation;

    // Validate end date (if provided)
    final endDateValidation = validateEndDate(
      medication.startDate,
      medication.endDate,
    );
    if (endDateValidation.isLeft()) return endDateValidation;

    return const Right(null);
  }
}
