import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:app_agrihurbi/core/error/failures.dart';
import 'package:app_agrihurbi/core/utils/typedef.dart';
import 'package:app_agrihurbi/features/subscription/domain/entities/subscription_entity.dart';
import 'package:app_agrihurbi/features/subscription/domain/repositories/subscription_repository.dart';

/// Manage Subscription Use Case
/// 
/// Handles all subscription management operations
@injectable
class ManageSubscription {
  final SubscriptionRepository _repository;

  const ManageSubscription(this._repository);

  /// Get current subscription
  Future<Either<Failure, SubscriptionEntity?>> getCurrentSubscription() async {
    return await _repository.getCurrentSubscription();
  }

  /// Create new subscription
  ResultFuture<SubscriptionEntity> createSubscription({
    required SubscriptionTier tier,
    required BillingPeriod billingPeriod,
    required PaymentMethod paymentMethod,
  }) async {
    return await _repository.createSubscription(
      tier: tier,
      billingPeriod: billingPeriod,
      paymentMethod: paymentMethod,
    );
  }

  /// Upgrade subscription
  ResultFuture<SubscriptionEntity> upgradeSubscription({
    required SubscriptionTier newTier,
  }) async {
    return await _repository.upgradeSubscription(newTier: newTier);
  }

  /// Downgrade subscription
  ResultFuture<SubscriptionEntity> downgradeSubscription({
    required SubscriptionTier newTier,
  }) async {
    return await _repository.downgradeSubscription(newTier: newTier);
  }

  /// Cancel subscription
  ResultVoid cancelSubscription({
    bool cancelImmediately = false,
  }) async {
    return await _repository.cancelSubscription(
      cancelImmediately: cancelImmediately,
    );
  }

  /// Reactivate subscription
  ResultFuture<SubscriptionEntity> reactivateSubscription() async {
    return await _repository.reactivateSubscription();
  }
}

/// Check Feature Access Use Case
@injectable
class CheckFeatureAccess {
  final SubscriptionRepository _repository;

  const CheckFeatureAccess(this._repository);

  /// Check if user has access to specific feature
  ResultFuture<bool> hasAccess(PremiumFeature feature) async {
    return await _repository.hasFeatureAccess(feature);
  }

  /// Get all available features
  ResultFuture<List<PremiumFeature>> getAvailableFeatures() async {
    return await _repository.getAvailableFeatures();
  }

  /// Get feature usage statistics
  ResultFuture<FeatureUsage> getFeatureUsage(PremiumFeature feature) async {
    return await _repository.getFeatureUsage(feature);
  }

  /// Record feature usage
  ResultVoid recordUsage({
    required PremiumFeature feature,
    int usage = 1,
  }) async {
    return await _repository.recordFeatureUsage(
      feature: feature,
      usage: usage,
    );
  }
}

/// Manage Payment Methods Use Case
@injectable
class ManagePaymentMethods {
  final SubscriptionRepository _repository;

  const ManagePaymentMethods(this._repository);

  /// Get all payment methods
  ResultFuture<List<PaymentMethod>> getPaymentMethods() async {
    return await _repository.getPaymentMethods();
  }

  /// Add new payment method
  ResultFuture<PaymentMethod> addPaymentMethod({
    required PaymentType type,
    required String token,
  }) async {
    return await _repository.addPaymentMethod(
      type: type,
      token: token,
    );
  }

  /// Remove payment method
  ResultVoid removePaymentMethod(String paymentMethodId) async {
    return await _repository.removePaymentMethod(paymentMethodId);
  }

  /// Set default payment method
  ResultVoid setDefaultPaymentMethod(String paymentMethodId) async {
    return await _repository.setDefaultPaymentMethod(paymentMethodId);
  }
}

/// Manage Trial Use Case
@injectable
class ManageTrial {
  final SubscriptionRepository _repository;

  const ManageTrial(this._repository);

  /// Start free trial
  ResultFuture<SubscriptionEntity> startTrial({
    required SubscriptionTier tier,
    int trialDays = 7,
  }) async {
    return await _repository.startFreeTrial(
      tier: tier,
      trialDays: trialDays,
    );
  }

  /// Check trial eligibility
  ResultFuture<bool> isEligible() async {
    return await _repository.isTrialEligible();
  }

  /// Get trial status
  Future<Either<Failure, TrialStatus?>> getTrialStatus() async {
    return await _repository.getTrialStatus();
  }
}

/// Get Subscription Plans Use Case
@injectable
class GetSubscriptionPlans {
  final SubscriptionRepository _repository;

  const GetSubscriptionPlans(this._repository);

  /// Get all available plans
  ResultFuture<List<SubscriptionPlan>> getAllPlans() async {
    return await _repository.getSubscriptionPlans();
  }

  /// Get specific plan details
  ResultFuture<SubscriptionPlan> getPlanDetails(SubscriptionTier tier) async {
    return await _repository.getPlanDetails(tier);
  }

  /// Compare plans
  ResultFuture<List<PlanComparison>> comparePlans() async {
    return await _repository.comparePlans();
  }
}

/// Manage Promo Codes Use Case
@injectable
class ManagePromoCodes {
  final SubscriptionRepository _repository;

  const ManagePromoCodes(this._repository);

  /// Apply promo code
  ResultFuture<PromoCodeResult> applyPromoCode(String code) async {
    return await _repository.applyPromoCode(code);
  }

  /// Remove promo code
  ResultVoid removePromoCode() async {
    return await _repository.removePromoCode();
  }

  /// Get active discounts
  ResultFuture<List<Discount>> getActiveDiscounts() async {
    return await _repository.getActiveDiscounts();
  }
}