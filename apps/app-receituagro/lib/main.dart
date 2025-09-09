import 'dart:async';

import 'package:core/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/di/injection_container.dart' as di;
import 'core/providers/preferences_provider.dart';
import 'core/services/app_data_manager.dart';
import 'core/services/culturas_data_loader.dart';
import 'core/services/navigation_service.dart';
import 'core/services/receituagro_notification_service.dart';
import 'core/services/receituagro_storage_service_emergency_stub.dart';
import 'core/services/revenuecat_service.dart' as local_rc;
import 'core/services/startup_optimization_service.dart';
// import 'core/setup/receituagro_data_setup.dart'; // temporarily disabled
import 'core/theme/receituagro_theme.dart';
import 'features/navigation/main_navigation_page.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure Flutter bindings are initialized first
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Sign in anonymously if no user is logged in
  // This ensures the app works even without user authentication
  final auth = FirebaseAuth.instance;
  if (auth.currentUser == null) {
    try {
      await auth.signInAnonymously();
    } catch (e) {
      // Log error but don't block app startup
      if (EnvironmentConfig.enableAnalytics) {
        FirebaseCrashlytics.instance.recordError(
          e,
          StackTrace.current,
          reason: 'Failed to sign in anonymously',
          fatal: false,
        );
      }
    }
  }

  // Initialize Performance Service
  final performanceService = PerformanceService();

  // Start performance tracking (only for mobile platforms)
  if (!kIsWeb) {
    await performanceService.startPerformanceTracking(
      config: const PerformanceConfig(
        enableFpsMonitoring: true,
        enableMemoryMonitoring: true,
        enableCpuMonitoring: false,
        enableFirebaseIntegration: true,
      ),
    );
    await performanceService.markAppStarted();
  }

  // Configure Crashlytics (only in production/staging and not on web)
  if (EnvironmentConfig.enableAnalytics && !kIsWeb) {
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    // Pass all uncaught asynchronous errors to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  // Initialize dependency injection
  await di.init();

  // EMERGENCY FIX: ReceitaAgro data initialization temporarily disabled
  try {
    print('🔧 [EMERGENCY] ReceitaAgro data initialization temporarily disabled to prevent Hive conflicts');
    // await ReceitaAgroDataSetup.initialize(); // Temporarily disabled
  } catch (e) {
    // Log error but don't block app startup
    if (EnvironmentConfig.enableAnalytics) {
      await FirebaseCrashlytics.instance.recordError(
        e,
        StackTrace.current,
        reason: 'Failed to initialize ReceitaAgro data (emergency mode)',
        fatal: false,
      );
    }
  }

  // 🚀 PERFORMANCE CRITICAL: Initialize startup optimization
  // This reduces image loading from 1181+ images (143MB) to lazy loading
  final startupOptimizationService = StartupOptimizationService();
  await startupOptimizationService.initializeApp();

  // Initialize storage service - EMERGENCY FIX: Using stub during Core Package repair
  final storageService = di.sl<ReceitaAgroStorageServiceEmergencyStub>();
  await storageService.initialize();

  // Initialize notifications
  final notificationService = di.sl<IReceitaAgroNotificationService>();
  await notificationService.initialize();

  // Initialize RevenueCat
  try {
    await local_rc.RevenueCatService.initialize();
  } catch (e) {
    // Log error but don't block app startup
    if (EnvironmentConfig.enableAnalytics) {
      FirebaseCrashlytics.instance.recordError(
        e,
        StackTrace.current,
        reason: 'Failed to initialize RevenueCat',
        fatal: false,
      );
    }
  }

  // Initialize data system
  final dataManager = di.sl<IAppDataManager>();
  final dataResult = await dataManager.initialize();

  dataResult.fold(
    (error) {
      // Log error but don't block app startup
      if (EnvironmentConfig.enableAnalytics) {
        FirebaseCrashlytics.instance.recordError(
          error,
          StackTrace.current,
          fatal: false,
        );
      }
    },
    (_) {
      // Data initialization successful
    },
  );

  // 🌱 CULTURAS: Loading culturas data using legacy repository system
  print('🌱 [MAIN] Carregando dados de culturas...');
  await CulturasDataLoader.loadCulturasData();
  print('🌱 [MAIN] Dados de culturas carregados com sucesso.');

  // Run app
  if (EnvironmentConfig.enableAnalytics && !kIsWeb) {
    // Run app in guarded zone for Crashlytics only in production/staging
    runZonedGuarded<Future<void>>(
      () async {
        if (!kIsWeb) {
          await performanceService.markFirstFrame();
        }
        runApp(const ReceitaAgroApp());
      },
      (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      },
    );
  } else {
    // Run app normally in development
    if (!kIsWeb) {
      await performanceService.markFirstFrame();
    }
    runApp(const ReceitaAgroApp());
  }
}

class ReceitaAgroApp extends StatelessWidget {
  const ReceitaAgroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..initialize()),
        ChangeNotifierProvider(
          create: (_) => PreferencesProvider()..initialize(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Pragas Soja',
            theme: ReceitaAgroTheme.lightTheme,
            darkTheme: ReceitaAgroTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const MainNavigationPage(),
            navigatorKey: NavigationService.navigatorKey,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
