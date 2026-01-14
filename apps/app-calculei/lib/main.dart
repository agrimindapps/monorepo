import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app_page.dart';
import 'firebase_options.dart';
import 'core/services/web_error_capture_service.dart';

void main() async {
  // Use path-based URLs for web (no #)
  usePathUrlStrategy();

  // Run app with error handling
  if (kIsWeb) {
    // Web: Use WebErrorCaptureService for Firestore-based error logging
    // IMPORTANT: WidgetsFlutterBinding.ensureInitialized() must be called inside the zone
    // or passed to runZonedGuarded to avoid "Zone mismatch" errors
    runZonedGuarded<Future<void>>(
      () async {
        WidgetsFlutterBinding.ensureInitialized();

        // Initialize Firebase inside the zone
        var firebaseInitialized = false;
        try {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
          firebaseInitialized = true;
          debugPrint('Firebase initialized successfully');
        } catch (e) {
          debugPrint('Firebase initialization failed: $e');
        }

        WebErrorCaptureService? webErrorService;
        if (firebaseInitialized) {
          webErrorService = await initializeWebErrorCapture();
        }

        // Bind the error handler to the service if available
        if (webErrorService != null) {
          FlutterError.onError = (details) {
            webErrorService!.captureError(
              error: details.exception,
              stackTrace: details.stack,
              errorType: ErrorType.exception,
            );
          };
        }

        runApp(const ProviderScope(child: App()));
      },
      (error, stackTrace) {
        // Fallback error logging if service isn't available
        debugPrint('Uncaught error: $error');
      },
    );
  } else {
    // Mobile/Desktop initialization
    WidgetsFlutterBinding.ensureInitialized();

    if (!kIsWeb) {
      DartPluginRegistrant.ensureInitialized();
    }

    // Initialize Firebase
    var firebaseInitialized = false;
    FirebaseCrashlyticsService? crashlyticsService;

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      firebaseInitialized = true;

      if (Platform.isAndroid || Platform.isIOS) {
        crashlyticsService = FirebaseCrashlyticsService();
      }
      debugPrint('Firebase initialized successfully');
    } catch (e) {
      debugPrint('Firebase initialization failed: $e');
    }

    if (firebaseInitialized && (Platform.isAndroid || Platform.isIOS)) {
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
}
