import 'package:app_plantis/features/tasks/domain/entities/task.dart';

/// Interface for task notification scheduling operations
/// Responsibility: Agendar e cancelar notificações por plataforma
abstract class ITaskNotificationScheduler {
  /// Schedule a reminder notification for a task
  Future<void> scheduleTaskNotification(Task task);

  /// Schedule an overdue notification for a task
  Future<void> scheduleOverdueNotification(Task task);

  /// Schedule a daily summary notification
  Future<void> scheduleDailySummaryNotification(List<Task> todayTasks);

  /// Cancel all notifications for a specific task
  Future<void> cancelTaskNotifications(String taskId);

  /// Cancel all scheduled task notifications
  Future<void> cancelAllTaskNotifications();
}
