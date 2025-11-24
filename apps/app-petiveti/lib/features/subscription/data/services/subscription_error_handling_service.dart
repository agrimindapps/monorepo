import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';

/// Service responsible for handling errors in subscription repository operations
///
/// Following Single Responsibility Principle (SRP):
/// - Centralizes error handling logic for repository operations
/// - Converts exceptions to failures consistently
/// - Eliminates try-catch duplication across repository methods
class SubscriptionErrorHandlingService {
  /// Executes an operation with error handling
  ///
  /// Wraps repository operations and converts exceptions to failures
  /// Supports fallback operations for offline scenarios
  ///
  /// Returns [Right] with the result if successful
  /// Returns [Left] with a Failure if an error occurs
  Future<Either<Failure, T>> executeOperation<T>({
    required Future<T> Function() operation,
    Future<T> Function()? fallback,
    required String errorMessage,
  }) async {
    try {
      final result = await operation();
      return Right(result);
    } on ServerException catch (e) {
      if (fallback != null) {
        try {
          final fallbackResult = await fallback();
          return Right(fallbackResult);
        } on CacheException catch (cacheError) {
          return Left(CacheFailure(message: cacheError.message));
        }
      }
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: '$errorMessage: $e'));
    }
  }

  /// Executes a void operation with error handling
  ///
  /// Wraps void repository operations and converts exceptions to failures
  ///
  /// Returns [Right] with null if successful
  /// Returns [Left] with a Failure if an error occurs
  Future<Either<Failure, void>> executeVoidOperation({
    required Future<void> Function() operation,
    required String errorMessage,
  }) async {
    try {
      await operation();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: '$errorMessage: $e'));
    }
  }

  /// Executes an operation with custom error mapping
  ///
  /// Allows repository methods to provide custom error handling logic
  ///
  /// Returns [Right] with the result if successful
  /// Returns [Left] with a Failure if an error occurs
  Future<Either<Failure, T>> executeWithCustomErrorMapping<T>({
    required Future<T> Function() operation,
    required Failure Function(dynamic error) errorMapper,
  }) async {
    try {
      final result = await operation();
      return Right(result);
    } catch (e) {
      return Left(errorMapper(e));
    }
  }
}
