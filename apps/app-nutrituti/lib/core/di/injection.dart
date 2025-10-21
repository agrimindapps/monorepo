import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/water/data/models/water_achievement_model.dart';
import '../../features/water/data/models/water_record_model.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  // Register external dependencies
  final sharedPrefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPrefs);

  getIt.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  getIt.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  getIt.registerSingleton<Logger>(Logger());

  // Register Hive boxes
  final waterRecordsBox = await Hive.openBox<WaterRecordModel>('waterRecords');
  getIt.registerSingleton<Box<WaterRecordModel>>(waterRecordsBox);

  final achievementsBox = await Hive.openBox<WaterAchievementModel>('waterAchievements');
  getIt.registerSingleton<Box<WaterAchievementModel>>(achievementsBox);

  // Initialize generated dependencies
  getIt.init();
}
