import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/exceptions.dart' as local_exceptions;
import '../../../../core/services/data_cleaner_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final remoteUser = await remoteDataSource.getCurrentUser();

      if (remoteUser != null) {
        await localDataSource.cacheUser(remoteUser);
        return Right(remoteUser);
      }
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null) {
        return Right(cachedUser);
      }

      return const Right(null);
    } on local_exceptions.ServerException catch (e) {
      try {
        final cachedUser = await localDataSource.getCachedUser();
        if (cachedUser != null) {
          return Right(cachedUser);
        }
      } catch (cacheError) {
        debugPrint('Failed to get cached user as fallback: $cacheError');
      }

      return Left(ServerFailure(e.message));
    } on local_exceptions.CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, UserEntity?>> watchAuthState() {
    try {
      return remoteDataSource
          .watchAuthState()
          .map<Either<Failure, UserEntity?>>((userModel) {
            if (userModel == null) {
              // Fire-and-forget: Clear cached user on logout
              localDataSource.clearCachedUser().catchError((Object e) {
                SecureLogger.warning(
                  'Failed to clear cached user on logout',
                  error: e,
                );
              });
              return const Right(null);
            }
            // Fire-and-forget: Cache user on login
            localDataSource.cacheUser(userModel).catchError((Object e) {
              SecureLogger.warning('Failed to cache user on login', error: e);
            });

            return Right(userModel);
          })
          .handleError((Object error) {
            if (error is local_exceptions.ServerException) {
              return Left<Failure, UserEntity?>(ServerFailure(error.message));
            }
            return Left<Failure, UserEntity?>(
              UnexpectedFailure(error.toString()),
            );
          });
    } catch (e) {
      return Stream.value(Left(UnexpectedFailure(e.toString())));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.signInWithEmail(email, password);
      await localDataSource.cacheUser(userModel);

      return Right(userModel);
    } on local_exceptions.AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on local_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInAnonymously() async {
    try {
      final userModel = await remoteDataSource.signInAnonymously();

      return Right(userModel);
    } on local_exceptions.AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on local_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final userModel = await remoteDataSource.signUpWithEmail(
        email,
        password,
        displayName,
      );
      await localDataSource.cacheUser(userModel);

      return Right(userModel);
    } on local_exceptions.AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on local_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final userModel = await remoteDataSource.updateProfile(
        displayName,
        photoUrl,
      );
      await localDataSource.cacheUser(userModel);

      return Right(userModel);
    } on local_exceptions.AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on local_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateEmail(String newEmail) async {
    try {
      await remoteDataSource.updateEmail(newEmail);
      return const Right(unit);
    } on local_exceptions.AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on local_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updatePassword(String newPassword) async {
    try {
      await remoteDataSource.updatePassword(newPassword);
      return const Right(unit);
    } on local_exceptions.AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on local_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> sendEmailVerification() async {
    try {
      await remoteDataSource.sendEmailVerification();
      return const Right(unit);
    } on local_exceptions.AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on local_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> sendPasswordResetEmail(String email) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email);
      return const Right(unit);
    } on local_exceptions.AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on local_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) async {
    try {
      return const Left(
        UnexpectedFailure('Password reset confirmation not implemented'),
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> linkAnonymousWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.linkAnonymousWithEmail(
        email,
        password,
      );
      await localDataSource.cacheUser(userModel);

      return Right(userModel);
    } on local_exceptions.AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on local_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final userModel = await remoteDataSource.signInWithGoogle();
      await localDataSource.cacheUser(userModel);

      return Right(userModel);
    } on local_exceptions.AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on local_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithApple() async {
    try {
      final userModel = await remoteDataSource.signInWithApple();
      await localDataSource.cacheUser(userModel);

      return Right(userModel);
    } on local_exceptions.AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on local_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithFacebook() async {
    try {
      final userModel = await remoteDataSource.signInWithFacebook();
      await localDataSource.cacheUser(userModel);

      return Right(userModel);
    } on local_exceptions.AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on local_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> linkAnonymousWithGoogle() async {
    try {
      final userModel = await remoteDataSource.linkAnonymousWithGoogle();
      await localDataSource.cacheUser(userModel);

      return Right(userModel);
    } on local_exceptions.AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on local_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> linkAnonymousWithApple() async {
    try {
      final userModel = await remoteDataSource.linkAnonymousWithApple();
      await localDataSource.cacheUser(userModel);

      return Right(userModel);
    } on local_exceptions.AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on local_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> linkAnonymousWithFacebook() async {
    try {
      final userModel = await remoteDataSource.linkAnonymousWithFacebook();
      await localDataSource.cacheUser(userModel);

      return Right(userModel);
    } on local_exceptions.AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on local_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await remoteDataSource.signOut();
      await localDataSource.clearCachedUser();
      await localDataSource.clearCachedCredentialsPreservingEmail();
      return const Right(unit);
    } on local_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on local_exceptions.CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAccount() async {
    try {
      await remoteDataSource.deleteAccount();
      await localDataSource.clearCachedUser();
      await _clearGasometerLocalData();

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

  /// Clears all local gasometer-specific data after account deletion
  Future<void> _clearGasometerLocalData() async {
    try {
      final dataCleanerService = DataCleanerService.instance;
      final clearResult = await dataCleanerService.clearAllData();

      if (clearResult['success'] == true) {
        final clearedBoxes = clearResult['totalClearedBoxes'] ?? 0;
        final clearedPrefs = clearResult['totalClearedPreferences'] ?? 0;

        if (kDebugMode) {
          debugPrint('✅ Gasometer local data cleared successfully:');
          debugPrint('   - Hive boxes: $clearedBoxes');
          debugPrint('   - SharedPreferences: $clearedPrefs');
        }
      } else {
        final errors = clearResult['errors'] as List? ?? [];
        if (errors.isNotEmpty && kDebugMode) {
          debugPrint('⚠️ Some errors occurred during data clearing:');
          for (final error in errors) {
            debugPrint('   - $error');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error during local data cleanup: $e');
      }
    }
  }

  @override
  Either<Failure, Unit> validateEmail(String email) {
    if (email.isEmpty) {
      return const Left(ValidationFailure('Email não pode estar vazio'));
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return const Left(ValidationFailure('Email inválido'));
    }

    return const Right(unit);
  }

  @override
  Either<Failure, Unit> validatePassword(String password) {
    if (password.isEmpty) {
      return const Left(ValidationFailure('Senha não pode estar vazia'));
    }

    if (password.length < 6) {
      return const Left(
        ValidationFailure('Senha deve ter pelo menos 6 caracteres'),
      );
    }

    return const Right(unit);
  }
}
