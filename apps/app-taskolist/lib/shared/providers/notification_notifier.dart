import 'package:core/core.dart' as core;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/core_providers.dart';
import '../../features/notifications/presentation/notification_stats.dart' as local_stats;
import '../../infrastructure/services/notification_service.dart';

part 'notification_notifier.g.dart';

@riverpod
TaskManagerNotificationService notificationService(NotificationServiceRef ref) {
  return ref.watch(taskManagerNotificationServiceProvider);
}

/// Provider para status de permissões
@riverpod
Future<core.NotificationPermissionEntity> notificationPermission(
  NotificationPermissionRef ref,
) async {
  final notificationService = ref.watch(notificationServiceProvider);
  return await notificationService.getPermissionStatus();
}

/// Provider para notificações pendentes
@riverpod
Future<List<core.PendingNotificationEntity>> pendingNotifications(
  PendingNotificationsRef ref,
) async {
  final notificationService = ref.watch(notificationServiceProvider);
  return await notificationService.getPendingNotifications();
}

/// Provider para notificações ativas
@riverpod
Future<List<core.PendingNotificationEntity>> activeNotifications(
  ActiveNotificationsRef ref,
) async {
  final notificationService = ref.watch(notificationServiceProvider);
  return await notificationService.getActiveNotifications();
}

/// Provider para estatísticas de notificações
@riverpod
Future<local_stats.NotificationStats> notificationStats(
  NotificationStatsRef ref,
) async {
  final notificationService = ref.watch(notificationServiceProvider);
  return await notificationService.getNotificationStats();
}

/// Provider para verificar se uma notificação específica está agendada
@riverpod
Future<bool> isNotificationScheduled(
  IsNotificationScheduledRef ref,
  int notificationId,
) async {
  final notificationService = ref.watch(notificationServiceProvider);
  return await notificationService.isNotificationScheduled(notificationId);
}

class NotificationSettings {
  final bool taskRemindersEnabled;
  final bool deadlineAlertsEnabled;
  final bool completionNotificationsEnabled;
  final bool weeklyReviewEnabled;
  final bool dailyProductivityEnabled;
  final Duration deadlineAlertBefore;
  final int weeklyReviewDayOfWeek;
  final int weeklyReviewHour;
  final int weeklyReviewMinute;
  final int dailyProductivityHour;
  final int dailyProductivityMinute;

  const NotificationSettings({
    this.taskRemindersEnabled = true,
    this.deadlineAlertsEnabled = true,
    this.completionNotificationsEnabled = true,
    this.weeklyReviewEnabled = false,
    this.dailyProductivityEnabled = false,
    this.deadlineAlertBefore = const Duration(hours: 24),
    this.weeklyReviewDayOfWeek = 1, // Segunda-feira
    this.weeklyReviewHour = 9,
    this.weeklyReviewMinute = 0,
    this.dailyProductivityHour = 14,
    this.dailyProductivityMinute = 0,
  });

  NotificationSettings copyWith({
    bool? taskRemindersEnabled,
    bool? deadlineAlertsEnabled,
    bool? completionNotificationsEnabled,
    bool? weeklyReviewEnabled,
    bool? dailyProductivityEnabled,
    Duration? deadlineAlertBefore,
    int? weeklyReviewDayOfWeek,
    int? weeklyReviewHour,
    int? weeklyReviewMinute,
    int? dailyProductivityHour,
    int? dailyProductivityMinute,
  }) {
    return NotificationSettings(
      taskRemindersEnabled: taskRemindersEnabled ?? this.taskRemindersEnabled,
      deadlineAlertsEnabled: deadlineAlertsEnabled ?? this.deadlineAlertsEnabled,
      completionNotificationsEnabled: completionNotificationsEnabled ?? this.completionNotificationsEnabled,
      weeklyReviewEnabled: weeklyReviewEnabled ?? this.weeklyReviewEnabled,
      dailyProductivityEnabled: dailyProductivityEnabled ?? this.dailyProductivityEnabled,
      deadlineAlertBefore: deadlineAlertBefore ?? this.deadlineAlertBefore,
      weeklyReviewDayOfWeek: weeklyReviewDayOfWeek ?? this.weeklyReviewDayOfWeek,
      weeklyReviewHour: weeklyReviewHour ?? this.weeklyReviewHour,
      weeklyReviewMinute: weeklyReviewMinute ?? this.weeklyReviewMinute,
      dailyProductivityHour: dailyProductivityHour ?? this.dailyProductivityHour,
      dailyProductivityMinute: dailyProductivityMinute ?? this.dailyProductivityMinute,
    );
  }
}

@riverpod
class NotificationSettingsNotifier extends _$NotificationSettingsNotifier {
  @override
  NotificationSettings build() {
    return const NotificationSettings();
  }

  void updateTaskReminders(bool enabled) {
    state = state.copyWith(taskRemindersEnabled: enabled);
  }

  void updateDeadlineAlerts(bool enabled) {
    state = state.copyWith(deadlineAlertsEnabled: enabled);
  }

  void updateCompletionNotifications(bool enabled) {
    state = state.copyWith(completionNotificationsEnabled: enabled);
  }

