import 'package:app_plantis/features/tasks/domain/entities/task.dart';

/// Interface for overdue task monitoring operations
/// Responsibility: Detectar e notificar tarefas vencidas
abstract class IOverdueTaskMonitor {
  /// Check for overdue tasks and create notifications
  Future<void> checkOverdueTasks(List<Task> allTasks);

  /// Handle overdue tasks detection
  Future<void> handleOverdueTasksDetection(List<Task> tasks);
}
