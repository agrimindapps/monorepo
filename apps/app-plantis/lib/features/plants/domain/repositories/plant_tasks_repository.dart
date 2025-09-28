import 'package:core/core.dart';

import '../entities/plant_task.dart';

abstract class PlantTasksRepository {
  Future<Either<Failure, List<PlantTask>>> getPlantTasks();
  Future<Either<Failure, List<PlantTask>>> getPlantTasksByPlantId(
    String plantId,
  );
  Future<Either<Failure, PlantTask>> getPlantTaskById(String id);
  Future<Either<Failure, PlantTask>> addPlantTask(PlantTask task);
  Future<Either<Failure, List<PlantTask>>> addPlantTasks(List<PlantTask> tasks);
  Future<Either<Failure, PlantTask>> updatePlantTask(PlantTask task);
  Future<Either<Failure, void>> deletePlantTask(String id);
  Future<Either<Failure, void>> deletePlantTasksByPlantId(String plantId);
  Future<Either<Failure, List<PlantTask>>> getPendingPlantTasks();
  Future<Either<Failure, List<PlantTask>>> getOverduePlantTasks();
  Future<Either<Failure, List<PlantTask>>> getTodayPlantTasks();
  Future<Either<Failure, List<PlantTask>>> getUpcomingPlantTasks();
  Future<Either<Failure, PlantTask>> completeTask(String id, {String? notes});
  Future<Either<Failure, void>> syncPendingChanges();
  Stream<List<PlantTask>> watchPlantTasks();
  Stream<List<PlantTask>> watchPlantTasksByPlantId(String plantId);
}
