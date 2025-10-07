import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../features/tasks/core/constants/tasks_constants.dart';
import '../../features/tasks/domain/entities/task.dart' as task_entity;
import '../../features/tasks/domain/usecases/add_task_usecase.dart';
import '../../features/tasks/domain/usecases/complete_task_usecase.dart';
import '../../features/tasks/domain/usecases/get_tasks_usecase.dart';
import '../../features/tasks/presentation/providers/tasks_state.dart';
import '../auth/auth_state_notifier.dart';
import '../localization/app_strings.dart';
import '../services/offline_sync_queue_service.dart' as offline_queue;
import '../services/sync_coordinator_service.dart' hide SyncPriority;
import '../services/task_notification_service.dart'
    hide NotificationPermissionStatus;
import '../services/task_notification_service.dart' as notification_service;

/// Tasks Notifier that handles all task operations with immutable state
class TasksNotifier extends AsyncNotifier<TasksState> {
  late final GetTasksUseCase _getTasksUseCase;
  late final AddTaskUseCase _addTaskUseCase;
  late final CompleteTaskUseCase _completeTaskUseCase;
  late final TaskNotificationService _notificationService;
  late final AuthStateNotifier _authStateNotifier;
  late final SyncCoordinatorService _syncCoordinator;
  late final offline_queue.OfflineSyncQueueService _offlineQueue;
  StreamSubscription<UserEntity?>? _authSubscription;

  @override
  Future<TasksState> build() async {
    _getTasksUseCase = ref.read(getTasksUseCaseProvider);
    _addTaskUseCase = ref.read(addTaskUseCaseProvider);
    _completeTaskUseCase = ref.read(completeTaskUseCaseProvider);
    _notificationService = ref.read(taskNotificationServiceProvider);
    _authStateNotifier = AuthStateNotifier.instance;
    _syncCoordinator = SyncCoordinatorService.instance;
    _syncCoordinator.initialize();
    _offlineQueue = offline_queue.OfflineSyncQueueService.instance;
    await _offlineQueue.initialize();
    await _initializeNotificationService();
    _initializeAuthListener();
    ref.onDispose(() {
      _authSubscription?.cancel();
    });
    return TasksState.initial();
  }

  /// Initializes the authentication state listener
  void _initializeAuthListener() {
    _authSubscription = _authStateNotifier.userStream.listen((user) {
      debugPrint(
        '🔐 TasksProvider: Auth state changed - user: ${user?.id}, initialized: ${_authStateNotifier.isInitialized}',
      );
      if (_authStateNotifier.isInitialized && user != null) {
        debugPrint('✅ TasksProvider: Auth is stable, loading tasks...');
        loadTasks();
      } else if (_authStateNotifier.isInitialized && user == null) {
        debugPrint(
          '🔄 TasksProvider: No user but auth initialized - clearing tasks',
        );
        state = AsyncData(TasksState.initial());
      }
    });
  }

  /// Validates task ownership against the currently authenticated user
  bool _validateTaskOwnership(task_entity.Task task) {
    final currentUser = _authStateNotifier.currentUser;
    if (currentUser == null) {
      debugPrint('🚫 Access denied: No authenticated user');
      return false;
    }
    if (task.userId == null) {
      debugPrint(
        '🚫 Access denied: Task has null userId (potential security risk)',
      );
      return false;
    }
    if (task.userId == currentUser.id) {
      return true;
    }
    debugPrint(
      '🚫 Access denied: Task belongs to user ${task.userId}, current user is ${currentUser.id}',
    );
    return false;
  }

  /// Retrieves a task by ID and validates user ownership
  task_entity.Task _getTaskWithOwnershipValidation(String taskId) {
    final currentState = state.valueOrNull ?? TasksState.initial();
    final task = currentState.allTasks.firstWhere(
      (t) => t.id == taskId,
      orElse: () => throw Exception('Task not found: $taskId'),
    );

    if (!_validateTaskOwnership(task)) {
      throw const UnauthorizedAccessException(
        'You are not authorized to modify this task',
      );
    }

    return task;
  }

