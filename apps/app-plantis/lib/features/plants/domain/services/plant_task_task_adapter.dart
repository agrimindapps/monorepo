import 'package:flutter/foundation.dart';

import '../../../tasks/domain/entities/task.dart' as task_entity;
import '../entities/plant.dart';
import '../entities/plant_task.dart';

/// Adaptador para conectar PlantTasks com o sistema de Tasks existente
/// Elimina duplicação e mantém compatibilidade entre os dois sistemas
class PlantTaskTaskAdapter {
  /// Converte PlantTask para Task (sistema principal)
  static task_entity.Task plantTaskToTask(PlantTask plantTask) {
    final taskType = _mapPlantTaskTypeToTaskType(plantTask.type);
    final taskStatus = _mapPlantTaskStatusToTaskStatus(plantTask.status);
    final priority = _mapPlantTaskTypeToPriority(plantTask.type);

    return task_entity.Task(
      id: plantTask.id,
      createdAt: plantTask.createdAt,
      updatedAt: DateTime.now(),
      title: plantTask.title,
      description: plantTask.description ?? plantTask.type.description,
      plantId: plantTask.plantId,
      type: taskType,
      status: taskStatus,
      priority: priority,
      dueDate: plantTask.scheduledDate,
      isRecurring: true, // PlantTasks são sempre recorrentes
      recurringIntervalDays: plantTask.intervalDays,
      nextDueDate: plantTask.nextScheduledDate,
      completedAt: plantTask.completedDate,
    );
  }

  /// Converte Task para PlantTask (quando aplicável)
  static PlantTask? taskToPlantTask(task_entity.Task task) {
    if (!task.isRecurring) {
      return null;
    }

    final plantTaskType = _mapTaskTypeToPlantTaskType(task.type);
    if (plantTaskType == null) {
      return null;
    }

    final plantTaskStatus = _mapTaskStatusToPlantTaskStatus(task.status);

    return PlantTask(
      id: task.id,
      plantId: task.plantId,
      type: plantTaskType,
      title: task.title,
      description: task.description,
      scheduledDate: task.dueDate,
      completedDate: task.completedAt,
      status: plantTaskStatus,
      intervalDays: task.recurringIntervalDays ?? 7,
      createdAt: task.createdAt ?? DateTime.now(),
      nextScheduledDate: task.nextDueDate,
    );
  }

  /// Verifica se uma Task foi originalmente uma PlantTask
  static bool isTaskFromPlantTask(task_entity.Task task) {
    return task.isRecurring;
  }

  /// Mapeia tipo de PlantTask para tipo de Task
  static task_entity.TaskType _mapPlantTaskTypeToTaskType(
    TaskType plantTaskType,
  ) {
    switch (plantTaskType) {
      case TaskType.watering:
        return task_entity.TaskType.watering;
      case TaskType.fertilizing:
        return task_entity.TaskType.fertilizing;
      case TaskType.pruning:
        return task_entity.TaskType.pruning;
      case TaskType.sunlightCheck:
        return task_entity.TaskType.sunlight;
      case TaskType.pestInspection:
        return task_entity.TaskType.pestInspection;
      case TaskType.replanting:
        return task_entity.TaskType.repotting;
    }
  }

  /// Mapeia status de PlantTask para status de Task
  static task_entity.TaskStatus _mapPlantTaskStatusToTaskStatus(
    TaskStatus plantTaskStatus,
  ) {
    switch (plantTaskStatus) {
      case TaskStatus.pending:
        return task_entity.TaskStatus.pending;
      case TaskStatus.completed:
        return task_entity.TaskStatus.completed;
      case TaskStatus.overdue:
        return task_entity.TaskStatus.overdue;
    }
  }

  /// Mapeia status de Task para status de PlantTask
  static TaskStatus _mapTaskStatusToPlantTaskStatus(
    task_entity.TaskStatus taskStatus,
  ) {
    switch (taskStatus) {
      case task_entity.TaskStatus.pending:
        return TaskStatus.pending;
      case task_entity.TaskStatus.completed:
        return TaskStatus.completed;
      case task_entity.TaskStatus.overdue:
        return TaskStatus.overdue;
      case task_entity.TaskStatus.cancelled:
        return TaskStatus.pending; // Mapear para pending como fallback
    }
  }

  /// Mapeia tipo de PlantTask para prioridade de Task
  static task_entity.TaskPriority _mapPlantTaskTypeToPriority(
    TaskType plantTaskType,
  ) {
    switch (plantTaskType) {
      case TaskType.watering:
        return task_entity.TaskPriority.high; // Rega é crítica
      case TaskType.fertilizing:
        return task_entity.TaskPriority.medium;
      case TaskType.pruning:
        return task_entity.TaskPriority.low;
      case TaskType.sunlightCheck:
        return task_entity.TaskPriority.medium;
      case TaskType.pestInspection:
        return task_entity.TaskPriority.high; // Pragas são críticas
      case TaskType.replanting:
        return task_entity.TaskPriority.high; // Replantar é importante
    }
  }

