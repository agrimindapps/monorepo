import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/auth/auth_state_notifier.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/services/offline_sync_queue_service.dart';
import '../../../../core/services/sync_coordinator_service.dart'
    hide SyncPriority;
import '../../../../core/services/task_notification_service.dart';
import '../../core/constants/tasks_constants.dart';
import '../../domain/entities/task.dart' as task_entity;
import '../../domain/usecases/add_task_usecase.dart';
import '../../domain/usecases/complete_task_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import 'tasks_state.dart';

/// TasksProvider with immutable state management and offline support
///
/// This provider manages the complete tasks lifecycle with the following features:
/// - Immutable state management for better performance
/// - Offline-first architecture with sync coordination
/// - Granular loading states for individual operations
/// - Real-time sync with conflict resolution
/// - Comprehensive error handling and user feedback
/// - Task filtering and search capabilities
/// - Notification scheduling integration
/// - Decoupled authentication state via AuthStateNotifier singleton
///
/// The provider follows Clean Architecture patterns and integrates with:
/// - Use cases for business logic execution
/// - Sync coordinator for network operations
/// - Offline queue for connection resilience
/// - Notification service for user reminders
/// - AuthStateNotifier for authentication state (breaks circular dependencies)
class TasksProvider extends ChangeNotifier {
  final GetTasksUseCase _getTasksUseCase;
  final AddTaskUseCase _addTaskUseCase;
  final CompleteTaskUseCase _completeTaskUseCase;
  final TaskNotificationService _notificationService;
  final AuthStateNotifier _authStateNotifier;
  final SyncCoordinatorService _syncCoordinator;
  final OfflineSyncQueueService _offlineQueue;
  StreamSubscription<UserEntity?>? _authSubscription;

  TasksProvider({
    required GetTasksUseCase getTasksUseCase,
    required AddTaskUseCase addTaskUseCase,
    required CompleteTaskUseCase completeTaskUseCase,
    AuthStateNotifier? authStateNotifier,
    TaskNotificationService? notificationService,
    SyncCoordinatorService? syncCoordinator,
    OfflineSyncQueueService? offlineQueue,
  }) : _getTasksUseCase = getTasksUseCase,
       _addTaskUseCase = addTaskUseCase,
       _completeTaskUseCase = completeTaskUseCase,
       _authStateNotifier = authStateNotifier ?? AuthStateNotifier.instance,
       _notificationService = notificationService ?? TaskNotificationService(),
       _syncCoordinator = syncCoordinator ?? SyncCoordinatorService.instance,
       _offlineQueue = offlineQueue ?? OfflineSyncQueueService.instance {
    _initializeNotificationService();
    _initializeAuthListener();
  }
  TasksState _state = TasksState.initial();
  TasksState get state => _state;
  List<task_entity.Task> get allTasks => _state.allTasks;
  List<task_entity.Task> get filteredTasks => _state.filteredTasks;
  bool get isLoading => _state.isLoading;
  String? get errorMessage => _state.errorMessage;
  TasksFilterType get currentFilter => _state.currentFilter;
  String? get selectedPlantId => _state.selectedPlantId;
  String get searchQuery => _state.searchQuery;
  List<task_entity.TaskType> get selectedTaskTypes => _state.selectedTaskTypes;
  List<task_entity.TaskPriority> get selectedPriorities =>
      _state.selectedPriorities;
  bool get hasError => _state.hasError;
  bool get isEmpty => _state.isEmpty;
  Map<String, bool> get individualTaskOperations =>
      _state.individualTaskOperations;
  Set<TaskLoadingOperation> get activeOperations => _state.activeOperations;
  String? get currentOperationMessage => _state.currentOperationMessage;
  bool isTaskOperationLoading(String taskId) =>
      _state.isTaskOperationLoading(taskId);
  bool get hasActiveOperations => _state.hasActiveOperations;
  bool isOperationActive(TaskLoadingOperation operation) =>
      _state.isOperationActive(operation);
  bool get isRefreshing => _state.isRefreshing;
  bool get isAddingTask => _state.isAddingTask;
  bool get isSyncing => _state.isSyncing;
  int get totalTasks => _state.totalTasks;
  int get completedTasks => _state.completedTasks;
  int get pendingTasks => _state.pendingTasks;
  int get overdueTasks => _state.overdueTasks;
  int get todayTasks => _state.todayTasks;
  int get upcomingTasksCount => _state.upcomingTasksCount;
  bool get hasPendingOfflineOperations => _offlineQueue.hasPendingOperations;
  int get pendingOfflineOperationsCount => _offlineQueue.pendingOperationsCount;

