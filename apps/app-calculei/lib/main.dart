import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui';

import 'package:core/core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app_page.dart';
import 'core/config/firebase_options.dart';
import 'core/di/injection.dart';
import 'features/vacation_calculator/data/datasources/vacation_local_datasource.dart';
import 'features/thirteenth_salary_calculator/data/datasources/thirteenth_salary_local_datasource.dart';
import 'features/overtime_calculator/data/datasources/overtime_local_datasource.dart';
import 'features/net_salary_calculator/data/datasources/net_salary_local_datasource.dart';
import 'features/emergency_reserve_calculator/data/datasources/emergency_reserve_local_datasource.dart';
import 'features/cash_vs_installment_calculator/data/datasources/cash_vs_installment_local_datasource.dart';
import 'features/unemployment_insurance_calculator/data/datasources/unemployment_insurance_local_datasource.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register plugins for non-web platforms
  if (!kIsWeb) {
    DartPluginRegistrant.ensureInitialized();
  }

  // Use path-based URLs for web (no #)
  usePathUrlStrategy();

  // Initialize Hive using core package
  await Hive.initFlutter();

  // Initialize Hive boxes for features
  await VacationLocalDataSourceImpl.initialize();
  await ThirteenthSalaryLocalDataSourceImplExtension.initialize();
  await OvertimeLocalDataSourceImplExtension.initialize();
  await NetSalaryLocalDataSourceImplExtension.initialize();
  await EmergencyReserveLocalDataSourceImplExtension.initialize();
  await CashVsInstallmentLocalDataSourceImplExtension.initialize();
  await UnemploymentInsuranceLocalDataSourceImplExtension.initialize();

  // Initialize DI
  await configureDependencies();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase services from core package
  final crashlyticsService = FirebaseCrashlyticsService();

  // Run app with error handling for mobile platforms
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    runZonedGuarded<Future<void>>(
      () async {
        runApp(const ProviderScope(child: App()));
      },
      (error, stackTrace) {
        crashlyticsService.recordError(
          exception: error,
          stackTrace: stackTrace,
          fatal: true,
        );
      },
    );
  } else {
    runApp(const ProviderScope(child: App()));
  }
}
