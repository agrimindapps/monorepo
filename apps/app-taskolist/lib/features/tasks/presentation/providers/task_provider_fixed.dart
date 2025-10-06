import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../domain/create_task.dart';
import '../../domain/delete_task.dart';
import '../../domain/get_tasks.dart';
import '../../domain/reorder_tasks.dart';
import '../../domain/task_entity.dart';
import '../../domain/update_task.dart';
import '../../domain/watch_tasks.dart';

/// TaskNotifier com correções para race conditions e memory leaks
class TaskNotifierFixed extends StateNotifier<AsyncValue<List<TaskEntity>>> {
  TaskNotifierFixed({
    required CreateTask createTask,
    required DeleteTask deleteTask,
    required GetTasks getTasks,
    required ReorderTasks reorderTasks,
    required UpdateTask updateTask,
    required WatchTasks watchTasks,
  }) : _createTask = createTask,
       _deleteTask = deleteTask,
       _getTasks = getTasks,
       _reorderTasks = reorderTasks,
       _updateTask = updateTask,
       _watchTasks = watchTasks,
       super(const AsyncValue.loading());

  final CreateTask _createTask;
  final DeleteTask _deleteTask;
  final GetTasks _getTasks;
  final ReorderTasks _reorderTasks;
  final UpdateTask _updateTask;
  final WatchTasks _watchTasks;
  StreamSubscription<List<TaskEntity>>? _watchSubscription;
  bool _isCreating = false;
  bool _isReordering = false;
  final Set<String> _operationsInProgress = {};
  final Map<String, Completer<void>> _pendingOperations = {};

  Future<void> getTasks({
    String? listId,
    String? userId,
    TaskStatus? status,
    TaskPriority? priority,
    bool? isStarred,
  }) async {
    state = const AsyncValue.loading();

    final result = await _getTasks(
      GetTasksParams(
        listId: listId,
        userId: userId,
        status: status,
        priority: priority,
        isStarred: isStarred,
      ),
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (tasks) => state = AsyncValue.data(tasks),
    );
  }

  Future<void> createTask(TaskEntity task) async {
    if (_isCreating) {
      throw StateError('Task creation already in progress');
    }
    if (_operationsInProgress.contains(task.id)) {
      throw StateError('Operation already in progress for task ${task.id}');
    }

    _isCreating = true;
    _operationsInProgress.add(task.id);

    try {
      final result = await _createTask(CreateTaskParams(task: task));

      result.fold(
        (failure) {
          if (state.hasValue) {
            _notifyError(failure);
          } else {
            state = AsyncValue.error(failure, StackTrace.current);
          }
        },
        (taskId) {
          final updatedTask = task.copyWith(id: taskId);
          if (state.hasValue) {
            final currentTasks = List<TaskEntity>.from(state.value!);
            currentTasks.add(updatedTask);
            currentTasks.sort((a, b) => (b.position).compareTo(a.position));

            state = AsyncValue.data(currentTasks);
          }
        },
      );
    } finally {
      _isCreating = false;
      _operationsInProgress.remove(task.id);
    }
  }

  Future<void> createSubtask(TaskEntity subtask) async {
    if (subtask.parentTaskId == null) {
      throw ArgumentError('Subtask must have a parentTaskId');
    }
    await createTask(subtask);
  }

  Future<void> updateTask(TaskEntity task) async {
    final operationKey = 'update_${task.id}';

    if (_operationsInProgress.contains(operationKey)) {
      await _pendingOperations[operationKey]?.future;
      return;
    }

    _operationsInProgress.add(operationKey);
    final completer = Completer<void>();
    _pendingOperations[operationKey] = completer;

    try {
      final result = await _updateTask(UpdateTaskParams(task: task));

      result.fold((failure) => _notifyError(failure), (_) {
        if (state.hasValue) {
          final currentTasks = List<TaskEntity>.from(state.value!);
          final index = currentTasks.indexWhere((t) => t.id == task.id);

          if (index != -1) {
            currentTasks[index] = task;
            state = AsyncValue.data(currentTasks);
          }
        }
      });

      completer.complete();
    } catch (e) {
      completer.completeError(e);
      rethrow;
    } finally {
      _operationsInProgress.remove(operationKey);
      _pendingOperations.remove(operationKey);
    }
  }

