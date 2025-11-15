# 🛣️ APP-PLANTIS - SOLID REFACTORING ROADMAP
**Detailed implementation plan with code examples and time estimates**

---

## 📋 EXECUTIVE SUMMARY

| Item | Current | Target | Effort | Priority |
|------|---------|--------|--------|----------|
| Overall SOLID Score | 8.2/10 | 9.3/10 | 97h | - |
| SRP Score | 8.2/10 | 8.9/10 | 47h | P0 |
| OCP Score | 8.3/10 | 8.8/10 | 24h | P1 |
| God Object Notifiers | 4 | 1 | 33h | P0 |
| Strategy Patterns Needed | 5 | 0 | 30h | P1 |
| Sync Feature Completion | 1% | 100% | 40h | P0 |

---

## 🔴 CRITICAL ISSUES (P0) - Week 1-2

### Issue 1: Sync Feature - Non-Existent 🔴

**Current State:**
```
lib/features/sync/
└── Barely exists
    ├── domain/ (empty)
    ├── data/ (empty)
    └── presentation/ (stub)
```

**Impact:** Zero sync functionality

**Solution:** Complete implementation from scratch

#### Step 1: Domain Layer (8h)

**File:** `lib/features/sync/domain/entities/sync_conflict.dart`
```dart
// Represents a data conflict during sync
class SyncConflict {
  final String entityId;
  final String entityType; // 'plant', 'task', etc.
  final dynamic localVersion;
  final dynamic remoteVersion;
  final DateTime localModified;
  final DateTime remoteModified;

  const SyncConflict({
    required this.entityId,
    required this.entityType,
    required this.localVersion,
    required this.remoteVersion,
    required this.localModified,
    required this.remoteModified,
  });

  bool get localIsNewer => localModified.isAfter(remoteModified);
  bool get remoteIsNewer => remoteModified.isAfter(localModified);
}

class SyncResult {
  final int synced;
  final int conflicts;
  final List<String> errors;
  final DateTime completedAt;

  const SyncResult({
    required this.synced,
    required this.conflicts,
    this.errors = const [],
    required this.completedAt,
  });
}
```

**File:** `lib/features/sync/domain/repositories/sync_repository.dart`
```dart
abstract class SyncRepository {
  /// Sync all pending changes with remote
  Future<Either<Failure, SyncResult>> syncPendingChanges();

  /// Resolve a specific conflict
  Future<Either<Failure, void>> resolveConflict(
    SyncConflict conflict,
    ConflictResolutionStrategy strategy,
  );

  /// Watch sync progress
  Stream<SyncProgress> watchSyncProgress();

  /// Get pending changes count
  Future<Either<Failure, int>> getPendingChangesCount();
}
```

**File:** `lib/features/sync/domain/repositories/conflict_resolution_strategy.dart`
```dart
abstract class ConflictResolutionStrategy {
  /// Resolve a conflict and return chosen version
  Future<Either<Failure, dynamic>> resolve(SyncConflict conflict);
  
  String get strategyName;
}

/// Keep local version as winner
class LocalWinsStrategy implements ConflictResolutionStrategy {
  @override
  String get strategyName => 'local_wins';

  @override
  Future<Either<Failure, dynamic>> resolve(SyncConflict conflict) async {
    return Right(conflict.localVersion);
  }
}

/// Keep remote version as winner
class RemoteWinsStrategy implements ConflictResolutionStrategy {
  @override
  String get strategyName => 'remote_wins';

  @override
  Future<Either<Failure, dynamic>> resolve(SyncConflict conflict) async {
    return Right(conflict.remoteVersion);
  }
}

/// Keep newest version (by timestamp)
class NewestWinsStrategy implements ConflictResolutionStrategy {
  @override
  String get strategyName => 'newest_wins';

  @override
  Future<Either<Failure, dynamic>> resolve(SyncConflict conflict) async {
    return Right(
      conflict.localIsNewer ? conflict.localVersion : conflict.remoteVersion,
    );
  }
}

/// Merge both versions intelligently (if possible)
class MergeStrategy implements ConflictResolutionStrategy {
  @override
  String get strategyName => 'merge';

  @override
  Future<Either<Failure, dynamic>> resolve(SyncConflict conflict) async {
    try {
      return Right(await _merge(conflict.localVersion, conflict.remoteVersion));
    } catch (e) {
      return Left(ValidationFailure('Cannot merge: $e'));
    }
  }

  Future<dynamic> _merge(dynamic local, dynamic remote) async {
    // Implementation depends on entity type
    // For lists: merge unique items
    // For maps: merge keys
    // For primitives: keep newest
    throw UnimplementedError('Override in subclass');
  }
}
```

