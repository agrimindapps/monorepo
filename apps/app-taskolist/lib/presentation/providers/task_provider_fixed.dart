import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:core/core.dart';

import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/reorder_tasks.dart';
import '../../domain/usecases/update_task.dart';
import '../../domain/usecases/watch_tasks.dart';

/// TaskNotifier com correções para race conditions e memory leaks
class TaskNotifierFixed extends StateNotifier<AsyncValue<List<TaskEntity>>> {
  TaskNotifierFixed({
    required CreateTask createTask,
    required DeleteTask deleteTask,
    required GetTasks getTasks,
    required ReorderTasks reorderTasks,
    required UpdateTask updateTask,
    required WatchTasks watchTasks,
  })  : _createTask = createTask,
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

  // FIX: Memory leak - Store subscription para cancelar no dispose
  StreamSubscription<List<TaskEntity>>? _watchSubscription;
  
  // FIX: Race condition - Flags para prevenir operações concorrentes
  bool _isCreating = false;
  bool _isReordering = false;
  
  // FIX: Race condition - Set para tracking de operações em progresso
  final Set<String> _operationsInProgress = {};
  
  // FIX: Race condition - Completer para gerenciar operações assíncronas
  final Map<String, Completer<void>> _pendingOperations = {};

  Future<void> getTasks({
    String? listId,
    String? userId,
    TaskStatus? status,
    TaskPriority? priority,
    bool? isStarred,
  }) async {
    state = const AsyncValue.loading();

    final result = await _getTasks(GetTasksParams(
      listId: listId,
      userId: userId,
      status: status,
      priority: priority,
      isStarred: isStarred,
    ));

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (tasks) => state = AsyncValue.data(tasks),
    );
  }

  Future<void> createTask(TaskEntity task) async {
    // FIX: Race condition - Prevenir criações concorrentes
    if (_isCreating) {
      throw StateError('Task creation already in progress');
    }
    
    // FIX: Race condition - Check se já existe operação para este ID
    if (_operationsInProgress.contains(task.id)) {
      throw StateError('Operation already in progress for task ${task.id}');
    }
    
    _isCreating = true;
    _operationsInProgress.add(task.id);
    
    try {
      final result = await _createTask(CreateTaskParams(task: task));

      result.fold(
        (failure) {
          // FIX: Better error handling sem sobrescrever estado válido
          if (state.hasValue) {
            // Preservar tasks existentes e adicionar erro como notificação
            _notifyError(failure);
          } else {
            state = AsyncValue.error(failure, StackTrace.current);
          }
        },
        (taskId) {
          final updatedTask = task.copyWith(id: taskId);
          if (state.hasValue) {
            // FIX: Race condition - Usar lista imutável
            final currentTasks = List<TaskEntity>.from(state.value!);
            currentTasks.add(updatedTask);
            
            // FIX: Manter ordem consistente
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
    // FIX: Validar que é realmente uma subtask
    if (subtask.parentTaskId == null) {
      throw ArgumentError('Subtask must have a parentTaskId');
    }
    await createTask(subtask);
  }

  Future<void> updateTask(TaskEntity task) async {
    // FIX: Race condition - Prevenir updates concorrentes
    final operationKey = 'update_${task.id}';
    
    if (_operationsInProgress.contains(operationKey)) {
      // FIX: Aguardar operação anterior completar
      await _pendingOperations[operationKey]?.future;
      return;
    }
    
    _operationsInProgress.add(operationKey);
    final completer = Completer<void>();
    _pendingOperations[operationKey] = completer;
    
    try {
      final result = await _updateTask(UpdateTaskParams(task: task));

      result.fold(
        (failure) => _notifyError(failure),
        (_) {
          if (state.hasValue) {
            // FIX: Race condition - Operação atômica com lista imutável
            final currentTasks = List<TaskEntity>.from(state.value!);
            final index = currentTasks.indexWhere((t) => t.id == task.id);
            
            if (index != -1) {
              currentTasks[index] = task;
              state = AsyncValue.data(currentTasks);
            }
          }
        },
      );
      
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
    // FIX: Race condition - Prevenir deletes concorrentes
    final operationKey = 'delete_$taskId';
    
    if (_operationsInProgress.contains(operationKey)) {
      return; // Já está sendo deletado
    }
    
    _operationsInProgress.add(operationKey);
    
    try {
      // FIX: Optimistic update com rollback em caso de erro
      List<TaskEntity>? previousTasks;
      
      if (state.hasValue) {
        previousTasks = List<TaskEntity>.from(state.value!);
        
        // Optimistic delete
        final updatedTasks = previousTasks.where((t) => t.id != taskId).toList();
        state = AsyncValue.data(updatedTasks);
      }
      
      final result = await _deleteTask(DeleteTaskParams(taskId: taskId));

      result.fold(
        (failure) {
          // FIX: Rollback em caso de erro
          if (previousTasks != null) {
            state = AsyncValue.data(previousTasks);
          }
          _notifyError(failure);
        },
        (_) {
          // Delete confirmado, nada a fazer
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
    // FIX: Verificar se é realmente uma subtask antes de deletar
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
    // FIX: Race condition - Prevenir reordenações concorrentes
    if (_isReordering) {
      return;
    }
    
    _isReordering = true;
    
    try {
      // FIX: Validar IDs antes de reordenar
      if (state.hasValue) {
        final currentTasks = state.value!;
        final validIds = taskIds.where((id) => 
          currentTasks.any((task) => task.id == id)
        ).toList();
        
        if (validIds.length != taskIds.length) {
          throw ArgumentError('Some task IDs are invalid');
        }
      }
      
      final result = await _reorderTasks(ReorderTasksParams(taskIds: taskIds));

      result.fold(
        (failure) => _notifyError(failure),
        (_) {
          if (state.hasValue) {
            final currentTasks = List<TaskEntity>.from(state.value!);
            final taskMap = {for (var task in currentTasks) task.id: task};
            
            // FIX: Reordenação mais eficiente
            final reorderedTasks = <TaskEntity>[];
            
            for (int i = 0; i < taskIds.length; i++) {
              final task = taskMap[taskIds[i]];
              if (task != null) {
                reorderedTasks.add(task.copyWith(position: i));
                taskMap.remove(taskIds[i]);
              }
            }
            
            // Adicionar tasks restantes mantendo ordem relativa
            reorderedTasks.addAll(taskMap.values);
            
            state = AsyncValue.data(reorderedTasks);
          }
        },
      );
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
    // FIX: Memory leak - Cancelar subscription anterior
    _watchSubscription?.cancel();
    
    final stream = _watchTasks(WatchTasksParams(
      listId: listId,
      userId: userId,
      status: status,
      priority: priority,
      isStarred: isStarred,
    ));

    // FIX: Memory leak - Armazenar subscription para cancelar depois
    _watchSubscription = stream.listen(
      (tasks) => state = AsyncValue.data(tasks),
      onError: (error, stackTrace) =>
          state = AsyncValue.error(error as Object? ?? 'Unknown error', stackTrace as StackTrace? ?? StackTrace.empty),
      cancelOnError: false, // FIX: Não cancelar em caso de erro
    );
  }
  
  // FIX: Helper para notificar erros sem sobrescrever estado
  void _notifyError(dynamic error) {
    // TODO: Implementar sistema de notificação de erros
    // Por enquanto, apenas log
    if (kDebugMode) {
      print('Error in TaskNotifier: $error');
    }
  }
  
  // FIX: Memory leak - Implementar dispose adequado
  @override
  void dispose() {
    _watchSubscription?.cancel();
    _watchSubscription = null;
    
    // Completar todas as operações pendentes
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