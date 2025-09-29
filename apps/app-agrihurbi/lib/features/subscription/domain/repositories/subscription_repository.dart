import 'package:app_agrihurbi/features/subscription/domain/entities/subscription_entity.dart';
import 'package:core/core.dart' show Failure;
import 'package:dartz/dartz.dart';

/// Subscription Repository Interface
/// 
/// Defines contract for premium subscription management,
/// payment processing, and feature access control
abstract class SubscriptionRepository {
  // === SUBSCRIPTION MANAGEMENT ===
  
  /// Get current user subscription
  Future<Either<Failure, SubscriptionEntity?>> getCurrentSubscription();

  /// Create new subscription
  Future<Either<Failure, SubscriptionEntity>> createSubscription({
    required SubscriptionTier tier,
    required BillingPeriod billingPeriod,
    required PaymentMethod paymentMethod,
  });

  /// Upgrade subscription tier
  Future<Either<Failure, SubscriptionEntity>> upgradeSubscription({
    required SubscriptionTier newTier,
  });

  /// Downgrade subscription tier
  Future<Either<Failure, SubscriptionEntity>> downgradeSubscription({
    required SubscriptionTier newTier,
  });

  /// Cancel subscription
  Future<Either<Failure, void>> cancelSubscription({
    bool cancelImmediately = false,
  });

  /// Reactivate canceled subscription
  Future<Either<Failure, SubscriptionEntity>> reactivateSubscription();

  /// Purchase subscription with payment method
  Future<Either<Failure, SubscriptionEntity>> purchaseSubscription({
    required SubscriptionTier tier,
    required String paymentMethodId,
  });

  /// Update auto-renewal setting
  Future<Either<Failure, void>> updateAutoRenewal(bool autoRenew);

  // === SUBSCRIPTION HISTORY ===
  
  /// Get subscription history
  Future<Either<Failure, List<SubscriptionEntity>>> getSubscriptionHistory();

  /// Get subscription invoices
  Future<Either<Failure, List<Invoice>>> getInvoices({
    int limit = 20,
    int offset = 0,
  });

  /// Download invoice PDF
  Future<Either<Failure, String>> downloadInvoice(String invoiceId);

  // === PAYMENT METHODS ===
  
  /// Get saved payment methods
  Future<Either<Failure, List<PaymentMethod>>> getPaymentMethods();

  /// Add new payment method
  Future<Either<Failure, PaymentMethod>> addPaymentMethod({
    required PaymentType type,
    required String token, // Payment processor token
  });

  /// Update payment method
  Future<Either<Failure, PaymentMethod>> updatePaymentMethod({
    required String paymentMethodId,
    required DateTime expiryDate,
  });

  /// Remove payment method
  Future<Either<Failure, void>> removePaymentMethod(String paymentMethodId);

  /// Set default payment method
  Future<Either<Failure, void>> setDefaultPaymentMethod(String paymentMethodId);

  // === FEATURE ACCESS ===
  
  /// Check if user has access to premium feature
  Future<Either<Failure, bool>> hasFeatureAccess(PremiumFeature feature);

  /// Get available features for current subscription
  Future<Either<Failure, List<PremiumFeature>>> getAvailableFeatures();

  /// Check feature usage limits
  Future<Either<Failure, FeatureUsage>> getFeatureUsage(PremiumFeature feature);

  /// Record feature usage
  Future<Either<Failure, void>> recordFeatureUsage({
    required PremiumFeature feature,
    int usage = 1,
  });

  // === SUBSCRIPTION PLANS ===
  
  /// Get all available subscription plans
  Future<Either<Failure, List<SubscriptionPlan>>> getSubscriptionPlans();

  /// Get plan details
  Future<Either<Failure, SubscriptionPlan>> getPlanDetails(SubscriptionTier tier);

  /// Compare subscription plans
  Future<Either<Failure, List<PlanComparison>>> comparePlans();

  // === TRIAL MANAGEMENT ===
  
  /// Start free trial
  Future<Either<Failure, SubscriptionEntity>> startFreeTrial({
    required SubscriptionTier tier,
    int trialDays = 7,
  });

