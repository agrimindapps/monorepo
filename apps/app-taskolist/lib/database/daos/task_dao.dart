import 'dart:convert';

import 'package:drift/drift.dart';

import '../../features/tasks/data/task_model.dart';
import '../../features/tasks/domain/task_entity.dart';
import '../tables/tasks_table.dart';
import '../taskolist_database.dart';

part 'task_dao.g.dart';

@DriftAccessor(tables: [Tasks])
class TaskDao extends DatabaseAccessor<TaskolistDatabase> with _$TaskDaoMixin {
  TaskDao(super.db);

  // ========================================================================
  // READ OPERATIONS
  // ========================================================================

  /// Get task by Firebase ID
  Future<TaskModel?> getTaskByFirebaseId(String firebaseId) async {
    final result = await (select(tasks)
          ..where((tbl) => tbl.firebaseId.equals(firebaseId)))
        .getSingleOrNull();

    return result != null ? _taskDataToModel(result) : null;
  }

  /// Get all tasks with optional filters
  Future<List<TaskModel>> getTasks({
    String? listId,
    String? userId,
    TaskStatus? status,
    TaskPriority? priority,
    bool? isStarred,
  }) async {
    final query = select(tasks)
      ..where((tbl) => tbl.isDeleted.equals(false));

    // Apply filters
    if (listId != null) {
      query.where((tbl) => tbl.listId.equals(listId));
    }
    if (userId != null) {
      query.where((tbl) =>
          tbl.createdById.equals(userId) | tbl.assignedToId.equals(userId));
    }
    if (status != null) {
      query.where((tbl) => tbl.status.equals(status.index));
    }
    if (priority != null) {
      query.where((tbl) => tbl.priority.equals(priority.index));
    }
    if (isStarred != null) {
      query.where((tbl) => tbl.isStarred.equals(isStarred));
    }

    // Order by position
    query.orderBy([(t) => OrderingTerm.asc(t.position)]);

    final results = await query.get();
    return results.map(_taskDataToModel).toList();
  }

  /// Watch tasks with filters (real-time updates)
  Stream<List<TaskModel>> watchTasks({
    String? listId,
    String? userId,
    TaskStatus? status,
    TaskPriority? priority,
    bool? isStarred,
  }) {
    final query = select(tasks)
      ..where((tbl) => tbl.isDeleted.equals(false));

    if (listId != null) {
      query.where((tbl) => tbl.listId.equals(listId));
    }
    if (userId != null) {
      query.where((tbl) =>
          tbl.createdById.equals(userId) | tbl.assignedToId.equals(userId));
    }
    if (status != null) {
      query.where((tbl) => tbl.status.equals(status.index));
    }
    if (priority != null) {
      query.where((tbl) => tbl.priority.equals(priority.index));
    }
    if (isStarred != null) {
      query.where((tbl) => tbl.isStarred.equals(isStarred));
    }

    query.orderBy([(t) => OrderingTerm.asc(t.position)]);

    return query.watch().map((results) => results.map(_taskDataToModel).toList());
  }

  // ========================================================================
  // WRITE OPERATIONS
  // ========================================================================

  /// Insert or update task
  Future<void> upsertTask(TaskModel task) async {
    await into(tasks).insertOnConflictUpdate(_modelToTaskData(task));
  }

