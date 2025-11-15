# 🔧 APP-PLANTIS SOLID Analysis - Code Examples

## Issue #1: TasksNotifier - God Object (SRP Violation)

### Current Problem (728 lines)
```dart
// lib/features/tasks/presentation/notifiers/tasks_notifier.dart
@riverpod
class TasksNotifier extends _$TasksNotifier {
  // RESPONSIBILITY 1: State management
  Future<TasksState> build() async { /* ... */ }

  // RESPONSIBILITY 2: Authentication listening
  void _initializeAuthListener() { /* ... */ }

  // RESPONSIBILITY 3: Ownership validation
  task_entity.Task _getTaskWithOwnershipValidation(String taskId) { /* ... */ }

  // RESPONSIBILITY 4: State updates
  void _updateState(TasksState Function(TasksState current) update) { /* ... */ }

  // RESPONSIBILITY 5: Loading operation tracking
  void _startTaskOperation(String taskId, {String? message}) { /* ... */ }
  void _completeTaskLoadingOperation(String taskId) { /* ... */ }
  void _startGlobalOperation(TaskLoadingOperation operation, {String? message}) { /* ... */ }
  void _completeGlobalOperation(TaskLoadingOperation operation) { /* ... */ }

  // RESPONSIBILITY 6: Task loading
  Future<void> loadTasks() async { /* ... */ }

  // RESPONSIBILITY 7: Task creation
  Future<bool> addTask(task_entity.Task task) async { /* ... */ }

  // RESPONSIBILITY 8: Task completion
  Future<bool> completeTask(String taskId, {String? notes}) async { /* ... */ }

  // RESPONSIBILITY 9: Search
  void searchTasks(String query) { /* ... */ }

  // RESPONSIBILITY 10: Filtering
  void setFilter(TasksFilterType filter, {String? plantId}) { /* ... */ }
  void setAdvancedFilters({...}) { /* ... */ }

  // RESPONSIBILITY 11: Refresh
  Future<void> refresh() async { /* ... */ }

  // RESPONSIBILITY 12: Error handling
  void clearError() { /* ... */ }

  // RESPONSIBILITY 13: Notification initialization
  Future<void> _initializeNotificationService() async { /* ... */ }

  // RESPONSIBILITY 14: Notification permissions
  Future<NotificationPermissionStatus> getNotificationPermissionStatus() async { /* ... */ }
  Future<bool> requestNotificationPermissions() async { /* ... */ }
  Future<bool> openNotificationSettings() async { /* ... */ }
  Future<int> getScheduledNotificationsCount() async { /* ... */ }

  // RESPONSIBILITY 15: Priority getters
  List<task_entity.Task> get highPriorityTasks { /* ... */ }
  List<task_entity.Task> get mediumPriorityTasks { /* ... */ }
  List<task_entity.Task> get lowPriorityTasks { /* ... */ }

  // RESPONSIBILITY 16: Network failure detection
  bool _isNetworkFailure(Failure failure) { /* ... */ }
}
```

### Recommended Solution: Extract Specialized Services

#### Service 1: TaskNotificationManager
```dart
@injectable
class TaskNotificationManager {
  final TaskNotificationService _notificationService;

  Future<void> initialize() async {
    _notificationService.initialize();
  }

  Future<NotificationPermissionStatus> getPermissionStatus() async {
    return _notificationService.getPermissionStatus();
  }

  Future<bool> requestPermissions() async {
    return _notificationService.requestPermissions();
  }

  Future<bool> openSettings() async {
    return _notificationService.openAppSettings();
  }

  Future<int> getScheduledCount() async {
    return _notificationService.getScheduledNotificationsCount();
  }

  void scheduleTaskNotification(Task task) {
    // Schedule notification
  }

  void cancelTaskNotifications(String taskId) {
    // Cancel notifications
  }
}
```

