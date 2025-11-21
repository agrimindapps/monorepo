import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_functions/firebase_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/security_config.dart';
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

part 'core_di_providers.g.dart';

// ============================================================================
// EXTERNAL DEPENDENCIES (Firebase, SharedPreferences, etc.)
// ============================================================================

/// SharedPreferences instance provider
/// Used for local storage and offline caching
@riverpod
Future<SharedPreferences> sharedPreferences(SharedPreferencesRef ref) async {
  return SharedPreferences.getInstance();
}

/// Firebase Storage instance
@riverpod
FirebaseStorage firebaseStorage(FirebaseStorageRef ref) {
  return FirebaseStorage.instance;
}

/// Firebase Firestore instance
@riverpod
FirebaseFirestore firebaseFirestore(FirebaseFirestoreRef ref) {
  return FirebaseFirestore.instance;
}

/// Firebase Auth instance
@riverpod
FirebaseAuth firebaseAuth(FirebaseAuthRef ref) {
  return FirebaseAuth.instance;
}

/// Firebase Functions instance
@riverpod
FirebaseFunctions firebaseFunctions(FirebaseFunctionsRef ref) {
  return FirebaseFunctions.instance;
}

/// Connectivity plugin instance
@riverpod
Connectivity connectivity(ConnectivityRef ref) {
  return Connectivity();
}

/// Connectivity service (singleton wrapper)
@riverpod
ConnectivityService connectivityService(ConnectivityServiceRef ref) {
  return ConnectivityService.instance;
}

// ============================================================================
// CORE REPOSITORIES (from core package + local implementations)
// ============================================================================

/// IAuthRepository provider - Firebase Auth implementation
@riverpod
IAuthRepository authRepository(AuthRepositoryRef ref) {
  return PlantisSecurityConfig.createEnhancedAuthService();
}

/// ISubscriptionRepository provider - RevenueCat implementation
@riverpod
ISubscriptionRepository subscriptionRepository(SubscriptionRepositoryRef ref) {
  return RevenueCatService();
}

/// IAnalyticsRepository provider - Firebase Analytics implementation
@riverpod
IAnalyticsRepository analyticsRepository(AnalyticsRepositoryRef ref) {
  return FirebaseAnalyticsService();
}

/// ICrashlyticsRepository provider - Firebase Crashlytics implementation
@riverpod
ICrashlyticsRepository crashlyticsRepository(CrashlyticsRepositoryRef ref) {
  return FirebaseCrashlyticsService();
}

/// IAppRatingRepository provider
@riverpod
IAppRatingRepository appRatingRepository(AppRatingRepositoryRef ref) {
  return AppRatingService(
    appStoreId: AppConstants.appStoreId,
    googlePlayId: AppConstants.googlePlayId,
    minDays: AppConstants.appRatingMinDays,
    minLaunches: AppConstants.appRatingMinLaunches,
    remindDays: AppConstants.appRatingRemindDays,
    remindLaunches: AppConstants.appRatingRemindLaunches,
  );
}

/// IPerformanceRepository provider
@riverpod
IPerformanceRepository performanceRepository(PerformanceRepositoryRef ref) {
  // TODO: Implement proper performance repository
  // For now, return a stub that delegates to core package
  return FirebasePerformanceService();
}

/// ILocalStorageRepository provider - Drift-based implementation
@riverpod
ILocalStorageRepository localStorageRepository(LocalStorageRepositoryRef ref) {
  // TODO: Implement proper local storage with Drift
  // For now, return a stub implementation
  return _StubLocalStorageRepository();
}

/// IFileRepository provider - File manager service
@riverpod
IFileRepository fileRepository(FileRepositoryRef ref) {
  return FileManagerService();
}

// ============================================================================
// CORE SERVICES
// ============================================================================

