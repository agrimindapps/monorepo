import 'package:core/core.dart' hide Column, getIt;
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/plant.dart';
import '../../domain/entities/plant_task.dart';
import '../../domain/repositories/plant_tasks_repository.dart';
import '../../domain/services/plant_task_generator.dart';
import 'plants_providers.dart';

part 'plant_task_provider.freezed.dart';
part 'plant_task_provider.g.dart';

/// State for Plant Tasks
@freezed
class PlantTaskState with _$PlantTaskState {
  const factory PlantTaskState({
    @Default({}) Map<String, List<PlantTask>> plantTasks,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _PlantTaskState;

  const PlantTaskState._();

  bool get hasError => errorMessage != null;
}

/// Provider Riverpod para gerenciar tarefas das plantas
@riverpod
class PlantTaskNotifier extends _$PlantTaskNotifier {
  PlantTaskGenerator get _taskGenerationService =>
      ref.read(plantTaskGeneratorProvider);
  PlantTasksRepository? get _repository =>
      ref.read(plantTasksRepositoryProvider);

  @override
  PlantTaskState build() {
    ref.onDispose(() {
      // Cleanup resources if needed
    });

    return const PlantTaskState();
  }

  /// Gets all tasks for a specific plant
  List<PlantTask> getTasksForPlant(String plantId) {
    return state.plantTasks[plantId] ?? [];
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

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      if (kDebugMode) {
        print('📥 PlantTaskProvider: Carregando tasks para planta $plantId');
      }

      final result = await _repository!.getPlantTasksByPlantId(plantId);
      result.fold(
        (failure) {
          state = state.copyWith(
            errorMessage: 'Erro ao carregar tarefas: ${failure.message}',
            isLoading: false,
          );
          if (kDebugMode) {
            print(
              '❌ PlantTaskProvider: Erro ao carregar tasks: ${failure.message}',
            );
          }
        },
        (tasks) {
          final updatedTasks = Map<String, List<PlantTask>>.from(state.plantTasks);
          updatedTasks[plantId] = tasks;
          state = state.copyWith(
            plantTasks: updatedTasks,
            isLoading: false,
          );
          if (kDebugMode) {
            print(
              '✅ PlantTaskProvider: ${tasks.length} tasks carregadas para planta $plantId',
            );
          }
        },
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro inesperado ao carregar tarefas: $e',
        isLoading: false,
      );
      if (kDebugMode) {
        print('❌ PlantTaskProvider: Erro inesperado: $e');
      }
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
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      if (kDebugMode) {
        print('🌱 PlantTaskProvider: Gerando tasks para planta ${plant.id}');
      }

      final tasks = _taskGenerationService.generateTasksForPlant(plant);

      if (_repository != null && tasks.isNotEmpty) {
        if (kDebugMode) {
          print(
            '💾 PlantTaskProvider: Persistindo ${tasks.length} tasks geradas',
          );
        }

        final result = await _repository!.addPlantTasks(tasks);
        result.fold(
          (failure) {
            state = state.copyWith(
              errorMessage: 'Erro ao salvar tarefas: ${failure.message}',
              isLoading: false,
            );
            if (kDebugMode) {
              print(
                '❌ PlantTaskProvider: Erro ao persistir tasks: ${failure.message}',
              );
            }
          },
          (savedTasks) {
            final updatedTasks = Map<String, List<PlantTask>>.from(state.plantTasks);
            updatedTasks[plant.id] = savedTasks;
            state = state.copyWith(
              plantTasks: updatedTasks,
              isLoading: false,
            );
            if (kDebugMode) {
              print(
                '✅ PlantTaskProvider: ${savedTasks.length} tasks persistidas com sucesso',
              );
            }
          },
        );
      } else {
        final updatedTasks = Map<String, List<PlantTask>>.from(state.plantTasks);
        updatedTasks[plant.id] = tasks;
        state = state.copyWith(
          plantTasks: updatedTasks,
          isLoading: false,
        );
        if (kDebugMode) {
          print(
            '⚠️ PlantTaskProvider: Repository não disponível, tasks mantidas em memória',
          );
        }
      }

      await _updateTaskStatuses(plant.id);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao gerar tarefas: $e',
        isLoading: false,
      );
      if (kDebugMode) {
        print('❌ PlantTaskProvider: Erro ao gerar tasks: $e');
      }
    }
  }

