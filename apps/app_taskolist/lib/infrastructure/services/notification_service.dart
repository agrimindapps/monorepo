import 'package:core/core.dart';
import 'dart:async';
import 'analytics_service.dart';
import 'crashlytics_service.dart';
import '../../domain/entities/notification_stats.dart';

/// Notification service específico do app Task Manager
class TaskManagerNotificationService {
  final INotificationRepository _notificationRepository;
  final TaskManagerAnalyticsService _analyticsService;
  final TaskManagerCrashlyticsService _crashlyticsService;

  TaskManagerNotificationService(
    this._notificationRepository,
    this._analyticsService,
    this._crashlyticsService,
  );

  // Canais de notificação do Task Manager
  static const String taskReminderChannelId = 'task_reminders';
  static const String taskDeadlineChannelId = 'task_deadlines';
  static const String taskCompletedChannelId = 'task_completed';
  static const String projectUpdateChannelId = 'project_updates';
  static const String generalChannelId = 'general';

  // IDs base para diferentes tipos de notificação
  static const int taskReminderBaseId = 10000;
  static const int taskDeadlineBaseId = 20000;
  static const int taskCompletedBaseId = 30000;
  static const int projectUpdateBaseId = 40000;
  static const int generalBaseId = 50000;

  /// Inicializa o serviço de notificações com canais específicos do Task Manager
  Future<bool> initialize() async {
    try {
      final channels = [
        NotificationChannelEntity(
          id: taskReminderChannelId,
          name: 'Lembretes de Tarefas',
          description: 'Notificações para lembrar sobre tarefas',
          importance: NotificationImportanceEntity.high,
          enableSound: true,
          enableVibration: true,
          enableLights: true,
          showBadge: true,
        ),
        NotificationChannelEntity(
          id: taskDeadlineChannelId,
          name: 'Prazos de Tarefas',
          description: 'Notificações urgentes sobre prazos vencendo',
          importance: NotificationImportanceEntity.max,
          enableSound: true,
          enableVibration: true,
          enableLights: true,
          showBadge: true,
        ),
        NotificationChannelEntity(
          id: taskCompletedChannelId,
          name: 'Tarefas Concluídas',
          description: 'Confirmações de tarefas completadas',
          importance: NotificationImportanceEntity.defaultImportance,
          enableSound: false,
          enableVibration: false,
          enableLights: false,
          showBadge: false,
        ),
        NotificationChannelEntity(
          id: projectUpdateChannelId,
          name: 'Atualizações de Projeto',
          description: 'Notificações sobre progresso de projetos',
          importance: NotificationImportanceEntity.low,
          enableSound: false,
          enableVibration: true,
          enableLights: false,
          showBadge: true,
        ),
        NotificationChannelEntity(
          id: generalChannelId,
          name: 'Geral',
          description: 'Notificações gerais do aplicativo',
          importance: NotificationImportanceEntity.defaultImportance,
          enableSound: true,
          enableVibration: true,
          enableLights: false,
          showBadge: true,
        ),
      ];

      final success = await _notificationRepository.initialize(
        defaultChannels: channels,
      );

      if (success) {
        await _analyticsService.logEvent('notifications_initialized');
        await _crashlyticsService.log('Notification service initialized successfully');
      }

      return success;
    } catch (e, stackTrace) {
      await _crashlyticsService.recordError(
        exception: e,
        stackTrace: stackTrace,
        reason: 'Failed to initialize notification service',
      );
      return false;
    }
  }

  /// Verifica e solicita permissões necessárias
  Future<NotificationPermissionEntity> requestPermissions() async {
    try {
      final permission = await _notificationRepository.requestPermission();
      
      await _analyticsService.logEvent('notification_permission_requested', parameters: {
        'granted': permission.isGranted,
        'can_show_alerts': permission.canShowAlerts,
        'can_schedule_exact': permission.canScheduleExactAlarms,
      });

      if (!permission.canScheduleExactAlarms) {
        // Solicitar permissão para agendamentos exatos se necessário
        await _notificationRepository.requestExactNotificationPermission();
      }

      return permission;
    } catch (e, stackTrace) {
      await _crashlyticsService.recordError(
        exception: e,
        stackTrace: stackTrace,
        reason: 'Failed to request notification permissions',
      );
      
      return const NotificationPermissionEntity(
        isGranted: false,
        canShowAlerts: false,
        canShowBadges: false,
        canPlaySounds: false,
        canScheduleExactAlarms: false,
      );
    }
  }

