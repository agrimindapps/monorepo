import '../../core/constants/tasks_constants.dart';
import '../../presentation/providers/tasks_state.dart';
import '../entities/task.dart' as task_entity;

/// Strategy interface for filtering tasks by status/type
/// Implements Strategy Pattern to allow extensible filter types
/// without modifying existing code (Open/Closed Principle)
abstract class TaskFilterStrategy {
  /// Apply filter strategy to tasks list
  List<task_entity.Task> apply(List<task_entity.Task> tasks);

  /// Get the filter type this strategy handles
  TasksFilterType get filterType;
}

/// Concrete strategy: Filter all tasks (no filtering)
class AllTasksFilterStrategy implements TaskFilterStrategy {
  @override
  TasksFilterType get filterType => TasksFilterType.all;

  @override
  List<task_entity.Task> apply(List<task_entity.Task> tasks) {
    return tasks;
  }
}

/// Concrete strategy: Filter tasks due today
class TodayTasksFilterStrategy implements TaskFilterStrategy {
  @override
  TasksFilterType get filterType => TasksFilterType.today;

  @override
  List<task_entity.Task> apply(List<task_entity.Task> tasks) {
    return tasks
        .where(
          (t) => t.isDueToday && t.status == task_entity.TaskStatus.pending,
        )
        .toList();
  }
}

/// Concrete strategy: Filter overdue tasks
class OverdueTasksFilterStrategy implements TaskFilterStrategy {
  @override
  TasksFilterType get filterType => TasksFilterType.overdue;

  @override
  List<task_entity.Task> apply(List<task_entity.Task> tasks) {
    return tasks.where((t) => t.isOverdue).toList();
  }
}

/// Concrete strategy: Filter tasks due in the next week
class UpcomingTasksFilterStrategy implements TaskFilterStrategy {
  @override
  TasksFilterType get filterType => TasksFilterType.upcoming;

  @override
  List<task_entity.Task> apply(List<task_entity.Task> tasks) {
    final now = DateTime.now();
    final nextWeek = now.add(TasksConstants.upcomingTasksDuration);
    return tasks
        .where(
          (t) =>
              t.status == task_entity.TaskStatus.pending &&
              t.dueDate.isAfter(now) &&
              t.dueDate.isBefore(nextWeek),
        )
        .toList();
  }
}

/// Concrete strategy: Filter all future tasks
class AllFutureTasksFilterStrategy implements TaskFilterStrategy {
  @override
  TasksFilterType get filterType => TasksFilterType.allFuture;

  @override
  List<task_entity.Task> apply(List<task_entity.Task> tasks) {
    final now = DateTime.now();
    return tasks
        .where(
          (t) =>
              t.status == task_entity.TaskStatus.pending &&
              t.dueDate.isAfter(now),
        )
        .toList();
  }
}

/// Concrete strategy: Filter completed tasks
class CompletedTasksFilterStrategy implements TaskFilterStrategy {
  @override
  TasksFilterType get filterType => TasksFilterType.completed;

  @override
  List<task_entity.Task> apply(List<task_entity.Task> tasks) {
    return tasks
        .where((t) => t.status == task_entity.TaskStatus.completed)
        .toList();
  }
}

/// Concrete strategy: Filter tasks by plant (returns all, filtering done elsewhere)
class ByPlantFilterStrategy implements TaskFilterStrategy {
  @override
  TasksFilterType get filterType => TasksFilterType.byPlant;

  @override
  List<task_entity.Task> apply(List<task_entity.Task> tasks) {
    return tasks;
  }
}

/// Registry for task filter strategies
/// Allows extensible addition of new filter strategies
/// without modifying existing code (Open/Closed Principle)
class TaskFilterStrategyRegistry {
  final Map<TasksFilterType, TaskFilterStrategy> _strategies = {};

  TaskFilterStrategyRegistry() {
    _registerDefaultStrategies();
  }

  /// Register all default strategies
  void _registerDefaultStrategies() {
    register(AllTasksFilterStrategy());
    register(TodayTasksFilterStrategy());
    register(OverdueTasksFilterStrategy());
    register(UpcomingTasksFilterStrategy());
    register(AllFutureTasksFilterStrategy());
    register(CompletedTasksFilterStrategy());
    register(ByPlantFilterStrategy());
  }

  /// Register a new filter strategy
  /// Can be called to add custom filters at runtime
  void register(TaskFilterStrategy strategy) {
    _strategies[strategy.filterType] = strategy;
  }

  /// Get strategy for a specific filter type
  TaskFilterStrategy? getStrategy(TasksFilterType filterType) {
    return _strategies[filterType];
  }

  /// Get all registered strategies
  Iterable<TaskFilterStrategy> getAllStrategies() {
    return _strategies.values;
  }

  /// Check if strategy is registered for a filter type
  bool hasStrategy(TasksFilterType filterType) {
    return _strategies.containsKey(filterType);
  }
}