**File:** `lib/features/sync/domain/usecases/sync_pending_changes_usecase.dart`
```dart
@injectable
class SyncPendingChangesUseCase 
    implements UseCase<SyncResult, NoParams> {
  const SyncPendingChangesUseCase(
    this.repository,
    this.conflictResolver,
  );

  final SyncRepository repository;
  final ConflictResolver conflictResolver;

  @override
  Future<Either<Failure, SyncResult>> call(NoParams params) async {
    try {
      final result = await repository.syncPendingChanges();

      return result.fold(
        (failure) => Left(failure),
        (syncResult) async {
          // If there are conflicts, try to resolve them
          if (syncResult.conflicts > 0) {
            await conflictResolver.resolveAll();
          }
          return Right(syncResult);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Sync failed: $e'));
    }
  }
}
```

#### Step 2: Data Layer (10h)

**File:** `lib/features/sync/data/datasources/sync_local_datasource.dart`
```dart
abstract class SyncLocalDatasource {
  /// Get all pending changes (not synced yet)
  Future<List<PendingChange>> getPendingChanges();

  /// Mark change as synced
  Future<void> markAsSynced(String changeId);

  /// Save conflict for resolution
  Future<void> saveConflict(SyncConflict conflict);

  /// Get unresolved conflicts
  Future<List<SyncConflict>> getUnresolvedConflicts();
}

@LazySingleton(as: SyncLocalDatasource)
class SyncLocalDatasourceImpl implements SyncLocalDatasource {
  final SyncQueueDao _syncQueueDao;
  final ConflictHistoryDao _conflictDao;

  SyncLocalDatasourceImpl(
    this._syncQueueDao,
    this._conflictDao,
  );

  @override
  Future<List<PendingChange>> getPendingChanges() async {
    return await _syncQueueDao.getAllPending();
  }

  @override
  Future<void> markAsSynced(String changeId) async {
    await _syncQueueDao.markAsSynced(changeId);
  }

  @override
  Future<void> saveConflict(SyncConflict conflict) async {
    await _conflictDao.insert(ConflictHistoryModel.fromEntity(conflict));
  }

  @override
  Future<List<SyncConflict>> getUnresolvedConflicts() async {
    final models = await _conflictDao.getUnresolved();
    return models.map((m) => m.toEntity()).toList();
  }
}
```

