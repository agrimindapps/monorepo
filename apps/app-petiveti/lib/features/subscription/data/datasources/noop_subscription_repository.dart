import 'package:core/core.dart';

/// No-op implementation of ISubscriptionRepository for compilation
/// TODO: Use proper ISubscriptionRepository from core or remove dependency
class NoOpSubscriptionRepository implements ISubscriptionRepository {
  const NoOpSubscriptionRepository();

  @override
  Stream<SubscriptionEntity?> get subscriptionStatus => Stream.value(null);

  @override
  Future<Either<Failure, bool>> hasActiveSubscription() async => right(false);

  @override
  Future<Either<Failure, SubscriptionEntity?>> getCurrentSubscription() async => right(null);

  @override
  Future<Either<Failure, List<SubscriptionEntity>>> getUserSubscriptions() async => right([]);

  @override
  Future<Either<Failure, List<ProductInfo>>> getAvailableProducts({
    required List<String> productIds,
  }) async => right([]);

  @override
  Future<Either<Failure, SubscriptionEntity>> purchaseProduct({
    required String productId,
  }) async => left(const ServerFailure('Not implemented'));

  @override
  Future<Either<Failure, void>> cancelSubscription({
    String? reason,
  }) async => right(null);

  @override
  Future<Either<Failure, List<SubscriptionEntity>>> restorePurchases() async => right([]);

  @override
  Future<Either<Failure, List<ProductInfo>>> getPlantisProducts() async => right([]);

  @override
  Future<Either<Failure, List<ProductInfo>>> getGasometerProducts() async => right([]);

  @override
  Future<Either<Failure, List<ProductInfo>>> getReceitaAgroProducts() async => right([]);

  @override
  Future<Either<Failure, String?>> getManagementUrl() async => right(null);

  @override
  Future<Either<Failure, String?>> getSubscriptionManagementUrl() async => right(null);

  @override
  Future<Either<Failure, bool>> hasGasometerSubscription() async => right(false);

  @override
  Future<Either<Failure, bool>> hasPlantisSubscription() async => right(false);

  @override
  Future<Either<Failure, bool>> hasReceitaAgroSubscription() async => right(false);

  @override
  Future<Either<Failure, bool>> isEligibleForTrial({
    required String productId,
  }) async => right(false);

  @override
  Future<Either<Failure, void>> setUser({
    required String userId,
    Map<String, String>? attributes,
  }) async => right(null);

  @override
  Future<Either<Failure, void>> setUserAttributes({
    required Map<String, String> attributes,
  }) async => right(null);
}
