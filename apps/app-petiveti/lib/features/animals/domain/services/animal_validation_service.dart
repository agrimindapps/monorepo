import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/animal.dart';

/// Service responsible for validating animal-related business rules.
///
/// **SOLID Principles:**
/// - **Single Responsibility**: Only validates animal data
/// - **Open/Closed**: New validations can be added without modifying existing ones
/// - **Dependency Inversion**: Used by use cases through abstraction
///
/// **Usage:**
/// ```dart
/// final validationResult = _validationService.validateForAdd(animal);
/// if (validationResult.isLeft()) return validationResult;
/// ```
class AnimalValidationService {
  /// Validates animal name
  ///
  /// **Rules:**
  /// - Cannot be empty
  /// - Cannot be only whitespace
  Either<Failure, void> validateName(String name) {
    if (name.trim().isEmpty) {
      return const Left(
        ValidationFailure(message: 'Nome do animal é obrigatório'),
      );
    }
    return const Right(null);
  }

  /// Validates animal species
  ///
  /// **Rules:**
  /// - Species name cannot be empty
  Either<Failure, void> validateSpecies(String speciesName) {
    if (speciesName.isEmpty) {
      return const Left(
        ValidationFailure(message: 'Espécie é obrigatória'),
      );
    }
    return const Right(null);
  }

  /// Validates animal weight
  ///
  /// **Rules:**
  /// - If provided, must be greater than zero
  Either<Failure, void> validateWeight(double? weight) {
    if (weight != null && weight <= 0) {
      return const Left(
        ValidationFailure(message: 'Peso deve ser maior que zero'),
      );
    }
    return const Right(null);
  }

  /// Validates animal ID
  ///
  /// **Rules:**
  /// - Cannot be empty
  /// - Cannot be only whitespace
  Either<Failure, void> validateId(String id) {
    if (id.trim().isEmpty) {
      return const Left(
        ValidationFailure(message: 'ID do animal é obrigatório'),
      );
    }
    return const Right(null);
  }

  /// Validates all fields for adding a new animal
  ///
  /// **Aggregates validations:**
  /// - Name
  /// - Species
  /// - Weight (if provided)
  Either<Failure, void> validateForAdd(Animal animal) {
    // Validate name
    final nameValidation = validateName(animal.name);
    if (nameValidation.isLeft()) return nameValidation;

    // Validate species
    final speciesValidation = validateSpecies(animal.species.name);
    if (speciesValidation.isLeft()) return speciesValidation;

    // Validate weight
    final weightValidation = validateWeight(animal.weight);
    if (weightValidation.isLeft()) return weightValidation;

    return const Right(null);
  }

  /// Validates all fields for updating an existing animal
  ///
  /// **Aggregates validations:**
  /// - Name
  /// - Species
  /// - Weight (if provided)
  Either<Failure, void> validateForUpdate(Animal animal) {
    // Same validation as add for now
    return validateForAdd(animal);
  }
}