**File:** `lib/features/sync/data/repositories/sync_repository_impl.dart`
```dart
@LazySingleton(as: SyncRepository)
class SyncRepositoryImpl implements SyncRepository {
  const SyncRepositoryImpl(
    this.localDatasource,
    this.remoteDatasource,
    this.conflictResolver,
  );

  final SyncLocalDatasource localDatasource;
  final SyncRemoteDatasource remoteDatasource;
  final ConflictResolver conflictResolver;

  @override
  Future<Either<Failure, SyncResult>> syncPendingChanges() async {
    try {
      // 1. Get pending changes from local DB
      final pendingChanges = await localDatasource.getPendingChanges();

      if (pendingChanges.isEmpty) {
        return Right(SyncResult(
          synced: 0,
          conflicts: 0,
          completedAt: DateTime.now(),
        ));
      }

      // 2. Push to remote
      final pushResult = await remoteDatasource.pushChanges(pendingChanges);

      return pushResult.fold(
        (failure) => Left(failure),
        (result) async {
          // 3. Handle conflicts
          for (var conflict in result.conflicts) {
            await localDatasource.saveConflict(conflict);
          }

          // 4. Mark synced changes
          for (var synced in result.syncedIds) {
            await localDatasource.markAsSynced(synced);
          }

          return Right(SyncResult(
            synced: result.syncedIds.length,
            conflicts: result.conflicts.length,
            completedAt: DateTime.now(),
          ));
        },
      );
    } catch (e) {
      return Left(NetworkFailure('Sync failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> resolveConflict(
    SyncConflict conflict,
    ConflictResolutionStrategy strategy,
  ) async {
    try {
      final resolution = await strategy.resolve(conflict);
      return resolution.fold(
        (failure) => Left(failure),
        (chosen) async {
          // Update local DB with resolved version
          // This is implementation-dependent
          return const Right(null);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Resolution failed: $e'));
    }
  }

  @override
  Stream<SyncProgress> watchSyncProgress() {
    // Implementation with Stream for real-time progress
    // Could use StreamController or watch from Drift
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, int>> getPendingChangesCount() async {
    try {
      final pending = await localDatasource.getPendingChanges();
      return Right(pending.length);
    } catch (e) {
      return Left(CacheFailure('Cannot get count: $e'));
    }
  }
}
```

#### Step 3: Presentation Layer (6h)

**File:** `lib/features/sync/presentation/providers/sync_notifier.dart`
```dart
@riverpod
class SyncNotifier extends _$SyncNotifier {
  late final SyncPendingChangesUseCase _syncUseCase;

  @override
  Future<SyncState> build() async {
    _syncUseCase = ref.read(syncPendingChangesUseCaseProvider);
    return const SyncState.idle();
  }

  Future<void> syncNow() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await _syncUseCase(NoParams());
      return result.fold(
        (failure) => throw failure,
        (syncResult) => SyncState.success(
          syncedCount: syncResult.synced,
          conflictCount: syncResult.conflicts,
        ),
      );
    });
  }

  Future<void> resolveConflict(
    SyncConflict conflict,
    ConflictResolutionStrategy strategy,
  ) async {
    // Resolve and re-sync
    await syncNow();
  }
}

@freezed
class SyncState with _$SyncState {
  const factory SyncState.idle() = _Idle;
  const factory SyncState.syncing() = _Syncing;
  const factory SyncState.success({
    required int syncedCount,
    required int conflictCount,
  }) = _Success;
  const factory SyncState.error(String message) = _Error;
}
```

**Effort:** 24h (8 domain + 10 data + 6 presentation)

---

### Issue 2: TasksNotifier God Object - 729 Lines 🔴

**Current State:**
```dart
@riverpod
class TasksNotifier {
  // 729 LINES ❌
  // 16+ responsibilities
}
```

**Solution:** Extract 4 specialized services

#### Refactoring Plan (13h):

**Step 1: Extract TaskNotificationManager (4h)**
```dart
@injectable
class TaskNotificationManager {
  final ITaskNotificationScheduler _scheduler;
  final IPermissionManager _permissionManager;

  Future<bool> requestPermissions() async {
    if (await _permissionManager.areNotificationsEnabled()) {
      return true;
    }
    return await _permissionManager.requestPermissions();
  }

  Future<void> scheduleReminders(List<Task> tasks) async {
    for (var task in tasks) {
      await _scheduler.scheduleTaskReminder(task: task);
    }
  }

  Future<void> cancelReminders(String taskId) async {
    await _scheduler.cancelTaskNotifications(taskId);
  }
}
```

**Step 2: Extract TasksAuthCoordinator (2h)**
```dart
@injectable
class TasksAuthCoordinator {
  final IAuthRepository _authRepository;

  void validateOwnership(Task task, String userId) {
    if (task.userId != userId) {
      throw UnauthorizedFailure('Cannot modify task: not owner');
    }
  }

  void validateMutability(Task task) {
    if (task.isCompleted && task.isPermanent) {
      throw ValidationFailure('Cannot modify completed permanent task');
    }
  }
}
```

