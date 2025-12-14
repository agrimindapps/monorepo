import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/providers/core_services_providers.dart';
import 'core/providers/sync_service_providers.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final sharedPreferences = await SharedPreferences.getInstance();

    // Create ProviderContainer for initialization
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
    );

    final crashlyticsRepository = container.read(crashlyticsRepositoryProvider);

    if (!kIsWeb) {
      FlutterError.onError = (errorDetails) {
        crashlyticsRepository.recordError(
          exception: errorDetails.exception,
          stackTrace: errorDetails.stack ?? StackTrace.empty,
          reason: errorDetails.summary.toString(),
          fatal: true,
        );
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        crashlyticsRepository.recordError(
          exception: error,
          stackTrace: stack,
          fatal: true,
        );
        return true;
      };
    }

    await _initializeFirebaseServices(container);

    // Initialize sync service (non-blocking)
    _initializeSyncService(container);

    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const PetiVetiApp(),
      ),
    );
  } catch (error) {
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
Future<void> _initializeFirebaseServices(ProviderContainer container) async {
  try {
    debugPrint('🚀 Initializing Firebase services...');

    final analyticsRepository = container.read(analyticsRepositoryProvider);
    final performanceRepository = container.read(performanceRepositoryProvider);
    final crashlyticsRepository = container.read(crashlyticsRepositoryProvider);

    await crashlyticsRepository.setCustomKey(
      key: 'app_name',
      value: 'PetiVeti',
    );
    await crashlyticsRepository.setCustomKey(
      key: 'environment',
      value: kDebugMode ? 'debug' : 'production',
    );
    await performanceRepository.startPerformanceTracking();
    await performanceRepository.markAppStarted();
    await analyticsRepository.logEvent(
      'app_initialized',
      parameters: {
        'platform': kIsWeb ? 'web' : 'mobile',
        'environment': kDebugMode ? 'debug' : 'production',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );

    await crashlyticsRepository.log('PetiVeti app initialized successfully');

    debugPrint('✅ Firebase services initialized successfully');
  } catch (e, stackTrace) {
    debugPrint('❌ Error initializing Firebase services: $e');
    try {
      final crashlyticsRepository = container.read(crashlyticsRepositoryProvider);
      await crashlyticsRepository.recordError(
        exception: e,
        stackTrace: stackTrace,
        reason: 'Firebase services initialization failed',
      );
    } catch (_) {}
  }
}

/// Initialize sync service (non-blocking)
/// Called after Firebase is ready, initializes in background
void _initializeSyncService(ProviderContainer container) {
  try {
    debugPrint('🔄 Initializing Sync Service...');
    
    // Initialize sync service asynchronously (non-blocking)
    container
        .read(syncServiceProvider.notifier)
        .initialize(developmentMode: kDebugMode)
        .then((_) {
      debugPrint('✅ Sync Service initialized');
    }).catchError((Object error) {
      debugPrint('❌ Sync Service initialization error: $error');
    });
  } catch (e) {
    debugPrint('❌ Error starting Sync Service initialization: $e');
  }
}
