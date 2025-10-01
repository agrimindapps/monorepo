import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injection_container.dart' as di;
import 'core/di/modules/account_deletion_module.dart';
import 'core/di/modules/sync_module.dart';
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

    // Initialize dependency injection (includes Hive initialization)
    await di.init();

    // ===== ACCOUNT DELETION INITIALIZATION =====
    // Initialize account deletion module after DI is ready
    try {
      print('🔐 MAIN: Initializing account deletion module...');
      AccountDeletionModule.init(di.getIt);
      print('✅ MAIN: Account deletion module initialized successfully');
    } catch (e) {
      print('❌ MAIN: Account deletion initialization failed: $e');
    }

    // ===== SYNC INITIALIZATION =====
    // Force sync initialization after DI is ready
    try {
      print('🔄 MAIN: Forcing AgrihUrbi sync initialization...');
      AgrihUrbiSyncDIModule.init();
      await AgrihUrbiSyncDIModule.initializeSyncService();
      print('✅ MAIN: AgrihUrbi sync initialization completed successfully');
    } catch (e) {
      print('❌ MAIN: Sync initialization failed: $e');
    }

    runApp(const ProviderScope(child: AgriHurbiApp()));
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

