import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/logging_service.dart';
import '../../../../core/logging/entities/log_entry.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../services/auth_error_handling_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;
  final AuthRemoteDataSource remoteDataSource;
  final AuthErrorHandlingService errorHandlingService;
  final ILoggingService loggingService;
  StreamSubscription<User?>? _authStateSubscription;

  AuthRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.errorHandlingService,
    required this.loggingService,
  });

  // Helper methods to replace mixin
  Future<T> logTimedOperation<T>({
    required String context,
    required String operation,
    required String message,
    required Future<T> Function() operationFunction,
    Map<String, dynamic>? metadata,
  }) async {
    return await loggingService.logTimedOperation<T>(
      context: context,
      operation: operation,
      message: message,
      operationFunction: operationFunction,
      metadata: metadata,
    );
  }

  Future<void> logOperationStart({
    required String context,
    required String operation,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    await loggingService.logInfo(
      context: context,
      operation: operation,
      message: 'Starting $message',
      metadata: metadata,
    );
  }

  Future<void> logOperationSuccess({
    required String context,
    required String operation,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    await loggingService.logInfo(
      context: context,
      operation: operation,
      message: 'Successfully completed $message',
      metadata: metadata,
    );
  }

  Future<void> logOperationError({
    required String context,
    required String operation,
    required String message,
    required dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) async {
    await loggingService.logError(
      context: context,
      operation: operation,
      message: 'Failed to $message',
      error: error,
      stackTrace: stackTrace,
      metadata: metadata,
    );
  }

  Future<void> logLocalStorageOperation({
    required String context,
    required String operation,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    await loggingService.logInfo(
      context: 'storage',
      operation: operation,
      message: 'Local storage: $message',
      metadata: {'original_context': context, ...?metadata},
    );
  }

  @override
  Future<Either<Failure, User>> signInWithEmail(
      String email, String password) async {
    return await logTimedOperation<Either<Failure, User>>(
      context: LogCategory.auth.name,
      operation: LogOperation.login.name,
      message: 'sign in with email',
      metadata: {'email': email, 'method': 'email'},
      operationFunction: () async {
        try {
          await logOperationStart(
            context: LogCategory.auth.name,
            operation: LogOperation.login.name,
            message: 'authenticating user with email',
            metadata: {'email': email},
          );

          final user = await remoteDataSource.signInWithEmail(email, password);

          await logLocalStorageOperation(
            context: LogCategory.auth.name,
            operation: LogOperation.create.name,
            message: 'caching user session',
            metadata: {'user_id': user.id, 'email': user.email},
          );

          await localDataSource.cacheUser(user);

          await logOperationSuccess(
            context: LogCategory.auth.name,
            operation: LogOperation.login.name,
            message: 'sign in with email',
            metadata: {'user_id': user.id, 'email': user.email},
          );

          return Right(user);
        } on ServerException catch (e, stackTrace) {
          await logOperationError(
            context: LogCategory.auth.name,
            operation: LogOperation.login.name,
            message: 'sign in with email - server error',
            error: e,
            stackTrace: stackTrace,
            metadata: {'email': email},
          );
          return Left(AuthFailure(message: e.message));
        } on CacheException catch (e, stackTrace) {
          await logOperationError(
            context: LogCategory.auth.name,
            operation: LogOperation.create.name,
            message: 'failed to cache user session',
            error: e,
            stackTrace: stackTrace,
            metadata: {'email': email},
          );
          try {
            final user = await remoteDataSource.getCurrentUser();
            if (user != null) {
              await logOperationSuccess(
                context: LogCategory.auth.name,
                operation: LogOperation.login.name,
                message: 'sign in with email (cache failed but auth succeeded)',
                metadata: {'user_id': user.id, 'cache_failed': true},
              );
              return Right(user);
            } else {
              return const Left(AuthFailure(message: 'Falha na autenticação'));
            }
          } catch (_) {
            return Left(CacheFailure(message: e.message));
          }
        } catch (e, stackTrace) {
          await logOperationError(
            context: LogCategory.auth.name,
            operation: LogOperation.login.name,
            message: 'sign in with email - unexpected error',
            error: e,
            stackTrace: stackTrace,
            metadata: {'email': email},
          );
          return Left(AuthFailure(message: 'Erro inesperado: $e'));
        }
      },
    );
  }

  @override
  Future<Either<Failure, User>> signUpWithEmail(
      String email, String password, String? name) async {
    return errorHandlingService.executeAuthOperation(
      operation: () => remoteDataSource.signUpWithEmail(email, password, name),
      operationName: 'criação da conta',
    );
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    return errorHandlingService.executeAuthOperation(
      operation: () => remoteDataSource.signInWithGoogle(),
      operationName: 'login com Google',
    );
  }

  @override
  Future<Either<Failure, User>> signInWithApple() async {
    return errorHandlingService.executeAuthOperation(
      operation: () => remoteDataSource.signInWithApple(),
      operationName: 'login com Apple',
    );
  }

  @override
  Future<Either<Failure, User>> signInWithFacebook() async {
    return errorHandlingService.executeAuthOperation(
      operation: () => remoteDataSource.signInWithFacebook(),
      operationName: 'login com Facebook',
    );
  }

  @override
  Future<Either<Failure, User>> signInAnonymously() async {
    return await logTimedOperation<Either<Failure, User>>(
      context: LogCategory.auth.name,
      operation: LogOperation.login.name,
      message: 'sign in anonymously',
      metadata: {'method': 'anonymous'},
      operationFunction: () async {
        try {
          await logOperationStart(
            context: LogCategory.auth.name,
            operation: LogOperation.login.name,
            message: 'authenticating user anonymously',
          );

          final user = await remoteDataSource.signInAnonymously();

          await logLocalStorageOperation(
            context: LogCategory.auth.name,
            operation: LogOperation.create.name,
            message: 'caching anonymous user session',
            metadata: {'user_id': user.id, 'is_anonymous': true},
          );

          await localDataSource.cacheUser(user);

          await logOperationSuccess(
            context: LogCategory.auth.name,
            operation: LogOperation.login.name,
            message: 'sign in anonymously',
            metadata: {'user_id': user.id},
          );

          return Right(user);
        } on ServerException catch (e, stackTrace) {
          await logOperationError(
            context: LogCategory.auth.name,
            operation: LogOperation.login.name,
            message: 'sign in anonymously - server error',
            error: e,
            stackTrace: stackTrace,
          );
          return Left(AuthFailure(message: e.message));
        } on CacheException catch (e, stackTrace) {
          await logOperationError(
            context: LogCategory.auth.name,
            operation: LogOperation.create.name,
            message: 'failed to cache anonymous user session',
            error: e,
            stackTrace: stackTrace,
          );
          try {
            final user = await remoteDataSource.getCurrentUser();
            if (user != null) {
              await logOperationSuccess(
                context: LogCategory.auth.name,
                operation: LogOperation.login.name,
                message:
                    'sign in anonymously (cache failed but auth succeeded)',
                metadata: {'user_id': user.id, 'cache_failed': true},
              );
              return Right(user);
            } else {
              return const Left(AuthFailure(message: 'Falha no login anônimo'));
            }
          } catch (_) {
            return Left(CacheFailure(message: e.message));
          }
        } catch (e, stackTrace) {
          await logOperationError(
            context: LogCategory.auth.name,
            operation: LogOperation.login.name,
            message: 'sign in anonymously - unexpected error',
            error: e,
            stackTrace: stackTrace,
          );
          return Left(AuthFailure(message: 'Erro inesperado: $e'));
        }
      },
    );
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    return errorHandlingService.executeVoidAuthOperation(
      operation: () async {
        await remoteDataSource.signOut();
        await localDataSource.clearCache();
        await localDataSource.clearToken();
      },
    );
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final remoteUser = await remoteDataSource.getCurrentUser();
      if (remoteUser != null) {
        await localDataSource.cacheUser(remoteUser);
        return Right(remoteUser);
      }
      final cachedUser = await localDataSource.getCachedUser();
      return Right(cachedUser);
    } on ServerException catch (_) {
      try {
        final cachedUser = await localDataSource.getCachedUser();
        return Right(cachedUser);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(AuthFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    return errorHandlingService.executeVoidAuthOperation(
      operation: () => remoteDataSource.sendEmailVerification(),
    );
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    return errorHandlingService.executeVoidAuthOperation(
      operation: () => remoteDataSource.sendPasswordResetEmail(email),
    );
  }

  @override
  Future<Either<Failure, User>> updateProfile(
      String? name, String? photoUrl) async {
    return errorHandlingService.executeAuthOperation(
      operation: () => remoteDataSource.updateProfile(name, photoUrl),
      operationName: 'atualização de perfil',
    );
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    return errorHandlingService.executeVoidAuthOperation(
      operation: () async {
        await remoteDataSource.deleteAccount();
        await localDataSource.clearCache();
        await localDataSource.clearToken();
      },
    );
  }

  @override
  Stream<Either<Failure, User?>> watchAuthState() {
    return remoteDataSource.watchAuthState().map((user) {
      if (user != null) {
        localDataSource.cacheUser(user).catchError((_) {});
      } else {
        localDataSource.clearCache().catchError((_) {});
        localDataSource.clearToken().catchError((_) {});
      }
      return Right<Failure, User?>(user);
    }).handleError((Object error) {
      if (error is ServerException) {
        return Left<Failure, User?>(AuthFailure(message: error.message));
      }
      return Left<Failure, User?>(
          AuthFailure(message: 'Erro inesperado: $error'));
    });
  }

  void dispose() {
    _authStateSubscription?.cancel();
  }
}
