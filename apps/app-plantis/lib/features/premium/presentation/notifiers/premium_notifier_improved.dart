import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:core/core.dart' hide getIt;

import '../../../../core/widgets/loading_overlay.dart';
import '../../data/services/subscription_sync_service.dart';

part 'premium_notifier_improved.g.dart';

/// State para gerenciamento Premium avançado com sincronização cross-device
class PremiumImprovedState {
  final SubscriptionEntity? currentSubscription;
  final List<ProductInfo> availableProducts;
  final bool isLoading;
  final String? errorMessage;
  final PurchaseOperation? currentOperation;
  final bool isSyncing;
  final DateTime? lastSyncAt;
  final List<String> premiumFeaturesEnabled;
  final Map<String, dynamic>? plantLimits;
  final int syncRetryCount;
  final PlantisSubscriptionSyncEvent? lastSyncEvent;

  const PremiumImprovedState({
    this.currentSubscription,
    this.availableProducts = const [],
    this.isLoading = false,
    this.errorMessage,
    this.currentOperation,
    this.isSyncing = false,
    this.lastSyncAt,
    this.premiumFeaturesEnabled = const [],
    this.plantLimits,
    this.syncRetryCount = 0,
    this.lastSyncEvent,
  });

  bool get isPremium => currentSubscription?.isActive ?? false;
  bool get isInTrial => currentSubscription?.isInTrial ?? false;
  bool get canPurchasePremium => true;

  bool get hasSyncErrors =>
      lastSyncEvent?.type == PlantisSubscriptionSyncEventType.failed;
  String? get syncErrorMessage => hasSyncErrors ? lastSyncEvent?.error : null;

  String get subscriptionStatus {
    if (currentSubscription == null) return 'Gratuito';
    if (currentSubscription!.isActive) {
      if (currentSubscription!.isInTrial) return 'Trial';
      return 'Premium';
    }
    return 'Expirado';
  }

  DateTime? get expirationDate => currentSubscription?.expirationDate;

  PremiumImprovedState copyWith({
    SubscriptionEntity? currentSubscription,
    List<ProductInfo>? availableProducts,
    bool? isLoading,
    String? errorMessage,
    PurchaseOperation? currentOperation,
    bool? isSyncing,
    DateTime? lastSyncAt,
    List<String>? premiumFeaturesEnabled,
    Map<String, dynamic>? plantLimits,
    int? syncRetryCount,
    PlantisSubscriptionSyncEvent? lastSyncEvent,
  }) {
    return PremiumImprovedState(
      currentSubscription: currentSubscription ?? this.currentSubscription,
      availableProducts: availableProducts ?? this.availableProducts,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      currentOperation: currentOperation,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      premiumFeaturesEnabled:
          premiumFeaturesEnabled ?? this.premiumFeaturesEnabled,
      plantLimits: plantLimits ?? this.plantLimits,
      syncRetryCount: syncRetryCount ?? this.syncRetryCount,
      lastSyncEvent: lastSyncEvent,
    );
  }
}

/// Notifier para gerenciamento Premium avançado com sincronização cross-device
@riverpod
class PremiumImprovedNotifier extends _$PremiumImprovedNotifier {
  late final ISubscriptionRepository _subscriptionRepository;
  late final IAuthRepository _authRepository;
  late final IAnalyticsRepository _analytics;
  late final SubscriptionSyncService _syncService;

  StreamSubscription<SubscriptionEntity?>? _subscriptionStream;
  StreamSubscription<UserEntity?>? _authStream;
  StreamSubscription<PlantisSubscriptionSyncEvent>? _syncEventsStream;
  StreamSubscription<SubscriptionEntity?>? _realtimeSubscriptionStream;

  @override
  Future<PremiumImprovedState> build() async {
    _subscriptionRepository = ref.read(subscriptionRepositoryProvider);
    _authRepository = ref.read(authRepositoryProvider);
    _analytics = ref.read(analyticsRepositoryProvider);

    _syncService = SubscriptionSyncService(
      authRepository: _authRepository,
      subscriptionRepository: _subscriptionRepository,
      analytics: _analytics,
    );

    // Setup subscriptions
    _setupSubscriptions();

    // Load initial data
    await _loadAvailableProducts();
    await _checkCurrentSubscription();

    // Start auto sync
    _syncService.startAutoSync();

    return const PremiumImprovedState();
  }

