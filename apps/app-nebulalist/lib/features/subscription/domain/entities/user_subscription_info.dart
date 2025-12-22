/// Represents the current subscription information of a user
///
/// This entity encapsulates all relevant information about a user's
/// subscription state, including premium status, product details,
/// and expiration dates.
class UserSubscriptionInfo {
  /// Whether user has an active premium subscription
  final bool isPremium;

  /// Product ID of the active subscription (null if free tier)
  final String? productId;

  /// When the subscription expires (null if free tier or lifetime)
  final DateTime? expirationDate;

  /// When the subscription was purchased (null if free tier)
  final DateTime? purchaseDate;

  /// Whether user is currently in trial period
  final bool isInTrialPeriod;

  /// Whether subscription will auto-renew
  final bool willRenew;

  /// Whether subscription has been canceled but still active
  final bool isCanceled;

  const UserSubscriptionInfo({
    required this.isPremium,
    required this.productId,
    required this.expirationDate,
    required this.purchaseDate,
    this.isInTrialPeriod = false,
    this.willRenew = false,
    this.isCanceled = false,
  });

  /// Factory for free tier users (no active subscription)
  factory UserSubscriptionInfo.free() => const UserSubscriptionInfo(
        isPremium: false,
        productId: null,
        expirationDate: null,
        purchaseDate: null,
        isInTrialPeriod: false,
        willRenew: false,
        isCanceled: false,
      );

  /// Create a copy with updated fields
  UserSubscriptionInfo copyWith({
    bool? isPremium,
    String? productId,
    DateTime? expirationDate,
    DateTime? purchaseDate,
    bool? isInTrialPeriod,
    bool? willRenew,
    bool? isCanceled,
  }) {
    return UserSubscriptionInfo(
      isPremium: isPremium ?? this.isPremium,
      productId: productId ?? this.productId,
      expirationDate: expirationDate ?? this.expirationDate,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      isInTrialPeriod: isInTrialPeriod ?? this.isInTrialPeriod,
      willRenew: willRenew ?? this.willRenew,
      isCanceled: isCanceled ?? this.isCanceled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserSubscriptionInfo &&
        other.isPremium == isPremium &&
        other.productId == productId &&
        other.expirationDate == expirationDate &&
        other.purchaseDate == purchaseDate &&
        other.isInTrialPeriod == isInTrialPeriod &&
        other.willRenew == willRenew &&
        other.isCanceled == isCanceled;
  }

  @override
  int get hashCode {
    return Object.hash(
      isPremium,
      productId,
      expirationDate,
      purchaseDate,
      isInTrialPeriod,
      willRenew,
      isCanceled,
    );
  }

  @override
  String toString() {
    return 'UserSubscriptionInfo(isPremium: $isPremium, productId: $productId, expirationDate: $expirationDate, purchaseDate: $purchaseDate, isInTrialPeriod: $isInTrialPeriod, willRenew: $willRenew, isCanceled: $isCanceled)';
  }
}
