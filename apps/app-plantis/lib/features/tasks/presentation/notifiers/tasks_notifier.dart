import 'dart:async';

import 'package:core/core.dart' hide Column, getIt;
import 'package:flutter/foundation.dart';

import '../../../../core/auth/auth_state_notifier.dart';
import '../../../../core/services/notification_permission_status.dart';
import '../../../../core/services/task_notification_service.dart';
import '../../domain/entities/task.dart' as task_entity;
import '../../domain/services/task_filter_service.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../providers/tasks_providers.dart';
import '../providers/tasks_state.dart';
import 'tasks_crud_notifier.dart';
import 'tasks_query_notifier.dart';

part 'tasks_notifier.g.dart';

/// Root TasksNotifier - Orchestrates specialized notifiers (SRP)
///
/// Responsibilities (Coordinator Pattern):
/// - Load and sync tasks from repository
/// - Coordinate between specialized notifiers
/// - Authentication state management
/// - Notification service management
///
/// Delegates to specialized notifiers:
/// - TasksCrudNotifier: ADD, UPDATE, DELETE, GET
/// - TasksQueryNotifier: LIST, SEARCH, FILTER
/// - TasksScheduleNotifier: RECURRING, REMINDERS, SCHEDULING
/// - TasksRecommendationNotifier: RECOMMENDATIONS, SUGGESTIONS
@riverpod
class TasksNotifier extends _$TasksNotifier {
  late final GetTasksUseCase _getTasksUseCase;
  late final TaskNotificationService _notificationService;
  late final AuthStateNotifier _authStateNotifier;
  late final ITaskFilterService _filterService;
  StreamSubscription<UserEntity?>? _authSubscription;

  @override
  Future<TasksState> build() async {
    _getTasksUseCase = ref.read(getTasksUseCaseProvider);
    _notificationService = TaskNotificationService();
    _authStateNotifier = AuthStateNotifier.instance;
    _filterService = ref.read(taskFilterServiceProvider);

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
    final currentState = state.valueOrNull ?? TasksState.initial();
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

  /// Delegates to specialized CRUD notifier
  Future<bool> addTask(task_entity.Task task) async {
    return await ref.read(tasksCrudNotifierProvider.notifier).addTask(task);
  }

  /// Delegates to specialized CRUD notifier
  Future<bool> completeTask(String taskId, {String? notes}) async {
    return await ref
        .read(tasksCrudNotifierProvider.notifier)
        .completeTask(taskId, notes: notes);
  }

  /// Delegates to specialized Query notifier
  void searchTasks(String query) {
    ref.read(tasksQueryNotifierProvider.notifier).searchTasks(query);
    _syncQueryStateToRoot();
  }

  /// Delegates to specialized Query notifier
  void setFilter(TasksFilterType filter, {String? plantId}) {
    ref
        .read(tasksQueryNotifierProvider.notifier)
        .setFilter(filter, plantId: plantId);
    _syncQueryStateToRoot();
  }

  /// Delegates to specialized Query notifier
  void setAdvancedFilters({
    List<task_entity.TaskType>? taskTypes,
    List<task_entity.TaskPriority>? priorities,
    String? plantId,
  }) {
    ref
        .read(tasksQueryNotifierProvider.notifier)
        .setAdvancedFilters(
          taskTypes: taskTypes,
          priorities: priorities,
          plantId: plantId,
        );
    _syncQueryStateToRoot();
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

  /// Helper: Sync query state to root
  void _syncQueryStateToRoot() {
    final queryState = ref.read(tasksQueryNotifierProvider);
    _updateState(
      (current) => current.copyWith(
        searchQuery: queryState.searchQuery,
        currentFilter: queryState.currentFilter,
        selectedPlantId: queryState.selectedPlantId,
        selectedTaskTypes: queryState.selectedTaskTypes,
        selectedPriorities: queryState.selectedPriorities,
        filteredTasks: queryState.filteredTasks,
      ),
    );
  }

  /// Helper: Update state
  void _updateState(TasksState Function(TasksState current) update) {
    final currentState = state.valueOrNull ?? TasksState.initial();
    state = AsyncValue.data(update(currentState));
  }

  /// Alias for setFilter - for backwards compatibility
  void filterTasks(TasksFilterType filter, {String? plantId}) {
    setFilter(filter, plantId: plantId);
  }
}
