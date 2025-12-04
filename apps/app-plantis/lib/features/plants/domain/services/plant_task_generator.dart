import 'dart:math';

import '../entities/plant.dart';
import '../entities/plant_task.dart';

class PlantTaskGenerator {
  static const String _taskIdPrefix = 'task_';

  /// Generates tasks for a plant based on its care configuration
  List<PlantTask> generateTasksForPlant(Plant plant) {
    final tasks = <PlantTask>[];
    final config = plant.config;

    if (config == null) return tasks;

    final plantingDate =
        plant.plantingDate ?? plant.createdAt ?? DateTime.now();
    final now = DateTime.now();
    if (config.hasWateringSchedule) {
      final wateringTask = _generateTask(
        plantId: plant.id,
        type: TaskType.watering,
        intervalDays: config.wateringIntervalDays!,
        plantingDate: plantingDate,
        currentDate: now,
      );
      tasks.add(wateringTask);
    }
    if (config.hasFertilizingSchedule) {
      final fertilizingTask = _generateTask(
        plantId: plant.id,
        type: TaskType.fertilizing,
        intervalDays: config.fertilizingIntervalDays!,
        plantingDate: plantingDate,
        currentDate: now,
      );
      tasks.add(fertilizingTask);
    }
    if (config.hasPruningSchedule) {
      final pruningTask = _generateTask(
        plantId: plant.id,
        type: TaskType.pruning,
        intervalDays: config.pruningIntervalDays!,
        plantingDate: plantingDate,
        currentDate: now,
      );
      tasks.add(pruningTask);
    }
    if (config.hasSunlightCheckSchedule) {
      final sunlightTask = _generateTask(
        plantId: plant.id,
        type: TaskType.sunlightCheck,
        intervalDays: config.sunlightCheckIntervalDays!,
        plantingDate: plantingDate,
        currentDate: now,
      );
      tasks.add(sunlightTask);
    }
    if (config.hasPestInspectionSchedule) {
      final pestTask = _generateTask(
        plantId: plant.id,
        type: TaskType.pestInspection,
        intervalDays: config.pestInspectionIntervalDays!,
        plantingDate: plantingDate,
        currentDate: now,
      );
      tasks.add(pestTask);
    }
    if (config.hasReplantingSchedule) {
      final replantingTask = _generateTask(
        plantId: plant.id,
        type: TaskType.replanting,
        intervalDays: config.replantingIntervalDays!,
        plantingDate: plantingDate,
        currentDate: now,
      );
      tasks.add(replantingTask);
    }

    return tasks;
  }

  /// Generates the next task for a completed task
  ///
  /// [completedTask] - A tarefa que foi concluída
  /// [completionDate] - Data REAL de conclusão (importante para tarefas atrasadas)
  ///
  /// Se [completionDate] não for fornecido, usa DateTime.now()
  ///
  /// ✅ FIX: Calcula próxima tarefa baseado em completionDate real,
  /// não em nextScheduledDate (que pode estar no passado se tarefa atrasada)
  /// 
  /// Se [customNextDueDate] for informado, usa essa data em vez de calcular
  PlantTask generateNextTask(
    PlantTask completedTask, {
    DateTime? completionDate,
    DateTime? customNextDueDate,
  }) {
    // Se o usuário informou uma data customizada, usa ela
    final nextScheduledDate = customNextDueDate ??
        (completionDate ?? DateTime.now()).add(
          Duration(days: completedTask.intervalDays),
        );

    return PlantTask(
      id: _generateTaskId(),
      plantId: completedTask.plantId,
      type: completedTask.type,
      title: completedTask.title,
      description: completedTask.description,
      scheduledDate: nextScheduledDate,
      status: TaskStatus.pending,
      intervalDays: completedTask.intervalDays,
      createdAt: DateTime.now(),
    );
  }

  /// Updates task statuses based on current date
  List<PlantTask> updateTaskStatuses(List<PlantTask> tasks) {
    return tasks.map((task) => task.updateStatus()).toList();
  }

  /// Gets tasks that are due soon (today or within 2 days)
  List<PlantTask> getUpcomingTasks(List<PlantTask> tasks) {
    return tasks
        .where((task) => task.status != TaskStatus.completed)
        .where((task) => task.isDueToday || task.isDueSoon)
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  /// Gets overdue tasks
  List<PlantTask> getOverdueTasks(List<PlantTask> tasks) {
    return tasks.where((task) => task.status == TaskStatus.overdue).toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  /// Gets all pending tasks sorted by date
  List<PlantTask> getPendingTasks(List<PlantTask> tasks) {
    return tasks.where((task) => task.status == TaskStatus.pending).toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  /// Private method to generate a single task
  PlantTask _generateTask({
    required String plantId,
    required TaskType type,
    required int intervalDays,
    required DateTime plantingDate,
    required DateTime currentDate,
  }) {
    final daysSincePlanting = currentDate.difference(plantingDate).inDays;
    final cyclesSincePlanting = (daysSincePlanting / intervalDays).floor();
    final nextScheduledDate = plantingDate.add(
      Duration(days: (cyclesSincePlanting + 1) * intervalDays),
    );
    final scheduledDate =
        nextScheduledDate.isBefore(currentDate)
            ? currentDate
            : nextScheduledDate;

    final task = PlantTask(
      id: _generateTaskId(),
      plantId: plantId,
      type: type,
      title: type.displayName,
      description: type.description,
      scheduledDate: scheduledDate,
      status: TaskStatus.pending,
      intervalDays: intervalDays,
      createdAt: currentDate,
    );

    return task.updateStatus();
  }

  /// Generates a unique task ID
  String _generateTaskId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999);
    return '$_taskIdPrefix${timestamp}_$random';
  }
}