  /// Mapeia TaskType para PlantTaskType
  static TaskType? _mapTaskTypeToPlantTaskType(task_entity.TaskType taskType) {
    switch (taskType) {
      case task_entity.TaskType.watering:
        return TaskType.watering;
      case task_entity.TaskType.fertilizing:
        return TaskType.fertilizing;
      case task_entity.TaskType.pruning:
        return TaskType.pruning;
      case task_entity.TaskType.sunlight:
        return TaskType.sunlightCheck;
      case task_entity.TaskType.pestInspection:
        return TaskType.pestInspection;
      case task_entity.TaskType.repotting:
        return TaskType.replanting;
      default:
        return null;
    }
  }

  /// Sincroniza PlantTasks com Tasks existentes
  /// Evita duplicação mantendo apenas a versão mais recente
  static List<task_entity.Task> mergePlantTasksWithTasks({
    required List<PlantTask> plantTasks,
    required List<task_entity.Task> existingTasks,
    required Map<String, Plant> plantsById,
  }) {
    final mergedTasks = <String, task_entity.Task>{};
    for (final task in existingTasks) {
      if (!isTaskFromPlantTask(task)) {
        mergedTasks[task.id] = task;
      }
    }
    for (final plantTask in plantTasks) {
      final task = plantTaskToTask(plantTask);
      mergedTasks[task.id] = task;
    }

    final result = mergedTasks.values.toList();

    if (kDebugMode) {
      print('🔄 PlantTaskTaskAdapter: Merge completed');
      print('   - ${plantTasks.length} PlantTasks convertidas');
      print(
        '   - ${existingTasks.where((t) => !isTaskFromPlantTask(t)).length} Tasks não-PlantTask mantidas',
      );
      print('   - ${result.length} Tasks totais no resultado');
    }

    return result;
  }

  /// Identifica conflitos entre PlantTasks e Tasks
  /// Retorna IDs de tasks que podem ter duplicação
  static List<String> findConflictingTaskIds({
    required List<PlantTask> plantTasks,
    required List<task_entity.Task> existingTasks,
  }) {
    final conflicts = <String>[];
    final plantTaskIds = plantTasks.map((pt) => pt.id).toSet();

    for (final task in existingTasks) {
      if (isTaskFromPlantTask(task) && plantTaskIds.contains(task.id)) {
        final plantTask = plantTasks.firstWhere((pt) => pt.id == task.id);
        final convertedTask = plantTaskToTask(plantTask);

        if (_hasSignificantDifferences(task, convertedTask)) {
          conflicts.add(task.id);
        }
      }
    }

    return conflicts;
  }

  /// Verifica se há diferenças significativas entre duas tasks
  static bool _hasSignificantDifferences(
    task_entity.Task task1,
    task_entity.Task task2,
  ) {
    return task1.title != task2.title ||
        task1.status != task2.status ||
        task1.dueDate != task2.dueDate ||
        task1.completedAt != task2.completedAt;
  }

  /// Gera relatório de migração/unificação
  static Map<String, dynamic> generateMigrationReport({
    required List<PlantTask> plantTasks,
    required List<task_entity.Task> existingTasks,
    required Map<String, Plant> plantsById,
  }) {
    final convertedTasks = plantTasks.length;
    final existingNonPlantTasks =
        existingTasks.where((t) => !isTaskFromPlantTask(t)).length;
    final existingPlantTasks =
        existingTasks.where((t) => isTaskFromPlantTask(t)).length;
    final conflicts = findConflictingTaskIds(
      plantTasks: plantTasks,
      existingTasks: existingTasks,
    );
    final plantsWithTasks = plantTasks.map((pt) => pt.plantId).toSet().length;
    final plantsFound = plantsById.length;

    return {
      'summary': {
        'plant_tasks_converted': convertedTasks,
        'existing_non_plant_tasks': existingNonPlantTasks,
        'existing_plant_tasks': existingPlantTasks,
        'conflicts_found': conflicts.length,
        'plants_with_tasks': plantsWithTasks,
        'plants_found': plantsFound,
      },
      'conflicts': conflicts,
      'migration_success': conflicts.isEmpty,
      'recommendations': _generateRecommendations(
        convertedTasks,
        existingNonPlantTasks,
        conflicts.length,
      ),
    };
  }

  /// Gera recomendações baseadas na análise
  static List<String> _generateRecommendations(
    int convertedTasks,
    int existingTasks,
    int conflicts,
  ) {
    final recommendations = <String>[];

    if (conflicts > 0) {
      recommendations.add(
        'Resolver $conflicts conflitos antes da migração completa',
      );
    }

    if (convertedTasks == 0) {
      recommendations.add(
        'Nenhuma PlantTask encontrada - verificar implementação da geração automática',
      );
    }

    if (existingTasks > 0) {
      recommendations.add('$existingTasks tasks existentes serão mantidas');
    }

    if (convertedTasks > 0 && conflicts == 0) {
      recommendations.add('Migração pode prosseguir sem problemas');
    }

    return recommendations;
  }
}
