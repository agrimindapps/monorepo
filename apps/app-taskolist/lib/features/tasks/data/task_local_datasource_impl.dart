import 'dart:async';

import 'package:core/core.dart';

import '../domain/task_entity.dart';
import 'task_local_datasource.dart';
import 'task_model.dart';

@LazySingleton(as: TaskLocalDataSource)
class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  static const String _boxName = 'tasks';
  Box<TaskModel>? _box;
  final StreamController<List<TaskModel>> _taskStreamController =
      StreamController<List<TaskModel>>.broadcast();

  Future<Box<TaskModel>> get _taskBox async {
    _box ??= await Hive.openBox<TaskModel>(_boxName);
    return _box!;
  }

  @override
  Future<void> cacheTask(TaskModel task) async {
    final box = await _taskBox;
    await box.put(task.id, task);
    _notifyListeners();
  }

  @override
  Future<void> cacheTasks(List<TaskModel> tasks) async {
    final box = await _taskBox;
    final taskMap = {for (TaskModel task in tasks) task.id: task};
    await box.putAll(taskMap);
    _notifyListeners();
  }

  @override
  Future<TaskModel?> getTask(String id) async {
    final box = await _taskBox;
    return box.get(id);
  }

  @override
  Future<List<TaskModel>> getTasks({
    String? listId,
    String? userId,
    TaskStatus? status,
    TaskPriority? priority,
    bool? isStarred,
  }) async {
    final box = await _taskBox;
    var tasks = box.values.toList();
    if (listId != null) {
      tasks = tasks.where((task) => task.listId == listId).toList();
    }

    if (userId != null) {
      tasks =
          tasks
              .where(
                (task) =>
                    task.createdById == userId || task.assignedToId == userId,
              )
              .toList();
    }

    if (status != null) {
      tasks = tasks.where((task) => task.status == status).toList();
    }

    if (priority != null) {
      tasks = tasks.where((task) => task.priority == priority).toList();
    }

    if (isStarred != null) {
      tasks = tasks.where((task) => task.isStarred == isStarred).toList();
    }
    tasks.sort((a, b) => a.position.compareTo(b.position));

    return tasks;
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    final box = await _taskBox;
    await box.put(task.id, task);
    _notifyListeners();
  }

  @override
  Future<void> deleteTask(String id) async {
    final box = await _taskBox;
    await box.delete(id);
    _notifyListeners();
  }

  @override
  Future<void> clearCache() async {
    final box = await _taskBox;
    await box.clear();
    _notifyListeners();
  }

  @override
  Stream<List<TaskModel>> watchTasks({
    String? listId,
    String? userId,
    TaskStatus? status,
    TaskPriority? priority,
    bool? isStarred,
  }) {
    getTasks(
      listId: listId,
      userId: userId,
      status: status,
      priority: priority,
      isStarred: isStarred,
    ).then((tasks) {
      if (!_taskStreamController.isClosed) {
        _taskStreamController.add(tasks);
      }
    });
    return _taskStreamController.stream.asyncMap((_) async {
      return await getTasks(
        listId: listId,
        userId: userId,
        status: status,
        priority: priority,
        isStarred: isStarred,
      );
    });
  }

  void _notifyListeners() {
    if (!_taskStreamController.isClosed) {
      getTasks().then((tasks) {
        _taskStreamController.add(tasks);
      });
    }
  }

  Future<void> dispose() async {
    await _taskStreamController.close();
    await _box?.close();
  }
  Future<int> getTaskCount({String? listId, String? userId}) async {
    final tasks = await getTasks(listId: listId, userId: userId);
    return tasks.length;
  }

  Future<int> getCompletedTaskCount({String? listId, String? userId}) async {
    final tasks = await getTasks(
      listId: listId,
      userId: userId,
      status: TaskStatus.completed,
    );
    return tasks.length;
  }

  Future<List<TaskModel>> getOverdueTasks({
    String? listId,
    String? userId,
  }) async {
    final tasks = await getTasks(listId: listId, userId: userId);
    final now = DateTime.now();

    return tasks
        .where(
          (task) =>
              task.dueDate != null &&
              task.dueDate!.isBefore(now) &&
              task.status != TaskStatus.completed &&
              task.status != TaskStatus.cancelled,
        )
        .toList();
  }

  Future<List<TaskModel>> getTasksByTag(String tag, {String? listId}) async {
    final tasks = await getTasks(listId: listId);
    return tasks.where((task) => task.tags.contains(tag)).toList();
  }
}
