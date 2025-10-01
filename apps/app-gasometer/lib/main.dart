import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/di/injection_container.dart' as di;
import 'core/di/modules/sync_module.dart';
import 'core/gasometer_sync_config.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Configure Crashlytics for Flutter errors
    if (!kIsWeb) {
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }

    // Initialize date formatting for Portuguese/Brazil
    await initializeDateFormatting('pt_BR', null);

    // Initialize dependency injection (includes Hive initialization)
    await di.init();

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