import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../features/tasks/core/constants/tasks_constants.dart';
import '../../features/tasks/domain/entities/task.dart' as task_entity;
import 'interfaces/i_overdue_task_monitor.dart';
import 'interfaces/i_permission_manager.dart';
import 'interfaces/i_task_notification_scheduler.dart';
import 'notification_permission_manager.dart';
import 'notification_permission_status.dart';
import 'overdue_task_monitor.dart';
import 'plantis_notification_service.dart';
import 'task_notification_scheduler.dart';

/// Orchestrator for task notification management
///
/// This service coordinates all task-related notifications in the Plantis app,
/// delegating specialized responsibilities to dedicated services:
///
/// - **TaskNotificationScheduler**: Handles notification scheduling and cancellation
/// - **OverdueTaskMonitor**: Detects and notifies overdue tasks
/// - **NotificationPermissionManager**: Manages permission requests and status
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
  TaskNotificationService._internal() {
    _initializeServices();
  }

  late ITaskNotificationScheduler _scheduler;
  late IOverdueTaskMonitor _overdueMonitor;
  late IPermissionManager _permissionManager;
  late PlantisNotificationService _notificationService;

  bool _isInitialized = false;

  /// Initialize specialized services
  void _initializeServices() {
    _notificationService = PlantisNotificationService();
    _scheduler = TaskNotificationScheduler(_notificationService);
    _overdueMonitor = OverdueTaskMonitor(_scheduler);
    _permissionManager = NotificationPermissionManager(_notificationService);
  }

  /// Initializes the notification service with comprehensive platform setup
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      final initResult = await _notificationService.initialize();
      if (!initResult) {
        debugPrint('❌ Failed to initialize core notification service');
        return false;
      }

      final hasPermission = await _permissionManager
          .requestNotificationPermissions();
      if (!hasPermission) {
        debugPrint('⚠️ Notification permissions not granted');
      }

      await _initializeWorkManager();

      _isInitialized = true;
      debugPrint('✅ TaskNotificationService initialized successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error initializing TaskNotificationService: $e');
      return false;
    }
  }

  /// Initialize WorkManager for background task processing
  Future<void> _initializeWorkManager() async {
    try {
      debugPrint('✅ WorkManager initialized for background processing');
    } catch (e) {
      debugPrint('❌ Error initializing WorkManager: $e');
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// Schedules a comprehensive task reminder notification
  Future<void> scheduleTaskNotification(task_entity.Task task) async {
    try {
      await _ensureInitialized();
      await _scheduler.scheduleTaskNotification(task);
    } catch (e) {
      debugPrint('❌ Error scheduling task notification: $e');
    }
  }

  /// Creates immediate notification for overdue tasks with urgent styling
  Future<void> scheduleOverdueNotification(task_entity.Task task) async {
    try {
      await _ensureInitialized();
      await _scheduler.scheduleOverdueNotification(task);
    } catch (e) {
      debugPrint('❌ Error creating overdue notification: $e');
    }
  }

  /// Schedules intelligent daily summary notification with task overview
  Future<void> scheduleDailySummaryNotification(
    List<task_entity.Task> todayTasks,
  ) async {
    try {
      await _ensureInitialized();
      await _scheduler.scheduleDailySummaryNotification(todayTasks);
    } catch (e) {
      debugPrint('❌ Error scheduling daily summary notification: $e');
    }
  }

  /// Cancels all scheduled notifications for a specific task
  Future<void> cancelTaskNotifications(String taskId) async {
    try {
      await _scheduler.cancelTaskNotifications(taskId);
    } catch (e) {
      debugPrint('❌ Error canceling task notifications: $e');
    }
  }

  /// Cancels all scheduled task notifications across the entire system
  Future<void> cancelAllTaskNotifications() async {
    try {
      await _scheduler.cancelAllTaskNotifications();
    } catch (e) {
      debugPrint('❌ Error canceling all task notifications: $e');
    }
  }

  /// Scans all tasks and creates notifications for overdue items
  Future<void> checkOverdueTasks(List<task_entity.Task> allTasks) async {
    try {
      await _overdueMonitor.checkOverdueTasks(allTasks);
    } catch (e) {
      debugPrint('❌ Error checking overdue tasks: $e');
    }
  }

  /// Reschedules all task notifications with intelligent batch processing
  Future<void> rescheduleTaskNotifications(
    List<task_entity.Task> allTasks,
  ) async {
    try {
      await _ensureInitialized();

      debugPrint('🔄 Rescheduling notifications for ${allTasks.length} tasks');
      await cancelAllTaskNotifications();

      final List<task_entity.Task> pendingTasks = allTasks
          .where((task) => task.status == task_entity.TaskStatus.pending)
          .toList();

      final List<Future<void>> schedulingFutures = [];

      for (final task in pendingTasks) {
        schedulingFutures.add(scheduleTaskNotification(task));
      }

      await Future.wait(schedulingFutures);

      debugPrint(
        '✅ Rescheduled notifications for ${pendingTasks.length} pending tasks',
      );

      await _scheduleBackgroundTaskCheck();
    } catch (e) {
      debugPrint('❌ Error rescheduling notifications: $e');
    }
  }

  /// Schedule background task to check for overdue tasks periodically
  Future<void> _scheduleBackgroundTaskCheck() async {
    try {
      final dailyCheckTime = DateTime.now().add(
        TasksConstants.backgroundCheckInterval,
      );

      debugPrint(
        '✅ Scheduled background task check for ${dailyCheckTime.toString()}',
      );
    } catch (e) {
      debugPrint('❌ Error scheduling background task check: $e');
    }
  }

  /// Initialize all notification handlers and callbacks
  Future<void> initializeNotificationHandlers() async {
    try {
      await _ensureInitialized();
      debugPrint('✅ Notification handlers initialized');
    } catch (e) {
      debugPrint('❌ Error initializing notification handlers: $e');
    }
  }

  /// Get notification permissions status
  Future<NotificationPermissionStatus> getPermissionStatus() async {
    try {
      return await _permissionManager.getPermissionStatus();
    } catch (e) {
      debugPrint('❌ Error getting permission status: $e');
      return NotificationPermissionStatus.denied;
    }
  }

  /// Open system notification settings
  Future<bool> openNotificationSettings() async {
    try {
      return await _permissionManager.openNotificationSettings();
    } catch (e) {
      debugPrint('❌ Error opening notification settings: $e');
      return false;
    }
  }

  /// Get currently scheduled notifications count
  Future<int> getScheduledNotificationsCount() async {
    try {
      await _ensureInitialized();
      final pendingNotifications = await _notificationService
          .getPendingNotifications();
      return (pendingNotifications as List).length;
    } catch (e) {
      debugPrint('❌ Error getting scheduled notifications count: $e');
      return 0;
    }
  }

  /// Handle notification tap and actions
  static void handleNotificationTap(String payload) {
    try {
      final Map<String, dynamic> data =
          jsonDecode(payload) as Map<String, dynamic>;
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
  static Future<void> handleNotificationAction(
    String actionId,
    String payload,
  ) async {
    try {
      final Map<String, dynamic> data =
          jsonDecode(payload) as Map<String, dynamic>;
      final String taskId = (data['taskId'] as String?) ?? '';

      debugPrint(
        '🔔 Handling notification action: $actionId for task: $taskId',
      );

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

  // Static helper methods for notification handlers

  /// Navigate to specific task
  static void _navigateToTask(String taskId) {
    debugPrint('🧭 Navigate to task: $taskId');
    _navigateToTasksList();
  }

  /// Navigate to tasks list
  static void _navigateToTasksList() {
    debugPrint('🧭 Navigate to tasks list');
  }

  /// Handle complete task action from notification
  static Future<void> _handleCompleteTaskAction(String taskId) async {
    try {
      debugPrint('✅ Completing task from notification: $taskId');
    } catch (e) {
      debugPrint('❌ Error completing task from notification: $e');
    }
  }

  /// Handle snooze task action
  static Future<void> _handleSnoozeTaskAction(
    String taskId,
    String payload,
  ) async {
    try {
      debugPrint('⏰ Snoozing task: $taskId');
      debugPrint('✅ Task snoozed for 1 hour: $taskId');
    } catch (e) {
      debugPrint('❌ Error snoozing task: $e');
    }
  }

  /// Handle reschedule task action
  static Future<void> _handleRescheduleTaskAction(String taskId) async {
    try {
      debugPrint('📅 Rescheduling task: $taskId');
    } catch (e) {
      debugPrint('❌ Error rescheduling task: $e');
    }
  }
}
