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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) DartPluginRegistrant.ensureInitialized();

  usePathUrlStrategy();

  // Initialize Hive using core package
  await Hive.initFlutter();

  // Initialize DI
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
