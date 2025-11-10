import 'package:core/core.dart' hide Column;

import '../entities/task.dart' as task_entity;

abstract class TasksRepository {
  Future<Either<Failure, List<task_entity.Task>>> getTasks();
  Future<Either<Failure, List<task_entity.Task>>> getTasksByPlantId(
    String plantId,
  );
  Future<Either<Failure, List<task_entity.Task>>> getTasksByStatus(
    task_entity.TaskStatus status,
  );
  Future<Either<Failure, List<task_entity.Task>>> getOverdueTasks();
  Future<Either<Failure, List<task_entity.Task>>> getTodayTasks();
  Future<Either<Failure, List<task_entity.Task>>> getUpcomingTasks();
  Future<Either<Failure, task_entity.Task>> getTaskById(String id);
  Future<Either<Failure, task_entity.Task>> addTask(task_entity.Task task);
  Future<Either<Failure, task_entity.Task>> updateTask(task_entity.Task task);
  Future<Either<Failure, void>> deleteTask(String id);
  Future<Either<Failure, task_entity.Task>> completeTask(
    String id, {
    String? notes,
  });
  Future<Either<Failure, void>> markTaskAsOverdue(String id);
  Future<Either<Failure, task_entity.Task>> createRecurringTask(
    task_entity.Task completedTask,
  );
}
