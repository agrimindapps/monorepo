# app-plantis SOLID Patterns Guide

This document provides before/after examples of SOLID principles applied to app-plantis.

## Single Responsibility Principle (SRP)

### Before: God Object Anti-pattern

```dart
// ❌ BAD: One class doing everything
@riverpod
class TasksNotifier extends _$TasksNotifier {
  // CRUD operations
  Future<void> addTask(Task task) async { }
  Future<void> updateTask(Task task) async { }
  Future<void> deleteTask(String id) async { }
  
  // Query operations
  void searchTasks(String query) { }
  void filterByPlantId(String plantId) { }
  void setTaskTypeFilter(String type) { }
  
  // Schedule operations
  List<Task> getOverdueTasks() { }
  List<Task> getTodayTasks() { }
  Task? generateNextRecurringTask(Task task) { }
  
  // Recommendations
  List<Task> getHighPriorityTasks() { }
  List<Task> getTodaySuggestions() { }
  
  // 5 reasons to change this class!
}
```

### After: Specialized Notifiers

```dart
// ✅ GOOD: Each notifier has ONE responsibility

// CRUD operations only
@riverpod
class TasksCrudNotifier extends _$TasksCrudNotifier {
  Future<void> addTask(Task task) async { }
  Future<void> completeTask(String id) async { }
  Future<void> deleteTask(String id) async { }
}

// Query/Filtering operations only
@riverpod
class TasksQueryNotifier extends _$TasksQueryNotifier {
  void searchTasks(String query) { }
  void setFilter(TasksFilterType filter) { }
  void setAdvancedFilters({...}) { }
  void setPlantFilter(String? plantId) { }
}

// Schedule/Recurring operations only
@riverpod
class TasksScheduleNotifier extends _$TasksScheduleNotifier {
  List<Task> getOverdueTasks() { }
  List<Task> getTodayTasks() { }
  List<Task> getUpcomingTasks() { }
  Task? generateNextRecurringTask(Task task) { }
}

// Recommendations only
@riverpod
class TasksRecommendationNotifier extends _$TasksRecommendationNotifier {
  List<Task> getHighPriorityTasks() { }
  List<Task> getTodaySuggestions() { }
  Map<String, dynamic> getOptimizations() { }
}
```

**Benefits:**
- Each notifier has ONE reason to change
- Easier to test in isolation
- Clearer API with focused methods
- Better code reusability

---

## Open/Closed Principle (OCP)

### Before: Conditional Explosion

```dart
// ❌ BAD: Closed for extension, open for modification
class TaskFilterService {
  List<Task> filterTasks(
    List<Task> tasks,
    String filterType,
    String? plantId,
    String? priority,
  ) {
    if (filterType == 'completed') {
      return tasks.where((t) => t.status == TaskStatus.completed).toList();
    } else if (filterType == 'pending') {
      return tasks.where((t) => t.status == TaskStatus.pending).toList();
    } else if (filterType == 'overdue') {
      return tasks.where((t) {
        final dueDate = t.dueDate;
        return dueDate != null && dueDate.isBefore(DateTime.now());
      }).toList();
    } else if (filterType == 'today') {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      return tasks.where((t) {
        final dueDate = t.dueDate;
        return dueDate != null && 
               dueDate.isAfter(today) &&
               dueDate.isBefore(today.add(Duration(days: 1)));
      }).toList();
    }
    // Need to add new else if for each new filter type
    return tasks;
  }
}
```

### After: Strategy Pattern with Polymorphism

```dart
// ✅ GOOD: Closed for modification, open for extension

// Base abstraction
abstract class ITaskFilterStrategy {
  List<Task> filter(List<Task> tasks);
}

// Concrete implementations - one per filter type
class CompletedTasksFilter implements ITaskFilterStrategy {
  @override
  List<Task> filter(List<Task> tasks) {
    return tasks.where((t) => t.status == TaskStatus.completed).toList();
  }
}

class PendingTasksFilter implements ITaskFilterStrategy {
  @override
  List<Task> filter(List<Task> tasks) {
    return tasks.where((t) => t.status == TaskStatus.pending).toList();
  }
}

class OverdueTasksFilter implements ITaskFilterStrategy {
  @override
  List<Task> filter(List<Task> tasks) {
    return tasks.where((t) {
      final dueDate = t.dueDate;
      return dueDate != null && dueDate.isBefore(DateTime.now());
    }).toList();
  }
}

class TodayTasksFilter implements ITaskFilterStrategy {
  @override
  List<Task> filter(List<Task> tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return tasks.where((t) {
      final dueDate = t.dueDate;
      return dueDate != null && 
             dueDate.isAfter(today) &&
             dueDate.isBefore(today.add(Duration(days: 1)));
    }).toList();
  }
}

// Easy to extend - add new filter without modifying existing code
class HighPriorityTasksFilter implements ITaskFilterStrategy {
  @override
  List<Task> filter(List<Task> tasks) {
    return tasks.where((t) =>
      t.priority == TaskPriority.urgent || 
      t.priority == TaskPriority.high
    ).toList();
  }
}

// Service uses strategies
class TaskFilterService {
  List<Task> applyFilter(
    List<Task> tasks,
    ITaskFilterStrategy strategy,
  ) {
    return strategy.filter(tasks);
  }
}
```