  Future<void> deleteTask(String taskId) async {
    final operationKey = 'delete_$taskId';

    if (_operationsInProgress.contains(operationKey)) {
      return; // Já está sendo deletado
    }

    _operationsInProgress.add(operationKey);

    try {
      List<TaskEntity>? previousTasks;

      if (state.hasValue) {
        previousTasks = List<TaskEntity>.from(state.value!);
        final updatedTasks =
            previousTasks.where((t) => t.id != taskId).toList();
        state = AsyncValue.data(updatedTasks);
      }

      final result = await _deleteTask(DeleteTaskParams(taskId: taskId));

      result.fold(
        (failure) {
          if (previousTasks != null) {
            state = AsyncValue.data(previousTasks);
          }
          _notifyError(failure);
        },
        (_) {
        },
      );
    } finally {
      _operationsInProgress.remove(operationKey);
    }
  }

  Future<void> updateSubtask(TaskEntity subtask) async {
    if (subtask.parentTaskId == null) {
      throw ArgumentError('Subtask must have a parentTaskId');
    }
    await updateTask(subtask);
  }

  Future<void> deleteSubtask(String subtaskId) async {
    if (state.hasValue) {
      final subtask = state.value!.firstWhere(
        (t) => t.id == subtaskId,
        orElse: () => throw ArgumentError('Subtask not found'),
      );

      if (subtask.parentTaskId == null) {
        throw ArgumentError('Cannot delete non-subtask as subtask');
      }
    }

    await deleteTask(subtaskId);
  }

  Future<void> reorderTasks(List<String> taskIds) async {
    if (_isReordering) {
      return;
    }

    _isReordering = true;

    try {
      if (state.hasValue) {
        final currentTasks = state.value!;
        final validIds =
            taskIds
                .where((id) => currentTasks.any((task) => task.id == id))
                .toList();

        if (validIds.length != taskIds.length) {
          throw ArgumentError('Some task IDs are invalid');
        }
      }

      final result = await _reorderTasks(ReorderTasksParams(taskIds: taskIds));

      result.fold((failure) => _notifyError(failure), (_) {
        if (state.hasValue) {
          final currentTasks = List<TaskEntity>.from(state.value!);
          final taskMap = {for (var task in currentTasks) task.id: task};
          final reorderedTasks = <TaskEntity>[];

          for (int i = 0; i < taskIds.length; i++) {
            final task = taskMap[taskIds[i]];
            if (task != null) {
              reorderedTasks.add(task.copyWith(position: i));
              taskMap.remove(taskIds[i]);
            }
          }
          reorderedTasks.addAll(taskMap.values);

          state = AsyncValue.data(reorderedTasks);
        }
      });
    } finally {
      _isReordering = false;
    }
  }

  void watchTasks({
    String? listId,
    String? userId,
    TaskStatus? status,
    TaskPriority? priority,
    bool? isStarred,
  }) {
    _watchSubscription?.cancel();

    final stream = _watchTasks(
      WatchTasksParams(
        listId: listId,
        userId: userId,
        status: status,
        priority: priority,
        isStarred: isStarred,
      ),
    );
    _watchSubscription = stream.listen(
      (tasks) => state = AsyncValue.data(tasks),
      onError:
          (Object error, StackTrace stackTrace) =>
              state = AsyncValue.error(error, stackTrace),
      cancelOnError: false, // FIX: Não cancelar em caso de erro
    );
  }
  void _notifyError(dynamic error) {
    if (kDebugMode) {
      print('Error in TaskNotifier: $error');
    }
  }
  @override
  void dispose() {
    _watchSubscription?.cancel();
    _watchSubscription = null;
    for (final completer in _pendingOperations.values) {
      if (!completer.isCompleted) {
        completer.completeError(StateError('Provider disposed'));
      }
    }
    _pendingOperations.clear();
    _operationsInProgress.clear();

    super.dispose();
  }
}
