import 'package:core/core.dart' hide Column;

/// Receituagro-specific environment configuration
/// Extends the generic AppEnvironmentConfig with receituagro-specific settings
class ReceituagroEnvironmentConfig extends AppEnvironmentConfig {
  static final ReceituagroEnvironmentConfig _instance =
      ReceituagroEnvironmentConfig._internal();
  factory ReceituagroEnvironmentConfig() => _instance;
  ReceituagroEnvironmentConfig._internal();

  /// Flag para usar mock data em analytics (apenas para desenvolvimento)
  /// Em produção, SEMPRE deve ser false
  static const bool DEBUG_ANALYTICS_MOCK_DATA = bool.fromEnvironment(
    'DEBUG_ANALYTICS_MOCK_DATA',
    defaultValue: true, // true apenas em debug, false em produção
  );

  @override
  String get appId => 'receituagro';

  @override
  String get firebaseProjectBaseName => 'plantis-receituagro';

  @override
  String get apiDomain => 'plantisreceituagro.com';

  String get weatherApiKey => EnvironmentConfig.get('WEATHER_API_KEY');

  String get googleMapsApiKey => EnvironmentConfig.get('GOOGLE_MAPS_API_KEY');

  String get revenueCatApiKey => EnvironmentConfig.get(
    'REVENUE_CAT_${environment.name.toUpperCase()}_KEY',
  );
  String get monthlyProductId =>
      EnvironmentConfig.getProductId('receituagro_pro_monthly');
  String get yearlyProductId =>
      EnvironmentConfig.getProductId('receituagro_pro_yearly');

  /// Print receituagro-specific configuration for debugging
  void printReceituagroConfig() {
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

/// Receituagro-specific box names for local storage
class ReceituagroBoxes {
  static const String main = 'receituagro_main';
  static const String diagnostics = 'receituagro_diagnostics';
  static const String crops = 'receituagro_crops';
  static const String defensivos = 'receituagro_defensivos';
  static const String pragas = 'receituagro_pragas';
  static const String knowledge = 'receituagro_knowledge';
  static const String backups = 'receituagro_backups';
}

/// Receituagro-specific image service configuration
class ReceituagroImageConfig {
  static const config = ImageServiceConfig(
    maxWidth: 1920,
    maxHeight: 1920,
    imageQuality: 85,
    maxImagesCount: 10,
    defaultFolder: 'diagnostics',
    folders: {
      'diagnostic': 'diagnostics',
      'defensivo': 'defensivos',
      'praga': 'pragas',
      'profile': 'profiles',
    },
  );
}
