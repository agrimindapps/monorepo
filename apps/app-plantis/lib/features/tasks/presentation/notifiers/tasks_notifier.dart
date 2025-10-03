import 'dart:async';

import 'package:core/core.dart' hide getIt;
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/auth_state_notifier.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/services/offline_sync_queue_service.dart';
import '../../../../core/services/sync_coordinator_service.dart'
    hide SyncPriority;
import '../../../../core/services/task_notification_service.dart';
import '../../core/constants/tasks_constants.dart';
import '../../domain/entities/task.dart' as task_entity;
import '../../domain/repositories/tasks_repository.dart';
import '../../domain/usecases/add_task_usecase.dart';
import '../../domain/usecases/complete_task_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../providers/tasks_state.dart';

part 'tasks_notifier.g.dart';

/// TasksNotifier with Riverpod AsyncNotifier and offline support
///
/// This notifier manages the complete tasks lifecycle with the following features:
/// - Immutable state management with AsyncValue for better performance
/// - Offline-first architecture with sync coordination
/// - Granular loading states for individual operations
/// - Real-time sync with conflict resolution
/// - Comprehensive error handling and user feedback
/// - Task filtering and search capabilities
/// - Notification scheduling integration
/// - Decoupled authentication state via AuthStateNotifier singleton
///
/// The notifier follows Clean Architecture patterns and integrates with:
/// - Use cases for business logic execution
/// - Sync coordinator for network operations
/// - Offline queue for connection resilience
/// - Notification service for user reminders
/// - AuthStateNotifier for authentication state (breaks circular dependencies)
@riverpod
class TasksNotifier extends _$TasksNotifier {
  late final GetTasksUseCase _getTasksUseCase;
  late final AddTaskUseCase _addTaskUseCase;
  late final CompleteTaskUseCase _completeTaskUseCase;
  late final TaskNotificationService _notificationService;
  late final AuthStateNotifier _authStateNotifier;
  late final SyncCoordinatorService _syncCoordinator;
  late final OfflineSyncQueueService _offlineQueue;

  // Stream subscription for auth state changes
  StreamSubscription<UserEntity?>? _authSubscription;

  @override
  Future<TasksState> build() async {
    // Initialize dependencies
    _getTasksUseCase = ref.read(getTasksUseCaseProvider);
    _addTaskUseCase = ref.read(addTaskUseCaseProvider);
    _completeTaskUseCase = ref.read(completeTaskUseCaseProvider);
    _notificationService = TaskNotificationService();
    _authStateNotifier = AuthStateNotifier.instance;
    _syncCoordinator = SyncCoordinatorService.instance;
    _offlineQueue = OfflineSyncQueueService.instance;

    // Initialize notification service when notifier is created
    await _initializeNotificationService();

    // Initialize auth state listener
    _initializeAuthListener();

    // Setup cleanup on dispose
    ref.onDispose(() {
      _authSubscription?.cancel();
      _syncCoordinator.cancelOperations(TaskSyncOperations.loadTasks);
      _syncCoordinator.cancelOperations(TaskSyncOperations.addTask);
      _syncCoordinator.cancelOperations(TaskSyncOperations.completeTask);
    });

    // Load initial tasks
    return await _loadTasksInternal();
  }

