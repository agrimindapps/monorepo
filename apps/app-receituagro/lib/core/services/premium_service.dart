import 'dart:async';
import 'dart:developer' as developer;

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../features/analytics/analytics_service.dart';
import 'cloud_functions_service.dart';
import 'remote_config_service.dart';

/// Premium subscription products for ReceitaAgro
enum ReceitaAgroPremiumProduct {
  monthly('receituagro_premium_monthly'),
  yearly('receituagro_premium_yearly');

  const ReceitaAgroPremiumProduct(this.productId);
  final String productId;
  
  String get environmentSpecificId => EnvironmentConfig.getProductId(productId);
}

/// Premium feature permissions
enum PremiumFeature {
  advancedDiagnostics,
  offlineMode,
  unlimitedSearches,
  exportReports,
  prioritySupport,
  additionalDevices,
  customBranding;
}

/// Premium subscription status
class PremiumStatus {
  final bool isPremium;
  final bool isActive;
  final DateTime? expirationDate;
  final String? productId;
  final bool isTrialActive;
  final DateTime? trialEndDate;
  final bool isInGracePeriod;
  final int devicesUsed;
  final int maxDevices;
  final Map<PremiumFeature, bool> featurePermissions;

  const PremiumStatus({
    required this.isPremium,
    required this.isActive,
    this.expirationDate,
    this.productId,
    this.isTrialActive = false,
    this.trialEndDate,
    this.isInGracePeriod = false,
    this.devicesUsed = 1,
    this.maxDevices = 3,
    this.featurePermissions = const {},
  });

  factory PremiumStatus.free() {
    return const PremiumStatus(
      isPremium: false,
      isActive: false,
      featurePermissions: {
        PremiumFeature.advancedDiagnostics: false,
        PremiumFeature.offlineMode: false,
        PremiumFeature.unlimitedSearches: false,
        PremiumFeature.exportReports: false,
        PremiumFeature.prioritySupport: false,
        PremiumFeature.additionalDevices: false,
        PremiumFeature.customBranding: false,
      },
    );
  }

  factory PremiumStatus.premium({
    required DateTime expirationDate,
    required String productId,
    bool isTrialActive = false,
    DateTime? trialEndDate,
    int devicesUsed = 1,
    int maxDevices = 3,
  }) {
    return PremiumStatus(
      isPremium: true,
      isActive: true,
      expirationDate: expirationDate,
      productId: productId,
      isTrialActive: isTrialActive,
      trialEndDate: trialEndDate,
      devicesUsed: devicesUsed,
      maxDevices: maxDevices,
      featurePermissions: const {
        PremiumFeature.advancedDiagnostics: true,
        PremiumFeature.offlineMode: true,
        PremiumFeature.unlimitedSearches: true,
        PremiumFeature.exportReports: true,
        PremiumFeature.prioritySupport: true,
        PremiumFeature.additionalDevices: true,
        PremiumFeature.customBranding: false, // Only for enterprise
      },
    );
  }

  bool hasFeature(PremiumFeature feature) {
    return featurePermissions[feature] ?? false;
  }

  bool get canAddDevice => devicesUsed < maxDevices;
  bool get isNearDeviceLimit => devicesUsed >= (maxDevices * 0.8);
}

/// ReceitaAgro Premium Service
/// Handles subscription management, premium features, and RevenueCat integration
/// Now uses core ISubscriptionRepository instead of direct purchases_flutter calls
class ReceitaAgroPremiumService extends ChangeNotifier {
  final ReceitaAgroAnalyticsService _analytics;
  final ReceitaAgroCloudFunctionsService _cloudFunctions;
  final ReceitaAgroRemoteConfigService _remoteConfig;
  final ISubscriptionRepository _subscriptionRepository;

