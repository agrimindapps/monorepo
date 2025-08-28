import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;
  final AuthRemoteDataSource remoteDataSource;
  StreamSubscription<UserModel?>? _authStateSubscription;

  AuthRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, User>> signInWithEmail(String email, String password) async {
    try {
      final user = await remoteDataSource.signInWithEmail(email, password);
      await localDataSource.cacheUser(user);
      return Right(user);
    } on ServerException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on CacheException catch (e) {
      // Still return success even if caching fails
      try {
        final user = await remoteDataSource.getCurrentUser();
        return user != null ? Right(user) : const Left(AuthFailure(message: 'Falha na autenticação'));
      } catch (_) {
        return Left(CacheFailure(message: e.message));
      }
    } catch (e) {
      return Left(AuthFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> signUpWithEmail(String email, String password, String? name) async {
    try {
      final user = await remoteDataSource.signUpWithEmail(email, password, name);
      await localDataSource.cacheUser(user);
      return Right(user);
    } on ServerException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on CacheException catch (e) {
      // Still return success even if caching fails
      try {
        final user = await remoteDataSource.getCurrentUser();
        return user != null ? Right(user) : const Left(AuthFailure(message: 'Falha na criação da conta'));
      } catch (_) {
        return Left(CacheFailure(message: e.message));
      }
    } catch (e) {
      return Left(AuthFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      final user = await remoteDataSource.signInWithGoogle();
      await localDataSource.cacheUser(user);
      return Right(user);
    } on ServerException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on CacheException catch (e) {
      // Still return success even if caching fails
      try {
        final user = await remoteDataSource.getCurrentUser();
        return user != null ? Right(user) : const Left(AuthFailure(message: 'Falha no login com Google'));
      } catch (_) {
        return Left(CacheFailure(message: e.message));
      }
    } catch (e) {
      return Left(AuthFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithApple() async {
    try {
      final user = await remoteDataSource.signInWithApple();
      await localDataSource.cacheUser(user);
      return Right(user);
    } on ServerException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on CacheException catch (e) {
      // Still return success even if caching fails
      try {
        final user = await remoteDataSource.getCurrentUser();
        return user != null ? Right(user) : const Left(AuthFailure(message: 'Falha no login com Apple'));
      } catch (_) {
        return Left(CacheFailure(message: e.message));
      }
    } catch (e) {
      return Left(AuthFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithFacebook() async {
    try {
      final user = await remoteDataSource.signInWithFacebook();
      await localDataSource.cacheUser(user);
      return Right(user);
    } on ServerException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on CacheException catch (e) {
      // Still return success even if caching fails
      try {
        final user = await remoteDataSource.getCurrentUser();
        return user != null ? Right(user) : const Left(AuthFailure(message: 'Falha no login com Facebook'));
      } catch (_) {
        return Left(CacheFailure(message: e.message));
      }
    } catch (e) {
      return Left(AuthFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      await localDataSource.clearCache();
      await localDataSource.clearToken();
      return const Right(null);
    } on ServerException catch (e) {
      // Even if remote signout fails, clear local data
      await localDataSource.clearCache();
      await localDataSource.clearToken();
      return Left(AuthFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(AuthFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      // First try to get from remote (Firebase Auth state)
      final remoteUser = await remoteDataSource.getCurrentUser();
      if (remoteUser != null) {
        await localDataSource.cacheUser(remoteUser);
        return Right(remoteUser);
      }

      // If no remote user, try local cache
      final cachedUser = await localDataSource.getCachedUser();
      return Right(cachedUser);
    } on ServerException catch (_) {
      // If server fails, fallback to cache
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
    try {
      await remoteDataSource.sendEmailVerification();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(AuthFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(AuthFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile(String? name, String? photoUrl) async {
    try {
      final updatedUser = await remoteDataSource.updateProfile(name, photoUrl);
      await localDataSource.cacheUser(updatedUser);
      return Right(updatedUser);
    } on ServerException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(AuthFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      await remoteDataSource.deleteAccount();
      await localDataSource.clearCache();
      await localDataSource.clearToken();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(AuthFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Stream<Either<Failure, User?>> watchAuthState() {
    return remoteDataSource.watchAuthState().map((user) {
      if (user != null) {
        // Update local cache when auth state changes
        localDataSource.cacheUser(user).catchError((_) {
          // Ignore cache errors in stream
        });
      } else {
        // Clear local cache when signed out
        localDataSource.clearCache().catchError((_) {
          // Ignore cache errors in stream
        });
        localDataSource.clearToken().catchError((_) {
          // Ignore cache errors in stream
        });
      }
      return Right<Failure, User?>(user);
    }).handleError((Object error) {
      if (error is ServerException) {
        return Left<Failure, User?>(AuthFailure(message: error.message));
      }
      return Left<Failure, User?>(AuthFailure(message: 'Erro inesperado: $error'));
    });
  }

  void dispose() {
    _authStateSubscription?.cancel();
  }
}