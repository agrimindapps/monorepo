import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/weight.dart';

/// Service responsible for weight-related validations
///
/// **SOLID Principles:**
/// - **Single Responsibility**: Only handles weight validation logic
/// - **Open/Closed**: New validation rules can be added without modifying existing code
class WeightValidationService {
  const WeightValidationService();

  /// Validates weight value
  ///
  /// **Rules:**
  /// - Must be greater than 0
  /// - Must be less than or equal to 500 kg (reasonable max for any pet)
  Either<Failure, double> validateWeight(double weight) {
    if (weight <= 0) {
      return const Left(
        ValidationFailure(message: 'Peso deve ser maior que zero'),
      );
    }

    if (weight > 500) {
      return const Left(
        ValidationFailure(message: 'Peso muito alto. Verifique o valor'),
      );
    }

    return Right(weight);
  }

  /// Validates animal ID
  ///
  /// **Rules:**
  /// - Cannot be empty
  Either<Failure, String> validateAnimalId(String animalId) {
    if (animalId.trim().isEmpty) {
      return const Left(
        ValidationFailure(message: 'Animal deve ser selecionado'),
      );
    }

    return Right(animalId.trim());
  }

  /// Validates weight ID
  ///
  /// **Rules:**
  /// - Cannot be empty
  Either<Failure, String> validateId(String id) {
    if (id.trim().isEmpty) {
      return const Left(
        ValidationFailure(message: 'ID do registro é obrigatório'),
      );
    }

    return Right(id.trim());
  }

  /// Validates weight date
  ///
  /// **Rules:**
  /// - Cannot be in the future
  /// - Cannot be more than 5 years in the past
  Either<Failure, DateTime> validateDate(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    if (date.isAfter(tomorrow)) {
      return const Left(
        ValidationFailure(message: 'Data do registro não pode ser futura'),
      );
    }

    final fiveYearsAgo = DateTime.now().subtract(const Duration(days: 365 * 5));
    if (date.isBefore(fiveYearsAgo)) {
      return const Left(
        ValidationFailure(
          message: 'Data do registro não pode ser superior a 5 anos no passado',
        ),
      );
    }

    return Right(date);
  }

  /// Validates body condition score
  ///
  /// **Rules:**
  /// - If provided, must be between 1 and 9
  Either<Failure, void> validateBodyConditionScore(int? score) {
    if (score == null) return const Right(null);

    if (score < 1 || score > 9) {
      return const Left(
        ValidationFailure(
          message: 'Condição corporal deve estar entre 1 e 9',
        ),
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
        ValidationFailure(
          message: 'Observações devem ter no máximo 500 caracteres',
        ),
      );
    }

    return const Right(null);
  }

  /// Validates complete weight for adding
  Either<Failure, Weight> validateForAdd(Weight weight) {
    // Validate weight value
    final weightValidation = validateWeight(weight.weight);
    if (weightValidation.isLeft()) {
      return weightValidation.fold(
        (failure) => Left(failure),
        (_) => throw UnimplementedError(),
      );
    }

    // Validate animal ID
    final animalIdValidation = validateAnimalId(weight.animalId);
    if (animalIdValidation.isLeft()) {
      return animalIdValidation.fold(
        (failure) => Left(failure),
        (_) => throw UnimplementedError(),
      );
    }

    // Validate date
    final dateValidation = validateDate(weight.date);
    if (dateValidation.isLeft()) {
      return dateValidation.fold(
        (failure) => Left(failure),
        (_) => throw UnimplementedError(),
      );
    }

    // Validate body condition score
    final bcsValidation = validateBodyConditionScore(weight.bodyConditionScore);
    if (bcsValidation.isLeft()) {
      return bcsValidation.fold(
        (failure) => Left(failure),
        (_) => throw UnimplementedError(),
      );
    }

    // Validate notes
    final notesValidation = validateNotes(weight.notes);
    if (notesValidation.isLeft()) {
      return notesValidation.fold(
        (failure) => Left(failure),
        (_) => throw UnimplementedError(),
      );
    }

    return Right(weight);
  }

  /// Validates complete weight for updating
  Either<Failure, Weight> validateForUpdate(Weight weight) {
    // Validate ID first
    final idValidation = validateId(weight.id);
    if (idValidation.isLeft()) {
      return idValidation.fold(
        (failure) => Left(failure),
        (_) => throw UnimplementedError(),
      );
    }

    return validateForAdd(weight);
  }

  /// Validates if weight change is concerning (rapid or excessive)
  ///
  /// Returns a warning message if concerning, null otherwise
  String? validateWeightChange(Weight current, Weight? previous) {
    if (previous == null) return null;

    final diff = current.calculateDifference(previous);
    if (diff == null) return null;

    // Rapid weight loss (more than 10% in less than 30 days)
    if (diff.percentageChange < -10 && diff.daysDifference < 30) {
      return 'Alerta: Perda de peso rápida detectada (${diff.formattedPercentage} em ${diff.daysDifference} dias)';
    }

    // Rapid weight gain (more than 15% in less than 30 days)
    if (diff.percentageChange > 15 && diff.daysDifference < 30) {
      return 'Alerta: Ganho de peso rápido detectado (${diff.formattedPercentage} em ${diff.daysDifference} dias)';
    }

    return null;
  }
}
