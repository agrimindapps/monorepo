import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';

import '../interfaces/network_info.dart';
import 'modules/domain_module.dart';
import 'modules/plants_module.dart';
import 'modules/spaces_module.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External dependencies
  await _initExternal();
  
  // Core services from package
  _initCoreServices();
  
  // Features
  _initAuth();
  _initPlants();
  _initSpaces();
  _initTasks();
  _initComments();
  _initPremium();
  
  // App services
  _initAppServices();
}

Future<void> _initExternal() async {
  // Shared Preferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  
  // Connectivity
  sl.registerLazySingleton(() => Connectivity());
}

void _initCoreServices() {
  // Firebase
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  
  // Network Info
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  
  // Auth Repository
  sl.registerLazySingleton<IAuthRepository>(() => FirebaseAuthService());
  
  // Analytics Repository
  sl.registerLazySingleton<IAnalyticsRepository>(() => FirebaseAnalyticsService());
  
  // Storage repositories
  sl.registerLazySingleton<ILocalStorageRepository>(() => HiveStorageService());
  
  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl(), sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl(), sl()));
}

void _initAuth() {
  AuthModule.init(sl);
}

void _initPlants() {
  PlantsDIModule.init(sl);
}

void _initSpaces() {
  SpacesDIModule.init(sl);
}

void _initTasks() {
  TasksModule.init(sl);
}

void _initComments() {
  CommentsModule.init(sl);
}

void _initPremium() {
  PremiumModule.init(sl);
}

void _initAppServices() {
  AppServicesModule.init(sl);
}