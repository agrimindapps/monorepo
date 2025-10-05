import 'dart:async';
import 'dart:ui';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';

import 'core/di/injection_container.dart' as di;
import 'core/di/modules/sync_module.dart';
import 'core/plantis_sync_config.dart';
import 'core/services/plantis_notification_service.dart';
import 'core/storage/plantis_boxes_setup.dart';
import 'features/development/services/app_data_inspector_initializer.dart';
import 'firebase_options.dart';

// Global references for error handlers
late ICrashlyticsRepository _crashlyticsRepository;
late IPerformanceRepository _performanceRepository;

// Provider local para SharedPreferences do app-plantis
final plantisSharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'SharedPreferences must be overridden at app startup',
  );
});

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Configure sync system for Plantis
  await PlantisSyncConfig.configure();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  // Note: Most models migrated to new architecture and no longer need adapters
  // TypeId 0-4 reserved for legacy models (now removed)

  // Register License Model adapters (from core package)
  Hive.registerAdapter(LicenseModelAdapter()); // TypeId: 10
  Hive.registerAdapter(LicenseTypeAdapter()); // TypeId: 11

  // Initialize app-specific dependency injection (includes core services)
  await di.init();

  // Register Plantis-specific storage boxes
  await PlantisBoxesSetup.registerPlantisBoxes();

  // Initialize DatabaseInspectorService with app-specific boxes
  AppDataInspectorInitializer.initialize();

  // Initialize unified subscription services (NEW - Simplified)
  final simpleSubscriptionSyncService = di.sl<SimpleSubscriptionSyncService>();
  await simpleSubscriptionSyncService.initialize();

  // Initialize notifications
  final notificationService = PlantisNotificationService();
  await notificationService.initialize();

  // Initialize app rating tracking
  final appRatingService = di.sl<IAppRatingRepository>();
  await appRatingService.incrementUsageCount();

  // Initialize sync service with connectivity monitoring
  await SyncDIModule.initializeSyncService(di.sl);

  // Initialize Firebase services (Analytics, Crashlytics, Performance)
  await _initializeFirebaseServices();

  // Initialize SharedPreferences for core providers
  final prefs = await SharedPreferences.getInstance();

  // Run app
  if (EnvironmentConfig.enableAnalytics) {
    // Run app in guarded zone for Crashlytics only in production/staging
    unawaited(
      runZonedGuarded<Future<void>>(
        () async {
          await _performanceRepository.markFirstFrame();
          runApp(
            ProviderScope(
              overrides: [
                // Override common providers with app-specific implementations
                plantisSharedPreferencesProvider.overrideWithValue(prefs),
              ],
              child: const PlantisApp(),
            ),
          );
        },
        (error, stack) {
          _crashlyticsRepository.recordError(
            exception: error,
            stackTrace: stack,
            fatal: true,
          );
        },
      ),
    );
  } else {
    // Run app normally in development
    await _performanceRepository.markFirstFrame();
    runApp(
      ProviderScope(
        overrides: [
          // Override common providers with app-specific implementations
          plantisSharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const PlantisApp(),
      ),
    );
  }
}

/// Initialize Firebase services (Analytics, Crashlytics, Performance)
Future<void> _initializeFirebaseServices() async {
  try {
    debugPrint('🚀 Initializing Firebase services...');

    // Get services from DI
    final analyticsRepository = di.sl<IAnalyticsRepository>();
    _crashlyticsRepository = di.sl<ICrashlyticsRepository>();
    _performanceRepository = di.sl<IPerformanceRepository>();

    // Configure Crashlytics error handlers (only in production/staging)
    if (EnvironmentConfig.enableAnalytics) {
      FlutterError.onError = (errorDetails) {
        _crashlyticsRepository.recordError(
          exception: errorDetails.exception,
          stackTrace: errorDetails.stack ?? StackTrace.empty,
          reason: errorDetails.summary.toString(),
          fatal: true,
        );
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        _crashlyticsRepository.recordError(
          exception: error,
          stackTrace: stack,
          fatal: true,
        );
        return true;
      };
    }

    // Configure initial context for Crashlytics
    await _crashlyticsRepository.setCustomKey(
      key: 'app_name',
      value: 'Plantis',
    );
    await _crashlyticsRepository.setCustomKey(
      key: 'environment',
      value: EnvironmentConfig.enableAnalytics ? 'production' : 'development',
    );

    // Start performance tracking
    await _performanceRepository.startPerformanceTracking(
      config: const PerformanceConfig(
        enableFpsMonitoring: true,
        enableMemoryMonitoring: true,
        enableCpuMonitoring: false,
        enableFirebaseIntegration: true,
      ),
    );
    await _performanceRepository.markAppStarted();

    // Log app initialization
    await analyticsRepository.logEvent(
      'app_initialized',
      parameters: {
        'platform': 'mobile',
        'environment':
            EnvironmentConfig.enableAnalytics ? 'production' : 'development',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );

    await _crashlyticsRepository.log('Plantis app initialized successfully');

    debugPrint('✅ Firebase services initialized successfully');
  } catch (e, stackTrace) {
    debugPrint('❌ Error initializing Firebase services: $e');

    // Try to record error even if services failed
    try {
      await _crashlyticsRepository.recordError(
        exception: e,
        stackTrace: stackTrace,
        reason: 'Firebase services initialization failed',
      );
    } catch (_) {
      // Ignore if Crashlytics also failed
    }
  }
}