#### Service 2: TaskFilterService
```dart
@injectable
class TaskFilterService {
  List<Task> applyFilters(
    List<Task> tasks,
    TasksFilterType filter,
    String searchQuery,
    String? plantId,
    List<TaskType>? taskTypes,
    List<TaskPriority>? priorities,
  ) {
    // Apply all filters
  }

  List<Task> getHighPriorityTasks(List<Task> tasks) {
    return tasks.where((t) => t.priority == TaskPriority.high).toList();
  }

  List<Task> getMediumPriorityTasks(List<Task> tasks) {
    return tasks.where((t) => t.priority == TaskPriority.medium).toList();
  }

  List<Task> getLowPriorityTasks(List<Task> tasks) {
    return tasks.where((t) => t.priority == TaskPriority.low).toList();
  }
}
```

#### Service 3: TasksAuthCoordinator
```dart
@injectable
class TasksAuthCoordinator {
  final IAuthRepository _authRepository;

  Stream<UserEntity?> get userStream => _authRepository.userStream;

  Task validateOwnershipOrThrow(Task task) {
    final currentUserId = _authRepository.currentUser?.id;
    if (task.ownerId != currentUserId) {
      throw UnauthorizedFailure('User is not task owner');
    }
    return task;
  }
}
```

#### Service 4: TasksLoadingStateManager
```dart
@injectable
class TasksLoadingStateManager {
  final Map<String, TaskLoadingOperation> _taskOperations = {};
  final Map<TaskLoadingOperation, bool> _globalOperations = {};

  void startTaskOperation(String taskId, {String? message}) {
    _taskOperations[taskId] = TaskLoadingOperation(
      taskId: taskId,
      message: message,
      startTime: DateTime.now(),
    );
  }

  void completeTaskOperation(String taskId) {
    _taskOperations.remove(taskId);
  }

  void startGlobalOperation(TaskLoadingOperation operation, {String? message}) {
    _globalOperations[operation] = true;
  }

  void completeGlobalOperation(TaskLoadingOperation operation) {
    _globalOperations.remove(operation);
  }
}
```

#### Refactored TasksNotifier (Now <300 lines)
```dart
@riverpod
class TasksNotifier extends _$TasksNotifier {
  late TaskNotificationManager _notificationManager;
  late TaskFilterService _filterService;
  late TasksAuthCoordinator _authCoordinator;
  late TasksLoadingStateManager _loadingStateManager;

  @override
  Future<TasksState> build() async {
    // Initialize managers
    _notificationManager = ref.read(taskNotificationManagerProvider);
    _filterService = ref.read(taskFilterServiceProvider);
    _authCoordinator = ref.read(tasksAuthCoordinatorProvider);
    _loadingStateManager = ref.read(tasksLoadingStateManagerProvider);

    // Initialize auth listener
    _initializeAuthListener();

    // Load initial tasks
    return await _loadTasksInternal();
  }

  // ONLY state management logic remains
  Future<void> loadTasks() async {
    _loadingStateManager.startGlobalOperation(TaskLoadingOperation.fetch);
    try {
      final repository = ref.read(tasksRepositoryProvider);
      final result = await repository.getTasks();

      result.fold(
        (failure) => _updateState((s) => s.copyWith(failure: failure)),
        (tasks) => _updateState((s) => s.copyWith(tasks: tasks)),
      );
    } finally {
      _loadingStateManager.completeGlobalOperation(TaskLoadingOperation.fetch);
    }
  }

  Future<bool> addTask(task_entity.Task task) async {
    _loadingStateManager.startGlobalOperation(TaskLoadingOperation.create);
    try {
      final repository = ref.read(tasksRepositoryProvider);
      final result = await repository.addTask(task);

      return result.fold(
        (failure) {
          _updateState((s) => s.copyWith(failure: failure));
          return false;
        },
        (newTask) {
          _updateState((s) => s.copyWith(
            tasks: [...s.tasks, newTask],
          ));
          _notificationManager.scheduleTaskNotification(newTask);
          return true;
        },
      );
    } finally {
      _loadingStateManager.completeGlobalOperation(TaskLoadingOperation.create);
    }
  }

  void setFilter(TasksFilterType filter, {String? plantId}) {
    _updateState((s) => s.copyWith(
      filter: filter,
      plantId: plantId,
    ));
  }

  // Delegate to services
  List<Task> get highPriorityTasks {
    return _filterService.getHighPriorityTasks(state.requireValue.tasks);
  }

  Future<bool> requestNotificationPermissions() async {
    return _notificationManager.requestPermissions();
  }

  // Private helpers
  void _updateState(TasksState Function(TasksState current) update) {
    state = AsyncValue.data(update(state.requireValue));
  }

  void _initializeAuthListener() {
    _authCoordinator.userStream.listen((user) {
      if (user == null) {
        _updateState((s) => s.copyWith(tasks: []));
      }
    });
  }

  Future<TasksState> _loadTasksInternal() async {
    final repository = ref.read(tasksRepositoryProvider);
    final result = await repository.getTasks();

    return result.fold(
      (failure) => TasksState.initial().copyWith(failure: failure),
      (tasks) => TasksState.initial().copyWith(tasks: tasks),
    );
  }
}
```

