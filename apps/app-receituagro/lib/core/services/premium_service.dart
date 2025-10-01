import 'dart:async';
import 'dart:developer' as developer;

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../features/analytics/analytics_service.dart';
import '../constants/receituagro_environment_config.dart';
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
class ReceitaAgroPremiumService extends ChangeNotifier {
  // Dependencies - required via constructor injection
  final ReceitaAgroAnalyticsService _analytics;
  final ReceitaAgroCloudFunctionsService _cloudFunctions;
  final ReceitaAgroRemoteConfigService _remoteConfig;

  /// Constructor with dependency injection
  ReceitaAgroPremiumService({
    required ReceitaAgroAnalyticsService analytics,
    required ReceitaAgroCloudFunctionsService cloudFunctions,
    required ReceitaAgroRemoteConfigService remoteConfig,
  })  : _analytics = analytics,
        _cloudFunctions = cloudFunctions,
        _remoteConfig = remoteConfig;

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
  List<StoreProduct> _availableProducts = [];
  List<Package> _availablePackages = [];
  CustomerInfo? _customerInfo;
  String? _lastError;
  bool _isLoading = false;

  // Getters
  bool get initialized => _initialized;
  PremiumStatus get status => _status;
  List<StoreProduct> get availableProducts => _availableProducts;
  List<Package> get availablePackages => _availablePackages;
  CustomerInfo? get customerInfo => _customerInfo;
  String? get lastError => _lastError;
  bool get isLoading => _isLoading;

  // Premium status shortcuts
  bool get isPremium => _status.isPremium;
  bool get isActive => _status.isActive;
  bool get isTrialActive => _status.isTrialActive;

