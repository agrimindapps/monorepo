import 'package:core/core.dart';

/// Gasometer-specific environment configuration
/// Extends the generic AppEnvironmentConfig with gasometer-specific settings
class GasometerEnvironmentConfig extends AppEnvironmentConfig {
  factory GasometerEnvironmentConfig() => _instance;
  GasometerEnvironmentConfig._internal();
  static final GasometerEnvironmentConfig _instance =
      GasometerEnvironmentConfig._internal();

  @override
  String get appId => 'gasometer';

  @override
  String get firebaseProjectBaseName => 'gasometer-app';

  @override
  String get apiDomain => 'gasometer.com';
  String get weatherApiKey =>
      EnvironmentConfig.get('WEATHER_API_KEY', fallback: 'weather_dummy_key');

  String get googleMapsApiKey =>
      EnvironmentConfig.get('GOOGLE_MAPS_API_KEY', fallback: 'maps_dummy_key');
  String get revenueCatApiKey => EnvironmentConfig.get(
    'REVENUE_CAT_${environment.name.toUpperCase()}_KEY',
    fallback: 'rcat_dev_dummy_key',
  );
  String get monthlyProductId =>
      EnvironmentConfig.getProductId('gasometer_premium_monthly');
  String get yearlyProductId =>
      EnvironmentConfig.getProductId('gasometer_premium_yearly');

  /// Print gasometer-specific configuration for debugging
  void printGasometerConfig() {
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

/// Gasometer-specific box names for local storage
class GasometerBoxes {
  static const String main = 'gasometer_main';
  static const String readings = 'gasometer_readings';
  static const String vehicles = 'gasometer_vehicles';
  static const String statistics = 'gasometer_statistics';
  static const String backups = 'gasometer_backups';
}

/// Gasometer-specific image service configuration
class GasometerImageConfig {
  static const config = ImageServiceConfig(
    maxWidth: 1920,
    maxHeight: 1920,
    imageQuality: 90,
    maxImagesCount: 3,
    defaultFolder: 'gasometers',
    folders: {
      'gasometer': 'gasometers',
      'reading': 'readings',
      'profile': 'profiles',
    },
  );
}
