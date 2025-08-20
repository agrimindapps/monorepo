import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/di/injection_container.dart' as di;
import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/update_task.dart';
import '../../domain/usecases/watch_tasks.dart';
import 'task_provider.dart';

// Provider para TaskNotifier
final taskNotifierProvider = StateNotifierProvider<TaskNotifier, AsyncValue<List<TaskEntity>>>((ref) {
  return TaskNotifier(
    createTask: di.sl<CreateTask>(),
    deleteTask: di.sl<DeleteTask>(),
    getTasks: di.sl<GetTasks>(),
    updateTask: di.sl<UpdateTask>(),
    watchTasks: di.sl<WatchTasks>(),
  );
});

// Provider para stream de tasks
final tasksStreamProvider = StreamProvider.family<List<TaskEntity>, TasksStreamParams>((ref, params) {
  final watchTasks = di.sl<WatchTasks>();
  
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
  final createTask = di.sl<CreateTask>();
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
    (failure) => throw failure,
    (taskId) => taskId,
  );
});

// Provider para buscar tasks
final getTasksProvider = FutureProvider.family<List<TaskEntity>, GetTasksRequest>((ref, request) async {
  final getTasks = di.sl<GetTasks>();
  
  final result = await getTasks(GetTasksParams(
    listId: request.listId,
    userId: request.userId,
    status: request.status,
    priority: request.priority,
    isStarred: request.isStarred,
  ));
  
  return result.fold(
    (failure) => throw failure,
    (tasks) => tasks,
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