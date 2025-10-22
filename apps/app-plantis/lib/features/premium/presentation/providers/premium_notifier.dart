import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/widgets/loading_overlay.dart';
import '../../data/services/subscription_sync_service.dart';

part 'premium_notifier.freezed.dart';
part 'premium_notifier.g.dart';

/// Error handling types for premium operations
enum PremiumErrorType { network, auth, purchase, sync, unknown }

/// Premium error details
class PremiumError {
  final PremiumErrorType type;
  final String message;
  const PremiumError({required this.type, required this.message});
}

/// Unified state for Premium/Subscription management with advanced sync features
@freezed
class PremiumState with _$PremiumState {
  const factory PremiumState({
    SubscriptionEntity? currentSubscription,
    @Default([]) List<ProductInfo> availableProducts,
    @Default(false) bool isLoading,
    PremiumError? error,
    PurchaseOperation? currentOperation,
    // Advanced sync features
    @Default(false) bool isSyncing,
    DateTime? lastSyncAt,
    @Default([]) List<String> premiumFeaturesEnabled,
    Map<String, dynamic>? plantLimits,
    @Default(0) int syncRetryCount,
    PlantisSubscriptionSyncEvent? lastSyncEvent,
  }) = _PremiumState;

  const PremiumState._();

  /// Basic premium status
  bool get isPremium => currentSubscription?.isActive ?? false;
  bool get isInTrial => currentSubscription?.isInTrial ?? false;
  bool get canPurchasePremium => true;

  /// Subscription status text
  String get subscriptionStatus {
    if (currentSubscription == null) return 'Gratuito';
    if (currentSubscription!.isActive) {
      if (currentSubscription!.isInTrial) return 'Trial';
      return 'Premium';
    }
    return 'Expirado';
  }

  /// Sync status
  bool get hasSyncErrors =>
      lastSyncEvent?.type == PlantisSubscriptionSyncEventType.failed;
  String? get syncErrorMessage => hasSyncErrors ? lastSyncEvent?.error : null;

  DateTime? get expirationDate => currentSubscription?.expirationDate;
}

/// Unified Premium provider with advanced sync capabilities
/// Consolidates features from all previous implementations
@riverpod
class PremiumNotifier extends _$PremiumNotifier {
  ISubscriptionRepository get _subscriptionRepository =>
      ref.read(subscriptionRepositoryProvider);
  IAuthRepository get _authRepository => ref.read(authRepositoryProvider);
  IAnalyticsRepository get _analytics => ref.read(analyticsRepositoryProvider);
  SimpleSubscriptionSyncService? get _simpleSubscriptionSyncService =>
      ref.read(simpleSubscriptionSyncServiceProvider);

  late final SubscriptionSyncService _syncService;

  StreamSubscription<SubscriptionEntity?>? _subscriptionStream;
  StreamSubscription<SubscriptionEntity?>? _syncSubscriptionStream;
  StreamSubscription<SubscriptionEntity?>? _realtimeSubscriptionStream;
  StreamSubscription<UserEntity?>? _authStream;
  StreamSubscription<PlantisSubscriptionSyncEvent>? _syncEventsStream;

  @override
  PremiumState build() {
    // Initialize advanced sync service
    _syncService = SubscriptionSyncService(
      authRepository: _authRepository,
      subscriptionRepository: _subscriptionRepository,
      analytics: _analytics,
    );

    ref.onDispose(() {
      _syncService.stopAutoSync();
      _subscriptionStream?.cancel();
      _syncSubscriptionStream?.cancel();
      _realtimeSubscriptionStream?.cancel();
      _authStream?.cancel();
      _syncEventsStream?.cancel();
      _syncService.dispose();

      if (kDebugMode) {
        debugPrint('[PremiumNotifier] Disposed successfully');
      }
    });

    _initialize();

    return const PremiumState();
  }

