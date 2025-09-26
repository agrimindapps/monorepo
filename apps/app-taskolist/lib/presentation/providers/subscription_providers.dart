import 'package:core/core.dart';

import '../../core/di/injection_container.dart' as di;
import '../../domain/entities/subscription_status.dart' as local_sub;
// Local Domain Entities
import '../../domain/entities/usage_stats.dart' as local;
import '../../domain/entities/user_limits.dart' as local;
import '../../infrastructure/services/subscription_service.dart';

class Subscription {
  static final subscriptionStatusProvider = StateNotifierProvider<SubscriptionStatusNotifier, AsyncValue<local_sub.SubscriptionStatus>>((ref) {
    return SubscriptionStatusNotifier();
  });
}

class SubscriptionStatusNotifier extends StateNotifier<AsyncValue<local_sub.SubscriptionStatus>> {
  SubscriptionStatusNotifier() : super(const AsyncValue.loading()) {
    _fetchSubscriptionStatus();
  }

  Future<void> _fetchSubscriptionStatus() async {
    try {
      // TODO: Implement actual subscription status fetching
      const status = local_sub.SubscriptionStatus(
        isActive: false, 
        expirationDate: null,
      );
      state = AsyncValue.data(status);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
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
final userLimitsProvider = FutureProvider.family<local.UserLimits, UserLimitsParams>((ref, params) async {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return await subscriptionService.getUserLimits(
    currentTasks: params.currentTasks,
    currentSubtasks: params.currentSubtasks,
    currentTags: params.currentTags,
    completedTasks: params.completedTasks,
    completedSubtasks: params.completedSubtasks,
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

// Provider para ações de subscription
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
final usageStatsProvider = FutureProvider<local.UsageStats>((ref) async {
  // Aqui você obteria as estatísticas reais dos repositórios
  // Por enquanto, retornando dados mock para demonstração
  return const local.UsageStats(
    totalTasks: 25,
    totalSubtasks: 8,
    totalTags: 3,
    completedTasks: 15,
    activeTasksThisWeek: 10,
  );
});

// Removendo classe duplicada de UsageStats, use local.UsageStats

// UserLimits class is defined in subscription_service.dart