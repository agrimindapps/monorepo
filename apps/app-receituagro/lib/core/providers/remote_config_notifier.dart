import 'dart:async';
import 'dart:developer' as developer;

import 'package:core/core.dart';

import '../services/remote_config_service.dart';

part 'remote_config_notifier.g.dart';

/// Estado do Remote Config
class RemoteConfigState {
  final bool isInitialized;
  final bool isLoading;
  final String? lastError;
  final DateTime? lastUpdated;
  final Map<ReceitaAgroFeatureFlag, bool> featureFlags;
  final Map<ReceitaAgroConfigKey, dynamic> configurations;

  const RemoteConfigState({
    required this.isInitialized,
    required this.isLoading,
    this.lastError,
    this.lastUpdated,
    required this.featureFlags,
    required this.configurations,
  });

  factory RemoteConfigState.initial() {
    return const RemoteConfigState(
      isInitialized: false,
      isLoading: false,
      lastError: null,
      lastUpdated: null,
      featureFlags: {},
      configurations: {},
    );
  }

  RemoteConfigState copyWith({
    bool? isInitialized,
    bool? isLoading,
    String? lastError,
    DateTime? lastUpdated,
    Map<ReceitaAgroFeatureFlag, bool>? featureFlags,
    Map<ReceitaAgroConfigKey, dynamic>? configurations,
  }) {
    return RemoteConfigState(
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      lastError: lastError ?? this.lastError,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      featureFlags: featureFlags ?? this.featureFlags,
      configurations: configurations ?? this.configurations,
    );
  }

  RemoteConfigState clearError() {
    return copyWith(lastError: null);
  }
}

/// Notifier para Remote Config state management
@riverpod
class RemoteConfigNotifier extends _$RemoteConfigNotifier {
  late final ReceitaAgroRemoteConfigService _remoteConfigService;
  Timer? _refreshTimer;

  @override
  Future<RemoteConfigState> build() async {
    _remoteConfigService = ReceitaAgroRemoteConfigService.instance;
    ref.onDispose(() {
      _refreshTimer?.cancel();
    });

    try {
      await _remoteConfigService.initialize();
      final featureFlags = await _loadFeatureFlags();
      final configurations = await _loadConfigurations();
      _setupAutoRefresh(featureFlags);

      if (EnvironmentConfig.enableLogging) {
        developer.log(
          '✅ RemoteConfigNotifier initialized successfully',
          name: 'RemoteConfigNotifier',
        );
      }

      return RemoteConfigState(
        isInitialized: true,
        isLoading: false,
        lastUpdated: DateTime.now(),
        featureFlags: featureFlags,
        configurations: configurations,
      );
    } catch (e, stackTrace) {
      if (EnvironmentConfig.enableAnalytics) {
      }

      developer.log(
        '❌ RemoteConfigNotifier initialization failed: $e',
        name: 'RemoteConfigNotifier',
        error: e,
        stackTrace: stackTrace,
      );

      return RemoteConfigState.initial().copyWith(
        lastError: 'Failed to initialize Remote Config: $e',
      );
    }
  }

