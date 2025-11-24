import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'core_providers.g.dart';

/// SharedPreferences provider - Must be overridden in ProviderScope
///
/// This provider is used to access SharedPreferences throughout the app.
/// It must be overridden in main.dart with the actual instance.
///
/// Example:
/// ```dart
/// final sharedPrefs = await SharedPreferences.getInstance();
/// runApp(
///   ProviderScope(
///     overrides: [
///       sharedPreferencesProvider.overrideWithValue(sharedPrefs),
///     ],
///     child: MyApp(),
///   ),
/// );
/// ```
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(SharedPreferencesRef ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope',
  );
}

/// FirebaseFirestore provider
///
/// Provides access to Firestore instance.
/// KeepAlive ensures singleton behavior across app lifecycle.
@Riverpod(keepAlive: true)
FirebaseFirestore firebaseFirestore(FirebaseFirestoreRef ref) {
  return FirebaseFirestore.instance;
}

/// FirebaseAuth provider
///
/// Provides access to Firebase Authentication.
/// KeepAlive ensures singleton behavior across app lifecycle.
@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(FirebaseAuthRef ref) {
  return FirebaseAuth.instance;
}

/// Logger provider
///
/// Provides a singleton Logger instance for app-wide logging.
/// KeepAlive ensures same logger instance used throughout app.
@Riverpod(keepAlive: true)
Logger logger(LoggerRef ref) {
  return Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );
}

/// Random provider
///
/// Provides a Random instance for game logic.
/// KeepAlive ensures consistent random seed during app lifecycle.
@Riverpod(keepAlive: true)
Random random(RandomRef ref) {
  return Random();
}