  /// Check trial eligibility
  Future<Either<Failure, bool>> isTrialEligible();

  /// Get trial status
  Future<Either<Failure, TrialStatus?>> getTrialStatus();

  // === PROMO CODES & DISCOUNTS ===
  
  /// Apply promo code
  Future<Either<Failure, PromoCodeResult>> applyPromoCode(String code);

  /// Remove applied promo code
  Future<Either<Failure, void>> removePromoCode();

  /// Get active discounts
  Future<Either<Failure, List<Discount>>> getActiveDiscounts();

  // === NOTIFICATIONS ===
  
  /// Get subscription notifications
  Future<Either<Failure, List<SubscriptionNotification>>> getNotifications();

  /// Mark notification as read
  Future<Either<Failure, void>> markNotificationAsRead(String notificationId);

  /// Update notification preferences
  Future<Either<Failure, void>> updateNotificationPreferences({
    required bool renewalReminders,
    required bool paymentFailures,
    required bool trialExpiry,
    required bool newFeatures,
  });
}

/// Invoice Entity
class Invoice {
  final String id;
  final String subscriptionId;
  final double amount;
  final String currency;
  final DateTime invoiceDate;
  final DateTime? paidAt;
  final InvoiceStatus status;
  final String downloadUrl;

  const Invoice({
    required id,
    required subscriptionId,
    required amount,
    required currency,
    required invoiceDate,
    paidAt,
    required status,
    required downloadUrl,
  });
}

/// Invoice Status
enum InvoiceStatus {
  pending,
  paid,
  failed,
  refunded,
}

/// Feature Usage Entity
class FeatureUsage {
  final PremiumFeature feature;
  final int currentUsage;
  final int limit;
  final DateTime resetDate;

  const FeatureUsage({
    required feature,
    required currentUsage,
    required limit,
    required resetDate,
  });

  bool get isLimitReached => currentUsage >= limit;
  int get remainingUsage => (limit - currentUsage).clamp(0, limit);
}

/// Subscription Plan Entity
class SubscriptionPlan {
  final SubscriptionTier tier;
  final String name;
  final String description;
  final double monthlyPrice;
  final double yearlyPrice;
  final List<PremiumFeature> features;
  final List<String> benefits;
  final bool isPopular;

  const SubscriptionPlan({
    required tier,
    required name,
    required description,
    required monthlyPrice,
    required yearlyPrice,
    required features,
    required benefits,
    isPopular = false,
  });
}

/// Plan Comparison Entity
class PlanComparison {
  final PremiumFeature feature;
  final Map<SubscriptionTier, bool> availability;
  final Map<SubscriptionTier, String?> limits;

  const PlanComparison({
    required feature,
    required availability,
    required limits,
  });
}

/// Trial Status Entity
class TrialStatus {
  final SubscriptionTier tier;
  final DateTime startDate;
  final DateTime endDate;
  final int daysRemaining;
  final bool isActive;

  const TrialStatus({
    required tier,
    required startDate,
    required endDate,
    required daysRemaining,
    required isActive,
  });
}

/// Promo Code Result Entity
class PromoCodeResult {
  final String code;
  final double discountPercent;
  final double discountAmount;
  final DateTime expiresAt;
  final bool isValid;
  final String? errorMessage;

  const PromoCodeResult({
    required code,
    required discountPercent,
    required discountAmount,
    required expiresAt,
    required isValid,
    errorMessage,
  });
}

/// Discount Entity
class Discount {
  final String id;
  final String name;
  final double discountPercent;
  final DateTime validUntil;
  final List<SubscriptionTier> applicableTiers;

  const Discount({
    required id,
    required name,
    required discountPercent,
    required validUntil,
    required applicableTiers,
  });
}

/// Subscription Notification Entity
class SubscriptionNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;

  const SubscriptionNotification({
    required id,
    required title,
    required message,
    required type,
    required createdAt,
    isRead = false,
  });
}

/// Notification Types
enum NotificationType {
  renewalReminder,
  paymentFailure,
  trialExpiry,
  newFeatures,
  upgrade,
  cancellation,
}