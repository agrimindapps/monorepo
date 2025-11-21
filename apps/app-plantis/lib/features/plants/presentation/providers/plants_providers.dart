import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/local/plants_local_datasource.dart';
import '../../data/datasources/remote/plants_remote_datasource.dart';
import '../../data/datasources/local/plant_tasks_local_datasource.dart';
import '../../data/datasources/remote/plant_tasks_remote_datasource.dart';
import '../../data/repositories/plant_comments_repository_impl.dart';
import '../../data/repositories/plant_tasks_repository_impl.dart';
import '../../data/repositories/plants_repository_impl.dart';
import '../../domain/repositories/plant_comments_repository.dart';
import '../../domain/repositories/plant_tasks_repository.dart';
import '../../domain/repositories/plants_repository.dart';
import '../../domain/services/plant_sync_service.dart';
import '../../domain/services/plants_connectivity_service.dart';
import '../../domain/usecases/add_plant_usecase.dart';
import '../../domain/usecases/delete_plant_usecase.dart';
import '../../domain/usecases/get_plants_usecase.dart';
import '../../domain/usecases/update_plant_usecase.dart';
import '../../data/services/plants_connectivity_service_impl.dart';
import '../../data/services/plant_sync_service_impl.dart';
import '../../../../database/repositories/plants_drift_repository.dart';
import '../../../../database/repositories/plant_tasks_drift_repository.dart';

// Import core providers
import '../../../../core/auth/auth_providers.dart';
import '../../../../core/services/services_providers.dart';
import '../../../../database/providers/database_providers.dart';

part 'plants_providers.g.dart';

// Datasources
@riverpod
PlantsLocalDatasource plantsLocalDatasource(PlantsLocalDatasourceRef ref) {
  final driftRepo = ref.watch(plantsDriftRepositoryProvider);
  return PlantsLocalDatasourceImpl(driftRepo);
}

@riverpod
PlantTasksLocalDatasource plantTasksLocalDatasource(PlantTasksLocalDatasourceRef ref) {
  final driftRepo = ref.watch(plantTasksDriftRepositoryProvider);
  return PlantTasksLocalDatasourceImpl(driftRepo);
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
PlantTasksRemoteDatasource plantTasksRemoteDatasource(PlantTasksRemoteDatasourceRef ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return PlantTasksRemoteDatasourceImpl(firestore);
}

// Services
@riverpod
PlantsConnectivityService plantsConnectivityService(PlantsConnectivityServiceRef ref) {
  final networkInfo = ref.watch(networkInfoProvider);
  return PlantsConnectivityServiceImpl(networkInfo);
}

@riverpod
PlantSyncService plantSyncService(PlantSyncServiceRef ref) {
  final localDatasource = ref.watch(plantsLocalDatasourceProvider);
  final remoteDatasource = ref.watch(plantsRemoteDatasourceProvider);
  return PlantSyncServiceImpl(
    localDatasource: localDatasource,
    remoteDatasource: remoteDatasource,
  );
}

// Repositories
@riverpod
PlantTasksRepository plantTasksRepository(PlantTasksRepositoryRef ref) {
  final localDatasource = ref.watch(plantTasksLocalDatasourceProvider);
  final remoteDatasource = ref.watch(plantTasksRemoteDatasourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  final authRepository = ref.watch(authRepositoryProvider);

  return PlantTasksRepositoryImpl(
    localDatasource: localDatasource,
    remoteDatasource: remoteDatasource,
    networkInfo: networkInfo,
    authService: authRepository,
  );
}

@riverpod
PlantCommentsRepository plantCommentsRepository(PlantCommentsRepositoryRef ref) {
  return PlantCommentsRepositoryImpl();
}

@riverpod
PlantsRepository plantsRepository(PlantsRepositoryRef ref) {
  final localDatasource = ref.watch(plantsLocalDatasourceProvider);
  final remoteDatasource = ref.watch(plantsRemoteDatasourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  final taskRepository = ref.watch(plantTasksRepositoryProvider);
  final commentsRepository = ref.watch(plantCommentsRepositoryProvider);
  final connectivityService = ref.watch(plantsConnectivityServiceProvider);
  final syncService = ref.watch(plantSyncServiceProvider);

  return PlantsRepositoryImpl(
    localDatasource: localDatasource,
    remoteDatasource: remoteDatasource,
    networkInfo: networkInfo,
    authService: authRepository,
    taskRepository: taskRepository,
    commentsRepository: commentsRepository,
    connectivityService: connectivityService,
    syncService: syncService,
  );
}

// UseCases
@riverpod
GetPlantsUseCase getPlantsUseCase(GetPlantsUseCaseRef ref) {
  final repository = ref.watch(plantsRepositoryProvider);
  return GetPlantsUseCase(repository);
}

@riverpod
GetPlantByIdUseCase getPlantByIdUseCase(GetPlantByIdUseCaseRef ref) {
  final repository = ref.watch(plantsRepositoryProvider);
  return GetPlantByIdUseCase(repository);
}

@riverpod
SearchPlantsUseCase searchPlantsUseCase(SearchPlantsUseCaseRef ref) {
  final repository = ref.watch(plantsRepositoryProvider);
  return SearchPlantsUseCase(repository);
}

@riverpod
AddPlantUseCase addPlantUseCase(AddPlantUseCaseRef ref) {
  final repository = ref.watch(plantsRepositoryProvider);
  return AddPlantUseCase(repository);
}

@riverpod
UpdatePlantUseCase updatePlantUseCase(UpdatePlantUseCaseRef ref) {
  final repository = ref.watch(plantsRepositoryProvider);
  return UpdatePlantUseCase(repository);
}

@riverpod
DeletePlantUseCase deletePlantUseCase(DeletePlantUseCaseRef ref) {
  final repository = ref.watch(plantsRepositoryProvider);
  return DeletePlantUseCase(repository);
}