  void _setupSubscriptions() {
    // Escuta eventos de sincronização em tempo real
    _syncEventsStream = _syncService.syncEventsStream.listen(
      (event) async {
        final currentState = state.valueOrNull ?? const PremiumImprovedState();

        switch (event.type) {
          case PlantisSubscriptionSyncEventType.success:
            state = AsyncValue.data(
              currentState.copyWith(
                isSyncing: false,
                lastSyncAt: event.syncedAt,
                syncRetryCount: 0,
                premiumFeaturesEnabled: event.premiumFeaturesEnabled ?? [],
                lastSyncEvent: event,
              ),
            );
            await _loadPlantLimits();
            break;

          case PlantisSubscriptionSyncEventType.failed:
            state = AsyncValue.data(
              currentState.copyWith(
                isSyncing: false,
                syncRetryCount: event.retryCount ?? 0,
                errorMessage: event.error,
                lastSyncEvent: event,
              ),
            );
            break;

          case PlantisSubscriptionSyncEventType.purchased:
            await _handlePurchaseEvent(event);
            break;

          case PlantisSubscriptionSyncEventType.cancelled:
            await _handleCancellationEvent(event);
            break;

          case PlantisSubscriptionSyncEventType.expired:
            await _handleExpirationEvent(event);
            break;

          default:
            state = AsyncValue.data(
              currentState.copyWith(lastSyncEvent: event),
            );
            break;
        }
      },
      onError: (Object error) {
        final currentState = state.valueOrNull ?? const PremiumImprovedState();
        state = AsyncValue.data(
          currentState.copyWith(
            errorMessage: 'Erro na sincronização: $error',
            isSyncing: false,
          ),
        );
      },
    );

    // Escuta mudanças na assinatura do RevenueCat
    _subscriptionStream =
        _subscriptionRepository.subscriptionStatus.listen((subscription) async {
      final currentState = state.valueOrNull ?? const PremiumImprovedState();
      state = AsyncValue.data(
        currentState.copyWith(currentSubscription: subscription),
      );

      // Trigger sincronização cross-device
      await _triggerSync();
    });

    // Escuta stream de assinatura em tempo real do Firebase
    _realtimeSubscriptionStream =
        _syncService.getRealtimeSubscriptionStream().listen((subscription) {
      final currentState = state.valueOrNull ?? const PremiumImprovedState();
      if (subscription != currentState.currentSubscription) {
        state = AsyncValue.data(
          currentState.copyWith(currentSubscription: subscription),
        );
      }
    });

    // Escuta mudanças de autenticação
    _authStream = _authRepository.currentUser.listen((user) {
      if (user != null) {
        _syncUserSubscription(user.id);
      } else {
        _resetSubscriptionState();
      }
    });

    // Cleanup on dispose
    ref.onDispose(() {
      _syncService.stopAutoSync();
      _subscriptionStream?.cancel();
      _authStream?.cancel();
      _syncEventsStream?.cancel();
      _realtimeSubscriptionStream?.cancel();
      _syncService.dispose();
    });
  }

  Future<void> _syncUserSubscription(String userId) async {
    try {
      await _subscriptionRepository.setUser(
        userId: userId,
        attributes: {
          'app': 'plantis',
          'platform': defaultTargetPlatform.name,
          'version': await _getAppVersion(),
          'syncEnabled': 'true',
        },
      );
      await _checkCurrentSubscription();
      await _triggerSync();
    } catch (e) {
      debugPrint('[PremiumImprovedNotifier] Erro ao sincronizar usuário: $e');
    }
  }

