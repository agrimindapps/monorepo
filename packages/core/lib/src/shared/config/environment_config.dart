import 'package:flutter/foundation.dart';

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
        const key = String.fromEnvironment('REVENUE_CAT_DEV_KEY', defaultValue: 'rcat_dev_dummy_key');
        if (key == 'rcat_dev_dummy_key') {
          if (kDebugMode) {
            print('⚠️ WARNING: Using dummy RevenueCat key for development/web');
          }
        }
        return key;
      case Environment.staging:
        const key = String.fromEnvironment('REVENUE_CAT_STAGING_KEY');
        if (key.isEmpty) throw Exception('REVENUE_CAT_STAGING_KEY not configured');
        return key;
      case Environment.production:
        const key = String.fromEnvironment('REVENUE_CAT_PROD_KEY');
        if (key.isEmpty) throw Exception('REVENUE_CAT_PROD_KEY not configured');
        return key;
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

  // GasOMeter Subscription Products
  static String get gasometerMonthlyProduct {
    switch (environment) {
      case Environment.development:
        return 'gasometer_premium_monthly_dev';
      case Environment.staging:
        return 'gasometer_premium_monthly_staging';
      case Environment.production:
        return 'gasometer_premium_monthly';
    }
  }

  static String get gasometerYearlyProduct {
    switch (environment) {
      case Environment.development:
        return 'gasometer_premium_yearly_dev';
      case Environment.staging:
        return 'gasometer_premium_yearly_staging';
      case Environment.production:
        return 'gasometer_premium_yearly';
    }
  }

  // API Keys
  static String get weatherApiKey {
    const key = String.fromEnvironment('WEATHER_API_KEY', defaultValue: 'weather_dummy_key');
    if (key == 'weather_dummy_key') {
      if (kDebugMode) {
        print('⚠️ WARNING: Using dummy weather API key for development/web');
      }
    }
    return key;
  }

  static String get googleMapsApiKey {
    const key = String.fromEnvironment('GOOGLE_MAPS_API_KEY', defaultValue: 'maps_dummy_key');
    if (key == 'maps_dummy_key') {
      if (kDebugMode) {
        print('⚠️ WARNING: Using dummy Google Maps API key for development/web');
      }
    }
    return key;
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
    if (kDebugMode && isDebugMode) {
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