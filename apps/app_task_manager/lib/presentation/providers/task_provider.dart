import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/update_task.dart';
import '../../domain/usecases/watch_tasks.dart';

class TaskNotifier extends StateNotifier<AsyncValue<List<TaskEntity>>> {
  TaskNotifier({
    required CreateTask createTask,
    required GetTasks getTasks,
    required UpdateTask updateTask,
    required WatchTasks watchTasks,
  })  : _createTask = createTask,
        _getTasks = getTasks,
        _updateTask = updateTask,
        _watchTasks = watchTasks,
        super(const AsyncValue.loading());

  final CreateTask _createTask;
  final GetTasks _getTasks;
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
          state = AsyncValue.error(error, stackTrace),
    );
  }
}