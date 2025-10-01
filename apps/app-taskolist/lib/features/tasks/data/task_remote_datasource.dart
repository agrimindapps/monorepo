import '../domain/task_entity.dart';
import 'task_model.dart';

abstract class TaskRemoteDataSource {
  Future<String> createTask(TaskModel task);
  
  Future<TaskModel> getTask(String id);
  
  Future<List<TaskModel>> getTasks({
    String? listId,
    String? userId,
    TaskStatus? status,
    TaskPriority? priority,
    bool? isStarred,
    DateTime? dueBefore,
    DateTime? dueAfter,
  });
  
  Future<void> updateTask(TaskModel task);
  
  Future<void> deleteTask(String id);
  
  Future<void> updateTaskStatus(String id, TaskStatus status);
  
  Future<void> toggleTaskStar(String id);
  
  Future<void> reorderTasks(List<String> taskIds);
  
  Future<List<TaskModel>> searchTasks(String query);
  
  Stream<List<TaskModel>> watchTasks({
    String? listId,
    String? userId,
    TaskStatus? status,
    TaskPriority? priority,
    bool? isStarred,
  });
  
  Future<List<TaskModel>> getSubtasks(String parentTaskId);
}