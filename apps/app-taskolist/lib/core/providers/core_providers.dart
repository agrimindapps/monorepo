import 'package:core/core.dart' hide getIt, Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../../database/taskolist_database.dart';
import '../../features/tasks/providers/task_providers.dart';
import '../../infrastructure/services/analytics_service.dart';
import '../../infrastructure/services/auth_service.dart';
import '../../infrastructure/services/crashlytics_service.dart';
import '../../infrastructure/services/notification_service.dart';
import '../../infrastructure/services/performance_service.dart';
import '../../infrastructure/services/subscription_service.dart';
import '../../infrastructure/services/sync_service.dart';
import '../services/auto_sync_service.dart';
import '../services/data_integrity_service.dart';
import '../services/taskolist_data_cleaner.dart';

part 'core_providers.g.dart';

// ============================================================================
// DATABASE
// ============================================================================

/// Provider do banco de dados principal
///
/// **IMPORTANTE:** Retorna a instância única do GetIt para evitar múltiplas instâncias.
/// Funciona em Web (WASM) e Mobile (Native) via DriftDatabaseConfig.
final taskolistDatabaseProvider = Provider<TaskolistDatabase>((ref) {
  final db = GetIt.I<TaskolistDatabase>();
  ref.keepAlive();
  return db;
});

/// Provider legado (mantido para compatibilidade)
@Deprecated('Use taskolistDatabaseProvider')
@riverpod
TaskolistDatabase taskolistDatabase(Ref ref) {
  return ref.watch(taskolistDatabaseProvider);
}

// ============================================================================
// CORE SERVICES (from core package)
// ============================================================================

@riverpod
ConnectivityService connectivityService(Ref ref) {
  return ConnectivityService.instance;
}

@riverpod
IAnalyticsRepository analyticsRepository(Ref ref) {
  return FirebaseAnalyticsService();
}

@riverpod
ICrashlyticsRepository crashlyticsRepository(Ref ref) {
  return FirebaseCrashlyticsService();
}

@riverpod
IPerformanceRepository performanceRepository(Ref ref) {
  return PerformanceService();
}

@riverpod
ISubscriptionRepository subscriptionRepository(Ref ref) {
  return RevenueCatService();
}

@riverpod
INotificationRepository notificationRepository(Ref ref) {
  return LocalNotificationService();
}

@riverpod
IAuthRepository authRepository(Ref ref) {
  return FirebaseAuthService();
}

// ============================================================================
// APP-SPECIFIC SERVICES
// ============================================================================

@riverpod
TaskManagerAnalyticsService taskManagerAnalyticsService(Ref ref) {
  final analyticsRepository = ref.watch(analyticsRepositoryProvider);
  return TaskManagerAnalyticsService(analyticsRepository);
}

@riverpod
TaskManagerCrashlyticsService taskManagerCrashlyticsService(Ref ref) {
  final crashlyticsRepository = ref.watch(crashlyticsRepositoryProvider);
  return TaskManagerCrashlyticsService(crashlyticsRepository);
}

@riverpod
TaskManagerPerformanceService taskManagerPerformanceService(Ref ref) {
  final performanceRepository = ref.watch(performanceRepositoryProvider);
  return TaskManagerPerformanceService(performanceRepository);
}

@riverpod
TaskManagerNotificationService taskManagerNotificationService(Ref ref) {
  final notificationRepository = ref.watch(notificationRepositoryProvider);
  final analyticsService = ref.watch(taskManagerAnalyticsServiceProvider);
  final crashlyticsService = ref.watch(taskManagerCrashlyticsServiceProvider);
  return TaskManagerNotificationService(
    notificationRepository,
    analyticsService,
    crashlyticsService,
  );
}

@riverpod
TaskManagerSubscriptionService taskManagerSubscriptionService(Ref ref) {
  final subscriptionRepository = ref.watch(subscriptionRepositoryProvider);
  final analyticsService = ref.watch(taskManagerAnalyticsServiceProvider);
  final crashlyticsService = ref.watch(taskManagerCrashlyticsServiceProvider);
  return TaskManagerSubscriptionService(
    subscriptionRepository,
    analyticsService,
    crashlyticsService,
  );
}

@riverpod
Future<TaskManagerAuthService> taskManagerAuthService(Ref ref) async {
  final authRepository = ref.watch(authRepositoryProvider);
  final analyticsService = ref.watch(taskManagerAnalyticsServiceProvider);
  final crashlyticsService = ref.watch(taskManagerCrashlyticsServiceProvider);
  final subscriptionService = ref.watch(taskManagerSubscriptionServiceProvider);
  final syncService = ref.watch(taskManagerSyncServiceProvider);
  final enhancedDeletionService = await ref.watch(
    enhancedAccountDeletionServiceProvider.future,
  );
  return TaskManagerAuthService(
    authRepository,
    analyticsService,
    crashlyticsService,
    subscriptionService,
    syncService,
    enhancedDeletionService,
  );
}

@riverpod
TaskManagerSyncService taskManagerSyncService(Ref ref) {
  final analyticsService = ref.watch(taskManagerAnalyticsServiceProvider);
  final crashlyticsService = ref.watch(taskManagerCrashlyticsServiceProvider);
  return TaskManagerSyncService(analyticsService, crashlyticsService);
}

// ============================================================================
// DATA SERVICES
// ============================================================================

@riverpod
DataIntegrityService dataIntegrityService(Ref ref) {
  final taskLocalDataSource = ref.watch(taskLocalDataSourceProvider);
  return DataIntegrityService(taskLocalDataSource);
}

@riverpod
Future<TaskolistDataCleaner> taskolistDataCleaner(Ref ref) async {
  final database = ref.watch(taskolistDatabaseProvider);
  final prefs = await SharedPreferences.getInstance();
  return TaskolistDataCleaner(database: database, prefs: prefs);
}

@riverpod
AutoSyncService autoSyncService(Ref ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  final dataIntegrityService = ref.watch(dataIntegrityServiceProvider);
  return AutoSyncService(connectivityService, dataIntegrityService);
}

// ============================================================================
// ACCOUNT DELETION SERVICES (from core package)
// ============================================================================

@riverpod
FirestoreDeletionService firestoreDeletionService(Ref ref) {
  return FirestoreDeletionService();
}

@riverpod
RevenueCatCancellationService revenueCatCancellationService(Ref ref) {
  return RevenueCatCancellationService();
}

@riverpod
AccountDeletionRateLimiter accountDeletionRateLimiter(Ref ref) {
  return AccountDeletionRateLimiter();
}

@riverpod
Future<EnhancedAccountDeletionService> enhancedAccountDeletionService(
  Ref ref,
) async {
  final appDataCleaner = await ref.watch(taskolistDataCleanerProvider.future);
  return EnhancedAccountDeletionService(
    authRepository: ref.watch(authRepositoryProvider),
    appDataCleaner: appDataCleaner,
    firestoreDeletion: ref.watch(firestoreDeletionServiceProvider),
    revenueCatCancellation: ref.watch(revenueCatCancellationServiceProvider),
    rateLimiter: ref.watch(accountDeletionRateLimiterProvider),
  );
}
