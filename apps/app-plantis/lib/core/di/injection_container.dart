import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:core/core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/presentation/providers/auth_provider.dart' as providers;
import '../../features/auth/presentation/providers/register_provider.dart';
import '../../features/premium/presentation/providers/premium_provider.dart';
import '../../features/settings/data/datasources/settings_local_datasource.dart';
import '../../features/settings/data/repositories/settings_repository.dart';
import '../../features/settings/domain/repositories/i_settings_repository.dart';
import '../../features/settings/presentation/providers/backup_settings_provider.dart';
import '../../features/settings/presentation/providers/notifications_settings_provider.dart';
import '../../features/settings/presentation/providers/settings_provider.dart';
import '../auth/auth_state_notifier.dart';
import '../data/repositories/backup_repository.dart';
import '../interfaces/network_info.dart';
import '../providers/analytics_provider.dart';
import '../providers/sync_status_provider.dart';
import '../services/backup_scheduler.dart';
import '../services/backup_service.dart';
import '../services/data_cleaner_service.dart';
import '../services/image_service.dart' as local;
import '../services/notification_manager.dart';
import '../services/plantis_notification_service.dart';
import '../services/secure_storage_service.dart';
import '../services/task_notification_service.dart';
import '../services/test_data_generator_service.dart';
import '../sync/sync_operations.dart';
import '../sync/sync_queue.dart';
import '../utils/navigation_service.dart';
import 'modules/plants_module.dart';
import 'modules/spaces_module.dart';
import 'modules/tasks_module.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External dependencies
  await _initExternal();

  // Core services from package
  _initCoreServices();

  // Features
  _initAuth();
  _initAccount();
  _initPlants();
  _initTasks();
  _initSpaces();
  _initComments();
  _initPremium();
  _initSettings();
  _initBackup();

  // App services
  _initAppServices();
}

Future<void> _initExternal() async {
  // Shared Preferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Connectivity
  sl.registerLazySingleton(() => Connectivity());

  // Network Services (usando ConnectivityService do core)
  sl.registerLazySingleton(() => ConnectivityService.instance);
  sl.registerLazySingleton(() => SyncQueue(sl()));
  sl.registerLazySingleton(() => SyncOperations(sl(), sl()));
}

void _initCoreServices() {
  // Firebase
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);

  // Network Info
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // Auth Repository
  sl.registerLazySingleton<IAuthRepository>(() => FirebaseAuthService());

  // Analytics Repository
  sl.registerLazySingleton<IAnalyticsRepository>(
    () => FirebaseAnalyticsService(),
  );

  // Crashlytics Repository
  sl.registerLazySingleton<ICrashlyticsRepository>(
    () => FirebaseCrashlyticsService(),
  );

  // Storage repositories
  sl.registerLazySingleton<ILocalStorageRepository>(() => HiveStorageService());
  
  // Secure Storage Service
  sl.registerLazySingleton<SecureStorageService>(() => SecureStorageService.instance);

  // App Rating Repository
  sl.registerLazySingleton<IAppRatingRepository>(
    () => AppRatingService(
      appStoreId: '123456789', // TODO: Replace with actual App Store ID
      googlePlayId:
          'br.com.agrimsolution.plantis', // TODO: Replace with actual Play Store ID
      minDays: 3,
      minLaunches: 5,
      remindDays: 7,
      remindLaunches: 10,
    ),
  );

  // Notification Services
  sl.registerLazySingleton(() => PlantisNotificationService());
  sl.registerLazySingleton(() => TaskNotificationService());

  // Notification Manager
  sl.registerLazySingleton(() => NotificationManager());

  // Image Service
  sl.registerLazySingleton(() => local.ImageService());

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl(), sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl(), sl()));
}

void _initAuth() {
  // Auth State Notifier (Singleton)
  sl.registerLazySingleton<AuthStateNotifier>(() => AuthStateNotifier.instance);
  
  // Auth Provider
  sl.registerLazySingleton(
    () => providers.AuthProvider(
      loginUseCase: sl(),
      logoutUseCase: sl(),
      authRepository: sl(),
      subscriptionRepository: sl<ISubscriptionRepository>(),
    ),
  );
  
  // Register Provider  
  sl.registerFactory(() => RegisterProvider());
}

