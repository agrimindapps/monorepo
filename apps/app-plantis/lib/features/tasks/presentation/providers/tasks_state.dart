import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/constants/tasks_constants.dart';
import '../../domain/entities/task.dart' as task_entity;

part 'tasks_state.freezed.dart';

// Type aliases for Freezed compatibility
typedef Task = task_entity.Task;
typedef TaskType = task_entity.TaskType;
typedef TaskPriority = task_entity.TaskPriority;
typedef TaskStatus = task_entity.TaskStatus;

/// Enumeration defining all available task filter types
///
/// This enum provides predefined filter categories for organizing and displaying tasks.
/// Each filter type has an associated display name for UI presentation.
///
/// Available filters:
/// - **all**: Shows all tasks regardless of status or date
/// - **today**: Shows only tasks due today and still pending
/// - **overdue**: Shows tasks that are past their due date and still pending
/// - **upcoming**: Shows pending tasks due within the next 15 days (short-term planning)
/// - **allFuture**: Shows all pending tasks with future dates (unlimited - long-term view)
/// - **completed**: Shows all completed tasks
/// - **byPlant**: Special filter for showing tasks of a specific plant
///
/// Usage:
/// ```dart
/// final filter = TasksFilterType.today;
/// print(filter.displayName); // "Hoje"
/// ```
enum TasksFilterType {
  all('Todas'),
  today('Hoje'),
  overdue('Atrasadas'),
  upcoming('Próxima'),
  allFuture('Futuras'),
  completed('Concluídas'),
  byPlant('Por Planta');

  const TasksFilterType(this.displayName);

  /// Localized display name for the filter type
  final String displayName;
}

/// Enumeration for tracking granular loading operations in the tasks system
///
/// This enum enables precise tracking of different types of operations that can
/// be in progress simultaneously. It allows the UI to show specific loading
/// indicators and messages for each operation type.
///
/// Operations:
/// - **loadingTasks**: Initial loading of tasks from remote source
/// - **addingTask**: Creating a new task (user-initiated)
/// - **completingTask**: Marking a task as completed (user-initiated)
/// - **syncing**: Synchronizing data with remote source (background)
/// - **refreshing**: User-initiated refresh operation (pull-to-refresh)
///
/// Benefits:
/// - Enables granular loading states in the UI
/// - Prevents conflicting operations from interfering with each other
/// - Provides clear feedback to users about what's happening
/// - Allows for operation-specific error handling
enum TaskLoadingOperation {
  loadingTasks,
  addingTask,
  completingTask,
  syncing,
  refreshing,
}

/// Immutable state class for comprehensive tasks management
///
/// This state class follows the principles of immutable state management to provide
/// better performance, predictability, and debugging capabilities. It encapsulates
/// all task-related data and computed properties in a single, cohesive state object.
///
/// Key features:
/// - **Immutability**: All properties are final with @freezed code generation
/// - **Equality**: Automatic equality implementation via @freezed
/// - **Computed Properties**: Provides calculated values like statistics and filtered lists
/// - **Granular Loading**: Tracks multiple concurrent operations independently
/// - **Type Safety**: Uses strong typing throughout for reliability
///
/// State includes:
/// - Complete task lists (all tasks and filtered subsets)
/// - Loading states for different operations
/// - Error handling with user-friendly messages
/// - Filter and search state
/// - Task statistics and computed properties
///
/// Usage:
/// ```dart
/// final newState = currentState.copyWith(
///   allTasks: updatedTasks,
///   isLoading: false,
/// );
/// ```
@freezed
sealed class TasksState with _$TasksState {
  const factory TasksState({
    @Default([]) List<task_entity.Task> allTasks,
    @Default([]) List<task_entity.Task> filteredTasks,
    @Default(false) bool isLoading,
    String? errorMessage,
    @Default(TasksFilterType.today) TasksFilterType currentFilter,
    String? selectedPlantId,
    @Default('') String searchQuery,
    @Default([]) List<task_entity.TaskType> selectedTaskTypes,
    @Default([]) List<task_entity.TaskPriority> selectedPriorities,
    @Default({}) Map<String, bool> individualTaskOperations,
    @Default({}) Set<TaskLoadingOperation> activeOperations,
    String? currentOperationMessage,
  }) = _TasksState;
}

/// Extension providing computed properties and methods for TasksState
extension TasksStateX on TasksState {
  /// Factory constructor for the initial state
  static TasksState initial() => const TasksState();

  /// Factory constructor for loading state
  static TasksState loading() => const TasksState(isLoading: true);

  /// Factory constructor for error state
  static TasksState error(String message, {TasksState? previousState}) {
    if (previousState != null) {
      return previousState.copyWith(isLoading: false, errorMessage: message);
    }
    return TasksState(errorMessage: message);
  }

  // ==================== Computed Properties ====================

  /// Returns true if there's an error message
  bool get hasError => errorMessage != null;

  /// Returns true if filtered tasks are empty and not loading
  bool get isEmpty => filteredTasks.isEmpty && !isLoading;

