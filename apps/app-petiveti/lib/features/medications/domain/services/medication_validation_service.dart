import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/medication.dart';

/// Service responsible for validating medication-related business rules.
///
/// **SOLID Principles:**
/// - **Single Responsibility**: Only validates medication data
/// - **Open/Closed**: New validations can be added without modifying existing ones
/// - **Dependency Inversion**: Used by use cases through abstraction
class MedicationValidationService {
  /// Validates medication name
  ///
  /// **Rules:**
  /// - Cannot be empty
  /// - Must have at least 2 characters
  /// - Must have at most 100 characters
  Either<Failure, void> validateName(String name) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return const Left(
        ValidationFailure(message: 'Nome do medicamento é obrigatório'),
      );
    }
    if (trimmedName.length < 2) {
      return const Left(
        ValidationFailure(message: 'Nome deve ter pelo menos 2 caracteres'),
      );
    }
    if (trimmedName.length > 100) {
      return const Left(
        ValidationFailure(message: 'Nome deve ter no máximo 100 caracteres'),
      );
    }
    return const Right(null);
  }

  /// Validates medication dosage
  ///
  /// **Rules:**
  /// - Cannot be empty
  /// - Must have at most 100 characters
  Either<Failure, void> validateDosage(String dosage) {
    final trimmedDosage = dosage.trim();
    if (trimmedDosage.isEmpty) {
      return const Left(
        ValidationFailure(message: 'Dosagem é obrigatória'),
      );
    }
    if (trimmedDosage.length > 100) {
      return const Left(
        ValidationFailure(message: 'Dosagem deve ter no máximo 100 caracteres'),
      );
    }
    return const Right(null);
  }

  /// Validates medication frequency
  ///
  /// **Rules:**
  /// - Cannot be empty
  /// - Must have at most 100 characters
  Either<Failure, void> validateFrequency(String frequency) {
    final trimmedFrequency = frequency.trim();
    if (trimmedFrequency.isEmpty) {
      return const Left(
        ValidationFailure(message: 'Frequência é obrigatória'),
      );
    }
    if (trimmedFrequency.length > 100) {
      return const Left(
        ValidationFailure(message: 'Frequência deve ter no máximo 100 caracteres'),
      );
    }
    return const Right(null);
  }

  /// Validates duration
  ///
  /// **Rules:**
  /// - If provided, must have at most 50 characters
  Either<Failure, void> validateDuration(String? duration) {
    if (duration == null || duration.trim().isEmpty) return const Right(null);
    
    if (duration.trim().length > 50) {
      return const Left(
        ValidationFailure(message: 'Duração deve ter no máximo 50 caracteres'),
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

  /// Validates medication ID
  ///
  /// **Rules:**
  /// - Cannot be empty
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
  /// - Cannot be more than 1 year in the past
  Either<Failure, void> validateStartDate(DateTime? startDate) {
    if (startDate == null) {
      return const Left(
        ValidationFailure(message: 'Data de início é obrigatória'),
      );
    }
    
    final minDate = DateTime.now().subtract(const Duration(days: 365));
    if (startDate.isBefore(minDate)) {
      return const Left(
        ValidationFailure(message: 'Data de início não pode ser superior a 1 ano no passado'),
      );
    }
    
    return const Right(null);
  }

  /// Validates end date
  ///
  /// **Rules:**
  /// - Must be after start date
  /// - Cannot be more than 2 years in the future
  Either<Failure, void> validateEndDate(DateTime? startDate, DateTime? endDate) {
    if (endDate == null || startDate == null) return const Right(null);
    
    if (endDate.isBefore(startDate) || endDate.isAtSameMomentAs(startDate)) {
      return const Left(
        ValidationFailure(
          message: 'Data de término deve ser posterior à data de início',
        ),
      );
    }
    
    final maxDate = DateTime.now().add(const Duration(days: 365 * 2));
    if (endDate.isAfter(maxDate)) {
      return const Left(
        ValidationFailure(
          message: 'Data de término não pode ser superior a 2 anos no futuro',
        ),
      );
    }
    
    // Validate treatment duration (max 1 year)
    final treatmentDays = endDate.difference(startDate).inDays;
    if (treatmentDays > 365) {
      return const Left(
        ValidationFailure(
          message: 'Duração do tratamento não pode exceder 1 ano',
        ),
      );
    }
    
    return const Right(null);
  }

  /// Validates prescriber name
  ///
  /// **Rules:**
  /// - If provided, must have at least 2 characters
  /// - Must have at most 100 characters
  Either<Failure, void> validatePrescribedBy(String? prescribedBy) {
    if (prescribedBy == null || prescribedBy.trim().isEmpty) {
      return const Right(null);
    }
    
    final trimmed = prescribedBy.trim();
    if (trimmed.length < 2) {
      return const Left(
        ValidationFailure(message: 'Nome do prescritor deve ter pelo menos 2 caracteres'),
      );
    }
    if (trimmed.length > 100) {
      return const Left(
        ValidationFailure(message: 'Nome do prescritor deve ter no máximo 100 caracteres'),
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

  /// Validates discontinuation reason
  ///
  /// **Rules:**
  /// - Cannot be empty
  /// - Must have at most 200 characters
  Either<Failure, void> validateDiscontinuationReason(String reason) {
    final trimmed = reason.trim();
    if (trimmed.isEmpty) {
      return const Left(
        ValidationFailure(message: 'Motivo da descontinuação é obrigatório'),
      );
    }
    if (trimmed.length > 200) {
      return const Left(
        ValidationFailure(message: 'Motivo deve ter no máximo 200 caracteres'),
      );
    }
    return const Right(null);
  }

  /// Validates all fields for adding a new medication
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

    // Validate duration
    final durationValidation = validateDuration(medication.duration);
    if (durationValidation.isLeft()) return durationValidation;

    // Validate animal ID
    final animalIdValidation = validateAnimalId(medication.animalId);
    if (animalIdValidation.isLeft()) return animalIdValidation;

    // Validate start date
    final startDateValidation = validateStartDate(medication.startDate);
    if (startDateValidation.isLeft()) return startDateValidation;

    // Validate end date
    final endDateValidation = validateEndDate(
      medication.startDate,
      medication.endDate,
    );
    if (endDateValidation.isLeft()) return endDateValidation;

    // Validate prescribed by
    final prescribedByValidation = validatePrescribedBy(medication.prescribedBy);
    if (prescribedByValidation.isLeft()) return prescribedByValidation;

    // Validate notes
    final notesValidation = validateNotes(medication.notes);
    if (notesValidation.isLeft()) return notesValidation;

    return const Right(null);
  }

  /// Validates all fields for updating an existing medication
  Either<Failure, void> validateForUpdate(Medication medication) {
    // Validate ID
    final idValidation = validateId(medication.id);
    if (idValidation.isLeft()) return idValidation;

    return validateForAdd(medication);
  }
}