**Benefits:**
- Add new filters by creating new implementations
- No modification to existing code
- Each filter is isolated and testable
- Follows Strategy pattern

---

## Liskov Substitution Principle (LSP)

### Before: Violating Contracts

```dart
// ❌ BAD: Subclass violates parent contract
abstract class ITaskRepository {
  Future<Either<Failure, List<Task>>> getTasks();
  Future<Either<Failure, Task>> getTaskById(String id);
  Future<Either<Failure, void>> addTask(Task task);
}

class TaskRepositoryImpl implements ITaskRepository {
  @override
  Future<Either<Failure, List<Task>>> getTasks() async {
    // Works fine, returns tasks
    return Right(tasks);
  }

  @override
  Future<Either<Failure, Task>> getTaskById(String id) async {
    // ❌ Violates contract: throws exception instead of returning Left
    throw UnimplementedException();
  }

  @override
  Future<Either<Failure, void>> addTask(Task task) async {
    return Right(null);
  }
}

// Client code breaks because subclass violates contract
final result = await repository.getTaskById('123');
// Throws exception instead of returning Left<Failure>
```

### After: Proper Contract Implementation

```dart
// ✅ GOOD: All implementations honor the contract

abstract class ITaskRepository {
  Future<Either<Failure, List<Task>>> getTasks();
  Future<Either<Failure, Task>> getTaskById(String id);
  Future<Either<Failure, void>> addTask(Task task);
}

class TaskRepositoryImpl implements ITaskRepository {
  @override
  Future<Either<Failure, List<Task>>> getTasks() async {
    try {
      final tasks = await _localDataSource.getTasks();
      return Right(tasks);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Task>> getTaskById(String id) async {
    try {
      final task = await _localDataSource.getTaskById(id);
      return Right(task);
    } on TaskNotFoundException {
      return Left(NotFoundFailure('Task not found'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addTask(Task task) async {
    try {
      await _localDataSource.addTask(task);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

class CachedTaskRepositoryImpl implements ITaskRepository {
  // Different implementation but same contract
  @override
  Future<Either<Failure, List<Task>>> getTasks() async {
    final cached = _cache.getTasks();
    if (cached != null) return Right(cached);
    
    final result = await _remote.getTasks();
    return result.fold(
      (failure) => Left(failure),
      (tasks) {
        _cache.save(tasks);
        return Right(tasks);
      },
    );
  }

  // ... other methods
}

// Both implementations can be used interchangeably
final repository1 = TaskRepositoryImpl();
final repository2 = CachedTaskRepositoryImpl();

final result = await repository1.getTaskById('123');
// Always returns Either<Failure, Task>, never throws
```

**Benefits:**
- Predictable contract behavior
- Can swap implementations without breaking code
- Better error handling
- Easier to mock for testing

---

## Interface Segregation Principle (ISP)

### Before: Fat Interface

```dart
// ❌ BAD: One fat interface for everything
abstract class ITaskRepository {
  Future<Either<Failure, List<Task>>> getTasks();
  Future<Either<Failure, List<Task>>> searchTasks(String query);
  Future<Either<Failure, List<Task>>> getTasksByStatus(TaskStatus status);
  Future<Either<Failure, List<Task>>> getTasksByPlantId(String plantId);
  Future<Either<Failure, Map<String, dynamic>>> getStatistics();
  Future<Either<Failure, Task>> getTaskById(String id);
  Future<Either<Failure, Task>> addTask(Task task);
  Future<Either<Failure, Task>> updateTask(Task task);
  Future<Either<Failure, void>> deleteTask(String id);
  Future<Either<Failure, void>> completeTask(String id);
  Future<Either<Failure, void>> syncPendingTasks();
}

// Client forced to implement everything even if not needed
class MockRepository implements ITaskRepository {
  // Must implement all 11 methods, even if only 2 are needed
  @override
  Future<Either<Failure, List<Task>>> getTasks() async { }
  @override
  Future<Either<Failure, List<Task>>> searchTasks(String query) async { }
  @override
  Future<Either<Failure, List<Task>>> getTasksByStatus(TaskStatus status) async { }
  // ... and 8 more methods just to satisfy the interface
}
```

