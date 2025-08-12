// Flutter

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../config/business_rules.dart';

// Local imports

/// Service for managing remote configuration updates
///
/// This service handles loading business rules from external sources
/// like Firebase Remote Config, REST APIs, or local storage.
class VeiculosRemoteConfigService {
  static const Duration _defaultTimeout = Duration(seconds: 10);
  static const Duration _cacheExpiration = Duration(hours: 1);

  DateTime? _lastFetchTime;
  VeiculosBusinessConfig? _cachedConfig;

  /// ========================================
  /// PUBLIC API
  /// ========================================

  /// Load configuration from remote source
  Future<VeiculosBusinessConfig> loadRemoteConfig({
    Duration? timeout,
    bool forceRefresh = false,
  }) async {
    // Check cache first
    if (!forceRefresh && _isCacheValid()) {
      if (kDebugMode) {
        debugPrint('[RemoteConfigService] Using cached config');
      }
      return _cachedConfig!;
    }

    try {
      // Simulate remote config loading (replace with actual implementation)
      final remoteData =
          await _fetchFromRemoteSource(timeout ?? _defaultTimeout);

      final config = VeiculosBusinessConfig.fromRemoteConfig(remoteData);

      // Update cache
      _cachedConfig = config;
      _lastFetchTime = DateTime.now();

      if (kDebugMode) {
        debugPrint(
            '[RemoteConfigService] Remote config loaded: ${config.profileName}');
      }

      return config;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[RemoteConfigService] Error loading remote config: $e');
      }

      // Return cached config if available, otherwise default
      return _cachedConfig ?? VeiculosBusinessConfig.defaultConfig();
    }
  }

  /// Load configuration for specific user profile
  Future<VeiculosBusinessConfig> loadConfigForProfile(
      UserProfile profile) async {
    try {
      // Try to load profile-specific config from remote
      final profileData = await _fetchProfileConfig(profile);
      return VeiculosBusinessConfig.fromRemoteConfig(profileData);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[RemoteConfigService] Error loading profile config: $e');
      }

      // Fallback to local profile config
      return VeiculosBusinessConfig.fromProfile(profile);
    }
  }

  /// Initialize remote config with automatic updates
  Future<void> initializeWithAutoUpdate({
    Duration updateInterval = const Duration(minutes: 30),
    required Function(VeiculosBusinessConfig) onConfigUpdate,
  }) async {
    // Load initial config
    try {
      final config = await loadRemoteConfig();
      onConfigUpdate(config);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[RemoteConfigService] Error in initial config load: $e');
      }
    }

    // Set up periodic updates (in a real app, use a proper timer or stream)
    if (kDebugMode) {
      debugPrint(
          '[RemoteConfigService] Auto-update initialized with interval: $updateInterval');
    }
    // TODO: Implement actual periodic updates
  }

  /// Check if configuration needs update
  bool needsUpdate() {
    return !_isCacheValid();
  }

  /// Clear cached configuration
  void clearCache() {
    _cachedConfig = null;
    _lastFetchTime = null;
    if (kDebugMode) {
      debugPrint('[RemoteConfigService] Cache cleared');
    }
  }

  /// ========================================
  /// REMOTE SOURCE SIMULATION
  /// ========================================

  /// Simulate fetching from remote source (Firebase Remote Config, API, etc.)
  Future<Map<String, dynamic>> _fetchFromRemoteSource(Duration timeout) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Simulate different configurations based on environment
    if (kDebugMode) {
      // Debug configuration with more permissive settings
      return {
        'profile_name': 'Debug',
        'max_vehicles': 5,
        'min_vehicle_year': 1900,
        'max_vehicle_year': DateTime.now().year + 5,
        'is_premium_enabled': true,
        'is_export_enabled': true,
        'is_advanced_stats_enabled': true,
        'max_import_file_size_mb': 50.0,
        'is_bulk_operations_enabled': true,
      };
    } else {
      // Production configuration
      return {
        'profile_name': 'Production',
        'max_vehicles': 2,
        'min_vehicle_year': 1950,
        'max_vehicle_year': DateTime.now().year + 2,
        'is_premium_enabled': false,
        'is_export_enabled': false,
        'is_advanced_stats_enabled': false,
        'max_import_file_size_mb': 1.0,
        'is_bulk_operations_enabled': false,
      };
    }
  }

  /// Simulate fetching profile-specific configuration
  Future<Map<String, dynamic>> _fetchProfileConfig(UserProfile profile) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final currentYear = DateTime.now().year;

    switch (profile) {
      case UserProfile.free:
        return {
          'profile_name': 'Free (Remote)',
          'max_vehicles': 3, // Slightly more generous than hardcoded
          'min_vehicle_year': 1950,
          'max_vehicle_year': currentYear + 2,
          'is_premium_enabled': false,
          'is_export_enabled': false,
          'is_advanced_stats_enabled': false,
          'max_import_file_size_mb': 2.0, // Slightly larger
          'is_bulk_operations_enabled': false,
        };

      case UserProfile.premium:
        return {
          'profile_name': 'Premium (Remote)',
          'max_vehicles': 15, // More than hardcoded
          'min_vehicle_year': 1900,
          'max_vehicle_year': currentYear + 5,
          'is_premium_enabled': true,
          'is_export_enabled': true,
          'is_advanced_stats_enabled': true,
          'max_import_file_size_mb': 25.0, // Larger than hardcoded
          'is_bulk_operations_enabled': true,
        };

      case UserProfile.enterprise:
        return {
          'profile_name': 'Enterprise (Remote)',
          'max_vehicles': 500, // Much larger than hardcoded
          'min_vehicle_year': 1800,
          'max_vehicle_year': currentYear + 10,
          'is_premium_enabled': true,
          'is_export_enabled': true,
          'is_advanced_stats_enabled': true,
          'max_import_file_size_mb': 500.0, // Much larger
          'is_bulk_operations_enabled': true,
        };
    }
  }

  /// ========================================
  /// CACHE MANAGEMENT
  /// ========================================

  bool _isCacheValid() {
    if (_cachedConfig == null || _lastFetchTime == null) {
      return false;
    }

    final timeSinceLastFetch = DateTime.now().difference(_lastFetchTime!);
    return timeSinceLastFetch < _cacheExpiration;
  }

  /// ========================================
  /// INTEGRATION HELPERS
  /// ========================================

  /// Integration with Firebase Remote Config (example)
  Future<Map<String, dynamic>> _fetchFromFirebaseRemoteConfig() async {
    // TODO: Implement Firebase Remote Config integration
    // Example:
    // final remoteConfig = FirebaseRemoteConfig.instance;
    // await remoteConfig.fetchAndActivate();
    // return {
    //   'max_vehicles': remoteConfig.getInt('max_vehicles'),
    //   'is_premium_enabled': remoteConfig.getBool('is_premium_enabled'),
    //   // ... other fields
    // };

    throw UnimplementedError(
        'Firebase Remote Config integration not implemented');
  }

  /// Integration with REST API (example)
  Future<Map<String, dynamic>> _fetchFromRestAPI(String userId) async {
    // TODO: Implement REST API integration
    // Example:
    // final response = await http.get(
    //   Uri.parse('https://api.example.com/config/$userId'),
    //   headers: {'Authorization': 'Bearer $token'},
    // );
    // return json.decode(response.body);

    throw UnimplementedError('REST API integration not implemented');
  }

  /// Integration with local storage (SharedPreferences)
  Future<Map<String, dynamic>?> _loadFromLocalStorage() async {
    // TODO: Implement SharedPreferences integration
    // Example:
    // final prefs = await SharedPreferences.getInstance();
    // final configJson = prefs.getString(_configKey);
    // if (configJson != null) {
    //   return json.decode(configJson);
    // }
    // return null;

    throw UnimplementedError('Local storage integration not implemented');
  }

  /// Save configuration to local storage
  Future<void> _saveToLocalStorage(Map<String, dynamic> config) async {
    // TODO: Implement SharedPreferences integration
    // Example:
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setString(_configKey, json.encode(config));

    if (kDebugMode) {
      debugPrint(
          '[RemoteConfigService] Config saved to local storage: ${config['profile_name']}');
    }
  }

  /// ========================================
  /// MONITORING AND DEBUGGING
  /// ========================================

  /// Get configuration status for debugging
  Map<String, dynamic> getConfigStatus() {
    return {
      'has_cached_config': _cachedConfig != null,
      'last_fetch_time': _lastFetchTime?.toIso8601String(),
      'cache_valid': _isCacheValid(),
      'cached_profile': _cachedConfig?.profileName,
      'cache_age_minutes': _lastFetchTime != null
          ? DateTime.now().difference(_lastFetchTime!).inMinutes
          : null,
    };
  }

  /// Log configuration change
  void logConfigurationChange(
    VeiculosBusinessConfig oldConfig,
    VeiculosBusinessConfig newConfig,
  ) {
    if (kDebugMode) {
      debugPrint('[RemoteConfigService] Configuration changed:');
      debugPrint(
          '  Profile: ${oldConfig.profileName} → ${newConfig.profileName}');
      debugPrint(
          '  Max Vehicles: ${oldConfig.maxVehicles} → ${newConfig.maxVehicles}');
      debugPrint(
          '  Premium: ${oldConfig.isPremiumEnabled} → ${newConfig.isPremiumEnabled}');
    }
  }
}

/// ========================================
/// CONFIGURATION CHANGE NOTIFIER
/// ========================================

/// Notifier for configuration changes
class VeiculosConfigChangeNotifier {
  final List<Function(VeiculosBusinessConfig)> _listeners = [];

  /// Add listener for configuration changes
  void addListener(Function(VeiculosBusinessConfig) listener) {
    _listeners.add(listener);
  }

  /// Remove listener
  void removeListener(Function(VeiculosBusinessConfig) listener) {
    _listeners.remove(listener);
  }

  /// Notify all listeners of configuration change
  void notifyConfigChange(VeiculosBusinessConfig newConfig) {
    for (final listener in _listeners) {
      try {
        listener(newConfig);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[ConfigChangeNotifier] Error in listener: $e');
        }
      }
    }
  }

  /// Clear all listeners
  void clearListeners() {
    _listeners.clear();
  }
}
