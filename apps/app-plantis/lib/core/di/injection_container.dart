import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:core/core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/domain/usecases/reset_password_usecase.dart';
import '../../features/auth/presentation/providers/auth_provider.dart' as providers;
import '../../features/auth/presentation/providers/register_provider.dart';
import '../../features/device_management/data/datasources/device_local_datasource.dart';
import '../../features/device_management/data/datasources/device_remote_datasource.dart';
import '../../features/device_management/data/repositories/device_repository_impl.dart';
import '../../features/device_management/domain/repositories/device_repository.dart';
import '../../features/device_management/domain/usecases/get_device_statistics_usecase.dart';
import '../../features/device_management/domain/usecases/update_device_activity_usecase.dart';
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
import '../providers/background_sync_provider.dart';
import '../providers/sync_status_provider.dart';
import '../providers/theme_provider.dart';
import '../services/background_sync_service.dart';
import '../services/backup_audit_service.dart';
import '../services/backup_data_transformer_service.dart';
import '../services/backup_restore_service.dart';
import '../services/backup_scheduler.dart';
import '../services/backup_service.dart';
import '../services/backup_validation_service.dart';
import '../services/data_cleaner_service.dart';
import '../services/interfaces/i_notification_permission_manager.dart';
import '../services/interfaces/i_notification_schedule_manager.dart';
import '../services/interfaces/i_plant_notification_manager.dart';
import '../services/interfaces/i_task_notification_manager.dart';
import '../services/notification_manager.dart';
import '../services/plantis_notification_service.dart';
import '../services/secure_storage_service.dart';
import '../services/task_notification_service.dart';
import '../services/test_data_generator_service.dart';
import '../services/url_launcher_service.dart';
import '../utils/navigation_service.dart' as local;
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
  _initDeviceManagement();
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
}

void _initCoreServices() {
  // Firebase
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  sl.registerLazySingleton(() => FirebaseFunctions.instance);

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

  // Box Registry Service (required by HiveStorageService)
  sl.registerLazySingleton<IBoxRegistryService>(() => BoxRegistryService());
  
  // Storage repositories
  sl.registerLazySingleton<ILocalStorageRepository>(() => HiveStorageService(sl<IBoxRegistryService>()));
  
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

  // Notification Manager - registrado com interfaces segregadas
  sl.registerLazySingleton(() => NotificationManager());
  
  // Interfaces segregadas para diferentes responsabilidades (ISP)
  sl.registerLazySingleton<ITaskNotificationManager>(() => sl<NotificationManager>());
  sl.registerLazySingleton<IPlantNotificationManager>(() => sl<NotificationManager>());
  sl.registerLazySingleton<INotificationPermissionManager>(() => sl<NotificationManager>());
  sl.registerLazySingleton<INotificationScheduleManager>(() => sl<NotificationManager>());

  // Image Service (using core package)
  sl.registerLazySingleton(() => ImageService(
    config: const ImageServiceConfig(
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 80,
      maxFileSizeInMB: 5,
      allowedFormats: ['.jpg', '.jpeg', '.png', '.webp'],
      folders: {
        'plants': 'plants',
        'spaces': 'spaces',
        'tasks': 'tasks',
        'profiles': 'profiles',
      },
    ),
  ));

  // URL Launcher Service
  sl.registerLazySingleton(() => UrlLauncherService());
  

  // License System (from core package)
  sl.registerLazySingleton<LicenseRepository>(() => LicenseLocalStorage());
  sl.registerLazySingleton<LicenseService>(() => LicenseService(sl<LicenseRepository>()));

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl(), sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl(), sl(), sl<DataCleanerService>()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
}

void _initAuth() {
  // Auth State Notifier (Singleton)
  sl.registerLazySingleton<AuthStateNotifier>(() => AuthStateNotifier.instance);
  
  // Background Sync Service
  sl.registerLazySingleton<BackgroundSyncService>(() => BackgroundSyncService());

  // Background Sync Provider
  sl.registerLazySingleton<BackgroundSyncProvider>(
    () => BackgroundSyncProvider(sl<BackgroundSyncService>()),
  );

  // Auth Provider - with BackgroundSyncProvider dependency
  sl.registerLazySingleton(
    () => providers.AuthProvider(
      loginUseCase: sl(),
      logoutUseCase: sl(),
      authRepository: sl(),
      resetPasswordUseCase: sl(),
      subscriptionRepository: sl<ISubscriptionRepository>(),
      backgroundSyncProvider: sl<BackgroundSyncProvider>(),
    ),
  );
  
  // Register Provider  
  sl.registerFactory(() => RegisterProvider());
}

void _initAccount() {
  // Account simplificado - sem DI necessário
}

