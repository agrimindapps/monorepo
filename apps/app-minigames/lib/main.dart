import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui';

import 'package:core/core.dart' hide sharedPreferencesProvider;
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app_page.dart';
import 'core/config/firebase_options.dart';
import 'core/providers/core_providers.dart';
import 'core/services/web_error_capture_service.dart';
import 'features/tetris/presentation/providers/tetris_dependencies.dart'
    as tetris_deps;
import 'features/simon_says/presentation/providers/simon_dependencies.dart'
    as simon_deps;
import 'features/reversi/presentation/providers/reversi_dependencies.dart'
    as reversi_deps;
import 'features/space_invaders/presentation/providers/space_invaders_dependencies.dart'
    as space_invaders_deps;
import 'features/arkanoid/presentation/providers/arkanoid_dependencies.dart'
    as arkanoid_deps;
import 'features/asteroids/presentation/providers/asteroids_dependencies.dart'
    as asteroids_deps;
import 'features/galaga/presentation/providers/galaga_dependencies.dart'
    as galaga_deps;
import 'features/dino_run/presentation/providers/dino_run_dependencies.dart'
    as dino_run_deps;
import 'features/frogger/presentation/providers/frogger_dependencies.dart'
    as frogger_deps;
import 'features/connect_four/presentation/providers/connect_four_dependencies.dart'
    as connect_four_deps;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) DartPluginRegistrant.ensureInitialized();

  usePathUrlStrategy();

  // Initialize Drift using core package (temporarily disabled)
  // final driftResult = await DriftManager.instance.initialize('app_minigames');
  // if (driftResult.isError) {
  //   debugPrint('Drift initialization failed: ${driftResult.error}');
  //   // Continue without local storage - app can still work with memory
  // }

  // Initialize async dependencies for Riverpod providers
  final sharedPrefs = await SharedPreferences.getInstance();

  // Initialize Firebase with error handling
  bool firebaseInitialized = false;
  FirebaseCrashlyticsService? crashlyticsService;
  WebErrorCaptureService? webErrorService;

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

  if (kIsWeb && firebaseInitialized) {
    // Web: Use WebErrorCaptureService for Firestore-based error logging
    webErrorService = await initializeWebErrorCapture();

    runZonedGuarded<Future<void>>(
      () async {
        runApp(
          ProviderScope(
            overrides: [
              // Override SharedPreferences provider with actual instance
              sharedPreferencesProvider.overrideWithValue(sharedPrefs),
              // Override Tetris SharedPreferences provider
              tetris_deps.sharedPreferencesProvider.overrideWithValue(sharedPrefs),
              // Override Simon Says SharedPreferences provider
              simon_deps.simonSharedPreferencesProvider.overrideWithValue(sharedPrefs),
              // Override Reversi SharedPreferences provider
              reversi_deps.reversiSharedPreferencesProvider.overrideWithValue(sharedPrefs),
              // Override Space Invaders SharedPreferences provider
              space_invaders_deps.spaceInvadersSharedPreferencesProvider.overrideWithValue(sharedPrefs),
              // Override Arkanoid SharedPreferences provider
              arkanoid_deps.arkanoidSharedPreferencesProvider.overrideWithValue(sharedPrefs),
              // Override Asteroids SharedPreferences provider
              asteroids_deps.asteroidsSharedPreferencesProvider.overrideWithValue(sharedPrefs),
              // Override Galaga SharedPreferences provider
              galaga_deps.galagaSharedPreferencesProvider.overrideWithValue(sharedPrefs),
              // Override DinoRun SharedPreferences provider
              dino_run_deps.dinoRunSharedPreferencesProvider.overrideWithValue(sharedPrefs),
              // Override Frogger SharedPreferences provider
              frogger_deps.froggerSharedPreferencesProvider.overrideWithValue(sharedPrefs),
              // Override ConnectFour SharedPreferences provider
              connect_four_deps.connect_fourSharedPreferencesProvider.overrideWithValue(sharedPrefs),
            ],
            child: const App(),
          ),
        );
      },
      (error, stackTrace) {
        webErrorService?.captureError(
          error: error,
          stackTrace: stackTrace,
          errorType: ErrorType.exception,
          severity: ErrorSeverity.critical,
        );
      },
    );
  } else if (!kIsWeb &&
      firebaseInitialized &&
      (Platform.isAndroid || Platform.isIOS)) {
    // Mobile: Use Crashlytics
    runZonedGuarded<Future<void>>(
      () async {
        runApp(
          ProviderScope(
            overrides: [
              // Override SharedPreferences provider with actual instance
              sharedPreferencesProvider.overrideWithValue(sharedPrefs),
              // Override Tetris SharedPreferences provider
              tetris_deps.sharedPreferencesProvider.overrideWithValue(sharedPrefs),
              // Override Simon Says SharedPreferences provider
              simon_deps.simonSharedPreferencesProvider.overrideWithValue(sharedPrefs),
              // Override Reversi SharedPreferences provider
              reversi_deps.reversiSharedPreferencesProvider.overrideWithValue(sharedPrefs),
              // Override Space Invaders SharedPreferences provider
              space_invaders_deps.spaceInvadersSharedPreferencesProvider.overrideWithValue(sharedPrefs),
              // Override Arkanoid SharedPreferences provider
              arkanoid_deps.arkanoidSharedPreferencesProvider.overrideWithValue(sharedPrefs),
              // Override Asteroids SharedPreferences provider
              asteroids_deps.asteroidsSharedPreferencesProvider.overrideWithValue(sharedPrefs),
              // Override Galaga SharedPreferences provider
              galaga_deps.galagaSharedPreferencesProvider.overrideWithValue(sharedPrefs),
              // Override DinoRun SharedPreferences provider
              dino_run_deps.dinoRunSharedPreferencesProvider.overrideWithValue(sharedPrefs),
              // Override Frogger SharedPreferences provider
              frogger_deps.froggerSharedPreferencesProvider.overrideWithValue(sharedPrefs),
              // Override ConnectFour SharedPreferences provider
              connect_four_deps.connect_fourSharedPreferencesProvider.overrideWithValue(sharedPrefs),
            ],
            child: const App(),
          ),
        );
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
    runApp(
      ProviderScope(
        overrides: [
          // Override SharedPreferences provider with actual instance
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
          // Override Tetris SharedPreferences provider
          tetris_deps.sharedPreferencesProvider.overrideWithValue(sharedPrefs),
          // Override Simon Says SharedPreferences provider
          simon_deps.simonSharedPreferencesProvider.overrideWithValue(sharedPrefs),
              // Override Reversi SharedPreferences provider
              reversi_deps.reversiSharedPreferencesProvider.overrideWithValue(sharedPrefs),
              // Override Space Invaders SharedPreferences provider
              space_invaders_deps.spaceInvadersSharedPreferencesProvider.overrideWithValue(sharedPrefs),
              // Override Arkanoid SharedPreferences provider
              arkanoid_deps.arkanoidSharedPreferencesProvider.overrideWithValue(sharedPrefs),
              // Override Asteroids SharedPreferences provider
              asteroids_deps.asteroidsSharedPreferencesProvider.overrideWithValue(sharedPrefs),
              // Override Galaga SharedPreferences provider
              galaga_deps.galagaSharedPreferencesProvider.overrideWithValue(sharedPrefs),
              // Override DinoRun SharedPreferences provider
              dino_run_deps.dinoRunSharedPreferencesProvider.overrideWithValue(sharedPrefs),
              // Override Frogger SharedPreferences provider
              frogger_deps.froggerSharedPreferencesProvider.overrideWithValue(sharedPrefs),
              // Override ConnectFour SharedPreferences provider
              connect_four_deps.connect_fourSharedPreferencesProvider.overrideWithValue(sharedPrefs),
        ],
        child: const App(),
      ),
    );
  }
}
