import 'dart:async';
import 'dart:ui';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
// Import Hive adapters - these include the generated adapters from .g.dart files
import 'core/data/models/comentario_model.dart';
import 'core/data/models/espaco_model.dart';
// import 'core/data/models/tarefa_model.dart'; // DEPRECATED: Migrado para TaskModel em inglês
import 'core/data/models/planta_config_model.dart';
import 'core/di/injection_container.dart' as di;
import 'core/plantis_sync_config.dart';
import 'core/services/plantis_notification_service.dart';
import 'core/storage/plantis_boxes_setup.dart';
import 'features/development/services/app_data_inspector_initializer.dart';
import 'firebase_options.dart';

// Provider local para SharedPreferences do app-plantis
final plantisSharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden at app startup');
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

  // Initialize Performance Service
  final performanceService = PerformanceService();
  await performanceService.startPerformanceTracking(
    config: const PerformanceConfig(
      enableFpsMonitoring: true,
      enableMemoryMonitoring: true,
      enableCpuMonitoring: false,
      enableFirebaseIntegration: true,
    ),
  );
  await performanceService.markAppStarted();

  // Configure Crashlytics (only in production/staging)
  if (EnvironmentConfig.enableAnalytics) {
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    // Pass all uncaught asynchronous errors to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  // Configure sync system for Plantis
  await PlantisSyncConfig.configure();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(ComentarioModelAdapter()); // TypeId: 0
  Hive.registerAdapter(EspacoModelAdapter()); // TypeId: 1
  // Hive.registerAdapter(PlantaModelAdapter()); // TypeId: 2 - REMOVIDO: Migrado para PlantModel
  // Hive.registerAdapter(TarefaModelAdapter()); // TypeId: 3 - DEPRECATED: Migrado para TaskModel
  Hive.registerAdapter(PlantaConfigModelAdapter()); // TypeId: 4

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
  final simpleSubscriptionSyncService =
      di.sl<SimpleSubscriptionSyncService>();
  await simpleSubscriptionSyncService.initialize();

  // Initialize notifications
  final notificationService = PlantisNotificationService();
  await notificationService.initialize();

  // Initialize app rating tracking
  final appRatingService = di.sl<IAppRatingRepository>();
  await appRatingService.incrementUsageCount();

  // Initialize SharedPreferences for core providers
  final prefs = await SharedPreferences.getInstance();

  // Run app
  if (EnvironmentConfig.enableAnalytics) {
    // Run app in guarded zone for Crashlytics only in production/staging
    unawaited(
      runZonedGuarded<Future<void>>(
        () async {
          await performanceService.markFirstFrame();
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
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        },
      ),
    );
  } else {
    // Run app normally in development
    await performanceService.markFirstFrame();
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
