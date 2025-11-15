import 'package:core/core.dart' hide Column;

abstract class PlantsDIModule {
  static void init(GetIt sl) {
    // PlantsLocalDatasource - auto-registered by @LazySingleton in plants_local_datasource.dart
    // PlantsRemoteDatasource - auto-registered by @LazySingleton in plants_remote_datasource.dart
    // PlantTasksLocalDatasource - auto-registered by @LazySingleton in plant_tasks_local_datasource.dart
    // PlantTasksRemoteDatasource - auto-registered by @LazySingleton in plant_tasks_remote_datasource.dart
    // PlantTaskGenerator - auto-registered by @injectable in plant_task_generator.dart
  }
}
