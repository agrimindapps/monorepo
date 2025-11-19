import 'package:drift/drift.dart';
import 'package:core/core.dart' hide Column;
import 'package:injectable/injectable.dart';

import '../../features/tasks/data/models/task_model.dart';
import '../../features/tasks/domain/entities/task.dart';
import '../plantis_database.dart' as db;

/// ============================================================================
/// TASKS DRIFT REPOSITORY
/// ============================================================================
///
/// Repository Drift para gerenciar tarefas do sistema novo.
///
/// **DIFERENÇA vs PlantTasks:**
/// - Tasks: Sistema novo, completo, com status/prioridade
/// - PlantTasks: Sistema legado, apenas cuidados de plantas
/// ============================================================================

@lazySingleton
class TasksDriftRepository {
  final db.PlantisDatabase _db;

  TasksDriftRepository(this._db);

  // ==================== CREATE ====================

  Future<int> insertTask(TaskModel model) async {
    final localPlantId = await _resolvePlantId(model.plantId);

    if (localPlantId == null) {
      throw StateError('Plant not found locally for id: ${model.plantId}');
    }

    final companion = db.TasksCompanion.insert(
      firebaseId: Value(model.id),
      title: model.title,
      description: Value(model.description),
      type: model.type.key,
      status: Value(model.status.key),
      priority: Value(model.priority.key),
      dueDate: model.dueDate,
      completedAt: Value(model.completedAt),
      plantId: localPlantId,
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
      isDirty: Value(model.isDirty),
      isDeleted: Value(model.isDeleted),
    );

    return await _db.into(_db.tasks).insert(companion);
  }

  // ==================== READ ====================

