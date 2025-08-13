import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:core/core.dart';

import 'app.dart';
import 'core/services/analytics_service.dart';
import 'core/services/local_data_service.dart';
import 'core/services/gasometer_notification_service.dart';
import 'firebase_options.dart';

// Import Hive adapters
import 'features/vehicles/data/models/vehicle_model.dart';
import 'features/fuel/data/models/fuel_supply_model.dart';
import 'features/odometer/data/models/odometer_model.dart';
import 'features/expenses/data/models/expense_model.dart';
import 'features/maintenance/data/models/maintenance_model.dart';
import 'core/data/models/category_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(VehicleModelAdapter());
  Hive.registerAdapter(FuelSupplyModelAdapter());
  Hive.registerAdapter(OdometerModelAdapter());
  Hive.registerAdapter(ExpenseModelAdapter());
  Hive.registerAdapter(MaintenanceModelAdapter());
  Hive.registerAdapter(CategoryModelAdapter());

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Performance Service (comentado temporariamente)
  // final performanceService = PerformanceService();
  // await performanceService.startPerformanceTracking(
  //   config: const PerformanceConfig(
  //     enableFpsMonitoring: true,
  //     enableMemoryMonitoring: true,
  //     enableCpuMonitoring: false,
  //     enableFirebaseIntegration: true,
  //   ),
  // );
  // await performanceService.markAppStarted();

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

  // Register Hive adapters when available (now registered above)
  // if (!Hive.isAdapterRegistered(0)) {
  //   Hive.registerAdapter(VehicleModelAdapter());
  // }

  // Log app start
  await analyticsService.logAppOpen();

  // Run app with error handling
  if (!kDebugMode) {
    runZonedGuarded<Future<void>>(
      () async {
        // await performanceService.markFirstFrame();
        runApp(const GasOMeterApp());
      },
      (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      },
    );
  } else {
    // await performanceService.markFirstFrame();
    runApp(const GasOMeterApp());
  }
}
