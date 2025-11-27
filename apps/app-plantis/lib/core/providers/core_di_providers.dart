import 'package:core/core.dart' hide Column;

import '../constants/app_constants.dart';
import '../data/adapters/plantis_image_service_adapter.dart';
import '../services/notification_manager.dart';
import '../services/notification_permission_manager.dart';
import '../services/overdue_task_monitor.dart';
import '../services/plantis_notification_service.dart';
import '../services/secure_storage_service.dart';
import '../services/task_notification_scheduler.dart';
import '../services/task_notification_service.dart';
import '../services/url_launcher_service.dart';
import '../services/data_cleaner_service.dart';
import '../services/interfaces/i_notification_permission_manager.dart';
import '../services/interfaces/i_notification_schedule_manager.dart';
import '../services/interfaces/i_overdue_task_monitor.dart';
import '../services/interfaces/i_permission_manager.dart';
import '../services/interfaces/i_plant_notification_manager.dart';
import '../services/interfaces/i_task_notification_manager.dart';
import '../services/interfaces/i_task_notification_scheduler.dart';
import '../auth/auth_state_notifier.dart';
import 'repository_providers.dart';
import '../../features/plants/presentation/providers/plants_providers.dart';
import '../../features/tasks/presentation/providers/tasks_providers.dart';

part 'core_di_providers.g.dart';

// ============================================================================
// EXTERNAL DEPENDENCIES (Firebase, SharedPreferences, etc.)
// ============================================================================

// Duplicates removed

/// Firebase Storage instance
@riverpod
FirebaseStorage firebaseStorage(Ref ref) {
  return FirebaseStorage.instance;
}

/// Firebase Functions instance
@riverpod
FirebaseFunctions firebaseFunctions(Ref ref) {
  return FirebaseFunctions.instance;
}

/// Firebase Performance Service (No-op implementation for now)
@riverpod
IPerformanceRepository performanceRepository(Ref ref) {
  // TODO: Implement proper performance monitoring when available
  return _StubPerformanceRepository();
}

class _StubPerformanceRepository implements IPerformanceRepository {
  @override
  Future<bool> startPerformanceTracking({PerformanceConfig? config}) async => true;
  
  @override
  Future<bool> stopPerformanceTracking() async => true;
  
  @override
  Future<bool> pausePerformanceTracking() async => true;
  
  @override
  Future<bool> resumePerformanceTracking() async => true;
  
  @override
  PerformanceMonitoringState getMonitoringState() => PerformanceMonitoringState.stopped;
  
  @override
  Future<void> setPerformanceThresholds(PerformanceThresholds thresholds) async {}
  
  @override
  Stream<double> getFpsStream() => Stream.value(60.0);
  
  @override
  Future<double> getCurrentFps() async => 60.0;
  
  @override
  Future<FpsMetrics> getFpsMetrics({Duration? period}) async => const FpsMetrics(
    currentFps: 60,
    averageFps: 60,
    minFps: 60,
    maxFps: 60,
    frameDrops: 0,
    jankFrames: 0,
    measurementDuration: Duration(seconds: 1),
  );
  
  @override
  Future<bool> isFpsHealthy() async => true;
  
  @override
  Stream<MemoryUsage> getMemoryStream() => Stream.value(const MemoryUsage(
    usedMemory: 0,
    totalMemory: 0,
    availableMemory: 0,
  ));
  
  @override
  Future<MemoryUsage> getMemoryUsage() async => const MemoryUsage(
    usedMemory: 0,
    totalMemory: 0,
    availableMemory: 0,
  );
  
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
  Future<AppStartupMetrics> getStartupMetrics() async => const AppStartupMetrics(
    coldStartTime: Duration(seconds: 1),
    warmStartTime: Duration(milliseconds: 500),
    firstFrameTime: Duration(milliseconds: 100),
    timeToInteractive: Duration(milliseconds: 500),
  );
  
  @override
  Future<void> markAppStarted() async {}
  
  @override
  Future<void> markFirstFrame() async {}
  
  @override
  Future<void> markAppInteractive() async {}
  
  @override
  Future<void> startTrace(String traceName, {Map<String, String>? attributes}) async {}
  
  @override
  Future<TraceResult?> stopTrace(String traceName, {Map<String, double>? metrics}) async => null;
  
