import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';

/// Service responsible for centralized error handling in promo repository operations
///
/// **SOLID Principles:**
/// - **Single Responsibility**: Only handles error handling logic
/// - **Open/Closed**: New error types can be handled without modifying existing code
/// - **Dependency Inversion**: Repository depends on this abstraction
///
/// **Benefits:**
/// - Eliminates repetitive try-catch blocks
/// - Consistent error logging across all operations
/// - Centralized error message formatting
/// - Easier to add new error handling strategies
class PromoErrorHandlingService {
  /// Executes an operation with automatic error handling
  ///
  /// Returns Either<Failure, T> where:
  /// - Right(T): Operation succeeded
  /// - Left(Failure): Operation failed with ServerFailure
  ///
  /// Automatically:
  /// - Wraps operation in try-catch
  /// - Converts exceptions to ServerFailure
  ///
  /// Example:
  /// ```dart
  /// return _errorHandlingService.executeOperation(
  ///   operation: () => _loadPromoContent(),
  ///   operationName: 'getPromoContent',
  /// );
  /// ```
  Future<Either<Failure, T>> executeOperation<T>({
    required Future<T> Function() operation,
    required String operationName,
  }) async {
    try {
      final result = await operation();
      return Right(result);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Falha ao $operationName: ${e.toString()}'),
      );
    }
  }

  /// Executes a void operation with automatic error handling
  ///
  /// Returns Either<Failure, void> where:
  /// - Right(null): Operation succeeded
  /// - Left(Failure): Operation failed with ServerFailure
  ///
  /// Example:
  /// ```dart
  /// return _errorHandlingService.executeVoidOperation(
  ///   operation: () => _submitEmail(email),
  ///   operationName: 'enviar pré-cadastro',
  /// );
  /// ```
  Future<Either<Failure, void>> executeVoidOperation({
    required Future<void> Function() operation,
    required String operationName,
  }) async {
    try {
      await operation();
      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Falha ao $operationName: ${e.toString()}'),
      );
    }
  }
}
