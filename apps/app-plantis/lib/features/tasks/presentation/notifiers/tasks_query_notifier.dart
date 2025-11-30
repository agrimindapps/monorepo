import 'package:core/core.dart' hide Column;

import '../../domain/entities/task.dart' as task_entity;
import '../../domain/services/task_filter_service.dart';
import '../providers/tasks_providers.dart';
import '../providers/tasks_state.dart';

part 'tasks_query_notifier.g.dart';

/// TasksQueryNotifier - Handles LIST, SEARCH, FILTER, HISTORY operations
///
/// Responsibilities (SRP):
/// - loadTasks() - Load and sync all tasks
/// - searchTasks() - Search by query
/// - setFilter() - Set task type filter
/// - setAdvancedFilters() - Set complex filters
/// - filterTasks() - Apply filter by plant ID
/// - refresh() - Manual refresh/sync
///
/// Does NOT handle:
/// - CRUD operations (see TasksCrudNotifier)
/// - Scheduling/recurring (see TasksScheduleNotifier)
/// - Recommendations (see TasksRecommendationNotifier)
@riverpod
class TasksQueryNotifier extends _$TasksQueryNotifier {
  late final ITaskFilterService _filterService;

  @override
  TasksState build() {
    _filterService = ref.read(taskFilterServiceProvider);
    return TasksStateX.initial();
  }

  /// Loads tasks from parent notifier (delegated from TasksNotifier)
  void loadTasksState(TasksState newState) {
    state = newState;
  }

  /// Searches tasks by query string
  void searchTasks(String query) {
    final currentState = state;
    if (currentState.allTasks.isEmpty) return;

    _updateState(
      (current) => current.copyWith(
        searchQuery: query,
        filteredTasks: _applyAllFilters(
          current.allTasks,
          query,
          current.currentFilter,
          current.selectedPlantId,
          current.selectedTaskTypes,
          current.selectedPriorities,
        ),
      ),
    );
  }

  /// Sets task type filter
  void setFilter(
    TasksFilterType filter, {
    String? plantId,
  }) {
    final currentState = state;
    if (currentState.allTasks.isEmpty) return;

    _updateState(
      (current) => current.copyWith(
        currentFilter: filter,
        selectedPlantId: plantId,
        filteredTasks: _applyAllFilters(
          current.allTasks,
          current.searchQuery,
          filter,
          plantId,
          current.selectedTaskTypes,
          current.selectedPriorities,
        ),
      ),
    );
  }

  /// Sets advanced filters for multiple criteria
  void setAdvancedFilters({
    required List<task_entity.TaskType>? taskTypes,
    required List<task_entity.TaskPriority>? priorities,
    String? plantId,
  }) {
    final currentState = state;
    if (currentState.allTasks.isEmpty) return;

    final newTaskTypes = taskTypes ?? currentState.selectedTaskTypes;
    final newPriorities = priorities ?? currentState.selectedPriorities;

    _updateState(
      (current) => current.copyWith(
        selectedTaskTypes: newTaskTypes,
        selectedPriorities: newPriorities,
        selectedPlantId: plantId ?? current.selectedPlantId,
        filteredTasks: _applyAllFilters(
          current.allTasks,
          current.searchQuery,
          current.currentFilter,
          plantId ?? current.selectedPlantId,
          newTaskTypes,
          newPriorities,
        ),
      ),
    );
  }

  /// Filters tasks by plant ID
  void filterTasks(
    TasksFilterType filter, {
    String? plantId,
  }) {
    setFilter(filter, plantId: plantId);
  }

  /// Filters task by plant ID specifically
  void setPlantFilter(String? plantId) {
    final currentState = state;
    if (currentState.allTasks.isEmpty) return;

    _updateState(
      (current) => current.copyWith(
        selectedPlantId: plantId,
        filteredTasks: _applyAllFilters(
          current.allTasks,
          current.searchQuery,
          current.currentFilter,
          plantId,
          current.selectedTaskTypes,
          current.selectedPriorities,
        ),
      ),
    );
  }

  /// Manual refresh (delegates to parent TasksNotifier)
  Future<void> refresh() async {
    // This will be coordinated with TasksNotifier
    // which will reload and update state
  }

  /// Helper: Apply all filters to task list
  List<task_entity.Task> _applyAllFilters(
    List<task_entity.Task> tasks,
    String searchQuery,
    TasksFilterType filter,
    String? plantId,
    List<task_entity.TaskType> taskTypes,
    List<task_entity.TaskPriority> priorities,
  ) {
    return _filterService.applyFilters(
      tasks,
      filter,
      searchQuery,
      plantId,
      taskTypes,
      priorities,
    );
  }

  /// Helper: Update state
  void _updateState(TasksState Function(TasksState current) update) {
    state = update(state);
  }
}

// LEGACY ALIAS
// ignore: deprecated_member_use_from_same_package
const tasksQueryNotifierProvider = tasksQueryProvider;
