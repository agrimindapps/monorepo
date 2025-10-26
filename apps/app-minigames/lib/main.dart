import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui';

import 'package:core/core.dart' hide sharedPreferencesProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_page.dart';
import 'core/config/firebase_options.dart';
import 'core/di/injection.dart';
import 'core/providers/core_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) DartPluginRegistrant.ensureInitialized();

  usePathUrlStrategy();

  // Initialize Hive using core package
  await Hive.initFlutter();

  // Initialize async dependencies for Riverpod providers
  final sharedPrefs = await SharedPreferences.getInstance();

  // Initialize DI (kept for backwards compatibility during migration)
  await configureDependencies();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase services from core package
  final crashlyticsService = FirebaseCrashlyticsService();

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    runZonedGuarded<Future<void>>(() async {
      runApp(
        ProviderScope(
          overrides: [
            // Override SharedPreferences provider with actual instance
            sharedPreferencesProvider.overrideWithValue(sharedPrefs),
          ],
          child: const App(),
        ),
      );
    }, (error, stackTrace) {
      crashlyticsService.recordError(
        exception: error,
        stackTrace: stackTrace,
        fatal: true,
      );
    });
  } else {
    runApp(
      ProviderScope(
        overrides: [
          // Override SharedPreferences provider with actual instance
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
        ],
        child: const App(),
      ),
    );
  }
}
