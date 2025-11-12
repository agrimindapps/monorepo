import 'package:core/core.dart' hide Column;

import '../../../features/plants/domain/services/plant_task_generator.dart';

abstract class PlantsDIModule {
  static void init(GetIt sl) {
    // PlantsLocalDatasource - auto-registered by @LazySingleton in plants_local_datasource.dart
    // PlantsRemoteDatasource - auto-registered by @LazySingleton in plants_remote_datasource.dart
    // PlantTasksLocalDatasource - auto-registered by @LazySingleton in plant_tasks_local_datasource.dart
    // PlantTasksRemoteDatasource - auto-registered by @LazySingleton in plant_tasks_remote_datasource.dart
    // PlantTaskGenerator - only register if not using @injectable

    sl.registerLazySingleton(() => PlantTaskGenerator());
  }
}
