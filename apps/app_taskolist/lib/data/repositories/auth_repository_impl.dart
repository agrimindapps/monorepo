import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../core/utils/typedef.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  @override
  ResultFuture<UserEntity> signInWithEmailPassword(String email, String password) async {
    try {
      final user = await _remoteDataSource.signInWithEmailPassword(email, password);
      await _localDataSource.cacheUser(user);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<UserEntity> signUpWithEmailPassword(String email, String password, String name) async {
    try {
      final user = await _remoteDataSource.signUpWithEmailPassword(email, password, name);
      await _localDataSource.cacheUser(user);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<void> signOut() async {
    try {
      await _remoteDataSource.signOut();
      await _localDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<UserEntity?> getCurrentUser() async {
    try {
      // Primeiro verifica se está logado
      final isSignedIn = await _localDataSource.isUserSignedIn();
      if (!isSignedIn) {
        return const Right(null);
      }

      // Tenta buscar usuário local primeiro
      final localUser = await _localDataSource.getCachedUser();
      if (localUser != null) {
        return Right(localUser);
      }

      // Se não tem local, busca remoto
      final remoteUser = await _remoteDataSource.getCurrentUser();
      if (remoteUser != null) {
        await _localDataSource.cacheUser(remoteUser);
      }
      
      return Right(remoteUser);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  ResultFuture<void> resetPassword(String email) async {
    try {
      await _remoteDataSource.resetPassword(email);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
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
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<UserEntity?> watchAuthState() {
    return _remoteDataSource.watchAuthState();
  }

  @override
  ResultFuture<void> deleteAccount() async {
    try {
      // Primeiro deletar conta remotamente
      await _remoteDataSource.deleteAccount();
      
      // Depois limpar dados locais
      await _localDataSource.clearCache();
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<bool> isSignedIn() async {
    try {
      final isSignedIn = await _localDataSource.isUserSignedIn();
      return Right(isSignedIn);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}