  /// Batch insert/update tasks
  Future<void> upsertTasks(List<TaskModel> taskList) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(
        tasks,
        taskList.map(_modelToTaskData).toList(),
      );
    });
  }

  /// Update task
  Future<bool> updateTask(TaskModel task) async {
    final count = await (update(tasks)
          ..where((tbl) => tbl.firebaseId.equals(task.id)))
        .write(_modelToTaskData(task));
    return count > 0;
  }

  /// Delete task (soft delete)
  Future<bool> deleteTask(String firebaseId) async {
    final count = await (update(tasks)
          ..where((tbl) => tbl.firebaseId.equals(firebaseId)))
        .write(
      TasksCompanion(
        isDeleted: const Value(true),
        isDirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return count > 0;
  }

  /// Hard delete task (permanent)
  Future<int> hardDeleteTask(String firebaseId) {
    return (delete(tasks)..where((tbl) => tbl.firebaseId.equals(firebaseId)))
        .go();
  }

  /// Clear all tasks
  Future<void> clearAllTasks() async {
    await delete(tasks).go();
  }

  // ========================================================================
  // HELPER QUERIES
  // ========================================================================

  /// Get task count
  Future<int> getTaskCount({String? listId, String? userId}) async {
    final count = countAll();
    final query = selectOnly(tasks)..addColumns([count]);

    query.where(tasks.isDeleted.equals(false));

    if (listId != null) {
      query.where(tasks.listId.equals(listId));
    }
    if (userId != null) {
      query.where(
          tasks.createdById.equals(userId) | tasks.assignedToId.equals(userId));
    }

    final result = await query.getSingleOrNull();
    return result?.read(count) ?? 0;
  }

  /// Get completed task count
  Future<int> getCompletedTaskCount({String? listId, String? userId}) async {
    final count = countAll();
    final query = selectOnly(tasks)..addColumns([count]);

    query.where(
        tasks.isDeleted.equals(false) & tasks.status.equals(TaskStatus.completed.index));

    if (listId != null) {
      query.where(tasks.listId.equals(listId));
    }
    if (userId != null) {
      query.where(
          tasks.createdById.equals(userId) | tasks.assignedToId.equals(userId));
    }

    final result = await query.getSingleOrNull();
    return result?.read(count) ?? 0;
  }

  /// Get overdue tasks
  Future<List<TaskModel>> getOverdueTasks({
    String? listId,
    String? userId,
  }) async {
    final now = DateTime.now();
    final query = select(tasks)
      ..where((tbl) =>
          tbl.isDeleted.equals(false) &
          tbl.dueDate.isSmallerThanValue(now) &
          tbl.status.isNotValue(TaskStatus.completed.index) &
          tbl.status.isNotValue(TaskStatus.cancelled.index));

    if (listId != null) {
      query.where((tbl) => tbl.listId.equals(listId));
    }
    if (userId != null) {
      query.where((tbl) =>
          tbl.createdById.equals(userId) | tbl.assignedToId.equals(userId));
    }

    final results = await query.get();
    return results.map(_taskDataToModel).toList();
  }

  /// Get tasks by tag
  Future<List<TaskModel>> getTasksByTag(String tag, {String? listId}) async {
    final allTasks = await getTasks(listId: listId);
    return allTasks.where((task) => task.tags.contains(tag)).toList();
  }

  // ========================================================================
  // CONVERTERS
  // ========================================================================

  /// Convert TaskData to TaskModel
  TaskModel _taskDataToModel(TaskData data) {
    return TaskModel(
      id: data.firebaseId,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      lastSyncAt: data.lastSyncAt,
      isDirty: data.isDirty,
      isDeleted: data.isDeleted,
      version: data.version,
      userId: data.userId,
      moduleName: data.moduleName,
      title: data.title,
      description: data.description,
      listId: data.listId,
      createdById: data.createdById,
      assignedToId: data.assignedToId,
      dueDate: data.dueDate,
      reminderDate: data.reminderDate,
      status: TaskStatus.values[data.status],
      priority: TaskPriority.values[data.priority],
      isStarred: data.isStarred,
      position: data.position,
      tags: (jsonDecode(data.tags) as List<dynamic>).cast<String>(),
      parentTaskId: data.parentTaskId,
      notes: data.notes,
    );
  }

  /// Convert TaskModel to TasksCompanion
  TasksCompanion _modelToTaskData(TaskModel model) {
    return TasksCompanion.insert(
      firebaseId: model.id,
      userId: Value(model.userId),
      moduleName: Value(model.moduleName),
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      lastSyncAt: Value(model.lastSyncAt),
      isDirty: Value(model.isDirty),
      isDeleted: Value(model.isDeleted),
      version: Value(model.version),
      title: model.title,
      description: Value(model.description),
      listId: model.listId,
      createdById: model.createdById,
      assignedToId: Value(model.assignedToId),
      dueDate: Value(model.dueDate),
      reminderDate: Value(model.reminderDate),
      status: Value(model.status.index),
      priority: Value(model.priority.index),
      isStarred: Value(model.isStarred),
      position: Value(model.position),
      tags: Value(jsonEncode(model.tags)),
      parentTaskId: Value(model.parentTaskId),
      notes: Value(model.notes),
    );
  }
}