---

## Issue #2: Task Filtering - Switch Statement (OCP Violation)

### Current Problem (Hardcoded)
```dart
// lib/features/tasks/domain/services/task_filter_service.dart
List<Task> applyFilters(List<Task> tasks, TasksFilterType filter, String? plantId) {
  switch (filter) {  // ❌ Adding new filter type requires modifying this method
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
      return tasks.where((t) => t.plantId == plantId).toList();
  }
}
```

### Solution: Strategy Pattern (Open/Closed)
```dart
// Abstract strategy interface
abstract class TaskFilterStrategy {
  List<Task> filter(List<Task> tasks, {String? plantId});
  String get filterName;
}

// Concrete strategies
class AllTasksFilter implements TaskFilterStrategy {
  @override
  String get filterName => 'All';

  @override
  List<Task> filter(List<Task> tasks, {String? plantId}) => tasks;
}

class PendingTasksFilter implements TaskFilterStrategy {
  @override
  String get filterName => 'Pending';

  @override
  List<Task> filter(List<Task> tasks, {String? plantId}) {
    return tasks.where((t) => t.status == TaskStatus.pending).toList();
  }
}

class CompletedTasksFilter implements TaskFilterStrategy {
  @override
  String get filterName => 'Completed';

  @override
  List<Task> filter(List<Task> tasks, {String? plantId}) {
    return tasks.where((t) => t.status == TaskStatus.completed).toList();
  }
}

class OverdueTasksFilter implements TaskFilterStrategy {
  @override
  String get filterName => 'Overdue';

  @override
  List<Task> filter(List<Task> tasks, {String? plantId}) {
    return tasks.where((t) => t.isOverdue).toList();
  }
}

class TodayTasksFilter implements TaskFilterStrategy {
  @override
  String get filterName => 'Today';

  @override
  List<Task> filter(List<Task> tasks, {String? plantId}) {
    return tasks.where((t) => _isToday(t.scheduledFor)).toList();
  }
}

class ByPlantTasksFilter implements TaskFilterStrategy {
  @override
  String get filterName => 'By Plant';

  @override
  List<Task> filter(List<Task> tasks, {String? plantId}) {
    if (plantId == null) return [];
    return tasks.where((t) => t.plantId == plantId).toList();
  }
}

// ✅ Refactored service - now extensible
@injectable
class TaskFilterService {
  final Map<TasksFilterType, TaskFilterStrategy> _strategies = {
    TasksFilterType.all: AllTasksFilter(),
    TasksFilterType.pending: PendingTasksFilter(),
    TasksFilterType.completed: CompletedTasksFilter(),
    TasksFilterType.overdue: OverdueTasksFilter(),
    TasksFilterType.today: TodayTasksFilter(),
    TasksFilterType.byPlant: ByPlantTasksFilter(),
  };

  // ✅ No switch statements - just lookup
  List<Task> applyFilters(
    List<Task> tasks,
    TasksFilterType filter, {
    String? plantId,
  }) {
    final strategy = _strategies[filter];
    if (strategy == null) {
      throw UnknownTaskFilterException('Unknown filter: $filter');
    }
    return strategy.filter(tasks, plantId: plantId);
  }

  // ✅ Adding new filter type: just create new strategy + register
  void registerCustomFilter(TasksFilterType type, TaskFilterStrategy strategy) {
    _strategies[type] = strategy;
  }
}
```