/// Enhanced Secure Storage Service
@riverpod
EnhancedSecureStorageService enhancedSecureStorageService(
  EnhancedSecureStorageServiceRef ref,
) {
  return EnhancedSecureStorageService(
    appIdentifier: AppConstants.appId,
    config: const SecureStorageConfig.plantis(),
  );
}

/// Secure Storage Service (singleton instance)
@riverpod
SecureStorageService secureStorageService(SecureStorageServiceRef ref) {
  return SecureStorageService.instance;
}

/// Image Service
@riverpod
ImageService imageService(ImageServiceRef ref) {
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
  PlantisImageServiceAdapterRef ref,
) {
  return PlantisImageServiceAdapterFactory.createForPlantis();
}

/// URL Launcher Service
@riverpod
UrlLauncherService urlLauncherService(UrlLauncherServiceRef ref) {
  return UrlLauncherService();
}

/// Data Cleaner Service
@riverpod
DataCleanerService dataCleanerService(DataCleanerServiceRef ref) {
  return DataCleanerService();
}

// ============================================================================
// NOTIFICATION SERVICES
// ============================================================================

/// Plantis Notification Service
@riverpod
PlantisNotificationService plantisNotificationService(
  PlantisNotificationServiceRef ref,
) {
  return PlantisNotificationService();
}

/// Task Notification Scheduler
@riverpod
ITaskNotificationScheduler taskNotificationScheduler(
  TaskNotificationSchedulerRef ref,
) {
  final notificationService = ref.watch(plantisNotificationServiceProvider);
  return TaskNotificationScheduler(notificationService);
}

/// Overdue Task Monitor
@riverpod
IOverdueTaskMonitor overdueTaskMonitor(OverdueTaskMonitorRef ref) {
  final scheduler = ref.watch(taskNotificationSchedulerProvider);
  return OverdueTaskMonitor(scheduler);
}

/// Permission Manager
@riverpod
IPermissionManager permissionManager(PermissionManagerRef ref) {
  final notificationService = ref.watch(plantisNotificationServiceProvider);
  return NotificationPermissionManager(notificationService);
}

/// Task Notification Service (orchestrator)
@riverpod
TaskNotificationService taskNotificationService(TaskNotificationServiceRef ref) {
  return TaskNotificationService();
}

/// Notification Manager (for backward compatibility)
@riverpod
NotificationManager notificationManager(NotificationManagerRef ref) {
  return NotificationManager();
}

/// ITaskNotificationManager implementation
@riverpod
ITaskNotificationManager taskNotificationManager(
  TaskNotificationManagerRef ref,
) {
  return ref.watch(notificationManagerProvider);
}

/// IPlantNotificationManager implementation
@riverpod
IPlantNotificationManager plantNotificationManager(
  PlantNotificationManagerRef ref,
) {
  return ref.watch(notificationManagerProvider);
}

/// INotificationPermissionManager implementation
@riverpod
INotificationPermissionManager notificationPermissionManager(
  NotificationPermissionManagerRef ref,
) {
  return ref.watch(notificationManagerProvider);
}

/// INotificationScheduleManager implementation
@riverpod
INotificationScheduleManager notificationScheduleManager(
  NotificationScheduleManagerRef ref,
) {
  return ref.watch(notificationManagerProvider);
}

// ============================================================================
// AUTH & STATE MANAGEMENT
// ============================================================================

/// Auth State Notifier (singleton for app-wide auth state)
@riverpod
AuthStateNotifier authStateNotifier(AuthStateNotifierRef ref) {
  return AuthStateNotifier.instance;
}

// ============================================================================
// STUB IMPLEMENTATIONS (Temporary placeholders for TODO items)
// ============================================================================

/// Temporary stub for local storage repository
/// TODO: Implement proper Drift-based storage
class _StubLocalStorageRepository implements ILocalStorageRepository {
  @override
  Future<void> saveData(String key, String value) async {}

  @override
  Future<String?> getData(String key) async => null;

  @override
  Future<void> deleteData(String key) async {}

  @override
  Future<void> clearAllData() async {}
}