  /// Checks if a specific task operation is loading
  bool isTaskOperationLoading(String taskId) =>
      individualTaskOperations[taskId] ?? false;

  /// Returns true if there are any active operations
  bool get hasActiveOperations => activeOperations.isNotEmpty;

  /// Checks if a specific operation is active
  bool isOperationActive(TaskLoadingOperation operation) =>
      activeOperations.contains(operation);

  /// Returns true if refreshing operation is active
  bool get isRefreshing => isOperationActive(TaskLoadingOperation.refreshing);

  /// Returns true if adding task operation is active
  bool get isAddingTask => isOperationActive(TaskLoadingOperation.addingTask);

  /// Returns true if syncing operation is active
  bool get isSyncing => isOperationActive(TaskLoadingOperation.syncing);

  // ==================== Task Statistics ====================

  /// Total number of tasks
  int get totalTasks => allTasks.length;

  /// Number of completed tasks
  int get completedTasks =>
      allTasks
          .whereType<task_entity.Task>()
          .where((t) => t.status == task_entity.TaskStatus.completed)
          .length;

  /// Number of pending tasks
  int get pendingTasks =>
      allTasks
          .whereType<task_entity.Task>()
          .where((t) => t.status == task_entity.TaskStatus.pending)
          .length;

  /// Number of overdue tasks
  int get overdueTasks =>
      allTasks
          .whereType<task_entity.Task>()
          .where(
            (t) => t.isOverdue && t.status == task_entity.TaskStatus.pending,
          )
          .length;

  /// Number of tasks due today
  int get todayTasks =>
      allTasks
          .whereType<task_entity.Task>()
          .where(
            (t) => t.isDueToday && t.status == task_entity.TaskStatus.pending,
          )
          .length;

  /// Number of upcoming tasks (within next 15 days)
  int get upcomingTasksCount {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final nextWeek = now.add(TasksConstants.upcomingTasksDuration);

    return allTasks
        .whereType<task_entity.Task>()
        .where(
          (t) =>
              t.status == task_entity.TaskStatus.pending &&
              t.dueDate.isAfter(tomorrow) &&
              t.dueDate.isBefore(nextWeek),
        )
        .length;
  }

  /// Get count of all future tasks (beyond upcoming window)
  int get allFutureTasksCount {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return allTasks
        .whereType<task_entity.Task>()
        .where(
          (t) =>
              t.status == task_entity.TaskStatus.pending &&
              t.dueDate.isAfter(today),
        )
        .length;
  }

  // ==================== Filtered Task Lists ====================

  /// Get tasks filtered by plant ID
  List<task_entity.Task> getTasksForPlant(String plantId) {
    return allTasks
        .whereType<task_entity.Task>()
        .where((task) => task.plantId == plantId)
        .toList();
  }

  /// Get overdue tasks list
  List<task_entity.Task> get overdueTasksList =>
      allTasks
          .whereType<task_entity.Task>()
          .where(
            (t) => t.isOverdue && t.status == task_entity.TaskStatus.pending,
          )
          .toList();

  /// Get today's tasks
  List<task_entity.Task> get todayTasksList =>
      allTasks
          .whereType<task_entity.Task>()
          .where(
            (t) => t.isDueToday && t.status == task_entity.TaskStatus.pending,
          )
          .toList();

  /// Get upcoming tasks
  List<task_entity.Task> get upcomingTasks {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final nextWeek = now.add(TasksConstants.upcomingTasksDuration);

    return allTasks
        .whereType<task_entity.Task>()
        .where(
          (t) =>
              t.status == task_entity.TaskStatus.pending &&
              t.dueDate.isAfter(tomorrow) &&
              t.dueDate.isBefore(nextWeek),
        )
        .toList();
  }

  /// Get completed tasks
  List<task_entity.Task> get completedTasksList =>
      allTasks
          .whereType<task_entity.Task>()
          .where((t) => t.status == task_entity.TaskStatus.completed)
          .toList();

  /// Get high priority tasks (high and urgent)
  List<task_entity.Task> get highPriorityTasks =>
      filteredTasks
          .whereType<task_entity.Task>()
          .where(
            (t) =>
                t.priority == task_entity.TaskPriority.high ||
                t.priority == task_entity.TaskPriority.urgent,
          )
          .toList();

  /// Get medium priority tasks
  List<task_entity.Task> get mediumPriorityTasks =>
      filteredTasks
          .whereType<task_entity.Task>()
          .where((t) => t.priority == task_entity.TaskPriority.medium)
          .toList();

  /// Get low priority tasks
  List<task_entity.Task> get lowPriorityTasks =>
      filteredTasks
          .whereType<task_entity.Task>()
          .where((t) => t.priority == task_entity.TaskPriority.low)
          .toList();

  // ==================== Custom CopyWith Extensions ====================

  /// CopyWith helper for clearing error message
  TasksState copyWithClearError() => copyWith(errorMessage: null);

  /// CopyWith helper for clearing operation message
  TasksState copyWithClearOperationMessage() =>
      copyWith(currentOperationMessage: null);
}
