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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register plugins for non-web platforms
  if (!kIsWeb) {
    DartPluginRegistrant.ensureInitialized();
  }

  // Use path-based URLs for web (no #)
  usePathUrlStrategy();

  // Initialize Firebase with error handling
  bool firebaseInitialized = false;
  FirebaseCrashlyticsService? crashlyticsService;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;

    // Initialize Firebase services from core package
    crashlyticsService = FirebaseCrashlyticsService();
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    debugPrint(
      'App will continue without Firebase features (local-first mode)',
    );
    // App continues without Firebase - local storage works independently
  }

  // No DI configuration needed - using Riverpod providers

  // Run app with error handling for mobile platforms
  if (!kIsWeb &&
      firebaseInitialized &&
      (Platform.isAndroid || Platform.isIOS)) {
    runZonedGuarded<Future<void>>(
      () async {
        runApp(const ProviderScope(child: App()));
      },
      (error, stackTrace) {
        crashlyticsService?.recordError(
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
