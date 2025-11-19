import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../../database/repositories/tasks_drift_repository.dart';
import '../../../domain/entities/task.dart';
import '../../models/task_model.dart';

/// ============================================================================
/// TASKS LOCAL DATASOURCE - MIGRADO PARA DRIFT
/// ============================================================================
///
/// **MIGRAÇÃO STORAGE SERVICE → DRIFT (Fase 2):**
/// - Removido código ILocalStorageRepository
/// - Usa TasksDriftRepository para persistência
/// - Mantém interface pública idêntica (0 breaking changes)
/// - Lógica de filtragem (overdue, today, upcoming) preservada
/// ============================================================================

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

@LazySingleton(as: TasksLocalDataSource)
class TasksLocalDataSourceImpl implements TasksLocalDataSource {
  final TasksDriftRepository _driftRepo;

  TasksLocalDataSourceImpl(this._driftRepo);

  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      return await _driftRepo.getAllTasks();
    } catch (e) {
      throw CacheFailure('Erro ao buscar tarefas locais: $e');
    }
  }

  @override
  Future<List<TaskModel>> getTasksByPlantId(String plantId) async {
    try {
      return await _driftRepo.getTasksByPlant(plantId);
    } catch (e) {
      throw CacheFailure('Erro ao buscar tarefas por planta: $e');
    }
  }

  @override
  Future<List<TaskModel>> getTasksByStatus(TaskStatus status) async {
    try {
      if (status == TaskStatus.pending) {
        return await _driftRepo.getPendingTasks();
      }

      // Para outros status, filtrar manualmente
      final tasks = await getTasks();
      return tasks.where((task) => task.status == status).toList();
    } catch (e) {
      throw CacheFailure('Erro ao buscar tarefas por status: $e');
    }
  }

  @override
  Future<List<TaskModel>> getOverdueTasks() async {
    try {
      final tasks = await _driftRepo.getPendingTasks();
      final now = DateTime.now();

      return tasks
          .where((task) => task.dueDate.isBefore(now))
          .toList();
    } catch (e) {
      throw CacheFailure('Erro ao buscar tarefas atrasadas: $e');
    }
  }

  @override
  Future<List<TaskModel>> getTodayTasks() async {
    try {
      final tasks = await _driftRepo.getPendingTasks();
      final today = DateTime.now();

      return tasks
          .where(
            (task) =>
                task.dueDate.year == today.year &&
                task.dueDate.month == today.month &&
                task.dueDate.day == today.day,
          )
          .toList();
    } catch (e) {
      throw CacheFailure('Erro ao buscar tarefas de hoje: $e');
    }
  }

  @override
  Future<List<TaskModel>> getUpcomingTasks() async {
    try {
      final tasks = await _driftRepo.getPendingTasks();
      final now = DateTime.now();
      final nextWeek = now.add(const Duration(days: 7));

      return tasks
          .where(
            (task) =>
                task.dueDate.isAfter(now) &&
                task.dueDate.isBefore(nextWeek),
          )
          .toList();
    } catch (e) {
      throw CacheFailure('Erro ao buscar tarefas futuras: $e');
    }
  }

  @override
  Future<TaskModel?> getTaskById(String id) async {
    try {
      return await _driftRepo.getTaskById(id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheTask(TaskModel task) async {
    try {
      // Verifica se já existe
      final existing = await _driftRepo.getTaskById(task.id);

      if (existing != null) {
        await _driftRepo.updateTask(task);
      } else {
        await _driftRepo.insertTask(task);
      }
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('Plant not found locally')) {
        // Skip caching task until its plant is available locally
        if (kDebugMode) {
          print('⚠️ TasksLocalDataSource: Skipping task ${task.id} - ${task.title} because plant is not cached yet');
        }
        return;
      }
      throw CacheFailure('Erro ao cachear tarefa: $e');
    }
  }

  @override
  Future<void> cacheTasks(List<TaskModel> tasks) async {
    try {
      // Insert/update em batch
      for (final task in tasks) {
        await cacheTask(task);
      }
    } catch (e) {
      throw CacheFailure('Erro ao cachear tarefas: $e');
    }
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    try {
      await _driftRepo.updateTask(task);
    } catch (e) {
      throw CacheFailure('Erro ao atualizar tarefa: $e');
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      await _driftRepo.deleteTask(id);
    } catch (e) {
      throw CacheFailure('Erro ao deletar tarefa: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _driftRepo.clearAll();
    } catch (e) {
      throw CacheFailure('Erro ao limpar cache de tarefas: $e');
    }
  }
}
