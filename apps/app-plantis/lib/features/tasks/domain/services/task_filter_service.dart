import '../../presentation/providers/tasks_state.dart';
import '../entities/task.dart' as task_entity;
import 'task_filter_strategies.dart';

/// Interface for task filtering and search operations
abstract class ITaskFilterService {
  /// Applies comprehensive filtering logic to a list of tasks
  List<task_entity.Task> applyFilters(
    List<task_entity.Task> allTasks,
    TasksFilterType currentFilter,
    String searchQuery,
    String? selectedPlantId,
    List<task_entity.TaskType> selectedTaskTypes,
    List<task_entity.TaskPriority> selectedPriorities,
  );

  /// Searches tasks by title or description
  List<task_entity.Task> searchTasks(
    List<task_entity.Task> tasks,
    String query,
  );

  /// Filters tasks by status and date range using strategy pattern
  List<task_entity.Task> filterByStatus(
    List<task_entity.Task> tasks,
    TasksFilterType filter,
  );

  /// Filters tasks by plant ID
  List<task_entity.Task> filterByPlant(
    List<task_entity.Task> tasks,
    String plantId,
  );

  /// Filters tasks by priority levels
  List<task_entity.Task> filterByPriorities(
    List<task_entity.Task> tasks,
    List<task_entity.TaskPriority> priorities,
  );

  /// Filters tasks by task types
  List<task_entity.Task> filterByTaskTypes(
    List<task_entity.Task> tasks,
    List<task_entity.TaskType> taskTypes,
  );

  /// Returns high priority tasks (high or urgent)
  List<task_entity.Task> getHighPriorityTasks(
    List<task_entity.Task> tasks,
  );

  /// Returns medium priority tasks
  List<task_entity.Task> getMediumPriorityTasks(
    List<task_entity.Task> tasks,
  );

  /// Returns low priority tasks
  List<task_entity.Task> getLowPriorityTasks(
    List<task_entity.Task> tasks,
  );
}

/// Implementation of task filtering service
/// Uses Strategy Pattern for filterByStatus to allow extensible filter types
/// without modifying existing code (Open/Closed Principle - SOLID)
class TaskFilterService implements ITaskFilterService {
  final TaskFilterStrategyRegistry _strategyRegistry;

  TaskFilterService({
    TaskFilterStrategyRegistry? strategyRegistry,
  }) : _strategyRegistry = strategyRegistry ?? TaskFilterStrategyRegistry();

  @override
  List<task_entity.Task> applyFilters(
    List<task_entity.Task> allTasks,
    TasksFilterType currentFilter,
    String searchQuery,
    String? selectedPlantId,
    List<task_entity.TaskType> selectedTaskTypes,
    List<task_entity.TaskPriority> selectedPriorities,
  ) {
    List<task_entity.Task> tasks = List.from(allTasks);

    // Apply status/date filter using strategy pattern
    tasks = filterByStatus(tasks, currentFilter);

    // Apply plant filter
    if (currentFilter == TasksFilterType.byPlant && selectedPlantId != null) {
      tasks = filterByPlant(tasks, selectedPlantId);
    }

    // Apply task type filter
    if (selectedTaskTypes.isNotEmpty) {
      tasks = filterByTaskTypes(tasks, selectedTaskTypes);
    }

    // Apply priority filter
    if (selectedPriorities.isNotEmpty) {
      tasks = filterByPriorities(tasks, selectedPriorities);
    }

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      tasks = searchTasks(tasks, searchQuery);
    }

    // Sort tasks
    tasks = _sortTasks(tasks);

    return tasks;
  }

  @override
  List<task_entity.Task> searchTasks(
    List<task_entity.Task> tasks,
    String query,
  ) {
    final lowerQuery = query.toLowerCase();
    return tasks
        .where(
          (task) =>
              task.title.toLowerCase().contains(lowerQuery) ||
              (task.description?.toLowerCase().contains(lowerQuery) ?? false),
        )
        .toList();
  }

  @override
  List<task_entity.Task> filterByStatus(
    List<task_entity.Task> tasks,
    TasksFilterType filter,
  ) {
    // Get strategy from registry (Open/Closed Principle)
    final strategy = _strategyRegistry.getStrategy(filter);

    if (strategy == null) {
      // Fallback to all tasks if strategy not found
      return tasks;
    }

    // Apply the strategy
    return strategy.apply(tasks);
  }

  @override
  List<task_entity.Task> filterByPlant(
    List<task_entity.Task> tasks,
    String plantId,
  ) {
    return tasks.where((t) => t.plantId == plantId).toList();
  }

  @override
  List<task_entity.Task> filterByPriorities(
    List<task_entity.Task> tasks,
    List<task_entity.TaskPriority> priorities,
  ) {
    return tasks.where((task) => priorities.contains(task.priority)).toList();
  }

  @override
  List<task_entity.Task> filterByTaskTypes(
    List<task_entity.Task> tasks,
    List<task_entity.TaskType> taskTypes,
  ) {
    return tasks.where((task) => taskTypes.contains(task.type)).toList();
  }

  @override
  List<task_entity.Task> getHighPriorityTasks(
    List<task_entity.Task> tasks,
  ) {
    return tasks
        .where(
          (t) =>
              t.priority == task_entity.TaskPriority.high ||
              t.priority == task_entity.TaskPriority.urgent,
        )
        .toList();
  }

  @override
  List<task_entity.Task> getMediumPriorityTasks(
    List<task_entity.Task> tasks,
  ) {
    return tasks
        .where((t) => t.priority == task_entity.TaskPriority.medium)
        .toList();
  }

  @override
  List<task_entity.Task> getLowPriorityTasks(
    List<task_entity.Task> tasks,
  ) {
    return tasks
        .where((t) => t.priority == task_entity.TaskPriority.low)
        .toList();
  }

  /// Sorts tasks by status, priority, and due date
  List<task_entity.Task> _sortTasks(List<task_entity.Task> tasks) {
    tasks.sort((a, b) {
      // Sort by status first (pending before completed)
      if (a.status != b.status) {
        if (a.status == task_entity.TaskStatus.pending) return -1;
        if (b.status == task_entity.TaskStatus.pending) return 1;
      }

      // Then by priority
      final aPriorityIndex = task_entity.TaskPriority.values.indexOf(a.priority);
      final bPriorityIndex = task_entity.TaskPriority.values.indexOf(b.priority);

      if (aPriorityIndex != bPriorityIndex) {
        return bPriorityIndex.compareTo(aPriorityIndex); // Higher priority first
      }

      // Finally by due date
      return a.dueDate.compareTo(b.dueDate);
    });

    return tasks;
  }
}
