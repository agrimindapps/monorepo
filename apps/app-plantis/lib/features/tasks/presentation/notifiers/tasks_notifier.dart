import 'dart:async';

import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

import '../../../../core/auth/auth_state_notifier.dart';
import '../../../../core/services/notification_permission_status.dart';
import '../../../../core/services/task_notification_service.dart';
import '../../domain/entities/task.dart' as task_entity;
import '../../domain/services/task_filter_service.dart';
import '../../domain/services/task_ownership_validator.dart';
import '../../domain/usecases/add_task_usecase.dart';
import '../../domain/usecases/complete_task_usecase.dart';
import '../../domain/usecases/get_task_by_id_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../providers/tasks_providers.dart';
import '../providers/tasks_state.dart';

part 'tasks_notifier.g.dart';

/// Root TasksNotifier - Orchestrates specialized notifiers (SRP)
///
/// Responsibilities (Coordinator Pattern):
/// - Load and sync tasks from repository
/// - Coordinate between specialized notifiers
/// - Authentication state management
/// - Notification service management
/// - CRUD operations (Merged from TasksCrudNotifier to fix state split)
///
/// Delegates to specialized notifiers:
/// - TasksQueryNotifier: LIST, SEARCH, FILTER
/// - TasksScheduleNotifier: RECURRING, REMINDERS, SCHEDULING
/// - TasksRecommendationNotifier: RECOMMENDATIONS, SUGGESTIONS
@riverpod
class TasksNotifier extends _$TasksNotifier {
  late final GetTasksUseCase _getTasksUseCase;
  late final AddTaskUseCase _addTaskUseCase;
  late final CompleteTaskUseCase _completeTaskUseCase;
  late final GetTaskByIdUseCase _getTaskByIdUseCase;
  late final TaskNotificationService _notificationService;
  late final AuthStateNotifier _authStateNotifier;
  late final ITaskFilterService _filterService;
  late final ITaskOwnershipValidator _ownershipValidator;
  StreamSubscription<UserEntity?>? _authSubscription;

  @override
  Future<TasksState> build() async {
    _getTasksUseCase = ref.read(getTasksUseCaseProvider);
    _addTaskUseCase = ref.read(addTaskUseCaseProvider);
    _completeTaskUseCase = ref.read(completeTaskUseCaseProvider);
    _getTaskByIdUseCase = ref.read(getTaskByIdUseCaseProvider);
    _notificationService = TaskNotificationService();
    _authStateNotifier = AuthStateNotifier.instance;
    _filterService = ref.read(taskFilterServiceProvider);
    _ownershipValidator = ref.read(taskOwnershipValidatorProvider);

    await _initializeNotificationService();
    _initializeAuthListener();

    ref.onDispose(() {
      _authSubscription?.cancel();
    });

    return await _loadTasksInternal();
  }

  /// Internal method to load tasks without triggering external operations
  Future<TasksState> _loadTasksInternal() async {
    try {
      debugPrint('🔄 TasksNotifier: Loading initial tasks...');

      final result = await _getTasksUseCase(const NoParams());

      return result.fold(
        (failure) {
          debugPrint(
            '❌ TasksNotifier: Failed to load initial tasks: ${failure.message}',
          );
          return TasksState.error(failure.userMessage);
        },
        (tasks) {
          debugPrint('✅ TasksNotifier: Loaded ${tasks.length} tasks');
          _notificationService.checkOverdueTasks(tasks);
          _notificationService.rescheduleTaskNotifications(tasks);

          return TasksState(
            allTasks: tasks,
            filteredTasks: tasks,
            isLoading: false,
          );
        },
      );
    } catch (e) {
      debugPrint('❌ TasksNotifier: Error loading initial tasks: $e');
      return TasksState.error('Erro ao carregar tarefas: $e');
    }
  }

  /// Initializes the authentication state listener
  void _initializeAuthListener() {
    _authSubscription = _authStateNotifier.userStream.listen((user) {
      debugPrint(
        '🔐 TasksNotifier: Auth state changed - user: ${user?.id}, initialized: ${_authStateNotifier.isInitialized}',
      );
      if (_authStateNotifier.isInitialized && user != null) {
        debugPrint('✅ TasksNotifier: Auth is stable, loading tasks...');
        loadTasks();
      } else if (_authStateNotifier.isInitialized && user == null) {
        debugPrint(
          '🔄 TasksNotifier: No user but auth initialized - clearing tasks',
        );
        state = AsyncValue.data(
          TasksState.initial().copyWith(
            allTasks: <task_entity.Task>[],
            filteredTasks: <task_entity.Task>[],
            errorMessage: null,
          ),
        );
      }
    });
  }

