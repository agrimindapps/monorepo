# SOLID VIOLATIONS - CODE EXAMPLES & FIXES
## App-Plantis - Concrete Examples with Refactoring Patterns

---

## TABLE OF CONTENTS

1. [SRP Violations](#srp-violations)
2. [OCP Violations](#ocp-violations)
3. [LSP Violations](#lsp-violations)
4. [ISP Violations](#isp-violations)
5. [DIP Violations](#dip-violations)
6. [Refactoring Cheat Sheet](#refactoring-cheat-sheet)

---

## SRP VIOLATIONS

### Violation 1: TasksNotifier God Object (729 lines)

**Location:** `lib/features/tasks/presentation/notifiers/tasks_notifier.dart`

**Problem:** Single class with 16+ responsibilities

#### BAD CODE (Current):

```dart
@riverpod
class TasksNotifier extends _$TasksNotifier {
  late final GetTasksUseCase _getTasksUseCase;
  late final AddTaskUseCase _addTaskUseCase;
  late final CompleteTaskUseCase _completeTaskUseCase;
  late final TaskNotificationService _notificationService; // ❌ Direct instantiation
  late final AuthStateNotifier _authStateNotifier;
  late final ITaskFilterService _filterService;
  late final ITaskOwnershipValidator _ownershipValidator;

  @override
  Future<TasksState> build() async {
    // RESPONSIBILITY 1: Initialize dependencies
    _getTasksUseCase = ref.read(getTasksUseCaseProvider);
    _addTaskUseCase = ref.read(addTaskUseCaseProvider);
    _completeTaskUseCase = ref.read(completeTaskUseCaseProvider);
    _notificationService = TaskNotificationService(); // ❌ Direct instantiation
    _authStateNotifier = AuthStateNotifier.instance;
    _filterService = ref.read(taskFilterServiceProvider);
    _ownershipValidator = ref.read(taskOwnershipValidatorProvider);

    // RESPONSIBILITY 2: Initialize notifications
    await _initializeNotificationService();

    // RESPONSIBILITY 3: Listen to auth
    _initializeAuthListener();

    return await _loadTasksInternal();
  }

  // RESPONSIBILITY 4: Auth listening (50 lines)
  void _initializeAuthListener() { /* ... */ }

  // RESPONSIBILITY 5: Ownership validation
  task_entity.Task _getTaskWithOwnershipValidation(String taskId) { /* ... */ }

  // RESPONSIBILITY 6-9: Loading state tracking (120 lines)
  void _startTaskOperation(String taskId, {String? message}) { /* ... */ }
  void _completeTaskLoadingOperation(String taskId) { /* ... */ }
  void _startGlobalOperation(TaskLoadingOperation operation, {String? message}) { /* ... */ }
  void _completeGlobalOperation(TaskLoadingOperation operation) { /* ... */ }

  // RESPONSIBILITY 10: Load tasks (90 lines)
  Future<void> loadTasks() async { /* ... */ }

  // RESPONSIBILITY 11: Add task (110 lines)
  Future<bool> addTask(task_entity.Task task) async { /* ... */ }

  // RESPONSIBILITY 12: Complete task (120 lines)
  Future<bool> completeTask(String taskId, {String? notes}) async { /* ... */ }

  // RESPONSIBILITY 13: Search (30 lines)
  void searchTasks(String query) { /* ... */ }

  // RESPONSIBILITY 14: Filtering (60 lines)
  void setFilter(TasksFilterType filter, {String? plantId}) { /* ... */ }
  void setAdvancedFilters({...}) { /* ... */ }

  // RESPONSIBILITY 15: Notification management (90 lines)
  Future<void> _initializeNotificationService() async { /* ... */ }
  Future<NotificationPermissionStatus> getNotificationPermissionStatus() async { /* ... */ }
  Future<bool> requestNotificationPermissions() async { /* ... */ }
  Future<bool> openNotificationSettings() async { /* ... */ }

  // RESPONSIBILITY 16: Priority getters
  List<task_entity.Task> get highPriorityTasks { /* ... */ }
  List<task_entity.Task> get mediumPriorityTasks { /* ... */ }
  List<task_entity.Task> get lowPriorityTasks { /* ... */ }
}
```

#### GOOD CODE (Refactored):

```dart
// 1. FOCUSED NOTIFIER (State management ONLY)
@riverpod
class TasksNotifier extends _$TasksNotifier {
  late final GetTasksUseCase _getTasksUseCase;
  late final AddTaskUseCase _addTaskUseCase;
  late final CompleteTaskUseCase _completeTaskUseCase;
  late final TasksAuthCoordinator _authCoordinator; // ✅ Injected
  late final ITaskFilterService _filterService;
  StreamSubscription<UserEntity?>? _authSubscription;

  @override
  Future<TasksState> build() async {
    _getTasksUseCase = ref.read(getTasksUseCaseProvider);
    _addTaskUseCase = ref.read(addTaskUseCaseProvider);
    _completeTaskUseCase = ref.read(completeTaskUseCaseProvider);
    _authCoordinator = ref.read(tasksAuthCoordinatorProvider); // ✅ DI
    _filterService = ref.read(taskFilterServiceProvider);

    // Delegate auth listening to coordinator
    _authSubscription = _authCoordinator.userStream.listen(_onUserChanged);

    ref.onDispose(() => _authSubscription?.cancel());

    return await _loadTasksInternal();
  }

  void _onUserChanged(UserEntity? user) {
    if (user == null) {
      state = AsyncValue.data(TasksState.initial());
    } else {
      loadTasks();
    }
  }

  Future<void> loadTasks() async {
    final result = await _getTasksUseCase(const NoParams());
    result.fold(
      (failure) => state = AsyncValue.data(
        TasksState.error(failure.userMessage),
      ),
      (tasks) {
        final filteredTasks = _filterService.applyCurrentFilter(tasks);
        state = AsyncValue.data(TasksState(
          allTasks: tasks,
          filteredTasks: filteredTasks,
        ));
      },
    );
  }

  Future<bool> addTask(Task task) async {
    // Delegate ownership validation
    _authCoordinator.validateOwnershipOrThrow(task);

    final result = await _addTaskUseCase(AddTaskParams(task: task));
    return result.fold(
      (failure) {
        state = AsyncValue.data(
          (state.valueOrNull ?? TasksState.initial())
              .copyWith(errorMessage: failure.userMessage),
        );
        return false;
      },
      (addedTask) {
        final updatedTasks = [...state.valueOrNull!.allTasks, addedTask];
        state = AsyncValue.data(
          (state.valueOrNull ?? TasksState.initial())
              .copyWith(allTasks: updatedTasks),
        );
        return true;
      },
    );
  }

  // Search/Filter delegated to filter service
  void searchTasks(String query) {
    final currentState = state.valueOrNull ?? TasksState.initial();
    final filteredTasks = _filterService.search(
      currentState.allTasks,
      query,
    );
    state = AsyncValue.data(
      currentState.copyWith(filteredTasks: filteredTasks),
    );
  }

  void setFilter(TasksFilterType filter) {
    final currentState = state.valueOrNull ?? TasksState.initial();
    final filteredTasks = _filterService.applyFilter(
      currentState.allTasks,
      filter,
    );
    state = AsyncValue.data(
      currentState.copyWith(filteredTasks: filteredTasks),
    );
  }
}

// 2. AUTH COORDINATOR SERVICE (Auth-related logic)
@injectable
class TasksAuthCoordinator {
  final AuthStateNotifier _authStateNotifier;
  final ITaskOwnershipValidator _ownershipValidator;

  TasksAuthCoordinator(
    this._authStateNotifier,
    this._ownershipValidator,
  );

  Stream<UserEntity?> get userStream => _authStateNotifier.userStream;

  UserEntity? get currentUser => _authStateNotifier.currentUser;

  bool get isAuthenticated => _authStateNotifier.isAuthenticated;

  void validateOwnershipOrThrow(Task task) {
    final user = currentUser;
    if (user == null) {
      throw UnauthorizedAccessException('User not authenticated');
    }

    _ownershipValidator.validateOwnershipOrThrow(task);
  }
}

// Provider
@riverpod
TasksAuthCoordinator tasksAuthCoordinator(TasksAuthCoordinatorRef ref) {
  return getIt<TasksAuthCoordinator>();
}

// 3. NOTIFICATION MANAGER SERVICE (Notification logic)
@injectable
class TaskNotificationManager {
  final TaskNotificationService _notificationService;

  TaskNotificationManager(this._notificationService);

  Future<void> initialize() async {
    final initResult = await _notificationService.initialize();
    if (initResult) {
      await _notificationService.initializeNotificationHandlers();
    }
  }

  Future<NotificationPermissionStatus> getPermissionStatus() async {
    return await _notificationService.getPermissionStatus();
  }

  Future<bool> requestPermissions() async {
    return await _notificationService.requestPermissions();
  }

  Future<bool> openSettings() async {
    return await _notificationService.openNotificationSettings();
  }

  Future<int> getScheduledCount() async {
    return await _notificationService.getScheduledNotificationsCount();
  }

  void scheduleTaskNotification(Task task) {
    _notificationService.scheduleTaskNotification(task);
  }

  void cancelTaskNotifications(String taskId) {
    _notificationService.cancelTaskNotifications(taskId);
  }

  void rescheduleAllNotifications(List<Task> tasks) {
    _notificationService.rescheduleTaskNotifications(tasks);
  }

  void checkOverdueTasks(List<Task> tasks) {
    _notificationService.checkOverdueTasks(tasks);
  }
}

// Provider
@riverpod
TaskNotificationManager taskNotificationManager(
  TaskNotificationManagerRef ref,
) {
  return getIt<TaskNotificationManager>();
}

// 4. FILTER SERVICE (Already exists - just use it!)
// lib/features/tasks/domain/services/task_filter_service.dart

@injectable
class TaskFilterService implements ITaskFilterService {
  @override
  List<Task> applyFilters(
    List<Task> tasks,
    TasksFilterType filter,
    String searchQuery,
    String? plantId,
    List<TaskType>? taskTypes,
    List<TaskPriority>? priorities,
  ) {
    var filtered = tasks;

    // Apply filter
    filtered = _applyFilter(filtered, filter);

    // Apply search
    if (searchQuery.isNotEmpty) {
      filtered = search(filtered, searchQuery);
    }

    // Apply plant filter
    if (plantId != null) {
      filtered = filtered.where((t) => t.plantId == plantId).toList();
    }

    // Apply task type filter
    if (taskTypes != null && taskTypes.isNotEmpty) {
      filtered = filtered.where((t) => taskTypes.contains(t.type)).toList();
    }

    // Apply priority filter
    if (priorities != null && priorities.isNotEmpty) {
      filtered = filtered.where((t) => priorities.contains(t.priority)).toList();
    }

    return filtered;
  }

  List<Task> _applyFilter(List<Task> tasks, TasksFilterType filter) {
    switch (filter) {
      case TasksFilterType.all:
        return tasks;
      case TasksFilterType.pending:
        return tasks.where((t) => t.status == TaskStatus.pending).toList();
      case TasksFilterType.completed:
        return tasks.where((t) => t.status == TaskStatus.completed).toList();
      case TasksFilterType.overdue:
        return tasks.where((t) => t.isOverdue).toList();
      case TasksFilterType.today:
        return tasks.where((t) => _isToday(t.scheduledFor)).toList();
      case TasksFilterType.byPlant:
        return tasks; // Handled by plantId parameter
    }
  }

  @override
  List<Task> search(List<Task> tasks, String query) {
    final lowerQuery = query.toLowerCase();
    return tasks.where((task) {
      return task.title.toLowerCase().contains(lowerQuery) ||
          (task.description?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  @override
  List<Task> getHighPriorityTasks(List<Task> tasks) {
    return tasks.where((t) => t.priority == TaskPriority.high).toList();
  }

  @override
  List<Task> getMediumPriorityTasks(List<Task> tasks) {
    return tasks.where((t) => t.priority == TaskPriority.medium).toList();
  }

  @override
  List<Task> getLowPriorityTasks(List<Task> tasks) {
    return tasks.where((t) => t.priority == TaskPriority.low).toList();
  }

  bool _isToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
```

**RESULT:**
- TasksNotifier: 729 lines → **180 lines** ✅
- Responsibilities: 16 → **4** (build, load, add, search/filter coordination) ✅
- New services: 3 (AuthCoordinator, NotificationManager, FilterService) ✅

---

### Violation 2: SettingsNotifier God Object (717 lines)

**Location:** `lib/features/settings/presentation/providers/settings_notifier.dart`

**Problem:** Manages 5 different settings categories in single class

#### BAD CODE (Current):

```dart
@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  // MANAGING 5 DIFFERENT SETTING TYPES
  Future<void> updateNotificationSettings(NotificationSettingsEntity newSettings) async { /* ... */ }
  Future<void> updateBackupSettings(BackupSettingsEntity newSettings) async { /* ... */ }
  Future<void> updateThemeSettings(ThemeSettingsEntity newSettings) async { /* ... */ }
  Future<void> updateAccountSettings(AccountSettingsEntity newSettings) async { /* ... */ }
  Future<void> updateAppSettings(AppSettingsEntity newSettings) async { /* ... */ }

  // 10+ TOGGLE METHODS
  Future<void> toggleTaskReminders(bool enabled) async { /* ... */ }
  Future<void> toggleOverdueNotifications(bool enabled) async { /* ... */ }
  Future<void> toggleDailySummary(bool enabled) async { /* ... */ }
  // ... 7 more

  // THEME METHODS
  Future<void> setThemeMode(ThemeMode themeMode) async { /* ... */ }
  Future<void> setDarkTheme() async { /* ... */ }
  Future<void> setLightTheme() async { /* ... */ }
  Future<void> setSystemTheme() async { /* ... */ }

  // NOTIFICATION ACTIONS
  Future<void> openNotificationSettings() async { /* ... */ }
  Future<void> sendTestNotification() async { /* ... */ }
  Future<void> clearAllNotifications() async { /* ... */ }

  // BACKUP ACTIONS
  Future<void> createConfigurationBackup() async { /* ... */ }

  // RESET
  Future<void> resetAllSettings() async { /* ... */ }
}
```

#### GOOD CODE (Refactored):

```dart
// 1. NOTIFICATION SETTINGS NOTIFIER (Focused on notifications)
@riverpod
class NotificationSettingsNotifier extends _$NotificationSettingsNotifier {
  late final ISettingsRepository _settingsRepository;
  late final PlantisNotificationService _notificationService;

  @override
  Future<NotificationSettingsEntity> build() async {
    _settingsRepository = ref.read(settingsRepositoryProvider);
    _notificationService = ref.read(plantisNotificationServiceProvider);
    return await _loadNotificationSettings();
  }

  Future<NotificationSettingsEntity> _loadNotificationSettings() async {
    final result = await _settingsRepository.loadSettings();
    return result.fold(
      (failure) => NotificationSettingsEntity.defaults(),
      (settings) => settings.notifications,
    );
  }

  Future<void> toggleTaskReminders(bool enabled) async {
    final current = state.valueOrNull ?? NotificationSettingsEntity.defaults();
    final updated = current.copyWith(taskRemindersEnabled: enabled);
    await _updateSettings(updated);
  }

  Future<void> toggleOverdueNotifications(bool enabled) async {
    final current = state.valueOrNull ?? NotificationSettingsEntity.defaults();
    final updated = current.copyWith(overdueNotificationsEnabled: enabled);
    await _updateSettings(updated);
  }

  Future<void> toggleDailySummary(bool enabled) async {
    final current = state.valueOrNull ?? NotificationSettingsEntity.defaults();
    final updated = current.copyWith(dailySummaryEnabled: enabled);
    await _updateSettings(updated);
  }

  Future<void> setReminderMinutesBefore(int minutes) async {
    final current = state.valueOrNull ?? NotificationSettingsEntity.defaults();
    final updated = current.copyWith(reminderMinutesBefore: minutes);
    await _updateSettings(updated);
  }

  Future<void> _updateSettings(NotificationSettingsEntity newSettings) async {
    final settingsResult = await _settingsRepository.loadSettings();
    final fullSettings = settingsResult.fold(
      (failure) => SettingsEntity.defaults(),
      (settings) => settings,
    );

    final updatedFullSettings = fullSettings.copyWith(
      notifications: newSettings,
    );

    final saveResult = await _settingsRepository.saveSettings(
      updatedFullSettings,
    );

    saveResult.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (_) {
        state = AsyncValue.data(newSettings);
      },
    );
  }

  Future<void> openNotificationSettings() async {
    await _notificationService.openNotificationSettings();
  }

  Future<void> sendTestNotification() async {
    await _notificationService.showTaskReminderNotification(
      taskName: 'Teste de Notificação',
      plantName: 'Planta de Teste',
      taskType: 'test',
    );
  }

  Future<void> clearAllNotifications() async {
    await _notificationService.cancelAllNotifications();
  }
}

// 2. THEME SETTINGS NOTIFIER (Focused on theme)
@riverpod
class ThemeSettingsNotifier extends _$ThemeSettingsNotifier {
  late final ISettingsRepository _settingsRepository;

  @override
  Future<ThemeSettingsEntity> build() async {
    _settingsRepository = ref.read(settingsRepositoryProvider);
    return await _loadThemeSettings();
  }

  Future<ThemeSettingsEntity> _loadThemeSettings() async {
    final result = await _settingsRepository.loadSettings();
    return result.fold(
      (failure) => ThemeSettingsEntity.defaults(),
      (settings) => settings.theme,
    );
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    final current = state.valueOrNull ?? ThemeSettingsEntity.defaults();
    final updated = current.copyWith(
      themeMode: themeMode,
      followSystemTheme: themeMode == ThemeMode.system,
    );
    await _updateSettings(updated);
  }

  Future<void> setDarkTheme() async => setThemeMode(ThemeMode.dark);
  Future<void> setLightTheme() async => setThemeMode(ThemeMode.light);
  Future<void> setSystemTheme() async => setThemeMode(ThemeMode.system);

  Future<void> _updateSettings(ThemeSettingsEntity newSettings) async {
    // Similar to NotificationSettingsNotifier
    final settingsResult = await _settingsRepository.loadSettings();
    final fullSettings = settingsResult.fold(
      (failure) => SettingsEntity.defaults(),
      (settings) => settings,
    );

    final updatedFullSettings = fullSettings.copyWith(theme: newSettings);

    final saveResult = await _settingsRepository.saveSettings(
      updatedFullSettings,
    );

    saveResult.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) => state = AsyncValue.data(newSettings),
    );
  }
}

// 3. BACKUP SETTINGS NOTIFIER (Focused on backup)
@riverpod
class BackupSettingsNotifier extends _$BackupSettingsNotifier {
  late final ISettingsRepository _settingsRepository;

  @override
  Future<BackupSettingsEntity> build() async {
    _settingsRepository = ref.read(settingsRepositoryProvider);
    return await _loadBackupSettings();
  }

  Future<BackupSettingsEntity> _loadBackupSettings() async {
    final result = await _settingsRepository.loadSettings();
    return result.fold(
      (failure) => BackupSettingsEntity.defaults(),
      (settings) => settings.backup,
    );
  }

  Future<void> updateBackupSettings(BackupSettingsEntity newSettings) async {
    final settingsResult = await _settingsRepository.loadSettings();
    final fullSettings = settingsResult.fold(
      (failure) => SettingsEntity.defaults(),
      (settings) => settings,
    );

    final updatedFullSettings = fullSettings.copyWith(backup: newSettings);

    final saveResult = await _settingsRepository.saveSettings(
      updatedFullSettings,
    );

    saveResult.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) => state = AsyncValue.data(newSettings),
    );
  }

  Future<void> createConfigurationBackup() async {
    final exportResult = await _settingsRepository.exportSettings();

    exportResult.fold(
      (failure) {
        // Handle error
      },
      (data) {
        // Success
      },
    );
  }
}

// 4. MAIN SETTINGS NOTIFIER (Coordinator - minimal logic)
@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  late final ISettingsRepository _settingsRepository;

  @override
  Future<SettingsState> build() async {
    _settingsRepository = ref.read(settingsRepositoryProvider);
    return await _initialize();
  }

  Future<SettingsState> _initialize() async {
    final result = await _settingsRepository.loadSettings();

    return result.fold(
      (failure) => SettingsState.initial().copyWith(
        errorMessage: failure.message,
      ),
      (settings) => SettingsState(
        settings: settings,
        isInitialized: true,
      ),
    );
  }

  Future<void> resetAllSettings() async {
    final result = await _settingsRepository.resetToDefaults();

    result.fold(
      (failure) {
        state = AsyncValue.data(
          (state.valueOrNull ?? SettingsState.initial()).copyWith(
            errorMessage: failure.message,
          ),
        );
      },
      (_) {
        state = AsyncValue.data(
          SettingsState.initial().copyWith(
            settings: SettingsEntity.defaults(),
            successMessage: 'Settings reset successfully',
          ),
        );

        // Invalidate specialized notifiers to reload
        ref.invalidate(notificationSettingsNotifierProvider);
        ref.invalidate(themeSettingsNotifierProvider);
        ref.invalidate(backupSettingsNotifierProvider);
      },
    );
  }

  Future<void> refresh() async {
    // Reload all settings
    await _initialize();
  }
}
```

**RESULT:**
- SettingsNotifier: 717 lines → **120 lines** ✅
- Specialized notifiers: 4 (Notifications, Theme, Backup, Main coordinator) ✅
- Each notifier <200 lines ✅

---

## OCP VIOLATIONS

### Violation 3: Switch Statements in Task Filtering

**Location:** `lib/features/tasks/domain/services/task_filter_service.dart` (suspected)

#### BAD CODE (Current Pattern):

```dart
class TaskFilterService {
  List<Task> applyFilters(
    List<Task> tasks,
    TasksFilterType filter,
    String searchQuery,
    String? plantId,
    List<TaskType>? taskTypes,
    List<TaskPriority>? priorities,
  ) {
    var filtered = tasks;

    // ❌ SWITCH STATEMENT - Violates OCP
    switch (filter) {
      case TasksFilterType.all:
        filtered = tasks;
        break;
      case TasksFilterType.pending:
        filtered = tasks.where((t) => t.status == TaskStatus.pending).toList();
        break;
      case TasksFilterType.completed:
        filtered = tasks.where((t) => t.status == TaskStatus.completed).toList();
        break;
      case TasksFilterType.overdue:
        filtered = tasks.where((t) => t.isOverdue).toList();
        break;
      case TasksFilterType.today:
        filtered = tasks.where((t) => _isToday(t.scheduledFor)).toList();
        break;
      case TasksFilterType.byPlant:
        if (plantId != null) {
          filtered = tasks.where((t) => t.plantId == plantId).toList();
        }
        break;
    }

    // Apply other filters...
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((task) {
        return task.title.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }
}
```

**Problem:** Adding new filter type requires modifying this class (violates OCP).

#### GOOD CODE (Strategy Pattern):

```dart
// 1. STRATEGY INTERFACE
abstract class TaskFilterStrategy {
  List<Task> filter(List<Task> tasks);
}

// 2. CONCRETE STRATEGIES

class AllTasksFilterStrategy implements TaskFilterStrategy {
  @override
  List<Task> filter(List<Task> tasks) => tasks;
}

class PendingTasksFilterStrategy implements TaskFilterStrategy {
  @override
  List<Task> filter(List<Task> tasks) {
    return tasks.where((t) => t.status == TaskStatus.pending).toList();
  }
}

class CompletedTasksFilterStrategy implements TaskFilterStrategy {
  @override
  List<Task> filter(List<Task> tasks) {
    return tasks.where((t) => t.status == TaskStatus.completed).toList();
  }
}

class OverdueTasksFilterStrategy implements TaskFilterStrategy {
  @override
  List<Task> filter(List<Task> tasks) {
    return tasks.where((t) => t.isOverdue).toList();
  }
}

class TodayTasksFilterStrategy implements TaskFilterStrategy {
  @override
  List<Task> filter(List<Task> tasks) {
    final now = DateTime.now();
    return tasks.where((task) {
      if (task.scheduledFor == null) return false;
      final date = task.scheduledFor!;
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }).toList();
  }
}

class ByPlantTasksFilterStrategy implements TaskFilterStrategy {
  final String plantId;

  ByPlantTasksFilterStrategy(this.plantId);

  @override
  List<Task> filter(List<Task> tasks) {
    return tasks.where((t) => t.plantId == plantId).toList();
  }
}

// 3. STRATEGY REGISTRY (Factory)
@injectable
class TaskFilterStrategyRegistry {
  final Map<TasksFilterType, TaskFilterStrategy> _strategies;

  TaskFilterStrategyRegistry()
      : _strategies = {
          TasksFilterType.all: AllTasksFilterStrategy(),
          TasksFilterType.pending: PendingTasksFilterStrategy(),
          TasksFilterType.completed: CompletedTasksFilterStrategy(),
          TasksFilterType.overdue: OverdueTasksFilterStrategy(),
          TasksFilterType.today: TodayTasksFilterStrategy(),
        };

  TaskFilterStrategy getStrategy(TasksFilterType type, {String? plantId}) {
    if (type == TasksFilterType.byPlant && plantId != null) {
      return ByPlantTasksFilterStrategy(plantId);
    }
    return _strategies[type] ?? AllTasksFilterStrategy();
  }

  // ✅ OPEN FOR EXTENSION: Register new filter without modifying existing code
  void registerStrategy(TasksFilterType type, TaskFilterStrategy strategy) {
    _strategies[type] = strategy;
  }
}

// 4. REFACTORED SERVICE (Uses Strategy)
@injectable
class TaskFilterService implements ITaskFilterService {
  final TaskFilterStrategyRegistry _strategyRegistry;

  TaskFilterService(this._strategyRegistry);

  @override
  List<Task> applyFilters(
    List<Task> tasks,
    TasksFilterType filter,
    String searchQuery,
    String? plantId,
    List<TaskType>? taskTypes,
    List<TaskPriority>? priorities,
  ) {
    // ✅ NO SWITCH - Uses Strategy
    final strategy = _strategyRegistry.getStrategy(filter, plantId: plantId);
    var filtered = strategy.filter(tasks);

    // Apply additional filters
    if (searchQuery.isNotEmpty) {
      filtered = _applySearchFilter(filtered, searchQuery);
    }

    if (taskTypes != null && taskTypes.isNotEmpty) {
      filtered = _applyTaskTypeFilter(filtered, taskTypes);
    }

    if (priorities != null && priorities.isNotEmpty) {
      filtered = _applyPriorityFilter(filtered, priorities);
    }

    return filtered;
  }

  List<Task> _applySearchFilter(List<Task> tasks, String query) {
    final lowerQuery = query.toLowerCase();
    return tasks.where((task) {
      return task.title.toLowerCase().contains(lowerQuery) ||
          (task.description?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  List<Task> _applyTaskTypeFilter(List<Task> tasks, List<TaskType> types) {
    return tasks.where((t) => types.contains(t.type)).toList();
  }

  List<Task> _applyPriorityFilter(
    List<Task> tasks,
    List<TaskPriority> priorities,
  ) {
    return tasks.where((t) => priorities.contains(t.priority)).toList();
  }
}
```

**BENEFITS:**
- ✅ Adding new filter = Add new strategy class (no modification)
- ✅ Testable: Each strategy can be tested independently
- ✅ Reusable: Strategies can be composed
- ✅ SOLID: Follows OCP + SRP

**Example - Adding New Filter:**
```dart
// NEW FILTER: Tasks this week
class ThisWeekTasksFilterStrategy implements TaskFilterStrategy {
  @override
  List<Task> filter(List<Task> tasks) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return tasks.where((task) {
      if (task.scheduledFor == null) return false;
      return task.scheduledFor!.isAfter(startOfWeek) &&
          task.scheduledFor!.isBefore(endOfWeek);
    }).toList();
  }
}

// ✅ NO MODIFICATION to existing code - just register!
registry.registerStrategy(
  TasksFilterType.thisWeek,
  ThisWeekTasksFilterStrategy(),
);
```

---

### Violation 4: PlantTaskGenerator likely uses switch

**Location:** `lib/features/plants/domain/services/plant_task_generator.dart` (need to verify)

**Suspected Pattern:**

```dart
class PlantTaskGenerator {
  List<PlantTask> generateTasksForPlant(Plant plant) {
    final tasks = <PlantTask>[];

    // ❌ SUSPECTED SWITCH STATEMENT
    for (final careType in plant.config.activeCareTypes) {
      switch (careType) {
        case CareType.watering:
          tasks.add(_createWateringTask(plant));
          break;
        case CareType.fertilizing:
          tasks.add(_createFertilizingTask(plant));
          break;
        case CareType.pruning:
          tasks.add(_createPruningTask(plant));
          break;
        case CareType.repotting:
          tasks.add(_createRepottingTask(plant));
          break;
        case CareType.pestControl:
          tasks.add(_createPestControlTask(plant));
          break;
      }
    }

    return tasks;
  }

  PlantTask _createWateringTask(Plant plant) { /* ... */ }
  PlantTask _createFertilizingTask(Plant plant) { /* ... */ }
  PlantTask _createPruningTask(Plant plant) { /* ... */ }
  PlantTask _createRepottingTask(Plant plant) { /* ... */ }
  PlantTask _createPestControlTask(Plant plant) { /* ... */ }
}
```

#### GOOD CODE (Strategy Pattern):

```dart
// 1. TASK GENERATION STRATEGY INTERFACE
abstract class PlantTaskGenerationStrategy {
  PlantTask generate(Plant plant);
  CareType get careType;
}

// 2. CONCRETE STRATEGIES

@injectable
class WateringTaskGenerationStrategy implements PlantTaskGenerationStrategy {
  @override
  CareType get careType => CareType.watering;

  @override
  PlantTask generate(Plant plant) {
    final config = plant.config!;
    final wateringInterval = config.wateringInterval ?? 7;

    return PlantTask(
      id: _generateId(),
      plantId: plant.id,
      type: TaskType.watering,
      title: 'Regar ${plant.name}',
      description: 'Regar a cada $wateringInterval dias',
      recurrenceInterval: wateringInterval,
      priority: TaskPriority.medium,
      userId: plant.userId,
      moduleName: 'plantis',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();
}

@injectable
class FertilizingTaskGenerationStrategy implements PlantTaskGenerationStrategy {
  @override
  CareType get careType => CareType.fertilizing;

  @override
  PlantTask generate(Plant plant) {
    final config = plant.config!;
    final fertilizingInterval = config.fertilizingInterval ?? 30;

    return PlantTask(
      id: _generateId(),
      plantId: plant.id,
      type: TaskType.fertilizing,
      title: 'Fertilizar ${plant.name}',
      description: 'Fertilizar a cada $fertilizingInterval dias',
      recurrenceInterval: fertilizingInterval,
      priority: TaskPriority.low,
      userId: plant.userId,
      moduleName: 'plantis',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();
}

@injectable
class PruningTaskGenerationStrategy implements PlantTaskGenerationStrategy {
  @override
  CareType get careType => CareType.pruning;

  @override
  PlantTask generate(Plant plant) {
    final config = plant.config!;
    final pruningInterval = config.pruningInterval ?? 90;

    return PlantTask(
      id: _generateId(),
      plantId: plant.id,
      type: TaskType.pruning,
      title: 'Podar ${plant.name}',
      description: 'Podar a cada $pruningInterval dias',
      recurrenceInterval: pruningInterval,
      priority: TaskPriority.low,
      userId: plant.userId,
      moduleName: 'plantis',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();
}

// ... More strategies for repotting, pestControl, etc.

// 3. REGISTRY
@injectable
class PlantTaskGenerationStrategyRegistry {
  final Map<CareType, PlantTaskGenerationStrategy> _strategies;

  PlantTaskGenerationStrategyRegistry(
    // ✅ Inject all strategies via GetIt
    WateringTaskGenerationStrategy wateringStrategy,
    FertilizingTaskGenerationStrategy fertilizingStrategy,
    PruningTaskGenerationStrategy pruningStrategy,
    // ... inject more
  ) : _strategies = {
          CareType.watering: wateringStrategy,
          CareType.fertilizing: fertilizingStrategy,
          CareType.pruning: pruningStrategy,
          // ... register more
        };

  PlantTaskGenerationStrategy? getStrategy(CareType careType) {
    return _strategies[careType];
  }

  void registerStrategy(PlantTaskGenerationStrategy strategy) {
    _strategies[strategy.careType] = strategy;
  }
}

// 4. REFACTORED GENERATOR
@injectable
class PlantTaskGenerator {
  final PlantTaskGenerationStrategyRegistry _strategyRegistry;

  PlantTaskGenerator(this._strategyRegistry);

  List<PlantTask> generateTasksForPlant(Plant plant) {
    if (plant.config == null) return [];

    final tasks = <PlantTask>[];

    // ✅ NO SWITCH - Uses Strategy
    for (final careType in plant.config!.activeCareTypes) {
      final strategy = _strategyRegistry.getStrategy(careType);
      if (strategy != null) {
        tasks.add(strategy.generate(plant));
      }
    }

    return tasks;
  }
}
```

**BENEFITS:**
- ✅ Adding new care type = Add new strategy class
- ✅ Each strategy independently testable
- ✅ Easy to customize per plant type
- ✅ Follows SRP + OCP

---

## ISP VIOLATIONS

### Violation 5: Fat PlantsRepository Interface

**Location:** `lib/features/plants/domain/repositories/plants_repository.dart`

#### BAD CODE (Current):

```dart
// ❌ FAT INTERFACE - Forces clients to depend on methods they don't use
abstract class PlantsRepository {
  // READ operations (6 methods)
  Future<Either<Failure, List<Plant>>> getPlants();
  Future<Either<Failure, Plant>> getPlantById(String id);
  Future<Either<Failure, List<Plant>>> searchPlants(String query);
  Future<Either<Failure, List<Plant>>> getPlantsBySpace(String spaceId);
  Future<Either<Failure, int>> getPlantsCount();
  Stream<List<Plant>> watchPlants();

  // WRITE operations (3 methods)
  Future<Either<Failure, Plant>> addPlant(Plant plant);
  Future<Either<Failure, Plant>> updatePlant(Plant plant);
  Future<Either<Failure, void>> deletePlant(String id);

  // SYNC operations (1 method)
  Future<Either<Failure, void>> syncPendingChanges();
}

// ❌ PROBLEM: Read-only use case forced to depend on write/sync methods
@injectable
class GetPlantsUseCase implements UseCase<List<Plant>, NoParams> {
  final PlantsRepository repository; // ❌ Depends on ALL 10 methods

  const GetPlantsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Plant>>> call(NoParams params) {
    return repository.getPlants(); // ✅ Only uses 1 method
  }
}
```

#### GOOD CODE (Segregated Interfaces):

```dart
// 1. SEGREGATED INTERFACES

/// Read-only operations for plants
abstract class PlantsReadRepository {
  Future<Either<Failure, List<Plant>>> getPlants();
  Future<Either<Failure, Plant>> getPlantById(String id);
  Future<Either<Failure, List<Plant>>> searchPlants(String query);
  Future<Either<Failure, List<Plant>>> getPlantsBySpace(String spaceId);
  Future<Either<Failure, int>> getPlantsCount();
  Stream<List<Plant>> watchPlants();
}

/// Write operations for plants
abstract class PlantsWriteRepository {
  Future<Either<Failure, Plant>> addPlant(Plant plant);
  Future<Either<Failure, Plant>> updatePlant(Plant plant);
  Future<Either<Failure, void>> deletePlant(String id);
}

/// Sync operations for plants
abstract class PlantsSyncRepository {
  Future<Either<Failure, void>> syncPendingChanges();
}

// 2. IMPLEMENTATION (Implements all three)

@LazySingleton(as: PlantsReadRepository)
@LazySingleton(as: PlantsWriteRepository)
@LazySingleton(as: PlantsSyncRepository)
class PlantsRepositoryImpl
    implements
        PlantsReadRepository,
        PlantsWriteRepository,
        PlantsSyncRepository {
  final PlantsLocalDatasource localDatasource;
  final PlantsRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;
  final IAuthRepository authService;

  PlantsRepositoryImpl({
    required this.localDatasource,
    required this.remoteDatasource,
    required this.networkInfo,
    required this.authService,
  });

  // READ methods
  @override
  Future<Either<Failure, List<Plant>>> getPlants() async { /* ... */ }

  @override
  Future<Either<Failure, Plant>> getPlantById(String id) async { /* ... */ }

  @override
  Future<Either<Failure, List<Plant>>> searchPlants(String query) async { /* ... */ }

  @override
  Future<Either<Failure, List<Plant>>> getPlantsBySpace(String spaceId) async { /* ... */ }

  @override
  Future<Either<Failure, int>> getPlantsCount() async { /* ... */ }

  @override
  Stream<List<Plant>> watchPlants() { /* ... */ }

  // WRITE methods
  @override
  Future<Either<Failure, Plant>> addPlant(Plant plant) async { /* ... */ }

  @override
  Future<Either<Failure, Plant>> updatePlant(Plant plant) async { /* ... */ }

  @override
  Future<Either<Failure, void>> deletePlant(String id) async { /* ... */ }

  // SYNC methods
  @override
  Future<Either<Failure, void>> syncPendingChanges() async { /* ... */ }
}

// 3. USE CASES NOW DEPEND ON SPECIFIC INTERFACES

// ✅ Read-only use case depends ONLY on read methods
@injectable
class GetPlantsUseCase implements UseCase<List<Plant>, NoParams> {
  final PlantsReadRepository repository; // ✅ Only 6 read methods visible

  const GetPlantsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Plant>>> call(NoParams params) {
    return repository.getPlants();
  }
}

// ✅ Search use case depends ONLY on read methods
@injectable
class SearchPlantsUseCase implements UseCase<List<Plant>, SearchPlantsParams> {
  final PlantsReadRepository repository; // ✅ Only read methods

  const SearchPlantsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Plant>>> call(SearchPlantsParams params) {
    if (params.query.trim().isEmpty) {
      return repository.getPlants();
    }
    return repository.searchPlants(params.query);
  }
}

// ✅ Write use case depends ONLY on write methods
@injectable
class AddPlantUseCase implements UseCase<Plant, AddPlantParams> {
  final PlantsWriteRepository repository; // ✅ Only 3 write methods visible

  AddPlantUseCase(this.repository);

  @override
  Future<Either<Failure, Plant>> call(AddPlantParams params) async {
    // Validation...
    final plant = Plant(...);
    return repository.addPlant(plant);
  }
}

// ✅ Delete use case depends ONLY on write methods
@injectable
class DeletePlantUseCase implements UseCase<void, String> {
  final PlantsWriteRepository repository; // ✅ Only write methods

  const DeletePlantUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) {
    return repository.deletePlant(id);
  }
}

// ✅ Sync coordinator depends ONLY on sync methods
@injectable
class PlantsSyncCoordinator {
  final PlantsSyncRepository repository; // ✅ Only sync methods

  PlantsSyncCoordinator(this.repository);

  Future<void> syncAll() async {
    await repository.syncPendingChanges();
  }
}

// 4. DI CONFIGURATION (GetIt + Injectable)

// injectable.config.dart (auto-generated)
// Registers PlantsRepositoryImpl as:
// - PlantsReadRepository
// - PlantsWriteRepository
// - PlantsSyncRepository
```

**BENEFITS:**
- ✅ Clients depend only on methods they use (ISP)
- ✅ Clearer separation of concerns
- ✅ Easier to test (mock only needed methods)
- ✅ Better API discoverability

**Same pattern applies to:**
- TasksRepository → TasksReadRepository, TasksWriteRepository, TasksSyncRepository
- SettingsRepository → SettingsReadRepository, SettingsWriteRepository

---

## DIP VIOLATIONS

### Violation 6: Direct Instantiation in Notifier

**Location:** `lib/features/tasks/presentation/notifiers/tasks_notifier.dart:55`

#### BAD CODE:

```dart
@riverpod
class TasksNotifier extends _$TasksNotifier {
  late final TaskNotificationService _notificationService;

  @override
  Future<TasksState> build() async {
    // ... other dependencies injected via ref.read()

    // ❌ DIRECT INSTANTIATION - Violates DIP
    _notificationService = TaskNotificationService();

    await _initializeNotificationService();
    // ...
  }
}
```

**Problem:** Depends on concrete class, not abstraction. Cannot mock for testing.

#### GOOD CODE:

```dart
// 1. CREATE PROVIDER FOR SERVICE

@riverpod
TaskNotificationService taskNotificationService(
  TaskNotificationServiceRef ref,
) {
  return getIt<TaskNotificationService>();
}

// 2. INJECT VIA PROVIDER

@riverpod
class TasksNotifier extends _$TasksNotifier {
  late final TaskNotificationService _notificationService;

  @override
  Future<TasksState> build() async {
    // ... other dependencies

    // ✅ INJECT VIA PROVIDER - Follows DIP
    _notificationService = ref.read(taskNotificationServiceProvider);

    await _initializeNotificationService();
    // ...
  }
}

// 3. REGISTER IN GetIt (injection.dart)

@module
abstract class CoreServicesModule {
  @lazySingleton
  TaskNotificationService get taskNotificationService =>
      TaskNotificationService();
}
```

**BENEFITS:**
- ✅ Testable (can provide mock via ProviderScope)
- ✅ Follows DIP (depends on abstraction via provider)
- ✅ Consistent with other dependencies

**Testing:**
```dart
void main() {
  testWidgets('TasksNotifier loads tasks', (tester) async {
    final mockNotificationService = MockTaskNotificationService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taskNotificationServiceProvider.overrideWithValue(
            mockNotificationService,
          ),
        ],
        child: MyApp(),
      ),
    );

    // Test with mocked service
  });
}
```

---

## REFACTORING CHEAT SHEET

### When to Apply Each Pattern

| Smell | Pattern | Example |
|-------|---------|---------|
| God Object (>500 lines) | **Extract Service** | TasksNotifier → TaskNotificationManager |
| Multiple responsibilities | **SRP - Single Responsibility** | SettingsNotifier → 4 specialized notifiers |
| Switch statements on types | **Strategy Pattern** | TaskFilterService → TaskFilterStrategy |
| Fat interface (>8 methods) | **ISP - Interface Segregation** | PlantsRepository → Read/Write/Sync |
| Direct instantiation | **DIP - Dependency Injection** | `new Service()` → `ref.read(serviceProvider)` |
| Hardcoded types | **Strategy + Registry** | PlantTaskGenerator → TaskGenerationStrategy |
| Difficult to test | **Extract Interface** | Concrete dependency → Abstract interface |
| Repeated code | **Extract Method/Service** | Common logic → Reusable service |

---

### Refactoring Steps Template

#### 1. Extract Service (For God Objects)

```dart
// BEFORE: God object with 20 methods
class XyzNotifier {
  // 20 methods mixing concerns
}

// AFTER: Focused notifier + specialized service
@riverpod
class XyzNotifier {
  // 5 methods - state management only
  Future<void> performAction() async {
    final result = await ref.read(xyzServiceProvider).doWork();
    _updateState(result);
  }
}

@injectable
class XyzService {
  // 15 methods - business logic
  Future<Either<Failure, Result>> doWork() async { /* ... */ }
}
```

#### 2. Strategy Pattern (For Switch Statements)

```dart
// BEFORE: Switch on type
switch (type) {
  case TypeA: return handleA();
  case TypeB: return handleB();
}

// AFTER: Strategy registry
abstract class XyzStrategy {
  Result handle();
}

class StrategyA implements XyzStrategy {
  @override
  Result handle() { /* ... */ }
}

@injectable
class StrategyRegistry {
  final Map<Type, XyzStrategy> _strategies = {
    Type.a: StrategyA(),
    Type.b: StrategyB(),
  };

  XyzStrategy getStrategy(Type type) => _strategies[type]!;
}
```

#### 3. Interface Segregation

```dart
// BEFORE: Fat interface
abstract class XyzRepository {
  // 15 mixed methods
}

// AFTER: Segregated interfaces
abstract class XyzReadRepository {
  // 8 read methods
}

abstract class XyzWriteRepository {
  // 5 write methods
}

abstract class XyzSyncRepository {
  // 2 sync methods
}

// Implementation
class XyzRepositoryImpl implements
    XyzReadRepository, XyzWriteRepository, XyzSyncRepository {
  // Implement all
}
```

---

## ESTIMATED REFACTORING TIMES

| Refactoring | Complexity | Time |
|-------------|-----------|------|
| Extract single service | Low | 2-3h |
| Break god object (5+ services) | High | 10-15h |
| Implement strategy pattern | Medium | 4-6h |
| Segregate fat interface | Low | 2-3h |
| Replace switch with strategy | Medium | 3-4h |
| Add DI provider | Low | 30min |
| Create interface for concrete class | Low | 1h |

---

## TESTING IMPACT

### Before Refactoring:
- ❌ TasksNotifier: Hard to test (god object)
- ❌ TaskFilterService: Hard to test (switch statements)
- ❌ Direct instantiation: Cannot mock

### After Refactoring:
- ✅ Focused notifiers: Easy to test
- ✅ Strategy pattern: Each strategy independently testable
- ✅ DI everywhere: Full mocking capability

**Example Test:**
```dart
void main() {
  group('TaskFilterService with Strategy', () {
    late TaskFilterStrategyRegistry registry;
    late TaskFilterService service;

    setUp(() {
      registry = TaskFilterStrategyRegistry();
      service = TaskFilterService(registry);
    });

    test('applies pending filter correctly', () {
      // Arrange
      final tasks = [
        Task(id: '1', status: TaskStatus.pending),
        Task(id: '2', status: TaskStatus.completed),
      ];

      // Act
      final result = service.applyFilters(
        tasks,
        TasksFilterType.pending,
        '',
        null,
        null,
        null,
      );

      // Assert
      expect(result.length, 1);
      expect(result.first.id, '1');
    });

    test('can register custom filter strategy', () {
      // Arrange
      final customStrategy = MockCustomFilterStrategy();

      // Act
      registry.registerStrategy(TasksFilterType.custom, customStrategy);

      // Assert
      expect(
        registry.getStrategy(TasksFilterType.custom),
        customStrategy,
      );
    });
  });
}
```

---

**END OF CODE EXAMPLES DOCUMENT**

Generated by: Code Intelligence Agent
Focus: Concrete violations with refactoring patterns