**Step 3: Extract TasksLoadingStateManager (3h)**
```dart
@injectable
class TasksLoadingStateManager {
  Future<List<Task>> manageLoading(
    Future<List<Task>> Function() operation,
  ) async {
    // Centralize loading state management
    try {
      return await operation();
    } catch (e) {
      rethrow;
    }
  }
}
```

**Step 4: Refactor TasksNotifier (4h)**
```dart
@riverpod
class TasksNotifier extends _$TasksNotifier {
  late final GetTasksUseCase _getTasks;
  late final TaskFilterService _filterService;
  late final TaskNotificationManager _notifications;
  late final TasksAuthCoordinator _authCoordinator;

  @override
  Future<TasksState> build() async {
    _getTasks = ref.read(getTasksUseCaseProvider);
    _filterService = ref.read(taskFilterServiceProvider);
    _notifications = ref.read(taskNotificationManagerProvider);
    _authCoordinator = ref.read(tasksAuthCoordinatorProvider);

    return await _loadTasks();
  }

  Future<TasksState> _loadTasks() async {
    final result = await _getTasks(NoParams());
    return result.fold(
      (failure) => TasksState.error(failure.message),
      (tasks) {
        final filtered = _filterService.applyFilters(tasks);
        return TasksState.success(tasks: filtered);
      },
    );
  }

  Future<void> completeTask(String taskId) async {
    // Use injected services instead of doing everything here
    final task = _findTask(taskId);
    _authCoordinator.validateOwnership(task, userId);
    await _notifications.cancelReminders(taskId);
    // ... rest of logic
  }
}
```

**Result:** 729 → 150 lines, 16 → 4 responsibilities

**Effort: 13 hours**

---

### Issue 3: SettingsNotifier God Object - 717 Lines 🔴

Similar to TasksNotifier, needs to extract:
- NotificationSettingsManager
- AnalyticsConfigManager
- ThemeManager
- AccountPreferencesManager

**Effort: 10 hours**
**Result: 717 → 120 lines**

---

## 🟡 HIGH IMPACT ISSUES (P1) - Week 3

### Issue 4: OCP Violations - Implement Strategy Patterns

#### 4A: TaskFilterStrategy (ALREADY DONE ✅)

#### 4B: ExportFormatStrategy (6h)

**Before:**
```dart
Future<Either<Failure, String>> export(
  List<Plant> plants,
  ExportFormat format,
) async {
  switch (format) {
    case ExportFormat.csv:
      return _exportToCsv(plants);
    case ExportFormat.pdf:
      return _exportToPdf(plants);
    case ExportFormat.json:
      return _exportToJson(plants);
    // Adding new format = modify method ❌
  }
}
```

**After:**
```dart
abstract class ExportStrategy {
  Future<Either<Failure, String>> export(List<Plant> data);
  ExportFormat get format;
}

class CsvExportStrategy implements ExportStrategy {
  @override
  ExportFormat get format => ExportFormat.csv;

  @override
  Future<Either<Failure, String>> export(List<Plant> data) async {
    // CSV-specific logic
  }
}

// Registry
class ExportStrategyRegistry {
  final Map<ExportFormat, ExportStrategy> _strategies = {};

  void register(ExportStrategy strategy) {
    _strategies[strategy.format] = strategy;
  }

  ExportStrategy? getStrategy(ExportFormat format) {
    return _strategies[format];
  }
}

// Usage
Future<Either<Failure, String>> export(
  List<Plant> plants,
  ExportFormat format,
) async {
  final strategy = registry.getStrategy(format);
  return strategy?.export(plants) ?? 
    Left(ValidationFailure('Unsupported format'));
}
```

**Effort: 6 hours**

#### 4C: SubscriptionTierStrategy (6h)

Similar pattern for Premium feature subscription tiers

**Effort: 6 hours**

#### 4D-E: Additional Strategies (12h total)
- DeviceValidationStrategy
- PasswordValidationStrategy

---

### Issue 5: ISP - Interface Segregation (8h)

#### 5A: Split PlantsRepository (3h)

