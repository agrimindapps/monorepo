import 'package:core/core.dart';

import '../../core/di/injection.dart' as di;
import '../../features/account/presentation/usage_stats.dart' as local;
import '../../features/auth/domain/user_limits.dart' as local;
import '../../features/premium/presentation/subscription_status.dart' as local_sub;
import '../../infrastructure/services/subscription_service.dart';

part 'subscription_notifier.g.dart';

@riverpod
TaskManagerSubscriptionService subscriptionService(SubscriptionServiceRef ref) {
  return di.getIt<TaskManagerSubscriptionService>();
}

/// Async Notifier para o estado de subscription
@riverpod
class SubscriptionStatusNotifier extends _$SubscriptionStatusNotifier {
  @override
  Future<local_sub.SubscriptionStatus> build() async {
    return const local_sub.SubscriptionStatus(
      isActive: false,
      expirationDate: null,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return const local_sub.SubscriptionStatus(
        isActive: false,
        expirationDate: null,
      );
    });
  }
}

/// Provider para verificar se tem premium
@riverpod
Future<bool> hasPremium(HasPremiumRef ref) async {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return await subscriptionService.hasPremiumSubscription();
}

/// Provider para o status da subscription atual
@riverpod
Future<SubscriptionEntity?> currentSubscription(CurrentSubscriptionRef ref) async {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return await subscriptionService.getCurrentSubscription();
}

/// Provider para features disponíveis
@riverpod
Future<List<String>> availableFeatures(AvailableFeaturesRef ref) async {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return await subscriptionService.getAvailableFeatures();
}

/// Provider para produtos disponíveis
@riverpod
Future<List<ProductInfo>> availableProducts(AvailableProductsRef ref) async {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return await subscriptionService.getTaskManagerProducts();
}

/// Provider para limites do usuário
@riverpod
Future<local.UserLimits> userLimits(
  UserLimitsRef ref,
  UserLimitsParams params,
) async {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return await subscriptionService.getUserLimits(
    currentTasks: params.currentTasks,
    currentSubtasks: params.currentSubtasks,
    currentTags: params.currentTags,
    completedTasks: params.completedTasks,
    completedSubtasks: params.completedSubtasks,
  );
}

/// Provider para verificar features específicas
@riverpod
Future<bool> hasFeature(HasFeatureRef ref, String featureName) async {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return await subscriptionService.hasFeature(featureName);
}

/// Provider para verificar se pode criar mais tarefas
@riverpod
Future<bool> canCreateTasks(CanCreateTasksRef ref, int currentTaskCount) async {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return await subscriptionService.canCreateMoreTasks(currentTaskCount);
}

/// Provider para verificar se pode criar mais subtarefas
@riverpod
Future<bool> canCreateSubtasks(
  CanCreateSubtasksRef ref,
  int currentSubtaskCount,
) async {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return await subscriptionService.canCreateMoreSubtasks(currentSubtaskCount);
}

/// Provider para verificar se pode criar mais tags
@riverpod
Future<bool> canCreateTags(CanCreateTagsRef ref, int currentTagCount) async {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return await subscriptionService.canCreateMoreTags(currentTagCount);
}

/// Provider para verificar elegibilidade para trial
@riverpod
Future<bool> isEligibleForTrial(IsEligibleForTrialRef ref) async {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return await subscriptionService.isEligibleForTrial();
}

/// Provider para URL de gerenciamento
@riverpod
Future<String?> managementUrl(ManagementUrlRef ref) async {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return await subscriptionService.getManagementUrl();
}

/// Provider para histórico de subscriptions
@riverpod
Future<List<SubscriptionEntity>> subscriptionHistory(
  SubscriptionHistoryRef ref,
) async {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return await subscriptionService.getUserSubscriptions();
}

/// Provider para o stream de subscription status
@riverpod
Stream<SubscriptionEntity?> subscriptionStatusStream(
  SubscriptionStatusStreamRef ref,
) {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return subscriptionService.subscriptionStatus;
}

@riverpod
SubscriptionActions subscriptionActions(SubscriptionActionsRef ref) {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return SubscriptionActions(subscriptionService, ref);
}

class SubscriptionActions {
  final TaskManagerSubscriptionService _subscriptionService;
  final SubscriptionActionsRef _ref;

  SubscriptionActions(this._subscriptionService, this._ref);

  /// Compra um produto e atualiza os providers
  Future<bool> purchaseProduct(String productId) async {
    final success = await _subscriptionService.purchaseProduct(productId);

    if (success) {
      _ref.invalidate(hasPremiumProvider);
      _ref.invalidate(currentSubscriptionProvider);
      _ref.invalidate(availableFeaturesProvider);
      _ref.invalidate(subscriptionHistoryProvider);
      _ref.invalidate(subscriptionStatusNotifierProvider);
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
      _ref.invalidate(subscriptionStatusNotifierProvider);
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
    _ref.invalidate(subscriptionStatusNotifierProvider);
  }
}

/// Provider para estatísticas de uso
@riverpod
Future<local.UsageStats> usageStats(UsageStatsRef ref) async {
  return const local.UsageStats(
    totalTasks: 25,
    totalSubtasks: 8,
    totalTags: 3,
    completedTasks: 15,
    activeTasksThisWeek: 10,
  );
}

/// Classe para passar parâmetros para o userLimitsProvider
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
