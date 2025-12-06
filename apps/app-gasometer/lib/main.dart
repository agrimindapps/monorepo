import 'package:core/core.dart' hide connectivityServiceProvider;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/gasometer_sync_config.dart';
import 'core/providers/dependency_providers.dart';
import 'core/services/connectivity/connectivity_sync_integration.dart';
import 'features/sync/domain/services/auto_sync_service.dart';
import 'firebase_options.dart';

late ICrashlyticsRepository _crashlyticsRepository;
late ConnectivitySyncIntegration _connectivityIntegration;
late AutoSyncService _autoSyncService;
late SharedPreferences _sharedPreferences;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  try {
    _sharedPreferences = await SharedPreferences.getInstance();
    if (kDebugMode) {
      SecureLogger.info('SharedPreferences initialized successfully');
    }
  } catch (e) {
    SecureLogger.warning('SharedPreferences initialization failed: $e');
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

  try {
    await initializeDateFormatting('pt_BR', null);

    // Create ProviderContainer for manual dependency resolution
    // Override SharedPreferences provider with initialized instance
    final container = ProviderContainer(
      overrides: [
        gasometerSharedPreferencesProvider.overrideWithValue(_sharedPreferences),
      ],
    );

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

    // Sync config only if Firebase is available
    // UNIFIED ENVIRONMENT: Single configuration for all environments
    // Web platform uses Firestore directly without local sync
    if (firebaseInitialized) {
      // Initialize Sync Service via Provider
      final syncService = container.read(gasometerSyncServiceProvider);
      
      print('🔥 [MAIN] ANTES de inicializar GasometerSyncConfig');
      SecureLogger.info(
        'Initializing GasometerSyncConfig (unified environment)',
      );
      await GasometerSyncConfig.initialize(syncService);
      print('🔥 [MAIN] DEPOIS de inicializar GasometerSyncConfig');
      SecureLogger.info('GasometerSyncConfig initialized successfully');
      
      // Setup connectivity monitoring for sync
      final connectivityService = container.read(connectivityServiceProvider);
      syncService.startConnectivityMonitoring(
        connectivityService.connectivityStream,
      );
      
    } else {
      SecureLogger.warning(
        'Sync services not initialized - running in local-only mode',
      );
    }

    if (firebaseInitialized) {
      await _initializeFirebaseServices(container);
    } else {
      SecureLogger.warning(
        'Firebase services not initialized - running in local-first mode',
      );
    }

    await _initializeConnectivityMonitoring(container);
    await _initializeAutoSync(container);

    runApp(UncontrolledProviderScope(
      container: container,
      child: const GasOMeterApp(),
    ));
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
    if (kDebugMode) {
      SecureLogger.info('Initializing Firebase services');
    }
    final analyticsRepository = container.read(analyticsRepositoryProvider);
    final performanceRepository = container.read(performanceRepositoryProvider);
    await _crashlyticsRepository.setCustomKey(
      key: 'app_name',
      value: 'GasOMeter',
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

    await _crashlyticsRepository.log('GasOMeter app initialized successfully');

    if (kDebugMode) {
      SecureLogger.info('Firebase services initialized successfully');
    }
  } catch (e, stackTrace) {
    SecureLogger.error('Error initializing Firebase services', error: e);
    try {
      await _crashlyticsRepository.recordError(
        exception: e,
        stackTrace: stackTrace,
        reason: 'Firebase services initialization failed',
      );
    } catch (_) {}
  }
}

/// Initialize connectivity monitoring and sync integration
Future<void> _initializeConnectivityMonitoring(ProviderContainer container) async {
  try {
    if (kDebugMode) {
      SecureLogger.info('Initializing connectivity monitoring');
    }

    final connectivityService = container.read(connectivityServiceProvider);
    final stateManager = container.read(connectivityStateManagerProvider);

    _connectivityIntegration = ConnectivitySyncIntegration(
      connectivityService: connectivityService,
      stateManager: stateManager,
    );

    await _connectivityIntegration.initialize();

    if (kDebugMode) {
      SecureLogger.info('Connectivity monitoring initialized successfully');
    }
  } catch (e, stackTrace) {
    SecureLogger.error('Error initializing connectivity monitoring', error: e);
    // Only try to record error if crashlytics is available
    try {
      await _crashlyticsRepository.recordError(
        exception: e,
        stackTrace: stackTrace,
        reason: 'Connectivity monitoring initialization failed',
      );
    } catch (_) {
      // Fail silently - app can still work without connectivity monitoring
    }
  }
}

/// Initialize auto-sync service for periodic background sync
Future<void> _initializeAutoSync(ProviderContainer container) async {
  try {
    if (kDebugMode) {
      SecureLogger.info('Initializing auto-sync service');
    }

    _autoSyncService = container.read(autoSyncServiceProvider);
    await _autoSyncService.initialize();

    // Auto-sync will be started by app lifecycle observer in GasOMeterApp
    // when app becomes active

    if (kDebugMode) {
      SecureLogger.info('Auto-sync service initialized successfully');
    }
  } catch (e, stackTrace) {
    SecureLogger.error('Error initializing auto-sync service', error: e);
    // Only try to record error if crashlytics is available
    try {
      await _crashlyticsRepository.recordError(
        exception: e,
        stackTrace: stackTrace,
        reason: 'Auto-sync service initialization failed',
      );
    } catch (_) {
      // Fail silently - app can still work without auto-sync
    }
  }
}

/// Get auto-sync service instance for lifecycle management
AutoSyncService get autoSyncService => _autoSyncService;