  @override
  Future<Duration> measureOperationTime<T>(
    String operationName,
    Future<T> Function() operation, {
    Map<String, String>? attributes,
  }) async {
    final stopwatch = Stopwatch()..start();
    await operation();
    stopwatch.stop();
    return stopwatch.elapsed;
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
  Future<void> incrementCounter(String name, {Map<String, String>? tags}) async {}
  
  @override
  Future<void> recordGauge(String name, double value, {Map<String, String>? tags}) async {}
  
  @override
  Future<void> recordTiming(String name, Duration duration, {Map<String, String>? tags}) async {}
  
  @override
  Future<PerformanceMetrics> getCurrentMetrics() async => PerformanceMetrics(
    timestamp: DateTime.now(),
    fps: 60,
    memoryUsage: const MemoryUsage(
      usedMemory: 0,
      totalMemory: 0,
      availableMemory: 0,
    ),
    cpuUsage: 0,
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

/// IAnalyticsRepository provider - Firebase Analytics implementation
@riverpod
IAnalyticsRepository analyticsRepository(Ref ref) {
  return FirebaseAnalyticsService();
}

/// ICrashlyticsRepository provider - Firebase Crashlytics implementation
@riverpod
ICrashlyticsRepository crashlyticsRepository(Ref ref) {
  return FirebaseCrashlyticsService();
}

/// IAppRatingRepository provider
@riverpod
IAppRatingRepository appRatingRepository(Ref ref) {
  return AppRatingService(
    appStoreId: AppConstants.appStoreId,
    googlePlayId: AppConstants.googlePlayId,
    minDays: AppConstants.appRatingMinDays,
    minLaunches: AppConstants.appRatingMinLaunches,
    remindDays: AppConstants.appRatingRemindDays,
    remindLaunches: AppConstants.appRatingRemindLaunches,
  );
}


// localStorageRepository removed (duplicate)


/// IFileRepository provider - File manager service
@riverpod
IFileRepository fileRepository(Ref ref) {
  return FileManagerService();
}

// ============================================================================
// CORE SERVICES
// ============================================================================

/// Enhanced Secure Storage Service
@riverpod
EnhancedSecureStorageService enhancedSecureStorageService(
  Ref ref,
) {
  return EnhancedSecureStorageService(
    appIdentifier: AppConstants.appId,
    config: const SecureStorageConfig.plantis(),
  );
}

/// Secure Storage Service (singleton instance)
@riverpod
SecureStorageService secureStorageService(Ref ref) {
  return SecureStorageService.instance;
}

/// Image Service
@riverpod
ImageService imageService(Ref ref) {
  return ImageService(
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
  );
}

/// Plantis Image Service Adapter
@riverpod
PlantisImageServiceAdapter plantisImageServiceAdapter(
  Ref ref,
) {
  return PlantisImageServiceAdapterFactory.createForPlantis();
}

/// URL Launcher Service
@riverpod
UrlLauncherService urlLauncherService(Ref ref) {
  return UrlLauncherService();
}

/// Data Cleaner Service
@riverpod
DataCleanerService dataCleanerService(Ref ref) {
  final plantsRepository = ref.watch(plantsRepositoryProvider);
  final tasksRepository = ref.watch(tasksRepositoryProvider);
  final spacesRepository = ref.watch(spacesRepositoryProvider);
  final deletePlantUseCase = ref.watch(deletePlantUseCaseProvider);

  return DataCleanerService(
    plantsRepository: plantsRepository,
    tasksRepository: tasksRepository,
    spacesRepository: spacesRepository,
    deletePlantUseCase: deletePlantUseCase,
  );
}

// ============================================================================
// NOTIFICATION SERVICES
// ============================================================================

/// Plantis Notification Service
@riverpod
PlantisNotificationService plantisNotificationService(
  Ref ref,
) {
  return PlantisNotificationService();
}

/// Task Notification Scheduler
@riverpod
ITaskNotificationScheduler taskNotificationScheduler(
  Ref ref,
) {
  final notificationService = ref.watch(plantisNotificationServiceProvider);
  return TaskNotificationScheduler(notificationService);
}

/// Overdue Task Monitor
@riverpod
IOverdueTaskMonitor overdueTaskMonitor(Ref ref) {
  final scheduler = ref.watch(taskNotificationSchedulerProvider);
  return OverdueTaskMonitor(scheduler);
}

/// Permission Manager
@riverpod
IPermissionManager permissionManager(Ref ref) {
  final notificationService = ref.watch(plantisNotificationServiceProvider);
  return NotificationPermissionManager(notificationService);
}

/// Task Notification Service (orchestrator)
@riverpod
TaskNotificationService taskNotificationService(Ref ref) {
  return TaskNotificationService();
}

/// Notification Manager (for backward compatibility)
@riverpod
NotificationManager notificationManager(Ref ref) {
  return NotificationManager();
}

/// ITaskNotificationManager implementation
@riverpod
ITaskNotificationManager taskNotificationManager(
  Ref ref,
) {
  return ref.watch(notificationManagerProvider);
}

/// IPlantNotificationManager implementation
@riverpod
IPlantNotificationManager plantNotificationManager(
  Ref ref,
) {
  return ref.watch(notificationManagerProvider);
}

/// INotificationPermissionManager implementation
@riverpod
INotificationPermissionManager notificationPermissionManager(
  Ref ref,
) {
  return ref.watch(notificationManagerProvider) as INotificationPermissionManager;
}

/// INotificationScheduleManager implementation
@riverpod
INotificationScheduleManager notificationScheduleManager(
  Ref ref,
) {
  return ref.watch(notificationManagerProvider);
}

// ============================================================================
// AUTH & STATE MANAGEMENT
// ============================================================================

// AuthStateNotifier provider is defined in auth_state_provider.dart
// to avoid circular dependencies and conflicts

/// Auth State Notifier (singleton for app-wide auth state)
@riverpod
AuthStateNotifier authStateNotifier(Ref ref) {
  return AuthStateNotifier.instance;
}

// ============================================================================
// STUB IMPLEMENTATIONS (Temporary placeholders for TODO items)
// ============================================================================

/// Temporary stub for local storage repository

/// Alias for backwards compatibility with legacy code
/// Use authStateProvider instead in new code
const authStateNotifierProvider = authStateProvider;
