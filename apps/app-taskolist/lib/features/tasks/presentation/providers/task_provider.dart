import 'package:core/core.dart';

import '../../domain/task_entity.dart';
import '../../domain/create_task.dart';
import '../../domain/delete_task.dart';
import '../../domain/get_tasks.dart';
import '../../domain/reorder_tasks.dart';
import '../../domain/update_task.dart';
import '../../domain/watch_tasks.dart';

class TaskNotifier extends StateNotifier<AsyncValue<List<TaskEntity>>> {
  TaskNotifier({
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
    final result = await _createTask(CreateTaskParams(task: task));

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (taskId) {
        final updatedTask = task.copyWith(id: taskId);
        if (state.hasValue) {
          final currentTasks = state.value!;
          state = AsyncValue.data([...currentTasks, updatedTask]);
        }
      },
    );
  }

  // Método específico para criar subtasks
  Future<void> createSubtask(TaskEntity subtask) async {
    await createTask(subtask);
  }

  Future<void> updateTask(TaskEntity task) async {
    final result = await _updateTask(UpdateTaskParams(task: task));

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) {
        if (state.hasValue) {
          final currentTasks = state.value!;
          final updatedTasks = currentTasks.map((t) {
            return t.id == task.id ? task : t;
          }).toList();
          state = AsyncValue.data(updatedTasks);
        }
      },
    );
  }

  Future<void> deleteTask(String taskId) async {
    final result = await _deleteTask(DeleteTaskParams(taskId: taskId));

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) {
        if (state.hasValue) {
          final currentTasks = state.value!;
          final updatedTasks = currentTasks.where((t) => t.id != taskId).toList();
          state = AsyncValue.data(updatedTasks);
        }
      },
    );
  }

  // Métodos específicos para subtasks
  Future<void> updateSubtask(TaskEntity subtask) async {
    await updateTask(subtask);
  }

  Future<void> deleteSubtask(String subtaskId) async {
    await deleteTask(subtaskId);
  }

  Future<void> reorderTasks(List<String> taskIds) async {
    final result = await _reorderTasks(ReorderTasksParams(taskIds: taskIds));

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) {
        if (state.hasValue) {
          final currentTasks = state.value!;
          // Reordenar as tasks localmente conforme a nova ordem
          final reorderedTasks = <TaskEntity>[];
          
          // Adicionar tasks na nova ordem
          for (int i = 0; i < taskIds.length; i++) {
            final taskId = taskIds[i];
            final task = currentTasks.firstWhere(
              (t) => t.id == taskId,
              orElse: () => currentTasks.first, // fallback, não deveria acontecer
            );
            reorderedTasks.add(task.copyWith(position: i));
          }
          
          // Adicionar qualquer task que não estava na lista de reordenação
          final remainingTasks = currentTasks.where(
            (task) => !taskIds.contains(task.id),
          ).toList();
          reorderedTasks.addAll(remainingTasks);
          
          state = AsyncValue.data(reorderedTasks);
        }
      },
    );
  }

  void watchTasks({
    String? listId,
    String? userId,
    TaskStatus? status,
    TaskPriority? priority,
    bool? isStarred,
  }) {
    final stream = _watchTasks(WatchTasksParams(
      listId: listId,
      userId: userId,
      status: status,
      priority: priority,
      isStarred: isStarred,
    ));

    stream.listen(
      (tasks) => state = AsyncValue.data(tasks),
      onError: (error, stackTrace) =>
          state = AsyncValue.error(error as Object? ?? 'Unknown error', stackTrace as StackTrace? ?? StackTrace.empty),
    );
  }
}