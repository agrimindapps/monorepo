import 'dart:async';

import 'package:core/core.dart' as core;
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/premium_status.dart';
import '../../domain/repositories/premium_repository.dart';
import '../datasources/premium_local_data_source.dart';
import '../datasources/premium_remote_data_source.dart';
import '../services/premium_sync_service.dart';

@LazySingleton(as: PremiumRepository)
class PremiumRepositoryImpl implements PremiumRepository {

  PremiumRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required PremiumSyncService syncService,
  }) : _syncService = syncService;
  final PremiumRemoteDataSource remoteDataSource;
  final PremiumLocalDataSource localDataSource;
  final PremiumSyncService _syncService;

  @override
  Stream<PremiumStatus> get premiumStatus => _syncService.premiumStatusStream;

  @override
  Future<Either<core.Failure, bool>> hasActivePremium() async {
    try {
      final status = await getPremiumStatus();
      return status.fold(
        (failure) => Left(failure),
        (premiumStatus) => Right(premiumStatus.isPremium),
      );
    } catch (e) {
      return Left(core.SubscriptionUnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<core.Failure, PremiumStatus>> getPremiumStatus() async {
    try {
      final status = _syncService.currentStatus;
      return Right(status);
    } catch (e) {
      return Left(core.SubscriptionUnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<core.Failure, List<core.ProductInfo>>> getAvailableProducts() async {
    try {
      final result = await remoteDataSource.getAvailableProducts();
      return result.fold(
        (failure) => Left(_mapFailure(failure)),
        (products) => Right(products),
      );
    } catch (e) {
      return const Left(core.SubscriptionUnknownFailure());
    }
  }

  @override
  Future<Either<core.Failure, core.SubscriptionEntity>> purchasePremium({
    required String productId,
  }) async {
    try {
      final result = await remoteDataSource.purchaseProduct(productId: productId);
      return result.fold(
        (failure) => Left(_mapFailure(failure)),
        (subscription) => Right(subscription),
      );
    } catch (e) {
      return const Left(core.SubscriptionPaymentFailure());
    }
  }

  @override
  Future<Either<core.Failure, bool>> restorePurchases() async {
    try {
      final result = await remoteDataSource.restorePurchases();
      return result.fold(
        (failure) => Left(_mapFailure(failure)),
        (subscriptions) => Right(subscriptions.isNotEmpty),
      );
    } catch (e) {
      return const Left(core.SubscriptionUnknownFailure());
    }
  }

  @override
  Future<Either<core.Failure, bool>> startFreeTrial() async {
    try {
      final result = await generateLocalLicense(days: 7);
      return result.fold(
        (failure) => Left(failure),
        (_) => const Right(true),
      );
    } catch (e) {
      return Left(core.SubscriptionValidationFailure(e.toString()));
    }
  }

  @override
  Future<Either<core.Failure, bool>> isEligibleForTrial() async {
    try {
      final hasActive = await hasActivePremium();
      return hasActive.fold(
        (failure) => Left(failure),
        (isPremium) => Right(!isPremium),
      );
    } catch (e) {
      return Left(core.SubscriptionValidationFailure(e.toString()));
    }
  }

  @override
  Future<Either<core.Failure, void>> setUser({
    required String userId,
    Map<String, String>? attributes,
  }) async {
    try {
      final result = await remoteDataSource.setUser(
        userId: userId,
        attributes: attributes,
      );
      return result.fold(
        (failure) => Left(_mapFailure(failure)),
        (success) => const Right(null),
      );
    } catch (e) {
      return const Left(core.SubscriptionAuthFailure());
    }
  }

  @override
  Future<Either<core.Failure, String?>> getManagementUrl() async {
    try {
      final result = await remoteDataSource.getManagementUrl();
      return result.fold(
        (failure) => Left(_mapFailure(failure)),
        (url) => Right(url),
      );
    } catch (e) {
      return const Left(core.SubscriptionUnknownFailure());
    }
  }

  @override
  Future<Either<core.Failure, bool>> canUseFeature(String featureId) async {
    try {
      final statusResult = await getPremiumStatus();
      return statusResult.fold(
        (failure) => Left(failure),
        (status) => Right(status.canUseFeature(featureId)),
      );
    } catch (e) {
      return Left(core.SubscriptionValidationFailure(e.toString()));
    }
  }

  @override
  Future<Either<core.Failure, bool>> canAddVehicle(int currentCount) async {
    try {
      final statusResult = await getPremiumStatus();
      return statusResult.fold(
        (failure) => Left(failure),
        (status) => Right(status.canAddVehicle(currentCount)),
      );
    } catch (e) {
      return Left(core.SubscriptionValidationFailure(e.toString()));
    }
  }

  @override
  Future<Either<core.Failure, bool>> canAddFuelRecord(int currentCount) async {
    try {
      final statusResult = await getPremiumStatus();
      return statusResult.fold(
        (failure) => Left(failure),
        (status) => Right(status.canAddFuelRecord(currentCount)),
      );
    } catch (e) {
      return Left(core.SubscriptionValidationFailure(e.toString()));
    }
  }

  @override
  Future<Either<core.Failure, bool>> canAddMaintenanceRecord(int currentCount) async {
    try {
      final statusResult = await getPremiumStatus();
      return statusResult.fold(
        (failure) => Left(failure),
        (status) => Right(status.canAddMaintenanceRecord(currentCount)),
      );
    } catch (e) {
      return Left(core.SubscriptionValidationFailure(e.toString()));
    }
  }

  @override
  Future<Either<core.Failure, void>> generateLocalLicense({int days = 30}) async {
    try {
      await localDataSource.generateLocalLicense(days: days);
      await _syncService.forceSync();

      return const Right(null);
    } catch (e) {
      return Left(core.SubscriptionUnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<core.Failure, void>> revokeLocalLicense() async {
    try {
      await localDataSource.revokeLocalLicense();
      await _syncService.forceSync();

      return const Right(null);
    } catch (e) {
      return Left(core.SubscriptionUnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<core.Failure, bool>> hasActiveLocalLicense() async {
    try {
      final hasLicense = await localDataSource.hasActiveLocalLicense();
      return Right(hasLicense);
    } catch (e) {
      return Left(core.SubscriptionUnknownFailure(e.toString()));
    }
  }

  /// Força sincronização imediata do status premium
  @override
  Future<Either<core.Failure, void>> forceSyncPremiumStatus() async {
    try {
      final result = await _syncService.forceSync();
      return result.fold(
        (failure) => Left(_mapFailure(failure)),
        (_) => const Right(null),
      );
    } catch (e) {
      return const Left(core.SubscriptionSyncFailure());
    }
  }

  /// Stream de eventos de sincronização
  @override
  Stream<PremiumSyncEvent> get syncEvents => _syncService.syncEvents;

  /// Processa webhook do RevenueCat
  @override
  Future<Either<core.Failure, void>> processWebhook({
    required Map<String, dynamic> payload,
    String? signature,
    String? secret,
  }) async {
    try {
      return const Right(null);
    } catch (e) {
      return const Left(core.SubscriptionServerFailure());
    }
  }

  /// Maps local Failure types to core.Failure types
  core.Failure _mapFailure(dynamic failure) {
    String? message;
    try {
      message = (failure as dynamic).message?.toString();
    } catch (_) {
      message = failure.toString();
    }
    final typeName = failure.runtimeType.toString();
    if (typeName.contains('Network')) {
      return core.SubscriptionNetworkFailure(message);
    } else if (typeName.contains('Auth')) {
      return core.SubscriptionAuthFailure(message);
    } else if (typeName.contains('Server')) {
      return core.SubscriptionServerFailure(message);
    } else if (typeName.contains('Validation')) {
      return core.SubscriptionValidationFailure(message);
    } else if (typeName.contains('Sync')) {
      return core.SubscriptionSyncFailure(message);
    } else {
      return core.SubscriptionUnknownFailure(message);
    }
  }

  void dispose() {
    _syncService.dispose();
  }
}