**Before:**
```dart
abstract class PlantsRepository {
  // 11 methods - fat interface
  Future<Either<Failure, List<Plant>>> getPlants();
  Future<Either<Failure, Plant>> getPlantById(String id);
  Future<Either<Failure, Plant>> addPlant(Plant plant);
  Future<Either<Failure, Plant>> updatePlant(Plant plant);
  Future<Either<Failure, void>> deletePlant(String id);
  Future<Either<Failure, List<Plant>>> searchPlants(String query);
  Future<Either<Failure, List<Plant>>> getPlantsBySpace(String spaceId);
  Future<Either<Failure, int>> getPlantsCount();
  Stream<List<Plant>> watchPlants();
  Future<Either<Failure, void>> syncPendingChanges();
}
```

**After:**
```dart
// Segregated interfaces
abstract class IPlantsReader {
  Future<Either<Failure, List<Plant>>> getPlants();
  Future<Either<Failure, Plant>> getPlantById(String id);
  Stream<List<Plant>> watchPlants();
}

abstract class IPlantsWriter {
  Future<Either<Failure, Plant>> addPlant(Plant plant);
  Future<Either<Failure, Plant>> updatePlant(Plant plant);
  Future<Either<Failure, void>> deletePlant(String id);
}

abstract class IPlantsQuery {
  Future<Either<Failure, List<Plant>>> searchPlants(String query);
  Future<Either<Failure, List<Plant>>> getPlantsBySpace(String spaceId);
  Future<Either<Failure, int>> getPlantsCount();
}

abstract class IPlantsSync {
  Future<Either<Failure, void>> syncPendingChanges();
}

// Compose for backward compatibility
abstract class PlantsRepository
    implements IPlantsReader, IPlantsWriter, IPlantsQuery, IPlantsSync {}
```

**Benefits:**
- Clients depend only on what they need
- Easier to mock specific interfaces
- Clearer responsibility

**Effort: 3 hours**

#### 5B: Split TasksRepository (3h)

Similar pattern

**Effort: 3 hours**

#### 5C: Split SettingsInterfaces (2h)

**Effort: 2 hours**

---

## ✅ POLISH ISSUES (P2) - Week 4-5

### Issue 6: Remove Direct Instantiations (4h)

**Before:**
```dart
class TaskNotificationService {
  void _initializeServices() {
    _notificationService = PlantisNotificationService(); // ❌
  }
}
```

**After:**
```dart
@injectable
class TaskNotificationService {
  final PlantisNotificationService _notificationService;

  TaskNotificationService({
    required PlantisNotificationService notificationService,
  }) : _notificationService = notificationService;
}
```

---

### Issue 7: Extract Utility Services (4h)

Create specialized services for cross-cutting concerns:
- DateUtilService
- ValidationUtilService
- StringUtilService

---

### Issue 8: Add Missing Tests (6h)

- Tests for new extracted services
- Integration tests
- UI tests

---

## 📊 TOTAL EFFORT BREAKDOWN

```
PHASE 1 (P0 - Critical):      53 hours
├─ Sync Feature:              30 hours
├─ TasksNotifier:             13 hours
└─ SettingsNotifier:          10 hours

PHASE 2 (P1 - High Impact):   30 hours
├─ Strategy Patterns:         24 hours
└─ Interface Segregation:      8 hours

PHASE 3 (P2 - Polish):        14 hours
├─ Remove Direct Instantiations: 4 hours
├─ Extract Utilities:          4 hours
└─ Add Tests:                  6 hours

TOTAL: 97 HOURS (2.5 weeks with 35h/week)
```

---

## 🎯 SUCCESS METRICS

| Metric | Current | Target |
|--------|---------|--------|
| Overall SOLID Score | 8.2/10 | 9.3/10 |
| God Objects | 4 | 1 |
| OCP Violations | 5 | 0 |
| Largest Notifier | 729 lines | <300 lines |
| Test Coverage | 80%+ | 85%+ |
| Code Duplication | Medium | Low |

---

**Roadmap Created:** 2025-11-14
**Ready to Implement:** Yes ✅
