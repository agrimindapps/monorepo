import 'dart:async';

import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';

import 'core/plantis_sync_config.dart';
import 'core/services/plantis_notification_service.dart';
import 'firebase_options.dart';

// late ICrashlyticsRepository _crashlyticsRepository;
// late IPerformanceRepository _performanceRepository;
// final plantisSharedPreferencesProvider = Provider<SharedPreferences>((ref) {
//   throw UnimplementedError(
//     'SharedPreferences must be overridden at app startup',
//   );
// });

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Performance Monitoring early
  final performance = PerformanceService();
  await performance.markAppStarted();

  // Skip orientation lock on web
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Initialize Firebase with error handling
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
    if (kDebugMode) {
      SecureLogger.info('Firebase initialized successfully');
    }
  } catch (e) {
    SecureLogger.error('Firebase initialization failed', error: e);
    SecureLogger.warning(
      'App will continue without Firebase features (local-first mode)',
    );
  }

  // Initialize SyncQueue before other sync services
  if (kDebugMode) {
    debugPrint('🔧 [MAIN] Inicializando SyncQueue...');
  }
  // SyncQueue initialization moved to providers
  if (kDebugMode) {
    debugPrint('✅ [MAIN] SyncQueue inicializado');
  }

  // Initialize SyncOperations after SyncQueue
  if (kDebugMode) {
    debugPrint('🔧 [MAIN] Inicializando SyncOperations...');
  }
  // SyncOperations initialization moved to providers
  if (kDebugMode) {
    debugPrint('✅ [MAIN] SyncOperations inicializado');
  }

  // Initialize UnifiedSyncManager with Plantis configuration (only if Firebase is available)
  if (firebaseInitialized) {
    await PlantisSyncConfig.configure();

    // Initialize the advanced subscription sync service
    // Subscription sync service initialization moved to providers
  } else {
    SecureLogger.warning(
      'Sync services not initialized - running in local-only mode',
    );
  }

  // Notification service can work without Firebase
  if (!kIsWeb) {
    final notificationService = PlantisNotificationService();
    await notificationService.initialize();
  }

  // App rating service initialization moved to providers

  if (firebaseInitialized) {
    await _initializeFirebaseServices();
  } else {
    SecureLogger.warning(
      'Firebase services not initialized - running in local-first mode',
    );
  }

  // Use the SharedPreferences instance
  final prefs = await SharedPreferences.getInstance();

  if (EnvironmentConfig.enableAnalytics) {
    await runZonedGuarded<Future<void>>(
      () async {
        // await _performanceRepository.markFirstFrame();
        runApp(
          ProviderScope(
            overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
            child: const PlantisApp(),
          ),
        );
      },
      (error, stack) {
        /*
        _crashlyticsRepository.recordError(
          exception: error,
          stackTrace: stack,
          fatal: true,
        );
        */
      },
    );
  } else {
    // await _performanceRepository.markFirstFrame();
    runApp(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const PlantisApp(),
      ),
    );
  }
}

/// Initialize Firebase services (Analytics, Crashlytics, Performance)
Future<void> _initializeFirebaseServices() async {
  try {
    if (kDebugMode) {
      SecureLogger.info('Initializing Firebase services...');
    }
    /*
    // Firebase services initialization moved to providers
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
        'environment': EnvironmentConfig.enableAnalytics
            ? 'production'
            : 'development',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );

    await _crashlyticsRepository.log('Plantis app initialized successfully');

    if (kDebugMode) {
      SecureLogger.info('Firebase services initialized successfully');
    }
    */
  } catch (e, _) {
    SecureLogger.error('Error initializing Firebase services', error: e);
    try {
      /*
      await _crashlyticsRepository.recordError(
        exception: e,
        stackTrace: stackTrace,
        reason: 'Firebase services initialization failed',
      );
      */
    } catch (_) {}
  }
}
