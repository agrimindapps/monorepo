import 'package:core/core.dart' hide Column, OfflineData;
import 'package:core/src/domain/repositories/i_local_storage_repository.dart';
import 'package:flutter/foundation.dart';

import '../../database/plantis_database.dart';

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
import '../../features/settings/di/device_management_di.dart';
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
import '../data/adapters/plantis_image_service_adapter.dart';
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
  // IMPORTANT: configureDependencies() MUST be called first
  // It registers all @module dependencies including SharedPreferences from ExternalModule
  // Calling it first prevents duplicate registration errors during hot reload
  await injectable.configureDependencies();

  await _initExternal();
  _initCoreServices(firebaseEnabled: firebaseEnabled);
  _initAuth();
  _initAccount();
  _initAccountDeletion(); // NEW: Account Deletion Services
  await _initDeviceManagement(); // Device Management for Settings
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
  // SharedPreferences is registered automatically via ExternalModule @preResolve
  // The build_runner generated code in injection.config.dart handles this
  // Do NOT register it manually here - it causes duplicate registration errors
}

void _initCoreServices({bool firebaseEnabled = false}) {
  // Register Firebase services only if Firebase is initialized
  if (firebaseEnabled) {
    try {
      // NOTE: FirebaseFirestore and FirebaseFunctions are already registered
      // via @injectable in injection.config.dart by build_runner.
      // Try registering only if not already present to avoid duplicate registration
      if (!sl.isRegistered<FirebaseFirestore>()) {
        sl.registerLazySingleton(() => FirebaseFirestore.instance);
      }
      if (!sl.isRegistered<FirebaseFunctions>()) {
        sl.registerLazySingleton(() => FirebaseFunctions.instance);
      }
      if (!sl.isRegistered<IAuthRepository>()) {
        sl.registerLazySingleton<IAuthRepository>(
          () => PlantisSecurityConfig.createEnhancedAuthService(),
        );
      }
      if (!sl.isRegistered<IAnalyticsRepository>()) {
        sl.registerLazySingleton<IAnalyticsRepository>(
          () => FirebaseAnalyticsService(),
        );
      }
      if (!sl.isRegistered<ICrashlyticsRepository>()) {
        sl.registerLazySingleton<ICrashlyticsRepository>(
          () => FirebaseCrashlyticsService(),
        );
      }
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

  // NetworkInfo is registered via @LazySingleton in network_info.dart
  // Do NOT register manually to avoid duplicate registration
  sl.registerLazySingleton<IPerformanceRepository>(
    () => _StubPerformanceRepository(),
  );
  // ⚠️ REMOVED: Hive services no longer exist
  // sl.registerLazySingleton<IBoxRegistryService>(() => BoxRegistryService());
  // sl.registerLazySingleton<ILocalStorageRepository>(
  //   () => HiveStorageService(sl<IBoxRegistryService>()),
  // );

  // ✅ REGISTER: PlantisDatabase manually (Injectable can't process Drift classes)
  sl.registerLazySingleton<PlantisDatabase>(() => PlantisDatabase.injectable());

  // ✅ ADDED: Drift-based local storage service
  // TODO: Fix PlantisDatabase type recognition issue
  // sl.registerLazySingleton<ILocalStorageRepository>(
  //   () => DriftStorageService(sl<PlantisDatabase>()),
  // );

  // TEMPORARY: Use stub implementation until PlantisDatabase is properly generated
  sl.registerLazySingleton<ILocalStorageRepository>(
    () => _StubLocalStorageRepository(),
  );

  sl.registerLazySingleton<EnhancedSecureStorageService>(
    () => EnhancedSecureStorageService(
      appIdentifier: AppConstants.appId,
      config: const SecureStorageConfig.plantis(),
    ),
  );
  // ⚠️ REMOVED: EnhancedEncryptedStorageService no longer exists
  // sl.registerLazySingleton<EnhancedEncryptedStorageService>(
  //   () => EnhancedEncryptedStorageService(
  //     secureStorage: sl<EnhancedSecureStorageService>(),
  //     appIdentifier: AppConstants.appId,
  //   ),
  // );
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
  // ⚠️ REMOVED: LicenseRepository no longer exists - LicenseService now uses SharedPreferences
  // sl.registerLazySingleton<LicenseRepository>(() => LicenseLocalStorage());
  // LicenseService is now registered via injectable in core package
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

Future<void> _initDeviceManagement() async {
  // Device Management DI é registrado via DeviceManagementDI.registerPhase1
  // que foi chamado antes do @InjectableInit
  await DeviceManagementDI.registerPhase1(sl);
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
  // NOTE: ISubscriptionRepository is already registered via @injectable
  // in injection.config.dart by build_runner. Do NOT register manually here
  // to avoid duplicate registration errors.
  //
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

  // EnhancedAccountDeletionService para delete account seguro
  // Check if not already registered via @injectable to avoid duplicate registration
  if (!sl.isRegistered<EnhancedAccountDeletionService>()) {
    sl.registerLazySingleton<EnhancedAccountDeletionService>(
      () => EnhancedAccountDeletionService(
        authRepository: sl<IAuthRepository>(),
        appDataCleaner: sl<DataCleanerService>(),
      ),
    );
  }
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
      prefs: sl<SharedPreferences>(),
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

/// TEMPORARY: Stub implementation of ILocalStorageRepository
/// Used until PlantisDatabase type recognition issue is resolved
class _StubLocalStorageRepository implements ILocalStorageRepository {
  @override
  Future<Either<Failure, void>> initialize() async => const Right(null);

  @override
  Future<Either<Failure, void>> save<T>({
    required String key,
    required T data,
    String? box,
  }) async => const Right(null);

  @override
  Future<Either<Failure, T?>> get<T>({
    required String key,
    String? box,
  }) async => const Right(null);

  @override
  Future<Either<Failure, void>> remove({
    required String key,
    String? box,
  }) async => const Right(null);

  @override
  Future<Either<Failure, void>> clear({String? box}) async => const Right(null);

  @override
  Future<Either<Failure, bool>> contains({
    required String key,
    String? box,
  }) async => const Right(false);

  @override
  Future<Either<Failure, List<String>>> getKeys({String? box}) async =>
      const Right([]);

  @override
  Future<Either<Failure, List<T>>> getValues<T>({String? box}) async =>
      const Right([]);

  @override
  Future<Either<Failure, int>> length({String? box}) async => const Right(0);

  @override
  Future<Either<Failure, void>> saveList<T>({
    required String key,
    required List<T> data,
    String? box,
  }) async => const Right(null);

  @override
  Future<Either<Failure, List<T>>> getList<T>({
    required String key,
    String? box,
  }) async => const Right([]);

  @override
  Future<Either<Failure, void>> addToList<T>({
    required String key,
    required T item,
    String? box,
  }) async => const Right(null);

  @override
  Future<Either<Failure, void>> removeFromList<T>({
    required String key,
    required T item,
    String? box,
  }) async => const Right(null);

  @override
  Future<Either<Failure, void>> saveWithTTL<T>({
    required String key,
    required T data,
    required Duration ttl,
    String? box,
  }) async => const Right(null);

  @override
  Future<Either<Failure, T?>> getWithTTL<T>({
    required String key,
    String? box,
  }) async => const Right(null);

  @override
  Future<Either<Failure, void>> cleanExpiredData({String? box}) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> saveUserSetting({
    required String key,
    required dynamic value,
  }) async => const Right(null);

  @override
  Future<Either<Failure, T?>> getUserSetting<T>({
    required String key,
    T? defaultValue,
  }) async => Right(defaultValue);

  @override
  Future<Either<Failure, Map<String, dynamic>>> getAllUserSettings() async =>
      const Right({});

  @override
  Future<Either<Failure, void>> saveOfflineData<T>({
    required String key,
    required T data,
    DateTime? lastSync,
  }) async => const Right(null);

  // Note: getOfflineData method omitted due to type conflicts - using stub that throws
  @override
  Future<Either<Failure, OfflineData<T>?>> getOfflineData<T>({
    required String key,
  }) async => const Right(null);

  @override
  Future<Either<Failure, void>> markAsSynced({required String key}) async =>
      const Right(null);

  @override
  Future<Either<Failure, List<String>>> getUnsyncedKeys() async =>
      const Right([]);
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
