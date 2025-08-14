/// Abstract interface for premium status management
/// Following Interface Segregation Principle (SOLID)
abstract class IPremiumService {
  /// Check if user has premium access
  Future<bool> isPremiumUser();
  
  /// Get premium status synchronously (cached)
  bool get isPremiumCached;
  
  /// Check if a specific feature is available for current user
  Future<bool> hasFeatureAccess(String featureId);
  
  /// Get user's subscription type
  Future<String?> getSubscriptionType();
  
  /// Get subscription expiry date
  Future<DateTime?> getSubscriptionExpiry();
  
  /// Check if subscription is active
  Future<bool> isSubscriptionActive();
  
  /// Get remaining days of subscription
  Future<int> getRemainingDays();
  
  /// Refresh premium status from server
  Future<void> refreshPremiumStatus();
  
  /// Get premium features list
  Future<List<String>> getPremiumFeatures();
  
  /// Check if trial is available
  Future<bool> isTrialAvailable();
  
  /// Start trial period
  Future<bool> startTrial();
  
  /// Stream of premium status changes
  Stream<bool> get premiumStatusStream;
  
  /// Get upgrade URL for non-premium users
  String? get upgradeUrl;
}