  void _initialize() {
    // Setup advanced sync events stream
    _syncEventsStream = _syncService.syncEventsStream.listen(
      (event) async {
        switch (event.type) {
          case PlantisSubscriptionSyncEventType.success:
            state = state.copyWith(
              isSyncing: false,
              lastSyncAt: event.syncedAt,
              syncRetryCount: 0,
              premiumFeaturesEnabled: event.premiumFeaturesEnabled ?? [],
              lastSyncEvent: event,
            );
            await _loadPlantLimits();
            break;

          case PlantisSubscriptionSyncEventType.failed:
            state = state.copyWith(
              isSyncing: false,
              syncRetryCount: event.retryCount ?? 0,
              error: PremiumError(
                type: PremiumErrorType.sync,
                message: event.error ?? 'Erro na sincronização',
              ),
              lastSyncEvent: event,
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
            state = state.copyWith(lastSyncEvent: event);
            break;
        }
      },
      onError: (Object error) {
        state = state.copyWith(
          error: PremiumError(
            type: PremiumErrorType.sync,
            message: 'Erro na sincronização: $error',
          ),
          isSyncing: false,
        );
      },
    );

    // Setup basic subscription streams
    if (_simpleSubscriptionSyncService != null) {
      _syncSubscriptionStream =
          _simpleSubscriptionSyncService!.subscriptionStatus.listen(
        (subscription) {
          state = state.copyWith(currentSubscription: subscription);
        },
        onError: (Object error) {
          state = state.copyWith(
            error: PremiumError(
              type: PremiumErrorType.unknown,
              message: error.toString(),
            ),
          );
        },
      );
    } else {
      _subscriptionStream = _subscriptionRepository.subscriptionStatus.listen(
        (subscription) async {
          state = state.copyWith(currentSubscription: subscription);
          await _triggerSync();
        },
        onError: (Object error) {
          state = state.copyWith(
            error: PremiumError(
              type: PremiumErrorType.unknown,
              message: error.toString(),
            ),
          );
        },
      );
    }

    // Setup realtime subscription stream
    _realtimeSubscriptionStream =
        _syncService.getRealtimeSubscriptionStream().listen(
      (subscription) {
        if (subscription != state.currentSubscription) {
          state = state.copyWith(currentSubscription: subscription);
        }
      },
      onError: (Object error) {
        if (kDebugMode) {
          debugPrint('[PremiumNotifier] Erro no stream Firebase: $error');
        }
      },
    );

    // Setup auth stream
    _authStream = _authRepository.currentUser.listen((user) {
      if (user != null) {
        _syncUserSubscription(user.id);
      } else {
        _resetSubscriptionState();
      }
    });

    _loadAvailableProducts();
    _checkCurrentSubscription();
    _syncService.startAutoSync();
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
      if (kDebugMode) {
        debugPrint('[PremiumNotifier] Erro ao sincronizar usuário: $e');
      }
    }
  }