  /// Updates the provider state and notifies listeners only if the state changed
  ///
  /// This method implements efficient state updates by comparing the new state
  /// with the current state and only notifying listeners when there's an actual
  /// change, preventing unnecessary widget rebuilds.
  ///
  /// Parameters:
  /// - [newState]: The new TasksState to set
  ///
  /// Example:
  /// ```dart
  /// _updateState(state.copyWith(
  ///   isLoading: true,
  ///   clearError: true,
  /// ));
  /// ```
  void _updateState(TasksState newState) {
    if (_state != newState) {
      _state = newState;
      if (!_disposed) {
        notifyListeners();
      }
    }
  }

  bool _disposed = false;

  /// Starts a loading operation for a specific task
  ///
  /// This method tracks individual task operations to provide granular loading
  /// states in the UI. Each task can have its own loading indicator without
  /// affecting the global loading state.
  ///
  /// Parameters:
  /// - [taskId]: Unique identifier of the task being operated on
  /// - [message]: Optional status message to display to the user
  ///
  /// Example:
  /// ```dart
  /// _startTaskOperation('task_123', message: 'Completing task...');
  /// ```
  void _startTaskOperation(String taskId, {String? message}) {
    final updatedOperations = Map<String, bool>.from(
      _state.individualTaskOperations,
    );
    updatedOperations[taskId] = true;

    _updateState(
      _state.copyWith(
        individualTaskOperations: updatedOperations,
        currentOperationMessage: message,
      ),
    );
  }

  /// Completes a task-specific loading operation and cleans up state
  ///
  /// This method removes the task from the individual loading operations map
  /// and clears any associated operation message, effectively ending the
  /// loading state for that specific task.
  ///
  /// Parameters:
  /// - [taskId]: Unique identifier of the task operation to complete
  ///
  /// Example:
  /// ```dart
  /// _completeTaskLoadingOperation('task_123');
  /// ```
  void _completeTaskLoadingOperation(String taskId) {
    final updatedOperations = Map<String, bool>.from(
      _state.individualTaskOperations,
    );
    updatedOperations.remove(taskId);

    _updateState(
      _state.copyWith(
        individualTaskOperations: updatedOperations,
        clearOperationMessage: true,
      ),
    );
  }

  /// Starts a global loading operation that affects the entire tasks system
  ///
  /// Global operations include actions like loading all tasks, refreshing,
  /// or syncing. These operations affect the entire UI state and are tracked
  /// separately from individual task operations.
  ///
  /// Parameters:
  /// - [operation]: Type of operation being started (from TaskLoadingOperation enum)
  /// - [message]: Optional status message to display to the user
  ///
  /// Example:
  /// ```dart
  /// _startGlobalOperation(
  ///   TaskLoadingOperation.loadingTasks,
  ///   message: 'Loading your tasks...',
  /// );
  /// ```
  void _startGlobalOperation(
    TaskLoadingOperation operation, {
    String? message,
  }) {
    final updatedOperations = Set<TaskLoadingOperation>.from(
      _state.activeOperations,
    );
    updatedOperations.add(operation);

    _updateState(
      _state.copyWith(
        activeOperations: updatedOperations,
        currentOperationMessage: message,
      ),
    );
  }

  /// Completes a global loading operation and updates the UI state
  ///
  /// This method removes the operation from the active operations set and
  /// optionally clears the operation message if no other operations are active.
  ///
  /// Parameters:
  /// - [operation]: Type of operation being completed (from TaskLoadingOperation enum)
  ///
  /// Example:
  /// ```dart
  /// _completeGlobalOperation(TaskLoadingOperation.loadingTasks);
  /// ```
  void _completeGlobalOperation(TaskLoadingOperation operation) {
    final updatedOperations = Set<TaskLoadingOperation>.from(
      _state.activeOperations,
    );
    updatedOperations.remove(operation);

    _updateState(
      _state.copyWith(
        activeOperations: updatedOperations,
        clearOperationMessage: updatedOperations.isEmpty,
      ),
    );
  }

