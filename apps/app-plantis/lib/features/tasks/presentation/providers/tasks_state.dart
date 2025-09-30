import 'package:equatable/equatable.dart';

import '../../core/constants/tasks_constants.dart';
import '../../domain/entities/task.dart' as task_entity;

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
/// - **Immutability**: All properties are final, preventing accidental mutations
/// - **Equality**: Implements Equatable for efficient change detection
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
class TasksState extends Equatable {
  final List<task_entity.Task> allTasks;
  final List<task_entity.Task> filteredTasks;
  final bool isLoading;
  final String? errorMessage;
  final TasksFilterType currentFilter;
  final String? selectedPlantId;
  final String searchQuery;
  final List<task_entity.TaskType> selectedTaskTypes;
  final List<task_entity.TaskPriority> selectedPriorities;

  // Granular loading states
  final Map<String, bool> individualTaskOperations; // taskId -> isLoading
  final Set<TaskLoadingOperation> activeOperations;
  final String? currentOperationMessage;

  const TasksState({
    this.allTasks = const [],
    this.filteredTasks = const [],
    this.isLoading = false,
    this.errorMessage,
    this.currentFilter = TasksFilterType.all,
    this.selectedPlantId,
    this.searchQuery = '',
    this.selectedTaskTypes = const [],
    this.selectedPriorities = const [],
    this.individualTaskOperations = const {},
    this.activeOperations = const {},
    this.currentOperationMessage,
  });

  /// Creates a copy of this state with some values changed
  TasksState copyWith({
    List<task_entity.Task>? allTasks,
    List<task_entity.Task>? filteredTasks,
    bool? isLoading,
    String? errorMessage,
    TasksFilterType? currentFilter,
    String? selectedPlantId,
    String? searchQuery,
    List<task_entity.TaskType>? selectedTaskTypes,
    List<task_entity.TaskPriority>? selectedPriorities,
    Map<String, bool>? individualTaskOperations,
    Set<TaskLoadingOperation>? activeOperations,
    String? currentOperationMessage,
    bool clearError = false,
    bool clearOperationMessage = false,
  }) {
    return TasksState(
      allTasks: allTasks ?? this.allTasks,
      filteredTasks: filteredTasks ?? this.filteredTasks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      currentFilter: currentFilter ?? this.currentFilter,
      selectedPlantId: selectedPlantId ?? this.selectedPlantId,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTaskTypes: selectedTaskTypes ?? this.selectedTaskTypes,
      selectedPriorities: selectedPriorities ?? this.selectedPriorities,
      individualTaskOperations:
          individualTaskOperations ?? this.individualTaskOperations,
      activeOperations: activeOperations ?? this.activeOperations,
      currentOperationMessage:
          clearOperationMessage
              ? null
              : currentOperationMessage ?? this.currentOperationMessage,
    );
  }

  /// Factory constructor for the initial state
  factory TasksState.initial() {
    return const TasksState();
  }

  /// Factory constructor for loading state
  factory TasksState.loading() {
    return const TasksState(isLoading: true);
  }

  /// Factory constructor for error state
  factory TasksState.error(String message, {TasksState? previousState}) {
    if (previousState != null) {
      return previousState.copyWith(isLoading: false, errorMessage: message);
    }
    return TasksState(errorMessage: message);
  }

  // Computed properties (getters)
  bool get hasError => errorMessage != null;
  bool get isEmpty => filteredTasks.isEmpty && !isLoading;

  // Granular loading state getters
  bool isTaskOperationLoading(String taskId) =>
      individualTaskOperations[taskId] ?? false;
  bool get hasActiveOperations => activeOperations.isNotEmpty;
  bool isOperationActive(TaskLoadingOperation operation) =>
      activeOperations.contains(operation);
  bool get isRefreshing => isOperationActive(TaskLoadingOperation.refreshing);
  bool get isAddingTask => isOperationActive(TaskLoadingOperation.addingTask);
  bool get isSyncing => isOperationActive(TaskLoadingOperation.syncing);

  /// Task statistics
  int get totalTasks => allTasks.length;

  int get completedTasks =>
      allTasks
          .where((t) => t.status == task_entity.TaskStatus.completed)
          .length;

  int get pendingTasks =>
      allTasks.where((t) => t.status == task_entity.TaskStatus.pending).length;

  int get overdueTasks =>
      allTasks
          .where(
            (t) => t.isOverdue && t.status == task_entity.TaskStatus.pending,
          )
          .length;

  int get todayTasks =>
      allTasks
          .where(
            (t) => t.isDueToday && t.status == task_entity.TaskStatus.pending,
          )
          .length;

  int get upcomingTasksCount {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final nextWeek = now.add(TasksConstants.upcomingTasksDuration);

    return allTasks
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
        .where(
          (t) =>
              t.status == task_entity.TaskStatus.pending &&
              t.dueDate.isAfter(today),
        )
        .length;
  }

  /// Get tasks filtered by plant ID
  List<task_entity.Task> getTasksForPlant(String plantId) {
    return allTasks.where((task) => task.plantId == plantId).toList();
  }

  /// Get overdue tasks list
  List<task_entity.Task> get overdueTasksList =>
      allTasks
          .where(
            (t) => t.isOverdue && t.status == task_entity.TaskStatus.pending,
          )
          .toList();

  /// Get today's tasks
  List<task_entity.Task> get todayTasksList =>
      allTasks
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
          .where((t) => t.status == task_entity.TaskStatus.completed)
          .toList();

  @override
  List<Object?> get props => [
    allTasks,
    filteredTasks,
    isLoading,
    errorMessage,
    currentFilter,
    selectedPlantId,
    searchQuery,
    selectedTaskTypes,
    selectedPriorities,
    individualTaskOperations,
    activeOperations,
    currentOperationMessage,
  ];

  @override
  String toString() {
    return 'TasksState('
        'totalTasks: $totalTasks, '
        'pendingTasks: $pendingTasks, '
        'completedTasks: $completedTasks, '
        'isLoading: $isLoading, '
        'hasError: $hasError, '
        'filter: $currentFilter'
        ')';
  }
}
