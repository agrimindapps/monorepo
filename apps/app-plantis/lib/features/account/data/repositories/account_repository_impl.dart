import 'dart:async';

import 'package:core/core.dart' hide Column;
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../domain/entities/account_info.dart';
import '../../domain/repositories/account_repository.dart';
import '../../../premium/domain/repositories/premium_repository.dart';
import '../datasources/account_local_datasource.dart';
import '../datasources/account_remote_datasource.dart';

/// Implementação do AccountRepository
/// Coordena entre data sources local e remoto
/// Usa EnhancedAccountDeletionService para delete account seguro
class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource remoteDataSource;
  final AccountLocalDataSource localDataSource;
  final fb.FirebaseAuth firebaseAuth;
  final EnhancedAccountDeletionService enhancedDeletionService;
  final PremiumRepository premiumRepository;

  const AccountRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.firebaseAuth,
    required this.enhancedDeletionService,
    required this.premiumRepository,
  });

  @override
  Future<Either<Failure, AccountInfo>> getAccountInfo() async {
    try {
      final userEntity = await remoteDataSource.getRemoteAccountInfo();

      if (userEntity == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      // Verifica status premium através do PremiumRepository (RevenueCat)
      final premiumResult = await premiumRepository.hasActivePremium();
      final isPremium = premiumResult.fold(
        (failure) => false, // Em caso de erro, assume free
        (hasActivePremium) => hasActivePremium,
      );

      final accountInfo = AccountInfo(
        userId: userEntity.id,
        displayName: userEntity.displayName,
        email: userEntity.email,
        isAnonymous: userEntity.provider == AuthProvider.anonymous,
        isPremium: isPremium,
        createdAt: userEntity.createdAt,
        lastLoginAt: userEntity.lastLoginAt,
        avatarUrl: userEntity.photoUrl,
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
      return Left(UnknownFailure('Erro ao limpar dados do usuário: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      final userEntity = await remoteDataSource.getRemoteAccountInfo();

      if (userEntity == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      // Usa EnhancedAccountDeletionService com todos os recursos de segurança:
      // - Re-autenticação obrigatória (será solicitada pela UI)
      // - Rate limiting
      // - Verificação de assinaturas RevenueCat
      // - Limpeza completa Firestore + Storage
      // - Limpeza local via DataCleanerService
      // - Auditoria e logging
      final result = await enhancedDeletionService.deleteAccount(
        userId: userEntity.id,
        isAnonymous: userEntity.provider == AuthProvider.anonymous,
        // Nota: password será solicitada pela UI antes de chamar este método
      );

      return result.fold((error) => Left(AuthFailure(error.message)), (
        deletionResult,
      ) {
        if (deletionResult.isSuccess) {
          return const Right(null);
        } else {
          return Left(AuthFailure(deletionResult.userMessage));
        }
      });
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(AuthFailure('Erro ao excluir conta: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final currentUser = firebaseAuth.currentUser;
      return Right(currentUser != null);
    } catch (e) {
      return Left(UnknownFailure('Erro ao verificar autenticação: $e'));
    }
  }

  @override
  Stream<AccountInfo?> watchAccountInfo() {
    return firebaseAuth.authStateChanges().asyncMap((fb.User? user) async {
      if (user == null) {
        return null;
      }

      // Verifica status premium através do PremiumRepository (RevenueCat)
      final premiumResult = await premiumRepository.hasActivePremium();
      final isPremium = premiumResult.fold(
        (failure) => false, // Em caso de erro, assume free
        (hasActivePremium) => hasActivePremium,
      );

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