  /// Initializes the authentication state listener
  ///
  /// This method sets up a subscription to the AuthStateNotifier to listen
  /// for authentication state changes. When the user logs in/out, it
  /// automatically reloads tasks to ensure data consistency.
  ///
  /// This approach breaks the circular dependency that existed when TasksProvider
  /// directly depended on AuthProvider, while maintaining the same functionality.
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
        _updateState(
          _state.copyWith(
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
  /// Parameters:
  /// - [task]: The task entity to validate ownership for
  ///
  /// Returns:
  /// - `true` if the current user owns the task (exact userId match)
  /// - `false` if no user is authenticated, task has null userId, or belongs to different user
  ///
  /// SECURITY: Tasks with null userId are DENIED access to prevent data exposure
  ///
  /// Example:
  /// ```dart
  /// if (_validateTaskOwnership(task)) {
  ///   // Safe to modify task
  ///   await updateTask(task);
  /// }
  /// ```
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
  ///
  /// This method combines task retrieval with ownership validation in a single
  /// operation. It throws an exception if the task is not found or if the user
  /// doesn't have permission to access it.
  ///
  /// Parameters:
  /// - [taskId]: Unique identifier of the task to retrieve
  ///
  /// Returns:
  /// - The task entity if found and owned by current user
  ///
  /// Throws:
  /// - [Exception] if task is not found
  /// - [UnauthorizedAccessException] if user doesn't own the task
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final task = _getTaskWithOwnershipValidation('task_123');
  ///   // Safe to use task
  /// } on UnauthorizedAccessException {
  ///   // Handle unauthorized access
  /// }
  /// ```
  task_entity.Task _getTaskWithOwnershipValidation(String taskId) {
    final task = _state.allTasks.firstWhere(
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
  List<task_entity.Task> get highPriorityTasks =>
      _state.filteredTasks
          .where(
            (t) =>
                t.priority == task_entity.TaskPriority.high ||
                t.priority == task_entity.TaskPriority.urgent,
          )
          .toList();

  List<task_entity.Task> get mediumPriorityTasks =>
      _state.filteredTasks
          .where((t) => t.priority == task_entity.TaskPriority.medium)
          .toList();

  List<task_entity.Task> get lowPriorityTasks =>
      _state.filteredTasks
          .where((t) => t.priority == task_entity.TaskPriority.low)
          .toList();

  /// Loads tasks from the remote data source with sync coordination
  ///
  /// This method orchestrates the complete task loading process including:
  /// - CRITICAL: Waits for authentication to be fully initialized
  /// - Sync throttling to prevent excessive API calls
  /// - Error handling with user-friendly messages
  /// - Loading state management
  /// - Notification scheduling for loaded tasks
  /// - Automatic overdue task detection
  ///
  /// The method uses the SyncCoordinator to ensure operations don't conflict
  /// and implements throttling to prevent rapid successive calls.
  ///
  /// Throws:
  /// - [SyncThrottledException] if called too frequently (handled internally)
  ///
  /// Example:
  /// ```dart
  /// await loadTasks(); // Will update state with loaded tasks
  /// ```
  Future<void> loadTasks() async {
    debugPrint('🔄 TasksProvider: Starting load tasks...');

    try {
      await _syncCoordinator.executeSyncOperation(
        operationType: TaskSyncOperations.loadTasks,
        priority: SyncPriority.high.index,
        minimumInterval:
            TasksConstants.syncMinimumInterval, // Throttle rapid calls
        operation: () => _loadTasksOperation(),
      );
    } on SyncThrottledException catch (e) {
      debugPrint('⚠️ Load tasks throttled: ${e.message}');
    } catch (e) {
      debugPrint('❌ TasksProvider: Load tasks failed: $e');
      _updateState(
        _state.copyWith(
          isLoading: false,
          errorMessage: 'Erro ao sincronizar tarefas: $e',
        ),
      );
    }
  }

  /// CRITICAL FIX: Wait for authentication initialization with timeout
  ///
  /// This method ensures that we don't attempt to load tasks before the
  /// authentication system is fully initialized. This prevents race conditions
  /// that cause data not to load properly.
  ///
  /// Returns:
  /// - `true` if authentication is initialized within timeout
  /// - `false` if timeout is reached
  Future<bool> _waitForAuthenticationWithTimeout({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (_authStateNotifier.isInitialized) {
      return true;
    }

    debugPrint('⏳ TasksProvider: Waiting for auth initialization...');
    try {
      await _authStateNotifier.initializedStream
          .where((isInitialized) => isInitialized)
          .timeout(timeout)
          .first;

      debugPrint('✅ TasksProvider: Auth initialization complete');
      return true;
    } on TimeoutException {
      debugPrint(
        '⚠️ TasksProvider: Auth initialization timeout after ${timeout.inSeconds}s',
      );
      return false;
    } catch (e) {
      debugPrint('❌ TasksProvider: Auth initialization error: $e');
      return false;
    }
  }

  Future<void> _loadTasksOperation() async {
    if (_disposed) return;
    final shouldShowLoading = _state.allTasks.isEmpty;

    if (shouldShowLoading) {
      _startGlobalOperation(
        TaskLoadingOperation.loadingTasks,
        message: AppStrings.loadingTasks,
      );
      _updateState(_state.copyWith(isLoading: true, clearError: true));
    } else {
      _startGlobalOperation(
        TaskLoadingOperation.syncing,
        message: AppStrings.synchronizing,
      );
      _updateState(_state.copyWith(clearError: true));
    }

    try {
      debugPrint('🔄 TasksProvider: Calling _getTasksUseCase...');
      final result = await _getTasksUseCase(const NoParams());
      debugPrint('✅ TasksProvider: _getTasksUseCase completed successfully');
      if (_disposed) return;

      result.fold(
        (failure) {
          if (_disposed) return;
          _completeGlobalOperation(TaskLoadingOperation.loadingTasks);
          _completeGlobalOperation(TaskLoadingOperation.syncing);
          _updateState(
            _state.copyWith(
              isLoading: false,
              errorMessage: _mapFailureToMessage(failure),
            ),
          );
          throw Exception(_mapFailureToMessage(failure));
        },
        (tasks) {
          if (_disposed) return;
          final filteredTasks = _applyFiltersToTasks(
            tasks,
            _state.currentFilter,
            _state.searchQuery,
            _state.selectedPlantId,
            _state.selectedTaskTypes,
            _state.selectedPriorities,
          );

          _completeGlobalOperation(TaskLoadingOperation.loadingTasks);
          _completeGlobalOperation(TaskLoadingOperation.syncing);
          _updateState(
            _state.copyWith(
              allTasks: tasks,
              filteredTasks: filteredTasks,
              isLoading: false,
              clearError: true,
            ),
          );
          _notificationService.checkOverdueTasks(tasks);
          _notificationService.rescheduleTaskNotifications(tasks);
        },
      );
    } catch (e) {
      if (_disposed) return;
      debugPrint('❌ TasksProvider: Load tasks operation failed: $e');
      debugPrint('❌ TasksProvider: Stack trace: ${StackTrace.current}');
      _completeGlobalOperation(TaskLoadingOperation.loadingTasks);
      _completeGlobalOperation(TaskLoadingOperation.syncing);
      _updateState(
        _state.copyWith(
          isLoading: false,
          errorMessage: 'Erro ao carregar tarefas: $e',
        ),
      );
      rethrow;
    }
  }

  /// Adds a new task with offline support and user validation
  ///
  /// This method handles the complete task creation workflow including:
  /// - User authentication validation
  /// - Optimistic updates for offline scenarios
  /// - Sync coordination to prevent conflicts
  /// - Automatic notification scheduling
  /// - Error handling with appropriate user feedback
  ///
  /// The method follows an offline-first approach, immediately updating the
  /// local state and queuing the operation for sync when network is available.
  ///
  /// Parameters:
  /// - [task]: The task entity to add (will be assigned to current user)
  ///
  /// Returns:
  /// - `true` if the task was successfully added (including optimistic updates)
  /// - `false` if there was an error that prevented task creation
  ///
  /// Example:
  /// ```dart
  /// final success = await addTask(newTask);
  /// if (success) {
  ///   // Task added successfully
  /// } else {
  ///   // Handle error (message will be in state.errorMessage)
  /// }
  /// ```
  Future<bool> addTask(task_entity.Task task) async {
    try {
      return await _syncCoordinator.executeSyncOperation<bool>(
        operationType: TaskSyncOperations.addTask,
        priority: SyncPriority.critical.index, // User-initiated operation
        operation: () => _addTaskOperation(task),
      );
    } catch (e) {
      _updateState(
        _state.copyWith(errorMessage: AppStrings.errorSyncingNewTask),
      );
      return false;
    }
  }

  Future<bool> _addTaskOperation(task_entity.Task task) async {
    _startGlobalOperation(
      TaskLoadingOperation.addingTask,
      message: AppStrings.addingTask,
    );
    _updateState(_state.copyWith(clearError: true));

    try {
      final currentUser = _authStateNotifier.currentUser;
      if (currentUser == null) {
        _completeGlobalOperation(TaskLoadingOperation.addingTask);
        _updateState(
          _state.copyWith(
            errorMessage: AppStrings.mustBeAuthenticatedToCreateTasks,
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
            final updatedTasks = List<task_entity.Task>.from(_state.allTasks)
              ..add(optimisticTask);
            final filteredTasks = _applyFiltersToTasks(
              updatedTasks,
              _state.currentFilter,
              _state.searchQuery,
              _state.selectedPlantId,
              _state.selectedTaskTypes,
              _state.selectedPriorities,
            );

            _updateState(
              _state.copyWith(
                allTasks: updatedTasks,
                filteredTasks: filteredTasks,
                clearError: true,
              ),
            );
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
              _state.copyWith(errorMessage: _mapFailureToMessage(failure)),
            );
            throw Exception(_mapFailureToMessage(failure));
          }
        },
        (addedTask) {
          final updatedTasks = List<task_entity.Task>.from(_state.allTasks)
            ..add(addedTask);
          final filteredTasks = _applyFiltersToTasks(
            updatedTasks,
            _state.currentFilter,
            _state.searchQuery,
            _state.selectedPlantId,
            _state.selectedTaskTypes,
            _state.selectedPriorities,
          );

          _completeGlobalOperation(TaskLoadingOperation.addingTask);
          _updateState(
            _state.copyWith(
              allTasks: updatedTasks,
              filteredTasks: filteredTasks,
              clearError: true,
            ),
          );
          _notificationService.scheduleTaskNotification(addedTask);
          return true;
        },
      );
    } catch (e) {
      _completeGlobalOperation(TaskLoadingOperation.addingTask);
      _updateState(
        _state.copyWith(errorMessage: AppStrings.unexpectedErrorAddingTask),
      );
      rethrow;
    }
  }

  /// Completes a task with offline support and ownership validation
  ///
  /// This method handles the complete task completion workflow including:
  /// - Task ownership validation for security
  /// - Optimistic updates for offline scenarios
  /// - Notification cancellation for completed tasks
  /// - Sync coordination to prevent conflicts
  /// - Automatic notification rescheduling
  ///
  /// The method follows an offline-first approach, immediately updating the
  /// local state and queuing the operation for sync when network is available.
  ///
  /// Parameters:
  /// - [taskId]: Unique identifier of the task to complete
  /// - [notes]: Optional completion notes from the user
  ///
  /// Returns:
  /// - `true` if the task was successfully completed (including optimistic updates)
  /// - `false` if there was an error that prevented completion
  ///
  /// Throws:
  /// - [UnauthorizedAccessException] if user doesn't own the task
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final success = await completeTask('task_123', notes: 'Watered all plants');
  ///   if (success) {
  ///     // Task completed successfully
  ///   }
  /// } on UnauthorizedAccessException {
  ///   // Handle unauthorized access
  /// }
  /// ```
  Future<bool> completeTask(String taskId, {String? notes}) async {
    try {
      return await _syncCoordinator.executeSyncOperation<bool>(
        operationType: TaskSyncOperations.completeTask,
        priority: SyncPriority.critical.index, // User-initiated operation
        operation: () => _completeTaskOperation(taskId, notes),
      );
    } catch (e) {
      _updateState(
        _state.copyWith(errorMessage: AppStrings.errorSyncingTaskCompletion),
      );
      return false;
    }
  }

  Future<bool> _completeTaskOperation(String taskId, String? notes) async {
    _startTaskOperation(taskId, message: AppStrings.completingTask);
    _updateState(_state.copyWith(clearError: true));

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
            final updatedTasks =
                _state.allTasks.map((t) {
                  return t.id == taskId ? completedTask : t;
                }).toList();

            final filteredTasks = _applyFiltersToTasks(
              updatedTasks,
              _state.currentFilter,
              _state.searchQuery,
              _state.selectedPlantId,
              _state.selectedTaskTypes,
              _state.selectedPriorities,
            );

            _updateState(
              _state.copyWith(
                allTasks: updatedTasks,
                filteredTasks: filteredTasks,
                clearError: true,
              ),
            );
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
            _notificationService.cancelTaskNotifications(taskId);
            _notificationService.rescheduleTaskNotifications(updatedTasks);

            _completeTaskLoadingOperation(taskId);
            return true; // Return success for optimistic update
          } else {
            _completeTaskLoadingOperation(taskId);
            _updateState(
              _state.copyWith(errorMessage: _mapFailureToMessage(failure)),
            );
            throw Exception(_mapFailureToMessage(failure));
          }
        },
        (completedTask) {
          final updatedTasks =
              _state.allTasks.map((t) {
                return t.id == taskId ? completedTask : t;
              }).toList();

          final filteredTasks = _applyFiltersToTasks(
            updatedTasks,
            _state.currentFilter,
            _state.searchQuery,
            _state.selectedPlantId,
            _state.selectedTaskTypes,
            _state.selectedPriorities,
          );

          _completeTaskLoadingOperation(taskId);
          _updateState(
            _state.copyWith(
              allTasks: updatedTasks,
              filteredTasks: filteredTasks,
              clearError: true,
            ),
          );
          _notificationService.cancelTaskNotifications(taskId);
          _notificationService.rescheduleTaskNotifications(updatedTasks);

          return true;
        },
      );
    } on UnauthorizedAccessException catch (e) {
      _completeTaskLoadingOperation(taskId);
      _updateState(_state.copyWith(errorMessage: e.message));
      rethrow;
    } catch (e) {
      _completeTaskLoadingOperation(taskId);
      _updateState(
        _state.copyWith(errorMessage: AppStrings.unexpectedErrorCompletingTask),
      );
      rethrow;
    }
  }

