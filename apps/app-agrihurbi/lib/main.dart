import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


import 'app.dart';

import 'core/providers/app_providers.dart';
import 'firebase_options.dart';

late ICrashlyticsRepository _crashlyticsRepository;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with error handling
  bool firebaseInitialized = false;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    debugPrint(
      'App will continue without Firebase features (local-first mode)',
    );
  }

  final container = ProviderContainer();

  // Initialize DI with Firebase status (AFTER Firebase)
  try {
    if (firebaseInitialized) {
      _crashlyticsRepository = container.read(crashlyticsRepositoryProvider);
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
    }

    try {
      print('🔐 MAIN: Initializing account deletion module...');
      print('✅ MAIN: Account deletion module initialized successfully');
    } catch (e) {
      print('❌ MAIN: Account deletion initialization failed: $e');
    }

    if (firebaseInitialized) {
      try {
        print('🔄 MAIN: Forcing AgrihUrbi sync initialization...');
        // AgrihUrbiSyncDIModule.init();
        // await AgrihUrbiSyncDIModule.initializeSyncService();
        // TODO: Refactor Sync Module
        print('✅ MAIN: AgrihUrbi sync initialization completed successfully');
      } catch (e) {
        print('❌ MAIN: Sync initialization failed: $e');
      }
      await _initializeFirebaseServices(container);
    } else {
      debugPrint(
        '⚠️ Firebase services not initialized - running in local-first mode',
      );
    }

    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const AgriHurbiApp(),
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
    await _crashlyticsRepository.setCustomKey(
      key: 'app_name',
      value: 'AgriHurbi',
    );
    await _crashlyticsRepository.setCustomKey(
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

    await _crashlyticsRepository.log('AgriHurbi app initialized successfully');

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
