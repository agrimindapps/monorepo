import 'package:cloud_functions/cloud_functions.dart';
import 'package:core/core.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../features/auth/domain/usecases/reset_password_usecase.dart';
import '../../features/auth/presentation/providers/auth_provider.dart'
    as providers;
import '../../features/auth/presentation/providers/register_provider.dart';
import '../../features/data_export/data/datasources/local/export_file_generator.dart';
import '../../features/data_export/data/datasources/local/plants_export_datasource.dart';
import '../../features/data_export/data/datasources/local/settings_export_datasource.dart';
import '../../features/data_export/data/repositories/data_export_repository_impl.dart';
import '../../features/data_export/domain/repositories/data_export_repository.dart';
import '../../features/data_export/domain/usecases/check_export_availability_usecase.dart';
import '../../features/data_export/domain/usecases/get_export_history_usecase.dart';
import '../../features/data_export/domain/usecases/request_export_usecase.dart';
import '../../features/data_export/presentation/providers/data_export_provider.dart';
import '../../features/device_management/data/datasources/device_local_datasource.dart';
import '../../features/device_management/data/datasources/device_remote_datasource.dart';
import '../../features/device_management/data/repositories/device_repository_impl.dart';
import '../../features/device_management/domain/repositories/device_repository.dart';
import '../../features/device_management/domain/usecases/get_device_statistics_usecase.dart';
import '../../features/device_management/domain/usecases/get_user_devices_usecase.dart'
    as local;
import '../../features/device_management/domain/usecases/revoke_device_usecase.dart'
    as local;
import '../../features/device_management/domain/usecases/update_device_activity_usecase.dart';
import '../../features/device_management/domain/usecases/validate_device_usecase.dart'
    as local;
import '../../features/device_management/presentation/providers/device_management_provider.dart';
import '../../features/plants/domain/repositories/plant_comments_repository.dart';
import '../../features/plants/domain/repositories/plants_repository.dart';
import '../../features/plants/domain/repositories/spaces_repository.dart';
import '../../features/premium/presentation/providers/premium_provider.dart';
import '../../features/settings/data/datasources/settings_local_datasource.dart';
import '../../features/settings/data/repositories/settings_repository.dart';
import '../../features/settings/domain/repositories/i_settings_repository.dart';
import '../../features/settings/presentation/providers/backup_settings_provider.dart';
import '../../features/settings/presentation/providers/notifications_settings_provider.dart';
import '../../features/settings/presentation/providers/settings_provider.dart';
import '../../features/tasks/domain/repositories/tasks_repository.dart';
import '../adapters/network_info_adapter.dart';
import '../adapters/plantis_image_service_adapter.dart';
import '../adapters/plantis_storage_adapter.dart';
import '../auth/auth_state_notifier.dart';
import '../config/security_config.dart';
import '../data/repositories/backup_repository.dart';
import '../interfaces/network_info.dart';
import '../providers/analytics_provider.dart';
import '../providers/background_sync_provider.dart';
import '../providers/sync_status_provider.dart';
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
import '../services/url_launcher_service.dart';
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
  _initDataExport();

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

  // Network Info - Migrated to Adapter Pattern for enhanced features
  // BACKWARD COMPATIBILITY: Interface NetworkInfo preservada, zero breaking changes
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoAdapter(sl<ConnectivityService>()),
  );

  // Auth Repository - Enhanced with security features
  sl.registerLazySingleton<IAuthRepository>(
    () => PlantisSecurityConfig.createEnhancedAuthService(),
  );

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
  sl.registerLazySingleton<ILocalStorageRepository>(
    () => HiveStorageService(sl<IBoxRegistryService>()),
  );

  // Enhanced Secure Storage Service with Plantis configuration
  sl.registerLazySingleton<EnhancedSecureStorageService>(
    () => EnhancedSecureStorageService(
      appIdentifier: 'plantis',
      config: const SecureStorageConfig.plantis(),
    ),
  );

  // Enhanced Encrypted Storage Service
  sl.registerLazySingleton<EnhancedEncryptedStorageService>(
    () => EnhancedEncryptedStorageService(
      secureStorage: sl<EnhancedSecureStorageService>(),
      appIdentifier: 'plantis',
    ),
  );

  // Plantis Storage Adapter (backward compatibility)
  sl.registerLazySingleton<PlantisStorageAdapter>(
    () => PlantisStorageAdapter(
      secureStorage: sl<EnhancedSecureStorageService>(),
      encryptedStorage: sl<EnhancedEncryptedStorageService>(),
    ),
  );

  // Legacy SecureStorageService interface (backward compatibility)
  sl.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService.instance,
  );

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

  // Notification Services (using core LocalNotificationService)
  sl.registerLazySingleton(() => PlantisNotificationService());
  sl.registerLazySingleton(() => TaskNotificationService());

  // Notification Manager - registrado com interfaces segregadas
  sl.registerLazySingleton(() => NotificationManager());

  // Interfaces segregadas para diferentes responsabilidades (ISP)
  sl.registerLazySingleton<ITaskNotificationManager>(
    () => sl<NotificationManager>(),
  );
  sl.registerLazySingleton<IPlantNotificationManager>(
    () => sl<NotificationManager>(),
  );
  sl.registerLazySingleton<INotificationPermissionManager>(
    () => sl<NotificationManager>(),
  );
  sl.registerLazySingleton<INotificationScheduleManager>(
    () => sl<NotificationManager>(),
  );

  // Enhanced Image Service (using adapter pattern)
  // Consolidates Core ImageService + ImagePreloaderService functionality
  sl.registerLazySingleton(
    () => PlantisImageServiceAdapterFactory.createForPlantis(),
  );

  // Backward compatibility: Register core ImageService separately if needed
  sl.registerLazySingleton(
    () => ImageService(
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
    ),
  );

  // File Manager Service (Core Package) - Replaces custom platform handlers
  sl.registerLazySingleton<IFileRepository>(() => FileManagerService());

  // URL Launcher Service
  sl.registerLazySingleton(() => UrlLauncherService());

  // License System (from core package)
  sl.registerLazySingleton<LicenseRepository>(() => LicenseLocalStorage());
  sl.registerLazySingleton<LicenseService>(
    () => LicenseService(sl<LicenseRepository>()),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl(), sl()));
  sl.registerLazySingleton(
    () => LogoutUseCase(sl(), sl(), sl<DataCleanerService>()),
  );
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
}

