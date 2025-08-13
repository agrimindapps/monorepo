import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'app.dart';
import 'core/services/analytics_service.dart';
import 'core/services/local_data_service.dart';
import 'core/services/gasometer_notification_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Analytics Service
  final analyticsService = AnalyticsService();
  analyticsService.initialize();

  // Initialize Local Data Service
  final localDataService = LocalDataService();
  await localDataService.initialize();

  // Initialize notifications
  final notificationService = GasOMeterNotificationService();
  await notificationService.initialize();

  // Configure Crashlytics and error handling
  if (!kDebugMode) {
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  // Register Hive adapters when available
  // if (!Hive.isAdapterRegistered(0)) {
  //   Hive.registerAdapter(VehicleModelAdapter());
  // }

  // Log app start
  await analyticsService.logAppOpen();

  // Run app with error handling
  if (!kDebugMode) {
    runZonedGuarded<Future<void>>(
      () async {
        runApp(const GasOMeterApp());
      },
      (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      },
    );
  } else {
    runApp(const GasOMeterApp());
  }
}
