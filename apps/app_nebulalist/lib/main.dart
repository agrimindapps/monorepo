import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'core/di/injection.dart';
import 'core/storage/boxes_setup.dart';
import 'core/config/environment_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Set environment (change for production)
  EnvironmentConfig.setEnvironment(Environment.development);

  // Initialize Hive local storage
  await BoxesSetup.init();

  // Initialize dependency injection
  await configureDependencies();

  // Run app with Riverpod
  runApp(
    const ProviderScope(
      child: AppNebulalistApp(),
    ),
  );
}
