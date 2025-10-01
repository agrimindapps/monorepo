import 'package:core/core.dart' hide getIt;
import 'package:uuid/uuid.dart';

import '../../../../core/di/injection.dart' as di;
import '../../domain/task_entity.dart';
import '../../domain/create_task.dart';
import '../../domain/delete_task.dart';
import '../../domain/get_tasks.dart';
import '../../domain/reorder_tasks.dart';
import '../../domain/update_task.dart';
import '../../domain/watch_tasks.dart';
import 'task_provider.dart';

// Provider para TaskNotifier
final taskNotifierProvider = StateNotifierProvider<TaskNotifier, AsyncValue<List<TaskEntity>>>((ref) {
  return TaskNotifier(
    createTask: di.getIt<CreateTask>(),
    deleteTask: di.getIt<DeleteTask>(),
    getTasks: di.getIt<GetTasks>(),
    reorderTasks: di.getIt<ReorderTasks>(),
    updateTask: di.getIt<UpdateTask>(),
    watchTasks: di.getIt<WatchTasks>(),
  );
});

// Provider para stream de tasks
final tasksStreamProvider = StreamProvider.family<List<TaskEntity>, TasksStreamParams>((ref, params) {
  final watchTasks = di.getIt<WatchTasks>();
  
  return watchTasks(WatchTasksParams(
    listId: params.listId,
    userId: params.userId,
    status: params.status,
    priority: params.priority,
    isStarred: params.isStarred,
  ));
});

// Provider para criar task com ID automático
final createTaskProvider = FutureProvider.family<String, TaskCreationData>((ref, taskData) async {
  final createTask = di.getIt<CreateTask>();
  const uuid = Uuid();
  
  final task = TaskEntity(
    id: uuid.v4(),
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
});

// Provider para buscar tasks
final getTasksProvider = FutureProvider.family<List<TaskEntity>, GetTasksRequest>((ref, request) async {
  final getTasks = di.getIt<GetTasks>();
  
  final result = await getTasks(GetTasksParams(
    listId: request.listId,
    userId: request.userId,
    status: request.status,
    priority: request.priority,
    isStarred: request.isStarred,
  ));

  return result.fold(
    (failure) => throw Exception(failure.message),
    (tasks) => tasks,
  );
});

// Provider para reordenar tasks
final reorderTasksProvider = FutureProvider.family<void, List<String>>((ref, taskIds) async {
  final reorderTasks = di.getIt<ReorderTasks>();
  
  final result = await reorderTasks(ReorderTasksParams(taskIds: taskIds));

  return result.fold(
    (failure) => throw Exception(failure.message),
    (_) => null,
  );
});

// Classes para parâmetros
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