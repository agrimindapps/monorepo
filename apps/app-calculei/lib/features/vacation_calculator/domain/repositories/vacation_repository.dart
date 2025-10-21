import 'package:core/core.dart';

import '../entities/vacation_calculation.dart';

/// Repository interface for vacation calculations
///
/// Defines contracts for persisting and retrieving vacation calculations.
/// Implementations should handle both local (Hive) and remote (Firebase) storage.
abstract class VacationRepository {
  /// Save a vacation calculation to storage
  Future<Either<Failure, VacationCalculation>> saveCalculation(
    VacationCalculation calculation,
  );

  /// Get calculation history (last N calculations)
  Future<Either<Failure, List<VacationCalculation>>> getCalculationHistory({
    int limit = 10,
  });

  /// Get a specific calculation by ID
  Future<Either<Failure, VacationCalculation>> getCalculationById(String id);

  /// Delete a calculation
  Future<Either<Failure, void>> deleteCalculation(String id);

  /// Clear all calculation history
  Future<Either<Failure, void>> clearHistory();
}
