// Package imports:
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

// Project imports:
import '../entities/thirteenth_salary_calculation.dart';
import '../repositories/thirteenth_salary_repository.dart';

/// Use case for retrieving 13th salary calculation history
///
/// Follows Single Responsibility Principle (SRP):
/// - Only responsible for orchestrating the history retrieval
/// - Delegates actual retrieval to repository
class GetThirteenthSalaryCalculationHistoryUseCase {
  final ThirteenthSalaryRepository _repository;

  GetThirteenthSalaryCalculationHistoryUseCase(this._repository);

  /// Retrieves calculation history
  ///
  /// Parameters:
  /// - [limit]: Maximum number of calculations to retrieve (default: 10)
  ///
  /// Returns:
  /// - Right(List<calculation>) if retrieved successfully
  /// - Left(CacheFailure) if retrieval fails
  Future<Either<Failure, List<ThirteenthSalaryCalculation>>> call({
    int limit = 10,
  }) async {
    return _repository.getCalculationHistory(limit: limit);
  }
}
