// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../core/services/notification_service.dart';
import '../constants/timeout_constants.dart';
import '../models/72_task_list.dart';
import '../models/task_model.dart';

/// Serviço especializado para agendamento de notificações de tarefas
/// Utiliza o Core NotificationService para notificações locais
class TodoistNotificationScheduler {
  static final TodoistNotificationScheduler _instance = 
      TodoistNotificationScheduler._internal();
  factory TodoistNotificationScheduler() => _instance;
  TodoistNotificationScheduler._internal();

  final NotificationService _coreNotificationService = NotificationService();

  // Canal específico para notificações do Todoist
  static const String _channelId = 'todoist_channel';
  static const String _channelName = 'Todoist Reminders';
  static const String _channelDescription = 'Lembretes e notificações de tarefas';

  // Offsets para diferentes tipos de notificação
  static const int _reminderOffset = 0;
  static const int _dueDateOffset = 1000;
  static const int _overdueOffset = 2000;

  /// Agenda lembretes para uma tarefa
  Future<void> scheduleTaskReminders(Task task, {TaskList? taskList}) async {
    // Cancela notificações existentes para esta tarefa
    await cancelTaskNotifications(task.id);

    if (task.isCompleted || task.isDeleted) {
      return; // Não agenda para tarefas completadas ou deletadas
    }

    final notifications = <NotificationRequest>[];

    // 1. Notificação de lembrete personalizado
    if (task.reminderDate != null && task.reminderDate!.isAfter(DateTime.now())) {
      notifications.add(NotificationRequest(
        id: _createTaskNotificationId(task.id, _reminderOffset),
        title: _buildReminderTitle(task, taskList),
        body: _buildReminderBody(task),
        scheduledDate: task.reminderDate!,
        channelId: _channelId,
        channelName: _channelName,
        channelDescription: _channelDescription,
        payload: _buildPayload(task.id, 'reminder'),
      ));
    }

    // 2. Notificação de prazo (due date)
    if (task.dueDate != null && task.dueDate!.isAfter(DateTime.now())) {
      // Notificação no horário do prazo
      notifications.add(NotificationRequest(
        id: _createTaskNotificationId(task.id, _dueDateOffset),
        title: _buildDueDateTitle(task, taskList),
        body: _buildDueDateBody(task),
        scheduledDate: task.dueDate!,
        channelId: _channelId,
        channelName: _channelName,
        channelDescription: _channelDescription,
        payload: _buildPayload(task.id, 'due_date'),
      ));

      // Notificação de aviso antecipado (1 hora antes para alta prioridade)
      if (task.priority == TaskPriority.high || task.priority == TaskPriority.urgent) {
        final advanceNoticeTime = task.dueDate!.subtract(TimeoutConstants.defaultReminderAdvance);
        if (advanceNoticeTime.isAfter(DateTime.now())) {
          notifications.add(NotificationRequest(
            id: _createTaskNotificationId(task.id, _dueDateOffset + 1),
            title: _buildAdvanceNoticeTitle(task, taskList),
            body: _buildAdvanceNoticeBody(task),
            scheduledDate: advanceNoticeTime,
            channelId: _channelId,
            channelName: _channelName,
            channelDescription: _channelDescription,
            payload: _buildPayload(task.id, 'advance_notice'),
          ));
        }
      }
    }

    // Agenda todas as notificações em lote
    if (notifications.isNotEmpty) {
      final results = await _coreNotificationService.scheduleMultipleNotifications(notifications);
      final successCount = results.where((result) => result).length;
      
      if (kDebugMode) {
        print('✅ Agendadas $successCount/${notifications.length} notificações para tarefa: ${task.title}');
      }
    }
  }

  /// Agenda notificações para múltiplas tarefas
  Future<void> scheduleMultipleTaskReminders(
    List<Task> tasks, 
    Map<String, TaskList>? taskListsMap,
  ) async {
    for (final task in tasks) {
      final taskList = taskListsMap?[task.listId];
      await scheduleTaskReminders(task, taskList: taskList);
    }
  }

