import 'dart:async';
import 'dart:developer' as developer;

import 'package:core/core.dart' hide Column;

import '../services/premium_service.dart';
import '../services/remote_config_service.dart';

part 'feature_flags_notifier.g.dart';

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

/// Estado dos feature flags
class FeatureFlagsState {
  final Map<ReceitaAgroFeatureFlag, bool> flagsCache;
  final bool isInitialized;

  const FeatureFlagsState({
    required this.flagsCache,
    required this.isInitialized,
  });

  factory FeatureFlagsState.initial() {
    return const FeatureFlagsState(
      flagsCache: {},
      isInitialized: false,
    );
  }

  FeatureFlagsState copyWith({
    Map<ReceitaAgroFeatureFlag, bool>? flagsCache,
    bool? isInitialized,
  }) {
    return FeatureFlagsState(
      flagsCache: flagsCache ?? this.flagsCache,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

/// Feature flags notifier that combines Remote Config with Premium status
@riverpod
class FeatureFlagsNotifier extends _$FeatureFlagsNotifier {
  late final ReceitaAgroRemoteConfigService _remoteConfig;
  late final ReceitaAgroPremiumService _premiumService;
  Timer? _refreshTimer;

  @override
  Future<FeatureFlagsState> build() async {
    _remoteConfig = ReceitaAgroRemoteConfigService.instance;
    _premiumService = ReceitaAgroPremiumService.instance;

    // Setup callback for premium status changes
    _premiumService.onStateChanged = _onPremiumStatusChanged;

    ref.onDispose(() {
      _refreshTimer?.cancel();
      _premiumService.onStateChanged = null;
    });

    try {
      await _remoteConfig.initialize();

      if (!_premiumService.initialized) {
        await _premiumService.initialize();
      }
      final initialCache = _calculateCommonFlags();
      _setupPeriodicRefresh();

      if (EnvironmentConfig.enableLogging) {
        developer.log(
          '✅ Feature Flags Notifier initialized',
          name: 'FeatureFlagsNotifier',
        );
      }

      return FeatureFlagsState(
        flagsCache: initialCache,
        isInitialized: true,
      );
    } catch (e, stackTrace) {
      developer.log(
        '❌ Failed to initialize Feature Flags Notifier: $e',
        name: 'FeatureFlagsNotifier',
        error: e,
        stackTrace: stackTrace,
      );
      return FeatureFlagsState.initial();
    }
  }

  /// Check if a feature is enabled (combines Remote Config + Premium status)
  bool isFeatureEnabled(ReceitaAgroFeatureFlag flag) {
    final currentState = state.value;
    if (currentState == null || !currentState.isInitialized) {
      return _remoteConfig.isFeatureEnabled(flag);
    }
    if (currentState.flagsCache.containsKey(flag)) {
      return currentState.flagsCache[flag]!;
    }
    return _calculateFeatureAvailability(flag);
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
    final currentState = state.value;
    if (currentState == null || !currentState.isInitialized) return;

    try {
      await _remoteConfig.fetchAndActivate();
      final newCache = _calculateCommonFlags();

      state = AsyncValue.data(
        currentState.copyWith(flagsCache: newCache),
      );
    } catch (e) {
      developer.log(
        '⚠️ Failed to refresh feature flags: $e',
        name: 'FeatureFlagsNotifier',
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
      case ReceitaAgroFeatureFlag.enableNewUiDesign:
      case ReceitaAgroFeatureFlag.enableImprovedOnboarding:
      case ReceitaAgroFeatureFlag.enableGamification:
        return false;
      case ReceitaAgroFeatureFlag.enablePushNotifications:
      case ReceitaAgroFeatureFlag.enableImageOptimization:
      case ReceitaAgroFeatureFlag.enableDataCaching:
      case ReceitaAgroFeatureFlag.enablePreloadContent:
        return false;
      case ReceitaAgroFeatureFlag.enableDetailedAnalytics:
      case ReceitaAgroFeatureFlag.enablePerformanceMonitoring:
      case ReceitaAgroFeatureFlag.enableCrashReporting:
        return false;
      case ReceitaAgroFeatureFlag.enableSubscriptionValidation:
      case ReceitaAgroFeatureFlag.enableDeviceManagement:
      case ReceitaAgroFeatureFlag.enableContentSynchronization:
        return false;
      case ReceitaAgroFeatureFlag.enablePremiumFeatures:
        return false; // This is the master toggle, not premium-gated
    }
  }

  /// Calculate common feature flags
  Map<ReceitaAgroFeatureFlag, bool> _calculateCommonFlags() {
    final commonFlags = [
      ReceitaAgroFeatureFlag.enablePremiumFeatures,
      ReceitaAgroFeatureFlag.enableAdvancedDiagnostics,
      ReceitaAgroFeatureFlag.enableOfflineMode,
      ReceitaAgroFeatureFlag.enablePushNotifications,
      ReceitaAgroFeatureFlag.enableImageOptimization,
      ReceitaAgroFeatureFlag.enableDataCaching,
    ];

    return Map.fromEntries(
      commonFlags.map((flag) => MapEntry(flag, _calculateFeatureAvailability(flag))),
    );
  }

  /// Setup periodic refresh
  void _setupPeriodicRefresh() {
    _refreshTimer?.cancel();
    final refreshInterval = EnvironmentConfig.isDebugMode
        ? const Duration(minutes: 30)
        : const Duration(hours: 2);

    _refreshTimer = Timer.periodic(refreshInterval, (_) => refresh());
  }

  /// Handle premium status changes
  void _onPremiumStatusChanged() {
    final currentState = state.value;
    if (currentState == null || !currentState.isInitialized) return;

    final newCache = _calculateCommonFlags();
    state = AsyncValue.data(
      currentState.copyWith(flagsCache: newCache),
    );
  }

  /// Get debug information
  Map<String, dynamic> getDebugInfo() {
    if (!EnvironmentConfig.enableLogging) return {};

    final currentState = state.value;
    if (currentState == null) return {};

    return {
      'initialized': currentState.isInitialized,
      'flagsCache': currentState.flagsCache.map((key, value) => MapEntry(key.key, value)),
      'premiumStatus': _premiumService.isPremium,
      'premiumActive': _premiumService.isActive,
    };
  }
}
