import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../features/tasks/core/constants/tasks_constants.dart';
import '../../features/tasks/domain/entities/task.dart' as task_entity;
import '../localization/app_strings.dart';
import 'interfaces/i_task_notification_scheduler.dart';
import 'plantis_notification_service.dart';

/// Service responsible for scheduling and canceling task notifications
/// Follows Single Responsibility Principle - handles only notification scheduling
class TaskNotificationScheduler implements ITaskNotificationScheduler {
  final PlantisNotificationService _notificationService;

  TaskNotificationScheduler(this._notificationService);

  /// Schedule a reminder notification for a task
  @override
  Future<void> scheduleTaskNotification(task_entity.Task task) async {
    try {
      final bool enabled = await _notificationService.areNotificationsEnabled();
      if (!enabled) {
        debugPrint('⚠️ Notifications not enabled, skipping task notification');
        return;
      }

      final DateTime notificationTime = await _getScheduledDateInUserTimezone(
        task,
      );
      if (notificationTime.isBefore(DateTime.now())) {
        debugPrint('⚠️ Notification time has passed, skipping: ${task.title}');
        return;
      }

      final String title = _getNotificationTitle(task);
      final String body = _getNotificationBody(task);
      final String payload = _createNotificationPayload(
        task,
        PlantisNotificationType.taskReminder,
      );

      final int notificationId = _createNotificationId('${task.id}_reminder');
      final actions = _createTaskNotificationActions(task);

      await _scheduleNotificationWithActions(
        id: notificationId,
        title: title,
        body: body,
        scheduledDate: notificationTime,
        payload: payload,
        actions: actions,
      );

      debugPrint(
        '✅ Scheduled task notification: ${task.title} at ${notificationTime.toString()}',
      );
    } catch (e) {
      debugPrint('❌ Error scheduling task notification: $e');
    }
  }

  /// Schedule an overdue notification for a task
  @override
  Future<void> scheduleOverdueNotification(task_entity.Task task) async {
    try {
      final bool enabled = await _notificationService.areNotificationsEnabled();
      if (!enabled) {
        debugPrint(
          '⚠️ Notifications not enabled, skipping overdue notification',
        );
        return;
      }

      const String title = AppStrings.taskOverdue;
      final String body = '${task.title} está atrasada';
      final String payload = _createNotificationPayload(
        task,
        PlantisNotificationType.overdueTask,
      );

      final int notificationId = _createNotificationId('${task.id}_overdue');
      final actions = [
        {
          'id': TasksConstants.completeTaskActionId,
          'title': AppStrings.completeNowAction,
          'icon': Platform.isAndroid ? TasksConstants.androidCheckIcon : '',
        },
        {
          'id': TasksConstants.rescheduleTaskActionId,
          'title': AppStrings.rescheduleAction,
          'icon': Platform.isAndroid ? TasksConstants.androidScheduleIcon : '',
        },
        {
          'id': TasksConstants.viewDetailsActionId,
          'title': AppStrings.viewDetailsAction,
          'icon': Platform.isAndroid ? TasksConstants.androidInfoIcon : '',
        },
      ];

      await _scheduleNotificationWithActions(
        id: notificationId,
        title: title,
        body: body,
        scheduledDate: DateTime.now(),
        payload: payload,
        actions: actions,
      );

      debugPrint('✅ Created overdue task notification: ${task.title}');
    } catch (e) {
      debugPrint('❌ Error creating overdue notification: $e');
    }
  }

  /// Schedule a daily summary notification
  @override
  Future<void> scheduleDailySummaryNotification(
    List<task_entity.Task> todayTasks,
  ) async {
    try {
      final bool enabled = await _notificationService.areNotificationsEnabled();
      if (!enabled) return;

      if (todayTasks.isEmpty) return;

      const String title = AppStrings.goodMorning;
      final String body = _getDailySummaryBody(todayTasks);
      final String payload = _createDailySummaryPayload(todayTasks);

      const int notificationId = TasksConstants.dailySummaryNotificationId;

      await _scheduleNotificationWithActions(
        id: notificationId,
        title: title,
        body: body,
        scheduledDate: DateTime.now(),
        payload: payload,
        actions: [],
      );
    } catch (e) {
      debugPrint('Erro ao agendar resumo diário: $e');
    }
  }

  /// Cancel all notifications for a specific task
  @override
  Future<void> cancelTaskNotifications(String taskId) async {
    try {
      final reminderId = _createNotificationId('${taskId}_reminder');
      final overdueId = _createNotificationId('${taskId}_overdue');
      await _notificationService.cancelNotification(reminderId);
      await _notificationService.cancelNotification(overdueId);
    } catch (e) {
      debugPrint('Erro ao cancelar notificações da tarefa: $e');
    }
  }

  /// Cancel all scheduled task notifications
  @override
  Future<void> cancelAllTaskNotifications() async {
    try {
      await _notificationService.cancelAllNotifications();
    } catch (e) {
      debugPrint('Erro ao cancelar todas as notificações: $e');
    }
  }

