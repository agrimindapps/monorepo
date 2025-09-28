import 'package:flutter/foundation.dart';
import '../../domain/entities/plant.dart';
import '../../domain/entities/plant_task.dart';
import '../../domain/repositories/plant_tasks_repository.dart';
import '../../domain/services/plant_task_generator.dart';

class PlantTaskProvider extends ChangeNotifier {
  final PlantTaskGenerator _taskGenerationService;
  final PlantTasksRepository? _repository;

  PlantTaskProvider({
    PlantTaskGenerator? taskGenerationService,
    PlantTasksRepository? repository,
  }) : _taskGenerationService = taskGenerationService ?? PlantTaskGenerator(),
       _repository = repository;

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

  /// Loads tasks for a plant from repository
  Future<void> loadTasksForPlant(String plantId) async {
    if (_repository == null) {
      if (kDebugMode) {
        print(
          '⚠️ PlantTaskProvider: Repository não disponível para carregar tasks',
        );
      }
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (kDebugMode) {
        print('📥 PlantTaskProvider: Carregando tasks para planta $plantId');
      }

      final result = await _repository.getPlantTasksByPlantId(plantId);
      result.fold(
        (failure) {
          _errorMessage = 'Erro ao carregar tarefas: ${failure.message}';
          if (kDebugMode) {
            print(
              '❌ PlantTaskProvider: Erro ao carregar tasks: ${failure.message}',
            );
          }
        },
        (tasks) {
          _plantTasks[plantId] = tasks;
          if (kDebugMode) {
            print(
              '✅ PlantTaskProvider: ${tasks.length} tasks carregadas para planta $plantId',
            );
          }
        },
      );
    } catch (e) {
      _errorMessage = 'Erro inesperado ao carregar tarefas: $e';
      if (kDebugMode) {
        print('❌ PlantTaskProvider: Erro inesperado: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
      if (kDebugMode) {
        print('🌱 PlantTaskProvider: Gerando tasks para planta ${plant.id}');
      }

      final tasks = _taskGenerationService.generateTasksForPlant(plant);

      // CRÍTICO: Persistir tasks geradas se repository disponível
      if (_repository != null && tasks.isNotEmpty) {
        if (kDebugMode) {
          print(
            '💾 PlantTaskProvider: Persistindo ${tasks.length} tasks geradas',
          );
        }

        final result = await _repository.addPlantTasks(tasks);
        result.fold(
          (failure) {
            _errorMessage = 'Erro ao salvar tarefas: ${failure.message}';
            if (kDebugMode) {
              print(
                '❌ PlantTaskProvider: Erro ao persistir tasks: ${failure.message}',
              );
            }
          },
          (savedTasks) {
            _plantTasks[plant.id] = savedTasks;
            if (kDebugMode) {
              print(
                '✅ PlantTaskProvider: ${savedTasks.length} tasks persistidas com sucesso',
              );
            }
          },
        );
      } else {
        // Fallback para comportamento anterior se repository não disponível
        _plantTasks[plant.id] = tasks;
        if (kDebugMode) {
          print(
            '⚠️ PlantTaskProvider: Repository não disponível, tasks mantidas em memória',
          );
        }
      }

      // Update task statuses
      await _updateTaskStatuses(plant.id);
    } catch (e) {
      _errorMessage = 'Erro ao gerar tarefas: $e';
      if (kDebugMode) {
        print('❌ PlantTaskProvider: Erro ao gerar tasks: $e');
      }
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

        // CRÍTICO: Atualizar na persistência
        if (_repository != null) {
          await _repository.updatePlantTask(pendingTask);
        }
      } else {
        // Mark as completed
        final completedTask = task.markAsCompleted();
        tasks[taskIndex] = completedTask;

        // CRÍTICO: Atualizar na persistência
        if (_repository != null) {
          await _repository.updatePlantTask(completedTask);
        }

        // Generate next task
        final nextTask = _taskGenerationService.generateNextTask(completedTask);
        tasks.add(nextTask);

        // CRÍTICO: Salvar nova task na persistência
        if (_repository != null) {
          await _repository.addPlantTask(nextTask);
        }
      }

      _plantTasks[plantId] = tasks;
      await _updateTaskStatuses(plantId);
    } catch (e) {
      _errorMessage = 'Erro ao alterar status da tarefa: $e';
      if (kDebugMode) {
        print('❌ PlantTaskProvider: Erro ao alterar status: $e');
      }
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

  /// Marks a task as completed with specific completion date and notes
  Future<void> completeTaskWithDate(
    String plantId,
    String taskId, {
    required DateTime completionDate,
    String? notes,
  }) async {
    try {
      final tasks = getTasksForPlant(plantId);
      final taskIndex = tasks.indexWhere((t) => t.id == taskId);

      if (taskIndex == -1) {
        _errorMessage = 'Tarefa não encontrada';
        notifyListeners();
        return;
      }

      final task = tasks[taskIndex];

      // Mark as completed with specific date
      final completedTask = task.copyWith(
        status: TaskStatus.completed,
        completedDate: completionDate,
        // Note: PlantTask doesn't have notes field, but we could extend it if needed
      );

      // Update the current task
      tasks[taskIndex] = completedTask;

      // CRÍTICO: Atualizar na persistência se disponível
      if (_repository != null) {
        await _repository.updatePlantTask(completedTask);
      }

      // Generate next task based on completion date
      final nextTask = _taskGenerationService.generateNextTask(completedTask);
      tasks.add(nextTask);

      // CRÍTICO: Salvar nova task na persistência se disponível
      if (_repository != null) {
        await _repository.addPlantTask(nextTask);
      }

      _plantTasks[plantId] = tasks;

      // Update all task statuses
      await _updateTaskStatuses(plantId);

      if (kDebugMode) {
        print(
          '✅ PlantTaskProvider: Tarefa $taskId concluída em ${completionDate.day}/${completionDate.month}/${completionDate.year}',
        );
      }
    } catch (e) {
      _errorMessage = 'Erro ao completar tarefa: $e';
      if (kDebugMode) {
        print('❌ PlantTaskProvider: Erro ao completar tarefa com data: $e');
      }
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
  Future<void> removeTasksForPlant(String plantId) async {
    try {
      // CRÍTICO: Remover da persistência
      if (_repository != null) {
        await _repository.deletePlantTasksByPlantId(plantId);
        if (kDebugMode) {
          print(
            '✅ PlantTaskProvider: Tasks da planta $plantId removidas da persistência',
          );
        }
      }

      _plantTasks.remove(plantId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao remover tarefas da planta: $e';
      if (kDebugMode) {
        print('❌ PlantTaskProvider: Erro ao remover tasks da planta: $e');
      }
      notifyListeners();
    }
  }

  /// Updates tasks when plant configuration changes
  Future<void> updateTasksForPlantConfig(Plant plant) async {
    // Remove existing tasks
    _plantTasks.remove(plant.id);

    // Generate new tasks based on updated config
    await generateTasksForPlant(plant);
  }
}