  /// Loads tasks from the remote data source with sync coordination
  Future<void> loadTasks() async {
    debugPrint('🔄 TasksProvider: Starting load tasks...');

    try {
      await _syncCoordinator.executeSyncOperation(
        operationType: TaskSyncOperations.loadTasks.name,
        priority: SyncPriority.high.index,
        minimumInterval: TasksConstants.syncMinimumInterval,
        operation: () => _loadTasksOperation(),
      );
    } on SyncThrottledException catch (e) {
      debugPrint('⚠️ Load tasks throttled: ${e.message}');
    } catch (e) {
      debugPrint('❌ TasksProvider: Load tasks failed: $e');
      final currentState = state.valueOrNull ?? TasksState.initial();
      state = AsyncData(
        currentState.copyWith(
          isLoading: false,
          errorMessage: 'Erro ao sincronizar tarefas: $e',
        ),
      );
    }
  }

  Future<void> _loadTasksOperation() async {
    final currentState = state.valueOrNull ?? TasksState.initial();
    final shouldShowLoading = currentState.allTasks.isEmpty;

    if (shouldShowLoading) {
      state = AsyncData(
        currentState.copyWith(
          isLoading: true,
          clearError: true,
          activeOperations: {
            ...currentState.activeOperations,
            TaskLoadingOperation.loadingTasks,
          },
          currentOperationMessage: AppStrings.loadingTasks,
        ),
      );
    } else {
      state = AsyncData(
        currentState.copyWith(
          clearError: true,
          activeOperations: {
            ...currentState.activeOperations,
            TaskLoadingOperation.syncing,
          },
          currentOperationMessage: AppStrings.synchronizing,
        ),
      );
    }

    try {
      debugPrint('🔄 TasksProvider: Calling _getTasksUseCase...');
      final result = await _getTasksUseCase(const NoParams());
      debugPrint('✅ TasksProvider: _getTasksUseCase completed successfully');

      result.fold(
        (failure) {
          final newState = state.valueOrNull ?? TasksState.initial();
          state = AsyncData(
            newState.copyWith(
              isLoading: false,
              errorMessage: _mapFailureToMessage(failure),
              activeOperations:
                  newState.activeOperations
                      .where(
                        (op) =>
                            op != TaskLoadingOperation.loadingTasks &&
                            op != TaskLoadingOperation.syncing,
                      )
                      .toSet(),
              clearOperationMessage: true,
            ),
          );
          throw Exception(_mapFailureToMessage(failure));
        },
        (tasks) {
          final newState = state.valueOrNull ?? TasksState.initial();
          final filteredTasks = _applyFiltersToTasks(
            tasks,
            newState.currentFilter,
            newState.searchQuery,
            newState.selectedPlantId,
            newState.selectedTaskTypes,
            newState.selectedPriorities,
          );

          state = AsyncData(
            newState.copyWith(
              allTasks: tasks,
              filteredTasks: filteredTasks,
              isLoading: false,
              clearError: true,
              activeOperations:
                  newState.activeOperations
                      .where(
                        (op) =>
                            op != TaskLoadingOperation.loadingTasks &&
                            op != TaskLoadingOperation.syncing,
                      )
                      .toSet(),
              clearOperationMessage: true,
            ),
          );
          _notificationService.checkOverdueTasks(tasks);
          _notificationService.rescheduleTaskNotifications(tasks);
        },
      );
    } catch (e) {
      debugPrint('❌ TasksProvider: Load tasks operation failed: $e');
      final newState = state.valueOrNull ?? TasksState.initial();
      state = AsyncData(
        newState.copyWith(
          isLoading: false,
          errorMessage: 'Erro ao carregar tarefas: $e',
          activeOperations:
              newState.activeOperations
                  .where(
                    (op) =>
                        op != TaskLoadingOperation.loadingTasks &&
                        op != TaskLoadingOperation.syncing,
                  )
                  .toSet(),
          clearOperationMessage: true,
        ),
      );
      rethrow;
    }
  }

  /// Adds a new task with offline support and user validation
  Future<bool> addTask(task_entity.Task task) async {
    try {
      return await _syncCoordinator.executeSyncOperation<bool>(
        operationType: TaskSyncOperations.addTask.name,
        priority: SyncPriority.critical.index,
        operation: () => _addTaskOperation(task),
      );
    } catch (e) {
      final currentState = state.valueOrNull ?? TasksState.initial();
      state = AsyncData(
        currentState.copyWith(errorMessage: AppStrings.errorSyncingNewTask),
      );
      return false;
    }
  }

