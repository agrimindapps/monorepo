import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

/// Service responsible for error handling in authentication operations
/// Follows Single Responsibility Principle - only handles error transformation
@lazySingleton
class AuthErrorHandlingService {
  final AuthLocalDataSource localDataSource;
  final AuthRemoteDataSource remoteDataSource;

  const AuthErrorHandlingService({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  /// Executes an authentication operation with standardized error handling
  Future<Either<Failure, User>> executeAuthOperation({
    required Future<UserModel> Function() operation,
    required String operationName,
  }) async {
    try {
      final user = await operation();
      await _cacheUser(user);
      return Right(user);
    } on ServerException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on CacheException catch (e) {
      return await _handleCacheException(e, operationName);
    } catch (e) {
      return Left(AuthFailure(message: 'Erro inesperado: $e'));
    }
  }

  /// Executes a void authentication operation with standardized error handling
  Future<Either<Failure, void>> executeVoidAuthOperation({
    required Future<void> Function() operation,
  }) async {
    try {
      await operation();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(AuthFailure(message: 'Erro inesperado: $e'));
    }
  }

  /// Executes a nullable user authentication operation
  Future<Either<Failure, User?>> executeNullableUserOperation({
    required Future<UserModel?> Function() operation,
  }) async {
    try {
      final user = await operation();
      if (user != null) {
        await _cacheUser(user);
      }
      return Right(user);
    } on ServerException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on CacheException catch (e) {
      // For getCurrentUser, cache failure is not critical
      try {
        final user = await remoteDataSource.getCurrentUser();
        return Right(user);
      } catch (_) {
        return Left(CacheFailure(message: e.message));
      }
    } catch (e) {
      return Left(AuthFailure(message: 'Erro inesperado: $e'));
    }
  }

  Future<void> _cacheUser(UserModel user) async {
    try {
      await localDataSource.cacheUser(user);
    } on CacheException {
      // Cache failure should not prevent successful authentication
      // Log the error but don't throw
    }
  }

  Future<Either<Failure, User>> _handleCacheException(
    CacheException e,
    String operationName,
  ) async {
    try {
      // Try to recover by fetching current user from remote
      final user = await remoteDataSource.getCurrentUser();
      if (user != null) {
        return Right(user);
      } else {
        return Left(AuthFailure(message: 'Falha na $operationName'));
      }
    } catch (_) {
      return Left(CacheFailure(message: e.message));
    }
  }
}
