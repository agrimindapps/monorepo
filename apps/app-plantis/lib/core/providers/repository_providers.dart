import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:core/core.dart';
import 'package:core/src/infrastructure/services/firebase_device_service.dart';
import 'package:core/src/infrastructure/storage/drift/services/drift_storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/security_config.dart';

import '../../database/providers/database_providers.dart';
import '../../features/auth/domain/usecases/reset_password_usecase.dart';
import '../../features/device_management/data/datasources/device_local_datasource.dart';
import '../../features/device_management/data/datasources/device_remote_datasource.dart';
import '../../features/device_management/data/repositories/device_repository_impl.dart';
import '../../features/device_management/domain/repositories/device_repository.dart';
import '../../features/settings/data/datasources/settings_local_datasource.dart';
import '../../features/settings/data/repositories/settings_repository.dart';
import '../../features/settings/domain/repositories/i_settings_repository.dart';
import '../../database/repositories/sync_queue_drift_repository.dart';
import '../../core/sync/sync_queue_drift_service.dart';
import '../../core/sync/sync_queue.dart' as app_sync_queue;
import '../../features/settings/domain/usecases/sync_settings_usecase.dart';
import '../../features/plants/data/datasources/local/plant_tasks_local_datasource.dart';
import '../../features/plants/data/datasources/local/plants_local_datasource.dart';
import '../../features/plants/data/datasources/local/spaces_local_datasource.dart';
import '../../features/plants/data/datasources/remote/plant_tasks_remote_datasource.dart';
import '../../features/plants/data/datasources/remote/plants_remote_datasource.dart';
import '../../features/plants/data/datasources/remote/spaces_remote_datasource.dart';
import '../../features/plants/data/repositories/plant_comments_repository_impl.dart';
import '../../features/plants/data/repositories/plant_tasks_repository_impl.dart';
import '../../features/plants/data/repositories/plants_repository_impl.dart';
import '../../features/plants/data/repositories/spaces_repository_impl.dart';
import '../../features/plants/data/services/plant_sync_service_impl.dart';
import '../../features/plants/data/services/plants_connectivity_service_impl.dart';
import '../../features/plants/domain/repositories/plant_comments_repository.dart';
import '../../features/plants/domain/repositories/plant_tasks_repository.dart';
import '../../features/plants/domain/repositories/plants_repository.dart';
import '../../features/plants/domain/repositories/spaces_repository.dart';
import '../../features/plants/domain/services/plant_sync_service.dart';
import '../../features/plants/domain/services/plants_connectivity_service.dart';
import '../services/plantis_sync_service.dart';
import '../services/rate_limiter_service.dart';
import '../interfaces/network_info.dart';
import 'core_di_providers.dart';

part 'repository_providers.g.dart';

/// === EXTERNAL SERVICES ===

@riverpod
FirebaseFirestore firebaseFirestore(FirebaseFirestoreRef ref) {
  return FirebaseFirestore.instance;
}

@riverpod
FirebaseAuth firebaseAuth(FirebaseAuthRef ref) {
  return FirebaseAuth.instance;
}

@riverpod
Connectivity connectivity(ConnectivityRef ref) {
  return Connectivity();
}

@riverpod
ConnectivityService connectivityService(ConnectivityServiceRef ref) {
  return ConnectivityService.instance;
}

/// === CORE REPOSITORIES ===

@riverpod
IAuthRepository authRepository(AuthRepositoryRef ref) {
  return PlantisSecurityConfig.createEnhancedAuthService();
}

@riverpod
ISubscriptionRepository subscriptionRepository(SubscriptionRepositoryRef ref) {
  return RevenueCatService();
}

@riverpod
NetworkInfo networkInfo(NetworkInfoRef ref) {
  return NetworkInfoImpl(ref.watch(connectivityProvider));
}

@riverpod
RateLimiterService rateLimiterService(RateLimiterServiceRef ref) {
  return RateLimiterService();
}

@riverpod
ILocalStorageRepository localStorageRepository(LocalStorageRepositoryRef ref) {
  final db = ref.watch(plantisDatabaseProvider);
  return DriftStorageService(db);
}