  /// Internal: Schedule notification with platform-specific actions
  Future<void> _scheduleNotificationWithActions({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    List<Map<String, String>>? actions,
  }) async {
    try {
      NotificationHelper.createReminderNotification(
        appName: 'Plantis',
        id: id,
        title: title,
        body: body,
        payload: payload,
        color: TasksConstants.notificationColor,
        scheduledDate: scheduledDate,
      );
      await _notificationService.scheduleDirectNotification(
        notificationId: id,
        title: title,
        body: body,
        scheduledTime: scheduledDate,
        payload: payload,
      );

      debugPrint(
        '✅ Scheduled notification: $title at ${scheduledDate.toString()}',
      );
    } catch (e) {
      debugPrint('❌ Error scheduling notification: $e');
    }
  }

  /// Get notification title based on task type
  String _getNotificationTitle(task_entity.Task task) {
    switch (task.type) {
      case task_entity.TaskType.watering:
        return AppStrings.timeToWater;
      case task_entity.TaskType.fertilizing:
        return AppStrings.timeToFertilize;
      case task_entity.TaskType.pruning:
        return AppStrings.timeToPrune;
      case task_entity.TaskType.repotting:
        return AppStrings.timeToRepot;
      case task_entity.TaskType.cleaning:
        return AppStrings.timeToClean;
      case task_entity.TaskType.spraying:
        return AppStrings.timeToSpray;
      case task_entity.TaskType.sunlight:
        return AppStrings.timeForSunlight;
      case task_entity.TaskType.shade:
        return AppStrings.timeForShade;
      case task_entity.TaskType.pestInspection:
        return AppStrings.timeForInspection;
      case task_entity.TaskType.custom:
        return AppStrings.careReminder;
    }
  }

  /// Get notification body with priority emoji
  String _getNotificationBody(task_entity.Task task) {
    String priorityEmoji = '';
    switch (task.priority) {
      case task_entity.TaskPriority.urgent:
        priorityEmoji = AppStrings.urgentPriorityEmoji;
        break;
      case task_entity.TaskPriority.high:
        priorityEmoji = AppStrings.highPriorityEmoji;
        break;
      case task_entity.TaskPriority.medium:
        priorityEmoji = AppStrings.mediumPriorityEmoji;
        break;
      case task_entity.TaskPriority.low:
        priorityEmoji = AppStrings.lowPriorityEmoji;
        break;
    }
    return '${task.title}$priorityEmoji';
  }

  /// Get daily summary body text
  String _getDailySummaryBody(List<task_entity.Task> todayTasks) {
    final int totalTasks = todayTasks.length;
    final int urgentTasks = todayTasks
        .where((t) => t.priority == task_entity.TaskPriority.urgent)
        .length;

    if (totalTasks == 1) {
      return '${AppStrings.oneTaskToday}${todayTasks.first.title}';
    } else if (urgentTasks > 0) {
      return AppStrings.multipleTasksWithUrgent
          .replaceAll('%TOTAL%', '$totalTasks')
          .replaceAll('%URGENT%', '$urgentTasks');
    } else {
      return AppStrings.multipleTasksScheduled.replaceAll(
        '%TOTAL%',
        '$totalTasks',
      );
    }
  }

  /// Get scheduled notification time in user's timezone
  Future<DateTime> _getScheduledDateInUserTimezone(
    task_entity.Task task,
  ) async {
    try {
      final DateTime localDueDate = task.dueDate.toLocal();
      final DateTime notificationTime = localDueDate.subtract(
        TasksConstants.notificationAdvanceTime,
      );

      debugPrint(
        '🕐 Task "${task.title}" due at ${task.dueDate} (UTC) -> $localDueDate (local) -> notification at $notificationTime',
      );

      return notificationTime;
    } catch (e) {
      debugPrint(
        '❌ Error converting to local timezone, falling back to direct conversion: $e',
      );
      return task.dueDate.toLocal().subtract(
        TasksConstants.notificationAdvanceTime,
      );
    }
  }

  /// Create platform-specific notification actions
  List<Map<String, String>> _createTaskNotificationActions(
    task_entity.Task task,
  ) {
    return [
      {
        'id': TasksConstants.completeTaskActionId,
        'title': AppStrings.completeAction,
        'icon': Platform.isAndroid ? TasksConstants.androidCheckIcon : '',
      },
      {
        'id': TasksConstants.snoozeTaskActionId,
        'title': AppStrings.remindLaterAction,
        'icon': Platform.isAndroid ? TasksConstants.androidSnoozeIcon : '',
      },
      {
        'id': TasksConstants.viewDetailsActionId,
        'title': AppStrings.viewDetailsAction,
        'icon': Platform.isAndroid ? TasksConstants.androidInfoIcon : '',
      },
    ];
  }

  /// Create notification ID from identifier
  int _createNotificationId(String identifier) {
    return identifier.hashCode.abs() % TasksConstants.maxNotificationId;
  }

  /// Create notification payload
  String _createNotificationPayload(
    task_entity.Task task,
    PlantisNotificationType type,
  ) {
    final Map<String, dynamic> payload = {
      'type': type.value,
      'taskId': task.id,
      'plantId': task.plantId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    return jsonEncode(payload);
  }

  /// Create daily summary payload
  String _createDailySummaryPayload(List<task_entity.Task> tasks) {
    final Map<String, dynamic> payload = {
      'type': PlantisNotificationType.dailyCareReminder.value,
      'taskIds': tasks.map((t) => t.id).toList(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    return jsonEncode(payload);
  }
}
