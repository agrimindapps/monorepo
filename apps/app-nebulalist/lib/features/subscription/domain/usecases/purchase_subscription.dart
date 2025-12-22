import 'package:core/core.dart' as core;
import 'package:flutter/foundation.dart';
import '../../../../core/constants/revenuecat_constants.dart';

/// UseCase for purchasing a subscription
///
/// Handles the complete purchase flow using the core repository
class PurchaseSubscription {
  final core.ISubscriptionRepository _repository;

  PurchaseSubscription(this._repository);

  /// Purchase a specific subscription plan
  ///
  /// [planId] - The plan identifier (from PremiumPlansWidget)
  ///
  /// Returns:
  /// - Right(true) if purchase was successful
  /// - Left(Failure) if purchase failed or was canceled
  Future<core.Either<core.Failure, bool>> call(String planId) async {
    try {
      debugPrint('[PurchaseSubscription] Starting purchase for plan: $planId');

      // 1. Convert mock plan ID to real product ID
      final productId = RevenueCatConstants.getProductId(planId);
      debugPrint('[PurchaseSubscription] Product ID: $productId');

      // 2. Purchase the product directly
      final result = await _repository.purchaseProduct(productId: productId);

      return result.fold(
        (failure) {
          debugPrint('[PurchaseSubscription] Purchase failed: $failure');
          return core.Left(failure);
        },
        (subscription) {
          debugPrint('[PurchaseSubscription] Purchase successful!');
          debugPrint('[PurchaseSubscription] Subscription: ${subscription.productId}');

          // Verify subscription is active
          if (subscription.isActive) {
            return const core.Right(true);
          } else {
            debugPrint('[PurchaseSubscription] Purchase succeeded but subscription not active');
            return core.Left(
              core.ValidationFailure(
                'Compra processada mas assinatura não foi ativada. Entre em contato com o suporte.',
              ),
            );
          }
        },
      );
    } catch (e, stackTrace) {
      debugPrint('[PurchaseSubscription] Unexpected error: $e');
      debugPrint('[PurchaseSubscription] Stack: $stackTrace');
      return core.Left(core.UnexpectedFailure('Erro inesperado na compra: $e'));
    }
  }
}
