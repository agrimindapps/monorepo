import 'package:core/core.dart' hide Column;
import 'package:injectable/injectable.dart';

import '../../features/plants/data/models/plant_task_model.dart';
import '../../features/plants/domain/entities/plant_task.dart';
import '../plantis_database.dart' as db;

/// Repository Drift para PlantTasks (sistema legado de cuidados)
@lazySingleton
class PlantTasksDriftRepository {
  final db.PlantisDatabase _db;

  PlantTasksDriftRepository(this._db);

  Future<int> insertPlantTask(PlantTaskModel model) async {
    final localPlantId = await _resolvePlantId(model.plantId);

    final companion = db.PlantTasksCompanion.insert(
      firebaseId: Value(model.id),
      plantId: localPlantId ?? 0,
      type: model.type.name,
      title: model.title,
      description: Value(model.description),
      scheduledDate: model.scheduledDate,
      completedDate: Value(model.completedDate),
      status: model.status.name,
      intervalDays: model.intervalDays,
      nextScheduledDate: Value(model.nextScheduledDate),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt ?? DateTime.now()),
      isDirty: Value(model.isDirty),
      isDeleted: Value(model.isDeleted),
    );

    return await _db.into(_db.plantTasks).insert(companion);
  }

  Future<List<PlantTaskModel>> getAllPlantTasks() async {
    final tasks =
        await (_db.select(_db.plantTasks)
              ..where((t) => t.isDeleted.equals(false))
              ..orderBy([(t) => OrderingTerm(expression: t.scheduledDate)]))
            .get();

    return tasks.map(_taskDriftToModel).toList();
  }

  Future<List<PlantTaskModel>> getPendingPlantTasks() async {
    final tasks =
        await (_db.select(_db.plantTasks)
              ..where(
                (t) => t.isDeleted.equals(false) & t.completedDate.isNull(),
              )
              ..orderBy([(t) => OrderingTerm(expression: t.scheduledDate)]))
            .get();

    return tasks.map(_taskDriftToModel).toList();
  }

  Future<bool> completePlantTask(String firebaseId) async {
    final updated =
        await (_db.update(
          _db.plantTasks,
        )..where((t) => t.firebaseId.equals(firebaseId))).write(
          db.PlantTasksCompanion(
            completedDate: Value(DateTime.now()),
            status: const Value('completed'),
            isDirty: const Value(true),
            updatedAt: Value(DateTime.now()),
          ),
        );

    return updated > 0;
  }

  /// Get plant task by firebaseId
  Future<PlantTaskModel?> getPlantTaskById(String firebaseId) async {
    final task = await (_db.select(
      _db.plantTasks,
    )..where((t) => t.firebaseId.equals(firebaseId))).getSingleOrNull();

    return task != null ? _taskDriftToModel(task) : null;
  }

  /// Get plant tasks by plant's firebaseId
  Future<List<PlantTaskModel>> getPlantTasksByPlantId(
    String plantFirebaseId,
  ) async {
    final localPlantId = await _resolvePlantId(plantFirebaseId);
    if (localPlantId == null) return [];

    final tasks =
        await (_db.select(_db.plantTasks)
              ..where(
                (t) =>
                    t.plantId.equals(localPlantId) & t.isDeleted.equals(false),
              )
              ..orderBy([(t) => OrderingTerm(expression: t.scheduledDate)]))
            .get();

    return tasks.map(_taskDriftToModel).toList();
  }

  /// Update plant task
  Future<bool> updatePlantTask(PlantTaskModel model) async {
    final localPlantId = await _resolvePlantId(model.plantId);

    final updated =
        await (_db.update(
          _db.plantTasks,
        )..where((t) => t.firebaseId.equals(model.id))).write(
          db.PlantTasksCompanion(
            plantId: Value(localPlantId ?? 0),
            type: Value(model.type.name),
            title: Value(model.title),
            description: Value(model.description),
            scheduledDate: Value(model.scheduledDate),
            completedDate: Value(model.completedDate),
            status: Value(model.status.name),
            intervalDays: Value(model.intervalDays),
            nextScheduledDate: Value(model.nextScheduledDate),
            updatedAt: Value(model.updatedAt ?? DateTime.now()),
            isDirty: Value(model.isDirty),
            isDeleted: Value(model.isDeleted),
          ),
        );

    return updated > 0;
  }

  /// Delete plant task (soft delete)
  Future<bool> deletePlantTask(String firebaseId) async {
    final updated =
        await (_db.update(
          _db.plantTasks,
        )..where((t) => t.firebaseId.equals(firebaseId))).write(
          db.PlantTasksCompanion(
            isDeleted: const Value(true),
            isDirty: const Value(true),
            updatedAt: Value(DateTime.now()),
          ),
        );

    return updated > 0;
  }

  /// Delete all plant tasks by plant's firebaseId
  Future<int> deletePlantTasksByPlantId(String plantFirebaseId) async {
    final localPlantId = await _resolvePlantId(plantFirebaseId);
    if (localPlantId == null) return 0;

    return await (_db.update(
      _db.plantTasks,
    )..where((t) => t.plantId.equals(localPlantId))).write(
      db.PlantTasksCompanion(
        isDeleted: const Value(true),
        isDirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Clear all plant tasks (for testing/reset)
  Future<int> clearAll() async {
    return await _db.delete(_db.plantTasks).go();
  }

  Stream<List<PlantTaskModel>> watchPendingPlantTasks() {
    return (_db.select(_db.plantTasks)
          ..where((t) => t.isDeleted.equals(false) & t.completedDate.isNull())
          ..orderBy([(t) => OrderingTerm(expression: t.scheduledDate)]))
        .watch()
        .map((tasks) => tasks.map(_taskDriftToModel).toList());
  }

  PlantTaskModel _taskDriftToModel(db.PlantTask task) {
    // Parse TaskType from string
    final taskType = TaskType.values.firstWhere(
      (e) => e.name == task.type,
      orElse: () => TaskType.watering,
    );

    // Parse TaskStatus from string
    final taskStatus = TaskStatus.values.firstWhere(
      (e) => e.name == task.status,
      orElse: () => TaskStatus.pending,
    );

    return PlantTaskModel(
      id: task.firebaseId ?? task.id.toString(),
      plantId: task.plantId.toString(),
      type: taskType,
      title: task.title,
      description: task.description,
      scheduledDate: task.scheduledDate,
      completedDate: task.completedDate,
      status: taskStatus,
      intervalDays: task.intervalDays,
      createdAt: task.createdAt ?? DateTime.now(),
      nextScheduledDate: task.nextScheduledDate,
      updatedAt: task.updatedAt,
      isDirty: task.isDirty,
      isDeleted: task.isDeleted,
    );
  }

  Future<int?> _resolvePlantId(String? plantFirebaseId) async {
    if (plantFirebaseId == null) return null;
    final asInt = int.tryParse(plantFirebaseId);
    if (asInt != null) return asInt;

    final plant = await (_db.select(
      _db.plants,
    )..where((p) => p.firebaseId.equals(plantFirebaseId))).getSingleOrNull();
    return plant?.id;
  }
}
