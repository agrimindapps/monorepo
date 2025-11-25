import 'dart:async';
import 'dart:developer' as developer;

import 'package:core/core.dart' hide Column, Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/remote_config_service.dart';

part 'remote_config_provider.g.dart';

/// Remote Config State
class RemoteConfigState {
  final bool isInitialized;
  final bool isLoading;
  final String? lastError;
  final DateTime? lastUpdated;
  final Map<ReceitaAgroFeatureFlag, bool> featureFlags;
  final Map<ReceitaAgroConfigKey, dynamic> configurations;

  const RemoteConfigState({
    this.isInitialized = false,
    this.isLoading = false,
    this.lastError,
    this.lastUpdated,
    this.featureFlags = const {},
    this.configurations = const {},
  });

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
}

/// Remote Config Service Provider
@riverpod
ReceitaAgroRemoteConfigService remoteConfigService(Ref ref) {
  return ReceitaAgroRemoteConfigService.instance;
}

/// Remote Config Notifier
@riverpod
class RemoteConfigNotifier extends _$RemoteConfigNotifier {
  Timer? _refreshTimer;

  @override
  RemoteConfigState build() {
    // Auto-initialize on first access
    _initialize();

    // Cleanup timer on dispose
    ref.onDispose(() {
      _refreshTimer?.cancel();
    });

    return const RemoteConfigState();
  }

  /// Initialize Remote Config
  Future<void> _initialize() async {
    if (state.isInitialized) return;

    state = state.copyWith(isLoading: true, lastError: null);

    try {
      final service = ref.read(remoteConfigServiceProvider);
      await service.initialize();
      await _loadAllValues();
      _setupAutoRefresh();

      state = state.copyWith(
        isInitialized: true,
        lastUpdated: DateTime.now(),
        isLoading: false,
      );

      if (EnvironmentConfig.enableLogging) {
        developer.log(
          '✅ RemoteConfigNotifier initialized successfully',
          name: 'RemoteConfigNotifier',
        );
      }
    } catch (e, stackTrace) {
      state = state.copyWith(
        lastError: 'Failed to initialize Remote Config: $e',
        isLoading: false,
      );

      if (EnvironmentConfig.enableAnalytics) {
        // Analytics tracking if needed
      }

      developer.log(
        '❌ RemoteConfigNotifier initialization failed: $e',
        name: 'RemoteConfigNotifier',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Refresh Remote Config values
  Future<void> refresh() async {
    if (!state.isInitialized) {
      await _initialize();
      return;
    }

    state = state.copyWith(isLoading: true, lastError: null);

    try {
      final service = ref.read(remoteConfigServiceProvider);
      final updated = await service.fetchAndActivate();

      if (updated) {
        await _loadAllValues();
        state = state.copyWith(
          lastUpdated: DateTime.now(),
          isLoading: false,
        );

        if (EnvironmentConfig.enableLogging) {
          developer.log(
            '🔄 Remote Config values refreshed',
            name: 'RemoteConfigNotifier',
          );
        }
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        lastError: 'Failed to refresh Remote Config: $e',
        isLoading: false,
      );

      developer.log(
        '⚠️ RemoteConfigNotifier refresh failed: $e',
        name: 'RemoteConfigNotifier',
        error: e,
      );
    }
  }

  /// Load all values from Remote Config service
  Future<void> _loadAllValues() async {
    final service = ref.read(remoteConfigServiceProvider);
    final featureFlags = <ReceitaAgroFeatureFlag, bool>{};
    final configurations = <ReceitaAgroConfigKey, dynamic>{};

    for (final feature in ReceitaAgroFeatureFlag.values) {
      featureFlags[feature] = service.isFeatureEnabled(feature);
    }

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
          configurations[config] = service.getIntConfig(config);
          break;
        case ReceitaAgroConfigKey.imageQualityLevel:
          configurations[config] = service.getDoubleConfig(config);
          break;
        case ReceitaAgroConfigKey.themeConfiguration:
          configurations[config] = service.getJsonConfig(config);
          break;
        default:
          configurations[config] = service.getStringConfig(config);
          break;
      }
    }

    state = state.copyWith(
      featureFlags: featureFlags,
      configurations: configurations,
    );
  }

  /// Setup auto-refresh timer
  void _setupAutoRefresh() {
    if (!EnvironmentConfig.isDebugMode &&
        !state.featureFlags[ReceitaAgroFeatureFlag.enableDetailedAnalytics]!) {
      return;
    }

    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 15), // Refresh every 15 minutes in debug
      (_) => refresh(),
    );
  }
}

/// Feature Flag Providers (Derived state)
@riverpod
bool isFeatureEnabled(Ref ref, ReceitaAgroFeatureFlag feature) {
  final state = ref.watch(remoteConfigProvider);

  if (!state.isInitialized) {
    return ref.read(remoteConfigServiceProvider).isFeatureEnabled(feature);
  }

  return state.featureFlags[feature] ?? false;
}

/// Configuration Providers (Derived state)
@riverpod
String getStringConfig(Ref ref, ReceitaAgroConfigKey key) {
  final state = ref.watch(remoteConfigProvider);

  if (!state.isInitialized) {
    return ref.read(remoteConfigServiceProvider).getStringConfig(key);
  }

  return state.configurations[key]?.toString() ?? '';
}

