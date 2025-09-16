import 'dart:async';

import 'package:core/core.dart' as core;
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/premium_status.dart';
import '../../domain/repositories/premium_repository.dart';
import '../datasources/premium_local_data_source.dart';
import '../datasources/premium_remote_data_source.dart';
import '../services/premium_sync_service.dart';

@LazySingleton(as: PremiumRepository)
class PremiumRepositoryImpl implements PremiumRepository {
  final PremiumRemoteDataSource remoteDataSource;
  final PremiumLocalDataSource localDataSource;
  final PremiumSyncService _syncService;

  PremiumRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required PremiumSyncService syncService,
  }) : _syncService = syncService;

  @override
  Stream<PremiumStatus> get premiumStatus => _syncService.premiumStatusStream;

  @override
  Future<Either<Failure, bool>> hasActivePremium() async {
    try {
      final status = await getPremiumStatus();
      return status.fold(
        (failure) => Left(failure),
        (premiumStatus) => Right(premiumStatus.isPremium),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PremiumStatus>> getPremiumStatus() async {
    try {
      // Usa o status do sync service que já consolida todas as fontes
      final status = _syncService.currentStatus;
      return Right(status);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<core.ProductInfo>>> getAvailableProducts() async {
    try {
      return await remoteDataSource.getAvailableProducts();
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, core.SubscriptionEntity>> purchasePremium({
    required String productId,
  }) async {
    try {
      return await remoteDataSource.purchaseProduct(productId: productId);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> restorePurchases() async {
    try {
      final result = await remoteDataSource.restorePurchases();
      return result.fold(
        (failure) => Left(failure),
        (subscriptions) => Right(subscriptions.isNotEmpty),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> startFreeTrial() async {
    try {
      // Para desenvolvimento, usar licença local
      final result = await generateLocalLicense(days: 7);
      return result.fold(
        (failure) => Left(failure),
        (_) => const Right(true),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isEligibleForTrial() async {
    try {
      // Elegível se não tem premium ativo
      final hasActive = await hasActivePremium();
      return hasActive.fold(
        (failure) => Left(failure),
        (isPremium) => Right(!isPremium),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setUser({
    required String userId,
    Map<String, String>? attributes,
  }) async {
    try {
      return await remoteDataSource.setUser(
        userId: userId,
        attributes: attributes,
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String?>> getManagementUrl() async {
    try {
      return await remoteDataSource.getManagementUrl();
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> canUseFeature(String featureId) async {
    try {
      final statusResult = await getPremiumStatus();
      return statusResult.fold(
        (failure) => Left(failure),
        (status) => Right(status.canUseFeature(featureId)),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> canAddVehicle(int currentCount) async {
    try {
      final statusResult = await getPremiumStatus();
      return statusResult.fold(
        (failure) => Left(failure),
        (status) => Right(status.canAddVehicle(currentCount)),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> canAddFuelRecord(int currentCount) async {
    try {
      final statusResult = await getPremiumStatus();
      return statusResult.fold(
        (failure) => Left(failure),
        (status) => Right(status.canAddFuelRecord(currentCount)),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> canAddMaintenanceRecord(int currentCount) async {
    try {
      final statusResult = await getPremiumStatus();
      return statusResult.fold(
        (failure) => Left(failure),
        (status) => Right(status.canAddMaintenanceRecord(currentCount)),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> generateLocalLicense({int days = 30}) async {
    try {
      await localDataSource.generateLocalLicense(days: days);

      // Força sync para atualizar todas as fontes
      await _syncService.forceSync();

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> revokeLocalLicense() async {
    try {
      await localDataSource.revokeLocalLicense();

      // Força sync para atualizar todas as fontes
      await _syncService.forceSync();

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> hasActiveLocalLicense() async {
    try {
      final hasLicense = await localDataSource.hasActiveLocalLicense();
      return Right(hasLicense);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Força sincronização imediata do status premium
  Future<Either<Failure, void>> forceSyncPremiumStatus() async {
    try {
      return await _syncService.forceSync();
    } catch (e) {
      return Left(ServerFailure('Erro na sincronização forçada: ${e.toString()}'));
    }
  }

  /// Stream de eventos de sincronização
  Stream<PremiumSyncEvent> get syncEvents => _syncService.syncEvents;

  /// Processa webhook do RevenueCat
  Future<Either<Failure, void>> processWebhook({
    required Map<String, dynamic> payload,
    String? signature,
    String? secret,
  }) async {
    try {
      // Note: O webhook data source está injetado no sync service
      // Este método é uma interface conveniente no repository
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao processar webhook: ${e.toString()}'));
    }
  }

  void dispose() {
    _syncService.dispose();
  }
}