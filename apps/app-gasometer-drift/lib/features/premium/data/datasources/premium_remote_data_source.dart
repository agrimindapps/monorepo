import 'package:core/core.dart' as core;
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';

/// Data source remoto para funcionalidades premium via RevenueCat
abstract class PremiumRemoteDataSource {
  /// Stream com o status da assinatura
  Stream<core.SubscriptionEntity?> get subscriptionStatus;

  /// Verifica se tem assinatura ativa
  Future<Either<Failure, bool>> hasActiveSubscription();

  /// Obtém a assinatura atual
  Future<Either<Failure, core.SubscriptionEntity?>> getCurrentSubscription();

  /// Obtém produtos disponíveis para GasOMeter
  Future<Either<Failure, List<core.ProductInfo>>> getAvailableProducts();

  /// Compra um produto
  Future<Either<Failure, core.SubscriptionEntity>> purchaseProduct({
    required String productId,
  });

  /// Restaura compras
  Future<Either<Failure, List<core.SubscriptionEntity>>> restorePurchases();

  /// Define usuário
  Future<Either<Failure, void>> setUser({
    required String userId,
    Map<String, String>? attributes,
  });

  /// Obtém URL de gerenciamento
  Future<Either<Failure, String?>> getManagementUrl();

  /// Verifica elegibilidade para trial
  Future<Either<Failure, bool>> isEligibleForTrial();
}

@LazySingleton(as: PremiumRemoteDataSource)
class PremiumRemoteDataSourceImpl implements PremiumRemoteDataSource {

  PremiumRemoteDataSourceImpl(this.subscriptionRepository);
  final core.ISubscriptionRepository subscriptionRepository;

  @override
  Stream<core.SubscriptionEntity?> get subscriptionStatus =>
      subscriptionRepository.subscriptionStatus;

  @override
  Future<Either<Failure, bool>> hasActiveSubscription() async {
    final result = await subscriptionRepository.hasGasometerSubscription();
    return result.fold(
      (coreFailure) => Left(ServerFailure(coreFailure.toString())),
      (success) => Right(success),
    );
  }

  @override
  Future<Either<Failure, core.SubscriptionEntity?>> getCurrentSubscription() async {
    final result = await subscriptionRepository.getCurrentSubscription();
    return result.fold(
      (coreFailure) => Left(ServerFailure(coreFailure.toString())),
      (success) => Right(success),
    );
  }

  @override
  Future<Either<Failure, List<core.ProductInfo>>> getAvailableProducts() async {
    final result = await subscriptionRepository.getGasometerProducts();
    return result.fold(
      (coreFailure) => Left(ServerFailure(coreFailure.toString())),
      (success) => Right(success),
    );
  }

  @override
  Future<Either<Failure, core.SubscriptionEntity>> purchaseProduct({
    required String productId,
  }) async {
    final result = await subscriptionRepository.purchaseProduct(productId: productId);
    return result.fold(
      (coreFailure) => Left(ServerFailure(coreFailure.toString())),
      (success) => Right(success),
    );
  }

  @override
  Future<Either<Failure, List<core.SubscriptionEntity>>> restorePurchases() async {
    final result = await subscriptionRepository.restorePurchases();
    return result.fold(
      (coreFailure) => Left(ServerFailure(coreFailure.toString())),
      (success) => Right(success),
    );
  }

  @override
  Future<Either<Failure, void>> setUser({
    required String userId,
    Map<String, String>? attributes,
  }) async {
    final result = await subscriptionRepository.setUser(
      userId: userId,
      attributes: attributes,
    );
    return result.fold(
      (coreFailure) => Left(ServerFailure(coreFailure.toString())),
      (success) => Right(success),
    );
  }

  @override
  Future<Either<Failure, String?>> getManagementUrl() async {
    final result = await subscriptionRepository.getManagementUrl();
    return result.fold(
      (coreFailure) => Left(ServerFailure(coreFailure.toString())),
      (success) => Right(success),
    );
  }

  @override
  Future<Either<Failure, bool>> isEligibleForTrial() async {
    try {
      final hasActiveResult = await hasActiveSubscription();
      return hasActiveResult.fold(
        (failure) => Left(failure),
        (hasActive) => Right(!hasActive),
      );
    } catch (e) {
      return Left(ServerFailure('Erro ao verificar elegibilidade para trial: $e'));
    }
  }
}
