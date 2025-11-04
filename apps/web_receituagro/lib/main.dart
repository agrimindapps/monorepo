import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app.dart';
import 'app-site/const/firebase_const.dart';
import 'core/di/injection.dart';
import 'services/info_device_service.dart';
import 'services/supabase_service.dart';
import 'themes/manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // DartPluginRegistrant.ensureInitialized(); // Not supported on web

  // Configura URLs limpas sem # na web
  usePathUrlStrategy();

  InfoDeviceService().setProduction();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Supabase
  await SupabaseService().initializeSupabase();

  // Configure Dependency Injection
  await configureDependencies();

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