### After: Segregated Interfaces

```dart
// ✅ GOOD: Separated interfaces for specific concerns

// CRUD operations only
abstract class ITasksCrudRepository {
  Future<Either<Failure, Task>> addTask(Task task);
  Future<Either<Failure, Task>> updateTask(Task task);
  Future<Either<Failure, void>> deleteTask(String id);
  Future<Either<Failure, void>> completeTask(String id);
}

// Query operations only
abstract class ITasksQueryRepository {
  Future<Either<Failure, List<Task>>> getTasks();
  Future<Either<Failure, Task>> getTaskById(String id);
  Future<Either<Failure, List<Task>>> searchTasks(String query);
  Future<Either<Failure, List<Task>>> filterByPlantId(String plantId);
  Future<Either<Failure, List<Task>>> filterByStatus(TaskStatus status);
  Future<Either<Failure, Map<String, dynamic>>> getStatistics();
}

// Sync operations only
abstract class ITasksSyncRepository {
  Future<Either<Failure, void>> syncPendingTasks();
}

// Now clients implement only what they need
class TasksCrudNotifier {
  final ITasksCrudRepository _repository;
  TasksCrudNotifier(this._repository);
  
  // Only needs CRUD operations
}

class TasksQueryNotifier {
  final ITasksQueryRepository _repository;
  TasksQueryNotifier(this._repository);
  
  // Only needs Query operations
}

class MockTasksQueryRepository implements ITasksQueryRepository {
  // Only implement the 6 query methods, not all 11
  @override
  Future<Either<Failure, List<Task>>> getTasks() async { }
  @override
  Future<Either<Failure, Task>> getTaskById(String id) async { }
  @override
  Future<Either<Failure, List<Task>>> searchTasks(String query) async { }
  // ... etc
}
```

**Benefits:**
- Clients depend only on what they use
- Easier mocking with smaller interfaces
- Clearer API contracts
- Reduced coupling

---

## Dependency Inversion Principle (DIP)

### Before: Hard-coded Dependencies

```dart
// ❌ BAD: Tight coupling, hard to test
@riverpod
class TasksQueryNotifier extends _$TasksQueryNotifier {
  final _filterService = TaskFilterService(); // Hard-coded
  final _recommendationService = TaskRecommendationService(); // Hard-coded
  
  @override
  TasksState build() {
    return TasksState.initial();
  }
  
  void searchTasks(String query) {
    // Uses hard-coded service, can't mock or swap
    final filtered = _filterService.applyFilters(...);
  }
}

// Testing is difficult - must use real implementations
final notifier = TasksQueryNotifier();
// Can't inject mock filter service
```

### After: Dependency Injection via Riverpod

```dart
// ✅ GOOD: Dependencies injected through Riverpod

// Provider for filter service (abstraction, not concrete)
@riverpod
ITaskFilterService taskFilterServiceProvider(TaskFilterServiceRef ref) {
  return TaskFilterService();
}

// Provider for recommendation service
@riverpod
ITaskRecommendationService taskRecommendationServiceProvider(
  TaskRecommendationServiceRef ref,
) {
  return TaskRecommendationService();
}

// Notifier depends on abstractions
@riverpod
class TasksQueryNotifier extends _$TasksQueryNotifier {
  late final ITaskFilterService _filterService;
  late final ITaskRecommendationService _recommendationService;
  
  @override
  TasksState build() {
    // Inject dependencies from Riverpod
    _filterService = ref.read(taskFilterServiceProvider);
    _recommendationService = ref.read(taskRecommendationServiceProvider);
    return TasksState.initial();
  }
  
  void searchTasks(String query) {
    // Uses injected service
    final filtered = _filterService.applyFilters(...);
  }
}

// Testing: Easy to override with mocks
final container = ProviderContainer(
  overrides: [
    taskFilterServiceProvider.overrideWithValue(MockFilterService()),
    taskRecommendationServiceProvider.overrideWithValue(
      MockRecommendationService(),
    ),
  ],
);

final notifier = container.read(tasksQueryNotifierProvider.notifier);
// Now uses mock implementations
```

**Benefits:**
- Loose coupling through abstractions
- Easy to test with mock implementations
- Can swap implementations without code changes
- Clear dependency graph
- Follows Riverpod best practices

---

## Summary: SRP Patterns in Use

| Principle | Pattern | Benefit |
|-----------|---------|---------|
| **SRP** | Specialized notifiers | Each handles one concern |
| **OCP** | Strategy pattern | Extend without modifying |
| **LSP** | Contract integrity | Predictable behavior |
| **ISP** | Segregated interfaces | Clients use what they need |
| **DIP** | Dependency injection | Loose coupling, testability |

All patterns work together to create maintainable, testable, and extensible code.