  /// Loads tasks from the remote data source with sync coordination
  Future<void> loadTasks() async {
    debugPrint('🔄 TasksNotifier: Starting load tasks...');

    try {
      await _loadTasksOperation();
    } catch (e) {
      debugPrint('❌ TasksNotifier: Load tasks failed: $e');
    }
  }

  Future<void> _loadTasksOperation() async {
    final currentState = state.value ?? TasksState.initial();
    final shouldShowLoading = currentState.allTasks.isEmpty;

    if (shouldShowLoading) {
      _updateState(
        (current) => current.copyWith(isLoading: true, errorMessage: null),
      );
    }

    try {
      debugPrint('🔄 TasksNotifier: Calling _getTasksUseCase...');
      final result = await _getTasksUseCase(const NoParams());
      debugPrint('✅ TasksNotifier: _getTasksUseCase completed successfully');

      result.fold(
        (failure) {
          _updateState(
            (current) => current.copyWith(
              isLoading: false,
              errorMessage: failure.userMessage,
            ),
          );
          throw Exception(failure.userMessage);
        },
        (tasks) {
          final filteredTasks = _filterService.applyFilters(
            tasks,
            currentState.currentFilter,
            currentState.searchQuery,
            currentState.selectedPlantId,
            currentState.selectedTaskTypes,
            currentState.selectedPriorities,
          );

          _updateState(
            (current) => current.copyWith(
              allTasks: tasks,
              filteredTasks: filteredTasks,
              isLoading: false,
              errorMessage: null,
            ),
          );
          _notificationService.checkOverdueTasks(tasks);
          _notificationService.rescheduleTaskNotifications(tasks);
        },
      );
    } catch (e) {
      debugPrint('❌ TasksNotifier: Load tasks operation failed: $e');
      _updateState(
        (current) => current.copyWith(
          isLoading: false,
          errorMessage: 'Erro ao carregar tarefas: $e',
        ),
      );
      rethrow;
    }
  }

  /// Adds a new task with offline support
  Future<bool> addTask(task_entity.Task task) async {
    try {
      final currentUser = _authStateNotifier.currentUser;
      if (currentUser == null) {
        _updateState(
          (current) => current.copyWith(
            errorMessage: 'Você deve estar autenticado para criar tarefas',
          ),
        );
        return false;
      }

      final taskWithUser = task.withUserId(currentUser.id);
      final result = await _addTaskUseCase(AddTaskParams(task: taskWithUser));

      return result.fold(
        (failure) {
          if (_isNetworkFailure(failure)) {
            _addOptimisticTask(taskWithUser);
            return true;
          } else {
            _updateState(
              (current) => current.copyWith(errorMessage: failure.userMessage),
            );
            return false;
          }
        },
        (addedTask) {
          _addTaskToState(addedTask);
          return true;
        },
      );
    } catch (e) {
      debugPrint('❌ TasksNotifier.addTask error: $e');
      return false;
    }
  }

  /// Completes a task with ownership validation
  Future<bool> completeTask(String taskId, {String? notes}) async {
    try {
      final task = await _getTaskWithOwnershipValidation(taskId);
      final result = await _completeTaskUseCase(
        CompleteTaskParams(taskId: taskId, notes: notes),
      );

      return result.fold(
        (failure) {
          if (_isNetworkFailure(failure)) {
            _completeTaskOptimistically(task, notes);
            return true;
          } else {
            _updateState(
              (current) => current.copyWith(errorMessage: failure.userMessage),
            );
            return false;
          }
        },
        (completedTask) {
          _updateTaskInState(completedTask);
          return true;
        },
      );
    } on UnauthorizedAccessException catch (e) {
      _updateState((current) => current.copyWith(errorMessage: e.message));
      return false;
    } catch (e) {
      debugPrint('❌ TasksNotifier.completeTask error: $e');
      return false;
    }
  }

  /// Helper: Get task with ownership validation
  Future<task_entity.Task> _getTaskWithOwnershipValidation(
      String taskId) async {
    final currentState = state.value ?? TasksState.initial();

    // 1. Try to find in local state first (fastest)
    final localTask = currentState.allTasks
        .whereType<task_entity.Task>()
        .cast<task_entity.Task?>()
        .firstWhere(
          (t) => t?.id == taskId,
          orElse: () => null,
        );

    if (localTask != null) {
      _ownershipValidator.validateOwnershipOrThrow(localTask);
      return localTask;
    }

    // 2. If not found locally, fetch from repository
    final result = await _getTaskByIdUseCase(taskId);

    return result.fold(
      (failure) => throw Exception('Task not found: $taskId'),
      (task) {
        _ownershipValidator.validateOwnershipOrThrow(task);
        return task;
      },
    );
  }

