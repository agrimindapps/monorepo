import 'package:core/core.dart';

/// Plantis-specific environment configuration
/// Extends the generic AppEnvironmentConfig with plantis-specific settings
class PlantisEnvironmentConfig extends AppEnvironmentConfig {
  static final PlantisEnvironmentConfig _instance =
      PlantisEnvironmentConfig._internal();
  factory PlantisEnvironmentConfig() => _instance;
  PlantisEnvironmentConfig._internal();

  @override
  String get appId => 'plantis';

  @override
  String get firebaseProjectBaseName => 'plantis-receituagro';

  @override
  String get apiDomain => 'plantisreceituagro.com';
  String get weatherApiKey => EnvironmentConfig.getApiKey(
    'WEATHER_API_KEY',
    fallback: 'weather_dummy_key',
  );

  String get googleMapsApiKey => EnvironmentConfig.getApiKey(
    'GOOGLE_MAPS_API_KEY',
    fallback: 'maps_dummy_key',
  );
  String get revenueCatApiKey => EnvironmentConfig.getApiKey(
    'REVENUE_CAT_${environment.name.toUpperCase()}_KEY',
    fallback: 'rcat_dev_dummy_key',
  );
  String get monthlyProductId =>
      EnvironmentConfig.getProductId('plantis_premium_monthly');
  String get yearlyProductId =>
      EnvironmentConfig.getProductId('plantis_premium_yearly');

  /// Print plantis-specific configuration for debugging
  void printPlantisConfig() {
    EnvironmentConfig.printConfig(
      additionalConfig: {
        'App ID': appId,
        'Firebase Project': firebaseProjectId,
        'API Base URL': apiBaseUrl,
        'Monthly Product': monthlyProductId,
        'Yearly Product': yearlyProductId,
      },
    );
  }
}

/// Plantis-specific box names for local storage
class PlantisBoxes {
  static const String main = 'plantis_main';
  static const String plants = 'plants';
  static const String spaces = 'spaces';
  static const String tasks = 'tasks';
  static const String comentarios = 'comentarios';
  static const String reminders = 'plantis_reminders';
  static const String care_logs = 'plantis_care_logs';
  static const String backups = 'plantis_backups';
}

/// Plantis-specific image service configuration
class PlantisImageConfig {
  static const config = ImageServiceConfig(
    maxWidth: 1920,
    maxHeight: 1920,
    imageQuality: 85,
    maxImagesCount: 5,
    defaultFolder: 'plants',
    folders: {
      'plant': 'plants',
      'space': 'spaces',
      'task': 'tasks',
      'profile': 'profiles',
    },
  );
}
