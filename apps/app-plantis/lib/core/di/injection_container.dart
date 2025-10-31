import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../features/auth/domain/usecases/reset_password_usecase.dart';
import '../../features/data_export/data/datasources/local/export_file_generator.dart';
import '../../features/data_export/data/datasources/local/plants_export_datasource.dart';
import '../../features/data_export/data/datasources/local/settings_export_datasource.dart';
import '../../features/data_export/data/repositories/data_export_repository_impl.dart';
import '../../features/data_export/domain/repositories/data_export_repository.dart';
import '../../features/data_export/domain/usecases/check_export_availability_usecase.dart';
import '../../features/data_export/domain/usecases/delete_export_usecase.dart';
import '../../features/data_export/domain/usecases/download_export_usecase.dart';
import '../../features/data_export/domain/usecases/get_export_history_usecase.dart';
import '../../features/data_export/domain/usecases/request_export_usecase.dart';
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
import '../../features/plants/domain/repositories/plant_comments_repository.dart';
import '../../features/plants/domain/repositories/plants_repository.dart';
import '../../features/plants/domain/repositories/spaces_repository.dart';
import '../../features/settings/data/datasources/settings_local_datasource.dart';
import '../../features/settings/data/repositories/settings_repository.dart';
import '../../features/settings/domain/repositories/i_settings_repository.dart';
// Settings providers moved to Riverpod notifiers
// See: settings_notifier.dart and notifications_settings_notifier.dart
import '../../features/tasks/domain/repositories/tasks_repository.dart';
import '../auth/auth_state_notifier.dart';
import '../config/security_config.dart';
import '../constants/app_constants.dart';
import '../data/adapters/network_info_adapter.dart';
import '../data/adapters/plantis_image_service_adapter.dart';
import '../interfaces/network_info.dart';
import '../providers/analytics_provider.dart';
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
import 'injection.dart' as injectable;
import 'modules/account_deletion_module.dart';
import 'modules/plants_module.dart';
import 'modules/spaces_module.dart';
import 'modules/sync_module.dart';
import 'modules/tasks_module.dart';

final sl = GetIt.instance;

Future<void> init({bool firebaseEnabled = false}) async {
  await _initExternal();
  _initCoreServices(firebaseEnabled: firebaseEnabled);
  await injectable.configureDependencies();
  _initAuth();
  _initAccount();
  _initAccountDeletion(); // NEW: Account Deletion Services
  _initDeviceManagement();
  _initPlants();
  _initTasks();
  _initSpaces();
  _initComments();
  _initPremium();
  _initSettings();
  _initDataExport();
  SyncDIModule.init(sl);
  _initAppServices();
}

Future<void> _initExternal() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  // Avoid duplicate registration during hot reload
  // Check if SharedPreferences is already registered in GetIt
  if (!sl.isRegistered<SharedPreferences>()) {
    sl.registerLazySingleton(() => sharedPreferences);
  }
}

void _initCoreServices({bool firebaseEnabled = false}) {
  // Register Firebase services only if Firebase is initialized
  if (firebaseEnabled) {
    try {
      sl.registerLazySingleton(() => FirebaseFirestore.instance);
      sl.registerLazySingleton(() => FirebaseFunctions.instance);
      sl.registerLazySingleton<IAuthRepository>(
        () => PlantisSecurityConfig.createEnhancedAuthService(),
      );
      sl.registerLazySingleton<IAnalyticsRepository>(
        () => FirebaseAnalyticsService(),
      );
      sl.registerLazySingleton<ICrashlyticsRepository>(
        () => FirebaseCrashlyticsService(),
      );
      if (kDebugMode) {
        SecureLogger.info('Firebase services registered in DI');
      }
    } catch (e) {
      SecureLogger.error('Failed to register Firebase services', error: e);
    }
  } else {
    if (kDebugMode) {
      SecureLogger.warning(
        'Firebase services not registered (running in local-only mode)',
      );
    }
  }

  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoAdapter(sl<ConnectivityService>()),
  );
  sl.registerLazySingleton<IPerformanceRepository>(
    () => _StubPerformanceRepository(),
  );
  sl.registerLazySingleton<IBoxRegistryService>(() => BoxRegistryService());
  sl.registerLazySingleton<ILocalStorageRepository>(
    () => HiveStorageService(sl<IBoxRegistryService>()),
  );
  sl.registerLazySingleton<EnhancedSecureStorageService>(
    () => EnhancedSecureStorageService(
      appIdentifier: AppConstants.appId,
      config: const SecureStorageConfig.plantis(),
    ),
  );
  sl.registerLazySingleton<EnhancedEncryptedStorageService>(
    () => EnhancedEncryptedStorageService(
      secureStorage: sl<EnhancedSecureStorageService>(),
      appIdentifier: AppConstants.appId,
    ),
  );
  sl.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService.instance,
  );
  sl.registerLazySingleton<IAppRatingRepository>(
    () => AppRatingService(
      appStoreId: AppConstants.appStoreId,
      googlePlayId: AppConstants.googlePlayId,
      minDays: AppConstants.appRatingMinDays,
      minLaunches: AppConstants.appRatingMinLaunches,
      remindDays: AppConstants.appRatingRemindDays,
      remindLaunches: AppConstants.appRatingRemindLaunches,
    ),
  );
  // RateLimiterService is registered via @injectable in injection.config.dart
  sl.registerLazySingleton(() => PlantisNotificationService());
  sl.registerLazySingleton(() => TaskNotificationService());
  sl.registerLazySingleton(() => NotificationManager());
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
  sl.registerLazySingleton(
    () => PlantisImageServiceAdapterFactory.createForPlantis(),
  );
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
  sl.registerLazySingleton<IFileRepository>(() => FileManagerService());
  sl.registerLazySingleton(() => UrlLauncherService());
  sl.registerLazySingleton<LicenseRepository>(() => LicenseLocalStorage());
  sl.registerLazySingleton<LicenseService>(
    () => LicenseService(sl<LicenseRepository>()),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl(), sl()));
  sl.registerLazySingleton(
    () => LogoutUseCase(sl(), sl(), sl<DataCleanerService>()),
  );
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
}

