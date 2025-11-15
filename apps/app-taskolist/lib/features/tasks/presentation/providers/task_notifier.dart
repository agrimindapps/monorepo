import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection.dart' as di;
import '../../domain/create_task.dart';
import '../../domain/delete_task.dart';
import '../../domain/get_subtasks.dart';
import '../../domain/get_tasks.dart';
import '../../domain/reorder_tasks.dart';
import '../../domain/task_entity.dart';
import '../../domain/update_task.dart';
import '../../domain/watch_tasks.dart';

part 'task_notifier.g.dart';

@riverpod
CreateTask createTaskUseCase(Ref ref) {
  return di.getIt<CreateTask>();
}

@riverpod
DeleteTask deleteTaskUseCase(Ref ref) {
  return di.getIt<DeleteTask>();
}

@riverpod
GetTasks getTasksUseCase(Ref ref) {
  return di.getIt<GetTasks>();
}

@riverpod
ReorderTasks reorderTasksUseCase(Ref ref) {
  return di.getIt<ReorderTasks>();
}

@riverpod
UpdateTask updateTaskUseCase(Ref ref) {
  return di.getIt<UpdateTask>();
}

@riverpod
WatchTasks watchTasksUseCase(Ref ref) {
  return di.getIt<WatchTasks>();
}

@riverpod
GetSubtasks getSubtasksUseCase(Ref ref) {
  return di.getIt<GetSubtasks>();
}

@riverpod
class TaskNotifier extends _$TaskNotifier {
  late final CreateTask _createTask;
  late final DeleteTask _deleteTask;
  late final GetTasks _getTasks;
  late final ReorderTasks _reorderTasks;
  late final UpdateTask _updateTask;

  @override
  Future<List<TaskEntity>> build() async {
    _createTask = ref.read(createTaskUseCaseProvider);
    _deleteTask = ref.read(deleteTaskUseCaseProvider);
    _getTasks = ref.read(getTasksUseCaseProvider);
    _reorderTasks = ref.read(reorderTasksUseCaseProvider);
    _updateTask = ref.read(updateTaskUseCaseProvider);
    final result = await _getTasks(const GetTasksParams());

    return result.fold(
      (failure) => throw Exception(failure.message),
      (tasks) => tasks,
    );
  }

  Future<void> getTasks({
    String? listId,
    String? userId,
    TaskStatus? status,
    TaskPriority? priority,
    bool? isStarred,
  }) async {
    state = const AsyncValue<List<TaskEntity>>.loading();

    state = await AsyncValue.guard(() async {
      final result = await _getTasks(
        GetTasksParams(
          listId: listId,
          userId: userId,
          status: status,
          priority: priority,
          isStarred: isStarred,
        ),
      );

      return result.fold(
        (failure) => throw Exception(failure.message),
        (tasks) => tasks,
      );
    });
  }

  Future<void> createTask(TaskEntity task) async {
    state = const AsyncValue<List<TaskEntity>>.loading();

    state = await AsyncValue.guard(() async {
      final result = await _createTask(CreateTaskParams(task: task));

      return result.fold((failure) => throw Exception(failure.message), (
        taskId,
      ) {
        final updatedTask = task.copyWith(id: taskId);
        final currentTasks = state.value ?? [];
        return [...currentTasks, updatedTask];
      });
    });
  }

  Future<void> createSubtask(TaskEntity subtask) async {
    await createTask(subtask);
  }

  Future<void> updateTask(TaskEntity task) async {
    state = const AsyncValue<List<TaskEntity>>.loading();

    state = await AsyncValue.guard(() async {
      final result = await _updateTask(UpdateTaskParams(task: task));

      return result.fold((failure) => throw Exception(failure.message), (_) {
        final currentTasks = state.value ?? [];
        return currentTasks.map<TaskEntity>((TaskEntity t) {
          return t.id == task.id ? task : t;
        }).toList();
      });
    });
  }

  Future<void> deleteTask(String taskId) async {
    state = const AsyncValue<List<TaskEntity>>.loading();

    state = await AsyncValue.guard(() async {
      final result = await _deleteTask(DeleteTaskParams(taskId: taskId));

      return result.fold((failure) => throw Exception(failure.message), (_) {
        final currentTasks = state.value ?? [];
        return currentTasks.where((TaskEntity t) => t.id != taskId).toList();
      });
    });
  }

  /// Métodos específicos para subtasks
  Future<void> updateSubtask(TaskEntity subtask) async {
    await updateTask(subtask);
  }

  Future<void> deleteSubtask(String subtaskId) async {
    await deleteTask(subtaskId);
  }

