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
  /// - Must have at least 2 characters
  /// - Must have at most 50 characters
  Either<Failure, void> validateName(String name) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return const Left(
        ValidationFailure(message: 'Nome do animal é obrigatório'),
      );
    }
    if (trimmedName.length < 2) {
      return const Left(
        ValidationFailure(message: 'Nome deve ter pelo menos 2 caracteres'),
      );
    }
    if (trimmedName.length > 50) {
      return const Left(
        ValidationFailure(message: 'Nome deve ter no máximo 50 caracteres'),
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
  /// - If provided, must be less than 500kg (reasonable max for any pet)
  Either<Failure, void> validateWeight(double? weight) {
    if (weight != null) {
      if (weight <= 0) {
        return const Left(
          ValidationFailure(message: 'Peso deve ser maior que zero'),
        );
      }
      if (weight > 500) {
        return const Left(
          ValidationFailure(message: 'Peso deve ser menor que 500kg'),
        );
      }
    }
    return const Right(null);
  }

  /// Validates animal birth date
  ///
  /// **Rules:**
  /// - Cannot be in the future
  /// - Cannot be more than 50 years in the past (reasonable max age)
  Either<Failure, void> validateBirthDate(DateTime? birthDate) {
    if (birthDate != null) {
      final now = DateTime.now();
      if (birthDate.isAfter(now)) {
        return const Left(
          ValidationFailure(message: 'Data de nascimento não pode ser no futuro'),
        );
      }
      final minDate = now.subtract(const Duration(days: 365 * 50));
      if (birthDate.isBefore(minDate)) {
        return const Left(
          ValidationFailure(message: 'Data de nascimento inválida'),
        );
      }
    }
    return const Right(null);
  }

  /// Validates animal breed
  ///
  /// **Rules:**
  /// - If provided, must have at least 2 characters
  /// - Must have at most 100 characters
  Either<Failure, void> validateBreed(String? breed) {
    if (breed != null && breed.trim().isNotEmpty) {
      if (breed.trim().length < 2) {
        return const Left(
          ValidationFailure(message: 'Raça deve ter pelo menos 2 caracteres'),
        );
      }
      if (breed.trim().length > 100) {
        return const Left(
          ValidationFailure(message: 'Raça deve ter no máximo 100 caracteres'),
        );
      }
    }
    return const Right(null);
  }

  /// Validates microchip number
  ///
  /// **Rules:**
  /// - If provided, must have between 9 and 15 characters (ISO standard)
  Either<Failure, void> validateMicrochip(String? microchip) {
    if (microchip != null && microchip.trim().isNotEmpty) {
      final trimmed = microchip.trim();
      if (trimmed.length < 9 || trimmed.length > 15) {
        return const Left(
          ValidationFailure(
            message: 'Número do microchip deve ter entre 9 e 15 caracteres',
          ),
        );
      }
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
  /// - Birth date (if provided)
  /// - Breed (if provided)
  /// - Microchip (if provided)
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

    // Validate birth date
    final birthDateValidation = validateBirthDate(animal.birthDate);
    if (birthDateValidation.isLeft()) return birthDateValidation;

    // Validate breed
    final breedValidation = validateBreed(animal.breed);
    if (breedValidation.isLeft()) return breedValidation;

    // Validate microchip
    final microchipValidation = validateMicrochip(animal.microchipNumber);
    if (microchipValidation.isLeft()) return microchipValidation;

    return const Right(null);
  }

  /// Validates all fields for updating an existing animal
  ///
  /// **Aggregates validations:**
  /// - All add validations
  /// - ID validation
  Either<Failure, void> validateForUpdate(Animal animal) {
    // Validate ID for updates
    final idValidation = validateId(animal.id);
    if (idValidation.isLeft()) return idValidation;

    // Same validation as add
    return validateForAdd(animal);
  }
}
