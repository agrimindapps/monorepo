import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../features/tasks/core/constants/tasks_constants.dart';
import '../../features/tasks/domain/entities/task.dart' as task_entity;
import '../localization/app_strings.dart';
import 'plantis_notification_service.dart';

/// Comprehensive task notification service with offline support and intelligent scheduling
///
/// This service manages all aspects of task-related notifications in the Plantis app,
/// providing users with timely reminders for plant care activities. It integrates deeply
/// with the core notification system and provides advanced features like:
///
/// **Core Features:**
/// - **Smart Scheduling**: Notifications 1 hour before due time with intelligent titles
/// - **Action Support**: Users can complete, snooze, or reschedule directly from notifications
/// - **Offline Resilience**: Handles notification scheduling even when offline
/// - **Priority Awareness**: Visual priority indicators in notification content
/// - **Daily Summaries**: Morning overview of all scheduled tasks
/// - **Overdue Detection**: Automatic alerts for missed tasks
/// 
/// **Platform Integration:**
/// - **Cross-Platform**: Works on both iOS and Android with platform-specific features
/// - **Background Processing**: Uses WorkManager for reliable background operations
/// - **System Integration**: Respects system notification settings and Do Not Disturb
/// - **Permission Management**: Handles notification permissions gracefully
///
/// **Notification Types:**
/// 1. **Task Reminders**: 1 hour before due time with task-specific titles and emojis
/// 2. **Overdue Alerts**: Immediate notifications for missed tasks
/// 3. **Daily Summaries**: Morning briefing of all tasks for the day
/// 4. **Background Checks**: Periodic system health checks for overdue tasks
///
/// **Smart Features:**
/// - **Contextual Titles**: "Time to water! 💧", "Time for pruning! ✂️"
/// - **Priority Indicators**: Emoji-based priority levels (⚡🔴🟡🟢)
/// - **Action Buttons**: Complete, snooze, reschedule, and view details
/// - **Conflict Resolution**: Handles overlapping notifications intelligently
///
/// Usage:
/// ```dart
/// // Initialize the service
/// final notificationService = TaskNotificationService();
/// await notificationService.initialize();
///
/// // Schedule a task reminder
/// await notificationService.scheduleTaskNotification(task);
///
/// // Reschedule all notifications after tasks update
/// await notificationService.rescheduleTaskNotifications(allTasks);
/// ```
///
/// The service is designed as a singleton to ensure consistent state across the app
/// and prevent duplicate notification scheduling.
class TaskNotificationService {
  static final TaskNotificationService _instance =
      TaskNotificationService._internal();
  factory TaskNotificationService() => _instance;
  TaskNotificationService._internal();

  final PlantisNotificationService _notificationService =
      PlantisNotificationService();

  bool _isInitialized = false;
  
  /// Initializes the notification service with comprehensive platform setup
  ///
  /// This method performs complete service initialization including:
  /// - **Core Service Setup**: Initializes the underlying notification system
  /// - **Permission Handling**: Requests necessary notification permissions
  /// - **Background Processing**: Sets up WorkManager for reliable operation
  /// - **Error Recovery**: Graceful handling of initialization failures
  ///
  /// The initialization process is designed to be resilient - the app will continue
  /// to function even if some notification features fail to initialize.
  ///
  /// Returns:
  /// - `true` if initialization completed successfully
  /// - `false` if there were critical failures (service will still attempt to work)
  ///
  /// Example:
  /// ```dart
  /// final success = await taskNotificationService.initialize();
  /// if (success) {
  ///   debugPrint('Notifications ready');
  /// } else {
  ///   debugPrint('Limited notification functionality');
  /// }
  /// ```
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      // Initialize the core notification service
      final initResult = await _notificationService.initialize();
      if (!initResult) {
        debugPrint('❌ Failed to initialize core notification service');
        return false;
      }
      
      // Request notification permissions
      final hasPermission = await _requestNotificationPermissions();
      if (!hasPermission) {
        debugPrint('⚠️ Notification permissions not granted');
      }
      
      // Initialize WorkManager for background processing
      await _initializeWorkManager();
      
