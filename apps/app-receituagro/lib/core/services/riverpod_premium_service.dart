import 'dart:async';

import 'package:core/core.dart' as core;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../interfaces/i_premium_service.dart';
import '../providers/core_providers.dart' as local_providers;
import '../providers/premium_notifier.dart';

/// Real implementation of IPremiumService that syncs with Riverpod PremiumNotifier
///
/// This adapter bridges the old IPremiumService interface
/// with the Riverpod-based PremiumNotifier state management.
class RiverpodPremiumService implements IPremiumService {
  final ProviderContainer _container;
  final StreamController<bool> _statusController =
      StreamController<bool>.broadcast();
  ProviderSubscription<AsyncValue<PremiumState>>? _subscription;

  RiverpodPremiumService(this._container) {
    // Listen to PremiumNotifier changes and update local state
    _subscription = _container.listen<AsyncValue<PremiumState>>(
      premiumProvider,
      (_, next) {
        next.whenData((state) {
          _statusController.add(state.isPremium);
        });
      },
    );
  }

  @override
  bool get isPremium {
    final state = _container.read(premiumProvider).value;
    return state?.isPremium ?? false;
  }

  @override
  PremiumStatus get status {
    final state = _container.read(premiumProvider).value;
    if (state == null || !state.isPremium) {
      return const PremiumStatus(isActive: false);
    }

    return PremiumStatus(
      isActive: state.isActive,
      expiryDate: state.status.expirationDate,
      planType: state.status.productId,
      isTestSubscription: false,
    );
  }

  @override
  bool get shouldShowPremiumDialogs => true;

  @override
  Stream<bool> get premiumStatusStream => _statusController.stream;

  @override
  String? get upgradeUrl => null;

  @override
  Future<void> checkPremiumStatus() async {
    // Premium status is automatically updated via Riverpod stream
    // Force refresh if needed
    final currentState = _container.read(premiumProvider).value;

    if (currentState != null) {
      // Trigger a rebuild
      _statusController.add(currentState.isPremium);
    }
  }

  @override
  Future<bool> isPremiumUser() async {
    return isPremium;
  }

  @override
  Future<String?> getSubscriptionType() async {
    final state = _container.read(premiumProvider).value;
    return state?.status.productId;
  }

  @override
  Future<DateTime?> getSubscriptionExpiry() async {
    final state = _container.read(premiumProvider).value;
    return state?.status.expirationDate;
  }

  @override
  Future<bool> isSubscriptionActive() async {
    final state = _container.read(premiumProvider).value;
    return state?.isActive ?? false;
  }

  @override
  Future<int> getRemainingDays() async {
    final state = _container.read(premiumProvider).value;
    final expiryDate = state?.status.expirationDate;

    if (expiryDate == null) return 0;

    final now = DateTime.now();
    final difference = expiryDate.difference(now);
    return difference.inDays > 0 ? difference.inDays : 0;
  }

  @override
  Future<void> refreshPremiumStatus() async {
    await checkPremiumStatus();
  }

  @override
  bool canUseFeature(String featureName) {
    if (isPremium) return true;

    // Free features
    const freeFeatures = ['basic_search', 'limited_results'];
    return freeFeatures.contains(featureName);
  }

  @override
  Future<bool> hasFeatureAccess(String featureId) async {
    return canUseFeature(featureId);
  }

  @override
  int getFeatureLimit(String featureName) {
    if (isPremium) return -1; // Unlimited for premium

    switch (featureName) {
      case 'search_results':
        return 10;
      case 'favorites':
        return 5;
      case 'diagnostics_per_day':
        return 3;
      default:
        return 0;
    }
  }

  @override
  bool hasReachedLimit(String featureName, int currentUsage) {
    final limit = getFeatureLimit(featureName);
    if (limit == -1) return false; // No limit
    return currentUsage >= limit;
  }

  @override
  Future<List<String>> getPremiumFeatures() async {
    return [
      'unlimited_search',
      'unlimited_favorites',
      'unlimited_diagnostics',
      'premium_recommendations',
      'advanced_filters',
      'export_data',
    ];
  }

  @override
  Future<bool> isTrialAvailable() async {
    final state = _container.read(premiumProvider).value;
    return state?.status.isTrialActive ?? false;
  }

  @override
  Future<bool> startTrial() async {
    // Trial is handled by RevenueCat/SubscriptionNotifier
    return false;
  }

  @override
  Future<void> generateTestSubscription() async {
    // For web/mock testing, delegate to SubscriptionRepository (MockSubscriptionService)
    final subscriptionRepo = _container.read(
      local_providers.subscriptionRepositoryProvider,
    );

    // If using MockSubscriptionService, trigger purchase
    if (subscriptionRepo is core.MockSubscriptionService) {
      await subscriptionRepo.purchaseProduct(
        productId: 'receituagro_premium_monthly',
      );

      // Force refresh premium state
      _container.invalidate(premiumProvider);
      await checkPremiumStatus();
    }
  }

  @override
  Future<void> removeTestSubscription() async {
    // For web/mock testing, delegate to SubscriptionRepository (MockSubscriptionService)
    final subscriptionRepo = _container.read(
      local_providers.subscriptionRepositoryProvider,
    );

    // If using MockSubscriptionService, trigger cancellation
    if (subscriptionRepo is core.MockSubscriptionService) {
      await subscriptionRepo.cancelSubscription();

      // Force refresh premium state
      _container.invalidate(premiumProvider);
      await checkPremiumStatus();
    }
  }

  @override
  Future<void> navigateToPremium() async {
    // Navigation is handled by the UI layer
  }

  void dispose() {
    _subscription?.close();
    _statusController.close();
  }
}
