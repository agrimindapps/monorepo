import 'package:core/core.dart';

import '../../../../core/error/exceptions.dart' as local_exceptions;

/// Mixin para tratamento de erros em repositórios
///
/// Responsabilidade: Padronizar tratamento de exceções e conversão para Failures
/// Aplica DRY (Don't Repeat Yourself) e Template Method Pattern
mixin RepositoryErrorHandler {
  /// Template method para executar operações com tratamento de erros padronizado
  Future<Either<Failure, T>> executeOperation<T>(
    Future<T> Function() operation, {
    Future<T?> Function()? fallback,
  }) async {
    try {
      final result = await operation();
      return Right(result);
    } on local_exceptions.AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on local_exceptions.ServerException catch (e) {
      // Tenta fallback se disponível
      if (fallback != null) {
        try {
          final fallbackResult = await fallback();
          if (fallbackResult != null) {
            return Right(fallbackResult as T);
          }
        } catch (_) {
          // Ignora erro de fallback
        }
      }
      return Left(ServerFailure(e.message));
    } on local_exceptions.CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// Template method para operações void (que retornam Unit)
  Future<Either<Failure, Unit>> executeVoidOperation(
    Future<void> Function() operation,
  ) async {
    try {
      await operation();
      return const Right(unit);
    } on local_exceptions.AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on local_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on local_exceptions.CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// Template method para operações com cache
  Future<Either<Failure, T>> executeWithCache<T>({
    required Future<T> Function() remoteOperation,
    required Future<void> Function(T data) cacheOperation,
  }) async {
    try {
      final result = await remoteOperation();
      await cacheOperation(result);
      return Right(result);
    } on local_exceptions.AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on local_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on local_exceptions.CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
