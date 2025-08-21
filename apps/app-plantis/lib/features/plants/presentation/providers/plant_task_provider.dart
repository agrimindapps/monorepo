import 'package:flutter/foundation.dart';
import '../../domain/entities/plant.dart';
import '../../domain/entities/plant_task.dart';
import '../../domain/services/task_generation_service.dart';

class PlantTaskProvider extends ChangeNotifier {
  final TaskGenerationService _taskGenerationService;

  PlantTaskProvider({TaskGenerationService? taskGenerationService})
    : _taskGenerationService = taskGenerationService ?? TaskGenerationService();

  // State
  final Map<String, List<PlantTask>> _plantTasks = {};
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// Gets all tasks for a specific plant
  List<PlantTask> getTasksForPlant(String plantId) {
    return _plantTasks[plantId] ?? [];
  }

  /// Gets pending tasks for a plant
  List<PlantTask> getPendingTasksForPlant(String plantId) {
    final tasks = getTasksForPlant(plantId);
    return _taskGenerationService.getPendingTasks(tasks);
  }

  /// Gets upcoming tasks for a plant (due today or within 2 days)
  List<PlantTask> getUpcomingTasksForPlant(String plantId) {
    final tasks = getTasksForPlant(plantId);
    return _taskGenerationService.getUpcomingTasks(tasks);
  }

  /// Gets overdue tasks for a plant
  List<PlantTask> getOverdueTasksForPlant(String plantId) {
    final tasks = getTasksForPlant(plantId);
    return _taskGenerationService.getOverdueTasks(tasks);
  }

  /// Gets task count summary for a plant
  Map<String, int> getTaskSummaryForPlant(String plantId) {
    final tasks = getTasksForPlant(plantId);
    final pending = _taskGenerationService.getPendingTasks(tasks);
    final upcoming = _taskGenerationService.getUpcomingTasks(tasks);
    final overdue = _taskGenerationService.getOverdueTasks(tasks);

    return {
      'total': tasks.length,
      'pending': pending.length,
      'upcoming': upcoming.length,
      'overdue': overdue.length,
      'completed': tasks.where((t) => t.status == TaskStatus.completed).length,
    };
  }

  /// Generates tasks for a plant based on its configuration
  Future<void> generateTasksForPlant(Plant plant) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final tasks = _taskGenerationService.generateTasksForPlant(plant);
      _plantTasks[plant.id] = tasks;

      // Update task statuses
      await _updateTaskStatuses(plant.id);
    } catch (e) {
      _errorMessage = 'Erro ao gerar tarefas: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggles task completion status
  Future<void> toggleTaskCompletion(String plantId, String taskId) async {
    try {
      final tasks = getTasksForPlant(plantId);
      final taskIndex = tasks.indexWhere((t) => t.id == taskId);

      if (taskIndex == -1) {
        _errorMessage = 'Tarefa não encontrada';
        notifyListeners();
        return;
      }

      final task = tasks[taskIndex];

      if (task.isCompleted) {
        // Mark as pending
        final pendingTask = task.copyWith(
          status: TaskStatus.pending,
          completedDate: null,
        );
        tasks[taskIndex] = pendingTask;
      } else {
        // Mark as completed
        final completedTask = task.markAsCompleted();
        tasks[taskIndex] = completedTask;

        // Generate next task
        final nextTask = _taskGenerationService.generateNextTask(completedTask);
        tasks.add(nextTask);
      }

      _plantTasks[plantId] = tasks;
      await _updateTaskStatuses(plantId);
    } catch (e) {
      _errorMessage = 'Erro ao alterar status da tarefa: $e';
      notifyListeners();
    }
  }

  /// Marks a task as completed and generates the next occurrence
  Future<void> completeTask(String plantId, String taskId) async {
    try {
      final tasks = getTasksForPlant(plantId);
      final taskIndex = tasks.indexWhere((t) => t.id == taskId);

      if (taskIndex == -1) {
        _errorMessage = 'Tarefa não encontrada';
        notifyListeners();
        return;
      }

      final task = tasks[taskIndex];
      final completedTask = task.markAsCompleted();

      // Update the current task
      tasks[taskIndex] = completedTask;

      // Generate next task
      final nextTask = _taskGenerationService.generateNextTask(completedTask);
      tasks.add(nextTask);

      _plantTasks[plantId] = tasks;

      // Update all task statuses
      await _updateTaskStatuses(plantId);
    } catch (e) {
      _errorMessage = 'Erro ao completar tarefa: $e';
      notifyListeners();
    }
  }

  /// Deletes a task
  Future<void> deleteTask(String plantId, String taskId) async {
    try {
      final tasks = getTasksForPlant(plantId);
      final taskIndex = tasks.indexWhere((t) => t.id == taskId);

      if (taskIndex == -1) {
        _errorMessage = 'Tarefa não encontrada';
        notifyListeners();
        return;
      }

      tasks.removeAt(taskIndex);
      _plantTasks[plantId] = tasks;

      await _updateTaskStatuses(plantId);
    } catch (e) {
      _errorMessage = 'Erro ao deletar tarefa: $e';
      notifyListeners();
    }
  }

  /// Updates all task statuses for a plant
  Future<void> _updateTaskStatuses(String plantId) async {
    final tasks = getTasksForPlant(plantId);
    final updatedTasks = _taskGenerationService.updateTaskStatuses(tasks);
    _plantTasks[plantId] = updatedTasks;
    notifyListeners();
  }

  /// Refreshes tasks for a plant (regenerates based on current config)
  Future<void> refreshTasksForPlant(Plant plant) async {
    await generateTasksForPlant(plant);
  }

  /// Gets all tasks for all plants (for dashboard/overview)
  Map<String, List<PlantTask>> get allPlantTasks =>
      Map.unmodifiable(_plantTasks);

  /// Gets all upcoming tasks across all plants
  List<PlantTask> getAllUpcomingTasks() {
    final allTasks = <PlantTask>[];
    for (final tasks in _plantTasks.values) {
      allTasks.addAll(_taskGenerationService.getUpcomingTasks(tasks));
    }
    return allTasks..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  /// Gets all overdue tasks across all plants
  List<PlantTask> getAllOverdueTasks() {
    final allTasks = <PlantTask>[];
    for (final tasks in _plantTasks.values) {
      allTasks.addAll(_taskGenerationService.getOverdueTasks(tasks));
    }
    return allTasks..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  /// Clears error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Removes all tasks for a plant (when plant is deleted)
  void removeTasksForPlant(String plantId) {
    _plantTasks.remove(plantId);
    notifyListeners();
  }

  /// Updates tasks when plant configuration changes
  Future<void> updateTasksForPlantConfig(Plant plant) async {
    // Remove existing tasks
    _plantTasks.remove(plant.id);

    // Generate new tasks based on updated config
    await generateTasksForPlant(plant);
  }
}
