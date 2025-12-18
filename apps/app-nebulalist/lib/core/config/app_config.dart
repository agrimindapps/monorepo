/// Application configuration
/// Centralizes all app configuration and constants
class AppConfig {
  AppConfig._();

  // App Information
  static const String appName = 'NebulaList';
  static const String appVersion = '1.0.0';
  static const String packageName = 'br.com.agrimind.nebulalist';

  // Firebase Configuration (configure in google-services.json)
  static const String firebaseProjectId = 'nebulalist-project';
  static const String firebaseStorageBucket = 'nebulalist.appspot.com';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String listsCollection = 'lists';
  static const String itemMastersCollection = 'item_masters';
  static const String listItemsCollection = 'list_items';

  // Drift Database Configuration
  static const String databaseName = 'nebulalist_drift.db';
  static const int databaseVersion = 2;

  // Feature Flags
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enablePremiumFeatures = true;
  static const bool enableOfflineMode = true;

  // Sync Configuration
  static const Duration syncInterval = Duration(minutes: 15);
  static const int maxSyncRetries = 3;
  static const Duration syncTimeout = Duration(seconds: 30);

  // Cache Configuration
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 100; // Max items in cache

  // Network Configuration
  static const Duration networkTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;

  // UI Configuration
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration snackbarDuration = Duration(seconds: 3);

  // Validation Rules
  static const int minNameLength = 2;
  static const int maxNameLength = 100;
  static const int minPasswordLength = 8;

  // Environment
  static bool get isProduction => const bool.fromEnvironment('dart.vm.product');
  static bool get isDevelopment => !isProduction;
}