void _initDeviceManagement() {
  // Firebase Device Service do core package
  sl.registerLazySingleton<FirebaseDeviceService>(
    () => FirebaseDeviceService(
      functions: sl<FirebaseFunctions>(),
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  // Remote DataSource - agora usando o Firebase real
  sl.registerLazySingleton<DeviceRemoteDataSource>(
    () => DeviceRemoteDataSourceImpl(
      firebaseDeviceService: sl<FirebaseDeviceService>(),
    ),
  );

  // Local DataSource - usar a implementação do core já registrada
  sl.registerLazySingleton<DeviceLocalDataSource>(
    () => DeviceLocalDataSourceImpl(
      storageService: sl<ILocalStorageRepository>(),
    ),
  );

  // Repository
  sl.registerLazySingleton<DeviceRepository>(
    () => DeviceRepositoryImpl(
      remoteDataSource: sl<DeviceRemoteDataSource>(),
      localDataSource: sl<DeviceLocalDataSource>(),
    ),
  );

  // Use Cases - usar apenas o que está implementado no app + o update activity local
  sl.registerLazySingleton<UpdateDeviceActivityUseCase>(
    () => UpdateDeviceActivityUseCase(sl<DeviceRepository>()),
  );

  sl.registerLazySingleton<GetDeviceStatisticsUseCase>(
    () => GetDeviceStatisticsUseCase(
      sl<DeviceRepository>(),
      sl<AuthStateNotifier>(),
    ),
  );

  // Provider simplificado por enquanto - implementação mínima
  sl.registerLazySingleton(
    () => _DeviceManagementProviderStub(),
  );
}


/// Provider temporário simplificado
class _DeviceManagementProviderStub extends ChangeNotifier {
  List<dynamic> get devices => [];
  bool get isLoading => false;
  String? get errorMessage => null;
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
  // Repository (mantém RevenueCat como implementação base)
  sl.registerLazySingleton<ISubscriptionRepository>(() => RevenueCatService());

  // Unified Subscription Services (NEW - Simplified)
  sl.registerLazySingleton<SimpleSubscriptionSyncService>(
    () => SimpleSubscriptionSyncService(
      subscriptionRepository: sl<ISubscriptionRepository>(),
      localStorage: sl<ILocalStorageRepository>(),
    ),
  );

  // Provider (atualizado para usar SimpleSubscriptionSyncService)
  sl.registerFactory(
    () => PremiumProvider(
      subscriptionRepository: sl(),
      authRepository: sl(),
      simpleSubscriptionSyncService: sl<SimpleSubscriptionSyncService>(), // NEW
    ),
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

  // Centralized Settings Provider (Enhanced Architecture)
  sl.registerLazySingleton<SettingsProvider>(
    () => SettingsProvider(
      settingsRepository: sl<ISettingsRepository>(),
      notificationService: sl<PlantisNotificationService>(),
      backupService: sl<BackupService>(),
      themeProvider: sl<ThemeProvider>(),
    )..initialize(), // Auto-initialize for better UX
  );

  // Notifications Settings Provider
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

  // Backup Services (Refatorados seguindo SOLID)
  sl.registerLazySingleton<BackupValidationService>(
    () => const BackupValidationService(),
  );
  
  sl.registerLazySingleton<BackupDataTransformerService>(
    () => const BackupDataTransformerService(),
  );
  
  sl.registerLazySingleton<BackupAuditService>(
    () => BackupAuditService(storageService: sl<SecureStorageService>()),
  );
  
  sl.registerLazySingleton<BackupRestoreService>(
    () => BackupRestoreService(
      plantsRepository: sl(),
      spacesRepository: sl(),
      tasksRepository: sl(),
      storageService: sl<SecureStorageService>(),
      validationService: sl<BackupValidationService>(),
      transformerService: sl<BackupDataTransformerService>(),
      auditService: sl<BackupAuditService>(),
    ),
  );

  // Backup Service
  sl.registerSingleton<BackupService>(
    BackupService(
      backupRepository: sl<IBackupRepository>(),
      validationService: sl<BackupValidationService>(),
      transformerService: sl<BackupDataTransformerService>(),
      restoreService: sl<BackupRestoreService>(),
      auditService: sl<BackupAuditService>(),
      storageService: sl<SecureStorageService>(),
      plantsRepository: sl(),
      spacesRepository: sl(),
      tasksRepository: sl(),
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
      connectivity: sl<Connectivity>(),
    ),
  );
}

void _initAppServices() {
  // Navigation Service
  sl.registerLazySingleton(() => local.NavigationService.instance);

  // Analytics Provider
  sl.registerLazySingleton<AnalyticsProvider>(
    () => AnalyticsProvider(
      analyticsRepository: sl<IAnalyticsRepository>(),
      crashlyticsRepository: sl<ICrashlyticsRepository>(),
    ),
  );

  // Theme Provider
  sl.registerLazySingleton<ThemeProvider>(() => ThemeProvider());

  // Sync Status Provider (legacy)
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