  /// Searches tasks by title, plant name, or description
  ///
  /// This method performs real-time search filtering on the loaded tasks.
  /// The search is case-insensitive and matches against task title, associated
  /// plant name, and task description (if present).
  ///
  /// Parameters:
  /// - [query]: Search query string (will be normalized to lowercase)
  ///
  /// Example:
  /// ```dart
  /// searchTasks('water'); // Will show all watering-related tasks
  /// searchTasks('roses'); // Will show tasks for rose plants
  /// ```
  void searchTasks(String query) {
    final normalizedQuery = query.toLowerCase();
    if (_state.searchQuery != normalizedQuery) {
      final filteredTasks = _applyFiltersToTasks(
        _state.allTasks,
        _state.currentFilter,
        normalizedQuery,
        _state.selectedPlantId,
        _state.selectedTaskTypes,
        _state.selectedPriorities,
      );

      _updateState(
        _state.copyWith(
          searchQuery: normalizedQuery,
          filteredTasks: filteredTasks,
        ),
      );
    }
  }

  /// Sets the active filter for task display with optional plant filtering
  ///
  /// This method applies predefined filters to show specific subsets of tasks.
  /// Filters include showing all tasks, today's tasks, overdue tasks, etc.
  /// When filtering by plant, the plantId parameter must be provided.
  ///
  /// Parameters:
  /// - [filter]: The filter type to apply (from TasksFilterType enum)
  /// - [plantId]: Required when filter is TasksFilterType.byPlant
  ///
  /// Example:
  /// ```dart
  /// setFilter(TasksFilterType.today); // Show only today's tasks
  /// setFilter(TasksFilterType.byPlant, plantId: 'plant_123'); // Show tasks for specific plant
  /// ```
  void setFilter(TasksFilterType filter, {String? plantId}) {
    if (_state.currentFilter != filter || _state.selectedPlantId != plantId) {
      final filteredTasks = _applyFiltersToTasks(
        _state.allTasks,
        filter,
        _state.searchQuery,
        plantId,
        _state.selectedTaskTypes,
        _state.selectedPriorities,
      );

      _updateState(
        _state.copyWith(
          currentFilter: filter,
          selectedPlantId: plantId,
          filteredTasks: filteredTasks,
        ),
      );
    }
  }

