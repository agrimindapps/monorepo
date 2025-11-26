import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/providers/dependency_providers.dart';
import 'core/config/environment_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific handling
  await _initializeFirebase();

  // Set environment (change for production)
  EnvironmentConfig.setEnvironment(Environment.development);

  // Initialize SharedPreferences for provider override
  final sharedPreferences = await SharedPreferences.getInstance();

  // Run app with Riverpod
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const AppNebulalistApp(),
    ),
  );
}

/// Initialize Firebase with platform-specific configuration
Future<void> _initializeFirebase() async {
  try {
    if (kIsWeb) {
      // For web, Firebase needs to be configured via index.html
      // or we can skip Firebase initialization if not configured
      debugPrint('Running on Web - Firebase initialization skipped');
      debugPrint('Configure Firebase in web/index.html for full functionality');
      // Uncomment below when firebase_options.dart is generated:
      // await Firebase.initializeApp(
      //   options: DefaultFirebaseOptions.currentPlatform,
      // );
    } else {
      // For mobile platforms
      await Firebase.initializeApp();
      debugPrint('Firebase initialized for mobile platform');
    }
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    debugPrint('App will continue without Firebase features');
    // App continues without Firebase - local-first approach
  }
}
