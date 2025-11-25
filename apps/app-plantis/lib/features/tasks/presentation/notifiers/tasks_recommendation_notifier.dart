import 'package:core/core.dart' hide Column;

import '../../domain/entities/task.dart' as task_entity;
import '../providers/tasks_state.dart';

part 'tasks_recommendation_notifier.g.dart';

/// TasksRecommendationNotifier - Handles RECOMMENDATIONS, SUGGESTIONS operations
///
/// Responsibilities (SRP):
/// - Task recommendations
/// - Smart suggestions
/// - Priority-based suggestions
/// - Plant health recommendations
/// - Optimization recommendations
///
/// Does NOT handle:
/// - CRUD operations (see TasksCrudNotifier)
/// - Query/filtering (see TasksQueryNotifier)
/// - Scheduling (see TasksScheduleNotifier)
@riverpod
class TasksRecommendationNotifier extends _$TasksRecommendationNotifier {
  @override
  TasksState build() {
    return TasksStateX.initial();
  }

  /// Updates state with new tasks (called from parent notifier)
  void updateTasksState(TasksState newState) {
    state = newState;
  }

  /// Gets recommended high-priority tasks
  List<task_entity.Task> getRecommendedHighPriorityTasks() {
    return state.allTasks
        .whereType<task_entity.Task>()
        .where((task) =>
            (task.priority == task_entity.TaskPriority.high ||
                task.priority == task_entity.TaskPriority.urgent) &&
            task.status == task_entity.TaskStatus.pending)
        .toList()
        ..sort((a, b) {
          // Sort by due date (nearest first)
          return a.dueDate.compareTo(b.dueDate);
        });
  }

  /// Gets recommended tasks to complete today
  List<task_entity.Task> getRecommendedTodayTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    return state.allTasks
        .whereType<task_entity.Task>()
        .where((task) {
          final dueDate = task.dueDate;
          return !dueDate.isBefore(today) &&
              dueDate.isBefore(tomorrow) &&
              task.status == task_entity.TaskStatus.pending;
        })
        .toList()
        ..sort((a, b) {
          // Sort by priority (higher first) - using enum index
          return _getPriorityValue(b.priority).compareTo(_getPriorityValue(a.priority));
        });
  }

  /// Helper to convert TaskPriority enum to numeric value for comparison
  int _getPriorityValue(task_entity.TaskPriority priority) {
    switch (priority) {
      case task_entity.TaskPriority.low:
        return 1;
      case task_entity.TaskPriority.medium:
        return 2;
      case task_entity.TaskPriority.high:
        return 3;
      case task_entity.TaskPriority.urgent:
        return 4;
    }
  }

  /// Gets suggested tasks based on plant health
  List<task_entity.Task> getPlantHealthSuggestions(String plantId) {
    return state.allTasks
        .whereType<task_entity.Task>()
        .where((task) =>
            task.plantId == plantId &&
            task.status == task_entity.TaskStatus.pending)
        .toList()
        ..sort((a, b) {
          // Prioritize by due date
          return a.dueDate.compareTo(b.dueDate);
        });
  }

  /// Gets optimization recommendations
  Map<String, dynamic> getOptimizationRecommendations() {
    final allTasks = state.allTasks.whereType<task_entity.Task>().toList();

    if (allTasks.isEmpty) {
      return {'message': 'No tasks to analyze'};
    }

    final overdueCount = allTasks
        .where((t) =>
            t.dueDate.isBefore(DateTime.now()) &&
            t.status != task_entity.TaskStatus.completed)
        .length;

    final highPriorityCount = allTasks
        .where((t) =>
            (t.priority == task_entity.TaskPriority.high ||
                t.priority == task_entity.TaskPriority.urgent) &&
            t.status == task_entity.TaskStatus.pending)
        .length;

    final completionRate = allTasks.isEmpty
        ? 0
        : (allTasks.where((t) => t.status == task_entity.TaskStatus.completed).length /
            allTasks.length *
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

    return {
      'overdueCount': overdueCount,
      'highPriorityCount': highPriorityCount,
      'completionRate': completionRate.toStringAsFixed(1),
      'recommendations': recommendations,
    };
  }

  /// Gets suggested filters based on task distribution
  Map<String, int> getSuggestedFilters() {
    final allTasks = state.allTasks.whereType<task_entity.Task>().toList();

    final taskTypeDistribution = <String, int>{};
    final plantDistribution = <String, int>{};
    final priorityDistribution = <String, int>{};

    for (final task in allTasks) {
      // Task type distribution
      final taskType = task.type.key;
      taskTypeDistribution[taskType] = (taskTypeDistribution[taskType] ?? 0) + 1;

      // Plant distribution
      final plantId = task.plantId;
      plantDistribution[plantId] = (plantDistribution[plantId] ?? 0) + 1;

      // Priority distribution
      final priorityKey = task.priority.key;
      priorityDistribution[priorityKey] =
          (priorityDistribution[priorityKey] ?? 0) + 1;
    }

    return {
      'taskTypes': taskTypeDistribution.length,
      'plants': plantDistribution.length,
      'priorityLevels': priorityDistribution.length,
    };
  }
}