  /// Toggles task completion status
  Future<void> toggleTaskCompletion(String plantId, String taskId) async {
    try {
      final tasks = List<PlantTask>.from(getTasksForPlant(plantId));
      final taskIndex = tasks.indexWhere((t) => t.id == taskId);

      if (taskIndex == -1) {
        state = state.copyWith(errorMessage: 'Tarefa não encontrada');
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
          await _repository!.updatePlantTask(pendingTask);
        }
      } else {
        final completedTask = task.markAsCompleted();
        tasks[taskIndex] = completedTask;
        if (_repository != null) {
          await _repository!.updatePlantTask(completedTask);
        }

        final nextTask = _taskGenerationService.generateNextTask(
          completedTask,
          completionDate: DateTime.now(),
        );
        tasks.add(nextTask);
        if (_repository != null) {
          await _repository!.addPlantTask(nextTask);
        }
      }

      final updatedTasks = Map<String, List<PlantTask>>.from(state.plantTasks);
      updatedTasks[plantId] = tasks;
      state = state.copyWith(plantTasks: updatedTasks);

      await _updateTaskStatuses(plantId);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao alterar status da tarefa: $e',
      );
      if (kDebugMode) {
        print('❌ PlantTaskProvider: Erro ao alterar status: $e');
      }
    }
  }

  /// Marks a task as completed and generates the next occurrence
  Future<void> completeTask(String plantId, String taskId) async {
    try {
      final tasks = List<PlantTask>.from(getTasksForPlant(plantId));
      final taskIndex = tasks.indexWhere((t) => t.id == taskId);

      if (taskIndex == -1) {
        state = state.copyWith(errorMessage: 'Tarefa não encontrada');
        return;
      }

      final task = tasks[taskIndex];
      final completedTask = task.markAsCompleted();
      tasks[taskIndex] = completedTask;

      final nextTask = _taskGenerationService.generateNextTask(
        completedTask,
        completionDate: DateTime.now(),
      );
      tasks.add(nextTask);

      final updatedTasks = Map<String, List<PlantTask>>.from(state.plantTasks);
      updatedTasks[plantId] = tasks;
      state = state.copyWith(plantTasks: updatedTasks);

      await _updateTaskStatuses(plantId);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro ao completar tarefa: $e');
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
      final tasks = List<PlantTask>.from(getTasksForPlant(plantId));
      final taskIndex = tasks.indexWhere((t) => t.id == taskId);

      if (taskIndex == -1) {
        state = state.copyWith(errorMessage: 'Tarefa não encontrada');
        return;
      }

      final task = tasks[taskIndex];
      final completedTask = task.copyWith(
        status: TaskStatus.completed,
        completedDate: completionDate,
      );
      tasks[taskIndex] = completedTask;

      if (_repository != null) {
        await _repository!.updatePlantTask(completedTask);
      }

      final nextTask = _taskGenerationService.generateNextTask(
        completedTask,
        completionDate: completionDate,
      );
      tasks.add(nextTask);

      if (_repository != null) {
        await _repository!.addPlantTask(nextTask);
      }

      final updatedTasks = Map<String, List<PlantTask>>.from(state.plantTasks);
      updatedTasks[plantId] = tasks;
      state = state.copyWith(plantTasks: updatedTasks);

      await _updateTaskStatuses(plantId);

      if (kDebugMode) {
        print(
          '✅ PlantTaskProvider: Tarefa $taskId concluída em ${completionDate.day}/${completionDate.month}/${completionDate.year}',
        );
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro ao completar tarefa: $e');
      if (kDebugMode) {
        print('❌ PlantTaskProvider: Erro ao completar tarefa com data: $e');
      }
    }
  }

  /// Deletes a task
  Future<void> deleteTask(String plantId, String taskId) async {
    try {
      final tasks = List<PlantTask>.from(getTasksForPlant(plantId));
      final taskIndex = tasks.indexWhere((t) => t.id == taskId);

      if (taskIndex == -1) {
        state = state.copyWith(errorMessage: 'Tarefa não encontrada');
        return;
      }

      tasks.removeAt(taskIndex);

      final updatedTasks = Map<String, List<PlantTask>>.from(state.plantTasks);
      updatedTasks[plantId] = tasks;
      state = state.copyWith(plantTasks: updatedTasks);

      await _updateTaskStatuses(plantId);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro ao deletar tarefa: $e');
    }
  }

  /// Updates all task statuses for a plant
  Future<void> _updateTaskStatuses(String plantId) async {
    final tasks = getTasksForPlant(plantId);
    final updatedTasks = _taskGenerationService.updateTaskStatuses(tasks);

    final updatedTasksMap = Map<String, List<PlantTask>>.from(state.plantTasks);
    updatedTasksMap[plantId] = updatedTasks;
    state = state.copyWith(plantTasks: updatedTasksMap);
  }

  /// Refreshes tasks for a plant (regenerates based on current config)
  Future<void> refreshTasksForPlant(Plant plant) async {
    await generateTasksForPlant(plant);
  }

  /// Gets all tasks for all plants (for dashboard/overview)
  Map<String, List<PlantTask>> get allPlantTasks =>
      Map.unmodifiable(state.plantTasks);

  /// Gets all upcoming tasks across all plants
  List<PlantTask> getAllUpcomingTasks() {
    final allTasks = <PlantTask>[];
    for (final tasks in state.plantTasks.values) {
      allTasks.addAll(_taskGenerationService.getUpcomingTasks(tasks));
    }
    return allTasks..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  /// Gets all overdue tasks across all plants
  List<PlantTask> getAllOverdueTasks() {
    final allTasks = <PlantTask>[];
    for (final tasks in state.plantTasks.values) {
      allTasks.addAll(_taskGenerationService.getOverdueTasks(tasks));
    }
    return allTasks..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  /// Clears error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Removes all tasks for a plant (when plant is deleted)
  Future<void> removeTasksForPlant(String plantId) async {
    try {
      if (_repository != null) {
        await _repository!.deletePlantTasksByPlantId(plantId);
        if (kDebugMode) {
          print(
            '✅ PlantTaskProvider: Tasks da planta $plantId removidas da persistência',
          );
        }
      }

      final updatedTasks = Map<String, List<PlantTask>>.from(state.plantTasks);
      updatedTasks.remove(plantId);
      state = state.copyWith(plantTasks: updatedTasks);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao remover tarefas da planta: $e',
      );
      if (kDebugMode) {
        print('❌ PlantTaskProvider: Erro ao remover tasks da planta: $e');
      }
    }
  }

  /// Updates tasks when plant configuration changes
  ///
  /// ✅ FIX: Deleta tarefas antigas do repositório (soft delete)
  /// para evitar tarefas órfãs/duplicadas
  Future<void> updateTasksForPlantConfig(Plant plant) async {
    try {
      state = state.copyWith(isLoading: true);

      if (_repository != null) {
        if (kDebugMode) {
          print(
            '🗑️ PlantTaskProvider: Deletando tarefas antigas da planta ${plant.id} antes de regenerar',
          );
        }
        await _repository!.deletePlantTasksByPlantId(plant.id);
        if (kDebugMode) {
          print('✅ PlantTaskProvider: Tarefas antigas deletadas (soft delete)');
        }
      }

      final updatedTasks = Map<String, List<PlantTask>>.from(state.plantTasks);
      updatedTasks.remove(plant.id);
      state = state.copyWith(plantTasks: updatedTasks);

      await generateTasksForPlant(plant);

      if (kDebugMode) {
        print(
          '✅ PlantTaskProvider: Tarefas regeneradas para planta ${plant.id}',
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao atualizar tarefas da planta: $e',
        isLoading: false,
      );
      if (kDebugMode) {
        print('❌ PlantTaskProvider: Erro ao atualizar tarefas: $e');
      }
    }
  }
}

// Dependency providers (to be defined in DI setup)
@riverpod
PlantTaskGenerator plantTaskGenerator(PlantTaskGeneratorRef ref) {
  return PlantTaskGenerator();
}

/// Type alias for backwards compatibility with existing code
/// Use PlantTaskNotifier instead in new code for type annotations
/// Use plantTaskNotifierProvider for accessing the provider
typedef PlantTaskProvider = PlantTaskNotifier;