@riverpod
int getIntConfig(Ref ref, ReceitaAgroConfigKey key) {
  final state = ref.watch(remoteConfigProvider);

  if (!state.isInitialized) {
    return ref.read(remoteConfigServiceProvider).getIntConfig(key);
  }

  final value = state.configurations[key];
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

@riverpod
double getDoubleConfig(Ref ref, ReceitaAgroConfigKey key) {
  final state = ref.watch(remoteConfigProvider);

  if (!state.isInitialized) {
    return ref.read(remoteConfigServiceProvider).getDoubleConfig(key);
  }

  final value = state.configurations[key];
  if (value is double) return value;
  if (value is String) return double.tryParse(value) ?? 0.0;
  if (value is int) return value.toDouble();
  return 0.0;
}

@riverpod
Map<String, dynamic> getJsonConfig(Ref ref, ReceitaAgroConfigKey key) {
  final state = ref.watch(remoteConfigProvider);

  if (!state.isInitialized) {
    return ref.read(remoteConfigServiceProvider).getJsonConfig(key);
  }

  final value = state.configurations[key];
  if (value is Map<String, dynamic>) return value;
  return {};
}

/// Helper Providers
@riverpod
List<String> supportedLanguages(Ref ref) {
  return ref.read(remoteConfigServiceProvider).getSupportedLanguages();
}

@riverpod
Map<String, dynamic> themeConfiguration(Ref ref) {
  return ref.watch(getJsonConfigProvider(ReceitaAgroConfigKey.themeConfiguration));
}

/// Premium feature helpers
@riverpod
bool isPremiumEnabled(Ref ref) {
  return ref.watch(isFeatureEnabledProvider(ReceitaAgroFeatureFlag.enablePremiumFeatures));
}

@riverpod
bool isAdvancedDiagnosticsEnabled(Ref ref) {
  return ref.watch(isFeatureEnabledProvider(ReceitaAgroFeatureFlag.enableAdvancedDiagnostics));
}

@riverpod
bool isOfflineModeEnabled(Ref ref) {
  return ref.watch(isFeatureEnabledProvider(ReceitaAgroFeatureFlag.enableOfflineMode));
}

/// Performance feature helpers
@riverpod
bool isImageOptimizationEnabled(Ref ref) {
  return ref.watch(isFeatureEnabledProvider(ReceitaAgroFeatureFlag.enableImageOptimization));
}

@riverpod
bool isDataCachingEnabled(Ref ref) {
  return ref.watch(isFeatureEnabledProvider(ReceitaAgroFeatureFlag.enableDataCaching));
}

@riverpod
bool isPreloadContentEnabled(Ref ref) {
  return ref.watch(isFeatureEnabledProvider(ReceitaAgroFeatureFlag.enablePreloadContent));
}

/// Analytics feature helpers
@riverpod
bool isDetailedAnalyticsEnabled(Ref ref) {
  return ref.watch(isFeatureEnabledProvider(ReceitaAgroFeatureFlag.enableDetailedAnalytics));
}

@riverpod
bool isPerformanceMonitoringEnabled(Ref ref) {
  return ref.watch(isFeatureEnabledProvider(ReceitaAgroFeatureFlag.enablePerformanceMonitoring));
}

/// Business logic helpers
@riverpod
bool isSubscriptionValidationEnabled(Ref ref) {
  return ref.watch(isFeatureEnabledProvider(ReceitaAgroFeatureFlag.enableSubscriptionValidation));
}

@riverpod
bool isDeviceManagementEnabled(Ref ref) {
  return ref.watch(isFeatureEnabledProvider(ReceitaAgroFeatureFlag.enableDeviceManagement));
}

/// Configuration helpers
@riverpod
int maxDevicesPerSubscription(Ref ref) {
  return ref.watch(getIntConfigProvider(ReceitaAgroConfigKey.maxDevicesPerSubscription));
}

@riverpod
int subscriptionGracePeriodHours(Ref ref) {
  return ref.watch(getIntConfigProvider(ReceitaAgroConfigKey.subscriptionGracePeriodHours));
}

@riverpod
double imageQualityLevel(Ref ref) {
  return ref.watch(getDoubleConfigProvider(ReceitaAgroConfigKey.imageQualityLevel));
}

@riverpod
int maxCacheSize(Ref ref) {
  return ref.watch(getIntConfigProvider(ReceitaAgroConfigKey.maxCacheSize));
}

/// Debug information provider
@riverpod
Map<String, dynamic> remoteConfigDebugInfo(Ref ref) {
  if (!EnvironmentConfig.enableLogging) return {};

  final state = ref.watch(remoteConfigProvider);

  return {
    'isInitialized': state.isInitialized,
    'isLoading': state.isLoading,
    'lastError': state.lastError,
    'lastUpdated': state.lastUpdated?.toIso8601String(),
    'featureFlags': state.featureFlags.map((key, value) => MapEntry(key.key, value)),
    'configurations': state.configurations.map((key, value) => MapEntry(key.key, value)),
  };
}
