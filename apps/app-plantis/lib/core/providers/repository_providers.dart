import 'package:core/core.dart';

import '../../core/sync/sync_queue_drift_service.dart';
import '../../database/providers/database_providers.dart';
import '../../database/repositories/sync_queue_drift_repository.dart';
import '../../features/auth/domain/usecases/reset_password_usecase.dart';
import '../../features/device_management/data/datasources/device_local_datasource.dart';
import '../../features/device_management/data/datasources/device_remote_datasource.dart';
import '../../features/device_management/data/repositories/device_repository_impl.dart';
import '../../features/device_management/domain/repositories/device_repository.dart';
import '../../features/plants/data/datasources/local/plant_tasks_local_datasource.dart';
import '../../features/plants/data/datasources/local/plants_local_datasource.dart';
import '../../features/plants/data/datasources/local/spaces_local_datasource.dart';
import '../../features/plants/data/datasources/remote/plant_tasks_remote_datasource.dart';
import '../../features/plants/data/datasources/remote/plants_remote_datasource.dart';
import '../../features/plants/data/datasources/remote/spaces_remote_datasource.dart';
import '../../features/plants/data/repositories/plant_tasks_repository_impl.dart';
import '../../features/plants/data/repositories/plants_repository_impl.dart';
import '../../features/plants/data/repositories/spaces_repository_impl.dart';
import '../../features/plants/data/services/plant_sync_service_impl.dart';
import '../../features/plants/data/services/plants_connectivity_service_impl.dart';
import '../../features/plants/domain/repositories/plant_tasks_repository.dart';
import '../../features/plants/domain/repositories/plants_repository.dart';
import '../../features/plants/domain/repositories/spaces_repository.dart';
import '../../features/plants/domain/services/plant_sync_service.dart';
import '../../features/plants/domain/services/plants_connectivity_service.dart';
import '../../features/settings/data/datasources/settings_local_datasource.dart';
import '../../features/settings/data/repositories/settings_repository.dart';
import '../../features/settings/domain/repositories/i_settings_repository.dart';
import '../../features/settings/domain/usecases/sync_settings_usecase.dart';
import '../config/security_config.dart';
import '../interfaces/network_info.dart';
import '../services/plantis_sync_service.dart';
import '../services/rate_limiter_service.dart';
import 'comments_providers.dart';
import 'core_di_providers.dart';

part 'repository_providers.g.dart';

/// === EXTERNAL SERVICES ===

@riverpod
FirebaseFirestore firebaseFirestore(Ref ref) {
  return FirebaseFirestore.instance;
}

@riverpod
FirebaseAuth firebaseAuth(Ref ref) {
  return FirebaseAuth.instance;
}

@riverpod
Connectivity connectivity(Ref ref) {
  return Connectivity();
}

@riverpod
ConnectivityService connectivityService(Ref ref) {
  return ConnectivityService.instance;
}

/// === CORE REPOSITORIES ===

@riverpod
IAuthRepository authRepository(Ref ref) {
  return PlantisSecurityConfig.createEnhancedAuthService();
}

@riverpod
ISubscriptionRepository subscriptionRepository(Ref ref) {
  return RevenueCatService();
}

@riverpod
NetworkInfo networkInfo(Ref ref) {
  return NetworkInfoImpl(ref.watch(connectivityProvider));
}

@riverpod
RateLimiterService rateLimiterService(Ref ref) {
  return RateLimiterService();
}

@riverpod
ILocalStorageRepository localStorageRepository(Ref ref) {
  final db = ref.watch(plantisDatabaseProvider);
  return DriftStorageService(db);
}