  /// Constructor with dependency injection
  ReceitaAgroPremiumService({
    required ReceitaAgroAnalyticsService analytics,
    required ReceitaAgroCloudFunctionsService cloudFunctions,
    required ReceitaAgroRemoteConfigService remoteConfig,
    required ISubscriptionRepository subscriptionRepository,
  })  : _analytics = analytics,
        _cloudFunctions = cloudFunctions,
        _remoteConfig = remoteConfig,
        _subscriptionRepository = subscriptionRepository;

  /// Factory for singleton pattern (optional, for backward compatibility)
  /// DEPRECATED: Use constructor injection via DI container instead
  @Deprecated('Use constructor injection via GetIt or Provider instead')
  static ReceitaAgroPremiumService? _instance;

  @Deprecated('Use constructor injection via GetIt or Provider instead')
  static ReceitaAgroPremiumService get instance {
    if (_instance == null) {
      throw StateError(
        'ReceitaAgroPremiumService not initialized. '
        'Use constructor injection instead of singleton pattern.',
      );
    }
    return _instance!;
  }

  /// Set singleton instance (for backward compatibility only)
  /// DEPRECATED: Use constructor injection instead
  @Deprecated('Use constructor injection via GetIt or Provider instead')
  static void setInstance(ReceitaAgroPremiumService service) {
    _instance = service;
  }

  bool _initialized = false;
  bool _isDisposed = false;
  PremiumStatus _status = PremiumStatus.free();
  List<ProductInfo> _availableProducts = [];
  SubscriptionEntity? _currentSubscription;
  String? _lastError;
  bool _isLoading = false;
  StreamSubscription<SubscriptionEntity?>? _subscriptionStreamSubscription;
  bool get initialized => _initialized;
  PremiumStatus get status => _status;
  List<ProductInfo> get availableProducts => _availableProducts;
  SubscriptionEntity? get currentSubscription => _currentSubscription;
  String? get lastError => _lastError;
  bool get isLoading => _isLoading;
  bool get isPremium => _status.isPremium;
  bool get isActive => _status.isActive;
  bool get isTrialActive => _status.isTrialActive;