  Future<void> _triggerSync() async {
    final currentState = state.valueOrNull ?? const PremiumImprovedState();
    if (currentState.isSyncing) return;

    try {
      state = AsyncValue.data(currentState.copyWith(isSyncing: true));
      await _syncService.syncSubscriptionStatus();
    } catch (e) {
      debugPrint('[PremiumImprovedNotifier] Erro na sincronização: $e');
      state = AsyncValue.data(
        currentState.copyWith(
          errorMessage: 'Erro na sincronização: $e',
          isSyncing: false,
        ),
      );
    }
  }

  void _resetSubscriptionState() {
    state = AsyncValue.data(
      const PremiumImprovedState(
        currentSubscription: null,
        premiumFeaturesEnabled: [],
        plantLimits: null,
        lastSyncAt: null,
        syncRetryCount: 0,
        lastSyncEvent: null,
      ),
    );
  }

  Future<void> _checkCurrentSubscription() async {
    final currentState = state.valueOrNull ?? const PremiumImprovedState();
    state = AsyncValue.data(
      currentState.copyWith(
        isLoading: true,
        errorMessage: null,
        currentOperation: PurchaseOperation.loadProducts,
      ),
    );

    final result = await _subscriptionRepository.getCurrentSubscription();

    result.fold(
      (failure) {
        state = AsyncValue.data(
          currentState.copyWith(
            errorMessage: failure.message,
            isLoading: false,
            currentOperation: null,
          ),
        );
      },
      (subscription) {
        state = AsyncValue.data(
          currentState.copyWith(
            currentSubscription: subscription,
            isLoading: false,
            currentOperation: null,
          ),
        );
      },
    );
  }

  Future<void> _loadAvailableProducts() async {
    final result = await _subscriptionRepository.getPlantisProducts();

    result.fold(
      (failure) {
        debugPrint('Erro ao carregar produtos: ${failure.message}');
      },
      (products) {
        final currentState = state.valueOrNull ?? const PremiumImprovedState();
        state = AsyncValue.data(
          currentState.copyWith(availableProducts: products),
        );
      },
    );
  }

  Future<bool> purchaseProduct(String productId) async {
    final currentState = state.valueOrNull ?? const PremiumImprovedState();
    state = AsyncValue.data(
      currentState.copyWith(
        isLoading: true,
        errorMessage: null,
        currentOperation: PurchaseOperation.purchase,
      ),
    );

    final result = await _subscriptionRepository.purchaseProduct(
      productId: productId,
    );

    return result.fold(
      (failure) {
        state = AsyncValue.data(
          currentState.copyWith(
            errorMessage: failure.message,
            isLoading: false,
            currentOperation: null,
          ),
        );
        return false;
      },
      (subscription) async {
        state = AsyncValue.data(
          currentState.copyWith(
            currentSubscription: subscription,
            isLoading: false,
            currentOperation: null,
          ),
        );

        // Trigger sincronização após compra
        await _triggerSync();

        // Log analytics
        final product = currentState.availableProducts.firstWhere(
          (p) => p.productId == productId,
          orElse: () => ProductInfo(
            productId: productId,
            title: '',
            description: '',
            price: 0.0,
            priceString: '',
            currencyCode: 'BRL',
          ),
        );

        await _syncService.logPurchaseEvent(
          productId: productId,
          price: product.price,
          currency: product.currencyCode,
        );

        await _analytics.logEvent(
          'plantis_purchase_success',
          parameters: {
            'product_id': productId,
            'price': product.price.toString(),
            'tier': subscription.tier.name,
          },
        );

        return true;
      },
    );
  }

