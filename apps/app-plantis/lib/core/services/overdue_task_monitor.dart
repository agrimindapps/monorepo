import 'package:flutter/material.dart';

import '../../features/tasks/domain/entities/task.dart' as task_entity;
import 'interfaces/i_overdue_task_monitor.dart';
import 'interfaces/i_task_notification_scheduler.dart';

/// Service responsible for monitoring and notifying overdue tasks
/// Follows Single Responsibility Principle - handles only overdue detection
class OverdueTaskMonitor implements IOverdueTaskMonitor {
  final ITaskNotificationScheduler _notificationScheduler;

  OverdueTaskMonitor(this._notificationScheduler);

  /// Check for overdue tasks and create notifications
  @override
  Future<void> checkOverdueTasks(List<task_entity.Task> allTasks) async {
    try {
      await handleOverdueTasksDetection(allTasks);
    } catch (e) {
      debugPrint('Erro ao verificar tarefas em atraso: $e');
    }
  }

  /// Handle overdue tasks detection - identifies overdue items and notifies
  @override
  Future<void> handleOverdueTasksDetection(List<task_entity.Task> tasks) async {
    try {
      final DateTime now = DateTime.now();
      final List<task_entity.Task> overdueTasks = tasks
          .where(
            (task) =>
                task.status == task_entity.TaskStatus.pending &&
                task.dueDate.isBefore(now),
          )
          .toList();

      if (overdueTasks.isEmpty) {
        debugPrint('✅ No overdue tasks found');
        return;
      }

      debugPrint(
        '🚨 Found ${overdueTasks.length} overdue tasks - generating notifications',
      );

      for (final task in overdueTasks) {
        await _notificationScheduler.scheduleOverdueNotification(task);
      }

      debugPrint(
        '✅ Processed ${overdueTasks.length} overdue task notifications',
      );
    } catch (e) {
      debugPrint('❌ Error handling overdue tasks detection: $e');
    }
  }
}