  /// Agenda lembrete para uma tarefa
  Future<bool> scheduleTaskReminder({
    required String taskId,
    required String taskTitle,
    required DateTime reminderTime,
    String? description,
  }) async {
    try {
      final notificationId = taskReminderBaseId + taskId.hashCode.abs() % 9999;
      
      final notification = NotificationEntity(
        id: notificationId,
        title: '📋 Lembrete de Tarefa',
        body: taskTitle,
        channelId: taskReminderChannelId,
        channelName: 'Lembretes de Tarefas',
        channelDescription: 'Notificações para lembrar sobre tarefas',
        scheduledDate: reminderTime,
        payload: 'task_reminder:$taskId',
        importance: NotificationImportanceEntity.high,
        priority: NotificationPriorityEntity.high,
        autoCancel: true,
        showBadge: true,
        actions: [
          NotificationActionEntity(
            id: 'mark_done',
            title: 'Marcar como Feita',
            icon: 'ic_check',
          ),
          NotificationActionEntity(
            id: 'snooze_1h',
            title: 'Lembrar em 1h',
            icon: 'ic_snooze',
          ),
        ],
      );

      final success = await _notificationRepository.scheduleNotification(notification);
      
      if (success) {
        await _analyticsService.logEvent('task_reminder_scheduled', parameters: {
          'task_id': taskId,
          'reminder_time': reminderTime.toIso8601String(),
        });
      }

      return success;
    } catch (e, stackTrace) {
      await _crashlyticsService.recordError(
        exception: e,
        stackTrace: stackTrace,
        reason: 'Failed to schedule task reminder',
        additionalInfo: {'task_id': taskId},
      );
      return false;
    }
  }

  /// Agenda notificação de deadline para uma tarefa
  Future<bool> scheduleTaskDeadlineAlert({
    required String taskId,
    required String taskTitle,
    required DateTime deadline,
    Duration alertBefore = const Duration(hours: 24),
  }) async {
    try {
      final alertTime = deadline.subtract(alertBefore);
      
      if (alertTime.isBefore(DateTime.now())) {
        return false; // Não agendar se já passou
      }

      final notificationId = taskDeadlineBaseId + taskId.hashCode.abs() % 9999;
      
      final notification = NotificationEntity(
        id: notificationId,
        title: '⚠️ Prazo Vencendo',
        body: '$taskTitle vence em ${_formatDuration(alertBefore)}',
        channelId: taskDeadlineChannelId,
        channelName: 'Prazos de Tarefas',
        channelDescription: 'Notificações urgentes sobre prazos vencendo',
        scheduledDate: alertTime,
        payload: 'task_deadline:$taskId',
        importance: NotificationImportanceEntity.max,
        priority: NotificationPriorityEntity.max,
        autoCancel: true,
        showBadge: true,
        color: 0xFFFF5722, // Cor vermelha para urgência
        actions: [
          NotificationActionEntity(
            id: 'mark_done',
            title: 'Marcar como Feita',
            icon: 'ic_check',
          ),
          NotificationActionEntity(
            id: 'extend_deadline',
            title: 'Adiar Prazo',
            icon: 'ic_schedule',
          ),
        ],
      );

      final success = await _notificationRepository.scheduleNotification(notification);
      
      if (success) {
        await _analyticsService.logEvent('task_deadline_scheduled', parameters: {
          'task_id': taskId,
          'deadline': deadline.toIso8601String(),
          'alert_before_hours': alertBefore.inHours,
        });
      }

      return success;
    } catch (e, stackTrace) {
      await _crashlyticsService.recordError(
        exception: e,
        stackTrace: stackTrace,
        reason: 'Failed to schedule task deadline alert',
        additionalInfo: {'task_id': taskId},
      );
      return false;
    }
  }

