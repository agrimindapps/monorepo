import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart' as local_failures;

/// Service responsible for standardizing error handling in animal repository operations.
///
/// **SOLID Principles:**
/// - **Single Responsibility**: Only handles error conversion and logging
/// - **Open/Closed**: New error types can be added without modifying existing code
/// - **Dependency Inversion**: Used by repository through abstraction
///
/// **Benefits:**
/// - Eliminates repetitive try-catch blocks
/// - Centralizes error logging logic
/// - Consistent error messages across all repository methods
/// - Easier to modify error handling strategy
///
/// **Usage:**
/// ```dart
/// return await _errorHandlingService.executeOperation(
///   operation: () => _localDataSource.getAnimals(),
///   errorMessage: 'Failed to get animals',
///   isCache: true,
/// );
/// ```
class AnimalErrorHandlingService {
  /// Executes an operation that returns data, handling errors automatically
  ///
  /// **Parameters:**
  /// - `operation`: The async operation to execute
  /// - `errorMessage`: Custom error message for failures
  /// - `isCache`: If true, returns CacheFailure; otherwise ServerFailure
  ///
  /// **Returns:**
  /// - `Right(T)`: Operation succeeded with result
  /// - `Left(Failure)`: Operation failed with appropriate failure type
  Future<Either<local_failures.Failure, T>> executeOperation<T>({
    required Future<T> Function() operation,
    required String errorMessage,
    bool isCache = false,
  }) async {
    try {
      final result = await operation();
      return Right(result);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[AnimalErrorHandling] $errorMessage: $e');
        debugPrint('Stack trace: $stackTrace');
      }

      final failure = isCache
          ? local_failures.CacheFailure(message: '$errorMessage: $e')
          : local_failures.ServerFailure(message: '$errorMessage: $e');

      return Left(failure);
    }
  }

  /// Executes a void operation, handling errors automatically
  ///
  /// **Parameters:**
  /// - `operation`: The async operation to execute
  /// - `errorMessage`: Custom error message for failures
  /// - `isCache`: If true, returns CacheFailure; otherwise ServerFailure
  ///
  /// **Returns:**
  /// - `Right(null)`: Operation succeeded
  /// - `Left(Failure)`: Operation failed with appropriate failure type
  Future<Either<local_failures.Failure, void>> executeVoidOperation({
    required Future<void> Function() operation,
    required String errorMessage,
    bool isCache = false,
  }) async {
    try {
      await operation();
      return const Right(null);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[AnimalErrorHandling] $errorMessage: $e');
        debugPrint('Stack trace: $stackTrace');
      }

      final failure = isCache
          ? local_failures.CacheFailure(message: '$errorMessage: $e')
          : local_failures.ServerFailure(message: '$errorMessage: $e');

      return Left(failure);
    }
  }

  /// Executes an operation with custom validation logic
  ///
  /// **Parameters:**
  /// - `operation`: The async operation to execute
  /// - `validator`: Function to validate the result
  /// - `errorMessage`: Custom error message for failures
  /// - `isCache`: If true, returns CacheFailure; otherwise ServerFailure
  ///
  /// **Returns:**
  /// - `Right(T)`: Operation succeeded and passed validation
  /// - `Left(Failure)`: Operation failed or validation failed
  Future<Either<local_failures.Failure, T>> executeWithValidation<T>({
    required Future<T> Function() operation,
    required Either<local_failures.Failure, void> Function(T) validator,
    required String errorMessage,
    bool isCache = false,
  }) async {
    try {
      final result = await operation();

      final validation = validator(result);
      if (validation.isLeft()) {
        return validation.fold(
          (failure) => Left(failure),
          (_) => Right(result), // Never reached
        );
      }

      return Right(result);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[AnimalErrorHandling] $errorMessage: $e');
        debugPrint('Stack trace: $stackTrace');
      }

      final failure = isCache
          ? local_failures.CacheFailure(message: '$errorMessage: $e')
          : local_failures.ServerFailure(message: '$errorMessage: $e');

      return Left(failure);
    }
  }
}