void _initAccount() {
  // Account simplificado - sem DI necessário
}

void _initPlants() {
  PlantsDIModule.init(sl);
}

void _initTasks() {
  TasksModule.init(sl);
}

void _initSpaces() {
  SpacesModule.init(sl);
}

void _initComments() {
  // TODO: Implement comments module
}

void _initPremium() {
  // Repository
  sl.registerLazySingleton<ISubscriptionRepository>(() => RevenueCatService());

  // Provider
  sl.registerFactory(
    () => PremiumProvider(subscriptionRepository: sl(), authRepository: sl()),
  );
}

void _initSettings() {
  // Settings DataSource
  sl.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSource(prefs: sl<SharedPreferences>()),
  );

  // Settings Repository
  sl.registerLazySingleton<ISettingsRepository>(
    () => SettingsRepository(localDataSource: sl<SettingsLocalDataSource>()),
  );

  // Centralized Settings Provider
  sl.registerLazySingleton<SettingsProvider>(
    () => SettingsProvider(
      settingsRepository: sl<ISettingsRepository>(),
      notificationService: sl<PlantisNotificationService>(),
      authRepository: sl<IAuthRepository>(),
      backupService: sl<BackupService>(),
      themeProvider: sl<ThemeProvider>(),
    ),
  );

  // Legacy Notifications Settings Provider (for compatibility during migration)
  sl.registerFactory(
    () => NotificationsSettingsProvider(
      notificationService: sl<PlantisNotificationService>(),
      prefs: sl<SharedPreferences>(),
    ),
  );
}

void _initBackup() {
  // Backup Repository
  sl.registerLazySingleton<IBackupRepository>(
    () => BackupRepository(
      storage: sl<FirebaseStorage>(),
      authRepository: sl<IAuthRepository>(),
    ),
  );

  // Backup Service
  sl.registerSingleton<BackupService>(
    BackupService(
      backupRepository: sl<IBackupRepository>(),
      authRepository: sl<IAuthRepository>(),
      plantsRepository: sl(),
      spacesRepository: sl(),
      tasksRepository: sl(),
      storageService: sl<SecureStorageService>(),
    ),
  );

  // Backup Scheduler
  sl.registerSingleton<BackupScheduler>(
    BackupScheduler(
      backupService: sl<BackupService>(),
      subscriptionRepository: sl<ISubscriptionRepository>(),
      connectivity: sl<Connectivity>(),
    ),
  );

  // Backup Scheduler Manager
  sl.registerSingleton<BackupSchedulerManager>(
    BackupSchedulerManager(sl<BackupScheduler>()),
  );

  // Backup Settings Provider
  sl.registerFactory(
    () => BackupSettingsProvider(
      backupService: sl<BackupService>(),
      subscriptionRepository: sl<ISubscriptionRepository>(),
      connectivity: sl<Connectivity>(),
    ),
  );
}

void _initAppServices() {
  // Navigation Service
  sl.registerLazySingleton(() => NavigationService.instance);

  // Analytics Provider
  sl.registerLazySingleton<AnalyticsProvider>(
    () => AnalyticsProvider(
      analyticsRepository: sl<IAnalyticsRepository>(),
      crashlyticsRepository: sl<ICrashlyticsRepository>(),
    ),
  );

  // Theme Provider
  sl.registerLazySingleton<ThemeProvider>(() => ThemeProvider());

  // Sync Status Provider
  sl.registerLazySingleton<SyncStatusProvider>(
    () => SyncStatusProvider(sl(), sl()),
  );

  // Test Data Generator Service
  sl.registerLazySingleton<TestDataGeneratorService>(
    () => TestDataGeneratorService(addPlantUseCase: sl(), addTaskUseCase: sl()),
  );

  // Data Cleaner Service
  sl.registerLazySingleton<DataCleanerService>(
    () => DataCleanerService(
      plantsRepository: sl(),
      tasksRepository: sl(),
      deletePlantUseCase: sl(),
    ),
  );
}
