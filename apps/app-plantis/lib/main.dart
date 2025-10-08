import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';

import 'core/di/injection_container.dart' as di;
import 'core/di/modules/sync_module.dart';
import 'core/di/solid_di_factory.dart';
import 'core/plantis_sync_config.dart';
import 'core/providers/solid_providers.dart';
import 'core/services/hive_schema_manager.dart';
import 'core/services/plantis_notification_service.dart';
import 'core/storage/plantis_boxes_setup.dart';
import 'features/development/services/app_data_inspector_initializer.dart';
import 'firebase_options.dart';

late ICrashlyticsRepository _crashlyticsRepository;
late IPerformanceRepository _performanceRepository;
final plantisSharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'SharedPreferences must be overridden at app startup',
  );
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  Hive.registerAdapter(LicenseModelAdapter()); // TypeId: 10
  Hive.registerAdapter(LicenseTypeAdapter()); // TypeId: 11

  // Run schema migrations
  await HiveSchemaManager.migrate();

  await di.init();
  SolidDIConfigurator.configure(
    kDebugMode ? DIMode.development : DIMode.production,
  );
  await PlantisBoxesSetup.registerPlantisBoxes();
  await PlantisSyncConfig.configure();
  AppDataInspectorInitializer.initialize();
  final simpleSubscriptionSyncService = di.sl<SimpleSubscriptionSyncService>();
  await simpleSubscriptionSyncService.initialize();
  final notificationService = PlantisNotificationService();
  await notificationService.initialize();
  final appRatingService = di.sl<IAppRatingRepository>();
  await appRatingService.incrementUsageCount();
  await SyncDIModule.initializeSyncService(di.sl);
  await _initializeFirebaseServices();
  final prefs = await SharedPreferences.getInstance();
  if (EnvironmentConfig.enableAnalytics) {
    unawaited(
      runZonedGuarded<Future<void>>(
        () async {
          await _performanceRepository.markFirstFrame();
          runApp(
            ProviderScope(
              overrides: [
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
    await _performanceRepository.markFirstFrame();
    runApp(
      ProviderScope(
        overrides: [plantisSharedPreferencesProvider.overrideWithValue(prefs)],
        child: const PlantisApp(),
      ),
    );
  }
}

/// Initialize Firebase services (Analytics, Crashlytics, Performance)
Future<void> _initializeFirebaseServices() async {
  try {
    debugPrint('🚀 Initializing Firebase services...');
    final analyticsRepository = di.sl<IAnalyticsRepository>();
    _crashlyticsRepository = di.sl<ICrashlyticsRepository>();
    _performanceRepository = di.sl<IPerformanceRepository>();
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
    await _crashlyticsRepository.setCustomKey(
      key: 'app_name',
      value: 'Plantis',
    );
    await _crashlyticsRepository.setCustomKey(
      key: 'environment',
      value: EnvironmentConfig.enableAnalytics ? 'production' : 'development',
    );
    await _performanceRepository.startPerformanceTracking(
      config: const PerformanceConfig(
        enableFpsMonitoring: true,
        enableMemoryMonitoring: true,
        enableCpuMonitoring: false,
        enableFirebaseIntegration: true,
      ),
    );
    await _performanceRepository.markAppStarted();
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
    try {
      await _crashlyticsRepository.recordError(
        exception: e,
        stackTrace: stackTrace,
        reason: 'Firebase services initialization failed',
      );
    } catch (_) {}
  }
}