  /// Cancela todas as notificações de uma tarefa
  Future<void> cancelTaskNotifications(String taskId) async {
    final notificationIds = [
      _createTaskNotificationId(taskId, _reminderOffset),
      _createTaskNotificationId(taskId, _dueDateOffset),
      _createTaskNotificationId(taskId, _dueDateOffset + 1), // advance notice
      _createTaskNotificationId(taskId, _overdueOffset),
    ];

    await _coreNotificationService.cancelMultipleNotifications(notificationIds);
    
    if (kDebugMode) {
      print('🗑️ Canceladas notificações para tarefa: $taskId');
    }
  }

  /// Cancela notificações para múltiplas tarefas
  Future<void> cancelMultipleTaskNotifications(List<String> taskIds) async {
    for (final taskId in taskIds) {
      await cancelTaskNotifications(taskId);
    }
  }

  /// Reagenda notificações quando uma tarefa é atualizada
  Future<void> rescheduleTaskReminders(Task task, {TaskList? taskList}) async {
    await scheduleTaskReminders(task, taskList: taskList);
  }

  /// Agenda notificação para tarefa atrasada (chamado pelo sistema de background)
  Future<void> scheduleOverdueNotification(Task task, {TaskList? taskList}) async {
    if (task.isCompleted || task.isDeleted || !task.isOverdue) {
      return;
    }

    final success = await _coreNotificationService.showNotification(
      id: _createTaskNotificationId(task.id, _overdueOffset),
      title: _buildOverdueTitle(task, taskList),
      body: _buildOverdueBody(task),
      channelId: _channelId,
      channelName: _channelName,
      channelDescription: _channelDescription,
      payload: _buildPayload(task.id, 'overdue'),
    );

    if (kDebugMode && success) {
      print('⚠️ Notificação de atraso enviada para: ${task.title}');
    }
  }

  /// Verifica quais notificações estão pendentes para uma tarefa
  Future<List<int>> getPendingTaskNotifications(String taskId) async {
    final allPending = await _coreNotificationService.getPendingNotifications();
    
    final taskNotificationIds = [
      _createTaskNotificationId(taskId, _reminderOffset),
      _createTaskNotificationId(taskId, _dueDateOffset),
      _createTaskNotificationId(taskId, _dueDateOffset + 1),
    ];

    return allPending
        .where((notification) => taskNotificationIds.contains(notification.id))
        .map((notification) => notification.id)
        .toList();
  }

  // ========== Métodos auxiliares para construção de conteúdo ==========

  int _createTaskNotificationId(String taskId, int offset) {
    return NotificationService.createNotificationId(taskId, offset: offset);
  }

  String _buildReminderTitle(Task task, TaskList? taskList) {
    return '🔔 Lembrete: ${task.title}';
  }

  String _buildReminderBody(Task task) {
    final priority = _getPriorityEmoji(task.priority);
    return '$priority ${task.description ?? 'Tarefa agendada'}';
  }

  String _buildDueDateTitle(Task task, TaskList? taskList) {
    return '⏰ Prazo: ${task.title}';
  }

  String _buildDueDateBody(Task task) {
    final priority = _getPriorityEmoji(task.priority);
    return '$priority Esta tarefa vence agora';
  }

  String _buildAdvanceNoticeTitle(Task task, TaskList? taskList) {
    return '⚡ Urgente: ${task.title}';
  }

  String _buildAdvanceNoticeBody(Task task) {
    return '🚨 Esta tarefa importante vence em 1 hora';
  }

  String _buildOverdueTitle(Task task, TaskList? taskList) {
    return '🚨 Atrasada: ${task.title}';
  }

  String _buildOverdueBody(Task task) {
    final priority = _getPriorityEmoji(task.priority);
    return '$priority Esta tarefa está atrasada';
  }

  String _buildPayload(String taskId, String type) {
    return 'todoist://$type/$taskId';
  }

  String _getPriorityEmoji(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return '🚨';
      case TaskPriority.high:
        return '🔴';
      case TaskPriority.medium:
        return '🟡';
      case TaskPriority.low:
        return '🟢';
    }
  }
}
