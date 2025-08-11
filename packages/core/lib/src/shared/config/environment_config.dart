enum Environment { development, staging, production }

/// Configuração centralizada de ambiente para o monorepo
/// Gerencia configurações de Firebase, RevenueCat e outros serviços
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

  // Firebase Configuration
  static String get firebaseProjectId {
    switch (environment) {
      case Environment.development:
        return 'plantis-receituagro-dev';
      case Environment.staging:
        return 'plantis-receituagro-staging';
      case Environment.production:
        return 'plantis-receituagro-prod';
    }
  }

  // RevenueCat Configuration
  static String get revenueCatApiKey {
    switch (environment) {
      case Environment.development:
        return const String.fromEnvironment('REVENUE_CAT_DEV_KEY', defaultValue: 'rc_dev_default');
      case Environment.staging:
        return const String.fromEnvironment('REVENUE_CAT_STAGING_KEY', defaultValue: 'rc_staging_default');
      case Environment.production:
        return const String.fromEnvironment('REVENUE_CAT_PROD_KEY', defaultValue: 'rc_prod_default');
    }
  }

  // Plantis Subscription Products
  static String get plantisMonthlyProduct {
    switch (environment) {
      case Environment.development:
        return 'plantis_premium_monthly_dev';
      case Environment.staging:
        return 'plantis_premium_monthly_staging';
      case Environment.production:
        return 'plantis_premium_monthly';
    }
  }

  static String get plantisYearlyProduct {
    switch (environment) {
      case Environment.development:
        return 'plantis_premium_yearly_dev';
      case Environment.staging:
        return 'plantis_premium_yearly_staging';
      case Environment.production:
        return 'plantis_premium_yearly';
    }
  }

  // ReceitaAgro Subscription Products
  static String get receitaAgroMonthlyProduct {
    switch (environment) {
      case Environment.development:
        return 'receituagro_pro_monthly_dev';
      case Environment.staging:
        return 'receituagro_pro_monthly_staging';
      case Environment.production:
        return 'receituagro_pro_monthly';
    }
  }

  static String get receitaAgroYearlyProduct {
    switch (environment) {
      case Environment.development:
        return 'receituagro_pro_yearly_dev';
      case Environment.staging:
        return 'receituagro_pro_yearly_staging';
      case Environment.production:
        return 'receituagro_pro_yearly';
    }
  }

  // API Keys
  static String get weatherApiKey {
    return const String.fromEnvironment('WEATHER_API_KEY', defaultValue: '');
  }

  static String get googleMapsApiKey {
    return const String.fromEnvironment('GOOGLE_MAPS_API_KEY', defaultValue: '');
  }

  // Debug Configuration
  static bool get isDebugMode {
    return environment == Environment.development;
  }

  static bool get isProductionMode {
    return environment == Environment.production;
  }

  // App Configuration
  static String get apiBaseUrl {
    switch (environment) {
      case Environment.development:
        return 'https://dev-api.plantisreceituagro.com';
      case Environment.staging:
        return 'https://staging-api.plantisreceituagro.com';
      case Environment.production:
        return 'https://api.plantisreceituagro.com';
    }
  }

  // Logging Configuration
  static bool get enableLogging {
    return environment != Environment.production;
  }

  static bool get enableAnalytics {
    return environment == Environment.production || environment == Environment.staging;
  }

  // Storage Configuration (for different environments)
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

  /// Print current configuration for debugging
  static void printConfig() {
    if (isDebugMode) {
      print('=== Environment Configuration ===');
      print('Environment: $environmentName');
      print('Firebase Project: $firebaseProjectId');
      print('API Base URL: $apiBaseUrl');
      print('Enable Logging: $enableLogging');
      print('Enable Analytics: $enableAnalytics');
      print('====================================');
    }
  }
}