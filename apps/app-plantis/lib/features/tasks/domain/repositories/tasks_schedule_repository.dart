import 'package:core/core.dart' hide Column;

import '../entities/task.dart' as task_entity;

/// TasksScheduleRepository - Interface for SCHEDULING, RECURRING, REMINDERS operations
///
/// ISP Pattern: Segregate repository into focused contracts
/// Each interface has 3-5 methods for single responsibility
///
/// Responsibilities:
/// - completeTask - Mark task as complete
/// - getOverdueTasks - Get overdue tasks
/// - createRecurring - Generate next recurring task
/// - markOverdue - Mark task as overdue
abstract class ITasksScheduleRepository {
  /// Mark task as completed with optional notes
  Future<Either<Failure, task_entity.Task>> completeTask(
    String id, {
    String? notes,
  });

  /// Retrieve all overdue tasks
  Future<Either<Failure, List<task_entity.Task>>> getOverdueTasks();

  /// Generate next recurring task from completed task
  Future<Either<Failure, task_entity.Task>> createRecurringTask(
    task_entity.Task completedTask,
  );

  /// Mark task as overdue
  Future<Either<Failure, void>> markTaskAsOverdue(String id);
}
