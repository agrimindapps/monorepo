import 'package:flutter/foundation.dart';

/// An enum representing the possible runtime environments.
enum Environment {
  /// The development environment, for local development and debugging.
  development,

  /// The staging environment, for pre-production testing.
  staging,

  /// The production environment, for the live application.
  production,
}

/// A generic environment configuration provider for the monorepo.
///
/// This class provides common, non-sensitive environment utilities. Apps should
/// extend [AppEnvironmentConfig] to provide their own app-specific configurations.
class EnvironmentConfig {
  /// The current runtime environment, determined by the 'ENV' compile-time variable.
  static Environment get environment {
    const env = String.fromEnvironment('ENV', defaultValue: 'development');
    return Environment.values.firstWhere(
      (e) => e.name == env,
      orElse: () => Environment.development,
    );
  }

  /// The name of the current environment (e.g., "production").
  static String get environmentName => environment.name;

  /// Returns `true` if the app is running in the development environment.
  static bool get isDebugMode => environment == Environment.development;

  /// Returns `true` if the app is running in the production environment.
  static bool get isProductionMode => environment == Environment.production;

  /// Returns `true` if the app is running in the staging environment.
  static bool get isStagingMode => environment == Environment.staging;

  /// Returns `true` if logging should be enabled.
  static bool get enableLogging => !isProductionMode;

  /// Returns `true` if analytics should be enabled.
  static bool get enableAnalytics => isProductionMode || isStagingMode;

  /// A prefix for local storage keys to prevent data conflicts between environments.
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

  /// **DANGER**: This is a placeholder for retrieving API keys and should not be used for production secrets.
  ///
  /// In a real application, use a secure secret management solution like `flutter_dotenv`
  /// or compile-time variables via `--dart-define`.
  static String getApiKey(String keyName, {String? fallback}) {
    final dummyKey = 'DUMMY_KEY_FOR_${keyName.toUpperCase()}';
    if (kDebugMode) {
      // ignore: avoid_print
      print(
          '⚠️ WARNING: Using placeholder for API key "$keyName". DO NOT use this in production.');
    }
    return fallback ?? dummyKey;
  }

  /// Constructs a Firebase project ID based on a [projectBaseName] and the current environment.
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

  /// Constructs an API base URL based on a [domain] and the current environment.
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

  /// Constructs a product identifier for in-app purchases based on a [baseName] and the current environment.
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

  /// Prints the current core and any additional configuration for debugging purposes.
  ///
  /// This method only prints in debug mode and redacts keys that appear to be sensitive.
  static void printConfig({Map<String, dynamic>? additionalConfig}) {
    if (kDebugMode) {
      debugPrint('╔══════════════════════════════════════════╗');
      debugPrint('║        Core Environment Configuration      ║');
      debugPrint('╟──────────────────────────────────────────╢');
      debugPrint('║ Environment: $environmentName');
      debugPrint('║ Enable Logging: $enableLogging');
      debugPrint('║ Enable Analytics: $enableAnalytics');
      debugPrint('║ Storage Prefix: "$storagePrefix"');

      if (additionalConfig != null) {
        debugPrint('╟──────────────────────────────────────────╢');
        debugPrint('║        Additional Configuration          ║');
        debugPrint('╟──────────────────────────────────────────╢');
        additionalConfig.forEach((key, value) {
          final displayValue = _isSensitiveKey(key) ? '[REDACTED]' : value;
          debugPrint('║ $key: $displayValue');
        });
      }
      debugPrint('╚══════════════════════════════════════════╝');
    }
  }

  /// Checks if a configuration key appears to be sensitive.
  static bool _isSensitiveKey(String key) {
    final sensitivePatterns = ['key', 'secret', 'password', 'token', 'credential', 'api'];
    final keyLower = key.toLowerCase();
    return sensitivePatterns.any(keyLower.contains);
  }
}

/// An abstract base class for creating app-specific environment configurations.
///
/// Apps should extend this class to define their own configurations, such as
/// API domains and Firebase project names.
abstract class AppEnvironmentConfig {
  /// A unique identifier for the application.
  String get appId;

  /// The base name of the Firebase project (e.g., "my-cool-app").
  String get firebaseProjectBaseName;

  /// The domain for the application's API.
  String get apiDomain;

  /// The full Firebase project ID, derived from the [firebaseProjectBaseName].
  String get firebaseProjectId =>
      EnvironmentConfig.getFirebaseProjectId(firebaseProjectBaseName);

  /// The full base URL for the API, derived from the [apiDomain].
  String get apiBaseUrl => EnvironmentConfig.getApiBaseUrl(apiDomain);

  // --- Convenience Getters ---

  /// The current runtime environment.
  Environment get environment => EnvironmentConfig.environment;

  /// Returns `true` if the app is in debug mode.
  bool get isDebugMode => EnvironmentConfig.isDebugMode;

  /// Returns `true` if the app is in production mode.
  bool get isProductionMode => EnvironmentConfig.isProductionMode;

  /// Returns `true` if logging should be enabled.
  bool get enableLogging => EnvironmentConfig.enableLogging;

  /// Returns `true` if analytics should be enabled.
  bool get enableAnalytics => EnvironmentConfig.enableAnalytics;
}