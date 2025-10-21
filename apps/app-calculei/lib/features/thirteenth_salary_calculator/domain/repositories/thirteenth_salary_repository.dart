// Package imports:
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

// Project imports:
import '../entities/thirteenth_salary_calculation.dart';

/// Repository interface for 13th salary calculations
///
/// Follows Dependency Inversion Principle (DIP):
/// - Domain layer depends on abstraction (this interface)
/// - Data layer implements this abstraction
///
/// Uses Either<Failure, T> for functional error handling
abstract class ThirteenthSalaryRepository {
  /// Saves a 13th salary calculation to local storage
  ///
  /// Returns:
  /// - Right(calculation) if saved successfully
  /// - Left(CacheFailure) if save operation fails
  Future<Either<Failure, ThirteenthSalaryCalculation>> saveCalculation(
    ThirteenthSalaryCalculation calculation,
  );

  /// Retrieves calculation history from local storage
  ///
  /// Parameters:
  /// - [limit]: Maximum number of calculations to retrieve (default: 10)
  ///
  /// Returns:
  /// - Right(List<calculation>) if retrieved successfully
  /// - Left(CacheFailure) if retrieval fails
  Future<Either<Failure, List<ThirteenthSalaryCalculation>>> getCalculationHistory({
    int limit = 10,
  });

  /// Retrieves a specific calculation by ID
  ///
  /// Parameters:
  /// - [id]: Unique identifier of the calculation
  ///
  /// Returns:
  /// - Right(calculation) if found
  /// - Left(CacheFailure) if not found or retrieval fails
  Future<Either<Failure, ThirteenthSalaryCalculation>> getCalculationById(
    String id,
  );

  /// Deletes a specific calculation from local storage
  ///
  /// Parameters:
  /// - [id]: Unique identifier of the calculation to delete
  ///
  /// Returns:
  /// - Right(void) if deleted successfully
  /// - Left(CacheFailure) if deletion fails
  Future<Either<Failure, void>> deleteCalculation(String id);

  /// Clears all calculation history from local storage
  ///
  /// Returns:
  /// - Right(void) if cleared successfully
  /// - Left(CacheFailure) if operation fails
  Future<Either<Failure, void>> clearHistory();
}
