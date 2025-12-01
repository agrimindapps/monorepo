import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:core/core.dart' hide Column;

part 'premium_notifier.g.dart';

enum PremiumErrorType { network, auth, purchase, sync, unknown }

class PremiumError {
  final PremiumErrorType type;
  final String message;

  const PremiumError({required this.type, required this.message});
}

class PremiumState {
  final SubscriptionEntity? currentSubscription;
  final List<ProductInfo> availableProducts;
  final bool isLoading;
  final PremiumError? error;
  final bool isSyncing;
  final bool hasSyncErrors;
  final DateTime? lastSyncAt;
  final List<String> premiumFeaturesEnabled;
  final Map<String, int>? plantLimits;
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
    this.plantLimits,
    this.syncErrorMessage,
    this.syncRetryCount = 0,
  });

  bool get isPremium => currentSubscription?.isActive ?? false;
  bool get isInTrial => currentSubscription?.isInTrial ?? false;

  PremiumState copyWith({
    SubscriptionEntity? currentSubscription,
    List<ProductInfo>? availableProducts,
    bool? isLoading,
    PremiumError? error,
    bool? isSyncing,
    bool? hasSyncErrors,
    DateTime? lastSyncAt,
    List<String>? premiumFeaturesEnabled,
    Map<String, int>? plantLimits,
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
      plantLimits: plantLimits ?? this.plantLimits,
      syncErrorMessage: syncErrorMessage ?? this.syncErrorMessage,
      syncRetryCount: syncRetryCount ?? this.syncRetryCount,
    );
  }
}

@riverpod
class PremiumNotifier extends _$PremiumNotifier {
  late final ISubscriptionRepository _subscriptionRepository;
  late final IAnalyticsRepository _analytics;

  @override
  Future<PremiumState> build() async {
    _initializeRepositories();
    return await _initialize();
  }

  void _initializeRepositories() {
    // TODO: Inject repositories via Riverpod
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

          unawaited(
            _analytics.logEvent(
              'premium_purchased',
              parameters: {'product_id': productId},
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
          final active = subscriptions.where((s) => s.isActive).toList();
          if (active.isNotEmpty) {
            state = AsyncValue.data(
              currentState.copyWith(
                currentSubscription: active.first,
                isLoading: false,
                error: null,
              ),
            );
          } else {
            state = AsyncValue.data(
              currentState.copyWith(isLoading: false, error: null),
            );
          }
          return active.isNotEmpty;
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

  void clearError() {
    state = state.maybeWhen(
      data: (data) => AsyncValue.data(data.copyWith(error: null)),
      orElse: () => state,
    );
  }

  bool canCreateUnlimitedPlants() {
    return state.maybeWhen(
      data: (data) {
        // Delegated to PremiumFeaturesManager for consistency
        return data.premiumFeaturesEnabled.contains('unlimited_plants');
      },
      orElse: () => false,
    );
  }

  int getCurrentPlantLimit() {
    return state.maybeWhen(
      data: (data) => data.plantLimits?['default'] ?? 5,
      orElse: () => 5,
    );
  }

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

  void clearSyncErrors() {
    state = state.maybeWhen(
      data: (data) => AsyncValue.data(
        data.copyWith(
          hasSyncErrors: false,
          syncErrorMessage: null,
          syncRetryCount: 0,
        ),
      ),
      orElse: () => state,
    );
  }

  Map<String, dynamic> getDebugInfo() {
    return state.maybeWhen(
      data: (data) => {
        'isPremium': data.isPremium,
        'isSyncing': data.isSyncing,
        'hasSyncErrors': data.hasSyncErrors,
        'lastSyncAt': data.lastSyncAt?.toIso8601String(),
        'subscription': data.currentSubscription?.toString(),
        'featuresEnabled': data.premiumFeaturesEnabled,
        'plantLimits': data.plantLimits,
        'syncError': data.syncErrorMessage,
        'retryCount': data.syncRetryCount,
      },
      orElse: () => {},
    );
  }

  bool canUseCustomReminders() {
    return state.maybeWhen(
      data: (data) => data.premiumFeaturesEnabled.contains('custom_reminders'),
      orElse: () => false,
    );
  }

  bool canExportData() {
    return state.maybeWhen(
      data: (data) => data.premiumFeaturesEnabled.contains('export_data'),
      orElse: () => false,
    );
  }

  bool canAccessPremiumThemes() {
    return state.maybeWhen(
      data: (data) => data.premiumFeaturesEnabled.contains('premium_themes'),
      orElse: () => false,
    );
  }

  bool canBackupToCloud() {
    return state.maybeWhen(
      data: (data) => data.premiumFeaturesEnabled.contains('cloud_backup'),
      orElse: () => false,
    );
  }

  bool canIdentifyPlants() {
    return state.maybeWhen(
      data: (data) =>
          data.premiumFeaturesEnabled.contains('plant_identification'),
      orElse: () => false,
    );
  }

  bool canDiagnoseDiseases() {
    return state.maybeWhen(
      data: (data) => data.premiumFeaturesEnabled.contains('disease_diagnosis'),
      orElse: () => false,
    );
  }

  bool canUseWeatherNotifications() {
    return state.maybeWhen(
      data: (data) =>
          data.premiumFeaturesEnabled.contains('weather_notifications'),
      orElse: () => false,
    );
  }

  bool canUseCareCalendar() {
    return state.maybeWhen(
      data: (data) => data.premiumFeaturesEnabled.contains('care_calendar'),
      orElse: () => false,
    );
  }
}

// LEGACY ALIAS
// ignore: deprecated_member_use_from_same_package
const premiumNotifierProvider = premiumProvider;