@riverpod
FirebaseDeviceService firebaseDeviceService(FirebaseDeviceServiceRef ref) {
  return FirebaseDeviceService(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
}

/// === DATASOURCES ===

@riverpod
PlantsLocalDatasource plantsLocalDatasource(PlantsLocalDatasourceRef ref) {
  final driftRepo = ref.watch(plantsDriftRepositoryProvider);
  return PlantsLocalDatasourceImpl(driftRepo);
}

@riverpod
PlantsRemoteDatasource plantsRemoteDatasource(PlantsRemoteDatasourceRef ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final rateLimiter = ref.watch(rateLimiterServiceProvider);
  return PlantsRemoteDatasourceImpl(
    firestore: firestore,
    rateLimiter: rateLimiter,
  );
}

@riverpod
SpacesLocalDatasource spacesLocalDatasource(SpacesLocalDatasourceRef ref) {
  final driftRepo = ref.watch(spacesDriftRepositoryProvider);
  return SpacesLocalDatasourceImpl(driftRepo);
}

@riverpod
SpacesRemoteDatasource spacesRemoteDatasource(SpacesRemoteDatasourceRef ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final rateLimiter = ref.watch(rateLimiterServiceProvider);
  return SpacesRemoteDatasourceImpl(
    firestore: firestore,
    rateLimiter: rateLimiter,
  );
}

@riverpod
PlantTasksLocalDatasource plantTasksLocalDatasource(
    PlantTasksLocalDatasourceRef ref) {
  final driftRepo = ref.watch(plantTasksDriftRepositoryProvider);
  return PlantTasksLocalDatasourceImpl(driftRepo);
}

@riverpod
PlantTasksRemoteDatasource plantTasksRemoteDatasource(
    PlantTasksRemoteDatasourceRef ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return PlantTasksRemoteDatasourceImpl(firestore);
}

@riverpod
DeviceLocalDataSource deviceLocalDataSource(DeviceLocalDataSourceRef ref) {
  return DeviceLocalDataSourceImpl(
    storageService: ref.watch(localStorageRepositoryProvider),
  );
}

@riverpod
DeviceRemoteDataSource deviceRemoteDataSource(DeviceRemoteDataSourceRef ref) {
  return DeviceRemoteDataSourceImpl(
    firebaseDeviceService: ref.watch(firebaseDeviceServiceProvider),
  );
}

/// === SERVICES ===

@riverpod
PlantsConnectivityService plantsConnectivityService(
    PlantsConnectivityServiceRef ref) {
  return PlantsConnectivityServiceImpl(
    networkInfo: ref.watch(networkInfoProvider),
  );
}

@riverpod
PlantSyncService plantSyncService(PlantSyncServiceRef ref) {
  return PlantSyncServiceImpl(
    localDatasource: ref.watch(plantsLocalDatasourceProvider),
    remoteDatasource: ref.watch(plantsRemoteDatasourceProvider),
  );
}

/// === REPOSITORIES ===

@riverpod
PlantCommentsRepository plantCommentsRepository(
    PlantCommentsRepositoryRef ref) {
  return PlantCommentsRepositoryImpl();
}

@riverpod
PlantTasksRepository plantTasksRepository(PlantTasksRepositoryRef ref) {
  return PlantTasksRepositoryImpl(
    localDatasource: ref.watch(plantTasksLocalDatasourceProvider),
    remoteDatasource: ref.watch(plantTasksRemoteDatasourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
    authService: ref.watch(authRepositoryProvider),
  );
}

@riverpod
SpacesRepository spacesRepository(SpacesRepositoryRef ref) {
  return SpacesRepositoryImpl(
    localDatasource: ref.watch(spacesLocalDatasourceProvider),
    remoteDatasource: ref.watch(spacesRemoteDatasourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
    authService: ref.watch(authRepositoryProvider),
  );
}

@riverpod
PlantsRepository plantsRepository(PlantsRepositoryRef ref) {
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
DeviceRepository deviceRepository(DeviceRepositoryRef ref) {
  return DeviceRepositoryImpl(
    localDataSource: ref.watch(deviceLocalDataSourceProvider),
    remoteDataSource: ref.watch(deviceRemoteDataSourceProvider),
  );
}

/// === APP SERVICES ===

@riverpod
PlantisSyncService plantisSyncService(PlantisSyncServiceRef ref) {
  return PlantisSyncService(
    plantsRepository: ref.watch(plantsRepositoryProvider),
    spacesRepository: ref.watch(spacesRepositoryProvider),
    plantTasksRepository: ref.watch(plantTasksRepositoryProvider),
    plantCommentsRepository: ref.watch(plantCommentsRepositoryProvider),
  );
}

/// === USECASES ===

@riverpod
LoginUseCase loginUseCase(LoginUseCaseRef ref) {
  return LoginUseCase(
    ref.watch(authRepositoryProvider),
    ref.watch(analyticsRepositoryProvider),
  );
}

@riverpod
LogoutUseCase logoutUseCase(LogoutUseCaseRef ref) {
  return LogoutUseCase(
    ref.watch(authRepositoryProvider),
    ref.watch(analyticsRepositoryProvider),
  );
}

@riverpod
ResetPasswordUseCase resetPasswordUseCase(ResetPasswordUseCaseRef ref) {
  return ResetPasswordUseCase(ref.watch(authRepositoryProvider));
}

/// === SETTINGS ===

@riverpod
SettingsLocalDataSource settingsLocalDataSource(
    SettingsLocalDataSourceRef ref) {
  return SettingsLocalDataSource(prefs: ref.watch(sharedPreferencesProvider));
}

@riverpod
ISettingsRepository settingsRepository(SettingsRepositoryRef ref) {
  return SettingsRepository(
    localDataSource: ref.watch(settingsLocalDataSourceProvider),
  );
}

@riverpod
SyncSettingsUseCase syncSettingsUseCase(SyncSettingsUseCaseRef ref) {
  return SyncSettingsUseCase(ref.watch(settingsRepositoryProvider));
}

/// === SYNC QUEUE ===

@riverpod
SyncQueueDriftRepository syncQueueDriftRepository(
    SyncQueueDriftRepositoryRef ref) {
  final db = ref.watch(plantisDatabaseProvider);
  return SyncQueueDriftRepository(db);
}

@riverpod
SyncQueueDriftService syncQueueDriftService(SyncQueueDriftServiceRef ref) {
  return SyncQueueDriftService(ref.watch(syncQueueDriftRepositoryProvider));
}

@riverpod
app_sync_queue.SyncQueue syncQueue(SyncQueueRef ref) {
  return app_sync_queue.SyncQueue(ref.watch(syncQueueDriftServiceProvider));
}
