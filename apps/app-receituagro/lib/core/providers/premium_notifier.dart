import 'dart:async';
import 'dart:developer' as developer;

import 'package:core/core.dart' hide PremiumFeature, Column;
import 'package:flutter/foundation.dart';

import '../../features/analytics/analytics_service.dart';
import '../providers/core_providers.dart' as local_providers;
import '../services/cloud_functions_service.dart';
import '../services/premium_service.dart';
import '../services/remote_config_service.dart';

part 'premium_notifier.g.dart';

/// Premium state
class PremiumState {
  final bool isInitialized;
  final bool isLoading;
  final PremiumStatus status;
  final List<ProductInfo> availableProducts;
  final SubscriptionEntity? currentSubscription;
  final String? lastError;

  const PremiumState({
    required this.isInitialized,
    required this.isLoading,
    required this.status,
    required this.availableProducts,
    this.currentSubscription,
    this.lastError,
  });

  factory PremiumState.initial() {
    return PremiumState(
      isInitialized: false,
      isLoading: false,
      status: PremiumStatus.free(),
      availableProducts: const [],
      currentSubscription: null,
      lastError: null,
    );
  }

  PremiumState copyWith({
    bool? isInitialized,
    bool? isLoading,
    PremiumStatus? status,
    List<ProductInfo>? availableProducts,
    SubscriptionEntity? currentSubscription,
    String? lastError,
  }) {
    return PremiumState(
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      status: status ?? this.status,
      availableProducts: availableProducts ?? this.availableProducts,
      currentSubscription: currentSubscription ?? this.currentSubscription,
      lastError: lastError ?? this.lastError,
    );
  }

  PremiumState clearError() {
    return copyWith(lastError: null);
  }
  bool get isPremium => status.isPremium;
  bool get isActive => status.isActive;
  bool get isTrialActive => status.isTrialActive;
}

/// Premium notifier for subscription management
@riverpod
class PremiumNotifier extends _$PremiumNotifier {
  late final ReceitaAgroAnalyticsService _analytics;
  late final ReceitaAgroCloudFunctionsService _cloudFunctions;
  late final ReceitaAgroRemoteConfigService _remoteConfig;
  late final ISubscriptionRepository _subscriptionRepository;

  StreamSubscription<SubscriptionEntity?>? _subscriptionStreamSubscription;

  @override
  Future<PremiumState> build() async {
    _analytics = ref.watch(local_providers.analyticsServiceProvider);
    // _cloudFunctions = ref.watch(receitaAgroCloudFunctionsServiceProvider);
    _cloudFunctions = ReceitaAgroCloudFunctionsService.instance;
    _remoteConfig = ReceitaAgroRemoteConfigService.instance;
    _subscriptionRepository = ref.watch(local_providers.subscriptionRepositoryProvider);
    ref.onDispose(() {
      _subscriptionStreamSubscription?.cancel();
      if (EnvironmentConfig.enableLogging) {
        developer.log(
          '🧹 Subscription stream listener cancelled',
          name: 'PremiumNotifier',
        );
      }
    });

    try {
      if (kIsWeb) {
        developer.log(
          '🌐 Premium Service: Skipping on web platform',
          name: 'PremiumNotifier',
        );

        return PremiumState.initial().copyWith(
          isInitialized: true,
          status: PremiumStatus.free(),
        );
      }
      _subscriptionStreamSubscription = _subscriptionRepository.subscriptionStatus.listen(
        _handleSubscriptionUpdate,
        onError: (Object error) {
          developer.log(
            '⚠️ Subscription stream error: $error',
            name: 'PremiumNotifier',
            error: error,
          );
        },
      );
      final currentSubscription = await _loadCurrentSubscription();
      final availableProducts = await _loadProducts();

      PremiumStatus status = PremiumStatus.free();
      if (currentSubscription != null) {
        status = _createPremiumStatusFromEntity(currentSubscription);
      } else {
        // Se não há assinatura no cache local, tenta restaurar automaticamente
        developer.log(
          '🔄 No cached subscription found, attempting auto-restore...',
          name: 'PremiumNotifier',
        );
        unawaited(_attemptAutoRestore());
      }

      if (EnvironmentConfig.enableLogging) {
        developer.log(
          '✅ Premium Service initialized (using core ISubscriptionRepository)',
          name: 'PremiumNotifier',
        );
      }

      await _analytics.logEvent(
        ReceitaAgroAnalyticsEvent.appOpened.eventName,
        {
          'premium_status': status.isPremium ? 'premium' : 'free',
        },
      );

      return PremiumState(
        isInitialized: true,
        isLoading: false,
        status: status,
        availableProducts: availableProducts,
        currentSubscription: currentSubscription,
      );
    } catch (e, stackTrace) {
      await _analytics.recordError(
        e,
        stackTrace,
        reason: 'Premium Service initialization failed',
      );

      developer.log(
        '❌ Premium Service initialization failed: $e',
        name: 'PremiumNotifier',
        error: e,
        stackTrace: stackTrace,
      );

      return PremiumState.initial().copyWith(
        lastError: 'Failed to initialize Premium Service: $e',
      );
    }
  }

