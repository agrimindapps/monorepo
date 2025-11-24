import 'package:core/core.dart' hide Column;

import '../entities/plant.dart';

/// Service responsible for validating Plant data
/// Centralizes validation logic following Single Responsibility Principle (SRP)
class PlantValidator {
  /// Validate plant ID
  Either<ValidationFailure, Unit> validateId(String id) {
    if (id.trim().isEmpty) {
      return const Left(ValidationFailure('ID da planta é obrigatório'));
    }
    return const Right(unit);
  }

  /// Validate plant name
  Either<ValidationFailure, Unit> validateName(String name) {
    final trimmedName = name.trim();
    
    if (trimmedName.isEmpty) {
      return const Left(ValidationFailure('Nome da planta é obrigatório'));
    }
    
    if (trimmedName.length > 100) {
      return const Left(
        ValidationFailure('Nome muito longo (máximo 100 caracteres)'),
      );
    }
    
    return const Right(unit);
  }

  /// Validate species (optional field)
  Either<ValidationFailure, Unit> validateSpecies(String? species) {
    if (species != null && species.trim().isNotEmpty) {
      if (species.length > 150) {
        return const Left(
          ValidationFailure('Espécie muito longa (máximo 150 caracteres)'),
        );
      }
    }
    return const Right(unit);
  }

  /// Validate notes (optional field)
  Either<ValidationFailure, Unit> validateNotes(String? notes) {
    if (notes != null && notes.trim().isNotEmpty) {
      if (notes.length > 1000) {
        return const Left(
          ValidationFailure('Notas muito longas (máximo 1000 caracteres)'),
        );
      }
    }
    return const Right(unit);
  }

  /// Validate planting date (optional field)
  Either<ValidationFailure, Unit> validatePlantingDate(DateTime? plantingDate) {
    if (plantingDate != null) {
      final now = DateTime.now();
      
      // Check if date is not in the future
      if (plantingDate.isAfter(now)) {
        return const Left(
          ValidationFailure('Data de plantio não pode ser no futuro'),
        );
      }
      
      // Check if date is not too far in the past (e.g., 100 years)
      final hundredYearsAgo = now.subtract(const Duration(days: 36500));
      if (plantingDate.isBefore(hundredYearsAgo)) {
        return const Left(
          ValidationFailure('Data de plantio muito antiga'),
        );
      }
    }
    return const Right(unit);
  }

  /// Validate watering interval days
  Either<ValidationFailure, Unit> validateWateringInterval(int? days) {
    if (days != null) {
      if (days <= 0) {
        return const Left(
          ValidationFailure('Intervalo de rega deve ser maior que zero'),
        );
      }
      if (days > 365) {
        return const Left(
          ValidationFailure('Intervalo de rega muito longo (máximo 365 dias)'),
        );
      }
    }
    return const Right(unit);
  }

  /// Validate complete plant entity
  Either<ValidationFailure, Unit> validatePlant(Plant plant) {
    return validateId(plant.id).flatMap(
      (_) => validateName(plant.name).flatMap(
        (_) => validateSpecies(plant.species).flatMap(
          (_) => validateNotes(plant.notes).flatMap(
            (_) => validatePlantingDate(plant.plantingDate).flatMap(
              (_) => validateWateringInterval(
                plant.config?.wateringIntervalDays,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Validate plant for creation (stricter validation)
  Either<ValidationFailure, Unit> validatePlantForCreation(Plant plant) {
    // For creation, name is mandatory
    final nameValidation = validateName(plant.name);
    if (nameValidation.isLeft()) {
      return nameValidation;
    }
    
    // Then validate the complete plant
    return validatePlant(plant);
  }

  /// Validate plant for update
  Either<ValidationFailure, Unit> validatePlantForUpdate(Plant plant) {
    // For update, ID must be present
    final idValidation = validateId(plant.id);
    if (idValidation.isLeft()) {
      return idValidation;
    }
    
    // Then validate the complete plant
    return validatePlant(plant);
  }
}

/// Extension to add flatMap to Either for chaining validations
extension EitherValidationExtension on Either<ValidationFailure, Unit> {
  Either<ValidationFailure, Unit> flatMap(
    Either<ValidationFailure, Unit> Function(Unit) f,
  ) {
    return fold(
      (failure) => Left(failure),
      (unit) => f(unit),
    );
  }
}