@riverpod
FirebaseDeviceService firebaseDeviceService(Ref ref) {
  return FirebaseDeviceService(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
}

/// === DATASOURCES ===

@riverpod
PlantsLocalDatasource plantsLocalDatasource(Ref ref) {
  final driftRepo = ref.watch(plantsDriftRepositoryProvider);
  return PlantsLocalDatasourceImpl(driftRepo);
}

@riverpod
PlantsRemoteDatasource plantsRemoteDatasource(Ref ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final rateLimiter = ref.watch(rateLimiterServiceProvider);
  return PlantsRemoteDatasourceImpl(
    firestore: firestore,
    rateLimiter: rateLimiter,
  );
}

@riverpod
SpacesLocalDatasource spacesLocalDatasource(Ref ref) {
  final driftRepo = ref.watch(spacesDriftRepositoryProvider);
  return SpacesLocalDatasourceImpl(driftRepo);
}

@riverpod
SpacesRemoteDatasource spacesRemoteDatasource(Ref ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final rateLimiter = ref.watch(rateLimiterServiceProvider);
  return SpacesRemoteDatasourceImpl(
    firestore: firestore,
    rateLimiter: rateLimiter,
  );
}

@riverpod
PlantTasksLocalDatasource plantTasksLocalDatasource(
    Ref ref) {
  final driftRepo = ref.watch(plantTasksDriftRepositoryProvider);
  return PlantTasksLocalDatasourceImpl(driftRepo);
}

@riverpod
PlantTasksRemoteDatasource plantTasksRemoteDatasource(
    Ref ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return PlantTasksRemoteDatasourceImpl(firestore);
}

@riverpod
DeviceLocalDataSource deviceLocalDataSource(Ref ref) {
  return DeviceLocalDataSourceImpl(
    storageService: ref.watch(localStorageRepositoryProvider),
  );
}

@riverpod
DeviceRemoteDataSource deviceRemoteDataSource(Ref ref) {
  return DeviceRemoteDataSourceImpl(
    firebaseDeviceService: ref.watch(firebaseDeviceServiceProvider),
  );
}

/// === SERVICES ===

@riverpod
PlantsConnectivityService plantsConnectivityService(
    Ref ref) {
  return PlantsConnectivityServiceImpl(
    networkInfo: ref.watch(networkInfoProvider),
  );
}

@riverpod
PlantSyncService plantSyncService(Ref ref) {
  return PlantSyncServiceImpl(
    localDatasource: ref.watch(plantsLocalDatasourceProvider),
    remoteDatasource: ref.watch(plantsRemoteDatasourceProvider),
  );
}

/// === REPOSITORIES ===

// PlantCommentsRepository moved to comments_providers.dart

@riverpod
PlantTasksRepository plantTasksRepository(Ref ref) {
  return PlantTasksRepositoryImpl(
    localDatasource: ref.watch(plantTasksLocalDatasourceProvider),
    remoteDatasource: ref.watch(plantTasksRemoteDatasourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
    authService: ref.watch(authRepositoryProvider),
  );
}

@riverpod
SpacesRepository spacesRepository(Ref ref) {
  return SpacesRepositoryImpl(
    localDatasource: ref.watch(spacesLocalDatasourceProvider),
    remoteDatasource: ref.watch(spacesRemoteDatasourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
    authService: ref.watch(authRepositoryProvider),
  );
}

@riverpod
PlantsRepository plantsRepository(Ref ref) {
  return PlantsRepositoryImpl(
    localDatasource: ref.watch(plantsLocalDatasourceProvider),
    remoteDatasource: ref.watch(plantsRemoteDatasourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
    authService: ref.watch(authRepositoryProvider),
    taskRepository: ref.watch(plantTasksRepositoryProvider),
    commentsRepository: ref.watch(plantCommentsRepositoryProvider),
    connectivityService: ref.watch(plantsConnectivityServiceProvider),
    syncService: ref.watch(plantSyncServiceProvider),
  );
}

@riverpod
DeviceRepository deviceRepository(Ref ref) {
  return DeviceRepositoryImpl(
    localDataSource: ref.watch(deviceLocalDataSourceProvider),
    remoteDataSource: ref.watch(deviceRemoteDataSourceProvider),
  );
}

/// === APP SERVICES ===

@riverpod
PlantisSyncService plantisSyncService(Ref ref) {
  return PlantisSyncService(
    plantsRepository: ref.watch(plantsRepositoryProvider),
    spacesRepository: ref.watch(spacesRepositoryProvider),
    plantTasksRepository: ref.watch(plantTasksRepositoryProvider),
    plantCommentsRepository: ref.watch(plantCommentsRepositoryProvider),
  );
}

/// === USECASES ===

@riverpod
LoginUseCase loginUseCase(Ref ref) {
  return LoginUseCase(
    ref.watch(authRepositoryProvider),
    ref.watch(analyticsRepositoryProvider),
  );
}

@riverpod
LogoutUseCase logoutUseCase(Ref ref) {
  return LogoutUseCase(
    ref.watch(authRepositoryProvider),
    ref.watch(analyticsRepositoryProvider),
  );
}

@riverpod
ResetPasswordUseCase resetPasswordUseCase(Ref ref) {
  return ResetPasswordUseCase(ref.watch(authRepositoryProvider));
}

/// === SETTINGS ===

@riverpod
SettingsLocalDataSource settingsLocalDataSource(
    Ref ref) {
  return SettingsLocalDataSource(prefs: ref.watch(sharedPreferencesProvider));
}

@riverpod
ISettingsRepository settingsRepository(Ref ref) {
  return SettingsRepository(
    localDataSource: ref.watch(settingsLocalDataSourceProvider),
  );
}

@riverpod
SyncSettingsUseCase syncSettingsUseCase(Ref ref) {
  return SyncSettingsUseCase(ref.watch(settingsRepositoryProvider));
}

/// === SYNC QUEUE ===

@riverpod
SyncQueueDriftRepository syncQueueDriftRepository(
    Ref ref) {
  final db = ref.watch(plantisDatabaseProvider);
  return SyncQueueDriftRepository(db);
}

@riverpod
SyncQueueDriftService syncQueueDriftService(Ref ref) {
  return SyncQueueDriftService(ref.watch(syncQueueDriftRepositoryProvider));
}

// syncQueue provider removed - uses local SyncQueue which conflicts with core's SyncQueue