  Future<bool> _addTaskOperation(task_entity.Task task) async {
    final currentState = state.valueOrNull ?? TasksState.initial();
    state = AsyncData(
      currentState.copyWith(
        clearError: true,
        activeOperations: {
          ...currentState.activeOperations,
          TaskLoadingOperation.addingTask,
        },
        currentOperationMessage: AppStrings.addingTask,
      ),
    );

    try {
      final currentUser = _authStateNotifier.currentUser;
      if (currentUser == null) {
        final newState = state.valueOrNull ?? TasksState.initial();
        state = AsyncData(
          newState.copyWith(
            errorMessage: AppStrings.mustBeAuthenticatedToCreateTasks,
            activeOperations:
                newState.activeOperations
                    .where((op) => op != TaskLoadingOperation.addingTask)
                    .toSet(),
            clearOperationMessage: true,
          ),
        );
        return false;
      }
      final taskWithUser = task.withUserId(currentUser.id);

      final result = await _addTaskUseCase(AddTaskParams(task: taskWithUser));

      return result.fold(
        (failure) {
          if (_isNetworkFailure(failure)) {
            debugPrint(
              '🌐 Network failure detected, queuing task for offline sync',
            );
            final optimisticTask = taskWithUser.copyWith(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              isDirty: true,
            );
            final newState = state.valueOrNull ?? TasksState.initial();
            final updatedTasks = [...newState.allTasks, optimisticTask];
            final filteredTasks = _applyFiltersToTasks(
              updatedTasks,
              newState.currentFilter,
              newState.searchQuery,
              newState.selectedPlantId,
              newState.selectedTaskTypes,
              newState.selectedPriorities,
            );

            state = AsyncData(
              newState.copyWith(
                allTasks: updatedTasks,
                filteredTasks: filteredTasks,
                clearError: true,
                activeOperations:
                    newState.activeOperations
                        .where((op) => op != TaskLoadingOperation.addingTask)
                        .toSet(),
                clearOperationMessage: true,
              ),
            );
            final queuedOperation = offline_queue.QueuedOperation(
              id: optimisticTask.id,
              type: OfflineTaskOperations.addTask.name,
              data: optimisticTask.toFirebaseMap(),
              createdAt: DateTime.now(),
              maxRetries: 3,
              retryCount: 0,
            );

            _offlineQueue.queueOperation(queuedOperation);

            return true; // Return success for optimistic update
          } else {
            final newState = state.valueOrNull ?? TasksState.initial();
            state = AsyncData(
              newState.copyWith(
                errorMessage: _mapFailureToMessage(failure),
                activeOperations:
                    newState.activeOperations
                        .where((op) => op != TaskLoadingOperation.addingTask)
                        .toSet(),
                clearOperationMessage: true,
              ),
            );
            throw Exception(_mapFailureToMessage(failure));
          }
        },
        (addedTask) {
          final newState = state.valueOrNull ?? TasksState.initial();
          final updatedTasks = [...newState.allTasks, addedTask];
          final filteredTasks = _applyFiltersToTasks(
            updatedTasks,
            newState.currentFilter,
            newState.searchQuery,
            newState.selectedPlantId,
            newState.selectedTaskTypes,
            newState.selectedPriorities,
          );

          state = AsyncData(
            newState.copyWith(
              allTasks: updatedTasks,
              filteredTasks: filteredTasks,
              clearError: true,
              activeOperations:
                  newState.activeOperations
                      .where((op) => op != TaskLoadingOperation.addingTask)
                      .toSet(),
              clearOperationMessage: true,
            ),
          );
          _notificationService.scheduleTaskNotification(addedTask);
          return true;
        },
      );
    } catch (e) {
      final newState = state.valueOrNull ?? TasksState.initial();
      state = AsyncData(
        newState.copyWith(
          errorMessage: AppStrings.unexpectedErrorAddingTask,
          activeOperations:
              newState.activeOperations
                  .where((op) => op != TaskLoadingOperation.addingTask)
                  .toSet(),
          clearOperationMessage: true,
        ),
      );
      rethrow;
    }
  }

