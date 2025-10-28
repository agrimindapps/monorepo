/// Environment configuration
/// Manages different configurations for dev/staging/production
enum Environment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  EnvironmentConfig._();

  static Environment _current = Environment.development;

  static Environment get current => _current;

  static void setEnvironment(Environment env) {
    _current = env;
  }

  // API Endpoints
  static String get apiBaseUrl {
    switch (_current) {
      case Environment.development:
        return 'https://dev-api.yourapp.com'; // TODO: Update
      case Environment.staging:
        return 'https://staging-api.yourapp.com'; // TODO: Update
      case Environment.production:
        return 'https://api.yourapp.com'; // TODO: Update
    }
  }

  // Firebase Projects
  static String get firebaseProjectId {
    switch (_current) {
      case Environment.development:
        return 'your-app-dev'; // TODO: Update
      case Environment.staging:
        return 'your-app-staging'; // TODO: Update
      case Environment.production:
        return 'your-app-prod'; // TODO: Update
    }
  }

  // Feature Flags by Environment
  static bool get enableDebugLogging {
    return _current == Environment.development;
  }

  static bool get enableAnalytics {
    return _current == Environment.production;
  }

  static bool get enableCrashReporting {
    return _current != Environment.development;
  }

  // Timeout configurations
  static Duration get networkTimeout {
    switch (_current) {
      case Environment.development:
        return const Duration(seconds: 60); // Longer timeout for debugging
      case Environment.staging:
        return const Duration(seconds: 45);
      case Environment.production:
        return const Duration(seconds: 30);
    }
  }

  // Environment display name
  static String get displayName {
    switch (_current) {
      case Environment.development:
        return 'Development';
      case Environment.staging:
        return 'Staging';
      case Environment.production:
        return 'Production';
    }
  }

  // Is production check
  static bool get isProduction => _current == Environment.production;
  static bool get isDevelopment => _current == Environment.development;
  static bool get isStaging => _current == Environment.staging;
}
