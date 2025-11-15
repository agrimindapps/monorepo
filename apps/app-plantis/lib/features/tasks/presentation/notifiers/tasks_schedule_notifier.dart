import 'package:core/core.dart' hide Column;

import '../../domain/entities/task.dart' as task_entity;
import '../providers/tasks_state.dart';

part 'tasks_schedule_notifier.g.dart';

/// TasksScheduleNotifier - Handles RECURRING, REMINDERS, SCHEDULING operations
///
/// Responsibilities (SRP):
/// - Recurring task logic
/// - Reminder calculations
/// - Scheduler operations
/// - Due date management
/// - Notification scheduling
///
/// Does NOT handle:
/// - CRUD operations (see TasksCrudNotifier)
/// - Query/filtering (see TasksQueryNotifier)
/// - Recommendations (see TasksRecommendationNotifier)
@riverpod
class TasksScheduleNotifier extends _$TasksScheduleNotifier {
  @override
  TasksState build() {
    return TasksState.initial();
  }

  /// Updates state with new tasks (called from parent notifier)
  void updateTasksState(TasksState newState) {
    state = newState;
  }

  /// Calculates overdue tasks
  List<task_entity.Task> getOverdueTasks() {
    final now = DateTime.now();
    return state.allTasks
        .whereType<task_entity.Task>()
        .where(
          (task) =>
              task.dueDate.isBefore(now) &&
              task.status != task_entity.TaskStatus.completed,
        )
        .toList();
  }

  /// Calculates today's tasks
  List<task_entity.Task> getTodayTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1, 0, 0, 0, 0, 0);

    return state.allTasks
        .whereType<task_entity.Task>()
        .where(
          (task) =>
              !task.dueDate.isBefore(today) &&
              task.dueDate.isBefore(tomorrow) &&
              task.status != task_entity.TaskStatus.completed,
        )
        .toList();
  }

  /// Calculates upcoming tasks
  List<task_entity.Task> getUpcomingTasks({int days = 7}) {
    final now = DateTime.now();
    final upcoming = now.add(Duration(days: days));

    return state.allTasks
        .whereType<task_entity.Task>()
        .where(
          (task) =>
              (task.dueDate.isAfter(now) || _isSameDay(task.dueDate, now)) &&
              task.dueDate.isBefore(upcoming) &&
              task.status != task_entity.TaskStatus.completed,
        )
        .toList();
  }

  /// Generates next recurring task
  task_entity.Task? generateNextRecurringTask(task_entity.Task completedTask) {
    if (!completedTask.isRecurring ||
        completedTask.recurringIntervalDays == null) {
      return null;
    }

    final nextDueDate = _calculateNextDueDate(
      completedTask.dueDate,
      completedTask.recurringIntervalDays!,
    );

    if (nextDueDate == null) {
      return null; // Recurring ended
    }

    return task_entity.Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      title: completedTask.title,
      description: completedTask.description,
      plantId: completedTask.plantId,
      type: completedTask.type,
      status: task_entity.TaskStatus.pending,
      priority: completedTask.priority,
      dueDate: nextDueDate,
      completedAt: null,
      completionNotes: null,
      isRecurring: completedTask.isRecurring,
      recurringIntervalDays: completedTask.recurringIntervalDays,
      nextDueDate: null,
      isDirty: true,
      userId: completedTask.userId,
      moduleName: completedTask.moduleName,
    );
  }

  /// Helper: Calculate next due date for recurring tasks
  DateTime? _calculateNextDueDate(DateTime currentDueDate, int intervalDays) {
    // Simply add the interval days to the current due date
    return currentDueDate.add(Duration(days: intervalDays));
  }

  /// Helper: Check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
