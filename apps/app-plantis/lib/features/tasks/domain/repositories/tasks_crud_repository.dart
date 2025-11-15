import 'package:core/core.dart' hide Column;

import '../entities/task.dart' as task_entity;

/// TasksCrudRepository - Interface for CREATE, READ, UPDATE, DELETE operations
///
/// ISP Pattern: Segregate repository into focused contracts
/// Each interface has 3-5 methods for single responsibility
///
/// Responsibilities:
/// - addTask - Create new task
/// - updateTask - Update existing task
/// - deleteTask - Delete task
/// - getTaskById - Retrieve single task by ID
abstract class ITasksCrudRepository {
  /// Create and store a new task
  Future<Either<Failure, task_entity.Task>> addTask(task_entity.Task task);

  /// Update an existing task
  Future<Either<Failure, task_entity.Task>> updateTask(task_entity.Task task);

  /// Delete a task by ID
  Future<Either<Failure, void>> deleteTask(String id);

  /// Retrieve a single task by ID
  Future<Either<Failure, task_entity.Task>> getTaskById(String id);
}
