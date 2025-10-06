import '../../../core/utils/typedef.dart';
import 'task_entity.dart';

abstract class TaskRepository {
  ResultFuture<String> createTask(TaskEntity task);
  
  ResultFuture<TaskEntity> getTask(String id);
  
  ResultFuture<List<TaskEntity>> getTasks({
    String? listId,
    String? userId,
    TaskStatus? status,
    TaskPriority? priority,
    bool? isStarred,
    DateTime? dueBefore,
    DateTime? dueAfter,
  });
  
  ResultFuture<void> updateTask(TaskEntity task);
  
  ResultFuture<void> deleteTask(String id);
  
  ResultFuture<void> updateTaskStatus(String id, TaskStatus status);
  
  ResultFuture<void> toggleTaskStar(String id);
  
  ResultFuture<void> reorderTasks(List<String> taskIds);
  
  Stream<List<TaskEntity>> watchTasks({
    String? listId,
    String? userId,
    TaskStatus? status,
    TaskPriority? priority,
    bool? isStarred,
  });
  
  ResultFuture<List<TaskEntity>> searchTasks(String query);
  
  ResultFuture<List<TaskEntity>> getSubtasks(String parentTaskId);
}
