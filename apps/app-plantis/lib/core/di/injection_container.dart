import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';

import '../interfaces/network_info.dart';
import '../services/plantis_notification_service.dart';
import '../services/task_notification_service.dart';
import '../services/image_service.dart';
import '../utils/navigation_service.dart';
import '../providers/analytics_provider.dart';
import 'modules/plants_module.dart';
import 'modules/spaces_module.dart';
import 'modules/tasks_module.dart';
import '../../features/auth/presentation/providers/auth_provider.dart' as providers;
import '../../features/premium/presentation/providers/premium_provider.dart';

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
  
  // Crashlytics Repository
  sl.registerLazySingleton<ICrashlyticsRepository>(() => FirebaseCrashlyticsService());
  
  // Storage repositories
  sl.registerLazySingleton<ILocalStorageRepository>(() => HiveStorageService());
  
  // App Rating Repository
  sl.registerLazySingleton<IAppRatingRepository>(() => AppRatingService(
    appStoreId: '123456789', // TODO: Replace with actual App Store ID
    googlePlayId: 'br.com.agrimsolution.plantis', // TODO: Replace with actual Play Store ID
    minDays: 3,
    minLaunches: 5,
    remindDays: 7,
    remindLaunches: 10,
  ));
  
  // Notification Services
  sl.registerLazySingleton(() => PlantisNotificationService());
  sl.registerLazySingleton(() => TaskNotificationService());
  
  // Image Service
  sl.registerLazySingleton(() => ImageService());
  
  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl(), sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl(), sl()));
}

void _initAuth() {
  // Auth Provider
  sl.registerLazySingleton(() => providers.AuthProvider(
    loginUseCase: sl(),
    logoutUseCase: sl(),
    authRepository: sl(),
    subscriptionRepository: sl<ISubscriptionRepository>(),
  ));
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
  // TODO: Implement comments module
}

void _initPremium() {
  // Repository
  sl.registerLazySingleton<ISubscriptionRepository>(
    () => RevenueCatService(),
  );
  
  // Provider
  sl.registerFactory(
    () => PremiumProvider(
      subscriptionRepository: sl(),
      authRepository: sl(),
    ),
  );
}

void _initAppServices() {
  // Navigation Service
  sl.registerLazySingleton(() => NavigationService.instance);
  
  // Analytics Provider
  sl.registerLazySingleton<AnalyticsProvider>(() => AnalyticsProvider(
    analyticsRepository: sl<IAnalyticsRepository>(),
    crashlyticsRepository: sl<ICrashlyticsRepository>(),
  ));
  
  // Theme Provider
  sl.registerLazySingleton<ThemeProvider>(() => ThemeProvider());
}