import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'app-site/const/firebase_const.dart';
import 'core/di/injection.dart';
import 'services/info_device_service.dart';
import 'services/supabase_service.dart';
import 'themes/manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // DartPluginRegistrant.ensureInitialized(); // Not supported on web

  InfoDeviceService().setProduction();

  ThemeData currentTheme = ThemeManager().currentTheme;

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Supabase
  await SupabaseService().initializeSupabase();

  // Configure Dependency Injection
  await configureDependencies();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeManager().currentTheme,
      home: const App(),
    );
  }
}
