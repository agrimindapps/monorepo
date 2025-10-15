import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Service for managing local notifications in NebulaList
/// Uses EnhancedNotificationService from core package
@lazySingleton
class NotificationService {
  final IEnhancedNotificationRepository _notificationRepo;

  NotificationService(this._notificationRepo);

  /// Schedule a reminder for a list
  ///
  /// [listId] - ID of the list
  /// [listName] - Name of the list to show in notification
  /// [reminderTime] - When to show the notification
  Future<void> scheduleListReminder({
    required String listId,
    required String listName,
    required DateTime reminderTime,
  }) async {
    try {
      // Use list ID hashCode as notification ID
      final notificationId = listId.hashCode;

      final notification = NotificationEntity(
        id: notificationId,
        title: '📋 Lembrete: $listName',
        body: 'Você tem itens pendentes nesta lista',
        scheduledDate: reminderTime,
        payload: 'list_reminder:$listId', // Simple string payload
      );

      await _notificationRepo.scheduleNotification(notification);
    } catch (e) {
      // Log error but don't throw - notifications are not critical
      debugPrint('[NotificationService] Error scheduling reminder: $e');
    }
  }

  /// Cancel a scheduled list reminder
  ///
  /// [listId] - ID of the list
  Future<void> cancelListReminder(String listId) async {
    try {
      final notificationId = listId.hashCode;
      await _notificationRepo.cancelNotification(notificationId);
    } catch (e) {
      debugPrint('[NotificationService] Error canceling reminder: $e');
    }
  }

  /// Show immediate notification when a list is completed
  ///
  /// [listName] - Name of the completed list
  Future<void> notifyListCompleted({required String listName}) async {
    try {
      final notification = NotificationEntity(
        id: DateTime.now().millisecondsSinceEpoch,
        title: '🎉 Lista concluída!',
        body: 'Parabéns! Você completou "$listName"',
      );

      await _notificationRepo.showNotification(notification);
    } catch (e) {
      debugPrint('[NotificationService] Error showing completion notification: $e');
    }
  }

  /// Schedule a recurring reminder for a list
  ///
  /// [listId] - ID of the list
  /// [listName] - Name of the list
  /// [frequency] - How often to remind (daily, weekly, etc)
  /// [startDate] - When to start reminders
  Future<void> scheduleRecurringListReminder({
    required String listId,
    required String listName,
    required RecurrenceFrequency frequency,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    try {
      final baseNotification = NotificationRequest(
        id: listId,
        title: '📋 Lembrete: $listName',
        body: 'Você tem itens pendentes nesta lista',
        data: {
          'list_id': listId,
          'type': 'list_reminder',
        },
      );

      final request = RecurringNotificationRequest(
        baseNotification: baseNotification,
        recurrenceRule: RecurrenceRule(frequency: frequency),
        startDate: startDate,
        endDate: endDate,
      );

      await _notificationRepo.scheduleRecurring(request);
    } catch (e) {
      debugPrint('[NotificationService] Error scheduling recurring reminder: $e');
    }
  }

  /// Check if list has scheduled reminder
  ///
  /// [listId] - ID of the list to check
  /// Returns true if list has active reminder
  Future<bool> hasScheduledReminder(String listId) async {
    try {
      final scheduled = await _notificationRepo.getScheduledNotifications();
      final notificationId = listId.hashCode;

      return scheduled.any((notification) => notification.id == notificationId);
    } catch (e) {
      debugPrint('[NotificationService] Error checking scheduled reminders: $e');
      return false;
    }
  }

  /// Get all scheduled reminders for lists
  Future<List<ScheduledNotification>> getScheduledListReminders() async {
    try {
      final scheduled = await _notificationRepo.getScheduledNotifications();

      // Filter only list reminders
      return scheduled.where((notification) {
        final type = notification.data['type'];
        return type == 'list_reminder';
      }).toList();
    } catch (e) {
      debugPrint('[NotificationService] Error getting scheduled reminders: $e');
      return [];
    }
  }

  /// Cancel all list reminders
  Future<void> cancelAllListReminders() async {
    try {
      final listReminders = await getScheduledListReminders();
      final ids = listReminders.map((n) => n.id).toList();

      if (ids.isNotEmpty) {
        await _notificationRepo.cancelBatch(ids);
      }
    } catch (e) {
      debugPrint('[NotificationService] Error canceling all reminders: $e');
    }
  }

  /// Show notification when item is added to list
  ///
  /// [itemName] - Name of the item
  /// [listName] - Name of the list
  Future<void> notifyItemAdded({
    required String itemName,
    required String listName,
  }) async {
    try {
      final notification = NotificationEntity(
        id: DateTime.now().millisecondsSinceEpoch,
        title: '✅ Item adicionado',
        body: '"$itemName" foi adicionado à lista "$listName"',
      );

      await _notificationRepo.showNotification(notification);
    } catch (e) {
      debugPrint('[NotificationService] Error showing item added notification: $e');
    }
  }
}
