import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/data/models/category_model.dart';
import 'core/di/injection_container.dart';
import 'core/services/analytics_service.dart';
import 'core/services/database_inspector_service.dart';
import 'core/services/gasometer_firebase_service.dart';
import 'core/services/gasometer_notification_service.dart';
// import 'core/interfaces/i_sync_service.dart'; // TODO: Replace with UnifiedSync in Phase 2
// import 'core/sync/models/sync_queue_item.dart'; // TODO: Replace with UnifiedSync models in Phase 2
import 'features/expenses/data/models/expense_model.dart';
import 'features/fuel/data/models/fuel_supply_model.dart';
import 'features/maintenance/data/models/maintenance_model.dart';
import 'features/odometer/data/models/odometer_model.dart';
// Import Hive adapters
import 'core/logging/entities/log_entry.dart';
import 'features/vehicles/data/models/vehicle_model.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('🚀 GasOMeter startup initiated...');

  // Initialize Brazilian Portuguese locale for date formatting
  print('🌍 Initializing locale data...');
  await initializeDateFormatting('pt_BR', null);
  print('✅ Locale data initialized successfully');

  // Disable Provider debug check for complex dependency management
  Provider.debugCheckInvalidValueType = null;

  // Initialize Hive
  print('📦 Initializing Hive...');
  await Hive.initFlutter();
  print('✅ Hive initialized successfully');

  // Register Hive adapters
  print('🔧 Registering Hive adapters...');
  Hive.registerAdapter(VehicleModelAdapter());
  Hive.registerAdapter(FuelSupplyModelAdapter());
  Hive.registerAdapter(OdometerModelAdapter());
  Hive.registerAdapter(ExpenseModelAdapter());
  Hive.registerAdapter(MaintenanceModelAdapter());
  Hive.registerAdapter(CategoryModelAdapter());
  // Hive.registerAdapter(SyncQueueItemAdapter()); // TODO: Replace with UnifiedSync models in Phase 2

  // Register LogEntry adapter for logging system
  if (!Hive.isAdapterRegistered(20)) {
    Hive.registerAdapter(LogEntryAdapter());
  }
  print('✅ Hive adapters registered successfully');

  // Initialize Firebase
  print('🔥 Initializing Firebase...');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('✅ Firebase initialized successfully');

  // Configure Firestore settings
  try {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // Reduce Firebase logging in debug mode to prevent console spam
    if (kDebugMode) {
      print(
          '🔧 Firestore configurado para desenvolvimento com logging otimizado');
    }
  } catch (e) {
    print('⚠️ Falha na configuração do Firestore: $e');
  }

  // Initialize Firebase Crashlytics (only in production)
  if (!kDebugMode) {
    try {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      // Wait a bit to ensure Crashlytics is fully initialized
      await Future<void>.delayed(const Duration(milliseconds: 1500));

      // Test Crashlytics availability
      await FirebaseCrashlytics.instance.log('Crashlytics initialization test');
      print('✅ Crashlytics successfully initialized');
    } catch (e) {
      print('⚠️ Crashlytics initialization failed: $e');
    }
  } else {
    print('🔧 Debug mode: Crashlytics disabled');
  }

  // Initialize Dependencies
  print('🔄 Initializing dependency injection...');
  await initializeDependencies();
  print('✅ Dependencies initialized successfully');

  // Initialize Analytics Service
  print('📊 Initializing Analytics...');
  final analyticsService = sl<AnalyticsService>();
  analyticsService.initialize();
  print('✅ Analytics initialized successfully');

  // Initialize Database Inspector
  print('🔍 Initializing Database Inspector...');
  final databaseInspectorService = GasOMeterDatabaseInspectorService.instance;
  databaseInspectorService.initialize();
  print('✅ Database Inspector initialized successfully');

  // Initialize notifications
  print('🔔 Initializing notifications...');
  final notificationService = sl<GasOMeterNotificationService>();
  await notificationService.initialize();
  print('✅ Notifications initialized successfully');

  // Initialize Sync Service - REMOVED: Legacy sync system
  // print('🔄 Initializing Sync Service...');
  // final syncService = sl<ISyncService>();
  // await syncService.initialize();
  // print('✅ Sync Service initialized successfully');
  // TODO: Replace with UnifiedSync initialization in Phase 2

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
  print('📈 Logging app open event...');
  await analyticsService.logAppOpen();
  print('✅ App open event logged successfully');

  // Test Firebase connectivity (only in debug mode) - run async to not block app startup
  if (kDebugMode) {
    print('🔍 Starting Firebase connectivity test (async)...');
    // Run connectivity test without blocking app startup
    GasometerFirebaseService.checkFirebaseConnectivity()
        .then((connectivityResult) {
      print(
          '🔗 Firebase connectivity result: ${connectivityResult['firestore']['status']}');
      if ((connectivityResult['errors'] as List).isNotEmpty) {
        print(
            '⚠️ Firebase connectivity errors: ${connectivityResult['errors']}');
      }
    }).catchError((Object e) {
      print('⚠️ Firebase connectivity test failed: $e');
    });
  }

  // Run app with error handling
  print('🎯 Starting GasOMeter app...');
  if (!kDebugMode) {
    runZonedGuarded<Future<void>>(
      () async {
        // await performanceService.markFirstFrame();
        runApp(const GasOMeterApp());
        print('🎉 GasOMeter app started successfully in production mode');
      },
      (error, stack) {
        print('💥 Fatal error during app startup: $error');
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      },
    );
  } else {
    // await performanceService.markFirstFrame();
    runApp(const GasOMeterApp());
    print('🎉 GasOMeter app started successfully in debug mode');
  }
}
