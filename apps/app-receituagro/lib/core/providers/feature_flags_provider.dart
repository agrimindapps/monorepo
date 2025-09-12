import 'dart:async';
import 'dart:developer' as developer;

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../services/premium_service.dart';
import '../services/remote_config_service.dart';

/// Feature flags provider that combines Remote Config with Premium status
/// Follows Provider pattern used throughout ReceitaAgro app
class FeatureFlagsProvider extends ChangeNotifier {
  final ReceitaAgroRemoteConfigService _remoteConfig;
  final ReceitaAgroPremiumService _premiumService;
  
  bool _isInitialized = false;
  Timer? _refreshTimer;

  // Feature flags cache
  final Map<ReceitaAgroFeatureFlag, bool> _flagsCache = {};
  
  FeatureFlagsProvider({
    ReceitaAgroRemoteConfigService? remoteConfig,
    ReceitaAgroPremiumService? premiumService,
  }) : _remoteConfig = remoteConfig ?? ReceitaAgroRemoteConfigService.instance,
       _premiumService = premiumService ?? ReceitaAgroPremiumService.instance;

  bool get isInitialized => _isInitialized;

  /// Initialize Feature Flags Provider
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Ensure dependencies are initialized
      await _remoteConfig.initialize();
      
      if (!_premiumService.initialized) {
        await _premiumService.initialize();
      }

      // Load initial feature flags
      _refreshFeatureFlags();
      
      // Setup periodic refresh
      _setupPeriodicRefresh();
      
      // Listen to premium service changes
      _premiumService.addListener(_onPremiumStatusChanged);

      _isInitialized = true;

