import 'package:core/core.dart' hide UserEntity, Column;

import '../../../core/errors/failures.dart' as local_failures;
import '../../../core/utils/typedef.dart';
import '../domain/auth_repository.dart';
import '../domain/user_entity.dart';
import 'auth_local_datasource.dart';
import 'auth_remote_datasource.dart';
import 'user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
  );

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  @override
  ResultFuture<UserEntity> signInWithEmailPassword(String email, String password) async {
    try {
      final user = await _remoteDataSource.signInWithEmailPassword(email, password);
      await _localDataSource.cacheUser(user);
      return Right(user);
    } catch (e) {
      return Left(local_failures.ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<UserEntity> signUpWithEmailPassword(String email, String password, String name) async {
    try {
      final user = await _remoteDataSource.signUpWithEmailPassword(email, password, name);
      await _localDataSource.cacheUser(user);
      return Right(user);
    } catch (e) {
      return Left(local_failures.ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<void> signOut() async {
    try {
      await _remoteDataSource.signOut();
      await _localDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      return Left(local_failures.ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<UserEntity?> getCurrentUser() async {
    try {
      final isSignedIn = await _localDataSource.isUserSignedIn();
      if (!isSignedIn) {
        return const Right(null);
      }
      final localUser = await _localDataSource.getCachedUser();
      if (localUser != null) {
        return Right(localUser);
      }
      final remoteUser = await _remoteDataSource.getCurrentUser();
      if (remoteUser != null) {
        await _localDataSource.cacheUser(remoteUser);
      }

      return Right(remoteUser);
    } catch (e) {
      return Left(local_failures.CacheFailure(e.toString()));
    }
  }

  @override
  ResultFuture<void> resetPassword(String email) async {
    try {
      await _remoteDataSource.resetPassword(email);
      return const Right(null);
    } catch (e) {
      return Left(local_failures.ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<void> updateProfile(UserEntity user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      await _remoteDataSource.updateProfile(userModel);
      await _localDataSource.cacheUser(userModel);
      return const Right(null);
    } catch (e) {
      return Left(local_failures.ServerFailure(e.toString()));
    }
  }

  @override
  Stream<UserEntity?> watchAuthState() {
    return _remoteDataSource.watchAuthState();
  }

  @override
  ResultFuture<void> deleteAccount() async {
    try {
      await _remoteDataSource.deleteAccount();
      await _localDataSource.clearCache();

      return const Right(null);
    } catch (e) {
      return Left(local_failures.ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<bool> isSignedIn() async {
    try {
      final isSignedIn = await _localDataSource.isUserSignedIn();
      return Right(isSignedIn);
    } catch (e) {
      return Left(local_failures.CacheFailure(e.toString()));
    }
  }
}
