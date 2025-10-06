import 'package:core/core.dart';

import '../../../features/plants/data/datasources/local/plant_tasks_local_datasource.dart';
import '../../../features/plants/data/datasources/local/plants_local_datasource.dart';
import '../../../features/plants/data/datasources/remote/plant_tasks_remote_datasource.dart';
import '../../../features/plants/data/datasources/remote/plants_remote_datasource.dart';
import '../../../features/plants/domain/services/plant_task_generator.dart';
import '../../../features/plants/presentation/providers/plant_details_provider.dart';
import '../../../features/plants/presentation/providers/plant_task_provider.dart';

abstract class PlantsDIModule {
  static void init(GetIt sl) {
    sl.registerLazySingleton<PlantsLocalDatasource>(
      () => PlantsLocalDatasourceImpl(),
    );

    sl.registerLazySingleton<PlantsRemoteDatasource>(
      () => PlantsRemoteDatasourceImpl(firestore: sl()),
    );
    sl.registerLazySingleton<PlantTasksLocalDatasource>(
      () => PlantTasksLocalDatasourceImpl(),
    );

    sl.registerLazySingleton<PlantTasksRemoteDatasource>(
      () => PlantTasksRemoteDatasourceImpl(firestore: sl()),
    );

    sl.registerFactory(
      () => PlantDetailsProvider(
        getPlantByIdUseCase: sl(),
        deletePlantUseCase: sl(),
        updatePlantUseCase: sl(),
      ),
    );
    sl.registerLazySingleton(() => PlantTaskGenerator());
    sl.registerFactory(
      () => PlantTaskProvider(
        taskGenerationService: sl(),
        repository: sl(),
      ),
    );
  }
}
