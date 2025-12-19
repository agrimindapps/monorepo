import 'package:core/core.dart' hide Column, subscriptionRepositoryProvider;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/dependency_providers.dart';
import '../../domain/entities/premium_features.dart';
import '../../domain/entities/premium_status.dart';

part 'premium_notifier.g.dart';

/// Tipos de erro do Premium
enum PremiumErrorType { network, auth, purchase, sync, unknown }

/// Erro do Premium
class PremiumError {
  final PremiumErrorType type;
  final String message;

  const PremiumError({required this.type, required this.message});
}

/// Estado do Premium
class PremiumState {
  final SubscriptionEntity? currentSubscription;
  final List<ProductInfo> availableProducts;
  final bool isLoading;
  final PremiumError? error;
  final bool isSyncing;
  final bool hasSyncErrors;
  final DateTime? lastSyncAt;
  final List<String> premiumFeaturesEnabled;
  final Map<String, int>? usageLimits;
  final String? syncErrorMessage;
  final int syncRetryCount;

  const PremiumState({
    this.currentSubscription,
    this.availableProducts = const [],
    this.isLoading = false,
    this.error,
    this.isSyncing = false,
    this.hasSyncErrors = false,
    this.lastSyncAt,
    this.premiumFeaturesEnabled = const [],
    this.usageLimits,
    this.syncErrorMessage,
    this.syncRetryCount = 0,
  });

  bool get isPremium => currentSubscription?.isActive ?? false;
  bool get isInTrial => currentSubscription?.isInTrial ?? false;

  /// Converte para PremiumStatus
  PremiumStatus get premiumStatus {
    if (isPremium) {
      return PremiumStatus.premium(
        subscription: currentSubscription,
        expirationDate: currentSubscription?.expirationDate,
        isInTrial: isInTrial,
      );
    }
    return PremiumStatus.free;
  }

  PremiumState copyWith({
    SubscriptionEntity? currentSubscription,
    List<ProductInfo>? availableProducts,
    bool? isLoading,
    PremiumError? error,
    bool? isSyncing,
    bool? hasSyncErrors,
    DateTime? lastSyncAt,
    List<String>? premiumFeaturesEnabled,
    Map<String, int>? usageLimits,
    String? syncErrorMessage,
    int? syncRetryCount,
  }) {
    return PremiumState(
      currentSubscription: currentSubscription ?? this.currentSubscription,
      availableProducts: availableProducts ?? this.availableProducts,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSyncing: isSyncing ?? this.isSyncing,
      hasSyncErrors: hasSyncErrors ?? this.hasSyncErrors,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      premiumFeaturesEnabled:
          premiumFeaturesEnabled ?? this.premiumFeaturesEnabled,
      usageLimits: usageLimits ?? this.usageLimits,
      syncErrorMessage: syncErrorMessage ?? this.syncErrorMessage,
      syncRetryCount: syncRetryCount ?? this.syncRetryCount,
    );
  }
}

/// Provider principal do Premium
@riverpod
class PremiumNotifier extends _$PremiumNotifier {
  late final ISubscriptionRepository _subscriptionRepository;

  @override
  Future<PremiumState> build() async {
    _subscriptionRepository = ref.watch(subscriptionRepositoryProvider);
    return await _initialize();
  }

  Future<PremiumState> _initialize() async {
    try {
      final result = await _subscriptionRepository.getCurrentSubscription();
      return result.fold(
        (failure) => PremiumState(
          error: PremiumError(
            type: PremiumErrorType.unknown,
            message: failure.message,
          ),
        ),
        (subscription) => PremiumState(currentSubscription: subscription),
      );
    } catch (e) {
      return PremiumState(
        error: PremiumError(
          type: PremiumErrorType.unknown,
          message: e.toString(),
        ),
      );
    }
  }