  /// Notifica quando uma tarefa é completada
  Future<bool> showTaskCompletedNotification({
    required String taskId,
    required String taskTitle,
    int? completedCount,
  }) async {
    try {
      final notificationId = taskCompletedBaseId + taskId.hashCode.abs() % 9999;
      
      String body = 'Parabéns! Você completou: $taskTitle';
      if (completedCount != null && completedCount > 1) {
        body += '\n🎉 Total de tarefas completadas hoje: $completedCount';
      }
      
      final notification = NotificationEntity(
        id: notificationId,
        title: '✅ Tarefa Concluída',
        body: body,
        channelId: taskCompletedChannelId,
        channelName: 'Tarefas Concluídas',
        channelDescription: 'Confirmações de tarefas completadas',
        payload: 'task_completed:$taskId',
        importance: NotificationImportanceEntity.defaultImportance,
        priority: NotificationPriorityEntity.defaultPriority,
        autoCancel: true,
        showBadge: false,
        color: 0xFF4CAF50, // Cor verde para sucesso
        silent: true, // Não fazer som para não ser intrusivo
      );

      final success = await _notificationRepository.showNotification(notification);
      
      if (success) {
        await _analyticsService.logEvent('task_completed_notification_sent', parameters: {
          'task_id': taskId,
          'completed_count': completedCount ?? 1,
        });
      }

      return success;
    } catch (e, stackTrace) {
      await _crashlyticsService.recordError(
        exception: e,
        stackTrace: stackTrace,
        reason: 'Failed to show task completed notification',
        additionalInfo: {'task_id': taskId},
      );
      return false;
    }
  }

  /// Agenda notificações recorrentes para revisão semanal
  Future<bool> scheduleWeeklyReview({
    required int dayOfWeek, // 1 = Segunda, 7 = Domingo
    required int hour,
    required int minute,
  }) async {
    try {
      final notificationId = generalBaseId + 1;
      
      final notification = NotificationEntity(
        id: notificationId,
        title: '📊 Revisão Semanal',
        body: 'Hora de revisar suas tarefas da semana e planejar a próxima!',
        channelId: projectUpdateChannelId,
        channelName: 'Atualizações de Projeto',
        channelDescription: 'Notificações sobre progresso de projetos',
        payload: 'weekly_review',
        importance: NotificationImportanceEntity.defaultImportance,
        priority: NotificationPriorityEntity.defaultPriority,
        autoCancel: true,
        showBadge: true,
      );

      final success = await _notificationRepository.schedulePeriodicNotification(
        notification,
        const Duration(days: 7),
      );
      
      if (success) {
        await _analyticsService.logEvent('weekly_review_scheduled', parameters: {
          'day_of_week': dayOfWeek,
          'hour': hour,
          'minute': minute,
        });
      }

      return success;
    } catch (e, stackTrace) {
      await _crashlyticsService.recordError(
        exception: e,
        stackTrace: stackTrace,
        reason: 'Failed to schedule weekly review',
      );
      return false;
    }
  }

  /// Agenda notificação de produtividade diária
  Future<bool> scheduleDailyProductivityReminder({
    required int hour,
    required int minute,
    bool enabled = true,
  }) async {
    if (!enabled) {
      return await _notificationRepository.cancelNotification(generalBaseId + 2);
    }

    try {
      final notificationId = generalBaseId + 2;
      
      final notification = NotificationEntity(
        id: notificationId,
        title: '🚀 Momento de Foco',
        body: 'Que tal verificar suas tarefas e manter o foco no que é importante?',
        channelId: generalChannelId,
        channelName: 'Geral',
        channelDescription: 'Notificações gerais do aplicativo',
        payload: 'daily_productivity',
        importance: NotificationImportanceEntity.defaultImportance,
        priority: NotificationPriorityEntity.defaultPriority,
        autoCancel: true,
        showBadge: true,
      );

      final success = await _notificationRepository.schedulePeriodicNotification(
        notification,
        const Duration(days: 1),
      );
      
      if (success) {
        await _analyticsService.logEvent('daily_productivity_scheduled', parameters: {
          'hour': hour,
          'minute': minute,
          'enabled': enabled,
        });
      }

      return success;
    } catch (e, stackTrace) {
      await _crashlyticsService.recordError(
        exception: e,
        stackTrace: stackTrace,
        reason: 'Failed to schedule daily productivity reminder',
      );
      return false;
    }
  }

