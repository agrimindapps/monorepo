import 'dart:async';
import 'dart:developer' as developer;

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../services/remote_config_service.dart';

/// Provider for Remote Config state management
/// Follows Provider pattern used throughout ReceitaAgro app
class RemoteConfigProvider extends ChangeNotifier {
  final ReceitaAgroRemoteConfigService _remoteConfigService;
  
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _lastError;
  DateTime? _lastUpdated;
  Timer? _refreshTimer;
  final Map<ReceitaAgroFeatureFlag, bool> _featureFlags = {};
  final Map<ReceitaAgroConfigKey, dynamic> _configurations = {};

  RemoteConfigProvider({
    ReceitaAgroRemoteConfigService? remoteConfigService,
  }) : _remoteConfigService = remoteConfigService ?? ReceitaAgroRemoteConfigService.instance;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  DateTime? get lastUpdated => _lastUpdated;

  /// Initialize Remote Config Provider
  Future<void> initialize() async {
    if (_isInitialized) return;

    _setLoading(true);
    _clearError();

    try {
      await _remoteConfigService.initialize();
      await _loadAllValues();
      _setupAutoRefresh();
      
      _isInitialized = true;
      _lastUpdated = DateTime.now();

      if (EnvironmentConfig.enableLogging) {
        developer.log(
          '✅ RemoteConfigProvider initialized successfully',
          name: 'RemoteConfigProvider',
        );
      }
    } catch (e, stackTrace) {
      _setError('Failed to initialize Remote Config: $e');
      
      if (EnvironmentConfig.enableAnalytics) {
      }
      
      developer.log(
        '❌ RemoteConfigProvider initialization failed: $e',
        name: 'RemoteConfigProvider',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh Remote Config values
  Future<void> refresh() async {
    if (!_isInitialized) {
      await initialize();
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      final updated = await _remoteConfigService.fetchAndActivate();
      
      if (updated) {
        await _loadAllValues();
        _lastUpdated = DateTime.now();
        
        if (EnvironmentConfig.enableLogging) {
          developer.log(
            '🔄 Remote Config values refreshed',
            name: 'RemoteConfigProvider',
          );
        }
      }
    } catch (e) {
      _setError('Failed to refresh Remote Config: $e');
      
      developer.log(
        '⚠️ RemoteConfigProvider refresh failed: $e',
        name: 'RemoteConfigProvider',
        error: e,
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Check if a feature is enabled
  bool isFeatureEnabled(ReceitaAgroFeatureFlag feature) {
    if (!_isInitialized) {
      return _featureFlags[feature] ?? _remoteConfigService.isFeatureEnabled(feature);
    }
    
    return _featureFlags[feature] ?? false;
  }

  /// Get string configuration value
  String getStringConfig(ReceitaAgroConfigKey key) {
    if (!_isInitialized) {
      return _remoteConfigService.getStringConfig(key);
    }
    
    return _configurations[key]?.toString() ?? '';
  }

  /// Get int configuration value
  int getIntConfig(ReceitaAgroConfigKey key) {
    if (!_isInitialized) {
      return _remoteConfigService.getIntConfig(key);
    }
    
    final value = _configurations[key];
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Get double configuration value
  double getDoubleConfig(ReceitaAgroConfigKey key) {
    if (!_isInitialized) {
      return _remoteConfigService.getDoubleConfig(key);
    }
    
    final value = _configurations[key];
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    if (value is int) return value.toDouble();
    return 0.0;
  }

  /// Get JSON configuration value
  Map<String, dynamic> getJsonConfig(ReceitaAgroConfigKey key) {
    if (!_isInitialized) {
      return _remoteConfigService.getJsonConfig(key);
    }
    
    final value = _configurations[key];
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

  /// Load all values from Remote Config service
  Future<void> _loadAllValues() async {
    for (final feature in ReceitaAgroFeatureFlag.values) {
      _featureFlags[feature] = _remoteConfigService.isFeatureEnabled(feature);
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
          _configurations[config] = _remoteConfigService.getIntConfig(config);
          break;
        case ReceitaAgroConfigKey.imageQualityLevel:
          _configurations[config] = _remoteConfigService.getDoubleConfig(config);
          break;
        case ReceitaAgroConfigKey.themeConfiguration:
          _configurations[config] = _remoteConfigService.getJsonConfig(config);
          break;
        default:
          _configurations[config] = _remoteConfigService.getStringConfig(config);
          break;
      }
    }
  }

  /// Setup auto-refresh timer
  void _setupAutoRefresh() {
    if (!EnvironmentConfig.isDebugMode && !isFeatureEnabled(ReceitaAgroFeatureFlag.enableDetailedAnalytics)) {
      return;
    }

    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 15), // Refresh every 15 minutes in debug
      (_) => refresh(),
    );
  }

  /// Set loading state
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Set error state
  void _setError(String error) {
    _lastError = error;
    notifyListeners();
  }

  /// Clear error state
  void _clearError() {
    if (_lastError != null) {
      _lastError = null;
      notifyListeners();
    }
  }

  /// Get debug information
  Map<String, dynamic> getDebugInfo() {
    if (!EnvironmentConfig.enableLogging) return {};
    
    return {
      'isInitialized': _isInitialized,
      'isLoading': _isLoading,
      'lastError': _lastError,
      'lastUpdated': _lastUpdated?.toIso8601String(),
      'featureFlags': _featureFlags.map((key, value) => MapEntry(key.key, value)),
      'configurations': _configurations.map((key, value) => MapEntry(key.key, value)),
    };
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