  /// Completes a task with offline support and ownership validation
  Future<bool> completeTask(String taskId, {String? notes}) async {
    try {
      return await _syncCoordinator.executeSyncOperation<bool>(
        operationType: TaskSyncOperations.completeTask.name,
        priority: SyncPriority.critical.index,
        operation: () => _completeTaskOperation(taskId, notes),
      );
    } catch (e) {
      final currentState = state.valueOrNull ?? TasksState.initial();
      state = AsyncData(
        currentState.copyWith(
          errorMessage: AppStrings.errorSyncingTaskCompletion,
        ),
      );
      return false;
    }
  }

  Future<bool> _completeTaskOperation(String taskId, String? notes) async {
    final currentState = state.valueOrNull ?? TasksState.initial();
    final updatedOperations = Map<String, bool>.from(
      currentState.individualTaskOperations,
    );
    updatedOperations[taskId] = true;

    state = AsyncData(
      currentState.copyWith(
        clearError: true,
        individualTaskOperations: updatedOperations,
        currentOperationMessage: AppStrings.completingTask,
      ),
    );

    try {
      final task = _getTaskWithOwnershipValidation(taskId);

      final result = await _completeTaskUseCase(
        CompleteTaskParams(taskId: taskId, notes: notes),
      );

      return result.fold(
        (failure) {
          if (_isNetworkFailure(failure)) {
            debugPrint(
              '🌐 Network failure detected, queuing task completion for offline sync',
            );
            final completedTask = task.copyWithTaskData(
              status: task_entity.TaskStatus.completed,
              completedAt: DateTime.now(),
              completionNotes: notes,
            );
            final newState = state.valueOrNull ?? TasksState.initial();
            final updatedTasks =
                newState.allTasks.map((t) {
                  return t.id == taskId ? completedTask : t;
                }).toList();

            final filteredTasks = _applyFiltersToTasks(
              updatedTasks,
              newState.currentFilter,
              newState.searchQuery,
              newState.selectedPlantId,
              newState.selectedTaskTypes,
              newState.selectedPriorities,
            );

            final newOperations = Map<String, bool>.from(
              newState.individualTaskOperations,
            );
            newOperations.remove(taskId);

            state = AsyncData(
              newState.copyWith(
                allTasks: updatedTasks,
                filteredTasks: filteredTasks,
                clearError: true,
                individualTaskOperations: newOperations,
                clearOperationMessage: true,
              ),
            );
            final queuedOperation = offline_queue.QueuedOperation(
              id: taskId,
              type: OfflineTaskOperations.completeTask.name,
              data: {
                'taskId': taskId,
                'notes': notes,
                'completedAt': DateTime.now().toIso8601String(),
              },
              createdAt: DateTime.now(),
              maxRetries: 3,
              retryCount: 0,
            );

            _offlineQueue.queueOperation(queuedOperation);
            _notificationService.cancelTaskNotifications(taskId);
            _notificationService.rescheduleTaskNotifications(updatedTasks);

            return true; // Return success for optimistic update
          } else {
            final newState = state.valueOrNull ?? TasksState.initial();
            final newOperations = Map<String, bool>.from(
              newState.individualTaskOperations,
            );
            newOperations.remove(taskId);

            state = AsyncData(
              newState.copyWith(
                errorMessage: _mapFailureToMessage(failure),
                individualTaskOperations: newOperations,
                clearOperationMessage: true,
              ),
            );
            throw Exception(_mapFailureToMessage(failure));
          }
        },
        (completedTask) {
          final newState = state.valueOrNull ?? TasksState.initial();
          final updatedTasks =
              newState.allTasks.map((t) {
                return t.id == taskId ? completedTask : t;
              }).toList();

          final filteredTasks = _applyFiltersToTasks(
            updatedTasks,
            newState.currentFilter,
            newState.searchQuery,
            newState.selectedPlantId,
            newState.selectedTaskTypes,
            newState.selectedPriorities,
          );

          final newOperations = Map<String, bool>.from(
            newState.individualTaskOperations,
          );
          newOperations.remove(taskId);

          state = AsyncData(
            newState.copyWith(
              allTasks: updatedTasks,
              filteredTasks: filteredTasks,
              clearError: true,
              individualTaskOperations: newOperations,
              clearOperationMessage: true,
            ),
          );
          _notificationService.cancelTaskNotifications(taskId);
          _notificationService.rescheduleTaskNotifications(updatedTasks);

          return true;
        },
      );
    } on UnauthorizedAccessException catch (e) {
      final newState = state.valueOrNull ?? TasksState.initial();
      final newOperations = Map<String, bool>.from(
        newState.individualTaskOperations,
      );
      newOperations.remove(taskId);

      state = AsyncData(
        newState.copyWith(
          errorMessage: e.message,
          individualTaskOperations: newOperations,
          clearOperationMessage: true,
        ),
      );
      rethrow;
    } catch (e) {
      final newState = state.valueOrNull ?? TasksState.initial();
      final newOperations = Map<String, bool>.from(
        newState.individualTaskOperations,
      );
      newOperations.remove(taskId);

      state = AsyncData(
        newState.copyWith(
          errorMessage: AppStrings.unexpectedErrorCompletingTask,
          individualTaskOperations: newOperations,
          clearOperationMessage: true,
        ),
      );
      rethrow;
    }
  }

