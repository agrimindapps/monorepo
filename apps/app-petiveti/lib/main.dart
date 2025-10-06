import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injection_container.dart' as di;
import 'core/di/modules/account_deletion_module.dart';
import 'core/di/modules/sync_module.dart';
import 'firebase_options.dart';
late ICrashlyticsRepository _crashlyticsRepository;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await di.init();
    _crashlyticsRepository = di.getIt<ICrashlyticsRepository>();
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
    try {
      print('🔐 MAIN: Initializing account deletion module...');
      AccountDeletionModule.init(di.getIt);
      print('✅ MAIN: Account deletion module initialized successfully');
    } catch (e) {
      print('❌ MAIN: Account deletion initialization failed: $e');
    }
    try {
      print('🔄 MAIN: Forcing Petiveti sync initialization...');
      PetivetiSyncDIModule.init();
      await PetivetiSyncDIModule.initializeSyncService();
      print('✅ MAIN: Petiveti sync initialization completed successfully');
    } catch (e) {
      print('❌ MAIN: Sync initialization failed: $e');
    }
    await _initializeFirebaseServices();

    runApp(const ProviderScope(child: PetiVetiApp()));
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
Future<void> _initializeFirebaseServices() async {
  try {
    debugPrint('🚀 Initializing Firebase services...');
    final analyticsRepository = di.getIt<IAnalyticsRepository>();
    final performanceRepository = di.getIt<IPerformanceRepository>();
    await _crashlyticsRepository.setCustomKey(
      key: 'app_name',
      value: 'PetiVeti',
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

    await _crashlyticsRepository.log('PetiVeti app initialized successfully');

    debugPrint('✅ Firebase services initialized successfully');
  } catch (e, stackTrace) {
    debugPrint('❌ Error initializing Firebase services: $e');
    try {
      await _crashlyticsRepository.recordError(
        exception: e,
        stackTrace: stackTrace,
        reason: 'Firebase services initialization failed',
      );
    } catch (_) {
    }
  }
}

