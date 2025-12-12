import 'dart:async';

import 'package:core/core.dart' hide Column, subscriptionRepositoryProvider;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../../../core/services/plantis_sync_service.dart';
import '../../../../database/repositories/subscription_local_repository.dart';
import '../../domain/providers/premium_usecases_provider.dart';
import '../../domain/providers/premium_validation_provider.dart';
import '../../domain/services/premium_validation_service.dart';
import '../../domain/usecases/get_current_subscription_usecase.dart';
import '../../domain/usecases/load_available_products_usecase.dart';
import '../../domain/usecases/purchase_product_usecase.dart';
import '../../domain/usecases/restore_purchases_usecase.dart';

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
  late final SubscriptionLocalRepository _localRepository;
  late final IAuthRepository _authRepository;
  late final PremiumValidationService _validationService;

  // UseCases
  late final PurchaseProductUseCase _purchaseProductUseCase;
  late final RestorePurchasesUseCase _restorePurchasesUseCase;
  late final LoadAvailableProductsUseCase _loadAvailableProductsUseCase;
  late final GetCurrentSubscriptionUseCase _getCurrentSubscriptionUseCase;

  late final PlantisSyncService _syncService;

  @override
  Future<PremiumState> build() async {
    // Inject repositories via Riverpod
    _subscriptionRepository = ref.watch(subscriptionRepositoryProvider);
    _localRepository = ref.watch(subscriptionLocalRepositoryProvider);
    _analytics = ref.watch(firebaseAnalyticsServiceProvider);
    _authRepository = ref.watch(authRepositoryProvider);
    _validationService = ref.watch(premiumValidationServiceProvider);
    _syncService = ref.watch(plantisSyncServiceProvider);

    // Inject UseCases
    _purchaseProductUseCase = ref.watch(purchaseProductUseCaseProvider);
    _restorePurchasesUseCase = ref.watch(restorePurchasesUseCaseProvider);
    _loadAvailableProductsUseCase = ref.watch(
      loadAvailableProductsUseCaseProvider,
    );
    _getCurrentSubscriptionUseCase = ref.watch(
      getCurrentSubscriptionUseCaseProvider,
    );

    return await _initialize();
  }

  Future<PremiumState> _initialize() async {
    try {
      // 1. Try to load from local cache first
      try {
        final user = await _authRepository.currentUser.first;
        if (user != null) {
          final localSub = await _localRepository.getActiveSubscription(
            user.id,
          );
          if (localSub != null) {
            return PremiumState(currentSubscription: localSub);
          }
        }
      } catch (e) {
        // Ignore local cache errors
      }

      final result = await _subscriptionRepository.getCurrentSubscription();
      return result.fold(
        (failure) => PremiumState(
          error: PremiumError(
            type: PremiumErrorType.unknown,
            message: failure.message,
          ),
        ),
        (subscription) {
          // Save to local cache
          if (subscription != null) {
            _localRepository.saveSubscription(subscription);
          }
          return PremiumState(currentSubscription: subscription);
        },
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
      final result = await _loadAvailableProductsUseCase(
        LoadAvailableProductsParams(productIds: productIds),
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
      final result = await _purchaseProductUseCase(
        PurchaseProductParams(productId: productId),
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

          // Save to local cache
          _localRepository.saveSubscription(subscription);

          // Trigger sync to Firebase
          _syncService.sync();

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
      final result = await _restorePurchasesUseCase();

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
        (hasSubscriptions) {
          // Subscription will be automatically reloaded by the provider
          state = AsyncValue.data(
            currentState.copyWith(isLoading: false, error: null),
          );

          return hasSubscriptions;
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

          // Save to local cache
          if (subscription != null) {
            _localRepository.saveSubscription(subscription);
          }
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
