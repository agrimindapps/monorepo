// Package imports:
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

// Project imports:
import '../entities/overtime_calculation.dart';

/// Repository interface for overtime calculations
///
/// Follows Dependency Inversion Principle (DIP):
/// - Domain layer depends on abstraction (this interface)
/// - Data layer implements this abstraction
///
/// Uses Either<Failure, T> for functional error handling
abstract class OvertimeRepository {
  /// Saves an overtime calculation to local storage
  Future<Either<Failure, OvertimeCalculation>> saveCalculation(
    OvertimeCalculation calculation,
  );

  /// Retrieves calculation history from local storage
  Future<Either<Failure, List<OvertimeCalculation>>> getCalculationHistory({
    int limit = 10,
  });

  /// Retrieves a specific calculation by ID
  Future<Either<Failure, OvertimeCalculation>> getCalculationById(String id);

  /// Deletes a specific calculation from local storage
  Future<Either<Failure, void>> deleteCalculation(String id);

  /// Clears all calculation history from local storage
  Future<Either<Failure, void>> clearHistory();
}
