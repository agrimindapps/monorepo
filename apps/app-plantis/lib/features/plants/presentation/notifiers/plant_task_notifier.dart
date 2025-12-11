import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../domain/entities/plant.dart';
import '../../domain/entities/plant_task.dart';
import '../../domain/repositories/plant_tasks_repository.dart';
import '../../domain/services/plant_task_generator.dart';

part 'plant_task_notifier.g.dart';

/// State para gerenciamento de tarefas de plantas
class PlantTaskState {
  final Map<String, List<PlantTask>> plantTasks;
  final bool isLoading;
  final String? errorMessage;

  const PlantTaskState({
    this.plantTasks = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  PlantTaskState copyWith({
    Map<String, List<PlantTask>>? plantTasks,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PlantTaskState(
      plantTasks: plantTasks ?? this.plantTasks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Notifier para gerenciamento de tarefas de plantas
@riverpod
class PlantTaskNotifier extends _$PlantTaskNotifier {
  late final PlantTaskGenerator _taskGenerationService;
  late final PlantTasksRepository? _repository;

  @override
  Future<PlantTaskState> build() async {
    _taskGenerationService = PlantTaskGenerator();
    _repository = ref.watch(plantTasksRepositoryProvider);

    return const PlantTaskState();
  }

  /// Get tasks for a specific plant
  List<PlantTask> getTasksForPlant(String plantId) {
    final currentState = state.value ?? const PlantTaskState();
    return currentState.plantTasks[plantId] ?? [];
  }

  /// Load tasks for a plant from repository
  Future<void> loadTasksForPlant(String plantId) async {
    if (_repository == null) {
      if (kDebugMode) {
        print('⚠️ PlantTaskNotifier: Repository not available');
      }
      return;
    }

    final currentState = state.value ?? const PlantTaskState();
    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      if (kDebugMode) {
        print('📥 PlantTaskNotifier: Loading tasks for plant $plantId');
      }

      final result = await _repository.getPlantTasksByPlantId(plantId);

      result.fold(
        (failure) {
          state = AsyncValue.data(
            currentState.copyWith(
              errorMessage: 'Erro ao carregar tarefas: ${failure.message}',
              isLoading: false,
            ),
          );
        },
        (tasks) {
          final updatedTasks = Map<String, List<PlantTask>>.from(
            currentState.plantTasks,
          );
          updatedTasks[plantId] = tasks;

          state = AsyncValue.data(
            currentState.copyWith(plantTasks: updatedTasks, isLoading: false),
          );

          if (kDebugMode) {
            print('✅ PlantTaskNotifier: ${tasks.length} tasks loaded');
          }
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          errorMessage: 'Erro inesperado: $e',
          isLoading: false,
        ),
      );
    }
  }

  /// Get pending tasks
  List<PlantTask> getPendingTasksForPlant(String plantId) {
    final tasks = getTasksForPlant(plantId);
    return _taskGenerationService.getPendingTasks(tasks);
  }

  /// Get upcoming tasks
  List<PlantTask> getUpcomingTasksForPlant(String plantId) {
    final tasks = getTasksForPlant(plantId);
    return _taskGenerationService.getUpcomingTasks(tasks);
  }

  /// Get overdue tasks
  List<PlantTask> getOverdueTasksForPlant(String plantId) {
    final tasks = getTasksForPlant(plantId);
    return _taskGenerationService.getOverdueTasks(tasks);
  }

  /// Get task summary
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

  /// Generate tasks for a plant
  Future<void> generateTasksForPlant(Plant plant) async {
    final currentState = state.value ?? const PlantTaskState();
    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      if (kDebugMode) {
        print('🌱 PlantTaskNotifier: Generating tasks for plant ${plant.id}');
      }

      final tasks = _taskGenerationService.generateTasksForPlant(plant);
      if (_repository != null && tasks.isNotEmpty) {
        final result = await _repository.addPlantTasks(tasks);

        result.fold(
          (failure) {
            state = AsyncValue.data(
              currentState.copyWith(
                errorMessage: 'Erro ao salvar tarefas: ${failure.message}',
                isLoading: false,
              ),
            );
          },
          (savedTasks) {
            final updatedTasks = Map<String, List<PlantTask>>.from(
              currentState.plantTasks,
            );
            updatedTasks[plant.id] = savedTasks;

            state = AsyncValue.data(
              currentState.copyWith(plantTasks: updatedTasks, isLoading: false),
            );

            _updateTaskStatuses(plant.id);
          },
        );
      } else {
        final updatedTasks = Map<String, List<PlantTask>>.from(
          currentState.plantTasks,
        );
        updatedTasks[plant.id] = tasks;

        state = AsyncValue.data(
          currentState.copyWith(plantTasks: updatedTasks, isLoading: false),
        );

        _updateTaskStatuses(plant.id);
      }
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          errorMessage: 'Erro ao gerar tarefas: $e',
          isLoading: false,
        ),
      );
    }
  }

  /// Toggle task completion
  Future<void> toggleTaskCompletion(String plantId, String taskId) async {
    try {
      final tasks = List<PlantTask>.from(getTasksForPlant(plantId));
      final taskIndex = tasks.indexWhere((t) => t.id == taskId);

      if (taskIndex == -1) {
        final currentState = state.value ?? const PlantTaskState();
        state = AsyncValue.data(
          currentState.copyWith(errorMessage: 'Tarefa não encontrada'),
        );
        return;
      }

      final task = tasks[taskIndex];

      if (task.isCompleted) {
        final pendingTask = task.copyWith(
          status: TaskStatus.pending,
          completedDate: null,
        );
        tasks[taskIndex] = pendingTask;

        if (_repository != null) {
          await _repository.updatePlantTask(pendingTask);
        }
      } else {
        final completedTask = task.markAsCompleted();
        tasks[taskIndex] = completedTask;

        if (_repository != null) {
          await _repository.updatePlantTask(completedTask);
        }
        final nextTask = _taskGenerationService.generateNextTask(
          completedTask,
          completionDate: DateTime.now(),
        );
        tasks.add(nextTask);

        if (_repository != null) {
          await _repository.addPlantTask(nextTask);
        }
      }

      final currentState = state.value ?? const PlantTaskState();
      final updatedTasks = Map<String, List<PlantTask>>.from(
        currentState.plantTasks,
      );
      updatedTasks[plantId] = tasks;

      state = AsyncValue.data(currentState.copyWith(plantTasks: updatedTasks));

      await _updateTaskStatuses(plantId);
    } catch (e) {
      final currentState = state.value ?? const PlantTaskState();
      state = AsyncValue.data(
        currentState.copyWith(errorMessage: 'Erro ao alterar status: $e'),
      );
    }
  }

  /// Complete task with date
  Future<void> completeTaskWithDate(
    String plantId,
    String taskId, {
    required DateTime completionDate,
    String? notes,
  }) async {
    try {
      final tasks = List<PlantTask>.from(getTasksForPlant(plantId));
      final taskIndex = tasks.indexWhere((t) => t.id == taskId);

      if (taskIndex == -1) {
        final currentState = state.value ?? const PlantTaskState();
        state = AsyncValue.data(
          currentState.copyWith(errorMessage: 'Tarefa não encontrada'),
        );
        return;
      }

      final task = tasks[taskIndex];
      final completedTask = task.copyWith(
        status: TaskStatus.completed,
        completedDate: completionDate,
      );

      tasks[taskIndex] = completedTask;

      if (_repository != null) {
        await _repository.updatePlantTask(completedTask);
      }
      final nextTask = _taskGenerationService.generateNextTask(
        completedTask,
        completionDate: completionDate,
      );
      tasks.add(nextTask);

      if (_repository != null) {
        await _repository.addPlantTask(nextTask);
      }

      final currentState = state.value ?? const PlantTaskState();
      final updatedTasks = Map<String, List<PlantTask>>.from(
        currentState.plantTasks,
      );
      updatedTasks[plantId] = tasks;

      state = AsyncValue.data(currentState.copyWith(plantTasks: updatedTasks));

      await _updateTaskStatuses(plantId);

      if (kDebugMode) {
        print('✅ PlantTaskNotifier: Task $taskId completed on $completionDate');
      }
    } catch (e) {
      final currentState = state.value ?? const PlantTaskState();
      state = AsyncValue.data(
        currentState.copyWith(errorMessage: 'Erro ao completar tarefa: $e'),
      );
    }
  }

  /// Delete task
  Future<void> deleteTask(String plantId, String taskId) async {
    try {
      final tasks = List<PlantTask>.from(getTasksForPlant(plantId));
      final taskIndex = tasks.indexWhere((t) => t.id == taskId);

      if (taskIndex == -1) {
        final currentState = state.value ?? const PlantTaskState();
        state = AsyncValue.data(
          currentState.copyWith(errorMessage: 'Tarefa não encontrada'),
        );
        return;
      }

      tasks.removeAt(taskIndex);

      final currentState = state.value ?? const PlantTaskState();
      final updatedTasks = Map<String, List<PlantTask>>.from(
        currentState.plantTasks,
      );
      updatedTasks[plantId] = tasks;

      state = AsyncValue.data(currentState.copyWith(plantTasks: updatedTasks));

      await _updateTaskStatuses(plantId);
    } catch (e) {
      final currentState = state.value ?? const PlantTaskState();
      state = AsyncValue.data(
        currentState.copyWith(errorMessage: 'Erro ao deletar tarefa: $e'),
      );
    }
  }

  /// Remove all tasks for a plant
  Future<void> removeTasksForPlant(String plantId) async {
    try {
      if (_repository != null) {
        await _repository.deletePlantTasksByPlantId(plantId);
      }

      final currentState = state.value ?? const PlantTaskState();
      final updatedTasks = Map<String, List<PlantTask>>.from(
        currentState.plantTasks,
      );
      updatedTasks.remove(plantId);

      state = AsyncValue.data(currentState.copyWith(plantTasks: updatedTasks));
    } catch (e) {
      final currentState = state.value ?? const PlantTaskState();
      state = AsyncValue.data(
        currentState.copyWith(errorMessage: 'Erro ao remover tarefas: $e'),
      );
    }
  }

  /// Update tasks when plant config changes
  Future<void> updateTasksForPlantConfig(Plant plant) async {
    try {
      final currentState = state.value ?? const PlantTaskState();
      state = AsyncValue.data(currentState.copyWith(isLoading: true));
      if (_repository != null) {
        await _repository.deletePlantTasksByPlantId(plant.id);
      }
      final updatedTasks = Map<String, List<PlantTask>>.from(
        currentState.plantTasks,
      );
      updatedTasks.remove(plant.id);

      state = AsyncValue.data(currentState.copyWith(plantTasks: updatedTasks));
      await generateTasksForPlant(plant);
    } catch (e) {
      final currentState = state.value ?? const PlantTaskState();
      state = AsyncValue.data(
        currentState.copyWith(
          errorMessage: 'Erro ao atualizar tarefas: $e',
          isLoading: false,
        ),
      );
    }
  }

  /// Get all upcoming tasks across all plants
  List<PlantTask> getAllUpcomingTasks() {
    final currentState = state.value ?? const PlantTaskState();
    final allTasks = <PlantTask>[];

    for (final tasks in currentState.plantTasks.values) {
      allTasks.addAll(_taskGenerationService.getUpcomingTasks(tasks));
    }

    return allTasks..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  /// Get all overdue tasks across all plants
  List<PlantTask> getAllOverdueTasks() {
    final currentState = state.value ?? const PlantTaskState();
    final allTasks = <PlantTask>[];

    for (final tasks in currentState.plantTasks.values) {
      allTasks.addAll(_taskGenerationService.getOverdueTasks(tasks));
    }

    return allTasks..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  /// Update task statuses for a plant
  Future<void> _updateTaskStatuses(String plantId) async {
    final tasks = getTasksForPlant(plantId);
    final updatedTasks = _taskGenerationService.updateTaskStatuses(tasks);

    final currentState = state.value ?? const PlantTaskState();
    final newTasks = Map<String, List<PlantTask>>.from(currentState.plantTasks);
    newTasks[plantId] = updatedTasks;

    state = AsyncValue.data(currentState.copyWith(plantTasks: newTasks));
  }

  /// Clear error
  void clearError() {
    final currentState = state.value ?? const PlantTaskState();
    state = AsyncValue.data(currentState.copyWith(errorMessage: null));
  }
}
