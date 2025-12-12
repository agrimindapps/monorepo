import 'package:core/core.dart';

/// Service responsible for validating premium subscription status and features
class PremiumValidationService {
  /// Checks if the subscription is active
  bool isSubscriptionActive(SubscriptionEntity? subscription) {
    return subscription?.isActive ?? false;
  }

  /// Checks if the subscription is in trial period
  bool isSubscriptionInTrial(SubscriptionEntity? subscription) {
    return subscription?.isInTrial ?? false;
  }

  /// Checks if a specific feature is available based on subscription status
  bool isFeatureAvailable({
    required SubscriptionEntity? subscription,
    required String featureId,
    required List<String> premiumFeatures,
  }) {
    // If subscription is not active, no premium features are available
    if (!isSubscriptionActive(subscription)) {
      return false;
    }

    // Check if the feature is in the list of enabled premium features
    return premiumFeatures.contains(featureId);
  }

  /// Determines if an upgrade prompt should be displayed to the user
  bool shouldDisplayUpgradePrompt(SubscriptionEntity? subscription) {
    return !isSubscriptionActive(subscription);
  }

  /// Validates plant creation limits based on subscription status
  bool canCreatePlant({
    required SubscriptionEntity? subscription,
    required int currentPlantCount,
    required int? freeTierLimit,
  }) {
    // Premium users have no limits
    if (isSubscriptionActive(subscription)) {
      return true;
    }

    // Free tier users are limited
    if (freeTierLimit == null) {
      return true; // No limit configured
    }

    return currentPlantCount < freeTierLimit;
  }

  /// Validates task creation limits based on subscription status
  bool canCreateTask({
    required SubscriptionEntity? subscription,
    required int currentTaskCount,
    required int? freeTierLimit,
  }) {
    // Premium users have no limits
    if (isSubscriptionActive(subscription)) {
      return true;
    }

    // Free tier users are limited
    if (freeTierLimit == null) {
      return true; // No limit configured
    }

    return currentTaskCount < freeTierLimit;
  }

  /// Gets the available features based on subscription status
  List<String> getAvailableFeatures({
    required SubscriptionEntity? subscription,
    required List<String> allPremiumFeatures,
    required List<String> freeTierFeatures,
  }) {
    if (isSubscriptionActive(subscription)) {
      return allPremiumFeatures;
    }
    return freeTierFeatures;
  }

  /// Validates sync capability based on subscription status
  bool canSyncData(SubscriptionEntity? subscription) {
    // Allow sync for premium users only
    return isSubscriptionActive(subscription);
  }

  /// Calculates remaining items for free tier users
  int getRemainingItems({
    required SubscriptionEntity? subscription,
    required int currentCount,
    required int? freeTierLimit,
  }) {
    // Premium users have unlimited items
    if (isSubscriptionActive(subscription)) {
      return -1; // Indicates unlimited
    }

    // Free tier calculation
    if (freeTierLimit == null) {
      return -1; // No limit configured
    }

    final remaining = freeTierLimit - currentCount;
    return remaining > 0 ? remaining : 0;
  }

  /// Validates subscription expiration
  bool isSubscriptionExpired(SubscriptionEntity? subscription) {
    if (subscription == null) return true;

    final expirationDate = subscription.expirationDate;
    if (expirationDate == null) return false;

    return DateTime.now().isAfter(expirationDate);
  }

  /// Checks if subscription is about to expire (within warning period)
  bool isSubscriptionExpiringSoon({
    required SubscriptionEntity? subscription,
    int warningDays = 7,
  }) {
    if (subscription == null) return false;

    final expirationDate = subscription.expirationDate;
    if (expirationDate == null) return false;

    final now = DateTime.now();
    final warningDate = expirationDate.subtract(Duration(days: warningDays));

    return now.isAfter(warningDate) && now.isBefore(expirationDate);
  }

  /// Validates if user can access premium content
  bool canAccessPremiumContent(SubscriptionEntity? subscription) {
    return isSubscriptionActive(subscription) &&
        !isSubscriptionExpired(subscription);
  }
}
