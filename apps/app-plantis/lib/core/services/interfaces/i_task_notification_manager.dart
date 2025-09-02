/// Interface para gerenciamento de notificações de tarefas
/// Segue o princípio ISP - Interface Segregation Principle
abstract class ITaskNotificationManager {
  /// Agenda notificação para uma tarefa específica
  Future<void> scheduleTaskReminder({
    required String taskId,
    required String taskName,
    required String plantName,
    String? taskDescription,
    String? plantId,
    DateTime? dueDate,
  });

  /// Cancela todas as notificações de uma tarefa específica
  Future<void> cancelTaskNotifications(String taskId);

  /// Mostra notificação instantânea de tarefa atrasada
  Future<void> showOverdueTaskNotification({
    required String taskName,
    required String plantName,
    required int daysOverdue,
  });

  /// Verifica e notifica sobre tarefas atrasadas
  Future<void> checkOverdueTasks();
}