  void updateWeeklyReview(bool enabled) {
    state = state.copyWith(weeklyReviewEnabled: enabled);
  }

  void updateDailyProductivity(bool enabled) {
    state = state.copyWith(dailyProductivityEnabled: enabled);
  }

  void updateDeadlineAlertTime(Duration alertBefore) {
    state = state.copyWith(deadlineAlertBefore: alertBefore);
  }

  void updateWeeklyReviewTime(int dayOfWeek, int hour, int minute) {
    state = state.copyWith(
      weeklyReviewDayOfWeek: dayOfWeek,
      weeklyReviewHour: hour,
      weeklyReviewMinute: minute,
    );
  }

  void updateDailyProductivityTime(int hour, int minute) {
    state = state.copyWith(
      dailyProductivityHour: hour,
      dailyProductivityMinute: minute,
    );
  }
}

@riverpod
NotificationActions notificationActions(NotificationActionsRef ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return NotificationActions(notificationService, ref);
}

/// Classe para ações de notificação
class NotificationActions {
  final TaskManagerNotificationService _notificationService;
  final NotificationActionsRef _ref;

  NotificationActions(this._notificationService, this._ref);

  /// Agenda lembrete para uma tarefa
  Future<bool> scheduleTaskReminder({
    required String taskId,
    required String taskTitle,
    required DateTime reminderTime,
    String? description,
  }) async {
    final success = await _notificationService.scheduleTaskReminder(
      taskId: taskId,
      taskTitle: taskTitle,
      reminderTime: reminderTime,
      description: description,
    );

    if (success) {
      _ref.invalidate(pendingNotificationsProvider);
      _ref.invalidate(notificationStatsProvider);
    }

    return success;
  }

  /// Agenda alerta de deadline
  Future<bool> scheduleTaskDeadlineAlert({
    required String taskId,
    required String taskTitle,
    required DateTime deadline,
    Duration? alertBefore,
  }) async {
    final settings = _ref.read(notificationSettingsNotifierProvider);
    final success = await _notificationService.scheduleTaskDeadlineAlert(
      taskId: taskId,
      taskTitle: taskTitle,
      deadline: deadline,
      alertBefore: alertBefore ?? settings.deadlineAlertBefore,
    );

    if (success) {
      _ref.invalidate(pendingNotificationsProvider);
      _ref.invalidate(notificationStatsProvider);
    }

    return success;
  }

  /// Mostra notificação de tarefa completada
  Future<bool> showTaskCompletedNotification({
    required String taskId,
    required String taskTitle,
    int? completedCount,
  }) async {
    final settings = _ref.read(notificationSettingsNotifierProvider);

    if (!settings.completionNotificationsEnabled) {
      return false;
    }

    final success = await _notificationService.showTaskCompletedNotification(
      taskId: taskId,
      taskTitle: taskTitle,
      completedCount: completedCount,
    );

    if (success) {
      _ref.invalidate(activeNotificationsProvider);
    }

    return success;
  }

  /// Cancela todas as notificações de uma tarefa
  Future<bool> cancelTaskNotifications(String taskId) async {
    final success = await _notificationService.cancelTaskNotifications(taskId);

    if (success) {
      _ref.invalidate(pendingNotificationsProvider);
      _ref.invalidate(activeNotificationsProvider);
      _ref.invalidate(notificationStatsProvider);
    }

    return success;
  }

  /// Agenda/cancela revisão semanal baseado nas configurações
  Future<bool> updateWeeklyReview() async {
    final settings = _ref.read(notificationSettingsNotifierProvider);

    if (settings.weeklyReviewEnabled) {
      return await _notificationService.scheduleWeeklyReview(
        dayOfWeek: settings.weeklyReviewDayOfWeek,
        hour: settings.weeklyReviewHour,
        minute: settings.weeklyReviewMinute,
      );
    } else {
      const weeklyReviewId = TaskManagerNotificationService.generalBaseId + 1;
      return await _notificationService.cancelNotification(weeklyReviewId);
    }
  }

  /// Agenda/cancela lembrete de produtividade baseado nas configurações
  Future<bool> updateDailyProductivityReminder() async {
    final settings = _ref.read(notificationSettingsNotifierProvider);

    return await _notificationService.scheduleDailyProductivityReminder(
      hour: settings.dailyProductivityHour,
      minute: settings.dailyProductivityMinute,
      enabled: settings.dailyProductivityEnabled,
    );
  }

  /// Cancela todas as notificações
  Future<bool> cancelAllNotifications() async {
    final success = await _notificationService.cancelAllNotifications();

    if (success) {
      _ref.invalidate(pendingNotificationsProvider);
      _ref.invalidate(activeNotificationsProvider);
      _ref.invalidate(notificationStatsProvider);
    }

    return success;
  }

  /// Abre configurações de notificação do sistema
  Future<bool> openNotificationSettings() async {
    return await _notificationService.openNotificationSettings();
  }

  /// Solicita permissões de notificação
  Future<core.NotificationPermissionEntity> requestPermissions() async {
    final permission = await _notificationService.requestPermissions();
    _ref.invalidate(notificationPermissionProvider);

    return permission;
  }
}
