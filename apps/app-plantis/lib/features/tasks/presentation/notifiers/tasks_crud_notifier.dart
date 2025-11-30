import 'dart:async';

import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

import '../../../../core/auth/auth_state_notifier.dart';
import '../../domain/entities/task.dart' as task_entity;
import '../../domain/services/task_filter_service.dart';
import '../../domain/services/task_ownership_validator.dart';
import '../../domain/usecases/add_task_usecase.dart';
import '../../domain/usecases/complete_task_usecase.dart';
import '../../domain/usecases/get_task_by_id_usecase.dart';
import '../providers/tasks_providers.dart';
import '../providers/tasks_state.dart';

part 'tasks_crud_notifier.g.dart';

/// TasksCrudNotifier - Handles CREATE, READ, UPDATE, DELETE operations
///
/// Responsibilities (SRP):
/// - addTask() - Add new task with offline support
/// - completeTask() - Complete task with ownership validation
/// - deleteTask() - Delete task (future implementation)
/// - getTaskById() - Retrieve single task
///
/// Does NOT handle:
/// - Listing, filtering, searching (see TasksQueryNotifier)
/// - Recurring/scheduling (see TasksScheduleNotifier)
/// - Recommendations (see TasksRecommendationNotifier)
@riverpod
class TasksCrudNotifier extends _$TasksCrudNotifier {
  late final AddTaskUseCase _addTaskUseCase;
  late final CompleteTaskUseCase _completeTaskUseCase;
  late final GetTaskByIdUseCase _getTaskByIdUseCase;
  late final AuthStateNotifier _authStateNotifier;
  late final ITaskOwnershipValidator _ownershipValidator;
  late final ITaskFilterService _filterService;

  @override
  TasksState build() {
    _addTaskUseCase = ref.read(addTaskUseCaseProvider);
    _completeTaskUseCase = ref.read(completeTaskUseCaseProvider);
    _getTaskByIdUseCase = ref.read(getTaskByIdUseCaseProvider);
    _authStateNotifier = AuthStateNotifier.instance;
    _ownershipValidator = ref.read(taskOwnershipValidatorProvider);
    _filterService = ref.read(taskFilterServiceProvider);

    return TasksStateX.initial();
  }

  /// Adds a new task with offline support
  Future<bool> addTask(task_entity.Task task) async {
    try {
      final currentUser = _authStateNotifier.currentUser;
      if (currentUser == null) {
        _updateState(
          (current) => current.copyWith(
            errorMessage: 'Você deve estar autenticado para criar tarefas',
          ),
        );
        return false;
      }

      final taskWithUser = task.withUserId(currentUser.id);
      final result = await _addTaskUseCase(AddTaskParams(task: taskWithUser));

      return result.fold(
        (failure) {
          if (_isNetworkFailure(failure)) {
            _addOptimisticTask(taskWithUser);
            return true;
          } else {
            _updateState(
              (current) => current.copyWith(errorMessage: failure.userMessage),
            );
            return false;
          }
        },
        (addedTask) {
          _addTaskToState(addedTask);
          return true;
        },
      );
    } catch (e) {
      debugPrint('❌ TasksCrudNotifier.addTask error: $e');
      return false;
    }
  }

  /// Completes a task with ownership validation
  Future<bool> completeTask(String taskId, {String? notes}) async {
    try {
      final task = await _getTaskWithOwnershipValidation(taskId);
      final result = await _completeTaskUseCase(
        CompleteTaskParams(taskId: taskId, notes: notes),
      );

      return result.fold(
        (failure) {
          if (_isNetworkFailure(failure)) {
            _completeTaskOptimistically(task, notes);
            return true;
          } else {
            _updateState(
              (current) => current.copyWith(errorMessage: failure.userMessage),
            );
            return false;
          }
        },
        (completedTask) {
          _updateTaskInState(completedTask);
          return true;
        },
      );
    } on UnauthorizedAccessException catch (e) {
      _updateState((current) => current.copyWith(errorMessage: e.message));
      return false;
    } catch (e) {
      debugPrint('❌ TasksCrudNotifier.completeTask error: $e');
      return false;
    }
  }

  /// Helper: Get task with ownership validation
  Future<task_entity.Task> _getTaskWithOwnershipValidation(
      String taskId) async {
    final currentState = state;

    // 1. Try to find in local state first (fastest)
    final localTask = currentState.allTasks
        .whereType<task_entity.Task>()
        .cast<task_entity.Task?>()
        .firstWhere(
          (t) => t?.id == taskId,
          orElse: () => null,
        );

    if (localTask != null) {
      _ownershipValidator.validateOwnershipOrThrow(localTask);
      return localTask;
    }

    // 2. If not found locally, fetch from repository
    final result = await _getTaskByIdUseCase(taskId);

    return result.fold(
      (failure) => throw Exception('Task not found: $taskId'),
      (task) {
        _ownershipValidator.validateOwnershipOrThrow(task);
        return task;
      },
    );
  }

  /// Helper: Add optimistic task for offline support
  void _addOptimisticTask(task_entity.Task task) {
    final optimisticTask = task.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      isDirty: true,
    );
    _addTaskToState(optimisticTask);
  }

  /// Helper: Add task to current state
  void _addTaskToState(task_entity.Task task) {
    final currentState = state;
    final updatedTasks = List<task_entity.Task>.from(currentState.allTasks)
      ..add(task);
    final filteredTasks = _applyCurrentFilters(updatedTasks);

    _updateState(
      (current) => current.copyWith(
        allTasks: updatedTasks,
        filteredTasks: filteredTasks,
        errorMessage: null,
      ),
    );
  }

  /// Helper: Update task in state
  void _updateTaskInState(task_entity.Task task) {
    final currentState = state;
    final updatedTasks = currentState.allTasks
        .whereType<task_entity.Task>()
        .map((t) => t.id == task.id ? task : t)
        .toList();

    final filteredTasks = _applyCurrentFilters(updatedTasks);

    _updateState(
      (current) => current.copyWith(
        allTasks: updatedTasks,
        filteredTasks: filteredTasks,
        errorMessage: null,
      ),
    );
  }

  /// Helper: Complete task optimistically
  void _completeTaskOptimistically(
    task_entity.Task task,
    String? notes,
  ) {
    final completedTask = task.copyWithTaskData(
      status: task_entity.TaskStatus.completed,
      completedAt: DateTime.now(),
      completionNotes: notes,
    );
    _updateTaskInState(completedTask);
  }

  /// Helper: Apply current filters to task list
  List<task_entity.Task> _applyCurrentFilters(
    List<task_entity.Task> tasks,
  ) {
    final currentState = state;
    return _filterService.applyFilters(
      tasks,
      currentState.currentFilter,
      currentState.searchQuery,
      currentState.selectedPlantId,
      currentState.selectedTaskTypes,
      currentState.selectedPriorities,
    );
  }

  /// Helper: Update state
  void _updateState(TasksState Function(TasksState current) update) {
    state = update(state);
  }

  /// Helper: Check if failure is network-related
  bool _isNetworkFailure(Failure failure) {
    return failure is NetworkFailure ||
        failure.toString().contains('NetworkException');
  }
}

// LEGACY ALIAS
// ignore: deprecated_member_use_from_same_package
const tasksCrudNotifierProvider = tasksCrudProvider;