  /// Searches tasks by title, plant name, or description
  void searchTasks(String query) {
    final normalizedQuery = query.toLowerCase();
    final currentState = state.valueOrNull ?? TasksState.initial();

    if (currentState.searchQuery != normalizedQuery) {
      final filteredTasks = _applyFiltersToTasks(
        currentState.allTasks,
        currentState.currentFilter,
        normalizedQuery,
        currentState.selectedPlantId,
        currentState.selectedTaskTypes,
        currentState.selectedPriorities,
      );

      state = AsyncData(
        currentState.copyWith(
          searchQuery: normalizedQuery,
          filteredTasks: filteredTasks,
        ),
      );
    }
  }

  /// Sets the active filter for task display with optional plant filtering
  void setFilter(TasksFilterType filter, {String? plantId}) {
    final currentState = state.valueOrNull ?? TasksState.initial();

    if (currentState.currentFilter != filter ||
        currentState.selectedPlantId != plantId) {
      final filteredTasks = _applyFiltersToTasks(
        currentState.allTasks,
        filter,
        currentState.searchQuery,
        plantId,
        currentState.selectedTaskTypes,
        currentState.selectedPriorities,
      );

      state = AsyncData(
        currentState.copyWith(
          currentFilter: filter,
          selectedPlantId: plantId,
          filteredTasks: filteredTasks,
        ),
      );
    }
  }

  /// Applies advanced filtering with multiple criteria
  void setAdvancedFilters({
    List<task_entity.TaskType>? taskTypes,
    List<task_entity.TaskPriority>? priorities,
    TasksFilterType? filter,
    String? plantId,
  }) {
    final currentState = state.valueOrNull ?? TasksState.initial();

    final filteredTasks = _applyFiltersToTasks(
      currentState.allTasks,
      filter ?? currentState.currentFilter,
      currentState.searchQuery,
      plantId ?? currentState.selectedPlantId,
      taskTypes ?? currentState.selectedTaskTypes,
      priorities ?? currentState.selectedPriorities,
    );

    state = AsyncData(
      currentState.copyWith(
        currentFilter: filter ?? currentState.currentFilter,
        selectedPlantId: plantId ?? currentState.selectedPlantId,
        selectedTaskTypes: taskTypes ?? currentState.selectedTaskTypes,
        selectedPriorities: priorities ?? currentState.selectedPriorities,
        filteredTasks: filteredTasks,
      ),
    );
  }

  /// Refreshes tasks from the remote data source with visual feedback
  Future<void> refresh() async {
    final currentState = state.valueOrNull ?? TasksState.initial();
    state = AsyncData(
      currentState.copyWith(
        activeOperations: {
          ...currentState.activeOperations,
          TaskLoadingOperation.refreshing,
        },
        currentOperationMessage: AppStrings.refreshing,
      ),
    );

    try {
      await loadTasks();
    } finally {
      final newState = state.valueOrNull ?? TasksState.initial();
      state = AsyncData(
        newState.copyWith(
          activeOperations:
              newState.activeOperations
                  .where((op) => op != TaskLoadingOperation.refreshing)
                  .toSet(),
          clearOperationMessage: true,
        ),
      );
    }
  }

