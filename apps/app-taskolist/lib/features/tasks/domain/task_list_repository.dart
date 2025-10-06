import '../../../core/utils/typedef.dart';
import 'task_list_entity.dart';

abstract class TaskListRepository {
  ResultFuture<String> createTaskList(TaskListEntity taskList);
  
  ResultFuture<TaskListEntity> getTaskList(String id);
  
  ResultFuture<List<TaskListEntity>> getTaskLists({
    String? userId,
    bool? isArchived,
  });
  
  ResultFuture<void> updateTaskList(TaskListEntity taskList);
  
  ResultFuture<void> deleteTaskList(String id);
  
  ResultFuture<void> shareTaskList(String id, List<String> memberIds);
  
  ResultFuture<void> archiveTaskList(String id);
  
  Stream<List<TaskListEntity>> watchTaskLists({
    String? userId,
    bool? isArchived,
  });
}