void _initAuth() {
  // Auth State Notifier (Singleton)
  sl.registerLazySingleton<AuthStateNotifier>(() => AuthStateNotifier.instance);

  // Background Sync Service
  sl.registerLazySingleton<BackgroundSyncService>(
    () => BackgroundSyncService(),
  );

  // Background Sync Provider
  sl.registerLazySingleton<BackgroundSyncProvider>(
    () => BackgroundSyncProvider(sl<BackgroundSyncService>()),
  );

  // Auth Provider - with BackgroundSyncProvider and DeviceValidation dependencies
  sl.registerLazySingleton(
    () => providers.AuthProvider(
      loginUseCase: sl(),
      logoutUseCase: sl(),
      authRepository: sl(),
      resetPasswordUseCase: sl(),
      subscriptionRepository: sl<ISubscriptionRepository>(),
      backgroundSyncProvider: sl<BackgroundSyncProvider>(),
      validateDeviceUseCase: sl<local.ValidateDeviceUseCase>(),
      revokeDeviceUseCase: sl<local.RevokeDeviceUseCase>(),
      revokeAllOtherDevicesUseCase: sl<local.RevokeAllOtherDevicesUseCase>(),
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

  // Use Cases locais do app-plantis
  sl.registerLazySingleton<local.GetUserDevicesUseCase>(
    () => local.GetUserDevicesUseCase(
      sl<DeviceRepository>(),
      sl<AuthStateNotifier>(),
    ),
  );

  sl.registerLazySingleton<local.ValidateDeviceUseCase>(
    () => local.ValidateDeviceUseCase(
      sl<DeviceRepository>(),
      sl<AuthStateNotifier>(),
    ),
  );

  sl.registerLazySingleton<local.RevokeDeviceUseCase>(
    () => local.RevokeDeviceUseCase(
      sl<DeviceRepository>(),
      sl<AuthStateNotifier>(),
    ),
  );

  sl.registerLazySingleton<local.RevokeAllOtherDevicesUseCase>(
    () => local.RevokeAllOtherDevicesUseCase(
      sl<DeviceRepository>(),
      sl<AuthStateNotifier>(),
    ),
  );

  sl.registerLazySingleton<GetDeviceStatisticsUseCase>(
    () => GetDeviceStatisticsUseCase(
      sl<DeviceRepository>(),
      sl<AuthStateNotifier>(),
    ),
  );

  sl.registerLazySingleton<UpdateDeviceActivityUseCase>(
    () => UpdateDeviceActivityUseCase(sl<DeviceRepository>()),
  );

  // Provider real ativo
  sl.registerLazySingleton<DeviceManagementProvider>(
    () => DeviceManagementProvider(
      getUserDevicesUseCase: sl<local.GetUserDevicesUseCase>(),
      validateDeviceUseCase: sl<local.ValidateDeviceUseCase>(),
      revokeDeviceUseCase: sl<local.RevokeDeviceUseCase>(),
      revokeAllOtherDevicesUseCase: sl<local.RevokeAllOtherDevicesUseCase>(),
      getDeviceStatisticsUseCase: sl<GetDeviceStatisticsUseCase>(),
      authStateNotifier: sl<AuthStateNotifier>(),
    ),
  );
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
  // Comments functionality is handled in plants module
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
  // Navigation Service - Core Package Implementation
  sl.registerLazySingleton<INavigationService>(() => NavigationService());

  // Analytics Provider
  sl.registerLazySingleton<AnalyticsProvider>(
    () => AnalyticsProvider(
      analyticsRepository: sl<IAnalyticsRepository>(),
      crashlyticsRepository: sl<ICrashlyticsRepository>(),
    ),
  );

  // Theme Provider (using core package implementation)
  sl.registerLazySingleton<ThemeProvider>(() => ThemeProvider()..initialize());

  // Sync Status Provider (legacy)
  sl.registerLazySingleton<SyncStatusProvider>(
    () => SyncStatusProvider(sl(), sl()),
  );

  // Data Cleaner Service
  sl.registerLazySingleton<DataCleanerService>(
    () => DataCleanerService(
      plantsRepository: sl(),
      tasksRepository: sl(),
      spacesRepository: sl(),
      deletePlantUseCase: sl(),
    ),
  );
}

void _initDataExport() {
  // Data Sources - using concrete implementations
  sl.registerLazySingleton<PlantsExportDataSource>(
    () => PlantsExportLocalDataSource(
      plantsRepository: sl<PlantsRepository>(),
      commentsRepository: sl<PlantCommentsRepository>(),
      tasksRepository: sl<TasksRepository>(),
      spacesRepository: sl<SpacesRepository>(),
    ),
  );

  sl.registerLazySingleton<SettingsExportDataSource>(
    () => SettingsExportLocalDataSource(),
  );

  sl.registerLazySingleton<ExportFileGenerator>(
    () => ExportFileGenerator(fileRepository: sl<IFileRepository>()),
  );

  // Repository
  sl.registerLazySingleton<DataExportRepository>(
    () => DataExportRepositoryImpl(
      plantsDataSource: sl<PlantsExportDataSource>(),
      settingsDataSource: sl<SettingsExportDataSource>(),
      fileGenerator: sl<ExportFileGenerator>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton<CheckExportAvailabilityUseCase>(
    () => CheckExportAvailabilityUseCase(sl<DataExportRepository>()),
  );

  sl.registerLazySingleton<RequestExportUseCase>(
    () => RequestExportUseCase(sl<DataExportRepository>()),
  );

  sl.registerLazySingleton<GetExportHistoryUseCase>(
    () => GetExportHistoryUseCase(sl<DataExportRepository>()),
  );

  // Provider
  sl.registerFactory<DataExportProvider>(
    () => DataExportProvider(
      checkAvailabilityUseCase: sl<CheckExportAvailabilityUseCase>(),
      requestExportUseCase: sl<RequestExportUseCase>(),
      getHistoryUseCase: sl<GetExportHistoryUseCase>(),
      repository: sl<DataExportRepository>(),
    ),
  );
}
