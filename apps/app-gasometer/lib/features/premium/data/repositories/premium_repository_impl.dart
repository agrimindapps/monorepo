import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:core/core.dart' as core;
import '../../../../core/error/failures.dart';
import '../../domain/entities/premium_status.dart';
import '../../domain/repositories/premium_repository.dart';
import '../datasources/premium_local_data_source.dart';
import '../datasources/premium_remote_data_source.dart';

@LazySingleton(as: PremiumRepository)
class PremiumRepositoryImpl implements PremiumRepository {
  final PremiumRemoteDataSource remoteDataSource;
  final PremiumLocalDataSource localDataSource;

  final StreamController<PremiumStatus> _statusController = 
      StreamController<PremiumStatus>.broadcast();

  StreamSubscription<core.SubscriptionEntity?>? _subscriptionSubscription;

  PremiumRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  }) {
    _initialize();
  }

  @override
  Stream<PremiumStatus> get premiumStatus => _statusController.stream;

  void _initialize() {
    // Escuta mudanças na assinatura e converte para PremiumStatus
    _subscriptionSubscription = remoteDataSource.subscriptionStatus.listen(
      (subscription) async {
        final status = await _buildPremiumStatus(subscription);
        _statusController.add(status);
      },
    );
  }

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
      // Primeiro, verifica licença local
      final hasLocalLicense = await localDataSource.hasActiveLocalLicense();
      if (hasLocalLicense) {
        final expiration = await localDataSource.getLocalLicenseExpiration();
        if (expiration != null && DateTime.now().isBefore(expiration)) {
          return Right(PremiumStatus.localLicense(expiration: expiration));
        }
      }

      // Depois, verifica assinatura remota
      final subscriptionResult = await remoteDataSource.getCurrentSubscription();
      return subscriptionResult.fold(
        (failure) => Left(failure),
        (subscription) async => Right(await _buildPremiumStatus(subscription)),
      );
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
      
      // Notifica mudança no status
      final status = await getPremiumStatus();
      status.fold(
        (failure) => null,
        (premiumStatus) => _statusController.add(premiumStatus),
      );
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> revokeLocalLicense() async {
    try {
      await localDataSource.revokeLocalLicense();
      
      // Notifica mudança no status
      final status = await getPremiumStatus();
      status.fold(
        (failure) => null,
        (premiumStatus) => _statusController.add(premiumStatus),
      );
      
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

  /// Constrói PremiumStatus a partir de SubscriptionEntity
  Future<PremiumStatus> _buildPremiumStatus(core.SubscriptionEntity? subscription) async {
    // Verifica licença local primeiro
    final hasLocalLicense = await localDataSource.hasActiveLocalLicense();
    if (hasLocalLicense) {
      final expiration = await localDataSource.getLocalLicenseExpiration();
      if (expiration != null && DateTime.now().isBefore(expiration)) {
        return PremiumStatus.localLicense(expiration: expiration);
      }
    }

    // Se não tem licença local, verifica assinatura
    if (subscription == null || !subscription.isActive) {
      return PremiumStatus.free;
    }

    return PremiumStatus.premium(
      subscription: subscription,
      expirationDate: subscription.expirationDate,
      isInTrial: subscription.isInTrial,
      trialDaysRemaining: subscription.daysRemaining,
    );
  }

  void dispose() {
    _subscriptionSubscription?.cancel();
    _statusController.close();
  }
}