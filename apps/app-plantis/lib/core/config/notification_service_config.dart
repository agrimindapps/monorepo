import 'package:flutter/foundation.dart';

import '../services/enhanced_plantis_notification_service.dart';
import '../services/plantis_notification_service.dart';
import '../services/plantis_notification_service_v2.dart';

/// Configuration for notification service implementation
///
/// This class provides a centralized way to configure which notification
/// service implementation to use, with feature flags and migration support.
class NotificationServiceConfig {
  // Feature flags
  static bool _enhancedNotificationsEnabled = true;
  static bool _autoMigrateOnInit = true;
  static bool _fallbackToLegacyOnError = false;
  static bool _enableAnalytics = true;
  static bool _enableDebugMode = kDebugMode;

  // Migration settings
  static bool _migrationCompleted = false;
  static bool _bypassMigrationValidation = false;

  /// Factory method to get the appropriate notification service
  ///
  /// Returns the service based on current configuration:
  /// - Enhanced service if enabled and migration is complete
  /// - V2 service (backward compatible) for gradual migration
  /// - Legacy service as fallback
  static dynamic getNotificationService() {
    if (_enhancedNotificationsEnabled) {
      if (_migrationCompleted) {
        // Return pure enhanced service for full features
        return EnhancedPlantisNotificationService();
      } else {
        // Return V2 service for backward compatibility during migration
        return PlantisNotificationServiceV2();
      }
    } else {
      // Return legacy service
      return PlantisNotificationService();
    }
  }

  /// Factory method specifically for enhanced service
  static EnhancedPlantisNotificationService getEnhancedService() {
    return EnhancedPlantisNotificationService();
  }

  /// Factory method specifically for legacy service
  static PlantisNotificationService getLegacyService() {
    return PlantisNotificationService();
  }

  /// Factory method specifically for V2 service (backward compatible)
  static PlantisNotificationServiceV2 getV2Service() {
    return PlantisNotificationServiceV2();
  }

  // Configuration Methods

  /// Enables enhanced notification framework
  static void enableEnhancedNotifications({
    bool autoMigrate = true,
    bool enableAnalytics = true,
    bool enableDebugMode = kDebugMode,
  }) {
    _enhancedNotificationsEnabled = true;
    _autoMigrateOnInit = autoMigrate;
    _enableAnalytics = enableAnalytics;
    _enableDebugMode = enableDebugMode;

    if (_enableDebugMode) {
      debugPrint('🔧 Enhanced notifications enabled');
      debugPrint('   - Auto migrate: $autoMigrate');
      debugPrint('   - Analytics: $enableAnalytics');
      debugPrint('   - Debug mode: $enableDebugMode');
    }
  }

  /// Disables enhanced notification framework (use legacy)
  static void disableEnhancedNotifications() {
    _enhancedNotificationsEnabled = false;
    _autoMigrateOnInit = false;

    if (_enableDebugMode) {
      debugPrint('🔧 Enhanced notifications disabled - using legacy service');
    }
  }

  /// Enables gradual migration mode
  static void enableGradualMigration({bool fallbackToLegacyOnError = false}) {
    _enhancedNotificationsEnabled = true;
    _migrationCompleted = false;
    _fallbackToLegacyOnError = fallbackToLegacyOnError;

    if (_enableDebugMode) {
      debugPrint('🔄 Gradual migration mode enabled');
      debugPrint('   - Fallback on error: $fallbackToLegacyOnError');
    }
  }

  /// Marks migration as completed
  static void markMigrationComplete() {
    _migrationCompleted = true;

    if (_enableDebugMode) {
      debugPrint('✅ Notification migration marked as complete');
    }
  }

  /// Resets migration status
  static void resetMigration() {
    _migrationCompleted = false;

    if (_enableDebugMode) {
      debugPrint('🔄 Migration status reset');
    }
  }

  // Getters for current configuration

  /// Returns true if enhanced notifications are enabled
  static bool get isEnhancedNotificationsEnabled =>
      _enhancedNotificationsEnabled;

  /// Returns true if auto migration is enabled
  static bool get isAutoMigrateEnabled => _autoMigrateOnInit;

  /// Returns true if migration is completed
  static bool get isMigrationCompleted => _migrationCompleted;

  /// Returns true if should fallback to legacy on error
  static bool get shouldFallbackToLegacy => _fallbackToLegacyOnError;

  /// Returns true if analytics is enabled
  static bool get isAnalyticsEnabled => _enableAnalytics;

  /// Returns true if debug mode is enabled
  static bool get isDebugModeEnabled => _enableDebugMode;

  // Service Type Detection

  /// Returns the type of service that would be returned
  static String getServiceType() {
    if (_enhancedNotificationsEnabled) {
      if (_migrationCompleted) {
        return 'enhanced';
      } else {
        return 'v2_compatible';
      }
    } else {
      return 'legacy';
    }
  }

  /// Returns true if the current configuration uses enhanced features
  static bool get usesEnhancedFeatures {
    return _enhancedNotificationsEnabled;
  }

  /// Returns true if the current configuration is backward compatible
  static bool get isBackwardCompatible {
    return getServiceType() == 'v2_compatible' || getServiceType() == 'legacy';
  }

  // Development and Testing Methods

  /// Forces migration completion (for testing)
  static void forceMigrationComplete() {
    _migrationCompleted = true;
    _bypassMigrationValidation = true;

    if (_enableDebugMode) {
      debugPrint('🧪 Migration forced complete (for testing)');
    }
  }

