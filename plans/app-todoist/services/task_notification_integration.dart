// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../core/services/notification_service.dart';
import '../models/72_task_list.dart';
import '../models/73_user.dart';
import '../models/task_model.dart';
import '../repository/task_list_repository.dart';
import '../repository/task_repository.dart';
import '../repository/user_repository.dart';
import 'notification_manager.dart';

/// Serviço de integração entre eventos de tarefas e notificações
/// Monitora mudanças em tarefas e agenda/cancela notificações automaticamente
class TaskNotificationIntegration {
  static final TaskNotificationIntegration _instance = 
      TaskNotificationIntegration._internal();
  factory TaskNotificationIntegration() => _instance;
  TaskNotificationIntegration._internal();

  final TodoistNotificationManager _notificationManager = TodoistNotificationManager();
  final NotificationService _coreService = NotificationService();
  
  // Repositórios para buscar dados relacionados
  late final TaskRepository _taskRepository;
  late final TaskListRepository _taskListRepository;
  late final UserRepository _userRepository;

  /// Inicializa a integração com os repositórios necessários
  void initialize({
    required TaskRepository taskRepository,
    required TaskListRepository taskListRepository,
    required UserRepository userRepository,
  }) {
    _taskRepository = taskRepository;
    _taskListRepository = taskListRepository;
    _userRepository = userRepository;

    if (kDebugMode) {
      print('✅ TaskNotificationIntegration inicializada');
    }
  }

  // ========== Eventos de tarefa ==========

  /// Chamado quando uma tarefa é criada
  Future<void> onTaskCreated(Task task) async {
    try {
      final taskList = await _getTaskList(task.listId);
      await _notificationManager.scheduleTaskNotifications(task, taskList: taskList);

      // Se a tarefa foi atribuída a alguém, notificar
      if (task.assignedToId != null && task.assignedToId != task.createdById) {
        final assignedTo = await _getUser(task.assignedToId!);
        final createdBy = await _getUser(task.createdById);
        
        if (assignedTo != null && createdBy != null) {
          await _notificationManager.notifyTaskAssignment(task, assignedTo, createdBy);
        }
      }

      if (kDebugMode) {
        print('📝 Tarefa criada: ${task.title}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao processar criação de tarefa: $e');
      }
    }
  }

  /// Chamado quando uma tarefa é atualizada
  Future<void> onTaskUpdated(Task oldTask, Task newTask) async {
    try {
      final taskList = await _getTaskList(newTask.listId);

      // Se a tarefa foi completada, cancela notificações
      if (!oldTask.isCompleted && newTask.isCompleted) {
        await _notificationManager.cancelTaskNotifications(newTask.id);
        await _handleTaskCompleted(newTask, taskList);
        return;
      }

      // Se a tarefa foi reaberta, reagenda notificações
      if (oldTask.isCompleted && !newTask.isCompleted) {
        await _notificationManager.scheduleTaskNotifications(newTask, taskList: taskList);
      }

      // Verifica se datas foram alteradas
      final datesChanged = oldTask.dueDate != newTask.dueDate || 
                          oldTask.reminderDate != newTask.reminderDate;
      
      if (datesChanged) {
        await _notificationManager.updateTaskNotifications(newTask, taskList: taskList);
      }

      // Verifica se foi atribuída a uma nova pessoa
      if (oldTask.assignedToId != newTask.assignedToId && newTask.assignedToId != null) {
        final assignedTo = await _getUser(newTask.assignedToId!);
        final updatedBy = await _getUser(newTask.createdById); // Assumindo que quem atualizou é o criador
        
        if (assignedTo != null && updatedBy != null) {
          await _notificationManager.notifyTaskAssignment(newTask, assignedTo, updatedBy);
        }
      }

      if (kDebugMode) {
        print('✏️ Tarefa atualizada: ${newTask.title}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao processar atualização de tarefa: $e');
      }
    }
  }

  /// Chamado quando uma tarefa é deletada
  Future<void> onTaskDeleted(Task task) async {
    try {
      await _notificationManager.cancelTaskNotifications(task.id);

      if (kDebugMode) {
        print('🗑️ Tarefa deletada: ${task.title}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao processar deleção de tarefa: $e');
      }
    }
  }

  /// Chamado quando um comentário é adicionado à tarefa
  Future<void> onTaskCommentAdded(Task task, String comment, String commenterId) async {
    try {
      final commenter = await _getUser(commenterId);
      if (commenter == null) return;

      await _notificationManager.notifyTaskComment(task, commenter, comment);

      if (kDebugMode) {
        print('💬 Comentário adicionado na tarefa: ${task.title}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao processar comentário: $e');
      }
    }
  }

  // ========== Eventos de lista ==========

  /// Chamado quando uma lista é compartilhada
  Future<void> onListShared(TaskList taskList, String sharedById, String sharedWithId) async {
    try {
      final sharedBy = await _getUser(sharedById);
      final sharedWith = await _getUser(sharedWithId);
      
      if (sharedBy != null && sharedWith != null) {
        await _notificationManager.notifyListShared(taskList, sharedBy, sharedWith);
      }

      if (kDebugMode) {
        print('📤 Lista compartilhada: ${taskList.title}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao processar compartilhamento de lista: $e');
      }
    }
  }