**Benefit:** To add a new filter type in the future, just:
1. Create new `class MyCustomFilter implements TaskFilterStrategy`
2. Register it: `filterService.registerCustomFilter(type, MyCustomFilter())`
3. NO changes to existing code ✅

---

## Issue #3: Fat Repository Interface (ISP Violation)

### Current Problem (11 methods, mixed concerns)
```dart
// lib/features/tasks/domain/repositories/tasks_repository.dart
abstract class TasksRepository {
  // READ operations (use cases that need read)
  Future<Either<Failure, List<Task>>> getTasks();
  Future<Either<Failure, Task>> getTaskById(String id);
  Future<Either<Failure, List<Task>>> getTasksByPlant(String plantId);

  // WRITE operations (use cases that need write)
  Future<Either<Failure, Task>> addTask(Task task);
  Future<Either<Failure, Task>> updateTask(Task task);
  Future<Either<Failure, void>> deleteTask(String id);
  Future<Either<Failure, Task>> completeTask(String id, String? notes);

  // SYNC operations (use cases that need sync)
  Future<Either<Failure, void>> syncPendingChanges();
  Future<Either<Failure, void>> resolveConflict(ConflictData conflict);

  // WATCH operations
  Stream<List<Task>> watchTasks();
}

// Problem: GetTasksUseCase depends on all 11 methods but only uses 1-2
class GetTasksUseCase {
  final TasksRepository repository; // ❌ Can access methods it shouldn't

  Future<Either<Failure, List<Task>>> call() {
    return repository.getTasks(); // Only uses this method
    // But could accidentally call: repository.deleteTask() ❌
  }
}
```

### Solution: Segregate by Responsibility (ISP)
```dart
// ✅ SEGREGATE: Read-only interface
abstract class TasksReadRepository {
  Future<Either<Failure, List<Task>>> getTasks();
  Future<Either<Failure, Task>> getTaskById(String id);
  Future<Either<Failure, List<Task>>> getTasksByPlant(String plantId);
  Stream<List<Task>> watchTasks();
}

// ✅ SEGREGATE: Write-only interface
abstract class TasksWriteRepository {
  Future<Either<Failure, Task>> addTask(Task task);
  Future<Either<Failure, Task>> updateTask(Task task);
  Future<Either<Failure, void>> deleteTask(String id);
  Future<Either<Failure, Task>> completeTask(String id, String? notes);
}

// ✅ SEGREGATE: Sync-only interface
abstract class TasksSyncRepository {
  Future<Either<Failure, void>> syncPendingChanges();
  Future<Either<Failure, void>> resolveConflict(ConflictData conflict);
}

// ✅ Implementation combines all (when needed)
@LazySingleton(as: TasksReadRepository)
@LazySingleton(as: TasksWriteRepository)
@LazySingleton(as: TasksSyncRepository)
class TasksRepositoryImpl
    implements TasksReadRepository, TasksWriteRepository, TasksSyncRepository {
  final TasksLocalDatasource _localDatasource;
  final TasksRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;

  // Read operations
  @override
  Future<Either<Failure, List<Task>>> getTasks() async {
    if (!_networkInfo.isConnected) {
      return _localDatasource.getTasks();
    }
    // ... sync logic
  }

  // Write operations
  @override
  Future<Either<Failure, Task>> addTask(Task task) async {
    // ... add logic
  }

  // Sync operations
  @override
  Future<Either<Failure, void>> syncPendingChanges() async {
    // ... sync logic
  }
}

// ✅ Use cases now depend ONLY on what they need
class GetTasksUseCase implements UseCase<List<Task>, NoParams> {
  final TasksReadRepository repository; // ✅ Only read methods visible

  GetTasksUseCase(this.repository);

  @override
  Future<Either<Failure, List<Task>>> call(NoParams params) {
    return repository.getTasks();
    // Compile error if trying to call: repository.deleteTask() ❌
  }
}

class AddTaskUseCase implements UseCase<Task, AddTaskParams> {
  final TasksWriteRepository repository; // ✅ Only write methods visible
  final TasksReadRepository readRepository; // If also needs to read

  AddTaskUseCase(this.repository, this.readRepository);

  @override
  Future<Either<Failure, Task>> call(AddTaskParams params) async {
    return repository.addTask(params.task);
    // Can't accidentally call: repository.syncPendingChanges() ❌
  }
}

class SyncTasksUseCase implements UseCase<void, NoParams> {
  final TasksSyncRepository repository; // ✅ Only sync methods visible

  SyncTasksUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.syncPendingChanges();
  }
}
```