  /// Applies comprehensive filtering logic to a list of tasks
  List<task_entity.Task> _applyFiltersToTasks(
    List<task_entity.Task> allTasks,
    TasksFilterType currentFilter,
    String searchQuery,
    String? selectedPlantId,
    List<task_entity.TaskType> selectedTaskTypes,
    List<task_entity.TaskPriority> selectedPriorities,
  ) {
    List<task_entity.Task> tasks = List.from(allTasks);
    switch (currentFilter) {
      case TasksFilterType.all:
        break;
      case TasksFilterType.today:
        tasks =
            tasks
                .where(
                  (t) =>
                      t.isDueToday &&
                      t.status == task_entity.TaskStatus.pending,
                )
                .toList();
        break;
      case TasksFilterType.overdue:
        tasks = tasks.where((t) => t.isOverdue).toList();
        break;
      case TasksFilterType.upcoming:
        final now = DateTime.now();
        final nextWeek = now.add(TasksConstants.upcomingTasksDuration);
        tasks =
            tasks
                .where(
                  (t) =>
                      t.status == task_entity.TaskStatus.pending &&
                      t.dueDate.isAfter(now) &&
                      t.dueDate.isBefore(nextWeek),
                )
                .toList();
        break;
      case TasksFilterType.allFuture:
        final now = DateTime.now();
        tasks =
            tasks
                .where(
                  (t) =>
                      t.status == task_entity.TaskStatus.pending &&
                      t.dueDate.isAfter(now),
                )
                .toList();
        break;
      case TasksFilterType.completed:
        tasks =
            tasks
                .where((t) => t.status == task_entity.TaskStatus.completed)
                .toList();
        break;
      case TasksFilterType.byPlant:
        if (selectedPlantId != null) {
          tasks = tasks.where((t) => t.plantId == selectedPlantId).toList();
        }
        break;
    }
    if (selectedTaskTypes.isNotEmpty) {
      tasks =
          tasks.where((task) => selectedTaskTypes.contains(task.type)).toList();
    }
    if (selectedPriorities.isNotEmpty) {
      tasks =
          tasks
              .where((task) => selectedPriorities.contains(task.priority))
              .toList();
    }
    if (searchQuery.isNotEmpty) {
      tasks =
          tasks.where((task) {
            return task.title.toLowerCase().contains(searchQuery) ||
                (task.description?.toLowerCase().contains(searchQuery) ??
                    false);
          }).toList();
    }
    tasks.sort((a, b) {
      if (a.status != b.status) {
        if (a.status == task_entity.TaskStatus.pending) return -1;
        if (b.status == task_entity.TaskStatus.pending) return 1;
      }
      final aPriorityIndex = task_entity.TaskPriority.values.indexOf(
        a.priority,
      );
      final bPriorityIndex = task_entity.TaskPriority.values.indexOf(
        b.priority,
      );
      if (aPriorityIndex != bPriorityIndex) {
        return bPriorityIndex.compareTo(
          aPriorityIndex,
        ); // Higher priority first
      }
      return a.dueDate.compareTo(b.dueDate);
    });

    return tasks;
  }

  /// Clears the current error state
  void clearError() {
    final currentState = state.valueOrNull ?? TasksState.initial();
    state = AsyncData(currentState.copyWith(clearError: true));
  }

  /// Sets filtering to show tasks for a specific plant
  void setPlantFilter(String? plantId) {
    setFilter(TasksFilterType.byPlant, plantId: plantId);
  }

  /// Maps domain failures to user-friendly error messages
  String _mapFailureToMessage(Failure failure) {
    return failure.userMessage;
  }

  /// Determines if a failure is network-related for offline queue handling
  bool _isNetworkFailure(Failure failure) {
    return failure is NetworkFailure ||
        failure.message.toLowerCase().contains('network') ||
        failure.message.toLowerCase().contains('connection') ||
        failure.message.toLowerCase().contains('timeout');
  }

