import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/expense_summary.dart';

/// Service responsible for error handling in expense operations
/// Follows Single Responsibility Principle - only handles error transformation
@lazySingleton
class ExpenseErrorHandlingService {
  const ExpenseErrorHandlingService();

  /// Executes an expense operation with standardized error handling
  Future<Either<Failure, T>> executeOperation<T>({
    required Future<T> Function() operation,
    required String operationName,
  }) async {
    try {
      final result = await operation();
      return Right(result);
    } catch (e) {
      return Left(
        CacheFailure(message: 'Erro ao $operationName: ${e.toString()}'),
      );
    }
  }

  /// Executes a void expense operation with standardized error handling
  Future<Either<Failure, void>> executeVoidOperation({
    required Future<void> Function() operation,
    required String operationName,
  }) async {
    try {
      await operation();
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(message: 'Erro ao $operationName: ${e.toString()}'),
      );
    }
  }

  /// Executes a list expense operation with standardized error handling
  Future<Either<Failure, List<Expense>>> executeListOperation({
    required Future<List<Expense>> Function() operation,
    required String operationName,
  }) async {
    try {
      final result = await operation();
      return Right(result);
    } catch (e) {
      return Left(
        CacheFailure(message: 'Erro ao $operationName: ${e.toString()}'),
      );
    }
  }

  /// Executes a summary operation with standardized error handling
  Future<Either<Failure, ExpenseSummary>> executeSummaryOperation({
    required Future<ExpenseSummary> Function() operation,
    required String operationName,
  }) async {
    try {
      final result = await operation();
      return Right(result);
    } catch (e) {
      return Left(
        CacheFailure(message: 'Erro ao $operationName: ${e.toString()}'),
      );
    }
  }
}
