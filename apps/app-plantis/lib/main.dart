import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:core/core.dart';

import 'app.dart';
import 'core/di/injection_container.dart' as di;
import 'core/services/plantis_notification_service.dart';
import 'features/development/services/app_data_inspector_initializer.dart';
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

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize dependency injection
  await di.init();
  
  // Initialize DatabaseInspectorService with app-specific boxes
  AppDataInspectorInitializer.initialize();

  // Initialize RevenueCat after DI
  final revenueCatService = di.sl<ISubscriptionRepository>();
  // O RevenueCat é inicializado automaticamente no construtor do RevenueCatService

  // Initialize notifications
  final notificationService = PlantisNotificationService();
  await notificationService.initialize();

  // Run app
  if (EnvironmentConfig.enableAnalytics) {
    // Run app in guarded zone for Crashlytics only in production/staging
    runZonedGuarded<Future<void>>(
      () async {
        runApp(const PlantisApp());
      },
      (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      },
    );
  } else {
    // Run app normally in development
    runApp(const PlantisApp());
  }
}
