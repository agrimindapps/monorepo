import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/game_2048/di/game_2048_injection.dart';
import '../../features/memory/di/memory_injection.dart';
import '../../features/soletrando/di/soletrando_injection.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies({bool firebaseEnabled = false}) async {
  // Register external dependencies
  final sharedPrefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPrefs);

  // Register Firebase services only if Firebase is initialized
  if (firebaseEnabled) {
    try {
      getIt.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
      getIt.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
      debugPrint('Firebase services registered in DI');
    } catch (e) {
      debugPrint('Failed to register Firebase services: $e');
    }
  } else {
    debugPrint('Firebase services not registered (running in local-only mode)');
  }

  getIt.registerSingleton<Logger>(Logger());

  // Initialize generated dependencies
  getIt.init();

  // Initialize feature modules
  await initGame2048DI(getIt);
  await initMemoryDI(getIt);
  await initSoletrandoDI(getIt);
}
