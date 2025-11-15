import 'package:core/core.dart' hide Column;

import '../entities/task.dart' as task_entity;

/// TasksQueryRepository - Interface for QUERY, SEARCH, FILTER, LIST operations
///
/// ISP Pattern: Segregate repository into focused contracts
/// Each interface has 3-5 methods for single responsibility
///
/// Responsibilities:
/// - getTasks - Retrieve all tasks
/// - searchTasks - Search by query
/// - filterByPlant - Filter by plant ID
/// - getByStatus - Filter by status
/// - getStatistics - Generate statistics
abstract class ITasksQueryRepository {
  /// Retrieve all tasks
  Future<Either<Failure, List<task_entity.Task>>> getTasks();

  /// Search tasks by query (title or description)
  Future<Either<Failure, List<task_entity.Task>>> searchTasks(String query);

  /// Filter tasks by plant ID
  Future<Either<Failure, List<task_entity.Task>>> filterByPlantId(
    String plantId,
  );

  /// Filter tasks by status
  Future<Either<Failure, List<task_entity.Task>>> filterByStatus(
    task_entity.TaskStatus status,
  );

  /// Get task statistics
  Future<Either<Failure, Map<String, dynamic>>> getStatistics();
}