  /// Reagenda todas as notificações de uma lista
  Future<void> onListUpdated(TaskList taskList) async {
    try {
      // Busca todas as tarefas da lista
      final allTasks = await _taskRepository.findAll();
      final tasks = allTasks.where((task) => task.listId == taskList.id).toList();
      
      // Reagenda notificações para todas as tarefas não completadas
      final activeTasks = tasks.where((task) => !task.isCompleted && !task.isDeleted).toList();
      
      await _notificationManager.scheduleMultipleTaskNotifications(
        activeTasks,
        {taskList.id: taskList},
      );

      if (kDebugMode) {
        print('🔄 Lista atualizada: ${taskList.title} (${activeTasks.length} tarefas ativas)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao processar atualização de lista: $e');
      }
    }
  }

  // ========== Operações em lote ==========

  /// Inicializa notificações para todas as tarefas existentes
  Future<void> initializeAllTaskNotifications() async {
    try {
      if (kDebugMode) {
        print('🚀 Inicializando notificações para todas as tarefas...');
      }

      // Busca todas as listas
      final taskLists = await _taskListRepository.findAll();
      final taskListsMap = Map.fromEntries(
        taskLists.map((list) => MapEntry(list.id, list))
      );

      // Busca todas as tarefas ativas
      final allTasks = await _taskRepository.findAll();
      final activeTasks = allTasks
          .where((task) => !task.isCompleted && !task.isDeleted)
          .toList();

      // Agenda notificações em lote
      await _notificationManager.scheduleMultipleTaskNotifications(
        activeTasks,
        taskListsMap,
      );

      if (kDebugMode) {
        print('✅ Notificações inicializadas para ${activeTasks.length} tarefas ativas');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao inicializar notificações: $e');
      }
    }
  }

  /// Verifica e agenda notificações para tarefas atrasadas
  Future<void> checkOverdueTasks() async {
    try {
      final allTasks = await _taskRepository.findAll();
      final overdueTasks = allTasks.where((task) => task.isOverdue).toList();

      if (overdueTasks.isEmpty) return;

      // Agenda notificações de atraso
      for (final task in overdueTasks) {
        // Agenda notificação de atraso imediata
        await _coreService.showNotification(
          id: NotificationService.createNotificationId('overdue_${task.id}'),
          title: '🚨 Atrasada: ${task.title}',
          body: 'Esta tarefa está atrasada',
          payload: 'todoist://overdue/${task.id}',
        );
      }

      if (kDebugMode) {
        print('⚠️ Processadas ${overdueTasks.length} tarefas atrasadas');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao verificar tarefas atrasadas: $e');
      }
    }
  }

  // ========== Métodos auxiliares ==========

  /// Manipula evento de tarefa completada
  Future<void> _handleTaskCompleted(Task task, TaskList? taskList) async {
    if (taskList == null || !taskList.isShared) return;

    // Busca membros da lista para notificar
    final members = await Future.wait(
      taskList.memberIds.map((id) => _getUser(id))
    );
    
    final validMembers = members.whereType<User>().toList();
    final completedBy = await _getUser(task.createdById); // Assumindo que é quem completou
    
    if (completedBy != null && validMembers.isNotEmpty) {
      await _notificationManager.notifyTaskCompleted(task, completedBy, validMembers);
    }
  }

  /// Busca uma lista de tarefas
  Future<TaskList?> _getTaskList(String listId) async {
    try {
      return await _taskListRepository.findById(listId);
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Erro ao buscar lista $listId: $e');
      }
      return null;
    }
  }

  /// Busca um usuário
  Future<User?> _getUser(String userId) async {
    try {
      return await _userRepository.findById(userId);
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Erro ao buscar usuário $userId: $e');
      }
      return null;
    }
  }

  // ========== Métodos de configuração ==========

  /// Atualiza configurações de notificação e reagenda se necessário
  Future<void> updateNotificationSettings({
    bool? remindersEnabled,
    bool? dueDateAlertsEnabled,
    bool? assignmentNotificationsEnabled,
    bool? commentNotificationsEnabled,
    Duration? defaultReminderAdvance,
  }) async {
    _notificationManager.updateNotificationSettings(
      remindersEnabled: remindersEnabled,
      dueDateAlertsEnabled: dueDateAlertsEnabled,
      assignmentNotificationsEnabled: assignmentNotificationsEnabled,
      commentNotificationsEnabled: commentNotificationsEnabled,
      defaultReminderAdvance: defaultReminderAdvance,
    );

    // Se as configurações de lembrete mudaram, reagenda todas as notificações
    if (remindersEnabled != null || dueDateAlertsEnabled != null) {
      await initializeAllTaskNotifications();
    }
  }

  /// Obtém estatísticas de notificações
  Future<Map<String, dynamic>> getNotificationStats() async {
    return await _notificationManager.getNotificationStats();
  }

  /// Limpa todas as notificações
  Future<void> clearAllNotifications() async {
    await _notificationManager.clearAllTodoistNotifications();
  }
}
