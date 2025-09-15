import 'package:get_it/get_it.dart';

import '../../../features/plants/data/datasources/local/plants_local_datasource.dart';
import '../../../features/plants/data/datasources/remote/plants_remote_datasource.dart';
import '../../../features/plants/data/repositories/plant_comments_repository_impl.dart';
import '../../../features/plants/data/repositories/plants_repository_impl.dart';
import '../../../features/plants/domain/repositories/plant_comments_repository.dart';
import '../../../features/plants/domain/repositories/plants_repository.dart';
import '../../../features/plants/domain/services/plant_task_generator.dart';
import '../../../features/plants/domain/usecases/add_plant_usecase.dart';
import '../../../features/plants/domain/usecases/delete_plant_usecase.dart';
import '../../../features/plants/domain/usecases/get_plants_usecase.dart';
import '../../../features/plants/domain/usecases/update_plant_usecase.dart';
import '../../../features/plants/presentation/providers/plant_comments_provider.dart';
import '../../../features/plants/presentation/providers/plant_details_provider.dart';
import '../../../features/plants/presentation/providers/plant_form_provider.dart';
import '../../../features/plants/presentation/providers/plant_task_provider.dart';
import '../../../features/plants/presentation/providers/plants_provider.dart';

abstract class PlantsDIModule {
  static void init(GetIt sl) {
    // Data sources
    sl.registerLazySingleton<PlantsLocalDatasource>(
      () => PlantsLocalDatasourceImpl(),
    );

    sl.registerLazySingleton<PlantsRemoteDatasource>(
      () => PlantsRemoteDatasourceImpl(firestore: sl()),
    );

    // Repository
    sl.registerLazySingleton<PlantsRepository>(
      () => PlantsRepositoryImpl(
        localDatasource: sl(),
        remoteDatasource: sl(),
        networkInfo: sl(),
        authService: sl(),
      ),
    );

    // Plant Comments Repository
    sl.registerLazySingleton<PlantCommentsRepository>(
      () => PlantCommentsRepositoryImpl(),
    );

    // Use cases
    sl.registerLazySingleton(() => GetPlantsUseCase(sl()));
    sl.registerLazySingleton(() => GetPlantByIdUseCase(sl()));
    sl.registerLazySingleton(() => SearchPlantsUseCase(sl()));
    sl.registerLazySingleton(
      () => AddPlantUseCase(sl(), generateInitialTasksUseCase: sl()),
    );
    sl.registerLazySingleton(() => UpdatePlantUseCase(sl()));
    sl.registerLazySingleton(() => DeletePlantUseCase(sl()));

    // Providers
    sl.registerFactory(
      () => PlantsProvider(
        getPlantsUseCase: sl(),
        getPlantByIdUseCase: sl(),
        searchPlantsUseCase: sl(),
        addPlantUseCase: sl(),
        updatePlantUseCase: sl(),
        deletePlantUseCase: sl(),
      ),
    );


    sl.registerFactory(
      () => PlantDetailsProvider(
        getPlantByIdUseCase: sl(),
        deletePlantUseCase: sl(),
        updatePlantUseCase: sl(),
      ),
    );

    sl.registerFactory(
      () => PlantFormProvider(
        getPlantByIdUseCase: sl(),
        addPlantUseCase: sl(),
        updatePlantUseCase: sl(),
        imageService: sl(),
      ),
    );

    // Plant task generator
    sl.registerLazySingleton(() => PlantTaskGenerator());

    // Plant task provider
    sl.registerFactory(() => PlantTaskProvider(taskGenerationService: sl()));

    // Plant comments provider  
    sl.registerFactory(() => PlantCommentsProvider(repository: sl()));
  }
}