  /// Refresh Remote Config values
  Future<void> refresh() async {
    final currentState = state.value;
    if (currentState == null) {
      return;
    }
    state = AsyncValue.data(currentState.copyWith(isLoading: true).clearError());

    try {
      final updated = await _remoteConfigService.fetchAndActivate();

      if (updated) {
        final featureFlags = await _loadFeatureFlags();
        final configurations = await _loadConfigurations();

        state = AsyncValue.data(
          currentState.copyWith(
            isLoading: false,
            featureFlags: featureFlags,
            configurations: configurations,
            lastUpdated: DateTime.now(),
          ),
        );

        if (EnvironmentConfig.enableLogging) {
          developer.log(
            '🔄 Remote Config values refreshed',
            name: 'RemoteConfigNotifier',
          );
        }
      } else {
        state = AsyncValue.data(currentState.copyWith(isLoading: false));
      }
    } catch (e) {
      developer.log(
        '⚠️ RemoteConfigNotifier refresh failed: $e',
        name: 'RemoteConfigNotifier',
        error: e,
      );

      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          lastError: 'Failed to refresh Remote Config: $e',
        ),
      );
    }
  }

  /// Check if a feature is enabled
  bool isFeatureEnabled(ReceitaAgroFeatureFlag feature) {
    final currentState = state.value;
    if (currentState == null || !currentState.isInitialized) {
      return _remoteConfigService.isFeatureEnabled(feature);
    }

    return currentState.featureFlags[feature] ?? false;
  }

  /// Get string configuration value
  String getStringConfig(ReceitaAgroConfigKey key) {
    final currentState = state.value;
    if (currentState == null || !currentState.isInitialized) {
      return _remoteConfigService.getStringConfig(key);
    }

    return currentState.configurations[key]?.toString() ?? '';
  }

  /// Get int configuration value
  int getIntConfig(ReceitaAgroConfigKey key) {
    final currentState = state.value;
    if (currentState == null || !currentState.isInitialized) {
      return _remoteConfigService.getIntConfig(key);
    }

    final value = currentState.configurations[key];
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Get double configuration value
  double getDoubleConfig(ReceitaAgroConfigKey key) {
    final currentState = state.value;
    if (currentState == null || !currentState.isInitialized) {
      return _remoteConfigService.getDoubleConfig(key);
    }

    final value = currentState.configurations[key];
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    if (value is int) return value.toDouble();
    return 0.0;
  }

  /// Get JSON configuration value
  Map<String, dynamic> getJsonConfig(ReceitaAgroConfigKey key) {
    final currentState = state.value;
    if (currentState == null || !currentState.isInitialized) {
      return _remoteConfigService.getJsonConfig(key);
    }

    final value = currentState.configurations[key];
    if (value is Map<String, dynamic>) return value;
    return {};
  }

  /// Get supported languages
  List<String> getSupportedLanguages() {
    return _remoteConfigService.getSupportedLanguages();
  }

  /// Get theme configuration
  Map<String, dynamic> getThemeConfiguration() {
    return getJsonConfig(ReceitaAgroConfigKey.themeConfiguration);
  }

  /// Premium feature helpers
  bool get isPremiumEnabled => isFeatureEnabled(ReceitaAgroFeatureFlag.enablePremiumFeatures);
  bool get isAdvancedDiagnosticsEnabled => isFeatureEnabled(ReceitaAgroFeatureFlag.enableAdvancedDiagnostics);
  bool get isOfflineModeEnabled => isFeatureEnabled(ReceitaAgroFeatureFlag.enableOfflineMode);

  /// Performance feature helpers
  bool get isImageOptimizationEnabled => isFeatureEnabled(ReceitaAgroFeatureFlag.enableImageOptimization);
  bool get isDataCachingEnabled => isFeatureEnabled(ReceitaAgroFeatureFlag.enableDataCaching);
  bool get isPreloadContentEnabled => isFeatureEnabled(ReceitaAgroFeatureFlag.enablePreloadContent);

  /// Analytics feature helpers
  bool get isDetailedAnalyticsEnabled => isFeatureEnabled(ReceitaAgroFeatureFlag.enableDetailedAnalytics);
  bool get isPerformanceMonitoringEnabled => isFeatureEnabled(ReceitaAgroFeatureFlag.enablePerformanceMonitoring);

  /// Business logic helpers
  bool get isSubscriptionValidationEnabled => isFeatureEnabled(ReceitaAgroFeatureFlag.enableSubscriptionValidation);
  bool get isDeviceManagementEnabled => isFeatureEnabled(ReceitaAgroFeatureFlag.enableDeviceManagement);

  /// Configuration helpers
  int get maxDevicesPerSubscription => getIntConfig(ReceitaAgroConfigKey.maxDevicesPerSubscription);
  int get subscriptionGracePeriodHours => getIntConfig(ReceitaAgroConfigKey.subscriptionGracePeriodHours);
  double get imageQualityLevel => getDoubleConfig(ReceitaAgroConfigKey.imageQualityLevel);
  int get maxCacheSize => getIntConfig(ReceitaAgroConfigKey.maxCacheSize);

  /// Load all feature flags
  Future<Map<ReceitaAgroFeatureFlag, bool>> _loadFeatureFlags() async {
    final flags = <ReceitaAgroFeatureFlag, bool>{};
    for (final feature in ReceitaAgroFeatureFlag.values) {
      flags[feature] = _remoteConfigService.isFeatureEnabled(feature);
    }
    return flags;
  }

  /// Load all configurations
  Future<Map<ReceitaAgroConfigKey, dynamic>> _loadConfigurations() async {
    final configs = <ReceitaAgroConfigKey, dynamic>{};

    for (final config in ReceitaAgroConfigKey.values) {
      switch (config) {
        case ReceitaAgroConfigKey.maxDevicesPerSubscription:
        case ReceitaAgroConfigKey.subscriptionGracePeriodHours:
        case ReceitaAgroConfigKey.maxCacheSize:
        case ReceitaAgroConfigKey.apiTimeoutSeconds:
        case ReceitaAgroConfigKey.contentUpdateInterval:
        case ReceitaAgroConfigKey.analyticsEventBatchSize:
        case ReceitaAgroConfigKey.analyticsFlushInterval:
        case ReceitaAgroConfigKey.onboardingStepsCount:
          configs[config] = _remoteConfigService.getIntConfig(config);
          break;
        case ReceitaAgroConfigKey.imageQualityLevel:
          configs[config] = _remoteConfigService.getDoubleConfig(config);
          break;
        case ReceitaAgroConfigKey.themeConfiguration:
          configs[config] = _remoteConfigService.getJsonConfig(config);
          break;
        default:
          configs[config] = _remoteConfigService.getStringConfig(config);
          break;
      }
    }

    return configs;
  }

  /// Setup auto-refresh timer
  void _setupAutoRefresh(Map<ReceitaAgroFeatureFlag, bool> featureFlags) {
    final enableRefresh = EnvironmentConfig.isDebugMode ||
        (featureFlags[ReceitaAgroFeatureFlag.enableDetailedAnalytics] ?? false);

    if (!enableRefresh) {
      return;
    }

    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 15), // Refresh every 15 minutes in debug
      (_) => refresh(),
    );
  }

  /// Get debug information
  Map<String, dynamic> getDebugInfo() {
    if (!EnvironmentConfig.enableLogging) return {};

    final currentState = state.value;
    if (currentState == null) return {};

    return {
      'isInitialized': currentState.isInitialized,
      'isLoading': currentState.isLoading,
      'lastError': currentState.lastError,
      'lastUpdated': currentState.lastUpdated?.toIso8601String(),
      'featureFlags': currentState.featureFlags.map((key, value) => MapEntry(key.key, value)),
      'configurations': currentState.configurations.map((key, value) => MapEntry(key.key, value)),
    };
  }
}