  /// Initializes the notification service with comprehensive setup
  Future<void> _initializeNotificationService() async {
    try {
      final initResult = await _notificationService.initialize();
      if (initResult) {
        await _notificationService.initializeNotificationHandlers();
        debugPrint(
          '✅ TasksProvider: Notification service initialized successfully',
        );
      } else {
        debugPrint(
          '⚠️ TasksProvider: Failed to initialize notification service',
        );
      }
    } catch (e) {
      debugPrint(
        '❌ TasksProvider: Error initializing notification service: $e',
      );
    }
  }

  /// Retrieves the current notification permission status
  Future<NotificationPermissionStatus> getNotificationPermissionStatus() async {
    final serviceStatus = await _notificationService.getPermissionStatus();
    switch (serviceStatus) {
      case notification_service.NotificationPermissionStatus.granted:
        return NotificationPermissionStatus.granted;
      case notification_service.NotificationPermissionStatus.denied:
        return NotificationPermissionStatus.denied;
      default:
        return NotificationPermissionStatus.notDetermined;
    }
  }

  /// Requests notification permissions from the user
  Future<bool> requestNotificationPermissions() async {
    try {
      return true; // Placeholder
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

  /// Undo task completion - marks a completed task as incomplete
  Future<bool> undoTaskCompletion(String taskId) async {
    try {
      return await _syncCoordinator.executeSyncOperation<bool>(
        operationType: 'undoTaskCompletion',
        priority: SyncPriority.critical.index,
        operation: () => _undoTaskCompletionOperation(taskId),
      );
    } catch (e) {
      final currentState = state.valueOrNull ?? TasksState.initial();
      state = AsyncData(
        currentState.copyWith(
          errorMessage: 'Failed to undo task completion',
          clearError: false,
        ),
      );
      return false;
    }
  }

  Future<bool> _undoTaskCompletionOperation(String taskId) async {
    final currentState = state.valueOrNull ?? TasksState.initial();
    final updatedTasks =
        currentState.allTasks.map((task) {
          if (task.id == taskId) {
            return task.copyWithTaskData(
              status: task_entity.TaskStatus.pending,
              completedAt: null,
            );
          }
          return task;
        }).toList();
    final filteredTasks = _applyFiltersToTasks(
      updatedTasks,
      currentState.currentFilter,
      currentState.searchQuery,
      currentState.selectedPlantId,
      currentState.selectedTaskTypes,
      currentState.selectedPriorities,
    );

    state = AsyncData(
      currentState.copyWith(
        allTasks: updatedTasks,
        filteredTasks: filteredTasks,
        clearError: true,
      ),
    );

    return true;
  }

  /// Filter tasks by type
  void filterTasks(TasksFilterType filter) {
    final currentState = state.valueOrNull ?? TasksState.initial();

    final filteredTasks = _applyFiltersToTasks(
      currentState.allTasks,
      filter,
      currentState.searchQuery,
      currentState.selectedPlantId,
      currentState.selectedTaskTypes,
      currentState.selectedPriorities,
    );

    state = AsyncData(
      currentState.copyWith(
        currentFilter: filter,
        filteredTasks: filteredTasks,
        clearError: true,
      ),
    );
  }
}

/// Main Tasks provider using Riverpod
final tasksProvider = AsyncNotifierProvider<TasksNotifier, TasksState>(() {
  return TasksNotifier();
});
final allTasksProvider = Provider<List<task_entity.Task>>((ref) {
  final tasksState = ref.watch(tasksProvider);
  return tasksState.maybeWhen(
    data: (TasksState state) => state.allTasks,
    orElse: () => <task_entity.Task>[],
  );
});

final filteredTasksProvider = Provider<List<task_entity.Task>>((ref) {
  final tasksState = ref.watch(tasksProvider);
  return tasksState.maybeWhen(
    data: (TasksState state) => state.filteredTasks,
    orElse: () => <task_entity.Task>[],
  );
});

final tasksIsLoadingProvider = Provider<bool>((ref) {
  final tasksState = ref.watch(tasksProvider);
  return tasksState.maybeWhen(
    data: (TasksState state) => state.isLoading,
    loading: () => true,
    orElse: () => false,
  );
});

final tasksErrorProvider = Provider<String?>((ref) {
  final tasksState = ref.watch(tasksProvider);
  return tasksState.maybeWhen(
    data: (TasksState state) => state.errorMessage,
    error: (Object error, _) => error.toString(),
    orElse: () => null,
  );
});
final highPriorityTasksProvider = Provider<List<task_entity.Task>>((ref) {
  final tasksState = ref.watch(tasksProvider);
  return tasksState.maybeWhen(
    data:
        (TasksState state) =>
            state.filteredTasks
                .where(
                  (task_entity.Task t) =>
                      t.priority == task_entity.TaskPriority.high ||
                      t.priority == task_entity.TaskPriority.urgent,
                )
                .toList(),
    orElse: () => <task_entity.Task>[],
  );
});

final mediumPriorityTasksProvider = Provider<List<task_entity.Task>>((ref) {
  final tasksState = ref.watch(tasksProvider);
  return tasksState.maybeWhen(
    data:
        (TasksState state) =>
            state.filteredTasks
                .where(
                  (task_entity.Task t) =>
                      t.priority == task_entity.TaskPriority.medium,
                )
                .toList(),
    orElse: () => <task_entity.Task>[],
  );
});

final lowPriorityTasksProvider = Provider<List<task_entity.Task>>((ref) {
  final tasksState = ref.watch(tasksProvider);
  return tasksState.maybeWhen(
    data:
        (TasksState state) =>
            state.filteredTasks
                .where(
                  (task_entity.Task t) =>
                      t.priority == task_entity.TaskPriority.low,
                )
                .toList(),
    orElse: () => <task_entity.Task>[],
  );
});
final totalTasksProvider = Provider<int>((ref) {
  final tasksState = ref.watch(tasksProvider);
  return tasksState.maybeWhen(
    data: (TasksState state) => state.totalTasks,
    orElse: () => 0,
  );
});

final completedTasksProvider = Provider<int>((ref) {
  final tasksState = ref.watch(tasksProvider);
  return tasksState.maybeWhen(
    data: (TasksState state) => state.completedTasks,
    orElse: () => 0,
  );
});

final pendingTasksProvider = Provider<int>((ref) {
  final tasksState = ref.watch(tasksProvider);
  return tasksState.maybeWhen(
    data: (TasksState state) => state.pendingTasks,
    orElse: () => 0,
  );
});

final overdueTasksProvider = Provider<int>((ref) {
  final tasksState = ref.watch(tasksProvider);
  return tasksState.maybeWhen(
    data: (TasksState state) => state.overdueTasks,
    orElse: () => 0,
  );
});
final hasPendingOfflineOperationsProvider = Provider<bool>((ref) {
  return offline_queue.OfflineSyncQueueService.instance.hasPendingOperations;
});

final pendingOfflineOperationsCountProvider = Provider<int>((ref) {
  return offline_queue.OfflineSyncQueueService.instance.pendingOperationsCount;
});
final getTasksUseCaseProvider = Provider<GetTasksUseCase>((ref) {
  return GetIt.instance<GetTasksUseCase>();
});

final addTaskUseCaseProvider = Provider<AddTaskUseCase>((ref) {
  return GetIt.instance<AddTaskUseCase>();
});

final completeTaskUseCaseProvider = Provider<CompleteTaskUseCase>((ref) {
  return GetIt.instance<CompleteTaskUseCase>();
});

final taskNotificationServiceProvider = Provider<TaskNotificationService>((
  ref,
) {
  return GetIt.instance<TaskNotificationService>();
});

/// Exception thrown when a user tries to access a task they don't own
class UnauthorizedAccessException implements Exception {
  final String message;

  const UnauthorizedAccessException(this.message);

  @override
  String toString() => 'UnauthorizedAccessException: $message';
}

enum TaskSyncOperations { loadTasks, addTask, completeTask }

enum OfflineTaskOperations { addTask, completeTask }

enum SyncPriority { low, medium, high, critical }

class SyncThrottledException implements Exception {
  final String message;
  SyncThrottledException(this.message);
}

enum NotificationPermissionStatus { granted, denied, notDetermined }
