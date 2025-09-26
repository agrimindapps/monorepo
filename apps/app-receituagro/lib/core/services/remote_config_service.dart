import 'dart:convert';
import 'dart:developer' as developer;

import 'package:core/core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Feature flags available in ReceitaAgro app
enum ReceitaAgroFeatureFlag {
  // Premium features
  enablePremiumFeatures('enable_premium_features'),
  enableAdvancedDiagnostics('enable_advanced_diagnostics'),
  enableOfflineMode('enable_offline_mode'),
  enablePushNotifications('enable_push_notifications'),

  // A/B Testing features
  enableNewUiDesign('enable_new_ui_design'),
  enableImprovedOnboarding('enable_improved_onboarding'),
  enableGamification('enable_gamification'),

  // Performance features
  enableImageOptimization('enable_image_optimization'),
  enableDataCaching('enable_data_caching'),
  enablePreloadContent('enable_preload_content'),

  // Analytics and monitoring
  enableDetailedAnalytics('enable_detailed_analytics'),
  enablePerformanceMonitoring('enable_performance_monitoring'),
  enableCrashReporting('enable_crash_reporting'),

  // Business logic
  enableSubscriptionValidation('enable_subscription_validation'),
  enableDeviceManagement('enable_device_management'),
  enableContentSynchronization('enable_content_synchronization');

  const ReceitaAgroFeatureFlag(this.key);
  final String key;
}

/// Configuration keys for dynamic app settings
enum ReceitaAgroConfigKey {
  // Subscription settings
  maxDevicesPerSubscription('max_devices_per_subscription'),
  subscriptionGracePeriodHours('subscription_grace_period_hours'),

  // Performance settings
  imageQualityLevel('image_quality_level'),
  maxCacheSize('max_cache_size_mb'),
  apiTimeoutSeconds('api_timeout_seconds'),

  // Content settings
  supportedLanguages('supported_languages'),
  defaultLanguage('default_language'),
  contentUpdateInterval('content_update_interval_hours'),

  // Analytics settings
  analyticsEventBatchSize('analytics_event_batch_size'),
  analyticsFlushInterval('analytics_flush_interval_minutes'),

  // UI/UX settings
  onboardingStepsCount('onboarding_steps_count'),
  homeScreenLayoutType('home_screen_layout_type'),
  themeConfiguration('theme_configuration');

  const ReceitaAgroConfigKey(this.key);
  final String key;
}

/// ReceitaAgro Remote Config Service
/// Handles Firebase Remote Config for feature flags and dynamic configuration
class ReceitaAgroRemoteConfigService {
  static ReceitaAgroRemoteConfigService? _instance;
  static ReceitaAgroRemoteConfigService get instance {
    _instance ??= ReceitaAgroRemoteConfigService._internal();
    return _instance!;
  }

  ReceitaAgroRemoteConfigService._internal();

  FirebaseRemoteConfig? _remoteConfig;
  bool _initialized = false;

  /// Initialize Remote Config with default values
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _remoteConfig = FirebaseRemoteConfig.instance;

