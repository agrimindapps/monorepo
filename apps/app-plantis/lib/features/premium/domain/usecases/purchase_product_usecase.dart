import 'package:core/core.dart';

import '../repositories/premium_repository.dart';

/// UseCase for purchasing a subscription product
class PurchaseProductUseCase
    implements UseCase<SubscriptionEntity, PurchaseProductParams> {
  final PremiumRepository _premiumRepository;
  final IAnalyticsRepository _analytics;

  PurchaseProductUseCase({
    required PremiumRepository premiumRepository,
    required IAnalyticsRepository analytics,
  }) : _premiumRepository = premiumRepository,
       _analytics = analytics;

  @override
  Future<Either<Failure, SubscriptionEntity>> call(
    PurchaseProductParams params,
  ) async {
    try {
      final result = await _premiumRepository.purchasePremium(
        productId: params.productId,
      );

      return result.fold((failure) => Left(failure), (subscription) {
        // Log analytics event
        _analytics.logEvent(
          'premium_purchased',
          parameters: {'product_id': params.productId},
        );

        return Right(subscription);
      });
    } catch (e) {
      return Left(
        ServerFailure(
          'Failed to purchase product: ${e.toString()}',
          code: 'PURCHASE_ERROR',
        ),
      );
    }
  }
}

/// Parameters for PurchaseProductUseCase
class PurchaseProductParams {
  final String productId;

  const PurchaseProductParams({required this.productId});
}