  /// Cancela todas as notificações de uma tarefa específica
  Future<bool> cancelTaskNotifications(String taskId) async {
    try {
      final reminderNotificationId = taskReminderBaseId + taskId.hashCode.abs() % 9999;
      final deadlineNotificationId = taskDeadlineBaseId + taskId.hashCode.abs() % 9999;
      final completedNotificationId = taskCompletedBaseId + taskId.hashCode.abs() % 9999;

      await Future.wait([
        _notificationRepository.cancelNotification(reminderNotificationId),
        _notificationRepository.cancelNotification(deadlineNotificationId),
        _notificationRepository.cancelNotification(completedNotificationId),
      ]);

      await _analyticsService.logEvent('task_notifications_cancelled', parameters: {
        'task_id': taskId,
      });

      return true;
    } catch (e, stackTrace) {
      await _crashlyticsService.recordError(
        exception: e,
        stackTrace: stackTrace,
        reason: 'Failed to cancel task notifications',
        additionalInfo: {'task_id': taskId},
      );
      return false;
    }
  }

  /// Configura callbacks para quando notificações são tocadas
  void setupNotificationHandlers({
    required Function(String? payload) onNotificationTap,
    required Function(String actionId, String? payload) onNotificationAction,
  }) {
    _notificationRepository.setNotificationTapCallback((payload) async {
      try {
        await _analyticsService.logEvent('notification_tapped', parameters: {
          'payload': payload ?? 'null',
        });
        
        onNotificationTap(payload);
      } catch (e, stackTrace) {
        await _crashlyticsService.recordError(
          exception: e,
          stackTrace: stackTrace,
          reason: 'Error handling notification tap',
        );
      }
    });

    _notificationRepository.setNotificationActionCallback((actionId, payload) async {
      try {
        await _analyticsService.logEvent('notification_action_tapped', parameters: {
          'action_id': actionId,
          'payload': payload ?? 'null',
        });
        
        onNotificationAction(actionId, payload);
      } catch (e, stackTrace) {
        await _crashlyticsService.recordError(
          exception: e,
          stackTrace: stackTrace,
          reason: 'Error handling notification action',
        );
      }
    });
  }

  /// Obtém estatísticas de notificações
  Future<NotificationStats> getNotificationStats() async {
    try {
      final pending = await _notificationRepository.getPendingNotifications();
      final active = await _notificationRepository.getActiveNotifications();
      
      final taskReminders = pending.where((n) => 
        n.id >= taskReminderBaseId && n.id < taskReminderBaseId + 10000).length;
      final taskDeadlines = pending.where((n) => 
        n.id >= taskDeadlineBaseId && n.id < taskDeadlineBaseId + 10000).length;
      
      return NotificationStats(
        totalNotifications: pending.length + active.length,
        unreadNotifications: pending.length,
        areNotificationsEnabled: true,
        totalPending: pending.length,
        taskReminders: taskReminders,
        taskDeadlines: taskDeadlines,
      );
    } catch (e) {
      return const NotificationStats(
        totalNotifications: 0,
        unreadNotifications: 0,
        areNotificationsEnabled: false,
        totalPending: 0,
        taskReminders: 0,
        taskDeadlines: 0,
      );
    }
  }

  /// Formata duração para exibição legível
  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} dia${duration.inDays > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hora${duration.inHours > 1 ? 's' : ''}';
    } else {
      return '${duration.inMinutes} minuto${duration.inMinutes > 1 ? 's' : ''}';
    }
  }

  // Delegate methods do core
  Future<NotificationPermissionEntity> getPermissionStatus() =>
      _notificationRepository.getPermissionStatus();

  Future<bool> openNotificationSettings() =>
      _notificationRepository.openNotificationSettings();

  Future<List<PendingNotificationEntity>> getPendingNotifications() =>
      _notificationRepository.getPendingNotifications();

  Future<List<PendingNotificationEntity>> getActiveNotifications() =>
      _notificationRepository.getActiveNotifications();

  Future<bool> cancelAllNotifications() =>
      _notificationRepository.cancelAllNotifications();

  Future<bool> cancelNotification(int notificationId) =>
      _notificationRepository.cancelNotification(notificationId);

  Future<bool> isNotificationScheduled(int notificationId) =>
      _notificationRepository.isNotificationScheduled(notificationId);

  int generateNotificationId(String identifier) =>
      _notificationRepository.generateNotificationId(identifier);
}

