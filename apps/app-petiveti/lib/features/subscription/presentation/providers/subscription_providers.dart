import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'subscription_providers.g.dart';

// ============================================================================
// STATE PROVIDERS
// ============================================================================

@riverpod
Future<bool> hasPremiumSubscription(Ref ref) async {
  final coreRepo = ref.watch(subscriptionRepositoryProvider);
  final result = await coreRepo.hasActiveSubscription();
  return result.fold((_) => false, (hasPremium) => hasPremium);
}

@riverpod
Future<SubscriptionInfo?> currentSubscription(Ref ref) async {
  final coreRepo = ref.watch(subscriptionRepositoryProvider);
  final result = await coreRepo.getCurrentSubscription();
  return result.fold((_) => null, (subscription) => subscription);
}

@riverpod
Future<List<ProductInfo>> availablePlans(Ref ref) async {
  final coreRepo = ref.watch(subscriptionRepositoryProvider);
  final result = await coreRepo.getAvailableProducts(productIds: [
    'petiveti_monthly_premium',
    'petiveti_yearly_premium',
    'petiveti_lifetime',
  ]);
  return result.fold((_) => [], (plans) => plans);
}

@riverpod
Future<bool> hasFeatureAccess(Ref ref, String featureKey) async {
  final hasPremium = await ref.watch(hasPremiumSubscriptionProvider.future);
  return hasPremium;
}

@riverpod
Future<bool> hasActiveTrial(Ref ref) async {
  final subscription = await ref.watch(currentSubscriptionProvider.future);
  return subscription?.isTrialActive ?? false;
}

@riverpod
Future<bool> subscription(Ref ref) async {
  return ref.watch(hasPremiumSubscriptionProvider.future);
}