  /// Internal method to load tasks without triggering external operations
  Future<TasksState> _loadTasksInternal() async {
    try {
      debugPrint('🔄 TasksNotifier: Loading initial tasks...');

      final result = await _getTasksUseCase(const NoParams());

      return result.fold(
        (failure) {
          debugPrint('❌ TasksNotifier: Failed to load initial tasks: ${failure.message}');
          return TasksState.error(failure.userMessage);
        },
        (tasks) {
          debugPrint('✅ TasksNotifier: Loaded ${tasks.length} tasks');

          // Check overdue tasks and send notifications
          _notificationService.checkOverdueTasks(tasks);
          // Reschedule all notifications
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
  ///
  /// This method sets up a subscription to the AuthStateNotifier to listen
  /// for authentication state changes. When the user logs in/out, it
  /// automatically reloads tasks to ensure data consistency.
  void _initializeAuthListener() {
    _authSubscription = _authStateNotifier.userStream.listen((user) {
      debugPrint(
        '🔐 TasksNotifier: Auth state changed - user: ${user?.id}, initialized: ${_authStateNotifier.isInitialized}',
      );

      // Only load tasks if auth is fully initialized AND stable
      if (_authStateNotifier.isInitialized && user != null) {
        debugPrint('✅ TasksNotifier: Auth is stable, loading tasks...');
        loadTasks();
      } else if (_authStateNotifier.isInitialized && user == null) {
        debugPrint(
          '🔄 TasksNotifier: No user but auth initialized - clearing tasks',
        );
        // Clear tasks when user logs out
        state = AsyncValue.data(
          TasksState.initial().copyWith(
            allTasks: <task_entity.Task>[],
            filteredTasks: <task_entity.Task>[],
            clearError: true,
          ),
        );
      }
    });
  }

  /// Validates task ownership against the currently authenticated user
  ///
  /// This security method ensures that users can only access and modify tasks
  /// that belong to them. It prevents unauthorized access to other users' data
  /// in multi-user environments.
  ///
  /// Returns:
  /// - `true` if the current user owns the task (exact userId match)
  /// - `false` if no user is authenticated, task has null userId, or belongs to different user
  ///
  /// SECURITY: Tasks with null userId are DENIED access to prevent data exposure
  bool _validateTaskOwnership(task_entity.Task task) {
    final currentUser = _authStateNotifier.currentUser;

    // If no user is authenticated, deny access
    if (currentUser == null) {
      debugPrint('🚫 Access denied: No authenticated user');
      return false;
    }

    // SECURITY FIX: Deny access for tasks with null userId
    if (task.userId == null) {
      debugPrint(
        '🚫 Access denied: Task has null userId (potential security risk)',
      );
      return false;
    }

    // SECURITY: Only allow access if task explicitly belongs to current user
    if (task.userId == currentUser.id) {
      return true;
    }

    // If task belongs to different user, deny access
    debugPrint(
      '🚫 Access denied: Task belongs to user ${task.userId}, current user is ${currentUser.id}',
    );
    return false;
  }

  /// Retrieves a task by ID and validates user ownership
  ///
  /// Throws:
  /// - [Exception] if task is not found
  /// - [UnauthorizedAccessException] if user doesn't own the task
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

  /// Updates the state with granular operation tracking
  void _updateState(TasksState Function(TasksState current) update) {
    final currentState = state.valueOrNull ?? TasksState.initial();
    state = AsyncValue.data(update(currentState));
  }

  /// Starts a loading operation for a specific task
  void _startTaskOperation(String taskId, {String? message}) {
    _updateState((current) {
      final updatedOperations = Map<String, bool>.from(
        current.individualTaskOperations,
      );
      updatedOperations[taskId] = true;

      return current.copyWith(
        individualTaskOperations: updatedOperations,
        currentOperationMessage: message,
      );
    });
  }

  /// Completes a task-specific loading operation
  void _completeTaskLoadingOperation(String taskId) {
    _updateState((current) {
      final updatedOperations = Map<String, bool>.from(
        current.individualTaskOperations,
      );
      updatedOperations.remove(taskId);

      return current.copyWith(
        individualTaskOperations: updatedOperations,
        clearOperationMessage: true,
      );
    });
  }

  /// Starts a global loading operation
  void _startGlobalOperation(
    TaskLoadingOperation operation, {
    String? message,
  }) {
    _updateState((current) {
      final updatedOperations = Set<TaskLoadingOperation>.from(
        current.activeOperations,
      );
      updatedOperations.add(operation);

      return current.copyWith(
        activeOperations: updatedOperations,
        currentOperationMessage: message,
      );
    });
  }

  /// Completes a global loading operation
  void _completeGlobalOperation(TaskLoadingOperation operation) {
    _updateState((current) {
      final updatedOperations = Set<TaskLoadingOperation>.from(
        current.activeOperations,
      );
      updatedOperations.remove(operation);

      return current.copyWith(
        activeOperations: updatedOperations,
        clearOperationMessage: updatedOperations.isEmpty,
      );
    });
  }

  /// Loads tasks from the remote data source with sync coordination
  ///
  /// This method orchestrates the complete task loading process including:
  /// - Sync throttling to prevent excessive API calls
  /// - Error handling with user-friendly messages
  /// - Loading state management
  /// - Notification scheduling for loaded tasks
  /// - Automatic overdue task detection
  Future<void> loadTasks() async {
    debugPrint('🔄 TasksNotifier: Starting load tasks...');

    try {
      await _syncCoordinator.executeSyncOperation(
        operationType: TaskSyncOperations.loadTasks,
        priority: SyncPriority.high.index,
        minimumInterval: TasksConstants.syncMinimumInterval,
        operation: () => _loadTasksOperation(),
      );
    } on SyncThrottledException catch (e) {
      debugPrint('⚠️ Load tasks throttled: ${e.message}');
      // Don't show error to user for throttling
    } catch (e) {
      debugPrint('❌ TasksNotifier: Load tasks failed: $e');
      _updateState(
        (current) => current.copyWith(
          isLoading: false,
          errorMessage: 'Erro ao sincronizar tarefas: $e',
        ),
      );
    }
  }

  Future<void> _loadTasksOperation() async {
    final currentState = state.valueOrNull ?? TasksState.initial();

    // Only show loading if we don't have tasks yet
    final shouldShowLoading = currentState.allTasks.isEmpty;

    if (shouldShowLoading) {
      _startGlobalOperation(
        TaskLoadingOperation.loadingTasks,
        message: AppStrings.loadingTasks,
      );
      _updateState((current) => current.copyWith(isLoading: true, clearError: true));
    } else {
      _startGlobalOperation(
        TaskLoadingOperation.syncing,
        message: AppStrings.synchronizing,
      );
      _updateState((current) => current.copyWith(clearError: true));
    }

    try {
      debugPrint('🔄 TasksNotifier: Calling _getTasksUseCase...');
      final result = await _getTasksUseCase(const NoParams());
      debugPrint('✅ TasksNotifier: _getTasksUseCase completed successfully');

      result.fold(
        (failure) {
          _completeGlobalOperation(TaskLoadingOperation.loadingTasks);
          _completeGlobalOperation(TaskLoadingOperation.syncing);
          _updateState(
            (current) => current.copyWith(
              isLoading: false,
              errorMessage: failure.userMessage,
            ),
          );
          throw Exception(failure.userMessage);
        },
        (tasks) {
          final filteredTasks = _applyFiltersToTasks(
            tasks,
            currentState.currentFilter,
            currentState.searchQuery,
            currentState.selectedPlantId,
            currentState.selectedTaskTypes,
            currentState.selectedPriorities,
          );

          _completeGlobalOperation(TaskLoadingOperation.loadingTasks);
          _completeGlobalOperation(TaskLoadingOperation.syncing);
          _updateState(
            (current) => current.copyWith(
              allTasks: tasks,
              filteredTasks: filteredTasks,
              isLoading: false,
              clearError: true,
            ),
          );

          // Check overdue tasks and send notifications
          _notificationService.checkOverdueTasks(tasks);
          // Reschedule all notifications
          _notificationService.rescheduleTaskNotifications(tasks);
        },
      );
    } catch (e) {
      debugPrint('❌ TasksNotifier: Load tasks operation failed: $e');
      _completeGlobalOperation(TaskLoadingOperation.loadingTasks);
      _completeGlobalOperation(TaskLoadingOperation.syncing);
      _updateState(
        (current) => current.copyWith(
          isLoading: false,
          errorMessage: 'Erro ao carregar tarefas: $e',
        ),
      );
      rethrow;
    }
  }

  /// Adds a new task with offline support and user validation
  ///
  /// Returns:
  /// - `true` if the task was successfully added (including optimistic updates)
  /// - `false` if there was an error that prevented task creation
  Future<bool> addTask(task_entity.Task task) async {
    try {
      return await _syncCoordinator.executeSyncOperation<bool>(
        operationType: TaskSyncOperations.addTask,
        priority: SyncPriority.critical.index,
        operation: () => _addTaskOperation(task),
      );
    } catch (e) {
      _updateState(
        (current) => current.copyWith(errorMessage: AppStrings.errorSyncingNewTask),
      );
      return false;
    }
  }

  Future<bool> _addTaskOperation(task_entity.Task task) async {
    _startGlobalOperation(
      TaskLoadingOperation.addingTask,
      message: AppStrings.addingTask,
    );
    _updateState((current) => current.copyWith(clearError: true));

    try {
      // Ensure task is associated with current user
      final currentUser = _authStateNotifier.currentUser;
      if (currentUser == null) {
        _completeGlobalOperation(TaskLoadingOperation.addingTask);
        _updateState(
          (current) => current.copyWith(
            errorMessage: AppStrings.mustBeAuthenticatedToCreateTasks,
          ),
        );
        return false;
      }

      // Assign current user to the task
      final taskWithUser = task.withUserId(currentUser.id);

      final result = await _addTaskUseCase(AddTaskParams(task: taskWithUser));

      return result.fold(
        (failure) {
          // If it's a network failure, queue for offline sync
          if (_isNetworkFailure(failure)) {
            debugPrint(
              '🌐 Network failure detected, queuing task for offline sync',
            );

            // Create optimistic local task
            final optimisticTask = taskWithUser.copyWith(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              isDirty: true,
            );

            // Add to local state immediately
            final currentState = state.valueOrNull ?? TasksState.initial();
            final updatedTasks = List<task_entity.Task>.from(currentState.allTasks)
              ..add(optimisticTask);
            final filteredTasks = _applyFiltersToTasks(
              updatedTasks,
              currentState.currentFilter,
              currentState.searchQuery,
              currentState.selectedPlantId,
              currentState.selectedTaskTypes,
              currentState.selectedPriorities,
            );

            _updateState(
              (current) => current.copyWith(
                allTasks: updatedTasks,
                filteredTasks: filteredTasks,
                clearError: true,
              ),
            );

            // Queue for offline sync
            final queuedOperation = QueuedOperation(
              id: optimisticTask.id,
              type: OfflineTaskOperations.addTask,
              data: optimisticTask.toFirebaseMap(),
              createdAt: DateTime.now(),
            );

            _offlineQueue.queueOperation(queuedOperation);

            _completeGlobalOperation(TaskLoadingOperation.addingTask);
            return true; // Return success for optimistic update
          } else {
            _completeGlobalOperation(TaskLoadingOperation.addingTask);
            _updateState(
              (current) => current.copyWith(errorMessage: failure.userMessage),
            );
            throw Exception(failure.userMessage);
          }
        },
        (addedTask) {
          final currentState = state.valueOrNull ?? TasksState.initial();
          final updatedTasks = List<task_entity.Task>.from(currentState.allTasks)
            ..add(addedTask);
          final filteredTasks = _applyFiltersToTasks(
            updatedTasks,
            currentState.currentFilter,
            currentState.searchQuery,
            currentState.selectedPlantId,
            currentState.selectedTaskTypes,
            currentState.selectedPriorities,
          );

          _completeGlobalOperation(TaskLoadingOperation.addingTask);
          _updateState(
            (current) => current.copyWith(
              allTasks: updatedTasks,
              filteredTasks: filteredTasks,
              clearError: true,
            ),
          );

          // Schedule notification for the new task
          _notificationService.scheduleTaskNotification(addedTask);
          return true;
        },
      );
    } catch (e) {
      _completeGlobalOperation(TaskLoadingOperation.addingTask);
      _updateState(
        (current) => current.copyWith(errorMessage: AppStrings.unexpectedErrorAddingTask),
      );
      rethrow;
    }
  }

  /// Completes a task with offline support and ownership validation
  ///
  /// Returns:
  /// - `true` if the task was successfully completed (including optimistic updates)
  /// - `false` if there was an error that prevented completion
  ///
  /// Throws:
  /// - [UnauthorizedAccessException] if user doesn't own the task
  Future<bool> completeTask(String taskId, {String? notes}) async {
    try {
      return await _syncCoordinator.executeSyncOperation<bool>(
        operationType: TaskSyncOperations.completeTask,
        priority: SyncPriority.critical.index,
        operation: () => _completeTaskOperation(taskId, notes),
      );
    } catch (e) {
      _updateState(
        (current) => current.copyWith(errorMessage: AppStrings.errorSyncingTaskCompletion),
      );
      return false;
    }
  }

  Future<bool> _completeTaskOperation(String taskId, String? notes) async {
    _startTaskOperation(taskId, message: AppStrings.completingTask);
    _updateState((current) => current.copyWith(clearError: true));

    try {
      // Validate ownership before completing task
      final task = _getTaskWithOwnershipValidation(taskId);

      final result = await _completeTaskUseCase(
        CompleteTaskParams(taskId: taskId, notes: notes),
      );

      return result.fold(
        (failure) {
          // If it's a network failure, queue for offline sync
          if (_isNetworkFailure(failure)) {
            debugPrint(
              '🌐 Network failure detected, queuing task completion for offline sync',
            );

            // Create optimistic local completion
            final completedTask = task.copyWithTaskData(
              status: task_entity.TaskStatus.completed,
              completedAt: DateTime.now(),
              completionNotes: notes,
            );

            // Update local state immediately
            final currentState = state.valueOrNull ?? TasksState.initial();
            final updatedTasks = currentState.allTasks.map((t) {
              return t.id == taskId ? completedTask : t;
            }).toList();

            final filteredTasks = _applyFiltersToTasks(
              updatedTasks,
              currentState.currentFilter,
              currentState.searchQuery,
              currentState.selectedPlantId,
              currentState.selectedTaskTypes,
              currentState.selectedPriorities,
            );

            _updateState(
              (current) => current.copyWith(
                allTasks: updatedTasks,
                filteredTasks: filteredTasks,
                clearError: true,
              ),
            );

            // Queue for offline sync
            final queuedOperation = QueuedOperation(
              id: taskId,
              type: OfflineTaskOperations.completeTask,
              data: {
                'taskId': taskId,
                'notes': notes,
                'completedAt': DateTime.now().toIso8601String(),
              },
              createdAt: DateTime.now(),
            );

            _offlineQueue.queueOperation(queuedOperation);

            // Cancel notifications optimistically
            _notificationService.cancelTaskNotifications(taskId);
            _notificationService.rescheduleTaskNotifications(updatedTasks);

            _completeTaskLoadingOperation(taskId);
            return true; // Return success for optimistic update
          } else {
            _completeTaskLoadingOperation(taskId);
            _updateState(
              (current) => current.copyWith(errorMessage: failure.userMessage),
            );
            throw Exception(failure.userMessage);
          }
        },
        (completedTask) {
          final currentState = state.valueOrNull ?? TasksState.initial();
          final updatedTasks = currentState.allTasks.map((t) {
            return t.id == taskId ? completedTask : t;
          }).toList();

          final filteredTasks = _applyFiltersToTasks(
            updatedTasks,
            currentState.currentFilter,
            currentState.searchQuery,
            currentState.selectedPlantId,
            currentState.selectedTaskTypes,
            currentState.selectedPriorities,
          );

          _completeTaskLoadingOperation(taskId);
          _updateState(
            (current) => current.copyWith(
              allTasks: updatedTasks,
              filteredTasks: filteredTasks,
              clearError: true,
            ),
          );

          // Cancel notifications for the completed task
          _notificationService.cancelTaskNotifications(taskId);
          // Reschedule notifications for remaining tasks
          _notificationService.rescheduleTaskNotifications(updatedTasks);

          return true;
        },
      );
    } on UnauthorizedAccessException catch (e) {
      _completeTaskLoadingOperation(taskId);
      _updateState((current) => current.copyWith(errorMessage: e.message));
      rethrow;
    } catch (e) {
      _completeTaskLoadingOperation(taskId);
      _updateState(
        (current) => current.copyWith(errorMessage: AppStrings.unexpectedErrorCompletingTask),
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

      _updateState(
        (current) => current.copyWith(
          searchQuery: normalizedQuery,
          filteredTasks: filteredTasks,
        ),
      );
    }
  }

  /// Sets the active filter for task display with optional plant filtering
  void setFilter(TasksFilterType filter, {String? plantId}) {
    final currentState = state.valueOrNull ?? TasksState.initial();

    if (currentState.currentFilter != filter || currentState.selectedPlantId != plantId) {
      final filteredTasks = _applyFiltersToTasks(
        currentState.allTasks,
        filter,
        currentState.searchQuery,
        plantId,
        currentState.selectedTaskTypes,
        currentState.selectedPriorities,
      );

      _updateState(
        (current) => current.copyWith(
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

    _updateState(
      (current) => current.copyWith(
        currentFilter: filter ?? current.currentFilter,
        selectedPlantId: plantId ?? current.selectedPlantId,
        selectedTaskTypes: taskTypes ?? current.selectedTaskTypes,
        selectedPriorities: priorities ?? current.selectedPriorities,
        filteredTasks: filteredTasks,
      ),
    );
  }

  /// Refreshes tasks from the remote data source with visual feedback
  Future<void> refresh() async {
    _startGlobalOperation(
      TaskLoadingOperation.refreshing,
      message: AppStrings.refreshing,
    );
    try {
      await loadTasks();
    } finally {
      _completeGlobalOperation(TaskLoadingOperation.refreshing);
    }
  }

  /// Clears the current error state
  void clearError() {
    _updateState((current) => current.copyWith(clearError: true));
  }

  /// Sets filtering to show tasks for a specific plant
  void setPlantFilter(String? plantId) {
    setFilter(TasksFilterType.byPlant, plantId: plantId);
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

    // Apply filter by type
    switch (currentFilter) {
      case TasksFilterType.all:
        break;
      case TasksFilterType.today:
        tasks = tasks
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
        tasks = tasks
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
        tasks = tasks
            .where(
              (t) =>
                  t.status == task_entity.TaskStatus.pending &&
                  t.dueDate.isAfter(now),
            )
            .toList();
        break;
      case TasksFilterType.completed:
        tasks = tasks
            .where((t) => t.status == task_entity.TaskStatus.completed)
            .toList();
        break;
      case TasksFilterType.byPlant:
        if (selectedPlantId != null) {
          tasks = tasks.where((t) => t.plantId == selectedPlantId).toList();
        }
        break;
    }

    // Apply filter by task type
    if (selectedTaskTypes.isNotEmpty) {
      tasks = tasks.where((task) => selectedTaskTypes.contains(task.type)).toList();
    }

    // Apply filter by priority
    if (selectedPriorities.isNotEmpty) {
      tasks = tasks
          .where((task) => selectedPriorities.contains(task.priority))
          .toList();
    }

    // Apply search
    if (searchQuery.isNotEmpty) {
      tasks = tasks.where((task) {
        return task.title.toLowerCase().contains(searchQuery) ||
            (task.description?.toLowerCase().contains(searchQuery) ?? false);
      }).toList();
    }

    // Sort by priority and date
    tasks.sort((a, b) {
      // First by status (pending first)
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
      return true; // Placeholder - implement when TaskNotificationService interface is defined
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

  // Convenience getters for offline sync status
  bool get hasPendingOfflineOperations => _offlineQueue.hasPendingOperations;
  int get pendingOfflineOperationsCount => _offlineQueue.pendingOperationsCount;

  // Computed getters that delegate to state (for backward compatibility)
  List<task_entity.Task> get highPriorityTasks {
    final currentState = state.valueOrNull ?? TasksState.initial();
    return currentState.filteredTasks
        .where(
          (t) =>
              t.priority == task_entity.TaskPriority.high ||
              t.priority == task_entity.TaskPriority.urgent,
        )
        .toList();
  }

  List<task_entity.Task> get mediumPriorityTasks {
    final currentState = state.valueOrNull ?? TasksState.initial();
    return currentState.filteredTasks
        .where((t) => t.priority == task_entity.TaskPriority.medium)
        .toList();
  }

  List<task_entity.Task> get lowPriorityTasks {
    final currentState = state.valueOrNull ?? TasksState.initial();
    return currentState.filteredTasks
        .where((t) => t.priority == task_entity.TaskPriority.low)
        .toList();
  }
}

/// Exception thrown when a user tries to access a task they don't own
class UnauthorizedAccessException implements Exception {
  final String message;

  const UnauthorizedAccessException(this.message);

  @override
  String toString() => 'UnauthorizedAccessException: $message';
}

// ============================================================================
// DEPENDENCY PROVIDERS
// ============================================================================

/// Provider for GetTasksUseCase
@riverpod
GetTasksUseCase getTasksUseCase(Ref ref) {
  final repository = ref.watch(tasksRepositoryProvider);
  return GetTasksUseCase(repository);
}

/// Provider for AddTaskUseCase
@riverpod
AddTaskUseCase addTaskUseCase(Ref ref) {
  final repository = ref.watch(tasksRepositoryProvider);
  return AddTaskUseCase(repository);
}

/// Provider for CompleteTaskUseCase
@riverpod
CompleteTaskUseCase completeTaskUseCase(Ref ref) {
  final repository = ref.watch(tasksRepositoryProvider);
  return CompleteTaskUseCase(repository);
}

/// Provider for TasksRepository
@riverpod
TasksRepository tasksRepository(Ref ref) {
  // Use GetIt to retrieve the repository instance
  // This assumes TasksRepository is registered in the DI container
  return getIt<TasksRepository>();
}
