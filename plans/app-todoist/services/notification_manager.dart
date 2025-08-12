// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../core/services/notification_service.dart';
import '../constants/timeout_constants.dart';
import '../models/72_task_list.dart';
import '../models/73_user.dart';
import '../models/notification.dart';
import '../models/task_model.dart';
import 'notification_scheduler.dart';
import 'notification_services.dart';

/// Gerenciador central de notificações do Todoist
/// Coordena entre notificações locais (scheduler) e notificações em nuvem (service)
class TodoistNotificationManager {
  static final TodoistNotificationManager _instance = 
      TodoistNotificationManager._internal();
  factory TodoistNotificationManager() => _instance;
  TodoistNotificationManager._internal();

  final TodoistNotificationScheduler _scheduler = TodoistNotificationScheduler();
  final TodoistCloudNotificationService _cloudService = TodoistCloudNotificationService();
  final NotificationService _coreService = NotificationService();

  // Configurações de preferências do usuário
  bool _remindersEnabled = true;
  bool _dueDateAlertsEnabled = true;
  bool _assignmentNotificationsEnabled = true;
  bool _commentNotificationsEnabled = true;
  Duration _defaultReminderAdvance = TimeoutConstants.defaultReminderAdvance;

  // Getters para configurações
  bool get remindersEnabled => _remindersEnabled;
  bool get dueDateAlertsEnabled => _dueDateAlertsEnabled;
  bool get assignmentNotificationsEnabled => _assignmentNotificationsEnabled;
  bool get commentNotificationsEnabled => _commentNotificationsEnabled;
  Duration get defaultReminderAdvance => _defaultReminderAdvance;

  /// Inicializa o gerenciador de notificações
  Future<void> initialize({
    Function(String? payload)? onLocalNotificationTap,
  }) async {
    // Inicializa o serviço core com callback para navegação
    await _coreService.initialize(
      onNotificationSelected: onLocalNotificationTap ?? _handleNotificationTap,
    );

    if (kDebugMode) {
      print('✅ TodoistNotificationManager inicializado');
    }
  }

  /// Manipulador padrão para toque em notificações
  void _handleNotificationTap(String? payload) {
    if (payload == null) return;

    if (kDebugMode) {
      print('📱 Notificação tocada: $payload');
    }

    // Parse do payload: todoist://type/taskId
    final uri = Uri.tryParse(payload);
    if (uri?.scheme == 'todoist') {
      final type = uri?.host;
      final taskId = uri?.pathSegments.firstOrNull;
      
      if (taskId != null) {
        _navigateToTask(taskId, type);
      }
    }
  }

  void _navigateToTask(String taskId, String? notificationType) {
    // Implementar navegação para a tarefa
    // Pode ser expandido com callbacks específicos para diferentes types
    if (kDebugMode) {
      print('🧭 Navegando para tarefa $taskId (tipo: $notificationType)');
    }
  }

  // ========== Métodos principais ==========

  /// Agenda todas as notificações para uma tarefa
  Future<void> scheduleTaskNotifications(Task task, {TaskList? taskList}) async {
    if (!_shouldScheduleNotifications(task)) return;

    // Agenda notificações locais
    await _scheduler.scheduleTaskReminders(task, taskList: taskList);

    if (kDebugMode) {
      print('📅 Notificações agendadas para: ${task.title}');
    }
  }

  /// Agenda notificações para múltiplas tarefas
  Future<void> scheduleMultipleTaskNotifications(
    List<Task> tasks,
    Map<String, TaskList>? taskListsMap,
  ) async {
    final validTasks = tasks.where(_shouldScheduleNotifications).toList();
    
    if (validTasks.isEmpty) return;

    await _scheduler.scheduleMultipleTaskReminders(validTasks, taskListsMap);

    if (kDebugMode) {
      print('📅 Notificações agendadas para ${validTasks.length} tarefas');
    }
  }

  /// Cancela todas as notificações de uma tarefa
  Future<void> cancelTaskNotifications(String taskId) async {
    await _scheduler.cancelTaskNotifications(taskId);

    if (kDebugMode) {
      print('🗑️ Notificações canceladas para tarefa: $taskId');
    }
  }

  /// Reagenda notificações quando uma tarefa é atualizada
  Future<void> updateTaskNotifications(Task task, {TaskList? taskList}) async {
    await _scheduler.rescheduleTaskReminders(task, taskList: taskList);

    if (kDebugMode) {
      print('🔄 Notificações reagendadas para: ${task.title}');
    }
  }

  // ========== Notificações específicas por tipo ==========

  /// Notificação de tarefa atribuída
  Future<void> notifyTaskAssignment(Task task, User assignedTo, User assignedBy) async {
    if (!assignmentNotificationsEnabled) return;

    // Notificação local imediata
    await _coreService.showNotification(
      id: NotificationService.createNotificationId('assignment_${task.id}'),
      title: '👤 Nova tarefa atribuída',
      body: '${assignedBy.name} atribuiu "${task.title}" para você',
      payload: 'todoist://assignment/${task.id}',
    );

    // Notificação em nuvem para sincronização entre devices
    final cloudNotification = Notification(
      id: '',
      userId: assignedTo.id,
      type: NotificationType.assignment,
      title: 'Nova tarefa atribuída',
      message: '${assignedBy.name} atribuiu "${task.title}" para você',
      relatedEntityId: task.id,
      createdAt: DateTime.now(),
    );

    await _cloudService.createNotification(cloudNotification);
  }

