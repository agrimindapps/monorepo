import 'package:core/core.dart' as core;
import '../entities/user_subscription_info.dart';

/// UseCase for getting subscription status
///
/// This use case provides both stream-based reactive updates
/// and one-time snapshot checks of the user's subscription status.
class GetSubscriptionStatus {
  final core.ISubscriptionRepository _repository;

  GetSubscriptionStatus(this._repository);

  /// Stream of subscription status updates
  ///
  /// Emits updates whenever subscription status changes
  /// (purchase, renewal, cancellation, expiration)
  Stream<UserSubscriptionInfo> call() {
    return _repository.subscriptionStatus.map((coreSubscription) {
      if (coreSubscription == null || !coreSubscription.isActive) {
        return UserSubscriptionInfo.free();
      }

      return UserSubscriptionInfo(
        isPremium: coreSubscription.isActive,
        productId: coreSubscription.productId,
        expirationDate: coreSubscription.expirationDate,
        purchaseDate: coreSubscription.purchaseDate,
        isInTrialPeriod: coreSubscription.isInTrial,
        willRenew: coreSubscription.isAutoRenewing,
      );
    });
  }

  /// Check if user is premium (one-time snapshot)
  ///
  /// Returns true if user has an active premium subscription
  /// Returns false if free tier or if check fails
  Future<bool> isPremium() async {
    final result = await _repository.hasActiveSubscription();
    return result.fold(
      (failure) => false, // On error, assume free tier
      (isActive) => isActive,
    );
  }

  /// Get current subscription status (one-time snapshot)
  Future<UserSubscriptionInfo> getCurrentStatus() async {
    final result = await _repository.getCurrentSubscription();

    return result.fold(
      (failure) => UserSubscriptionInfo.free(),
      (subscription) {
        if (subscription == null || !subscription.isActive) {
          return UserSubscriptionInfo.free();
        }

        return UserSubscriptionInfo(
          isPremium: subscription.isActive,
          productId: subscription.productId,
          expirationDate: subscription.expirationDate,
          purchaseDate: subscription.purchaseDate,
          isInTrialPeriod: subscription.isInTrial,
          willRenew: subscription.isAutoRenewing,
        );
      },
    );
  }
}