**Benefit:** 
- Each use case depends ONLY on needed methods ✅
- Compiler enforces ISP at compile-time ✅
- Can't accidentally call wrong method ✅

---

## Issue #4: SYNC Feature - Incomplete Implementation

### Current State (BROKEN)
```
lib/features/sync/presentation/notifiers/
└── conflict_notifier.g.dart  ← Only generated file!

Missing:
❌ Domain layer (entities, repositories, use cases)
❌ Data layer (datasources, models, repositories)
❌ Service layer (sync coordinator, conflict resolver)
```

### Recommended Complete Implementation

#### 1. Domain Layer: Entities & Failures
```dart
// lib/features/sync/domain/entities/sync_event.dart
class SyncEvent {
  final String id;
  final SyncEventType type;
  final String entityType;
  final String entityId;
  final DateTime timestamp;
  final Map<String, dynamic> changeData;

  SyncEvent({
    required this.id,
    required this.type,
    required this.entityType,
    required this.entityId,
    required this.timestamp,
    required this.changeData,
  });
}

enum SyncEventType { create, update, delete }

// lib/features/sync/domain/failures/sync_failures.dart
abstract class SyncFailure extends Failure {
  String get message;
}

class ConflictDetectedFailure extends SyncFailure {
  final List<ConflictData> conflicts;

  ConflictDetectedFailure(this.conflicts);

  @override
  String get message => 'Sync conflicts detected: ${conflicts.length}';
}

class SyncTimeoutFailure extends SyncFailure {
  @override
  String get message => 'Sync operation timed out';
}

class NetworkFailure extends SyncFailure {
  @override
  String get message => 'Network unavailable for sync';
}
```

#### 2. Domain Layer: Sync Strategy
```dart
// lib/features/sync/domain/services/conflict_resolution_strategy.dart
abstract class ConflictResolutionStrategy {
  Future<Either<SyncFailure, ResolvedConflict>> resolve(ConflictData conflict);
}

class ClientWinsStrategy implements ConflictResolutionStrategy {
  @override
  Future<Either<SyncFailure, ResolvedConflict>> resolve(ConflictData conflict) async {
    // Client version always wins
    return Right(ResolvedConflict(
      entityId: conflict.entityId,
      resolution: conflict.clientVersion,
      timestamp: DateTime.now(),
    ));
  }
}

class ServerWinsStrategy implements ConflictResolutionStrategy {
  @override
  Future<Either<SyncFailure, ResolvedConflict>> resolve(ConflictData conflict) async {
    // Server version always wins
    return Right(ResolvedConflict(
      entityId: conflict.entityId,
      resolution: conflict.serverVersion,
      timestamp: DateTime.now(),
    ));
  }
}

class MergeStrategy implements ConflictResolutionStrategy {
  @override
  Future<Either<SyncFailure, ResolvedConflict>> resolve(ConflictData conflict) async {
    // Intelligent merge of client and server changes
    final merged = _merge(conflict.clientVersion, conflict.serverVersion);
    return Right(ResolvedConflict(
      entityId: conflict.entityId,
      resolution: merged,
      timestamp: DateTime.now(),
    ));
  }

  dynamic _merge(dynamic clientVersion, dynamic serverVersion) {
    // Smart merge logic
    return serverVersion; // TODO: implement intelligent merge
  }
}
```

