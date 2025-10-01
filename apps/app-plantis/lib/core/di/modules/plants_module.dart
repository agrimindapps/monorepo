import 'package:core/core.dart';

import '../../../features/plants/data/datasources/local/plant_tasks_local_datasource.dart';
import '../../../features/plants/data/datasources/local/plants_local_datasource.dart';
import '../../../features/plants/data/datasources/remote/plant_tasks_remote_datasource.dart';
import '../../../features/plants/data/datasources/remote/plants_remote_datasource.dart';
import '../../../features/plants/data/repositories/plant_comments_repository_impl.dart';
import '../../../features/plants/data/repositories/plant_tasks_repository_impl.dart';
import '../../../features/plants/domain/repositories/plant_comments_repository.dart';
import '../../../features/plants/domain/repositories/plant_tasks_repository.dart';
import '../../../features/plants/domain/services/plant_task_generator.dart';
import '../../../features/plants/presentation/providers/plant_comments_provider.dart';
import '../../../features/plants/presentation/providers/plant_details_provider.dart';
import '../../../features/plants/presentation/providers/plant_task_provider.dart';

abstract class PlantsDIModule {
  static void init(GetIt sl) {
    // Data sources
    sl.registerLazySingleton<PlantsLocalDatasource>(
      () => PlantsLocalDatasourceImpl(),
    );

    sl.registerLazySingleton<PlantsRemoteDatasource>(
      () => PlantsRemoteDatasourceImpl(firestore: sl()),
    );

    // Repository - PlantsRepository já registrado via Injectable (@LazySingleton)

    // Plant Comments Repository
    sl.registerLazySingleton<PlantCommentsRepository>(
      () => PlantCommentsRepositoryImpl(),
    );

    // Plant Tasks Repository
    sl.registerLazySingleton<PlantTasksRepository>(
      () => PlantTasksRepositoryImpl(
        localDatasource: sl(),
        remoteDatasource: sl(),
        networkInfo: sl(),
        authService: sl(),
      ),
    );

    // Plant Tasks Data Sources
    sl.registerLazySingleton<PlantTasksLocalDatasource>(
      () => PlantTasksLocalDatasourceImpl(),
    );

    sl.registerLazySingleton<PlantTasksRemoteDatasource>(
      () => PlantTasksRemoteDatasourceImpl(firestore: sl()),
    );

    // Use cases - Todos já registrados via Injectable (@injectable)

    // Legacy PlantsProvider removed - now using Riverpod PlantsNotifier

    sl.registerFactory(
      () => PlantDetailsProvider(
        getPlantByIdUseCase: sl(),
        deletePlantUseCase: sl(),
        updatePlantUseCase: sl(),
      ),
    );

    // PlantFormProvider removido - agora usa sistema SOLID com PlantFormStateManager

    // Plant task generator
    sl.registerLazySingleton(() => PlantTaskGenerator());

    // Plant task provider
    sl.registerFactory(() => PlantTaskProvider(taskGenerationService: sl()));

    // Plant comments provider
    sl.registerFactory(() => PlantCommentsProvider(repository: sl()));
  }
}