  /// Purchase a premium subscription
  Future<Either<String, SubscriptionEntity>> purchaseProduct(String productId) async {
    final currentState = state.value;
    if (currentState == null || !currentState.isInitialized) {
      return const Left('Premium Service not initialized');
    }
    state = AsyncValue.data(currentState.copyWith(isLoading: true).clearError());

    try {
      await _analytics.logSubscriptionEvent(
        'purchase_started',
        productId,
      );

      final result = await _subscriptionRepository.purchaseProduct(productId: productId);

      return result.fold(
        (failure) {
          final errorMessage = 'Purchase failed: ${failure.message}';
          state = AsyncValue.data(
            currentState.copyWith(isLoading: false, lastError: errorMessage),
          );
          return Left(errorMessage);
        },
        (subscription) async {
          final newStatus = _createPremiumStatusFromEntity(subscription);
          await _syncSubscriptionWithCloudFunctions(subscription);

          await _analytics.logSubscriptionEvent(
            'purchased',
            productId,
            additionalData: {
              'tier': subscription.tier.name,
              'status': subscription.status.name,
            },
          );

          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              currentSubscription: subscription,
              status: newStatus,
            ),
          );

          return Right(subscription);
        },
      );
    } catch (e, stackTrace) {
      final errorMessage = 'Purchase failed: $e';

      await _analytics.recordError(
        e,
        stackTrace,
        reason: 'Purchase failed: $productId',
      );

      developer.log(
        '❌ Purchase failed: $e',
        name: 'PremiumNotifier',
        error: e,
        stackTrace: stackTrace,
      );

      state = AsyncValue.data(
        currentState.copyWith(isLoading: false, lastError: errorMessage),
      );

      return Left(errorMessage);
    }
  }

  /// Restore purchases
  Future<Either<String, List<SubscriptionEntity>>> restorePurchases() async {
    final currentState = state.value;
    if (currentState == null || !currentState.isInitialized) {
      return const Left('Premium Service not initialized');
    }
    state = AsyncValue.data(currentState.copyWith(isLoading: true).clearError());

    try {
      final result = await _subscriptionRepository.restorePurchases();

      return result.fold(
        (failure) {
          final errorMessage = 'Restore failed: ${failure.message}';
          state = AsyncValue.data(
            currentState.copyWith(isLoading: false, lastError: errorMessage),
          );
          return Left(errorMessage);
        },
        (subscriptions) async {
          SubscriptionEntity? activeSubscription;
          PremiumStatus newStatus = PremiumStatus.free();

          if (subscriptions.isNotEmpty) {
            activeSubscription = subscriptions.firstWhere(
              (sub) => sub.isActive,
              orElse: () => subscriptions.first,
            );
            newStatus = _createPremiumStatusFromEntity(activeSubscription);
            await _syncSubscriptionWithCloudFunctions(activeSubscription);
          }

          await _analytics.logEvent(
            ReceitaAgroAnalyticsEvent.subscriptionViewed.eventName,
            {
              'action': 'restore',
              'active_subscriptions': subscriptions.where((s) => s.isActive).length,
            },
          );

          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              currentSubscription: activeSubscription,
              status: newStatus,
            ),
          );

          return Right(subscriptions);
        },
      );
    } catch (e, stackTrace) {
      final errorMessage = 'Restore failed: $e';

      await _analytics.recordError(
        e,
        stackTrace,
        reason: 'Restore purchases failed',
      );

      state = AsyncValue.data(
        currentState.copyWith(isLoading: false, lastError: errorMessage),
      );

      return Left(errorMessage);
    }
  }

  /// Check if user has access to a premium feature
  bool hasFeatureAccess(PremiumFeature feature) {
    final currentState = state.value;
    if (currentState == null) return false;
    switch (feature) {
      case PremiumFeature.advancedDiagnostics:
        if (!_remoteConfig.isFeatureEnabled(ReceitaAgroFeatureFlag.enableAdvancedDiagnostics)) {
          return false;
        }
        break;
      case PremiumFeature.offlineMode:
        if (!_remoteConfig.isFeatureEnabled(ReceitaAgroFeatureFlag.enableOfflineMode)) {
          return false;
        }
        break;
      default:
        break;
    }

    return currentState.status.hasFeature(feature);
  }

  /// Get feature access denial reason
  String getFeatureAccessDenialReason(PremiumFeature feature) {
    final currentState = state.value;
    if (currentState == null) return 'Serviço não inicializado';

    if (!_remoteConfig.isFeatureEnabled(ReceitaAgroFeatureFlag.enablePremiumFeatures)) {
      return 'Feature temporariamente indisponível';
    }

    if (!currentState.status.isPremium) {
      return 'Recurso disponível apenas para usuários Premium';
    }

    if (!currentState.status.isActive) {
      return 'Assinatura Premium inativa ou expirada';
    }

    if (!currentState.status.hasFeature(feature)) {
      return 'Recurso não incluído no seu plano atual';
    }

    return 'Acesso negado';
  }

  /// Show premium upgrade screen
  Future<void> showPremiumUpgrade(PremiumFeature requestedFeature) async {
    await _analytics.logPremiumAttempt(requestedFeature.toString());
    developer.log(
      '💰 Premium upgrade requested for feature: $requestedFeature',
      name: 'PremiumNotifier',
    );
  }

  /// Get current subscription data (compatibility method)
  Map<String, dynamic>? getCurrentSubscription() {
    final currentState = state.value;
    if (currentState == null || !currentState.status.isPremium || !currentState.status.isActive) {
      return null;
    }

    return {
      'productId': currentState.status.productId,
      'expirationDate': currentState.status.expirationDate?.toIso8601String(),
      'isActive': currentState.status.isActive,
      'isTrialActive': currentState.status.isTrialActive,
      'trialEndDate': currentState.status.trialEndDate?.toIso8601String(),
      'isInGracePeriod': currentState.status.isInGracePeriod,
      'devicesUsed': currentState.status.devicesUsed,
      'maxDevices': currentState.status.maxDevices,
    };
  }

  /// Get debug information
  Map<String, dynamic> getDebugInfo() {
    final currentState = state.value;
    if (currentState == null) return {};

    return {
      'initialized': currentState.isInitialized,
      'isPremium': currentState.status.isPremium,
      'isActive': currentState.status.isActive,
      'productId': currentState.status.productId,
      'expirationDate': currentState.status.expirationDate?.toIso8601String(),
      'availableProducts': currentState.availableProducts.length,
      'lastError': currentState.lastError,
    };
  }

  /// Load current subscription and update status
  Future<SubscriptionEntity?> _loadCurrentSubscription() async {
    try {
      final result = await _subscriptionRepository.getCurrentSubscription();
      return result.fold(
        (failure) {
          developer.log(
            '⚠️ Failed to load subscription: ${failure.message}',
            name: 'PremiumNotifier',
          );
          return null;
        },
        (subscription) => subscription,
      );
    } catch (e) {
      developer.log(
        '⚠️ Failed to load current subscription: $e',
        name: 'PremiumNotifier',
        error: e,
      );
      return null;
    }
  }

  /// Load available products
  Future<List<ProductInfo>> _loadProducts() async {
    try {
      final result = await _subscriptionRepository.getReceitaAgroProducts();
      return result.fold(
        (failure) {
          developer.log(
            '⚠️ Failed to load products: ${failure.message}',
            name: 'PremiumNotifier',
          );
          return [];
        },
        (products) => products,
      );
    } catch (e) {
      developer.log(
        '⚠️ Failed to load products: $e',
        name: 'PremiumNotifier',
        error: e,
      );
      return [];
    }
  }

  /// Handle subscription updates from stream
  void _handleSubscriptionUpdate(SubscriptionEntity? subscription) {
    final currentState = state.value;
    if (currentState == null) return;

    if (subscription != null) {
      final newStatus = _createPremiumStatusFromEntity(subscription);
      _syncSubscriptionWithCloudFunctions(subscription);
      state = AsyncValue.data(
        currentState.copyWith(
          currentSubscription: subscription,
          status: newStatus,
        ),
      );
    } else {
      state = AsyncValue.data(
        currentState.copyWith(
          currentSubscription: null,
          status: PremiumStatus.free(),
        ),
      );
    }
  }

  /// Create premium status from subscription entity
  PremiumStatus _createPremiumStatusFromEntity(SubscriptionEntity subscription) {
    if (subscription.isActive && subscription.isReceitaAgroSubscription) {
      return PremiumStatus.premium(
        expirationDate: subscription.expirationDate ?? DateTime.now().add(const Duration(days: 30)),
        productId: subscription.productId,
        isTrialActive: subscription.isTrialActive,
        maxDevices: _remoteConfig.getIntConfig(ReceitaAgroConfigKey.maxDevicesPerSubscription),
      );
    } else {
      return PremiumStatus.free();
    }
  }

  /// Sync subscription with cloud functions
  Future<void> _syncSubscriptionWithCloudFunctions(SubscriptionEntity subscription) async {
    try {
      if (subscription.isActive) {
        await _cloudFunctions.syncRevenueCatPurchase(
          receiptData: subscription.originalPurchaseDate?.toIso8601String() ?? '',
          productId: subscription.productId,
          purchaseToken: subscription.id,
        );
      }
    } catch (e) {
      developer.log(
        '⚠️ Failed to sync with cloud functions: $e',
        name: 'PremiumNotifier',
        error: e,
      );
    }
  }

  /// Attempt automatic restore on initialization (background operation)
  /// Called when no cached subscription is found
  Future<void> _attemptAutoRestore() async {
    try {
      developer.log(
        '🔄 Starting automatic restore purchases...',
        name: 'PremiumNotifier',
      );

      final result = await _subscriptionRepository.restorePurchases();

      await result.fold(
        (failure) async {
          developer.log(
            '⚠️ Auto-restore failed: ${failure.message}',
            name: 'PremiumNotifier',
          );
        },
        (subscriptions) async {
          if (subscriptions.isNotEmpty) {
            final activeSubscription = subscriptions.firstWhere(
              (sub) => sub.isActive,
              orElse: () => subscriptions.first,
            );

            if (activeSubscription.isActive) {
              developer.log(
                '✅ Auto-restore successful: Found active subscription (${activeSubscription.productId})',
                name: 'PremiumNotifier',
              );

              // Update state with restored subscription
              final currentState = state.value;
              if (currentState != null) {
                final newStatus = _createPremiumStatusFromEntity(activeSubscription);
                await _syncSubscriptionWithCloudFunctions(activeSubscription);

                state = AsyncValue.data(
                  currentState.copyWith(
                    currentSubscription: activeSubscription,
                    status: newStatus,
                  ),
                );

                await _analytics.logEvent(
                  ReceitaAgroAnalyticsEvent.subscriptionViewed.eventName,
                  {
                    'action': 'auto_restore',
                    'product_id': activeSubscription.productId,
                  },
                );
              }
            } else {
              developer.log(
                'ℹ️ Auto-restore: No active subscriptions found',
                name: 'PremiumNotifier',
              );
            }
          } else {
            developer.log(
              'ℹ️ Auto-restore: No subscriptions to restore',
              name: 'PremiumNotifier',
            );
          }
        },
      );
    } catch (e) {
      developer.log(
        '⚠️ Auto-restore error: $e',
        name: 'PremiumNotifier',
        error: e,
      );
      // Não lança erro - auto-restore é uma operação silenciosa
    }
  }
}