  Future<List<TaskModel>> getAllTasks() async {
    final tasks =
        await (_db.select(_db.tasks)
              ..where((t) => t.isDeleted.equals(false))
              ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
            .get();

    return tasks.map(_taskDriftToModel).toList();
  }

  Future<TaskModel?> getTaskById(String firebaseId) async {
    final task = await (_db.select(
      _db.tasks,
    )..where((t) => t.firebaseId.equals(firebaseId))).getSingleOrNull();

    return task != null ? _taskDriftToModel(task) : null;
  }

  Future<List<TaskModel>> getPendingTasks() async {
    final tasks =
        await (_db.select(_db.tasks)
              ..where(
                (t) => t.isDeleted.equals(false) & t.status.equals('pending'),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
            .get();

    return tasks.map(_taskDriftToModel).toList();
  }

  Future<List<TaskModel>> getTasksByPlant(String plantFirebaseId) async {
    final localPlantId = await _resolvePlantId(plantFirebaseId);
    if (localPlantId == null) return [];

    final tasks =
        await (_db.select(_db.tasks)
              ..where(
                (t) =>
                    t.plantId.equals(localPlantId) & t.isDeleted.equals(false),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
            .get();

    return tasks.map(_taskDriftToModel).toList();
  }

  // ==================== UPDATE ====================

  Future<bool> updateTask(TaskModel model) async {
    final localId = await _getLocalIdByFirebaseId(model.id);
    if (localId == null) return false;

    final localPlantId = await _resolvePlantId(model.plantId);

    final companion = db.TasksCompanion(
      id: Value(localId),
      title: Value(model.title),
      description: Value(model.description),
      type: Value(model.type.key),
      status: Value(model.status.key),
      priority: Value(model.priority.key),
      dueDate: Value(model.dueDate),
      completedAt: Value(model.completedAt),
      plantId: localPlantId != null ? Value(localPlantId) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
      isDirty: Value(model.isDirty),
      isDeleted: Value(model.isDeleted),
    );

    final updated = await (_db.update(
      _db.tasks,
    )..where((t) => t.id.equals(localId))).write(companion);

    return updated > 0;
  }

  Future<bool> completeTask(String firebaseId) async {
    final updated =
        await (_db.update(
          _db.tasks,
        )..where((t) => t.firebaseId.equals(firebaseId))).write(
          db.TasksCompanion(
            status: Value('completed'),
            completedAt: Value(DateTime.now()),
            isDirty: Value(true),
            updatedAt: Value(DateTime.now()),
          ),
        );

    return updated > 0;
  }

  // ==================== DELETE ====================

  Future<bool> deleteTask(String firebaseId) async {
    final updated =
        await (_db.update(
          _db.tasks,
        )..where((t) => t.firebaseId.equals(firebaseId))).write(
          db.TasksCompanion(
            isDeleted: Value(true),
            isDirty: Value(true),
            updatedAt: Value(DateTime.now()),
          ),
        );

    return updated > 0;
  }

  Future<void> clearAll() async {
    await _db.delete(_db.tasks).go();
  }

  // ==================== STREAMS ====================

  Stream<List<TaskModel>> watchTasks() {
    return (_db.select(_db.tasks)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
        .watch()
        .map((tasks) => tasks.map(_taskDriftToModel).toList());
  }

  Stream<List<TaskModel>> watchPendingTasks() {
    return (_db.select(_db.tasks)
          ..where((t) =>
              t.isDeleted.equals(false) & t.status.equals('pending'))
          ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
        .watch()
        .map((tasks) => tasks.map(_taskDriftToModel).toList());
  }

  // ==================== SYNC HELPERS ====================

  Future<List<TaskModel>> getDirtyTasks() async {
    final tasks = await (_db.select(
      _db.tasks,
    )..where((t) => t.isDirty.equals(true))).get();

    return tasks.map(_taskDriftToModel).toList();
  }

  Future<void> markAsSynced(String firebaseId) async {
    await (_db.update(
      _db.tasks,
    )..where((t) => t.firebaseId.equals(firebaseId))).write(
      db.TasksCompanion(
        isDirty: Value(false),
        lastSyncAt: Value(DateTime.now()),
      ),
    );
  }

  // ==================== CONVERTERS ====================

  TaskModel _taskDriftToModel(db.Task task) {
    // Parse TaskType from string
    final taskType = TaskType.values.firstWhere(
      (e) => e.key == task.type,
      orElse: () => TaskType.custom,
    );

    // Parse TaskStatus from string
    final taskStatus = TaskStatus.values.firstWhere(
      (e) => e.key == task.status,
      orElse: () => TaskStatus.pending,
    );

    // Parse TaskPriority from string
    final taskPriority = TaskPriority.values.firstWhere(
      (e) => e.key == task.priority,
      orElse: () => TaskPriority.medium,
    );

    return TaskModel(
      id: task.firebaseId ?? task.id.toString(),
      title: task.title,
      description: task.description,
      type: taskType,
      status: taskStatus,
      priority: taskPriority,
      dueDate: task.dueDate,
      completedAt: task.completedAt,
      plantId: task.plantId.toString(),
      createdAt: task.createdAt ?? DateTime.now(),
      updatedAt: task.updatedAt ?? DateTime.now(),
      lastSyncAt: task.lastSyncAt,
      isDirty: task.isDirty,
      isDeleted: task.isDeleted,
      version: task.version,
      userId: task.userId,
      moduleName: task.moduleName,
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

  Future<int?> _getLocalIdByFirebaseId(String firebaseId) async {
    final task = await (_db.select(
      _db.tasks,
    )..where((t) => t.firebaseId.equals(firebaseId))).getSingleOrNull();

    return task?.id;
  }

  // ==================== STATISTICS ====================

  Future<int> countPendingTasks() async {
    final count = countAll();
    final query = _db.selectOnly(_db.tasks)
      ..addColumns([count])
      ..where(
        _db.tasks.isDeleted.equals(false) & _db.tasks.status.equals('pending'),
      );

    return query.map((row) => row.read(count)!).getSingle();
  }

  Future<int> countCompletedTasks() async {
    final count = countAll();
    final query = _db.selectOnly(_db.tasks)
      ..addColumns([count])
      ..where(
        _db.tasks.isDeleted.equals(false) &
            _db.tasks.status.equals('completed'),
      );

    return query.map((row) => row.read(count)!).getSingle();
  }
}
