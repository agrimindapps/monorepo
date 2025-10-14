import 'dart:io';

import 'package:flutter/foundation.dart';

enum Environment { development, staging, production }

/// Exception thrown when environment configuration is invalid or missing
class ConfigurationException implements Exception {
  final String message;
  ConfigurationException(this.message);

  @override
  String toString() => 'ConfigurationException: $message';
}

/// Generic environment configuration for the monorepo
/// This provides common environment utilities without app-specific configuration
/// Apps should create their own specific environment configs that extend or use this
///
/// Usage:
/// ```dart
/// // In main.dart, before runApp:
/// await EnvironmentConfig.initialize();
///
/// // Access values:
/// final apiKey = EnvironmentConfig.get('FIREBASE_API_KEY');
/// ```
class EnvironmentConfig {
  static final Map<String, String> _config = {};
  static bool _initialized = false;
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
  /// Initializes environment configuration from .env file
  ///
  /// Looks for .env file in the project root
  /// Throws [ConfigurationException] if required keys are missing
  static Future<void> initialize({
    String? envFilePath,
    List<String>? requiredKeys,
  }) async {
    if (_initialized) {
      if (kDebugMode) {
        debugPrint('⚠️ EnvironmentConfig already initialized');
      }
      return;
    }

    try {
      // Try to load .env file (not available on Web)
      if (!kIsWeb) {
        final path = envFilePath ?? '.env';
        final envFile = File(path);

        if (await envFile.exists()) {
          await _loadEnvFile(envFile);
          if (kDebugMode) {
            debugPrint('✅ Loaded environment from $path');
          }
        } else {
          if (kDebugMode) {
            debugPrint(
              '⚠️ No .env file found at $path. Using compile-time environment or defaults.',
            );
          }
        }
      }

      // Validate required keys if provided
      if (requiredKeys != null && requiredKeys.isNotEmpty) {
        _validateRequiredKeys(requiredKeys);
      }

      _initialized = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to initialize EnvironmentConfig: $e');
      }
      rethrow;
    }
  }

  /// Loads and parses .env file
  static Future<void> _loadEnvFile(File envFile) async {
    final lines = await envFile.readAsLines();

    for (var line in lines) {
      line = line.trim();

      // Skip empty lines and comments
      if (line.isEmpty || line.startsWith('#')) continue;

      // Parse KEY=VALUE format
      final separatorIndex = line.indexOf('=');
      if (separatorIndex == -1) continue;

      final key = line.substring(0, separatorIndex).trim();
      final value = line.substring(separatorIndex + 1).trim();

      // Remove quotes if present
      var cleanValue = value;
      if ((cleanValue.startsWith('"') && cleanValue.endsWith('"')) ||
          (cleanValue.startsWith("'") && cleanValue.endsWith("'"))) {
        cleanValue = cleanValue.substring(1, cleanValue.length - 1);
      }

      _config[key] = cleanValue;
    }
  }

  /// Validates that required keys are present and non-empty
  static void _validateRequiredKeys(List<String> required) {
    final missing = <String>[];

    for (final key in required) {
      final value = get(key, fallback: null);
      if (value == null || value.isEmpty) {
        missing.add(key);
      }
    }

    if (missing.isNotEmpty) {
      throw ConfigurationException(
        'Required environment variables missing or empty: ${missing.join(", ")}\n'
        'Check your .env file or environment configuration.',
      );
    }
  }

  /// Gets an environment variable value
  ///
  /// Order of precedence:
  /// 1. Runtime .env file (if loaded)
  /// 2. Compile-time environment (--dart-define)
  /// 3. Fallback value (if provided)
  ///
  /// Throws [ConfigurationException] if key not found and no fallback provided
  static String get(String key, {String? fallback}) {
    if (!_initialized && kDebugMode) {
      debugPrint(
        '⚠️ WARNING: EnvironmentConfig.get("$key") called before initialize(). '
        'Call EnvironmentConfig.initialize() in main() first.',
      );
    }

    // 1. Check runtime .env config
    if (_config.containsKey(key) && _config[key]!.isNotEmpty) {
      return _config[key]!;
    }

    // 2. Check compile-time environment
    const compileTime = String.fromEnvironment('');
    if (compileTime.isNotEmpty) {
      final compileValue = String.fromEnvironment(key, defaultValue: '');
      if (compileValue.isNotEmpty) {
        return compileValue;
      }
    }

    // 3. Use fallback
    if (fallback != null) {
      return fallback;
    }

    // 4. Throw if no value found
    throw ConfigurationException(
      'Environment variable "$key" not found and no fallback provided.\n'
      'Add it to your .env file or pass a fallback value.',
    );
  }

  /// Gets an optional environment variable (returns null if not found)
  static String? getOptional(String key) {
    try {
      return get(key);
    } catch (e) {
      return null;
    }
  }

  /// Gets an environment variable as bool
  ///
  /// Accepts: true, false, 1, 0, yes, no (case-insensitive)
  static bool getBool(String key, {bool fallback = false}) {
    try {
      final value = get(key, fallback: fallback.toString()).toLowerCase();
      return value == 'true' || value == '1' || value == 'yes';
    } catch (e) {
      return fallback;
    }
  }

  /// Gets an environment variable as int
  static int getInt(String key, {int? fallback}) {
    try {
      final value = get(key, fallback: fallback?.toString());
      return int.parse(value);
    } catch (e) {
      if (fallback != null) return fallback;
      throw ConfigurationException(
        'Environment variable "$key" is not a valid integer',
      );
    }
  }

  /// Checks if a key exists in configuration
  static bool has(String key) {
    return _config.containsKey(key) ||
        String.fromEnvironment(key, defaultValue: '').isNotEmpty;
  }

  /// Legacy method - kept for backward compatibility
  @Deprecated('Use get() or getOptional() instead')
  static String getApiKey(String keyName, {String? fallback}) {
    return get(keyName, fallback: fallback ?? 'dummy_fallback_key');
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
