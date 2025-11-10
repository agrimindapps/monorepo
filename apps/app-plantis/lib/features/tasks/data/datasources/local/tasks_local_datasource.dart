import 'package:core/core.dart' hide Column;

import '../../../../../core/constants/plantis_environment_config.dart';
import '../../../domain/entities/task.dart';
import '../../models/task_model.dart';

abstract class TasksLocalDataSource {
  Future<List<TaskModel>> getTasks();
  Future<List<TaskModel>> getTasksByPlantId(String plantId);
  Future<List<TaskModel>> getTasksByStatus(TaskStatus status);
  Future<List<TaskModel>> getOverdueTasks();
  Future<List<TaskModel>> getTodayTasks();
  Future<List<TaskModel>> getUpcomingTasks();
  Future<TaskModel?> getTaskById(String id);
  Future<void> cacheTask(TaskModel task);
  Future<void> cacheTasks(List<TaskModel> tasks);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
  Future<void> clearCache();
}

class TasksLocalDataSourceImpl implements TasksLocalDataSource {
  final ILocalStorageRepository storageService;
  static const String _boxName = PlantisBoxes.tasks;

  TasksLocalDataSourceImpl(this.storageService);

  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      final result = await storageService.get<List<dynamic>>(
        key: 'all_tasks',
        box: _boxName,
      );

      return result.fold((failure) => <TaskModel>[], (tasksData) {
        if (tasksData == null) return <TaskModel>[];

        return tasksData
            .map<TaskModel>((data) {
              final Map<String, dynamic> taskMap = Map<String, dynamic>.from(
                data as Map,
              );
              return TaskModel.fromJson(taskMap);
            })
            .where((task) => !task.isDeleted)
            .toList();
      });
    } catch (e) {
      throw Exception('Erro ao buscar tarefas locais: $e');
    }
  }

  @override
  Future<List<TaskModel>> getTasksByPlantId(String plantId) async {
    final tasks = await getTasks();
    return tasks.where((task) => task.plantId == plantId).toList();
  }

  @override
  Future<List<TaskModel>> getTasksByStatus(TaskStatus status) async {
    final tasks = await getTasks();
    return tasks.where((task) => task.status == status).toList();
  }

  @override
  Future<List<TaskModel>> getOverdueTasks() async {
    final tasks = await getTasks();
    final now = DateTime.now();

    return tasks
        .where(
          (task) =>
              task.status == TaskStatus.pending && task.dueDate.isBefore(now),
        )
        .toList();
  }

  @override
  Future<List<TaskModel>> getTodayTasks() async {
    final tasks = await getTasks();
    final today = DateTime.now();

    return tasks
        .where(
          (task) =>
              task.status == TaskStatus.pending &&
              task.dueDate.year == today.year &&
              task.dueDate.month == today.month &&
              task.dueDate.day == today.day,
        )
        .toList();
  }

  @override
  Future<List<TaskModel>> getUpcomingTasks() async {
    final tasks = await getTasks();
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));

    return tasks
        .where(
          (task) =>
              task.status == TaskStatus.pending &&
              task.dueDate.isAfter(now) &&
              task.dueDate.isBefore(nextWeek),
        )
        .toList();
  }

  @override
  Future<TaskModel?> getTaskById(String id) async {
    try {
      final tasks = await getTasks();
      return tasks.firstWhere(
        (task) => task.id == id,
        orElse: () => throw StateError('Task not found'),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheTask(TaskModel task) async {
    try {
      final tasks = await getTasks();
      final existingIndex = tasks.indexWhere((t) => t.id == task.id);

      if (existingIndex >= 0) {
        tasks[existingIndex] = task;
      } else {
        tasks.add(task);
      }

      await _saveTasks(tasks);
    } catch (e) {
      throw Exception('Erro ao cachear tarefa: $e');
    }
  }

  @override
  Future<void> cacheTasks(List<TaskModel> tasks) async {
    try {
      final taskMaps = tasks.map((task) => task.toJson()).toList();

      final result = await storageService.save<List<Map<String, dynamic>>>(
        key: 'all_tasks',
        data: taskMaps,
        box: _boxName,
      );

      result.fold(
        (failure) =>
            throw Exception('Erro ao salvar tarefas: ${failure.message}'),
        (_) => <String, dynamic>{},
      );
    } catch (e) {
      throw Exception('Erro ao cachear tarefas: $e');
    }
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    await cacheTask(task);
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      final tasks = await getTasks();
      final taskIndex = tasks.indexWhere((t) => t.id == id);

      if (taskIndex >= 0) {
        final updatedTask = tasks[taskIndex].copyWith(
          isDeleted: true,
          isDirty: true,
          updatedAt: DateTime.now(),
        );
        tasks[taskIndex] = updatedTask;
        await _saveTasks(tasks);
      }
    } catch (e) {
      throw Exception('Erro ao deletar tarefa: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final result = await storageService.remove(
        key: 'all_tasks',
        box: _boxName,
      );

      result.fold(
        (failure) =>
            throw Exception('Erro ao limpar cache: ${failure.message}'),
        (_) => <String, dynamic>{},
      );
    } catch (e) {
      throw Exception('Erro ao limpar cache de tarefas: $e');
    }
  }

  Future<void> _saveTasks(List<TaskModel> tasks) async {
    final taskMaps = tasks.map((task) => task.toJson()).toList();

    final result = await storageService.save<List<Map<String, dynamic>>>(
      key: 'all_tasks',
      data: taskMaps,
      box: _boxName,
    );

    result.fold(
      (failure) =>
          throw Exception('Erro ao salvar tarefas: ${failure.message}'),
      (_) => <String, dynamic>{},
    );
  }
}
