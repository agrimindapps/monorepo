import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:provider/provider.dart';
import 'package:core/core.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/receituagro_theme.dart';
import 'core/services/receituagro_notification_service.dart';
import 'features/navigation/main_navigation_page.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Configure Crashlytics (only in production/staging)
  if (EnvironmentConfig.enableAnalytics) {
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

  // Initialize notifications
  final notificationService = ReceitaAgroNotificationService();
  await notificationService.initialize();

  // Run app
  if (EnvironmentConfig.enableAnalytics) {
    // Run app in guarded zone for Crashlytics only in production/staging
    runZonedGuarded<Future<void>>(
      () async {
        runApp(const ReceitaAgroApp());
      },
      (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      },
    );
  } else {
    // Run app normally in development
    runApp(const ReceitaAgroApp());
  }
}

class ReceitaAgroApp extends StatelessWidget {
  const ReceitaAgroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider()..initialize(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Pragas Soja',
            theme: ReceitaAgroTheme.lightTheme,
            darkTheme: ReceitaAgroTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const MainNavigationPage(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
