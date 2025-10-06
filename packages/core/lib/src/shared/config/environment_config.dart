import 'package:flutter/foundation.dart';

enum Environment { development, staging, production }

/// Generic environment configuration for the monorepo
/// This provides common environment utilities without app-specific configuration
/// Apps should create their own specific environment configs that extend or use this
class EnvironmentConfig {
  static Environment get environment {
    const env = String.fromEnvironment('ENV', defaultValue: 'development');
    switch (env) {
      case 'production':
        return Environment.production;
      case 'staging':
        return Environment.staging;
      case 'development':
      default:
        return Environment.development;
    }
  }

  static String get environmentName => environment.name;
  static bool get isDebugMode {
    return environment == Environment.development;
  }

  static bool get isProductionMode {
    return environment == Environment.production;
  }

  static bool get isStagingMode {
    return environment == Environment.staging;
  }
  static bool get enableLogging {
    return environment != Environment.production;
  }

  static bool get enableAnalytics {
    return environment == Environment.production || environment == Environment.staging;
  }
  static String get storagePrefix {
    switch (environment) {
      case Environment.development:
        return 'dev_';
      case Environment.staging:
        return 'staging_';
      case Environment.production:
        return '';
    }
  }
  static String getApiKey(String keyName, {String? fallback}) {
    try {
      if (kIsWeb) {
        return fallback ?? 'dummy_web_key';
      } else {
        return fallback ?? 'dummy_dev_key';
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ WARNING: Environment key $keyName not available, using fallback');
      }
      return fallback ?? 'dummy_fallback_key';
    }
  }
  static String getFirebaseProjectId(String projectBaseName) {
    switch (environment) {
      case Environment.development:
        return '$projectBaseName-dev';
      case Environment.staging:
        return '$projectBaseName-staging';
      case Environment.production:
        return '$projectBaseName-prod';
    }
  }
  static String getApiBaseUrl(String domain) {
    switch (environment) {
      case Environment.development:
        return 'https://dev-api.$domain';
      case Environment.staging:
        return 'https://staging-api.$domain';
      case Environment.production:
        return 'https://api.$domain';
    }
  }
  static String getProductId(String baseName) {
    switch (environment) {
      case Environment.development:
        return '${baseName}_dev';
      case Environment.staging:
        return '${baseName}_staging';
      case Environment.production:
        return baseName;
    }
  }

  /// Print current configuration for debugging (non-sensitive data only)
  static void printConfig({Map<String, dynamic>? additionalConfig}) {
    if (kDebugMode && isDebugMode) {
      debugPrint('=== Core Environment Configuration ===');
      debugPrint('Environment: $environmentName');
      debugPrint('Enable Logging: $enableLogging');
      debugPrint('Enable Analytics: $enableAnalytics');
      debugPrint('Storage Prefix: $storagePrefix');
      
      if (additionalConfig != null) {
        debugPrint('=== Additional Configuration ===');
        additionalConfig.forEach((key, value) {
          if (!_isSensitiveKey(key)) {
            debugPrint('$key: $value');
          } else {
            debugPrint('$key: [REDACTED]');
          }
        });
      }
      debugPrint('==========================================');
    }
  }

  /// Checks if a configuration key contains sensitive information
  static bool _isSensitiveKey(String key) {
    final sensitivePatterns = ['key', 'secret', 'password', 'token', 'credential', 'api'];
    final keyLower = key.toLowerCase();
    return sensitivePatterns.any((pattern) => keyLower.contains(pattern));
  }
}

/// Base class for app-specific environment configurations
/// Apps should extend this class to add their own specific configurations
abstract class AppEnvironmentConfig {
  /// App identifier
  String get appId;

  /// Firebase project base name
  String get firebaseProjectBaseName;

  /// API domain
  String get apiDomain;
  String get firebaseProjectId => 
      EnvironmentConfig.getFirebaseProjectId(firebaseProjectBaseName);

  String get apiBaseUrl => 
      EnvironmentConfig.getApiBaseUrl(apiDomain);

  Environment get environment => EnvironmentConfig.environment;
  bool get isDebugMode => EnvironmentConfig.isDebugMode;
  bool get isProductionMode => EnvironmentConfig.isProductionMode;
  bool get enableLogging => EnvironmentConfig.enableLogging;
  bool get enableAnalytics => EnvironmentConfig.enableAnalytics;
}