  /// Helper: Add optimistic task for offline support
  void _addOptimisticTask(task_entity.Task task) {
    final optimisticTask = task.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      isDirty: true,
    );
    _addTaskToState(optimisticTask);
  }

  /// Helper: Add task to current state
  void _addTaskToState(task_entity.Task task) {
    final currentState = state.value ?? TasksState.initial();
    final updatedTasks = List<task_entity.Task>.from(currentState.allTasks)
      ..add(task);
    final filteredTasks = _applyCurrentFilters(updatedTasks);

    _updateState(
      (current) => current.copyWith(
        allTasks: updatedTasks,
        filteredTasks: filteredTasks,
        errorMessage: null,
      ),
    );
  }

  /// Helper: Update task in state
  void _updateTaskInState(task_entity.Task task) {
    final currentState = state.value ?? TasksState.initial();
    final updatedTasks = currentState.allTasks
        .whereType<task_entity.Task>()
        .map((t) => t.id == task.id ? task : t)
        .toList();

    final filteredTasks = _applyCurrentFilters(updatedTasks);

    _updateState(
      (current) => current.copyWith(
        allTasks: updatedTasks,
        filteredTasks: filteredTasks,
        errorMessage: null,
      ),
    );
  }

  /// Helper: Complete task optimistically
  void _completeTaskOptimistically(
    task_entity.Task task,
    String? notes,
  ) {
    final completedTask = task.copyWithTaskData(
      status: task_entity.TaskStatus.completed,
      completedAt: DateTime.now(),
      completionNotes: notes,
    );
    _updateTaskInState(completedTask);
  }

  /// Helper: Apply current filters to task list
  List<task_entity.Task> _applyCurrentFilters(
    List<task_entity.Task> tasks,
  ) {
    final currentState = state.value ?? TasksState.initial();
    return _filterService.applyFilters(
      tasks,
      currentState.currentFilter,
      currentState.searchQuery,
      currentState.selectedPlantId,
      currentState.selectedTaskTypes,
      currentState.selectedPriorities,
    );
  }

  /// Helper: Check if failure is network-related
  bool _isNetworkFailure(Failure failure) {
    return failure is NetworkFailure ||
        failure.toString().contains('NetworkException');
  }

  /// Searches tasks by query string
  void searchTasks(String query) {
    final currentState = state.value ?? TasksState.initial();
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
    final currentState = state.value ?? TasksState.initial();
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
    List<task_entity.TaskType>? taskTypes,
    List<task_entity.TaskPriority>? priorities,
    String? plantId,
  }) {
    final currentState = state.value ?? TasksState.initial();
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

  /// Refreshes tasks from the remote data source with visual feedback
  Future<void> refresh() async {
    try {
      await loadTasks();
    } finally {
      // Refresh complete
    }
  }

  /// Clears the current error state
  void clearError() {
    _updateState((current) => current.copyWith(errorMessage: null));
  }

  /// Sets filtering to show tasks for a specific plant
  void setPlantFilter(String? plantId) {
    setFilter(TasksFilterType.byPlant, plantId: plantId);
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


  /// Initializes the notification service with comprehensive setup
  Future<void> _initializeNotificationService() async {
    try {
      final initResult = await _notificationService.initialize();
      if (initResult) {
        await _notificationService.initializeNotificationHandlers();
        debugPrint(
          '✅ TasksNotifier: Notification service initialized successfully',
        );
      } else {
        debugPrint(
          '⚠️ TasksNotifier: Failed to initialize notification service',
        );
      }
    } catch (e) {
      debugPrint(
        '❌ TasksNotifier: Error initializing notification service: $e',
      );
    }
  }

  /// Retrieves the current notification permission status
  Future<NotificationPermissionStatus> getNotificationPermissionStatus() async {
    return await _notificationService.getPermissionStatus();
  }

  /// Requests notification permissions from the user
  Future<bool> requestNotificationPermissions() async {
    try {
      return true;
    } catch (e) {
      debugPrint('❌ Error requesting notification permissions: $e');
      return false;
    }
  }

  /// Opens the system notification settings for the app
  Future<bool> openNotificationSettings() async {
    return await _notificationService.openNotificationSettings();
  }

  /// Returns the count of currently scheduled notifications
  Future<int> getScheduledNotificationsCount() async {
    return await _notificationService.getScheduledNotificationsCount();
  }

  /// Helper: Update state
  void _updateState(TasksState Function(TasksState current) update) {
    final currentState = state.value ?? TasksState.initial();
    state = AsyncValue.data(update(currentState));
  }

  /// Alias for setFilter - for backwards compatibility
  void filterTasks(TasksFilterType filter, {String? plantId}) {
    setFilter(filter, plantId: plantId);
  }
}

/// Alias for backwards compatibility with legacy code
/// Use tasksProvider instead in new code
const tasksNotifierProvider = tasksProvider;