void _initAuth() {
  sl.registerLazySingleton<AuthStateNotifier>(() => AuthStateNotifier.instance);
}

void _initAccount() {}

void _initAccountDeletion() {
  AccountDeletionModule.init(sl);
}

void _initDeviceManagement() {
  sl.registerLazySingleton<FirebaseDeviceService>(
    () => FirebaseDeviceService(
      functions: sl<FirebaseFunctions>(),
      firestore: sl<FirebaseFirestore>(),
    ),
  );
  sl.registerLazySingleton<DeviceRemoteDataSource>(
    () => DeviceRemoteDataSourceImpl(
      firebaseDeviceService: sl<FirebaseDeviceService>(),
    ),
  );
  sl.registerLazySingleton<DeviceLocalDataSource>(
    () => DeviceLocalDataSourceImpl(
      storageService: sl<ILocalStorageRepository>(),
    ),
  );
  sl.registerLazySingleton<DeviceRepository>(
    () => DeviceRepositoryImpl(
      remoteDataSource: sl<DeviceRemoteDataSource>(),
      localDataSource: sl<DeviceLocalDataSource>(),
    ),
  );
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

void _initComments() {}

void _initPremium() {
  sl.registerLazySingleton<ISubscriptionRepository>(() => RevenueCatService());

  // ✅ MIGRATED: SimpleSubscriptionSyncService foi substituído por
  // AdvancedSubscriptionSyncService (registrado via @injectable no
  // AdvancedSubscriptionModule). Adapter mantém compatibilidade com
  // interface Plantis original.
  //
  // Eliminou: 1,085 linhas de SubscriptionSyncService customizado
  // Ganhou: Multi-source sync, conflict resolution, retry, debounce, cache
  //
  // NOTE: AdvancedSubscriptionModule é registrado automaticamente via
  // build_runner (@module annotation), não precisa chamar manualmente.
  // O arquivo injection.config.dart inclui todos os providers.
}

void _initSettings() {
  // Datasource & Repository (still needed by Riverpod notifiers)
  sl.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSource(prefs: sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<ISettingsRepository>(
    () => SettingsRepository(localDataSource: sl<SettingsLocalDataSource>()),
  );

  // Providers migrated to Riverpod notifiers:
  // - SettingsProvider → settingsNotifierProvider
  // - NotificationsSettingsProvider → notificationsSettingsNotifierProvider
}

void _initAppServices() {
  sl.registerLazySingleton<INavigationService>(() => NavigationService());
  sl.registerLazySingleton<AnalyticsProvider>(
    () => AnalyticsProvider(
      analyticsRepository: sl<IAnalyticsRepository>(),
      crashlyticsRepository: sl<ICrashlyticsRepository>(),
    ),
  );
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
  sl.registerLazySingleton<DataExportRepository>(
    () => DataExportRepositoryImpl(
      plantsDataSource: sl<PlantsExportDataSource>(),
      settingsDataSource: sl<SettingsExportDataSource>(),
      fileGenerator: sl<ExportFileGenerator>(),
      hiveManager: sl<IHiveManager>(),
    ),
  );
  sl.registerLazySingleton<CheckExportAvailabilityUseCase>(
    () => CheckExportAvailabilityUseCase(sl<DataExportRepository>()),
  );

  sl.registerLazySingleton<RequestExportUseCase>(
    () => RequestExportUseCase(sl<DataExportRepository>()),
  );

  sl.registerLazySingleton<GetExportHistoryUseCase>(
    () => GetExportHistoryUseCase(sl<DataExportRepository>()),
  );

  sl.registerLazySingleton<DownloadExportUseCase>(
    () => DownloadExportUseCase(sl<DataExportRepository>()),
  );

  sl.registerLazySingleton<DeleteExportUseCase>(
    () => DeleteExportUseCase(sl<DataExportRepository>()),
  );
}

/// Stub implementation of IPerformanceRepository for development
class _StubPerformanceRepository implements IPerformanceRepository {
  @override
  Future<bool> startPerformanceTracking({PerformanceConfig? config}) async =>
      true;

  @override
  Future<bool> stopPerformanceTracking() async => true;

  @override
  Future<bool> pausePerformanceTracking() async => true;

  @override
  Future<bool> resumePerformanceTracking() async => true;

  @override
  PerformanceMonitoringState getMonitoringState() =>
      PerformanceMonitoringState.running;

  @override
  Future<void> setPerformanceThresholds(
    PerformanceThresholds thresholds,
  ) async {}

  @override
  Stream<double> getFpsStream() => Stream.value(60.0);

  @override
  Future<double> getCurrentFps() async => 60.0;

  @override
  Future<FpsMetrics> getFpsMetrics({Duration? period}) async =>
      const FpsMetrics(
        currentFps: 60.0,
        averageFps: 60.0,
        minFps: 55.0,
        maxFps: 60.0,
        frameDrops: 0,
        jankFrames: 0,
        measurementDuration: Duration(seconds: 1),
      );

  @override
  Future<bool> isFpsHealthy() async => true;

  @override
  Stream<MemoryUsage> getMemoryStream() => Stream.value(
    const MemoryUsage(usedMemory: 0, totalMemory: 100, availableMemory: 100),
  );

  @override
  Future<MemoryUsage> getMemoryUsage() async =>
      const MemoryUsage(usedMemory: 0, totalMemory: 100, availableMemory: 100);

  @override
  Future<bool> isMemoryHealthy() async => true;

  @override
  Future<void> forceGarbageCollection() async {}

  @override
  Future<double> getCpuUsage() async => 0.0;

  @override
  Stream<double> getCpuStream() => Stream.value(0.0);

  @override
  Future<bool> isCpuHealthy() async => true;

  @override
  Future<AppStartupMetrics> getStartupMetrics() async =>
      const AppStartupMetrics(
        coldStartTime: Duration(seconds: 1),
        warmStartTime: Duration(milliseconds: 500),
        timeToInteractive: Duration(seconds: 2),
        firstFrameTime: Duration(milliseconds: 800),
      );

  @override
  Future<void> markAppStarted() async {}

  @override
  Future<void> markFirstFrame() async {}

  @override
  Future<void> markAppInteractive() async {}

  @override
  Future<void> startTrace(
    String traceName, {
    Map<String, String>? attributes,
  }) async {}

  @override
  Future<TraceResult?> stopTrace(
    String traceName, {
    Map<String, double>? metrics,
  }) async => null;

  @override
  Future<Duration> measureOperationTime<T>(
    String operationName,
    Future<T> Function() operation, {
    Map<String, String>? attributes,
  }) async {
    final start = DateTime.now();
    await operation();
    return DateTime.now().difference(start);
  }

  @override
  List<String> getActiveTraces() => [];

  @override
  Future<void> recordCustomMetric({
    required String name,
    required double value,
    required MetricType type,
    String? unit,
    Map<String, String>? tags,
  }) async {}

  @override
  Future<void> incrementCounter(
    String name, {
    Map<String, String>? tags,
  }) async {}

  @override
  Future<void> recordGauge(
    String name,
    double value, {
    Map<String, String>? tags,
  }) async {}

  @override
  Future<void> recordTiming(
    String name,
    Duration duration, {
    Map<String, String>? tags,
  }) async {}

  @override
  Future<PerformanceMetrics> getCurrentMetrics() async => PerformanceMetrics(
    fps: 60.0,
    memoryUsage: const MemoryUsage(
      usedMemory: 0,
      totalMemory: 100,
      availableMemory: 100,
    ),
    cpuUsage: 0.0,
    timestamp: DateTime.now(),
  );

  @override
  Future<List<PerformanceMetrics>> getPerformanceHistory({
    DateTime? since,
    int? limit,
    Duration? period,
  }) async => [];

  @override
  Future<Map<String, dynamic>> getPerformanceReport({
    DateTime? startTime,
    DateTime? endTime,
  }) async => {};

  @override
  Future<String> exportPerformanceData({
    required String format,
    DateTime? startTime,
    DateTime? endTime,
  }) async => '';

  @override
  Stream<Map<String, dynamic>> getPerformanceAlertsStream() => Stream.value({});

  @override
  Future<List<String>> checkPerformanceIssues() async => [];

  @override
  Future<void> setPerformanceAlertCallback(
    void Function(String alertType, Map<String, dynamic> data) callback,
  ) async {}

  @override
  Future<bool> syncWithFirebase() async => true;

  @override
  Future<void> enableFirebaseSync({Duration? interval}) async {}

  @override
  Future<void> disableFirebaseSync() async {}

  @override
  Future<void> clearOldPerformanceData({Duration? olderThan}) async {}

  @override
  Future<Map<String, dynamic>> getDevicePerformanceInfo() async => {};

  @override
  Future<Map<String, bool>> getFeatureSupport() async => {};

  @override
  Future<void> resetAllMetrics() async {}
}
