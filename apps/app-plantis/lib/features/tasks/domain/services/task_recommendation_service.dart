import '../entities/task.dart' as task_entity;

/// TaskRecommendationService - Generates smart task recommendations
///
/// Responsibilities (SRP - <250 lines):
/// - Recommend high-priority tasks
/// - Suggest tasks to complete today
/// - Plant health recommendations
/// - Generate optimization suggestions
/// - Task statistics
///
/// This service is injected via Riverpod (DIP)
abstract class ITaskRecommendationService {
  /// Get high-priority tasks for focus
  List<task_entity.Task> getHighPriorityTasks(List<task_entity.Task> tasks);

  /// Get suggested tasks for today
  List<task_entity.Task> getTodaySuggestions(List<task_entity.Task> tasks);

  /// Get plant-specific recommendations
  List<task_entity.Task> getPlantRecommendations(
    List<task_entity.Task> tasks,
    String plantId,
  );

  /// Get optimization recommendations
  Map<String, dynamic> getOptimizations(List<task_entity.Task> tasks);
}

class TaskRecommendationService implements ITaskRecommendationService {
  @override
  List<task_entity.Task> getHighPriorityTasks(List<task_entity.Task> tasks) {
    return tasks
        .where(
          (t) =>
              (t.priority == task_entity.TaskPriority.urgent ||
                  t.priority == task_entity.TaskPriority.high) &&
              t.status == task_entity.TaskStatus.pending,
        )
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  @override
  List<task_entity.Task> getTodaySuggestions(List<task_entity.Task> tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    return tasks.where((t) {
      final dueDate = t.dueDate;
      return !dueDate.isBefore(today) &&
          dueDate.isBefore(tomorrow) &&
          t.status == task_entity.TaskStatus.pending;
    }).toList()..sort((a, b) {
      // Sort by priority (higher first)
      const priorityOrder = {
        task_entity.TaskPriority.urgent: 0,
        task_entity.TaskPriority.high: 1,
        task_entity.TaskPriority.medium: 2,
        task_entity.TaskPriority.low: 3,
      };
      return (priorityOrder[a.priority] ?? 4).compareTo(
        priorityOrder[b.priority] ?? 4,
      );
    });
  }

  @override
  List<task_entity.Task> getPlantRecommendations(
    List<task_entity.Task> tasks,
    String plantId,
  ) {
    return tasks
        .where(
          (t) =>
              t.plantId == plantId &&
              t.status == task_entity.TaskStatus.pending,
        )
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  @override
  Map<String, dynamic> getOptimizations(List<task_entity.Task> tasks) {
    if (tasks.isEmpty) {
      return {'message': 'No tasks to analyze'};
    }

    final overdueCount = tasks
        .where(
          (t) =>
              t.dueDate.isBefore(DateTime.now()) &&
              t.status != task_entity.TaskStatus.completed,
        )
        .length;

    final highPriorityCount = tasks
        .where(
          (t) =>
              (t.priority == task_entity.TaskPriority.urgent ||
                  t.priority == task_entity.TaskPriority.high) &&
              t.status == task_entity.TaskStatus.pending,
        )
        .length;

    final completionRate = tasks.isEmpty
        ? 0
        : (tasks
                  .where((t) => t.status == task_entity.TaskStatus.completed)
                  .length /
              tasks.length *
              100);

    final recommendations = <String>[];

    if (overdueCount > 3) {
      recommendations.add(
        'You have $overdueCount overdue tasks. Consider completing them soon.',
      );
    }

    if (highPriorityCount > 5) {
      recommendations.add(
        'You have $highPriorityCount high-priority tasks. Try to focus on them.',
      );
    }

    if (completionRate < 30) {
      recommendations.add(
        'Your completion rate is low. Try to complete more tasks.',
      );
    }

    if (completionRate > 80) {
      recommendations.add(
        'Great work! You have a high completion rate. Keep it up!',
      );
    }

    return {
      'overdueCount': overdueCount,
      'highPriorityCount': highPriorityCount,
      'completionRate': completionRate.toStringAsFixed(1),
      'recommendations': recommendations,
    };
  }
}
