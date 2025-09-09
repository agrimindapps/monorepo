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

  // Generic Configuration Methods
  static bool get isDebugMode {
    return environment == Environment.development;
  }

  static bool get isProductionMode {
    return environment == Environment.production;
  }

  static bool get isStagingMode {
    return environment == Environment.staging;
  }

  // Generic Logging Configuration
  static bool get enableLogging {
    return environment != Environment.production;
  }

  static bool get enableAnalytics {
    return environment == Environment.production || environment == Environment.staging;
  }

  // Generic Storage Configuration (for different environments)
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

  // Generic API Key Helper
  static String getApiKey(String keyName, {String? fallback}) {
    final key = String.fromEnvironment(keyName, defaultValue: fallback ?? '');
    if (key.isEmpty || (fallback != null && key == fallback)) {
      if (kDebugMode && fallback != null) {
        print('⚠️ WARNING: Using fallback value for $keyName');
      }
    }
    return key;
  }

  // Generic Firebase Project ID Helper
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

  // Generic API Base URL Helper
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

  // Generic Product ID Helper for subscriptions
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

  /// Print current configuration for debugging
  static void printConfig({Map<String, dynamic>? additionalConfig}) {
    if (kDebugMode && isDebugMode) {
      print('=== Core Environment Configuration ===');
      print('Environment: $environmentName');
      print('Enable Logging: $enableLogging');
      print('Enable Analytics: $enableAnalytics');
      print('Storage Prefix: $storagePrefix');
      
      if (additionalConfig != null) {
        print('=== Additional Configuration ===');
        additionalConfig.forEach((key, value) {
          print('$key: $value');
        });
      }
      print('==========================================');
    }
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

  // Convenience getters using core helpers
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