  /// Carrega produtos disponíveis
  Future<void> loadAvailableProducts(List<String> productIds) async {
    state = const AsyncValue.loading();
    final currentState = state.maybeWhen(
      data: (data) => data,
      orElse: () => const PremiumState(),
    );

    try {
      final result = await _subscriptionRepository.getAvailableProducts(
        productIds: productIds,
      );

      state = result.fold(
        (failure) => AsyncValue.data(
          currentState.copyWith(
            error: PremiumError(
              type: PremiumErrorType.unknown,
              message: failure.message,
            ),
          ),
        ),
        (products) => AsyncValue.data(
          currentState.copyWith(availableProducts: products, error: null),
        ),
      );
    } catch (e, stack) {
      state = AsyncValue.error(
        PremiumError(type: PremiumErrorType.unknown, message: e.toString()),
        stack,
      );
    }
  }

  /// Compra um produto
  Future<bool> purchaseProduct(String productId) async {
    final currentState = state.maybeWhen(
      data: (data) => data,
      orElse: () => const PremiumState(),
    );

    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      final result = await _subscriptionRepository.purchaseProduct(
        productId: productId,
      );

      return result.fold(
        (failure) {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              error: PremiumError(
                type: PremiumErrorType.purchase,
                message: failure.message,
              ),
            ),
          );
          return false;
        },
        (subscription) {
          state = AsyncValue.data(
            currentState.copyWith(
              currentSubscription: subscription,
              isLoading: false,
              error: null,
            ),
          );
          return true;
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          error: PremiumError(
            type: PremiumErrorType.purchase,
            message: e.toString(),
          ),
        ),
      );
      return false;
    }
  }

  /// Restaura compras anteriores
  Future<bool> restorePurchases() async {
    final currentState = state.maybeWhen(
      data: (data) => data,
      orElse: () => const PremiumState(),
    );

    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      final result = await _subscriptionRepository.restorePurchases();

      return result.fold(
        (failure) {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              error: PremiumError(
                type: PremiumErrorType.purchase,
                message: failure.message,
              ),
            ),
          );
          return false;
        },
        (subscriptions) {
          state = AsyncValue.data(
            currentState.copyWith(isLoading: false, error: null),
          );
          return subscriptions.isNotEmpty;
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          error: PremiumError(
            type: PremiumErrorType.purchase,
            message: e.toString(),
          ),
        ),
      );
      return false;
    }
  }

  /// Limpa erro atual
  void clearError() {
    state = state.maybeWhen(
      data: (data) => AsyncValue.data(data.copyWith(error: null)),
      orElse: () => state,
    );
  }

  /// Força sincronização do status
  Future<void> forceSyncSubscription() async {
    final currentState = state.maybeWhen(
      data: (data) => data,
      orElse: () => const PremiumState(),
    );

    state = AsyncValue.data(currentState.copyWith(isSyncing: true));

    try {
      final result = await _subscriptionRepository.getCurrentSubscription();
      result.fold(
        (failure) {
          state = AsyncValue.data(
            currentState.copyWith(
              isSyncing: false,
              hasSyncErrors: true,
              syncErrorMessage: failure.message,
            ),
          );
        },
        (subscription) {
          state = AsyncValue.data(
            currentState.copyWith(
              currentSubscription: subscription,
              isSyncing: false,
              hasSyncErrors: false,
              lastSyncAt: DateTime.now(),
              syncErrorMessage: null,
              syncRetryCount: 0,
            ),
          );
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          isSyncing: false,
          hasSyncErrors: true,
          syncErrorMessage: e.toString(),
        ),
      );
    }
  }

  // === Feature Check Methods ===

  bool canCreateUnlimitedLists() {
    return state.maybeWhen(
      data: (data) => data.premiumStatus.canUseFeature('unlimited_lists'),
      orElse: () => false,
    );
  }

  bool canCreateUnlimitedTasks() {
    return state.maybeWhen(
      data: (data) => data.premiumStatus.canUseFeature('unlimited_tasks'),
      orElse: () => false,
    );
  }

  bool canUseCloudSync() {
    return state.maybeWhen(
      data: (data) => data.premiumStatus.canUseFeature('cloud_sync'),
      orElse: () => false,
    );
  }

  bool canShareLists() {
    return state.maybeWhen(
      data: (data) => data.premiumStatus.canUseFeature('shared_lists'),
      orElse: () => false,
    );
  }

  bool canUseSmartReminders() {
    return state.maybeWhen(
      data: (data) => data.premiumStatus.canUseFeature('smart_reminders'),
      orElse: () => false,
    );
  }

  bool canUseAdvancedCategories() {
    return state.maybeWhen(
      data: (data) => data.premiumStatus.canUseFeature('advanced_categories'),
      orElse: () => false,
    );
  }

  bool canAccessStatistics() {
    return state.maybeWhen(
      data: (data) => data.premiumStatus.canUseFeature('detailed_statistics'),
      orElse: () => false,
    );
  }

  bool canUsePremiumThemes() {
    return state.maybeWhen(
      data: (data) => data.premiumStatus.canUseFeature('premium_themes'),
      orElse: () => false,
    );
  }

  bool canExportData() {
    return state.maybeWhen(
      data: (data) => data.premiumStatus.canUseFeature('data_export'),
      orElse: () => false,
    );
  }

  bool canUseRecurringTasks() {
    return state.maybeWhen(
      data: (data) => data.premiumStatus.canUseFeature('recurring_tasks'),
      orElse: () => false,
    );
  }

  // === Limit Check Methods ===

  int getMaxLists() {
    return state.maybeWhen(
      data: (data) => data.premiumStatus.limits.maxLists,
      orElse: () => UsageLimits.free.maxLists,
    );
  }

  int getMaxTasksPerList() {
    return state.maybeWhen(
      data: (data) => data.premiumStatus.limits.maxTasksPerList,
      orElse: () => UsageLimits.free.maxTasksPerList,
    );
  }

  bool hasReachedListLimit(int currentCount) {
    return state.maybeWhen(
      data: (data) => data.premiumStatus.hasReachedLimit(
        limitType: 'lists',
        currentCount: currentCount,
      ),
      orElse: () => currentCount >= UsageLimits.free.maxLists,
    );
  }

  bool hasReachedTaskLimit(int currentCount) {
    return state.maybeWhen(
      data: (data) => data.premiumStatus.hasReachedLimit(
        limitType: 'tasks_per_list',
        currentCount: currentCount,
      ),
      orElse: () => currentCount >= UsageLimits.free.maxTasksPerList,
    );
  }

  /// Debug info
  Map<String, dynamic> getDebugInfo() {
    return state.maybeWhen(
      data: (data) => {
        'isPremium': data.isPremium,
        'isInTrial': data.isInTrial,
        'isSyncing': data.isSyncing,
        'hasSyncErrors': data.hasSyncErrors,
        'lastSyncAt': data.lastSyncAt?.toIso8601String(),
        'subscription': data.currentSubscription?.toString(),
        'featuresEnabled': data.premiumFeaturesEnabled,
        'usageLimits': data.usageLimits,
        'syncError': data.syncErrorMessage,
        'retryCount': data.syncRetryCount,
      },
      orElse: () => {},
    );
  }
}

/// Provider de conveniência para verificar se é premium
@riverpod
bool isPremium(Ref ref) {
  return ref.watch(premiumProvider).maybeWhen(
        data: (state) => state.isPremium,
        orElse: () => false,
      );
}

/// Provider de conveniência para PremiumStatus
@riverpod
PremiumStatus premiumStatus(Ref ref) {
  return ref.watch(premiumProvider).maybeWhen(
        data: (state) => state.premiumStatus,
        orElse: () => PremiumStatus.free,
      );
}

/// Alias para compatibilidade com padrões de outros apps
const premiumNotifierProvider = premiumProvider;

/// Product IDs do Nebulalist
class NebulalistProductIds {
  static const String monthlyPremium = 'nebulalist_premium_monthly';
  static const String semesterPremium = 'nebulalist_premium_semester';
  static const String annualPremium = 'nebulalist_premium_annual';

  static const List<String> all = [
    monthlyPremium,
    semesterPremium,
    annualPremium,
  ];
}
