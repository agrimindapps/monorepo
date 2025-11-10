import 'package:core/core.dart' hide getIt, Column;

import '../../core/di/injection.dart' as di;
import '../../features/account/presentation/usage_stats.dart' as local;
import '../../features/auth/domain/user_limits.dart' as local;
import '../../features/premium/presentation/subscription_status.dart'
    as local_sub;
import '../../infrastructure/services/subscription_service.dart';

class Subscription {
  static final subscriptionStatusProvider = StateNotifierProvider<
    SubscriptionStatusNotifier,
    AsyncValue<local_sub.SubscriptionStatus>
  >((ref) {
    return SubscriptionStatusNotifier();
  });
}

class SubscriptionStatusNotifier
    extends StateNotifier<AsyncValue<local_sub.SubscriptionStatus>> {
  SubscriptionStatusNotifier() : super(const AsyncValue.loading()) {
    _fetchSubscriptionStatus();
  }

  Future<void> _fetchSubscriptionStatus() async {
    try {
      const status = local_sub.SubscriptionStatus(
        isActive: false,
        expirationDate: null,
      );
      state = const AsyncValue.data(status);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
final subscriptionServiceProvider = Provider<TaskManagerSubscriptionService>((
  ref,
) {
  return di.getIt<TaskManagerSubscriptionService>();
});
final hasPremiumProvider = FutureProvider<bool>((ref) async {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return await subscriptionService.hasPremiumSubscription();
});
final currentSubscriptionProvider = FutureProvider<SubscriptionEntity?>((
  ref,
) async {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return await subscriptionService.getCurrentSubscription();
});
final availableFeaturesProvider = FutureProvider<List<String>>((ref) async {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return await subscriptionService.getAvailableFeatures();
});
final availableProductsProvider = FutureProvider<List<ProductInfo>>((
  ref,
) async {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return await subscriptionService.getTaskManagerProducts();
});
final userLimitsProvider =
    FutureProvider.family<local.UserLimits, UserLimitsParams>((
      ref,
      params,
    ) async {
      final subscriptionService = ref.watch(subscriptionServiceProvider);
      return await subscriptionService.getUserLimits(
        currentTasks: params.currentTasks,
        currentSubtasks: params.currentSubtasks,
        currentTags: params.currentTags,
        completedTasks: params.completedTasks,
        completedSubtasks: params.completedSubtasks,
      );
    });
final hasFeatureProvider = FutureProvider.family<bool, String>((
  ref,
  featureName,
) async {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return await subscriptionService.hasFeature(featureName);
});
final canCreateTasksProvider = FutureProvider.family<bool, int>((
  ref,
  currentTaskCount,
) async {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return await subscriptionService.canCreateMoreTasks(currentTaskCount);
});
final canCreateSubtasksProvider = FutureProvider.family<bool, int>((
  ref,
  currentSubtaskCount,
) async {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return await subscriptionService.canCreateMoreSubtasks(currentSubtaskCount);
});
final canCreateTagsProvider = FutureProvider.family<bool, int>((
  ref,
  currentTagCount,
) async {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return await subscriptionService.canCreateMoreTags(currentTagCount);
});
final subscriptionStatusStreamProvider = StreamProvider<SubscriptionEntity?>((
  ref,
) {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return subscriptionService.subscriptionStatus;
});
final isEligibleForTrialProvider = FutureProvider<bool>((ref) async {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return await subscriptionService.isEligibleForTrial();
});
final managementUrlProvider = FutureProvider<String?>((ref) async {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return await subscriptionService.getManagementUrl();
});
final subscriptionHistoryProvider = FutureProvider<List<SubscriptionEntity>>((
  ref,
) async {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return await subscriptionService.getUserSubscriptions();
});
class UserLimitsParams {
  final int currentTasks;
  final int currentSubtasks;
  final int currentTags;
  final int completedTasks;
  final int completedSubtasks;

  const UserLimitsParams({
    required this.currentTasks,
    required this.currentSubtasks,
    required this.currentTags,
    this.completedTasks = 0,
    this.completedSubtasks = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserLimitsParams &&
          runtimeType == other.runtimeType &&
          currentTasks == other.currentTasks &&
          currentSubtasks == other.currentSubtasks &&
          currentTags == other.currentTags &&
          completedTasks == other.completedTasks &&
          completedSubtasks == other.completedSubtasks;

  @override
  int get hashCode =>
      currentTasks.hashCode ^
      currentSubtasks.hashCode ^
      currentTags.hashCode ^
      completedTasks.hashCode ^
      completedSubtasks.hashCode;
}
final subscriptionActionsProvider = Provider<SubscriptionActions>((ref) {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return SubscriptionActions(subscriptionService, ref);
});

class SubscriptionActions {
  final TaskManagerSubscriptionService _subscriptionService;
  final Ref _ref;

  SubscriptionActions(this._subscriptionService, this._ref);

  /// Compra um produto e atualiza os providers
  Future<bool> purchaseProduct(String productId) async {
    final success = await _subscriptionService.purchaseProduct(productId);

    if (success) {
      _ref.invalidate(hasPremiumProvider);
      _ref.invalidate(currentSubscriptionProvider);
      _ref.invalidate(availableFeaturesProvider);
      _ref.invalidate(subscriptionHistoryProvider);
    }

    return success;
  }

  /// Restaura compras e atualiza os providers
  Future<bool> restorePurchases() async {
    final success = await _subscriptionService.restorePurchases();

    if (success) {
      _ref.invalidate(hasPremiumProvider);
      _ref.invalidate(currentSubscriptionProvider);
      _ref.invalidate(availableFeaturesProvider);
      _ref.invalidate(subscriptionHistoryProvider);
    }

    return success;
  }

  /// Define o usuário no RevenueCat
  Future<void> setUser(String userId, {Map<String, String>? attributes}) async {
    await _subscriptionService.setUser(userId, attributes: attributes);
    _ref.invalidate(hasPremiumProvider);
    _ref.invalidate(currentSubscriptionProvider);
    _ref.invalidate(availableFeaturesProvider);
    _ref.invalidate(subscriptionHistoryProvider);
  }
}
final usageStatsProvider = FutureProvider<local.UsageStats>((ref) async {
  return const local.UsageStats(
    totalTasks: 25,
    totalSubtasks: 8,
    totalTags: 3,
    completedTasks: 15,
    activeTasksThisWeek: 10,
  );
});
