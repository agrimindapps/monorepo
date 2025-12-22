/// RevenueCat product identifiers and configurations for NebulaList
///
/// This file contains all product IDs, entitlements, and subscription-related
/// constants for the NebulaList premium subscription system.
class RevenueCatConstants {
  RevenueCatConstants._();

  // ========== Product IDs ==========

  /// Monthly subscription plan - R$ 9,99/month
  static const String monthlyProductId = 'nebulalist_monthly';

  /// Semester subscription plan - R$ 49,99/6 months (Save 17%)
  static const String semesterProductId = 'nebulalist_semester';

  /// Annual subscription plan - R$ 89,99/year (Save 25%)
  static const String annualProductId = 'nebulalist_annual';

  // ========== Entitlements ==========

  /// Premium entitlement ID
  /// Users with this active entitlement have unlimited access
  static const String premiumEntitlementId = 'premium';

  // ========== Offering IDs ==========

  /// Default offering ID (configured in RevenueCat Dashboard)
  static const String defaultOfferingId = 'default';

  // ========== Package IDs ==========

  /// Package ID for monthly plan in RevenueCat
  static const String monthlyPackageId = '\$rc_monthly';

  /// Package ID for semester plan in RevenueCat
  static const String semesterPackageId = '\$rc_six_month';

  /// Package ID for annual plan in RevenueCat
  static const String annualPackageId = '\$rc_annual';

  // ========== Feature Limits ==========

  /// Maximum active lists for free tier users
  static const int freeListsLimit = 10;

  /// Maximum lists for premium users (unlimited)
  static const int premiumListsLimit = -1; // -1 = unlimited

  // ========== Helpers ==========

  /// Maps mock plan ID to real product ID
  static String getProductId(String mockPlanId) {
    switch (mockPlanId) {
      case 'nebulalist_monthly':
        return monthlyProductId;
      case 'nebulalist_semester':
        return semesterProductId;
      case 'nebulalist_annual':
        return annualProductId;
      default:
        return monthlyProductId; // Default to monthly
    }
  }

  /// Maps product ID to package ID
  static String getPackageId(String productId) {
    switch (productId) {
      case monthlyProductId:
        return monthlyPackageId;
      case semesterProductId:
        return semesterPackageId;
      case annualProductId:
        return annualPackageId;
      default:
        return monthlyPackageId;
    }
  }

  /// Checks if product ID is valid
  static bool isValidProductId(String productId) {
    return productId == monthlyProductId ||
        productId == semesterProductId ||
        productId == annualProductId;
  }
}