  /// Notificação de novo comentário
  Future<void> notifyTaskComment(Task task, User commenter, String comment) async {
    if (!commentNotificationsEnabled) return;

    await _coreService.showNotification(
      id: NotificationService.createNotificationId('comment_${task.id}_${DateTime.now().millisecondsSinceEpoch}'),
      title: '💬 Novo comentário',
      body: '${commenter.name} comentou em "${task.title}"',
      payload: 'todoist://comment/${task.id}',
    );

    // Notificação em nuvem
    final cloudNotification = Notification(
      id: '',
      userId: task.createdById, // Ou outros membros relevantes
      type: NotificationType.comment,
      title: 'Novo comentário',
      message: '${commenter.name} comentou em "${task.title}": ${comment.length > 50 ? '${comment.substring(0, 50)}...' : comment}',
      relatedEntityId: task.id,
      createdAt: DateTime.now(),
    );

    await _cloudService.createNotification(cloudNotification);
  }

  /// Notificação de lista compartilhada
  Future<void> notifyListShared(TaskList taskList, User sharedBy, User sharedWith) async {
    await _coreService.showNotification(
      id: NotificationService.createNotificationId('list_shared_${taskList.id}'),
      title: '📋 Lista compartilhada',
      body: '${sharedBy.name} compartilhou "${taskList.title}" com você',
      payload: 'todoist://list/${taskList.id}',
    );

    // Notificação em nuvem
    final cloudNotification = Notification(
      id: '',
      userId: sharedWith.id,
      type: NotificationType.listShared,
      title: 'Lista compartilhada',
      message: '${sharedBy.name} compartilhou "${taskList.title}" com você',
      relatedEntityId: taskList.id,
      createdAt: DateTime.now(),
    );

    await _cloudService.createNotification(cloudNotification);
  }

  /// Notificação de tarefa completada (para membros da lista)
  Future<void> notifyTaskCompleted(Task task, User completedBy, List<User> listMembers) async {
    for (final member in listMembers) {
      if (member.id == completedBy.id) continue; // Não notifica quem completou

      await _coreService.showNotification(
        id: NotificationService.createNotificationId('completed_${task.id}_${member.id}'),
        title: '✅ Tarefa completada',
        body: '${completedBy.name} completou "${task.title}"',
        payload: 'todoist://completed/${task.id}',
      );

      // Notificação em nuvem
      final cloudNotification = Notification(
        id: '',
        userId: member.id,
        type: NotificationType.taskCompleted,
        title: 'Tarefa completada',
        message: '${completedBy.name} completou "${task.title}"',
        relatedEntityId: task.id,
        createdAt: DateTime.now(),
      );

      await _cloudService.createNotification(cloudNotification);
    }
  }

  // ========== Métodos de configuração ==========

  /// Atualiza configurações de notificação
  void updateNotificationSettings({
    bool? remindersEnabled,
    bool? dueDateAlertsEnabled,
    bool? assignmentNotificationsEnabled,
    bool? commentNotificationsEnabled,
    Duration? defaultReminderAdvance,
  }) {
    _remindersEnabled = remindersEnabled ?? _remindersEnabled;
    _dueDateAlertsEnabled = dueDateAlertsEnabled ?? _dueDateAlertsEnabled;
    _assignmentNotificationsEnabled = assignmentNotificationsEnabled ?? _assignmentNotificationsEnabled;
    _commentNotificationsEnabled = commentNotificationsEnabled ?? _commentNotificationsEnabled;
    _defaultReminderAdvance = defaultReminderAdvance ?? _defaultReminderAdvance;

    if (kDebugMode) {
      print('⚙️ Configurações de notificação atualizadas');
    }
  }

  /// Carrega configurações de notificação (pode ser expandido para usar SharedPreferences)
  Future<void> loadNotificationSettings() async {
    // TODO: Implementar carregamento de preferências do usuário
    // Por enquanto usa valores padrão
    
    if (kDebugMode) {
      print('📋 Configurações de notificação carregadas');
    }
  }

  // ========== Métodos auxiliares ==========

  /// Verifica se deve agendar notificações para uma tarefa
  bool _shouldScheduleNotifications(Task task) {
    if (task.isCompleted || task.isDeleted) return false;
    
    // Verifica se tem reminder ou due date no futuro
    final hasValidReminder = task.reminderDate != null && 
        task.reminderDate!.isAfter(DateTime.now()) && 
        remindersEnabled;
        
    final hasValidDueDate = task.dueDate != null && 
        task.dueDate!.isAfter(DateTime.now()) && 
        dueDateAlertsEnabled;

    return hasValidReminder || hasValidDueDate;
  }

  /// Obtém estatísticas de notificações pendentes
  Future<Map<String, dynamic>> getNotificationStats() async {
    final pending = await _coreService.getPendingNotifications();
    
    final todoistNotifications = pending.where(
      (n) => n.payload?.startsWith('todoist://') == true
    ).toList();

    return {
      'total_pending': pending.length,
      'todoist_pending': todoistNotifications.length,
      'reminders_enabled': remindersEnabled,
      'due_date_alerts_enabled': dueDateAlertsEnabled,
      'last_check': DateTime.now().toIso8601String(),
    };
  }

  /// Limpa todas as notificações do Todoist
  Future<void> clearAllTodoistNotifications() async {
    final pending = await _coreService.getPendingNotifications();
    
    final todoistNotificationIds = pending
        .where((n) => n.payload?.startsWith('todoist://') == true)
        .map((n) => n.id)
        .toList();

    if (todoistNotificationIds.isNotEmpty) {
      await _coreService.cancelMultipleNotifications(todoistNotificationIds);
      
      if (kDebugMode) {
        print('🧹 ${todoistNotificationIds.length} notificações do Todoist removidas');
      }
    }
  }
}