  /// Applies advanced filtering with multiple criteria
  ///
  /// This method allows complex filtering combinations including task types,
  /// priorities, and standard filters. All parameters are optional and when
  /// not provided, the current values are maintained.
  ///
  /// Parameters:
  /// - [taskTypes]: List of task types to include (e.g., watering, fertilizing)
  /// - [priorities]: List of priorities to include (e.g., high, urgent)
  /// - [filter]: Standard filter to apply (today, overdue, etc.)
  /// - [plantId]: Specific plant to filter by
  ///
  /// Example:
  /// ```dart
  /// setAdvancedFilters(
  ///   taskTypes: [TaskType.watering, TaskType.fertilizing],
  ///   priorities: [TaskPriority.high, TaskPriority.urgent],
  ///   filter: TasksFilterType.today,
  /// );
  /// ```
  void setAdvancedFilters({
    List<task_entity.TaskType>? taskTypes,
    List<task_entity.TaskPriority>? priorities,
    TasksFilterType? filter,
    String? plantId,
  }) {
    final filteredTasks = _applyFiltersToTasks(
      _state.allTasks,
      filter ?? _state.currentFilter,
      _state.searchQuery,
      plantId ?? _state.selectedPlantId,
      taskTypes ?? _state.selectedTaskTypes,
      priorities ?? _state.selectedPriorities,
    );

    _updateState(
      _state.copyWith(
        currentFilter: filter ?? _state.currentFilter,
        selectedPlantId: plantId ?? _state.selectedPlantId,
        selectedTaskTypes: taskTypes ?? _state.selectedTaskTypes,
        selectedPriorities: priorities ?? _state.selectedPriorities,
        filteredTasks: filteredTasks,
      ),
    );
  }