  Future<void> _triggerSync() async {
    if (state.isSyncing) return;

    try {
      state = state.copyWith(isSyncing: true);
      await _syncService.syncSubscriptionStatus();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PremiumNotifier] Erro na sincronização: $e');
      }
      state = state.copyWith(
        error: PremiumError(
          type: PremiumErrorType.sync,
          message: 'Erro na sincronização: $e',
        ),
        isSyncing: false,
      );
    }
  }

  void _resetSubscriptionState() {
    state = const PremiumState(
      currentSubscription: null,
      premiumFeaturesEnabled: [],
      plantLimits: null,
      lastSyncAt: null,
      syncRetryCount: 0,
      lastSyncEvent: null,
    );
  }

  /// Helper method to run operations with consistent state handling
  Future<Either<Failure, T>> _runOperation<T>(
    PurchaseOperation operation,
    Future<Either<Failure, T>> Function() action,
  ) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      currentOperation: operation,
    );

    final result = await action();

    result.fold((failure) {
      state = state.copyWith(
        error: PremiumError(
          type: PremiumErrorType.unknown,
          message: failure.message,
        ),
      );
    }, (_) {});

    state = state.copyWith(isLoading: false, currentOperation: null);

    return result;
  }

  Future<void> _loadAvailableProducts() async {
    final result = await _runOperation<List<ProductInfo>>(
      PurchaseOperation.loadProducts,
      () => _subscriptionRepository.getPlantisProducts(),
    );

    result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint('Erro ao carregar produtos: ${failure.message}');
        }
      },
      (products) {
        state = state.copyWith(availableProducts: products);
      },
    );
  }

  Future<void> _checkCurrentSubscription() async {
    if (_simpleSubscriptionSyncService != null) {
      await _runOperation<bool>(
        PurchaseOperation.loadProducts,
        () => _simpleSubscriptionSyncService!.hasActiveSubscriptionForApp(
          'plantis',
        ),
      );
    } else {
      final result = await _runOperation<SubscriptionEntity?>(
        PurchaseOperation.loadProducts,
        () => _subscriptionRepository.getCurrentSubscription(),
      );
      result.fold((failure) {}, (subscription) {
        state = state.copyWith(currentSubscription: subscription);
      });
    }
  }

  /// Purchase a product
  Future<bool> purchaseProduct(String productId) async {
    final result = await _runOperation<SubscriptionEntity>(
      PurchaseOperation.purchase,
      () => _subscriptionRepository.purchaseProduct(productId: productId),
    );

    return result.fold((failure) => false, (subscription) async {
      state = state.copyWith(currentSubscription: subscription);

      // Trigger sync and log analytics
      await _triggerSync();

      final product = state.availableProducts.firstWhere(
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
    });
  }

  /// Restore previous purchases
  Future<bool> restorePurchases() async {
    final result = await _runOperation<List<SubscriptionEntity>>(
      PurchaseOperation.restore,
      () => _subscriptionRepository.restorePurchases(),
    );

    return result.fold((failure) => false, (subscriptions) {
      if (subscriptions.isNotEmpty) {
        final active = subscriptions.where((s) => s.isActive).toList();
        if (active.isNotEmpty) {
          state = state.copyWith(currentSubscription: active.first);
        }
      }
      return true;
    });
  }

  /// Get subscription management URL
  Future<String?> getManagementUrl() async {
    final result = await _subscriptionRepository.getManagementUrl();
    return result.fold((failure) => null, (url) => url);
  }

  /// Check if eligible for trial
  Future<bool> checkEligibilityForTrial(String productId) async {
    final result = await _subscriptionRepository.isEligibleForTrial(
      productId: productId,
    );
    return result.fold((failure) => false, (isEligible) => isEligible);
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Clear current operation
  void clearCurrentOperation() {
    state = state.copyWith(currentOperation: null);
  }

  // ========== Premium Feature Checks ==========

  bool canCreateUnlimitedPlants() {
    final maxPlants = state.plantLimits?['maxPlants'] as int?;
    return maxPlants == -1 || state.isPremium;
  }

  bool canAccessAdvancedFeatures() =>
      state.isPremium &&
      state.premiumFeaturesEnabled.contains('advanced_reminders');

  bool canExportData() =>
      state.isPremium && state.premiumFeaturesEnabled.contains('export_data');

  bool canUseCustomReminders() =>
      state.isPremium &&
      state.premiumFeaturesEnabled.contains('advanced_reminders');

  bool canAccessPremiumThemes() =>
      state.isPremium &&
      state.premiumFeaturesEnabled.contains('custom_themes');

  bool canBackupToCloud() =>
      state.isPremium &&
      state.premiumFeaturesEnabled.contains('cloud_backup');

  bool canIdentifyPlants() =>
      state.isPremium &&
      state.premiumFeaturesEnabled.contains('plant_identification');

  bool canDiagnoseDiseases() =>
      state.isPremium &&
      state.premiumFeaturesEnabled.contains('disease_diagnosis');

  bool canUseWeatherNotifications() =>
      state.isPremium &&
      state.premiumFeaturesEnabled.contains('weather_based_notifications');

  bool canUseCareCalendar() =>
      state.isPremium &&
      state.premiumFeaturesEnabled.contains('care_calendar');

  bool hasFeature(String featureId) {
    if (!state.isPremium) return false;

    // Fallback to basic features if sync features not loaded
    if (state.premiumFeaturesEnabled.isEmpty) {
      const premiumFeatures = [
        'unlimited_plants',
        'advanced_reminders',
        'export_data',
        'custom_themes',
        'cloud_backup',
        'detailed_analytics',
        'plant_identification',
        'disease_diagnosis',
      ];
      return premiumFeatures.contains(featureId);
    }

    return state.premiumFeaturesEnabled.contains(featureId);
  }

  int getCurrentPlantLimit() {
    final maxPlants = state.plantLimits?['maxPlants'] as int?;
    return maxPlants == -1 ? 999999 : (maxPlants ?? 5); // 5 is free tier limit
  }

  bool canCreateMorePlants(int currentPlantCount) {
    if (canCreateUnlimitedPlants()) return true;
    return currentPlantCount < getCurrentPlantLimit();
  }

  // ========== Advanced Sync Features ==========

  /// Force manual sync
  Future<void> forceSyncSubscription() async {
    await _triggerSync();
  }

  /// Clear sync errors
  void clearSyncErrors() {
    state = state.copyWith(
      error: null,
      syncRetryCount: 0,
      lastSyncEvent: null,
    );
  }

  /// Get sync status for UI
  Map<String, dynamic> getSyncStatus() {
    return {
      'isSyncing': state.isSyncing,
      'lastSyncAt': state.lastSyncAt?.toIso8601String(),
      'hasErrors': state.hasSyncErrors,
      'errorMessage': state.syncErrorMessage,
      'retryCount': state.syncRetryCount,
      'featuresCount': state.premiumFeaturesEnabled.length,
    };
  }

  /// Get debug info
  Map<String, dynamic> getDebugInfo() {
    return {
      'subscription': {
        'isActive': state.isPremium,
        'isInTrial': state.isInTrial,
        'tier': state.currentSubscription?.tier.name,
        'productId': state.currentSubscription?.productId,
        'expirationDate': state.expirationDate?.toIso8601String(),
      },
      'sync': getSyncStatus(),
      'features': {
        'enabled': state.premiumFeaturesEnabled,
        'plantLimits': state.plantLimits,
      },
      'products': state.availableProducts
          .map((p) => {'id': p.productId, 'price': p.priceString})
          .toList(),
    };
  }

  // ========== Event Handlers ==========

  Future<void> _handlePurchaseEvent(PlantisSubscriptionSyncEvent event) async {
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
    state = state.copyWith(
      premiumFeaturesEnabled: [],
      plantLimits: {'maxPlants': 5, 'canCreateCustomCategories': false},
    );
  }

  Future<void> _loadPlantLimits() async {
    try {
      final user = await _authRepository.currentUser.first;
      if (user == null) return;

      state = state.copyWith(
        plantLimits: {
          'maxPlants': state.isPremium ? -1 : 5,
          'canCreateCustomCategories': state.isPremium,
          'canImportPlantData': state.isPremium,
          'lastUpdated': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PremiumNotifier] Erro ao carregar limites: $e');
      }
    }
  }

  Future<String> _getAppVersion() async {
    return '1.0.0'; // TODO: Get from package_info
  }
}

// ========== Dependency Providers ==========

@riverpod
ISubscriptionRepository subscriptionRepository(
  SubscriptionRepositoryRef ref,
) {
  return GetIt.instance<ISubscriptionRepository>();
}

@riverpod
IAuthRepository authRepository(AuthRepositoryRef ref) {
  return GetIt.instance<IAuthRepository>();
}

@riverpod
IAnalyticsRepository analyticsRepository(AnalyticsRepositoryRef ref) {
  return GetIt.instance<IAnalyticsRepository>();
}

@riverpod
SimpleSubscriptionSyncService? simpleSubscriptionSyncService(
  SimpleSubscriptionSyncServiceRef ref,
) {
  try {
    return GetIt.instance<SimpleSubscriptionSyncService>();
  } catch (e) {
    return null; // Service is optional
  }
}

/// Type alias for backwards compatibility
typedef PremiumProvider = PremiumNotifier;