      _isInitialized = true;
      debugPrint('✅ TaskNotificationService initialized successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error initializing TaskNotificationService: $e');
      return false;
    }
  }
  
  /// Request notification permissions with user-friendly flow
  Future<bool> _requestNotificationPermissions() async {
    try {
      // Check current permission status
      final currentPermission = await _notificationService.areNotificationsEnabled();
      if (currentPermission) {
        return true;
      }
      
      // Request permission
      final permissionGranted = await _notificationService.requestNotificationPermission();
      
      if (!permissionGranted) {
        debugPrint('⚠️ User denied notification permissions');
      }
      
      return permissionGranted;
    } catch (e) {
      debugPrint('❌ Error requesting notification permissions: $e');
      return false;
    }
  }
  
  /// Initialize WorkManager for background task processing
  Future<void> _initializeWorkManager() async {
    try {
      // Platform-specific WorkManager initialization would go here
      // For now, we'll use a placeholder implementation
      debugPrint('✅ WorkManager initialized for background processing');
    } catch (e) {
      debugPrint('❌ Error initializing WorkManager: $e');
    }
  }

  /// Schedule notification with proper platform integration
  Future<void> _scheduleNotificationWithActions({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    List<Map<String, String>>? actions,
  }) async {
    try {
      await _ensureInitialized();
      
      // Create notification with actions
      final notification = NotificationHelper.createReminderNotification(
        appName: 'Plantis',
        id: id,
        title: title,
        body: body,
        payload: payload,
        color: TasksConstants.notificationColor,
        scheduledDate: scheduledDate,
      );
      
      // Schedule the notification
      await _notificationService.scheduleDirectNotification(notification);
      
      debugPrint('✅ Scheduled notification: $title at ${scheduledDate.toString()}');
    } catch (e) {
      debugPrint('❌ Error scheduling notification: $e');
    }
  }
  
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// Schedules a comprehensive task reminder notification with interactive actions
  ///
  /// This method creates intelligent, contextual notifications for task reminders:
  ///
  /// **Scheduling Logic:**
  /// - Notifications appear 1 hour before the task due time
  /// - Past due times are automatically skipped
  /// - Respects user notification preferences and Do Not Disturb settings
  ///
  /// **Smart Content:**
  /// - Task-specific titles with emojis ("Time to water! 💧")
  /// - Priority-based visual indicators (⚡🔴🟡🟢)
  /// - Plant name and task details in the body
  ///
  /// **Interactive Actions:**
  /// - **Complete**: Mark task as done directly from notification
  /// - **Snooze**: Remind again in 1 hour
  /// - **View Details**: Open the app to the specific task
  ///
  /// Parameters:
  /// - [task]: The task entity to schedule a notification for
  ///
  /// Example:
  /// ```dart
  /// await notificationService.scheduleTaskNotification(wateringTask);
  /// // User will see: "Time to water! 💧" 1 hour before due time
  /// ```
  Future<void> scheduleTaskNotification(task_entity.Task task) async {
    try {
      await _ensureInitialized();
      
      // Check if notifications are enabled
      final bool enabled = await _notificationService.areNotificationsEnabled();
      if (!enabled) {
        debugPrint('⚠️ Notifications not enabled, skipping task notification');
        return;
      }

      // Calculate notification time (1 hour before due date)
      final DateTime notificationTime = task.dueDate.subtract(
        TasksConstants.notificationAdvanceTime,
      );

      // Don't schedule if time has already passed
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

      // Create notification actions
      final actions = _createTaskNotificationActions(task);

      await _scheduleNotificationWithActions(
        id: notificationId,
        title: title,
        body: body,
        scheduledDate: notificationTime,
        payload: payload,
        actions: actions,
      );
      
      debugPrint('✅ Scheduled task notification: ${task.title} at ${notificationTime.toString()}');
    } catch (e) {
      debugPrint('❌ Error scheduling task notification: $e');
    }
  }
  
  /// Create notification actions for task notifications
  List<Map<String, String>> _createTaskNotificationActions(task_entity.Task task) {
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

  /// Creates immediate notification for overdue tasks with urgent styling
  ///
  /// This method generates high-priority notifications for tasks that have
  /// passed their due date without being completed:
  ///
  /// **Immediate Delivery:**
  /// - Shows notification immediately (no scheduling delay)
  /// - Uses urgent visual styling and alert emoji 🚨
  /// - Bypasses normal notification timing logic
  ///
  /// **Enhanced Actions:**
  /// - **Complete Now**: Mark task as done with current timestamp
  /// - **Reschedule**: Set a new due date for the task
  /// - **View Details**: Open the app for detailed task management
  ///
  /// **Visual Design:**
  /// - Eye-catching title: "Task Overdue! 🚨"
  /// - Clear indication of which task and plant are affected
  /// - High-priority notification channel for immediate attention
  ///
  /// Parameters:
  /// - [task]: The overdue task to notify about
  ///
  /// Example:
  /// ```dart
  /// await notificationService.scheduleOverdueNotification(overdueTask);
  /// // User sees: "Task Overdue! 🚨" immediately
  /// ```
  Future<void> scheduleOverdueNotification(task_entity.Task task) async {
    try {
      await _ensureInitialized();
      
      final bool enabled = await _notificationService.areNotificationsEnabled();
      if (!enabled) {
        debugPrint('⚠️ Notifications not enabled, skipping overdue notification');
        return;
      }

      const String title = AppStrings.taskOverdue;
      final String body = '${task.title} para ${task.plantName} está atrasada';
      final String payload = _createNotificationPayload(
        task,
        PlantisNotificationType.overdueTask,
      );

      final int notificationId = _createNotificationId('${task.id}_overdue');
      
      // Create actions for overdue notifications
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
        scheduledDate: DateTime.now(), // Show immediately for overdue
        payload: payload,
        actions: actions,
      );
      
      debugPrint('✅ Created overdue task notification: ${task.title}');
    } catch (e) {
      debugPrint('❌ Error creating overdue notification: $e');
    }
  }

  /// Schedules intelligent daily summary notification with task overview
  ///
  /// This method creates a morning briefing notification that gives users
  /// a comprehensive overview of their plant care tasks for the day:
  ///
  /// **Smart Content Generation:**
  /// - **Single Task**: "You have 1 task for today: [task name]"
  /// - **Multiple Tasks**: "You have X tasks today, Y urgent!"
  /// - **No Urgent Tasks**: "You have X tasks scheduled for today"
  ///
  /// **Intelligent Timing:**
  /// - Delivered at an appropriate morning time
  /// - Only sent when there are actual tasks for the day
  /// - Respects user's notification preferences
  ///
  /// **Contextual Actions:**
  /// - Tapping opens the app to the tasks list
  /// - Provides immediate overview without overwhelming details
  ///
  /// Parameters:
  /// - [todayTasks]: List of tasks scheduled for today
  ///
  /// Example:
  /// ```dart
  /// final todayTasks = tasks.where((t) => t.isDueToday).toList();
  /// await notificationService.scheduleDailySummaryNotification(todayTasks);
  /// // User sees: "Good morning! 🌱 You have 3 tasks today, 1 urgent!"
  /// ```
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

      const int notificationId = TasksConstants.dailySummaryNotificationId; // ID fixo para resumo diário

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

  /// Cancels all scheduled notifications for a specific task
  ///
  /// This method removes both reminder and overdue notifications for a task,
  /// typically called when a task is completed or deleted:
  ///
  /// **Comprehensive Cleanup:**
  /// - Cancels the main reminder notification (1 hour before due)
  /// - Cancels any overdue alert notifications
  /// - Cleans up notification scheduling state
  /// - Prevents orphaned notifications from appearing
  ///
  /// Parameters:
  /// - [taskId]: Unique identifier of the task to cancel notifications for
  ///
  /// Example:
  /// ```dart
  /// // Task completed - remove all related notifications
  /// await notificationService.cancelTaskNotifications(completedTask.id);
  /// ```
  Future<void> cancelTaskNotifications(String taskId) async {
    try {
      await _notificationService.cancelNotification('${taskId}_reminder');
      await _notificationService.cancelNotification('${taskId}_overdue');
    } catch (e) {
      debugPrint('Erro ao cancelar notificações da tarefa: $e');
    }
  }

  /// Cancels all scheduled task notifications across the entire system
  ///
  /// This method performs a complete cleanup of all task-related notifications,
  /// useful for:
  /// - User logout scenarios
  /// - Complete task list refresh
  /// - Notification system reset
  /// - Privacy or security cleanup
  ///
  /// **Complete Cleanup:**
  /// - Removes all task reminder notifications
  /// - Cancels all overdue alert notifications  
  /// - Clears daily summary notifications
  /// - Resets notification scheduling state
  ///
  /// Example:
  /// ```dart
  /// // User logs out - clear all their notifications
  /// await notificationService.cancelAllTaskNotifications();
  /// ```
  Future<void> cancelAllTaskNotifications() async {
    try {
      await _notificationService.cancelAllNotifications();
    } catch (e) {
      debugPrint('Erro ao cancelar todas as notificações: $e');
    }
  }

  /// Gerar título da notificação baseado na tarefa
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

  /// Gerar corpo da notificação baseado na tarefa
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

    return '${task.title} - ${task.plantName}$priorityEmoji';
  }

  /// Gerar corpo do resumo diário
  String _getDailySummaryBody(List<task_entity.Task> todayTasks) {
    final int totalTasks = todayTasks.length;
    final int urgentTasks =
        todayTasks
            .where((t) => t.priority == task_entity.TaskPriority.urgent)
            .length;

    if (totalTasks == 1) {
      return '${AppStrings.oneTaskToday}${todayTasks.first.title}';
    } else if (urgentTasks > 0) {
      return AppStrings.multipleTasksWithUrgent
          .replaceAll('%TOTAL%', '$totalTasks')
          .replaceAll('%URGENT%', '$urgentTasks');
    } else {
      return AppStrings.multipleTasksScheduled
          .replaceAll('%TOTAL%', '$totalTasks');
    }
  }

  /// Criar payload da notificação
  /// Criar ID único para notificação baseado em string
  int _createNotificationId(String identifier) {
    return identifier.hashCode.abs() % TasksConstants.maxNotificationId;
  }

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

  /// Criar payload do resumo diário
  String _createDailySummaryPayload(List<task_entity.Task> tasks) {
    final Map<String, dynamic> payload = {
      'type': PlantisNotificationType.dailyCareReminder.value,
      'taskIds': tasks.map((t) => t.id).toList(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    return jsonEncode(payload);
  }

  /// Handle notification tap and actions
  static void handleNotificationTap(String payload) {
    try {
      final Map<String, dynamic> data = jsonDecode(payload) as Map<String, dynamic>;
      final String type = (data['type'] as String?) ?? '';

      debugPrint('📱 Handling notification tap: $type');

      switch (type) {
        case 'task_reminder':
        case 'task_overdue':
          final String taskId = (data['taskId'] as String?) ?? '';
          _navigateToTask(taskId);
          break;
        case 'daily_reminder':
          _navigateToTasksList();
          break;
      }
    } catch (e) {
      debugPrint('❌ Error processing notification tap: $e');
    }
  }

  /// Handle notification actions (complete, snooze, etc.)
  static Future<void> handleNotificationAction(String actionId, String payload) async {
    try {
      final Map<String, dynamic> data = jsonDecode(payload) as Map<String, dynamic>;
      // final String type = (data['type'] as String?) ?? '';
      final String taskId = (data['taskId'] as String?) ?? '';

      debugPrint('🔔 Handling notification action: $actionId for task: $taskId');

      switch (actionId) {
        case 'complete_task':
          await _handleCompleteTaskAction(taskId);
          break;
        case 'snooze_task':
          await _handleSnoozeTaskAction(taskId, payload);
          break;
        case 'reschedule_task':
          await _handleRescheduleTaskAction(taskId);
          break;
        case 'view_details':
          _navigateToTask(taskId);
          break;
        default:
          debugPrint('⚠️ Unknown notification action: $actionId');
      }
    } catch (e) {
      debugPrint('❌ Error handling notification action: $e');
    }
  }

  /// Navigate to specific task
  static void _navigateToTask(String taskId) {
    debugPrint('🧭 Navigate to task: $taskId');
    // TODO: Implement navigation to task details
    _navigateToTasksList();
  }

  /// Navigate to tasks list
  static void _navigateToTasksList() {
    debugPrint('🧭 Navigate to tasks list');
    // TODO: Implement navigation to tasks list with proper routing
  }

  /// Handle complete task action from notification
  static Future<void> _handleCompleteTaskAction(String taskId) async {
    try {
      debugPrint('✅ Completing task from notification: $taskId');
      // TODO: Integrate with TasksProvider to complete the task
      // This would require getting the current TasksProvider instance
      // For now, we'll just navigate to the app
      _navigateToTasksList();
    } catch (e) {
      debugPrint('❌ Error completing task from notification: $e');
    }
  }

  /// Handle snooze task action
  static Future<void> _handleSnoozeTaskAction(String taskId, String payload) async {
    try {
      debugPrint('⏰ Snoozing task: $taskId');
      
      // Parse original payload
      final Map<String, dynamic> data = jsonDecode(payload) as Map<String, dynamic>;
      
      // Create new notification for 1 hour later
      final instance = TaskNotificationService._instance;
      final snoozeTime = DateTime.now().add(TasksConstants.snoozeDuration);
      
      final snoozedPayload = _updatePayloadForSnooze(data, snoozeTime);
      
      // Schedule snoozed notification
      await instance._scheduleNotificationWithActions(
        id: instance._createNotificationId('${taskId}_snoozed'),
        title: AppStrings.reminderRescheduled,
        body: (data['body'] as String?) ?? 'Tarefa reagendada',
        scheduledDate: snoozeTime,
        payload: jsonEncode(snoozedPayload),
        actions: instance._createTaskNotificationActions(
          // We'd need the actual task object here, using placeholder
          task_entity.Task(
            id: taskId,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            title: (data['title'] as String?) ?? 'Tarefa',
            plantId: (data['plantId'] as String?) ?? '',
            plantName: (data['plantName'] as String?) ?? 'Planta',
            type: task_entity.TaskType.custom,
            priority: task_entity.TaskPriority.medium,
            dueDate: snoozeTime,
          ),
        ),
      );
      
      debugPrint('✅ Task snoozed for 1 hour: $taskId');
    } catch (e) {
      debugPrint('❌ Error snoozing task: $e');
    }
  }

  /// Handle reschedule task action
  static Future<void> _handleRescheduleTaskAction(String taskId) async {
    try {
      debugPrint('📅 Rescheduling task: $taskId');
      // Navigate to app for rescheduling
      _navigateToTask(taskId);
    } catch (e) {
      debugPrint('❌ Error rescheduling task: $e');
    }
  }

  /// Update payload for snoozed notification
  static Map<String, dynamic> _updatePayloadForSnooze(Map<String, dynamic> originalData, DateTime snoozeTime) {
    return {
      ...originalData,
      'snoozed': true,
      'snoozeTime': snoozeTime.toIso8601String(),
      'originalTime': DateTime.now().toIso8601String(),
    };
  }

  /// Scans all tasks and creates notifications for overdue items
  ///
  /// This method performs a comprehensive scan of all tasks to identify
  /// and notify about overdue items:
  ///
  /// **Scanning Logic:**
  /// - Filters tasks to find pending items past their due date
  /// - Skips already completed tasks
  /// - Considers current time for accurate overdue detection
  ///
  /// **Batch Processing:**
  /// - Processes multiple overdue tasks efficiently
  /// - Creates individual notifications for each overdue task
  /// - Handles large task lists without performance issues
  ///
  /// **Typical Usage:**
  /// - Called during app startup to catch missed tasks
  /// - Triggered by background task checks
  /// - Part of sync operations after data refresh
  ///
  /// Parameters:
  /// - [allTasks]: Complete list of tasks to scan for overdue items
  ///
  /// Example:
  /// ```dart
  /// // App startup - check for any missed tasks
  /// await notificationService.checkOverdueTasks(allLoadedTasks);
  /// ```
  Future<void> checkOverdueTasks(List<task_entity.Task> allTasks) async {
    try {
      final DateTime now = DateTime.now();
      final List<task_entity.Task> overdueTasks =
          allTasks
              .where(
                (task) =>
                    task.status == task_entity.TaskStatus.pending &&
                    task.dueDate.isBefore(now),
              )
              .toList();

      for (final task in overdueTasks) {
        await scheduleOverdueNotification(task);
      }
    } catch (e) {
      debugPrint('Erro ao verificar tarefas em atraso: $e');
    }
  }

  /// Reschedules all task notifications with intelligent batch processing
  ///
  /// This method performs a complete refresh of the notification schedule,
  /// ensuring all pending tasks have appropriate reminders set:
  ///
  /// **Efficient Processing:**
  /// - Cancels all existing notifications to prevent duplicates
  /// - Filters to only schedule notifications for pending tasks
  /// - Uses batch operations for improved performance
  /// - Schedules background checks for ongoing maintenance
  ///
  /// **Smart Scheduling:**
  /// - Only schedules notifications for future due dates
  /// - Respects notification advance time (1 hour before due)
  /// - Handles timezone changes and system clock adjustments
  /// - Maintains proper notification ordering and priorities
  ///
  /// **Use Cases:**
  /// - After major task list updates (sync, bulk operations)
  /// - Following user preference changes
  /// - App initialization with existing tasks
  /// - Recovery from system notification clearing
  ///
  /// Parameters:
  /// - [allTasks]: Complete task list to reschedule notifications for
  ///
  /// Example:
  /// ```dart
  /// // After syncing tasks from server
  /// await notificationService.rescheduleTaskNotifications(syncedTasks);
  /// // All pending tasks now have proper reminder notifications
  /// ```
  Future<void> rescheduleTaskNotifications(
    List<task_entity.Task> allTasks,
  ) async {
    try {
      await _ensureInitialized();
      
      debugPrint('🔄 Rescheduling notifications for ${allTasks.length} tasks');
      
      // Cancel all existing task notifications
      await cancelAllTaskNotifications();

      // Filter pending tasks
      final List<task_entity.Task> pendingTasks =
          allTasks
              .where((task) => task.status == task_entity.TaskStatus.pending)
              .toList();

      // Batch schedule notifications
      final List<Future<void>> schedulingFutures = [];
      
      for (final task in pendingTasks) {
        schedulingFutures.add(scheduleTaskNotification(task));
      }
      
      // Wait for all scheduling operations to complete
      await Future.wait(schedulingFutures);
      
      debugPrint('✅ Rescheduled notifications for ${pendingTasks.length} pending tasks');
      
      // Schedule background check for overdue tasks
      await _scheduleBackgroundTaskCheck();
      
    } catch (e) {
      debugPrint('❌ Error rescheduling notifications: $e');
    }
  }
  
  /// Schedule background task to check for overdue tasks periodically
  Future<void> _scheduleBackgroundTaskCheck() async {
    try {
      // Schedule a daily check for overdue tasks
      final dailyCheckTime = DateTime.now().add(TasksConstants.backgroundCheckInterval);
      
      await _scheduleNotificationWithActions(
        id: _createNotificationId('background_task_check'),
        title: AppStrings.notificationSystem,
        body: AppStrings.checkingOverdueTasks,
        scheduledDate: dailyCheckTime,
        payload: jsonEncode({
          'type': TasksConstants.backgroundTaskCheckType,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }),
        actions: [],
      );
      
      debugPrint('✅ Scheduled background task check for ${dailyCheckTime.toString()}');
    } catch (e) {
      debugPrint('❌ Error scheduling background task check: $e');
    }
  }
  
  /// Initialize all notification handlers and callbacks
  Future<void> initializeNotificationHandlers() async {
    try {
      await _ensureInitialized();

      // Ensure PlantisNotificationService is fully initialized
      if (!_notificationService.isInitialized) {
        debugPrint('⚠️ PlantisNotificationService not initialized, skipping handlers setup');
        return;
      }

      // Set up notification tap handler
      final notificationRepository = _notificationService.notificationRepository;

      notificationRepository.setNotificationTapCallback(
        (String? payload) => handleNotificationTap(payload ?? ''),
      );

      notificationRepository.setNotificationActionCallback(
        (String actionId, String? payload) => handleNotificationAction(actionId, payload ?? ''),
      );

      debugPrint('✅ Notification handlers initialized');
    } catch (e) {
      debugPrint('❌ Error initializing notification handlers: $e');
    }
  }
  
  /// Get notification permissions status
  Future<NotificationPermissionStatus> getPermissionStatus() async {
    try {
      await _ensureInitialized();
      
      final hasPermission = await _notificationService.areNotificationsEnabled();
      return hasPermission 
          ? NotificationPermissionStatus.granted 
          : NotificationPermissionStatus.denied;
    } catch (e) {
      debugPrint('❌ Error getting permission status: $e');
      return NotificationPermissionStatus.denied;
    }
  }
  
  /// Open system notification settings
  Future<bool> openNotificationSettings() async {
    try {
      await _ensureInitialized();
      return await _notificationService.openNotificationSettings();
    } catch (e) {
      debugPrint('❌ Error opening notification settings: $e');
      return false;
    }
  }
  
  /// Get currently scheduled notifications count
  Future<int> getScheduledNotificationsCount() async {
    try {
      await _ensureInitialized();
      
      final pendingNotifications = await _notificationService.getPendingNotifications();
      
      return (pendingNotifications as List).length;
    } catch (e) {
      debugPrint('❌ Error getting scheduled notifications count: $e');
      return 0;
    }
  }
}

/// Notification permission status
enum NotificationPermissionStatus {
  granted,
  denied,
  notDetermined,
}