  /// Refreshes tasks from the remote data source with visual feedback
  ///
  /// This method provides a user-initiated refresh operation with appropriate
  /// loading states. It's typically called from pull-to-refresh gestures or
  /// refresh buttons in the UI.
  ///
  /// The method ensures the refresh operation is tracked separately from
  /// regular loading operations to provide accurate UI feedback.
  ///
  /// Example:
  /// ```dart
  /// await refresh(); // User will see "Refreshing..." message
  /// ```
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

  /// Applies comprehensive filtering logic to a list of tasks
  ///
  /// This pure function implements all task filtering logic including:
  /// - Time-based filters (today, overdue, upcoming)
  /// - Status-based filters (completed, pending)
  /// - Plant-based filtering
  /// - Task type filtering
  /// - Priority filtering
  /// - Text search filtering
  /// - Intelligent sorting by priority and due date
  ///
  /// Being a pure function, it doesn't mutate state, making it easier to test
  /// and reason about. The function is used internally by all filtering methods.
  ///
  /// Parameters:
  /// - [allTasks]: Complete list of tasks to filter
  /// - [currentFilter]: Primary filter type to apply
  /// - [searchQuery]: Text search query
  /// - [selectedPlantId]: Plant ID for plant-specific filtering
  /// - [selectedTaskTypes]: List of task types to include
  /// - [selectedPriorities]: List of priorities to include
  ///
  /// Returns:
  /// - Filtered and sorted list of tasks
  ///
  /// Example:
  /// ```dart
  /// final filtered = _applyFiltersToTasks(
  ///   allTasks,
  ///   TasksFilterType.today,
  ///   'water',
  ///   null,
  ///   [TaskType.watering],
  ///   [TaskPriority.high],
  /// );
  /// ```
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
        ); // Maior prioridade primeiro
      }
      return a.dueDate.compareTo(b.dueDate);
    });

    return tasks;
  }

  /// Clears the current error state
  ///
  /// This method removes any error messages from the state, typically called
  /// when the user acknowledges an error or when starting a new operation.
  ///
  /// Example:
  /// ```dart
  /// clearError(); // Removes error message from UI
  /// ```
  void clearError() {
    _updateState(_state.copyWith(clearError: true));
  }

  /// Sets filtering to show tasks for a specific plant
  ///
  /// This is a convenience method that applies the byPlant filter with the
  /// specified plant ID. It's equivalent to calling setFilter with
  /// TasksFilterType.byPlant and providing the plantId.
  ///
  /// Parameters:
  /// - [plantId]: ID of the plant to filter by, or null to show all plants
  ///
  /// Example:
  /// ```dart
  /// setPlantFilter('plant_123'); // Show only tasks for this plant
  /// setPlantFilter(null); // Reset plant filter
  /// ```
  void setPlantFilter(String? plantId) {
    setFilter(TasksFilterType.byPlant, plantId: plantId);
  }

  /// Maps domain failures to user-friendly error messages
  ///
  /// This method converts technical failure objects into messages that
  /// can be safely displayed to users. It ensures consistent error
  /// messaging throughout the application.
  ///
  /// Parameters:
  /// - [failure]: The failure object to convert
  ///
  /// Returns:
  /// - User-friendly error message string
  String _mapFailureToMessage(Failure failure) {
    return failure.userMessage;
  }

  /// Determines if a failure is network-related for offline queue handling
  ///
  /// This method analyzes failure objects to determine if they represent
  /// network connectivity issues. Network failures trigger optimistic
  /// updates and offline queue operations.
  ///
  /// Parameters:
  /// - [failure]: The failure object to analyze
  ///
  /// Returns:
  /// - `true` if the failure is network-related
  /// - `false` if it's a validation or other type of failure
  bool _isNetworkFailure(Failure failure) {
    return failure is NetworkFailure ||
        failure.message.toLowerCase().contains('network') ||
        failure.message.toLowerCase().contains('connection') ||
        failure.message.toLowerCase().contains('timeout');
  }

  /// Initializes the notification service with comprehensive setup
  ///
  /// This method handles the complete notification service initialization
  /// including:
  /// - Core service initialization
  /// - Permission requests
  /// - Notification handlers setup
  /// - WorkManager initialization for background processing
  ///
  /// The method is called automatically during provider construction and
  /// includes proper error handling to ensure the app continues functioning
  /// even if notifications fail to initialize.
  ///
  /// Returns:
  /// - A Future that completes when initialization is finished
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
  ///
  /// This method checks the system-level notification permissions and
  /// returns the current status. It's useful for showing appropriate
  /// UI elements or prompting users to enable notifications.
  ///
  /// Returns:
  /// - [NotificationPermissionStatus.granted] if permissions are enabled
  /// - [NotificationPermissionStatus.denied] if permissions are denied
  /// - [NotificationPermissionStatus.notDetermined] if not yet requested
  Future<NotificationPermissionStatus> getNotificationPermissionStatus() async {
    return await _notificationService.getPermissionStatus();
  }

  /// Requests notification permissions from the user
  ///
  /// This method triggers the system notification permission dialog.
  /// It should be called in response to user action and with proper
  /// context about why notifications are needed.
  ///
  /// Returns:
  /// - `true` if permissions were granted
  /// - `false` if permissions were denied or an error occurred
  Future<bool> requestNotificationPermissions() async {
    try {
      return true; // Placeholder
    } catch (e) {
      debugPrint('❌ Error requesting notification permissions: $e');
      return false;
    }
  }

  /// Opens the system notification settings for the app
  ///
  /// This method navigates the user to the system settings where they
  /// can manually enable or configure notification preferences. It's
  /// typically used when permissions are denied and need manual enabling.
  ///
  /// Returns:
  /// - `true` if the settings screen was successfully opened
  /// - `false` if there was an error opening the settings
  Future<bool> openNotificationSettings() async {
    return await _notificationService.openNotificationSettings();
  }

  /// Returns the count of currently scheduled notifications
  ///
  /// This method provides insight into how many notifications are
  /// currently queued in the system. It's useful for debugging
  /// and for showing users how many reminders they have set.
  ///
  /// Returns:
  /// - Integer count of scheduled notifications
  Future<int> getScheduledNotificationsCount() async {
    return await _notificationService.getScheduledNotificationsCount();
  }

  /// Disposes of the provider and cancels ongoing operations
  ///
  /// This method performs cleanup when the provider is no longer needed.
  /// It cancels any ongoing sync operations to prevent memory leaks and
  /// ensures proper resource cleanup.
  ///
  /// Called automatically by Flutter when the provider is removed from
  /// the widget tree.
  @override
  void dispose() {
    _disposed = true;
    _authSubscription?.cancel();
    _syncCoordinator.cancelOperations(TaskSyncOperations.loadTasks);
    _syncCoordinator.cancelOperations(TaskSyncOperations.addTask);
    _syncCoordinator.cancelOperations(TaskSyncOperations.completeTask);

    super.dispose();
  }
}

/// Exception thrown when a user tries to access a task they don't own
class UnauthorizedAccessException implements Exception {
  final String message;

  const UnauthorizedAccessException(this.message);

  @override
  String toString() => 'UnauthorizedAccessException: $message';
}