  /// Enables test mode
  static void enableTestMode() {
    _enableDebugMode = true;
    _bypassMigrationValidation = true;

    if (_enableDebugMode) {
      debugPrint('🧪 Test mode enabled');
    }
  }

  /// Resets all configuration to defaults
  static void resetToDefaults() {
    _enhancedNotificationsEnabled = true;
    _autoMigrateOnInit = true;
    _fallbackToLegacyOnError = false;
    _enableAnalytics = true;
    _enableDebugMode = kDebugMode;
    _migrationCompleted = false;
    _bypassMigrationValidation = false;

    if (_enableDebugMode) {
      debugPrint('🔧 Notification service config reset to defaults');
    }
  }

  // Configuration Presets

  /// Development preset - enhanced with debug
  static void setDevelopmentPreset() {
    _enhancedNotificationsEnabled = true;
    _autoMigrateOnInit = true;
    _fallbackToLegacyOnError = true;
    _enableAnalytics = true;
    _enableDebugMode = true;
    _migrationCompleted = false;

    debugPrint('🛠️ Development preset applied');
  }

  /// Production preset - enhanced with minimal debug
  static void setProductionPreset() {
    _enhancedNotificationsEnabled = true;
    _autoMigrateOnInit = true;
    _fallbackToLegacyOnError = false;
    _enableAnalytics = true;
    _enableDebugMode = false;
    _migrationCompleted = true;

    if (kDebugMode) {
      debugPrint('🚀 Production preset applied');
    }
  }

  /// Testing preset - V2 service with test mode
  static void setTestingPreset() {
    _enhancedNotificationsEnabled = true;
    _autoMigrateOnInit = false;
    _fallbackToLegacyOnError = false;
    _enableAnalytics = false;
    _enableDebugMode = true;
    _migrationCompleted = false;
    _bypassMigrationValidation = true;

    debugPrint('🧪 Testing preset applied');
  }

  /// Legacy preset - use old service only
  static void setLegacyPreset() {
    _enhancedNotificationsEnabled = false;
    _autoMigrateOnInit = false;
    _fallbackToLegacyOnError = false;
    _enableAnalytics = false;
    _enableDebugMode = kDebugMode;
    _migrationCompleted = false;

    if (_enableDebugMode) {
      debugPrint('📜 Legacy preset applied');
    }
  }

  // Configuration Summary

  /// Returns a summary of current configuration
  static Map<String, dynamic> getConfigurationSummary() {
    return {
      'service_type': getServiceType(),
      'enhanced_enabled': _enhancedNotificationsEnabled,
      'auto_migrate': _autoMigrateOnInit,
      'migration_complete': _migrationCompleted,
      'fallback_enabled': _fallbackToLegacyOnError,
      'analytics_enabled': _enableAnalytics,
      'debug_enabled': _enableDebugMode,
      'bypass_validation': _bypassMigrationValidation,
      'backward_compatible': isBackwardCompatible,
      'uses_enhanced_features': usesEnhancedFeatures,
    };
  }

  /// Prints configuration summary to debug console
  static void printConfigurationSummary() {
    if (_enableDebugMode) {
      debugPrint('📋 Notification Service Configuration:');
      final config = getConfigurationSummary();
      config.forEach((key, value) {
        debugPrint('   $key: $value');
      });
    }
  }

  // Validation Methods

  /// Validates current configuration
  static List<String> validateConfiguration() {
    final errors = <String>[];

    // Check for conflicting settings
    if (!_enhancedNotificationsEnabled && _migrationCompleted) {
      errors.add(
        'Migration cannot be completed with enhanced notifications disabled',
      );
    }

    if (_autoMigrateOnInit && !_enhancedNotificationsEnabled) {
      errors.add('Auto migration enabled but enhanced notifications disabled');
    }

    if (_fallbackToLegacyOnError && _migrationCompleted) {
      errors.add('Fallback to legacy enabled but migration marked complete');
    }

    return errors;
  }

  /// Returns true if configuration is valid
  static bool get isConfigurationValid {
    return validateConfiguration().isEmpty;
  }

  /// Throws exception if configuration is invalid
  static void assertValidConfiguration() {
    final errors = validateConfiguration();
    if (errors.isNotEmpty) {
      throw StateError(
        'Invalid notification service configuration: ${errors.join(', ')}',
      );
    }
  }
}

/// Extension for easy service type checking
extension NotificationServiceTypeChecking on dynamic {
  bool get isEnhancedService => this is EnhancedPlantisNotificationService;
  bool get isV2Service => this is PlantisNotificationServiceV2;
  bool get isLegacyService =>
      this is PlantisNotificationService &&
      this is! PlantisNotificationServiceV2;

  String get serviceTypeName {
    if (isEnhancedService) return 'Enhanced';
    if (isV2Service) return 'V2 Compatible';
    if (isLegacyService) return 'Legacy';
    return 'Unknown';
  }
}

/// Usage examples:
///
/// ```dart
/// // Basic usage - get service based on current config
/// final service = NotificationServiceConfig.getNotificationService();
///
/// // Development setup
/// NotificationServiceConfig.setDevelopmentPreset();
/// final devService = NotificationServiceConfig.getNotificationService();
///
/// // Production setup
/// NotificationServiceConfig.setProductionPreset();
/// final prodService = NotificationServiceConfig.getNotificationService();
///
/// // Gradual migration
/// NotificationServiceConfig.enableGradualMigration();
/// final migrationService = NotificationServiceConfig.getNotificationService();
///
/// // Check service type
/// debugPrint('Using service: ${service.serviceTypeName}');
/// ```