#### 3. Data Layer: Sync Coordinator
```dart
// lib/features/sync/data/services/sync_coordinator.dart
@injectable
class SyncCoordinator {
  final PlantsRepository _plantsRepository;
  final TasksRepository _tasksRepository;
  final SyncQueueRepository _syncQueueRepository;
  final NetworkInfo _networkInfo;
  final ConflictResolutionStrategy _conflictStrategy;

  Future<Either<SyncFailure, void>> synchronizeAll() async {
    if (!_networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      // 1. Get pending changes from queue
      final pendingChanges = await _syncQueueRepository.getPendingChanges();

      // 2. Sync each entity type
      for (final change in pendingChanges) {
        final result = await _syncEntityChange(change);
        result.fold(
          (failure) {
            // Log failure but continue
            print('Sync failed for ${change.entityId}: $failure');
          },
          (_) {
            // Mark as synced
            _syncQueueRepository.markSynced(change.id);
          },
        );
      }

      return Right(null);
    } catch (e) {
      return Left(SyncTimeoutFailure());
    }
  }

  Future<Either<SyncFailure, void>> _syncEntityChange(SyncEvent change) async {
    switch (change.entityType) {
      case 'Plant':
        return _syncPlantChange(change);
      case 'Task':
        return _syncTaskChange(change);
      default:
        return Left(SyncTimeoutFailure());
    }
  }

  Future<Either<SyncFailure, void>> _syncPlantChange(SyncEvent change) async {
    if (change.type == SyncEventType.create) {
      final plant = Plant.fromMap(change.changeData);
      return _plantsRepository.addPlant(plant).then((_) => Right(null));
    } else if (change.type == SyncEventType.update) {
      final plant = Plant.fromMap(change.changeData);
      return _plantsRepository.updatePlant(plant).then((_) => Right(null));
    } else {
      return _plantsRepository.deletePlant(change.entityId).then((_) => Right(null));
    }
  }

  // Similar for tasks...
}
```

#### 4. Data Layer: Sync Queue Repository
```dart
// lib/features/sync/data/repositories/sync_queue_repository.dart
@LazySingleton(as: SyncQueueRepository)
class SyncQueueRepositoryImpl implements SyncQueueRepository {
  final SyncQueueDao _dao;

  @override
  Future<List<SyncEvent>> getPendingChanges() async {
    return _dao.getAllPending();
  }

  @override
  Future<void> addPendingChange(SyncEvent event) async {
    await _dao.insert(SyncEventModel.fromEntity(event));
  }

  @override
  Future<void> markSynced(String eventId) async {
    await _dao.updateStatus(eventId, SyncStatus.synced);
  }

  @override
  Future<void> markFailed(String eventId, String error) async {
    await _dao.updateStatus(eventId, SyncStatus.failed, errorMessage: error);
  }
}
```

#### 5. Presentation Layer: Sync Notifier
```dart
// lib/features/sync/presentation/notifiers/sync_notifier.dart
@riverpod
class SyncNotifier extends _$SyncNotifier {
  late SyncCoordinator _coordinator;

  @override
  Future<SyncState> build() async {
    _coordinator = ref.read(syncCoordinatorProvider);
    return SyncState.idle();
  }

  Future<void> synchronizeAll() async {
    state = AsyncValue.loading();

    final result = await _coordinator.synchronizeAll();

    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (_) => AsyncValue.data(SyncState.synced()),
    );
  }

  Future<void> handleConflict(ConflictData conflict) async {
    // Delegate to conflict resolution
    // Updates state with conflict UI
  }
}
```

---

## Summary of Fixes

| Issue | Type | Effort | ROI | Status |
|-------|------|--------|-----|--------|
| TasksNotifier God Object | SRP | 13h | HIGH | 🔴 Critical |
| SettingsNotifier God Object | SRP | 10h | HIGH | 🔴 Critical |
| Task Filter Switch | OCP | 6h | MEDIUM | ⚠️ High |
| Fat Repository Interfaces | ISP | 8h | MEDIUM | ⚠️ High |
| SYNC Feature Incomplete | Architecture | 30h | CRITICAL | 🔴 Critical |

**Total Refactoring:** 75 hours (~2 weeks)