  /// Initialize Premium Service
  Future<void> initialize() async {
    if (_initialized) return;

    _setLoading(true);

    try {
      // Skip RevenueCat configuration on web platform
      if (kIsWeb) {
        developer.log(
          '🌐 Premium Service: Skipping RevenueCat configuration on web platform',
          name: 'PremiumService',
        );
        
        // Set mock status for web
        _status = PremiumStatus.free();
        _initialized = true;
        _setLoading(false);
        
        developer.log(
          '✅ Premium Service initialized (web mock mode)',
          name: 'PremiumService',
        );
        return;
      }

      // Configure RevenueCat (mobile only)
      final configuration = PurchasesConfiguration(
        _getRevenueCatApiKey(),
      );
      
      await Purchases.configure(configuration);

      // Set up listeners
      Purchases.addCustomerInfoUpdateListener(_handleCustomerInfoUpdate);

      // Load initial data
      await _loadCustomerInfo();
      await _loadProducts();
      
      _initialized = true;

      if (EnvironmentConfig.enableLogging) {
        developer.log(
          '✅ Premium Service initialized',
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
  Future<Either<String, CustomerInfo>> purchasePackage(Package package) async {
    if (!_initialized) {
      return const Left('Premium Service not initialized');
    }

    _setLoading(true);
    _clearError();

    try {
      await _analytics.logSubscriptionEvent(
        'purchase_started',
        package.storeProduct.identifier,
      );

      final purchaseResult = await Purchases.purchasePackage(package);
      final customerInfo = purchaseResult.customerInfo;
      
      // Validate with cloud functions
      await _syncWithCloudFunctions(customerInfo);
      
      await _analytics.logSubscriptionEvent(
        'purchased',
        package.storeProduct.identifier,
        additionalData: {
          'price': package.storeProduct.price,
          'currency': package.storeProduct.currencyCode,
        },
      );

      return Right(customerInfo);
    } catch (e, stackTrace) {
      final errorMessage = 'Purchase failed: $e';
      _setError(errorMessage);

      await _analytics.recordError(
        e,
        stackTrace,
        reason: 'Purchase failed: ${package.storeProduct.identifier}',
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
  Future<Either<String, CustomerInfo>> restorePurchases() async {
    if (!_initialized) {
      return const Left('Premium Service not initialized');
    }

    _setLoading(true);
    _clearError();

    try {
      final customerInfo = await Purchases.restorePurchases();
      
      // Sync with cloud functions
      await _syncWithCloudFunctions(customerInfo);

      await _analytics.logEvent(
        ReceitaAgroAnalyticsEvent.subscriptionViewed.eventName,
        {
          'action': 'restore',
          'active_subscriptions': customerInfo.activeSubscriptions.length,
        },
      );

      return Right(customerInfo);
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
    // Check remote config for feature toggles first
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
    
    // This would typically navigate to a premium screen
    // For now, just log the event
    developer.log(
      '💰 Premium upgrade requested for feature: $requestedFeature',
      name: 'PremiumService',
    );
  }

  /// Load customer info and update status
  Future<void> _loadCustomerInfo() async {
    try {
      _customerInfo = await Purchases.getCustomerInfo();
      _updatePremiumStatus(_customerInfo!);
    } catch (e) {
      developer.log(
        '⚠️ Failed to load customer info: $e',
        name: 'PremiumService',
        error: e,
      );
    }
  }

  /// Load available products
  Future<void> _loadProducts() async {
    try {
      final offerings = await Purchases.getOfferings();
      
      if (offerings.current != null) {
        _availablePackages = offerings.current!.availablePackages;
        _availableProducts = _availablePackages
            .map((package) => package.storeProduct)
            .toList();
      }
    } catch (e) {
      developer.log(
        '⚠️ Failed to load products: $e',
        name: 'PremiumService',
        error: e,
      );
    }
  }

  /// Handle customer info updates
  void _handleCustomerInfoUpdate(CustomerInfo customerInfo) {
    _customerInfo = customerInfo;
    _updatePremiumStatus(customerInfo);
    
    // Sync with cloud functions
    _syncWithCloudFunctions(customerInfo);
  }

  /// Update premium status based on customer info
  void _updatePremiumStatus(CustomerInfo customerInfo) {
    final hasActiveSubscription = customerInfo.activeSubscriptions.isNotEmpty;
    final entitlementInfo = customerInfo.entitlements.active.values.isNotEmpty
        ? customerInfo.entitlements.active.values.first
        : null;

    if (hasActiveSubscription && entitlementInfo != null) {
      // Parse expiration date correctly from EntitlementInfo
      DateTime? parsedExpirationDate;
      final expirationDateString = entitlementInfo.expirationDate;
      if (expirationDateString != null && expirationDateString.isNotEmpty) {
        // entitlementInfo.expirationDate is already a String, no need for toString()
        parsedExpirationDate = DateTime.tryParse(expirationDateString);
      }

      _status = PremiumStatus.premium(
        expirationDate: parsedExpirationDate ?? DateTime.now().add(const Duration(days: 30)),
        productId: entitlementInfo.productIdentifier,
        isTrialActive: entitlementInfo.periodType == PeriodType.trial,
        maxDevices: _remoteConfig.getIntConfig(ReceitaAgroConfigKey.maxDevicesPerSubscription),
      );
    } else {
      _status = PremiumStatus.free();
    }

    notifyListeners();
  }

  /// Sync subscription with cloud functions
  Future<void> _syncWithCloudFunctions(CustomerInfo customerInfo) async {
    try {
      if (customerInfo.activeSubscriptions.isNotEmpty) {
        final activeSubscription = customerInfo.activeSubscriptions.first;
        final entitlement = customerInfo.entitlements.active[activeSubscription];

        if (entitlement != null) {
          await _cloudFunctions.syncRevenueCatPurchase(
            receiptData: customerInfo.originalPurchaseDate?.toString() ?? '',
            productId: entitlement.productIdentifier,
            purchaseToken: customerInfo.originalApplicationVersion ?? '',
          );
        }
      }
    } catch (e) {
      developer.log(
        '⚠️ Failed to sync with cloud functions: $e',
        name: 'PremiumService',
        error: e,
      );
    }
  }

  /// Get RevenueCat API key based on environment
  String _getRevenueCatApiKey() {
    try {
      // Use app-specific configuration
      final config = ReceituagroEnvironmentConfig();
      return config.revenueCatApiKey;
    } catch (e) {
      // Fallback to dummy keys
      if (kDebugMode) {
        print('[PremiumService] Using fallback API key due to configuration error: $e');
      }
      return EnvironmentConfig.isProductionMode ? 'dummy_prod_key' : 'dummy_dev_key';
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

    // Remove RevenueCat listener to prevent memory leak
    try {
      if (_initialized && !kIsWeb) {
        Purchases.removeCustomerInfoUpdateListener(_handleCustomerInfoUpdate);

        if (EnvironmentConfig.enableLogging) {
          developer.log(
            '🧹 RevenueCat listener removed',
            name: 'PremiumService',
          );
        }
      }
    } catch (e) {
      developer.log(
        '⚠️ Error removing RevenueCat listener: $e',
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