import 'package:core/core.dart';

import '../../core/providers/core_providers.dart';
import '../../features/account/presentation/usage_stats.dart' as local;
import '../../features/auth/domain/user_limits.dart' as local;
import '../../features/premium/presentation/subscription_status.dart' as local_sub;
import '../../infrastructure/services/subscription_service.dart';

part 'subscription_notifier.g.dart';

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
    state = const AsyncLoading<local_sub.SubscriptionStatus>();
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
Future<bool> hasPremium(Ref ref) async {
  final subscriptionService = ref.watch(taskManagerSubscriptionServiceProvider);
  return await subscriptionService.hasPremiumSubscription();
}

/// Provider para o status da subscription atual
@riverpod
Future<SubscriptionEntity?> currentSubscription(Ref ref) async {
  final subscriptionService = ref.watch(taskManagerSubscriptionServiceProvider);
  return await subscriptionService.getCurrentSubscription();
}

/// Provider para features disponíveis
@riverpod
Future<List<String>> availableFeatures(Ref ref) async {
  final subscriptionService = ref.watch(taskManagerSubscriptionServiceProvider);
  return await subscriptionService.getAvailableFeatures();
}

/// Provider para produtos disponíveis
@riverpod
Future<List<ProductInfo>> availableProducts(Ref ref) async {
  final subscriptionService = ref.watch(taskManagerSubscriptionServiceProvider);
  return await subscriptionService.getTaskManagerProducts();
}

/// Provider para limites do usuário
@riverpod
Future<local.UserLimits> userLimits(
  Ref ref,
  UserLimitsParams params,
) async {
  final subscriptionService = ref.watch(taskManagerSubscriptionServiceProvider);
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
Future<bool> hasFeature(Ref ref, String featureName) async {
  final subscriptionService = ref.watch(taskManagerSubscriptionServiceProvider);
  return await subscriptionService.hasFeature(featureName);
}

/// Provider para verificar se pode criar mais tarefas
@riverpod
Future<bool> canCreateTasks(Ref ref, int currentTaskCount) async {
  final subscriptionService = ref.watch(taskManagerSubscriptionServiceProvider);
  return await subscriptionService.canCreateMoreTasks(currentTaskCount);
}

/// Provider para verificar se pode criar mais subtarefas
@riverpod
Future<bool> canCreateSubtasks(
  Ref ref,
  int currentSubtaskCount,
) async {
  final subscriptionService = ref.watch(taskManagerSubscriptionServiceProvider);
  return await subscriptionService.canCreateMoreSubtasks(currentSubtaskCount);
}

/// Provider para verificar se pode criar mais tags
@riverpod
Future<bool> canCreateTags(Ref ref, int currentTagCount) async {
  final subscriptionService = ref.watch(taskManagerSubscriptionServiceProvider);
  return await subscriptionService.canCreateMoreTags(currentTagCount);
}

/// Provider para verificar elegibilidade para trial
@riverpod
Future<bool> isEligibleForTrial(Ref ref) async {
  final subscriptionService = ref.watch(taskManagerSubscriptionServiceProvider);
  return await subscriptionService.isEligibleForTrial();
}

/// Provider para URL de gerenciamento
@riverpod
Future<String?> managementUrl(Ref ref) async {
  final subscriptionService = ref.watch(taskManagerSubscriptionServiceProvider);
  return await subscriptionService.getManagementUrl();
}

/// Provider para histórico de subscriptions
@riverpod
Future<List<SubscriptionEntity>> subscriptionHistory(
  Ref ref,
) async {
  final subscriptionService = ref.watch(taskManagerSubscriptionServiceProvider);
  return await subscriptionService.getUserSubscriptions();
}

/// Provider para o stream de subscription status
@riverpod
Stream<SubscriptionEntity?> subscriptionStatusStream(
  Ref ref,
) {
  final subscriptionService = ref.watch(taskManagerSubscriptionServiceProvider);
  return subscriptionService.subscriptionStatus;
}

@riverpod
SubscriptionActions subscriptionActions(Ref ref) {
  final subscriptionService = ref.watch(taskManagerSubscriptionServiceProvider);
  return SubscriptionActions(subscriptionService, ref);
}

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