  Future<void> reorderTasks(List<String> taskIds) async {
    state = const AsyncValue<List<TaskEntity>>.loading();

    state = await AsyncValue.guard(() async {
      final result = await _reorderTasks(ReorderTasksParams(taskIds: taskIds));

      return result.fold((failure) => throw Exception(failure.message), (_) {
        final currentTasks = state.value ?? [];
        final reorderedTasks = <TaskEntity>[];
        for (int i = 0; i < taskIds.length; i++) {
          final taskId = taskIds[i];
          final task = currentTasks.firstWhere(
            (TaskEntity t) => t.id == taskId,
            orElse: () => currentTasks.first, // fallback, não deveria acontecer
          );
          reorderedTasks.add(task.copyWith(position: i));
        }
        final remainingTasks = currentTasks
            .where((TaskEntity task) => !taskIds.contains(task.id))
            .toList();
        reorderedTasks.addAll(remainingTasks);

        return reorderedTasks;
      });
    });
  }
}

/// Classes para parâmetros
class TasksStreamParams {
  final String? listId;
  final String? userId;
  final TaskStatus? status;
  final TaskPriority? priority;
  final bool? isStarred;

  const TasksStreamParams({
    this.listId,
    this.userId,
    this.status,
    this.priority,
    this.isStarred,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TasksStreamParams &&
        other.listId == listId &&
        other.userId == userId &&
        other.status == status &&
        other.priority == priority &&
        other.isStarred == isStarred;
  }

  @override
  int get hashCode {
    return listId.hashCode ^
        userId.hashCode ^
        status.hashCode ^
        priority.hashCode ^
        isStarred.hashCode;
  }
}

/// Provider para stream de tasks
@riverpod
Stream<List<TaskEntity>> tasksStream(Ref ref, TasksStreamParams params) {
  final watchTasks = ref.watch(watchTasksUseCaseProvider);

  return watchTasks(
    WatchTasksParams(
      listId: params.listId,
      userId: params.userId,
      status: params.status,
      priority: params.priority,
      isStarred: params.isStarred,
    ),
  );
}

class TaskCreationData {
  final String title;
  final String? description;
  final String listId;
  final String createdById;
  final String? assignedToId;
  final DateTime? dueDate;
  final DateTime? reminderDate;
  final TaskStatus? status;
  final TaskPriority? priority;
  final bool? isStarred;
  final int? position;
  final List<String>? tags;
  final String? parentTaskId;

  const TaskCreationData({
    required this.title,
    this.description,
    required this.listId,
    required this.createdById,
    this.assignedToId,
    this.dueDate,
    this.reminderDate,
    this.status,
    this.priority,
    this.isStarred,
    this.position,
    this.tags,
    this.parentTaskId,
  });
}

/// Provider para criar task com ID automático
@riverpod
Future<String> createTaskWithId(Ref ref, TaskCreationData taskData) async {
  final createTask = ref.watch(createTaskUseCaseProvider);

  final task = TaskEntity(
    id: FirebaseFirestore.instance.collection('_').doc().id,
    title: taskData.title,
    description: taskData.description,
    listId: taskData.listId,
    createdById: taskData.createdById,
    assignedToId: taskData.assignedToId,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    dueDate: taskData.dueDate,
    reminderDate: taskData.reminderDate,
    status: taskData.status ?? TaskStatus.pending,
    priority: taskData.priority ?? TaskPriority.medium,
    isStarred: taskData.isStarred ?? false,
    position: taskData.position ?? 0,
    tags: taskData.tags ?? const [],
    parentTaskId: taskData.parentTaskId,
  );

  final result = await createTask(CreateTaskParams(task: task));

  return result.fold(
    (failure) => throw Exception(failure.message),
    (taskId) => taskId,
  );
}

class GetTasksRequest {
  final String? listId;
  final String? userId;
  final TaskStatus? status;
  final TaskPriority? priority;
  final bool? isStarred;

  const GetTasksRequest({
    this.listId,
    this.userId,
    this.status,
    this.priority,
    this.isStarred,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GetTasksRequest &&
        other.listId == listId &&
        other.userId == userId &&
        other.status == status &&
        other.priority == priority &&
        other.isStarred == isStarred;
  }

  @override
  int get hashCode {
    return listId.hashCode ^
        userId.hashCode ^
        status.hashCode ^
        priority.hashCode ^
        isStarred.hashCode;
  }
}

/// Provider para buscar tasks
@riverpod
Future<List<TaskEntity>> getTasksFuture(
  Ref ref,
  GetTasksRequest request,
) async {
  final getTasks = ref.watch(getTasksUseCaseProvider);

  final result = await getTasks(
    GetTasksParams(
      listId: request.listId,
      userId: request.userId,
      status: request.status,
      priority: request.priority,
      isStarred: request.isStarred,
    ),
  );

  return result.fold(
    (failure) => throw Exception(failure.message),
    (tasks) => tasks,
  );
}

/// Provider para buscar subtasks de uma tarefa específica
@riverpod
Future<List<TaskEntity>> subtasks(Ref ref, String parentTaskId) async {
  final getSubtasks = ref.watch(getSubtasksUseCaseProvider);

  final result = await getSubtasks(
    GetSubtasksParams(parentTaskId: parentTaskId),
  );

  return result.fold(
    (failure) => throw Exception(failure.message),
    (subtasks) => subtasks,
  );
}
