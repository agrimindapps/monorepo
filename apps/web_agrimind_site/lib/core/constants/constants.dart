// Application-wide constants

// API Configuration
class ApiConstants {
  static const String baseUrl = 'https://api.agrimind.com.br';
  static const int timeout = 30000; // 30 seconds
}

// App Configuration
class AppConstants {
  static const String appName = 'Agrimind';
  static const String appVersion = '1.0.0';

  // Cache durations
  static const Duration cacheDuration = Duration(hours: 24);
  static const Duration shortCacheDuration = Duration(minutes: 15);
}

// Storage Keys
class StorageKeys {
  static const String userPreferences = 'user_preferences';
  static const String themeMode = 'theme_mode';
  static const String language = 'language';
  static const String cachedCulturas = 'cached_culturas';
  static const String cachedDefensivos = 'cached_defensivos';
  static const String cachedPragas = 'cached_pragas';
  static const String cachedFitossanitarios = 'cached_fitossanitarios';
}

// Route Names
class Routes {
  static const String home = '/';
  static const String culturas = '/culturas';
  static const String culturasDetail = '/culturas/:id';
  static const String defensivos = '/defensivos';
  static const String defensivosDetail = '/defensivos/:id';
  static const String pragas = '/pragas';
  static const String pragasDetail = '/pragas/:id';
  static const String fitossanitarios = '/fitossanitarios';
  static const String fitossanitariosDetail = '/fitossanitarios/:id';
  static const String diagnostico = '/diagnostico';
}