      if (EnvironmentConfig.enableLogging) {
        developer.log(
          '✅ Feature Flags Provider initialized',
          name: 'FeatureFlagsProvider',
        );
      }
    } catch (e, stackTrace) {
      developer.log(
        '❌ Failed to initialize Feature Flags Provider: $e',
        name: 'FeatureFlagsProvider',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Check if a feature is enabled (combines Remote Config + Premium status)
  bool isFeatureEnabled(ReceitaAgroFeatureFlag flag) {
    if (!_isInitialized) {
      return _remoteConfig.isFeatureEnabled(flag);
    }

    // Use cached value if available
    if (_flagsCache.containsKey(flag)) {
      return _flagsCache[flag]!;
    }

    // Calculate feature availability
    final isEnabled = _calculateFeatureAvailability(flag);
    _flagsCache[flag] = isEnabled;
    
    return isEnabled;
  }

  /// Get feature availability with detailed reasoning
  FeatureAvailability getFeatureAvailability(ReceitaAgroFeatureFlag flag) {
    final remoteEnabled = _remoteConfig.isFeatureEnabled(flag);
    final requiresPremium = _requiresPremium(flag);
    final hasPremium = _premiumService.isPremium;
    final premiumActive = _premiumService.isActive;

    if (!remoteEnabled) {
      return const FeatureAvailability(
        available: false,
        reason: FeatureUnavailableReason.disabledByRemoteConfig,
        message: 'Recurso temporariamente desabilitado',
      );
    }

    if (requiresPremium && !hasPremium) {
      return const FeatureAvailability(
        available: false,
        reason: FeatureUnavailableReason.requiresPremium,
        message: 'Recurso disponível apenas para usuários Premium',
      );
    }

    if (requiresPremium && hasPremium && !premiumActive) {
      return const FeatureAvailability(
        available: false,
        reason: FeatureUnavailableReason.premiumInactive,
        message: 'Assinatura Premium inativa ou expirada',
      );
    }

    return const FeatureAvailability(
      available: true,
      reason: FeatureUnavailableReason.none,
      message: 'Recurso disponível',
    );
  }

  /// Premium feature shortcuts
  bool get isPremiumFeaturesEnabled => isFeatureEnabled(ReceitaAgroFeatureFlag.enablePremiumFeatures);
  bool get isAdvancedDiagnosticsEnabled => isFeatureEnabled(ReceitaAgroFeatureFlag.enableAdvancedDiagnostics);
  bool get isOfflineModeEnabled => isFeatureEnabled(ReceitaAgroFeatureFlag.enableOfflineMode);
  bool get isPushNotificationsEnabled => isFeatureEnabled(ReceitaAgroFeatureFlag.enablePushNotifications);

  /// A/B Testing shortcuts
  bool get isNewUiDesignEnabled => isFeatureEnabled(ReceitaAgroFeatureFlag.enableNewUiDesign);
  bool get isImprovedOnboardingEnabled => isFeatureEnabled(ReceitaAgroFeatureFlag.enableImprovedOnboarding);
  bool get isGamificationEnabled => isFeatureEnabled(ReceitaAgroFeatureFlag.enableGamification);

  /// Performance shortcuts
  bool get isImageOptimizationEnabled => isFeatureEnabled(ReceitaAgroFeatureFlag.enableImageOptimization);
  bool get isDataCachingEnabled => isFeatureEnabled(ReceitaAgroFeatureFlag.enableDataCaching);
  bool get isPreloadContentEnabled => isFeatureEnabled(ReceitaAgroFeatureFlag.enablePreloadContent);

  /// Analytics shortcuts
  bool get isDetailedAnalyticsEnabled => isFeatureEnabled(ReceitaAgroFeatureFlag.enableDetailedAnalytics);
  bool get isPerformanceMonitoringEnabled => isFeatureEnabled(ReceitaAgroFeatureFlag.enablePerformanceMonitoring);
  bool get isCrashReportingEnabled => isFeatureEnabled(ReceitaAgroFeatureFlag.enableCrashReporting);

  /// Business logic shortcuts
  bool get isSubscriptionValidationEnabled => isFeatureEnabled(ReceitaAgroFeatureFlag.enableSubscriptionValidation);
  bool get isDeviceManagementEnabled => isFeatureEnabled(ReceitaAgroFeatureFlag.enableDeviceManagement);
  bool get isContentSynchronizationEnabled => isFeatureEnabled(ReceitaAgroFeatureFlag.enableContentSynchronization);

  /// Refresh feature flags from Remote Config
  Future<void> refresh() async {
    if (!_isInitialized) return;

    try {
      await _remoteConfig.fetchAndActivate();
      _refreshFeatureFlags();
    } catch (e) {
      developer.log(
        '⚠️ Failed to refresh feature flags: $e',
        name: 'FeatureFlagsProvider',
        error: e,
      );
    }
  }

  /// Calculate feature availability considering all factors
  bool _calculateFeatureAvailability(ReceitaAgroFeatureFlag flag) {
    final availability = getFeatureAvailability(flag);
    return availability.available;
  }

  /// Check if feature requires premium subscription
  bool _requiresPremium(ReceitaAgroFeatureFlag flag) {
    switch (flag) {
      case ReceitaAgroFeatureFlag.enableAdvancedDiagnostics:
      case ReceitaAgroFeatureFlag.enableOfflineMode:
        return true;
      
      // A/B testing features don't require premium
      case ReceitaAgroFeatureFlag.enableNewUiDesign:
      case ReceitaAgroFeatureFlag.enableImprovedOnboarding:
      case ReceitaAgroFeatureFlag.enableGamification:
        return false;
      
      // Core features don't require premium
      case ReceitaAgroFeatureFlag.enablePushNotifications:
      case ReceitaAgroFeatureFlag.enableImageOptimization:
      case ReceitaAgroFeatureFlag.enableDataCaching:
      case ReceitaAgroFeatureFlag.enablePreloadContent:
        return false;
      
      // Analytics follows environment config, not premium
      case ReceitaAgroFeatureFlag.enableDetailedAnalytics:
      case ReceitaAgroFeatureFlag.enablePerformanceMonitoring:
      case ReceitaAgroFeatureFlag.enableCrashReporting:
        return false;
      
      // Business logic features don't require premium
      case ReceitaAgroFeatureFlag.enableSubscriptionValidation:
      case ReceitaAgroFeatureFlag.enableDeviceManagement:
      case ReceitaAgroFeatureFlag.enableContentSynchronization:
        return false;
      
      // Premium features themselves
      case ReceitaAgroFeatureFlag.enablePremiumFeatures:
        return false; // This is the master toggle, not premium-gated
      
      default:
        return false;
    }
  }

  /// Refresh feature flags cache
  void _refreshFeatureFlags() {
    _flagsCache.clear();
    
    // Pre-calculate commonly used flags
    final commonFlags = [
      ReceitaAgroFeatureFlag.enablePremiumFeatures,
      ReceitaAgroFeatureFlag.enableAdvancedDiagnostics,
      ReceitaAgroFeatureFlag.enableOfflineMode,
      ReceitaAgroFeatureFlag.enablePushNotifications,
      ReceitaAgroFeatureFlag.enableImageOptimization,
      ReceitaAgroFeatureFlag.enableDataCaching,
    ];

    for (final flag in commonFlags) {
      _flagsCache[flag] = _calculateFeatureAvailability(flag);
    }

    notifyListeners();
  }

  /// Setup periodic refresh
  void _setupPeriodicRefresh() {
    _refreshTimer?.cancel();
    
    // Refresh every 30 minutes in debug, every 2 hours in production
    final refreshInterval = EnvironmentConfig.isDebugMode
        ? const Duration(minutes: 30)
        : const Duration(hours: 2);
    
    _refreshTimer = Timer.periodic(refreshInterval, (_) => refresh());
  }

  /// Handle premium status changes
  void _onPremiumStatusChanged() {
    _refreshFeatureFlags();
  }

  /// Get debug information
  Map<String, dynamic> getDebugInfo() {
    if (!EnvironmentConfig.enableLogging) return {};
    
    return {
      'initialized': _isInitialized,
      'flagsCache': _flagsCache.map((key, value) => MapEntry(key.key, value)),
      'premiumStatus': _premiumService.isPremium,
      'premiumActive': _premiumService.isActive,
    };
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _premiumService.removeListener(_onPremiumStatusChanged);
    super.dispose();
  }
}

/// Feature availability information
class FeatureAvailability {
  final bool available;
  final FeatureUnavailableReason reason;
  final String message;

  const FeatureAvailability({
    required this.available,
    required this.reason,
    required this.message,
  });
}

/// Reasons why a feature might be unavailable
enum FeatureUnavailableReason {
  none,
  disabledByRemoteConfig,
  requiresPremium,
  premiumInactive,
  deviceLimitReached,
  networkUnavailable,
}