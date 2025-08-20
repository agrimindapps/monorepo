import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import '../../core/di/injection_container.dart' as di;
import '../../infrastructure/services/subscription_service.dart';

// Provider para o serviço de subscription
final subscriptionServiceProvider = Provider<TaskManagerSubscriptionService>((ref) {
  return di.sl<TaskManagerSubscriptionService>();
});

// Provider para verificar se tem premium
final hasPremiumProvider = FutureProvider<bool>((ref) async {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return await subscriptionService.hasPremiumSubscription();
});

// Provider para o status da subscription atual
final currentSubscriptionProvider = FutureProvider<SubscriptionEntity?>((ref) async {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return await subscriptionService.getCurrentSubscription();
});

// Provider para features disponíveis
final availableFeaturesProvider = FutureProvider<List<String>>((ref) async {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return await subscriptionService.getAvailableFeatures();
});

// Provider para produtos disponíveis
final availableProductsProvider = FutureProvider<List<ProductInfo>>((ref) async {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return await subscriptionService.getTaskManagerProducts();
});

// Provider para limites do usuário
final userLimitsProvider = FutureProvider.family<UserLimits, UserLimitsParams>((ref, params) async {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return await subscriptionService.getUserLimits(
    currentTasks: params.currentTasks,
    currentSubtasks: params.currentSubtasks,
    currentTags: params.currentTags,
  );
});

// Provider para verificar features específicas
final hasFeatureProvider = FutureProvider.family<bool, String>((ref, featureName) async {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return await subscriptionService.hasFeature(featureName);
});

// Provider para verificar se pode criar mais tarefas
final canCreateTasksProvider = FutureProvider.family<bool, int>((ref, currentTaskCount) async {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return await subscriptionService.canCreateMoreTasks(currentTaskCount);
});

// Provider para verificar se pode criar mais subtarefas
final canCreateSubtasksProvider = FutureProvider.family<bool, int>((ref, currentSubtaskCount) async {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return await subscriptionService.canCreateMoreSubtasks(currentSubtaskCount);
});

// Provider para verificar se pode criar mais tags
final canCreateTagsProvider = FutureProvider.family<bool, int>((ref, currentTagCount) async {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return await subscriptionService.canCreateMoreTags(currentTagCount);
});

// Provider para o stream de subscription status
final subscriptionStatusStreamProvider = StreamProvider<SubscriptionEntity?>((ref) {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return subscriptionService.subscriptionStatus;
});

// Provider para verificar elegibilidade para trial
final isEligibleForTrialProvider = FutureProvider<bool>((ref) async {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return await subscriptionService.isEligibleForTrial();
});

// Provider para URL de gerenciamento
final managementUrlProvider = FutureProvider<String?>((ref) async {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return await subscriptionService.getManagementUrl();
});

// Provider para histórico de subscriptions
final subscriptionHistoryProvider = FutureProvider<List<SubscriptionEntity>>((ref) async {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return await subscriptionService.getUserSubscriptions();
});

// Classe para passar parâmetros para o userLimitsProvider
class UserLimitsParams {
  final int currentTasks;
  final int currentSubtasks;
  final int currentTags;

  const UserLimitsParams({
    required this.currentTasks,
    required this.currentSubtasks,
    required this.currentTags,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserLimitsParams &&
          runtimeType == other.runtimeType &&
          currentTasks == other.currentTasks &&
          currentSubtasks == other.currentSubtasks &&
          currentTags == other.currentTags;

  @override
  int get hashCode =>
      currentTasks.hashCode ^ currentSubtasks.hashCode ^ currentTags.hashCode;
}

// Provider para ações de subscription
final subscriptionActionsProvider = Provider<SubscriptionActions>((ref) {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return SubscriptionActions(subscriptionService, ref);
});

class SubscriptionActions {
  final TaskManagerSubscriptionService _subscriptionService;
  final ProviderRef _ref;

  SubscriptionActions(this._subscriptionService, this._ref);

  /// Compra um produto e atualiza os providers
  Future<bool> purchaseProduct(String productId) async {
    final success = await _subscriptionService.purchaseProduct(productId);
    
    if (success) {
      // Invalidar providers relacionados para forçar atualização
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
      // Invalidar providers relacionados
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
    
    // Invalidar providers após definir usuário
    _ref.invalidate(hasPremiumProvider);
    _ref.invalidate(currentSubscriptionProvider);
    _ref.invalidate(availableFeaturesProvider);
    _ref.invalidate(subscriptionHistoryProvider);
  }
}

// Provider para estatísticas de uso
final usageStatsProvider = FutureProvider<UsageStats>((ref) async {
  // Aqui você obteria as estatísticas reais dos repositórios
  // Por enquanto, retornando dados mock para demonstração
  return const UsageStats(
    totalTasks: 25,
    totalSubtasks: 8,
    totalTags: 3,
    completedTasks: 15,
    activeTasksThisWeek: 10,
  );
});

class UsageStats {
  final int totalTasks;
  final int totalSubtasks;
  final int totalTags;
  final int completedTasks;
  final int activeTasksThisWeek;

  const UsageStats({
    required this.totalTasks,
    required this.totalSubtasks,
    required this.totalTags,
    required this.completedTasks,
    required this.activeTasksThisWeek,
  });
}