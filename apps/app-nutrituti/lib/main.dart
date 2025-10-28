import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app_page.dart';
import 'const/environment_const.dart';
import 'const/firebase_options.dart';
import 'core/di/injection.dart';
import 'features/water/data/models/water_achievement_model.dart';
import 'features/water/data/models/water_record_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) DartPluginRegistrant.ensureInitialized();

  usePathUrlStrategy();

  // Initialize Environment (AdMob, Supabase, etc)
  AppEnvironment().initialize();

  // Initialize Supabase
  await Supabase.initialize(
    url: AppEnvironment().supabaseUrl,
    anonKey: AppEnvironment().supabaseAnnoKey,
  );

  // Initialize Hive using core package
  await Hive.initFlutter();

  // Register custom adapters for Water feature
  Hive.registerAdapter(WaterRecordModelAdapter());
  Hive.registerAdapter(WaterAchievementModelAdapter());
  Hive.registerAdapter(AchievementTypeAdapterAdapter());

  // Initialize DI (this will open Hive boxes)
  await configureDependencies();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase services from core package
  final crashlyticsService = FirebaseCrashlyticsService();

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    runZonedGuarded<Future<void>>(() async {
      runApp(const ProviderScope(child: App()));
    }, (error, stackTrace) {
      crashlyticsService.recordError(
        exception: error,
        stackTrace: stackTrace,
        fatal: true,
      );
    });
  } else {
    runApp(const ProviderScope(child: App()));
  }
}
