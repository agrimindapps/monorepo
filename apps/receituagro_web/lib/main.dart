import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app.dart';
import 'app-site/const/firebase_const.dart';

import 'services/info_device_service.dart';
import 'services/supabase_service.dart';
import 'themes/manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!GetPlatform.isWeb) DartPluginRegistrant.ensureInitialized();

  InfoDeviceService().setProduction();

  ThemeData currentTheme = ThemeManager().currentTheme;

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await SupabaseService().initializeSupabase();

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: currentTheme,
      home: const App(),
    ),
  );
}
