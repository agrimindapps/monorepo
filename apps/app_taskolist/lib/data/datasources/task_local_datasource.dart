import '../../domain/entities/task_entity.dart';
import '../models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<void> cacheTask(TaskModel task);
  
  Future<void> cacheTasks(List<TaskModel> tasks);
  
  Future<TaskModel?> getTask(String id);
  
  Future<List<TaskModel>> getTasks({
    String? listId,
    String? userId,
    TaskStatus? status,
    TaskPriority? priority,
    bool? isStarred,
  });
  
  Future<void> updateTask(TaskModel task);
  
  Future<void> deleteTask(String id);
  
  Future<void> clearCache();
  
  Stream<List<TaskModel>> watchTasks({
    String? listId,
    String? userId,
    TaskStatus? status,
    TaskPriority? priority,
    bool? isStarred,
  });
}