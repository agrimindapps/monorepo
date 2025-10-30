import 'dart:async';

import 'package:core/core.dart';

import '../../domain/entities/account_info.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_local_datasource.dart';
import '../datasources/account_remote_datasource.dart';

/// Implementação do AccountRepository
/// Coordena entre data sources local e remoto
class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource remoteDataSource;
  final AccountLocalDataSource localDataSource;
  final FirebaseService firebaseService;

  const AccountRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.firebaseService,
  });

  @override
  Future<Either<Failure, AccountInfo>> getAccountInfo() async {
    try {
      final userEntity = await remoteDataSource.getRemoteAccountInfo();
      
      if (userEntity == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      // TODO: Verificar status premium através do RevenueCat
      const isPremium = false;

      final accountInfo = AccountInfo(
        userId: userEntity.id,
        displayName: userEntity.displayName ?? 'Usuário',
        email: userEntity.email ?? '',
        isAnonymous: userEntity.isAnonymous,
        isPremium: isPremium,
        createdAt: userEntity.createdAt,
        lastLoginAt: userEntity.lastLoginAt,
        avatarUrl: userEntity.photoURL,
      );

      return Right(accountInfo);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnknownFailure('Erro ao buscar informações da conta: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Realiza logout remoto
      await remoteDataSource.logout();
      
      // Limpa dados locais da sessão
      await localDataSource.clearAccountData();
      
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(AuthFailure('Erro ao fazer logout: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> clearUserData() async {
    try {
      final userEntity = await remoteDataSource.getRemoteAccountInfo();
      
      if (userEntity == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      // Limpa dados locais
      final localCleared = await localDataSource.clearLocalUserData();
      
      // Limpa dados remotos
      final remoteCleared = await remoteDataSource.clearRemoteUserData(
        userEntity.id,
      );
      
      final totalCleared = localCleared + remoteCleared;
      
      return Right(totalCleared);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(
        UnknownFailure('Erro ao limpar dados do usuário: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      final userEntity = await remoteDataSource.getRemoteAccountInfo();
      
      if (userEntity == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      // Deleta conta remota (isso já limpa os dados)
      await remoteDataSource.deleteAccount(userEntity.id);
      
      // Limpa dados locais
      await localDataSource.clearAccountData();
      
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(AuthFailure('Erro ao excluir conta: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final currentUser = firebaseService.currentUser;
      return Right(currentUser != null);
    } catch (e) {
      return Left(UnknownFailure('Erro ao verificar autenticação: $e'));
    }
  }

  @override
  Stream<AccountInfo?> watchAccountInfo() {
    return firebaseService.authStateChanges.asyncMap((user) async {
      if (user == null) {
        return null;
      }

      // TODO: Verificar status premium através do RevenueCat
      const isPremium = false;

      return AccountInfo(
        userId: user.uid,
        displayName: user.displayName ?? 'Usuário',
        email: user.email ?? '',
        isAnonymous: user.isAnonymous,
        isPremium: isPremium,
        createdAt: user.metadata.creationTime,
        lastLoginAt: user.metadata.lastSignInTime,
        avatarUrl: user.photoURL,
      );
    });
  }
}
