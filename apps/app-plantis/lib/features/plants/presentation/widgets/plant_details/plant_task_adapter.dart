import '../../../../tasks/domain/entities/task.dart' as task_entity;
import '../../../domain/entities/plant_task.dart' as plant_task;

/// Adaptador para converter entre PlantTask e Task entities
///
/// Este adaptador permite reutilizar o TaskCompletionDialog (que espera Task)
/// com PlantTasks da plant details section, mantendo compatibilidade.
///
/// Implementação como mixin para evitar warning de classe sem instância.
mixin PlantTaskAdapter {
  /// Converte PlantTask para Task entity
  ///
  /// Necessário para usar TaskCompletionDialog que espera Task.
  /// Mapeia campos compatíveis e define valores padrão para campos específicos da Task.
  static task_entity.Task plantTaskToTask(
    plant_task.PlantTask plantTask,
    String plantName,
  ) {
    return task_entity.Task(
      id: plantTask.id,
      createdAt: plantTask.createdAt,
      updatedAt: DateTime.now(),
      title: plantTask.title,
      description: plantTask.description,
      plantId: plantTask.plantId,
      plantName: plantName,
      type: _mapTaskType(plantTask.type),
      status: _mapTaskStatus(plantTask.status),
      priority: _mapTaskPriority(plantTask.type),
      dueDate: plantTask.scheduledDate,
      completedAt: plantTask.completedDate,
      isRecurring: true,
      recurringIntervalDays: plantTask.intervalDays,
      nextDueDate: plantTask.nextScheduledDate,
    );
  }

  /// Mapeia TaskType de PlantTask para Task
  static task_entity.TaskType _mapTaskType(plant_task.TaskType plantTaskType) {
    switch (plantTaskType) {
      case plant_task.TaskType.watering:
        return task_entity.TaskType.watering;
      case plant_task.TaskType.fertilizing:
        return task_entity.TaskType.fertilizing;
      case plant_task.TaskType.pruning:
        return task_entity.TaskType.pruning;
      case plant_task.TaskType.sunlightCheck:
        return task_entity.TaskType.sunlight;
      case plant_task.TaskType.pestInspection:
        return task_entity.TaskType.pestInspection;
      case plant_task.TaskType.replanting:
        return task_entity.TaskType.repotting;
    }
  }

  /// Mapeia TaskStatus de PlantTask para Task
  static task_entity.TaskStatus _mapTaskStatus(
    plant_task.TaskStatus plantTaskStatus,
  ) {
    switch (plantTaskStatus) {
      case plant_task.TaskStatus.pending:
        return task_entity.TaskStatus.pending;
      case plant_task.TaskStatus.completed:
        return task_entity.TaskStatus.completed;
      case plant_task.TaskStatus.overdue:
        return task_entity.TaskStatus.overdue;
    }
  }

  /// Define prioridade baseada no tipo da tarefa
  ///
  /// Rega e inspeção de pragas são alta prioridade,
  /// outros tipos são média prioridade.
  static task_entity.TaskPriority _mapTaskPriority(
    plant_task.TaskType plantTaskType,
  ) {
    switch (plantTaskType) {
      case plant_task.TaskType.watering:
      case plant_task.TaskType.pestInspection:
        return task_entity.TaskPriority.high;
      case plant_task.TaskType.fertilizing:
      case plant_task.TaskType.pruning:
      case plant_task.TaskType.replanting:
        return task_entity.TaskPriority.medium;
      case plant_task.TaskType.sunlightCheck:
        return task_entity.TaskPriority.low;
    }
  }
}