      // Set config settings
      await _remoteConfig!.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval:
              EnvironmentConfig.isDebugMode
                  ? const Duration(seconds: 30) // Fast iteration in debug
                  : const Duration(hours: 1), // Conservative in production
        ),
      );

      // Set default values
      await _remoteConfig!.setDefaults(_getDefaultValues());

      // Fetch and activate
      await _fetchAndActivate();

      _initialized = true;

      if (EnvironmentConfig.enableLogging) {
        developer.log(
          '✅ ReceitaAgro Remote Config initialized successfully',
          name: 'RemoteConfigService',
        );
      }
    } catch (e, stackTrace) {
      if (EnvironmentConfig.enableAnalytics) {
        // Log to Crashlytics in production
        // FirebaseCrashlytics.instance.recordError(e, stackTrace);
      }

      developer.log(
        '❌ Failed to initialize Remote Config: $e',
        name: 'RemoteConfigService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Fetch and activate remote config
  Future<bool> fetchAndActivate() async {
    if (!_initialized || _remoteConfig == null) {
      await initialize();
    }

    return await _fetchAndActivate();
  }

  Future<bool> _fetchAndActivate() async {
    try {
      final activated = await _remoteConfig!.fetchAndActivate();

      if (EnvironmentConfig.enableLogging) {
        developer.log(
          'Remote Config ${activated ? "updated with new values" : "already up to date"}',
          name: 'RemoteConfigService',
        );
      }

      return activated;
    } catch (e) {
      developer.log(
        '⚠️ Failed to fetch Remote Config: $e',
        name: 'RemoteConfigService',
        error: e,
      );
      return false;
    }
  }

  /// Check if a feature flag is enabled
  bool isFeatureEnabled(ReceitaAgroFeatureFlag feature) {
    if (!_initialized || _remoteConfig == null) {
      // Return default value if not initialized
      return _getFeatureDefaultValue(feature);
    }

    try {
      return _remoteConfig!.getBool(feature.key);
    } catch (e) {
      developer.log(
        '⚠️ Error getting feature flag ${feature.key}: $e',
        name: 'RemoteConfigService',
      );
      return _getFeatureDefaultValue(feature);
    }
  }

  /// Get configuration value as string
  String getStringConfig(ReceitaAgroConfigKey key) {
    if (!_initialized || _remoteConfig == null) {
      return _getConfigDefaultValue(key);
    }

    try {
      return _remoteConfig!.getString(key.key);
    } catch (e) {
      developer.log(
        '⚠️ Error getting config ${key.key}: $e',
        name: 'RemoteConfigService',
      );
      return _getConfigDefaultValue(key);
    }
  }

  /// Get configuration value as int
  int getIntConfig(ReceitaAgroConfigKey key) {
    if (!_initialized || _remoteConfig == null) {
      return int.tryParse(_getConfigDefaultValue(key)) ?? 0;
    }

    try {
      return _remoteConfig!.getInt(key.key);
    } catch (e) {
      developer.log(
        '⚠️ Error getting int config ${key.key}: $e',
        name: 'RemoteConfigService',
      );
      return int.tryParse(_getConfigDefaultValue(key)) ?? 0;
    }
  }

  /// Get configuration value as double
  double getDoubleConfig(ReceitaAgroConfigKey key) {
    if (!_initialized || _remoteConfig == null) {
      return double.tryParse(_getConfigDefaultValue(key)) ?? 0.0;
    }

    try {
      return _remoteConfig!.getDouble(key.key);
    } catch (e) {
      developer.log(
        '⚠️ Error getting double config ${key.key}: $e',
        name: 'RemoteConfigService',
      );
      return double.tryParse(_getConfigDefaultValue(key)) ?? 0.0;
    }
  }

  /// Get configuration as JSON object
  Map<String, dynamic> getJsonConfig(ReceitaAgroConfigKey key) {
    final jsonString = getStringConfig(key);
    try {
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      developer.log(
        '⚠️ Error parsing JSON config ${key.key}: $e',
        name: 'RemoteConfigService',
      );
      return {};
    }
  }

  /// Get list of supported languages
  List<String> getSupportedLanguages() {
    final languagesJson = getStringConfig(
      ReceitaAgroConfigKey.supportedLanguages,
    );
    try {
      final languages = json.decode(languagesJson) as List;
      return languages.cast<String>();
    } catch (e) {
      return ['pt', 'en']; // Default fallback
    }
  }

  /// Get theme configuration
  Map<String, dynamic> getThemeConfiguration() {
    return getJsonConfig(ReceitaAgroConfigKey.themeConfiguration);
  }

  /// Get all current values (for debugging)
  Map<String, dynamic> getAllValues() {
    if (!_initialized || _remoteConfig == null) {
      return {};
    }

    return _remoteConfig!.getAll().map(
      (key, value) => MapEntry(key, value.asString()),
    );
  }

  /// Default values for Remote Config
  Map<String, dynamic> _getDefaultValues() {
    return {
      // Feature flags defaults
      ...ReceitaAgroFeatureFlag.values.asMap().map(
        (_, feature) => MapEntry(feature.key, _getFeatureDefaultValue(feature)),
      ),

      // Configuration defaults
      ...ReceitaAgroConfigKey.values.asMap().map(
        (_, config) => MapEntry(config.key, _getConfigDefaultValue(config)),
      ),
    };
  }

  /// Get default value for feature flag
  bool _getFeatureDefaultValue(ReceitaAgroFeatureFlag feature) {
    switch (feature) {
      // Premium features - disabled by default
      case ReceitaAgroFeatureFlag.enablePremiumFeatures:
      case ReceitaAgroFeatureFlag.enableAdvancedDiagnostics:
        return false;

      // Core features - enabled by default
      case ReceitaAgroFeatureFlag.enableOfflineMode:
      case ReceitaAgroFeatureFlag.enablePushNotifications:
      case ReceitaAgroFeatureFlag.enableImageOptimization:
      case ReceitaAgroFeatureFlag.enableDataCaching:
        return true;

      // A/B testing features - disabled by default
      case ReceitaAgroFeatureFlag.enableNewUiDesign:
      case ReceitaAgroFeatureFlag.enableImprovedOnboarding:
      case ReceitaAgroFeatureFlag.enableGamification:
        return false;

      // Performance features - enabled by default
      case ReceitaAgroFeatureFlag.enablePreloadContent:
        return true;

      // Analytics - follows environment config
      case ReceitaAgroFeatureFlag.enableDetailedAnalytics:
      case ReceitaAgroFeatureFlag.enablePerformanceMonitoring:
      case ReceitaAgroFeatureFlag.enableCrashReporting:
        return EnvironmentConfig.enableAnalytics;

      // Business logic - enabled by default
      case ReceitaAgroFeatureFlag.enableSubscriptionValidation:
      case ReceitaAgroFeatureFlag.enableDeviceManagement:
      case ReceitaAgroFeatureFlag.enableContentSynchronization:
        return true;
    }
  }

  /// Get default value for configuration key
  String _getConfigDefaultValue(ReceitaAgroConfigKey key) {
    switch (key) {
      // Subscription settings
      case ReceitaAgroConfigKey.maxDevicesPerSubscription:
        return '3';
      case ReceitaAgroConfigKey.subscriptionGracePeriodHours:
        return '24';

      // Performance settings
      case ReceitaAgroConfigKey.imageQualityLevel:
        return '0.8';
      case ReceitaAgroConfigKey.maxCacheSize:
        return '100';
      case ReceitaAgroConfigKey.apiTimeoutSeconds:
        return '30';

      // Content settings
      case ReceitaAgroConfigKey.supportedLanguages:
        return '["pt", "en"]';
      case ReceitaAgroConfigKey.defaultLanguage:
        return 'pt';
      case ReceitaAgroConfigKey.contentUpdateInterval:
        return '24';

      // Analytics settings
      case ReceitaAgroConfigKey.analyticsEventBatchSize:
        return '50';
      case ReceitaAgroConfigKey.analyticsFlushInterval:
        return '5';

      // UI/UX settings
      case ReceitaAgroConfigKey.onboardingStepsCount:
        return '4';
      case ReceitaAgroConfigKey.homeScreenLayoutType:
        return 'grid';
      case ReceitaAgroConfigKey.themeConfiguration:
        return '{"primaryColor": "#4CAF50", "accentColor": "#FF9800"}';
    }
  }
}
