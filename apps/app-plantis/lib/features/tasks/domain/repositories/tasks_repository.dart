import 'package:core/core.dart' hide Column;

import '../entities/task.dart' as task_entity;
import './tasks_crud_repository.dart';
import './tasks_query_repository.dart';
import './tasks_schedule_repository.dart';

/// TasksRepository - Composite interface (ISP Pattern)
///
/// Combines segregated repository interfaces:
/// - ITasksCrudRepository (4 methods: add, update, delete, get)
/// - ITasksQueryRepository (5 methods: list, search, filter, history, stats)
/// - ITasksScheduleRepository (3 methods: complete, recurring, schedule)
///
/// Backward compatibility: still provides all original methods
abstract class TasksRepository
    implements
        ITasksCrudRepository,
        ITasksQueryRepository,
        ITasksScheduleRepository {
  // Legacy method compatibility
  Future<Either<Failure, List<task_entity.Task>>> getTasksByPlantId(
    String plantId,
  );

  Future<Either<Failure, List<task_entity.Task>>> getTasksByStatus(
    task_entity.TaskStatus status,
  );

  Future<Either<Failure, List<task_entity.Task>>> getTodayTasks();

  Future<Either<Failure, List<task_entity.Task>>> getUpcomingTasks();
}
