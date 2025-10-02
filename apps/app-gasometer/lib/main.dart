import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/di/injection_container.dart' as di;
import 'core/di/modules/sync_module.dart';
import 'core/gasometer_sync_config.dart';
import 'firebase_options.dart';

// Global reference to crashlytics for error handlers
late ICrashlyticsRepository _crashlyticsRepository;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize date formatting for Portuguese/Brazil
    await initializeDateFormatting('pt_BR', null);

    // Initialize dependency injection (includes Hive initialization)
    await di.init();

    // Get crashlytics repository from DI
    _crashlyticsRepository = di.sl<ICrashlyticsRepository>();

    // Configure Crashlytics for Flutter errors
    if (!kIsWeb) {
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

    // Initialize UnifiedSyncManager with Gasometer configuration
    if (kDebugMode) {
      print('🔄 Initializing GasometerSyncConfig (development mode)...');
      await GasometerSyncConfig.configureDevelopment();
      print('✅ GasometerSyncConfig initialized successfully');
    } else {
      await GasometerSyncConfig.configure();
    }

    // Initialize sync service with connectivity monitoring
    await SyncDIModule.initializeSyncService(di.sl);

    // Initialize Firebase services (Analytics, Crashlytics, Performance)
    await _initializeFirebaseServices();

    runApp(const ProviderScope(child: GasOMeterApp()));
  } catch (error) {
    // Handle initialization errors
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Erro de inicialização',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
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
    final performanceRepository = di.sl<IPerformanceRepository>();

    // Configure initial context for Crashlytics
    await _crashlyticsRepository.setCustomKey(
      key: 'app_name',
      value: 'GasOMeter',
    );
    await _crashlyticsRepository.setCustomKey(
      key: 'environment',
      value: kDebugMode ? 'debug' : 'production',
    );

    // Start performance tracking
    await performanceRepository.startPerformanceTracking();
    await performanceRepository.markAppStarted();

    // Log app initialization
    await analyticsRepository.logEvent(
      'app_initialized',
      parameters: {
        'platform': kIsWeb ? 'web' : 'mobile',
        'environment': kDebugMode ? 'debug' : 'production',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );

    await _crashlyticsRepository.log('GasOMeter app initialized successfully');

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
