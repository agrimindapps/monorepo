// Package imports:
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

// Project imports:
import '../entities/thirteenth_salary_calculation.dart';
import '../repositories/thirteenth_salary_repository.dart';

/// Use case for saving a 13th salary calculation to local storage
///
/// Follows Single Responsibility Principle (SRP):
/// - Only responsible for orchestrating the save operation
/// - Delegates actual storage to repository
class SaveThirteenthSalaryCalculationUseCase {
  final ThirteenthSalaryRepository _repository;

  SaveThirteenthSalaryCalculationUseCase(this._repository);

  /// Saves a 13th salary calculation
  ///
  /// Returns:
  /// - Right(calculation) if saved successfully
  /// - Left(CacheFailure) if save operation fails
  Future<Either<Failure, ThirteenthSalaryCalculation>> call(
    ThirteenthSalaryCalculation calculation,
  ) async {
    return _repository.saveCalculation(calculation);
  }
}