  /// Initialize Premium Service
  Future<void> initialize() async {
    if (_initialized) return;

    _setLoading(true);

    try {
      if (kIsWeb) {
        developer.log(
          '🌐 Premium Service: Skipping on web platform',
          name: 'PremiumService',
        );
        _status = PremiumStatus.free();
        _initialized = true;
        _setLoading(false);

        developer.log(
          '✅ Premium Service initialized (web mock mode)',
          name: 'PremiumService',
        );
        return;
      }
      _subscriptionStreamSubscription = _subscriptionRepository.subscriptionStatus.listen(
        _handleSubscriptionUpdate,
        onError: (Object error) {
          developer.log(
            '⚠️ Subscription stream error: $error',
            name: 'PremiumService',
            error: error,
          );
        },
      );
      await _loadCurrentSubscription();
      await _loadProducts();

      _initialized = true;

      if (EnvironmentConfig.enableLogging) {
        developer.log(
          '✅ Premium Service initialized (using core ISubscriptionRepository)',
          name: 'PremiumService',
        );
      }

      await _analytics.logEvent(
        ReceitaAgroAnalyticsEvent.appOpened.eventName,
        {
          'premium_status': _status.isPremium ? 'premium' : 'free',
        },
      );
    } catch (e, stackTrace) {
      _setError('Failed to initialize Premium Service: $e');

      await _analytics.recordError(
        e,
        stackTrace,
        reason: 'Premium Service initialization failed',
      );

      developer.log(
        '❌ Premium Service initialization failed: $e',
        name: 'PremiumService',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Purchase a premium subscription
  Future<Either<String, SubscriptionEntity>> purchaseProduct(String productId) async {
    if (!_initialized) {
      return const Left('Premium Service not initialized');
    }

    _setLoading(true);
    _clearError();

    try {
      await _analytics.logSubscriptionEvent(
        'purchase_started',
        productId,
      );

      final result = await _subscriptionRepository.purchaseProduct(productId: productId);

      return result.fold(
        (failure) {
          final errorMessage = 'Purchase failed: ${failure.message}';
          _setError(errorMessage);
          return Left(errorMessage);
        },
        (subscription) async {
          _currentSubscription = subscription;
          _updatePremiumStatusFromEntity(subscription);
          await _syncSubscriptionWithCloudFunctions(subscription);

          await _analytics.logSubscriptionEvent(
            'purchased',
            productId,
            additionalData: {
              'tier': subscription.tier.name,
              'status': subscription.status.name,
            },
          );

          return Right(subscription);
        },
      );
    } catch (e, stackTrace) {
      final errorMessage = 'Purchase failed: $e';
      _setError(errorMessage);

      await _analytics.recordError(
        e,
        stackTrace,
        reason: 'Purchase failed: $productId',
      );

      developer.log(
        '❌ Purchase failed: $e',
        name: 'PremiumService',
        error: e,
        stackTrace: stackTrace,
      );

      return Left(errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  /// Restore purchases
  Future<Either<String, List<SubscriptionEntity>>> restorePurchases() async {
    if (!_initialized) {
      return const Left('Premium Service not initialized');
    }

    _setLoading(true);
    _clearError();

    try {
      final result = await _subscriptionRepository.restorePurchases();

      return result.fold(
        (failure) {
          final errorMessage = 'Restore failed: ${failure.message}';
          _setError(errorMessage);
          return Left(errorMessage);
        },
        (subscriptions) async {
          if (subscriptions.isNotEmpty) {
            final activeSubscription = subscriptions.firstWhere(
              (sub) => sub.isActive,
              orElse: () => subscriptions.first,
            );
            _currentSubscription = activeSubscription;
            _updatePremiumStatusFromEntity(activeSubscription);
            await _syncSubscriptionWithCloudFunctions(activeSubscription);
          }

          await _analytics.logEvent(
            ReceitaAgroAnalyticsEvent.subscriptionViewed.eventName,
            {
              'action': 'restore',
              'active_subscriptions': subscriptions.where((s) => s.isActive).length,
            },
          );

          return Right(subscriptions);
        },
      );
    } catch (e, stackTrace) {
      final errorMessage = 'Restore failed: $e';
      _setError(errorMessage);

      await _analytics.recordError(
        e,
        stackTrace,
        reason: 'Restore purchases failed',
      );

      return Left(errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  /// Check if user has access to a premium feature
  bool hasFeatureAccess(PremiumFeature feature) {
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

    return _status.hasFeature(feature);
  }

  /// Get feature access denial reason
  String getFeatureAccessDenialReason(PremiumFeature feature) {
    if (!_remoteConfig.isFeatureEnabled(ReceitaAgroFeatureFlag.enablePremiumFeatures)) {
      return 'Feature temporariamente indisponível';
    }

    if (!_status.isPremium) {
      return 'Recurso disponível apenas para usuários Premium';
    }

    if (!_status.isActive) {
      return 'Assinatura Premium inativa ou expirada';
    }

    if (!_status.hasFeature(feature)) {
      return 'Recurso não incluído no seu plano atual';
    }

    return 'Acesso negado';
  }

  /// Show premium upgrade screen
  Future<void> showPremiumUpgrade(PremiumFeature requestedFeature) async {
    await _analytics.logPremiumAttempt(requestedFeature.toString());
    developer.log(
      '💰 Premium upgrade requested for feature: $requestedFeature',
      name: 'PremiumService',
    );
  }

  /// Load current subscription and update status
  Future<void> _loadCurrentSubscription() async {
    try {
      final result = await _subscriptionRepository.getCurrentSubscription();
      result.fold(
        (failure) {
          developer.log(
            '⚠️ Failed to load subscription: ${failure.message}',
            name: 'PremiumService',
          );
        },
        (subscription) {
          _currentSubscription = subscription;
          if (subscription != null) {
            _updatePremiumStatusFromEntity(subscription);
          }
        },
      );
    } catch (e) {
      developer.log(
        '⚠️ Failed to load current subscription: $e',
        name: 'PremiumService',
        error: e,
      );
    }
  }

  /// Load available products
  Future<void> _loadProducts() async {
    try {
      final result = await _subscriptionRepository.getReceitaAgroProducts();
      result.fold(
        (failure) {
          developer.log(
            '⚠️ Failed to load products: ${failure.message}',
            name: 'PremiumService',
          );
        },
        (products) {
          _availableProducts = products;
        },
      );
    } catch (e) {
      developer.log(
        '⚠️ Failed to load products: $e',
        name: 'PremiumService',
        error: e,
      );
    }
  }

  /// Handle subscription updates from stream
  void _handleSubscriptionUpdate(SubscriptionEntity? subscription) {
    _currentSubscription = subscription;
    if (subscription != null) {
      _updatePremiumStatusFromEntity(subscription);
      _syncSubscriptionWithCloudFunctions(subscription);
    } else {
      _status = PremiumStatus.free();
      notifyListeners();
    }
  }

  /// Update premium status based on subscription entity
  void _updatePremiumStatusFromEntity(SubscriptionEntity subscription) {
    if (subscription.isActive && subscription.isReceitaAgroSubscription) {
      _status = PremiumStatus.premium(
        expirationDate: subscription.expirationDate ?? DateTime.now().add(const Duration(days: 30)),
        productId: subscription.productId,
        isTrialActive: subscription.isTrialActive,
        maxDevices: _remoteConfig.getIntConfig(ReceitaAgroConfigKey.maxDevicesPerSubscription),
      );
    } else {
      _status = PremiumStatus.free();
    }

    notifyListeners();
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
        name: 'PremiumService',
        error: e,
      );
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Set error
  void _setError(String error) {
    _lastError = error;
    notifyListeners();
  }

  /// Clear error
  void _clearError() {
    if (_lastError != null) {
      _lastError = null;
      notifyListeners();
    }
  }

  /// Get current subscription data (compatibility method)
  Map<String, dynamic>? getCurrentSubscription() {
    if (!_status.isPremium || !_status.isActive) {
      return null;
    }
    
    return {
      'productId': _status.productId,
      'expirationDate': _status.expirationDate?.toIso8601String(),
      'isActive': _status.isActive,
      'isTrialActive': _status.isTrialActive,
      'trialEndDate': _status.trialEndDate?.toIso8601String(),
      'isInGracePeriod': _status.isInGracePeriod,
      'devicesUsed': _status.devicesUsed,
      'maxDevices': _status.maxDevices,
    };
  }

  /// Get debug information
  Map<String, dynamic> getDebugInfo() {
    return {
      'initialized': _initialized,
      'isPremium': _status.isPremium,
      'isActive': _status.isActive,
      'productId': _status.productId,
      'expirationDate': _status.expirationDate?.toIso8601String(),
      'availableProducts': _availableProducts.length,
      'lastError': _lastError,
    };
  }

  @override
  void dispose() {
    if (_isDisposed) return;

    _isDisposed = true;
    try {
      _subscriptionStreamSubscription?.cancel();

      if (EnvironmentConfig.enableLogging) {
        developer.log(
          '🧹 Subscription stream listener cancelled',
          name: 'PremiumService',
        );
      }
    } catch (e) {
      developer.log(
        '⚠️ Error cancelling subscription stream: $e',
        name: 'PremiumService',
        error: e,
      );
    }

    if (EnvironmentConfig.enableLogging) {
      developer.log(
        '✅ Premium Service disposed',
        name: 'PremiumService',
      );
    }

    super.dispose();
  }
}

/// Alias for compatibility
typedef PremiumService = ReceitaAgroPremiumService;