  Future<bool> restorePurchases() async {
    final currentState = state.valueOrNull ?? const PremiumImprovedState();
    state = AsyncValue.data(
      currentState.copyWith(
        isLoading: true,
        errorMessage: null,
        currentOperation: PurchaseOperation.restore,
      ),
    );

    final result = await _subscriptionRepository.restorePurchases();

    return result.fold(
      (failure) {
        state = AsyncValue.data(
          currentState.copyWith(
            errorMessage: failure.message,
            isLoading: false,
            currentOperation: null,
          ),
        );
        return false;
      },
      (subscriptions) {
        if (subscriptions.isNotEmpty) {
          final activeSubscriptions =
              subscriptions.where((s) => s.isActive).toList();

          if (activeSubscriptions.isNotEmpty) {
            state = AsyncValue.data(
              currentState.copyWith(
                currentSubscription: activeSubscriptions.first,
                isLoading: false,
                currentOperation: null,
              ),
            );
          }
        } else {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              currentOperation: null,
            ),
          );
        }
        return true;
      },
    );
  }

  Future<String?> getManagementUrl() async {
    final result = await _subscriptionRepository.getManagementUrl();
    return result.fold((failure) => null, (url) => url);
  }

  Future<bool> checkEligibilityForTrial(String productId) async {
    final result = await _subscriptionRepository.isEligibleForTrial(
      productId: productId,
    );
    return result.fold((failure) => false, (isEligible) => isEligible);
  }

  void clearError() {
    final currentState = state.valueOrNull ?? const PremiumImprovedState();
    state = AsyncValue.data(currentState.copyWith(errorMessage: null));
  }

  void clearCurrentOperation() {
    final currentState = state.valueOrNull ?? const PremiumImprovedState();
    state = AsyncValue.data(currentState.copyWith(currentOperation: null));
  }

  // Advanced feature checks
  bool canCreateUnlimitedPlants() {
    final currentState = state.valueOrNull;
    final maxPlants = currentState?.plantLimits?['maxPlants'] as int?;
    return maxPlants == -1 || (currentState?.isPremium ?? false);
  }

  bool canAccessAdvancedFeatures() {
    final currentState = state.valueOrNull;
    return (currentState?.isPremium ?? false) &&
        currentState!.premiumFeaturesEnabled.contains('advanced_reminders');
  }

  bool canExportData() {
    final currentState = state.valueOrNull;
    return (currentState?.isPremium ?? false) &&
        currentState!.premiumFeaturesEnabled.contains('export_data');
  }

  bool canUseCustomReminders() {
    final currentState = state.valueOrNull;
    return (currentState?.isPremium ?? false) &&
        currentState!.premiumFeaturesEnabled.contains('advanced_reminders');
  }

  bool canAccessPremiumThemes() {
    final currentState = state.valueOrNull;
    return (currentState?.isPremium ?? false) &&
        currentState!.premiumFeaturesEnabled.contains('custom_themes');
  }

  bool canBackupToCloud() {
    final currentState = state.valueOrNull;
    return (currentState?.isPremium ?? false) &&
        currentState!.premiumFeaturesEnabled.contains('cloud_backup');
  }

  bool canIdentifyPlants() {
    final currentState = state.valueOrNull;
    return (currentState?.isPremium ?? false) &&
        currentState!.premiumFeaturesEnabled.contains('plant_identification');
  }

  bool canDiagnoseDiseases() {
    final currentState = state.valueOrNull;
    return (currentState?.isPremium ?? false) &&
        currentState!.premiumFeaturesEnabled.contains('disease_diagnosis');
  }

  bool canUseWeatherNotifications() {
    final currentState = state.valueOrNull;
    return (currentState?.isPremium ?? false) &&
        currentState!.premiumFeaturesEnabled
            .contains('weather_based_notifications');
  }

  bool canUseCareCalendar() {
    final currentState = state.valueOrNull;
    return (currentState?.isPremium ?? false) &&
        currentState!.premiumFeaturesEnabled.contains('care_calendar');
  }

  bool hasFeature(String featureId) {
    final currentState = state.valueOrNull;
    if (!(currentState?.isPremium ?? false)) return false;
    return currentState!.premiumFeaturesEnabled.contains(featureId);
  }

  int getCurrentPlantLimit() {
    final currentState = state.valueOrNull;
    final maxPlants = currentState?.plantLimits?['maxPlants'] as int?;
    return maxPlants == -1 ? 999999 : (maxPlants ?? 5);
  }

  bool canCreateMorePlants(int currentPlantCount) {
    if (canCreateUnlimitedPlants()) return true;
    return currentPlantCount < getCurrentPlantLimit();
  }

  // Event handlers
  Future<void> _handlePurchaseEvent(
    PlantisSubscriptionSyncEvent event,
  ) async {
    await _analytics.logEvent(
      'plantis_purchase_synced',
      parameters: {
        'product_id': event.productId ?? 'unknown',
        'purchased_at': event.purchasedAt?.toIso8601String() ?? 'unknown',
      },
    );

    await _checkCurrentSubscription();
    await _loadPlantLimits();
  }

  Future<void> _handleCancellationEvent(
    PlantisSubscriptionSyncEvent event,
  ) async {
    await _analytics.logEvent(
      'plantis_cancellation_synced',
      parameters: {
        'reason': event.reason ?? 'unknown',
        'expires_at': event.expiresAt?.toIso8601String() ?? 'unknown',
      },
    );
  }

  Future<void> _handleExpirationEvent(
    PlantisSubscriptionSyncEvent event,
  ) async {
    await _analytics.logEvent(
      'plantis_expiration_synced',
      parameters: {
        'expired_at': event.expiredAt?.toIso8601String() ?? 'unknown',
      },
    );

    final currentState = state.valueOrNull ?? const PremiumImprovedState();
    state = AsyncValue.data(
      currentState.copyWith(
        premiumFeaturesEnabled: [],
        plantLimits: {'maxPlants': 5, 'canCreateCustomCategories': false},
      ),
    );
  }

  Future<void> _loadPlantLimits() async {
    try {
      final user = await _authRepository.currentUser.first;
      if (user == null) return;

      final currentState = state.valueOrNull ?? const PremiumImprovedState();
      state = AsyncValue.data(
        currentState.copyWith(
          plantLimits: {
            'maxPlants': currentState.isPremium ? -1 : 5,
            'canCreateCustomCategories': currentState.isPremium,
            'canImportPlantData': currentState.isPremium,
            'lastUpdated': DateTime.now().toIso8601String(),
          },
        ),
      );
    } catch (e) {
      debugPrint('[PremiumImprovedNotifier] Erro ao carregar limites: $e');
    }
  }

  Future<String> _getAppVersion() async {
    return '1.0.0';
  }

  // Public methods
  Future<void> forceSyncSubscription() async {
    await _triggerSync();
  }

  void clearSyncErrors() {
    final currentState = state.valueOrNull ?? const PremiumImprovedState();
    state = AsyncValue.data(
      currentState.copyWith(
        errorMessage: null,
        syncRetryCount: 0,
        lastSyncEvent: null,
      ),
    );
  }

  Map<String, dynamic> getSyncStatus() {
    final currentState = state.valueOrNull ?? const PremiumImprovedState();
    return {
      'isSyncing': currentState.isSyncing,
      'lastSyncAt': currentState.lastSyncAt?.toIso8601String(),
      'hasErrors': currentState.hasSyncErrors,
      'errorMessage': currentState.syncErrorMessage,
      'retryCount': currentState.syncRetryCount,
      'featuresCount': currentState.premiumFeaturesEnabled.length,
    };
  }

  Map<String, dynamic> getDebugInfo() {
    final currentState = state.valueOrNull ?? const PremiumImprovedState();
    return {
      'subscription': {
        'isActive': currentState.isPremium,
        'isInTrial': currentState.isInTrial,
        'tier': currentState.currentSubscription?.tier.name,
        'productId': currentState.currentSubscription?.productId,
        'expirationDate':
            currentState.expirationDate?.toIso8601String(),
      },
      'sync': getSyncStatus(),
      'features': {
        'enabled': currentState.premiumFeaturesEnabled,
        'plantLimits': currentState.plantLimits,
      },
      'products': currentState.availableProducts
          .map((p) => {'id': p.productId, 'price': p.priceString})
          .toList(),
    };
  }
}

// Dependency Providers
@riverpod
ISubscriptionRepository subscriptionRepository(Ref ref) {
  return GetIt.instance<ISubscriptionRepository>();
}

@riverpod
IAuthRepository authRepository(Ref ref) {
  return GetIt.instance<IAuthRepository>();
}

@riverpod
IAnalyticsRepository analyticsRepository(Ref ref) {
  return GetIt.instance<IAnalyticsRepository>();
}
