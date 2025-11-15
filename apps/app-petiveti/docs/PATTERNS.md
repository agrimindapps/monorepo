# SOLID Patterns Implementation Guide

This document provides detailed before/after code examples for each SOLID principle pattern used in app-petiveti.

---

## 1. SRP (Single Responsibility Principle) Pattern

**Goal**: Each class/service has ONE reason to change

### Before: God Object Anti-Pattern

```dart
// ❌ BAD: WeightNotifier handles EVERYTHING
class WeightNotifier extends StateNotifier<WeightState> {
  WeightNotifier(this._repo) : super(WeightState());
  
  final WeightRepository _repo;
  
  // Responsibility 1: CRUD operations
  Future<void> addWeight(Weight w) async { ... }
  Future<void> updateWeight(Weight w) async { ... }
  Future<void> deleteWeight(String id) async { ... }
  
  // Responsibility 2: Filtering
  Future<void> filterByAnimal(String animalId) async { ... }
  void clearFilter() { ... }
  
  // Responsibility 3: Sorting
  void sortByDate() { ... }
  void sortByValue() { ... }
  
  // Responsibility 4: Analytics
  double getAverageWeight() { ... }
  List<WeightTrend> getTrends() { ... }
  
  // Responsibility 5: Persistence
  Future<void> syncWithServer() async { ... }
  void saveDraft() { ... }
  
  // Result: 50+ lines, multiple reasons to change
}
```

### After: SRP Pattern - Separated Notifiers

```dart
// ✅ GOOD: Each notifier has ONE responsibility

/// Responsibility 1: CRUD operations only
class WeightsCrudNotifier extends StateNotifier<List<Weight>> {
  WeightsCrudNotifier(this._repo) : super([]);
  final WeightCrudRepository _repo;
  
  Future<void> addWeight(Weight weight) async {
    // Only handles create/update/delete
  }
}

/// Responsibility 2: Filtering only
class WeightsFilterNotifier extends StateNotifier<WeightsFilterState> {
  WeightsFilterNotifier() : super(const WeightsFilterState());
  
  void setSelectedAnimal(String? animalId) {
    state = state.copyWith(selectedAnimalId: animalId);
  }
}

/// Responsibility 3: Sorting only
class WeightsSortNotifier extends StateNotifier<WeightsSortState> {
  WeightsSortNotifier() : super(const WeightsSortState());
  
  void setSortOrder(WeightSortOrder order) {
    state = state.copyWith(sortOrder: order);
  }
}

/// Responsibility 4: Data querying only
class WeightsQueryNotifier extends StateNotifier<AsyncValue<List<Weight>>> {
  WeightsQueryNotifier(this._repo) : super(const AsyncValue.loading());
  final WeightQueryRepository _repo;
  
  Future<void> loadWeights() async { ... }
}

/// Responsibility 5: Analytics only
@riverpod
double weightAverage(WeightAverageRef ref) {
  final weights = ref.watch(weightsQueryNotifierProvider);
  return weights.when(
    data: (w) => w.isNotEmpty ? w.fold(0, (a, b) => a + b.value) / w.length : 0,
    loading: () => 0,
    error: (_, __) => 0,
  );
}
```

**Benefits**:
- Each notifier has ONE reason to change
- Easier to test (mock one responsibility at a time)
- Reusable across features
- Easier to maintain and debug

---

## 2. OCP (Open/Closed Principle) Pattern

**Goal**: Classes are OPEN for extension, CLOSED for modification

### Before: Hard to Extend Anti-Pattern

```dart
// ❌ BAD: To add new state types, must modify the base class
class WeightsState {
  final bool isLoading;
  final String? error;
  final List<Weight>? data;
  
  const WeightsState({
    this.isLoading = false,
    this.error,
    this.data,
  });
  
  // To add new fields, modify this class
  // Risk: breaks existing code
}
```

### After: OCP Pattern - Inheritance-Based Extension

```dart
// ✅ GOOD: Base class is closed, features extend without modification

/// Base interface - closed for modification
abstract class AsyncState<T> {
  bool get isLoading;
  bool get hasError;
  String? get errorMessage;
  T? get data;
  
  bool get isInitial => !isLoading && !hasError && data == null;
  bool get hasData => data != null;
}

/// Base implementation with copyWith pattern
abstract class AsyncStateBase<T> implements AsyncState<T> {
  @override
  final bool isLoading;
  @override
  final bool hasError;
  @override
  final String? errorMessage;
  @override
  final T? data;

  const AsyncStateBase({
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.data,
  });

  /// Extension point: subclasses implement copyWithAsync
  AsyncStateBase<T> copyWithAsync({
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    T? data,
    bool clearError = false,
  });
}

/// Feature extends without modifying base
class WeightsQueryState extends AsyncStateBase<List<Weight>> {
  final WeightSortOrder sortOrder;
  final String? selectedAnimalId;

  const WeightsQueryState({
    super.isLoading = false,
    super.hasError = false,
    super.errorMessage,
    super.data,
    this.sortOrder = WeightSortOrder.dateDesc,
    this.selectedAnimalId,
  });

  @override
  WeightsQueryState copyWithAsync({
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    List<Weight>? data,
    bool clearError = false,
    WeightSortOrder? sortOrder,
    String? selectedAnimalId,
  }) {
    return WeightsQueryState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      data: data ?? this.data,
      sortOrder: sortOrder ?? this.sortOrder,
      selectedAnimalId: selectedAnimalId ?? this.selectedAnimalId,
    );
  }
}
```

**Benefits**:
- Add new state types by extending, not modifying
- Old code keeps working
- Each feature has its own extended state
- Consistent patterns across app

---

## 3. LSP (Liskov Substitution Principle) Pattern

**Goal**: Subtypes must be substitutable for their base types

### Before: Breaking Contracts Anti-Pattern

```dart
// ❌ BAD: Implementations don't respect contracts
abstract class WeightRepository {
  Future<Either<Failure, List<Weight>>> getWeights();
}

class WeightRepositoryImpl implements WeightRepository {
  @override
  Future<Either<Failure, List<Weight>>> getWeights() async {
    // ❌ PROBLEM 1: Throws exceptions instead of returning Either
    if (_offline) throw OfflineException();
    
    // ❌ PROBLEM 2: Returns null instead of List<Weight>
    final data = await _datasource.getWeights();
    if (data == null) return null; // Should return Left<Failure>!
    
    // ❌ PROBLEM 3: Returns bare list instead of Either
    return data; // Should return Right(data)!
  }
}
```

### After: LSP Pattern - Respecting Contracts

```dart
// ✅ GOOD: All implementations honor the contract

abstract class WeightRepository {
  Future<Either<Failure, List<Weight>>> getWeights();
}

class WeightRepositoryImpl implements WeightRepository {
  final LocalDataSource _local;
  final RemoteDataSource _remote;
  
  @override
  Future<Either<Failure, List<Weight>>> getWeights() async {
    try {
      // Try remote first
      if (await _isOnline()) {
        final remote = await _remote.getWeights();
        // Cache locally
        await _local.cacheWeights(remote);
        return Right(remote);
      }
      
      // Fall back to local
      final cached = await _local.getWeights();
      if (cached.isNotEmpty) {
        return Right(cached);
      }
      
      return Left(CacheFailure('No cached data'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

// Can be used polymorphically - all return Either<Failure, List<Weight>>
final repo = WeightRepositoryImpl(...);
final result = await repo.getWeights();
result.fold(
  (failure) => print('Error: ${failure.message}'),
  (weights) => print('Success: ${weights.length} weights'),
);
```

**Benefits**:
- Predictable behavior from all implementations
- Type-safe error handling
- No unexpected exceptions
- Easy to test with mocks

---

## 4. ISP (Interface Segregation Principle) Pattern

**Goal**: Clients depend on specific interfaces, not monolithic ones

### Before: Fat Interface Anti-Pattern

```dart
// ❌ BAD: One massive interface - clients forced to depend on everything
abstract class HomeRepository {
  Future<Either<Failure, HomeStats>> getStats();
  Future<Either<Failure, HomeStats>> refreshStats();
  Future<Either<Failure, Map<String, dynamic>>> getHealthStatus();
  Future<Either<Failure, int>> getNotificationCount();
  Future<Either<Failure, List<Notification>>> getRecentNotifications();
  Future<Either<Failure, bool>>> hasUrgentAlerts();
  Future<Either<Failure, DashboardStatus>> getDashboardStatus();
  Future<Either<Failure, bool>>> checkOnlineStatus();
  Future<Either<Failure, void>> refresh();
}

// Client depends on EVERYTHING, even if it only needs stats
class StatsWidget extends StatelessWidget {
  final HomeRepository repo; // Depends on ALL 9 methods!
  
  @override
  Widget build(context) {
    // Only uses getStats(), but depends on 8 other methods
  }
}
```

### After: ISP Pattern - Segregated Interfaces

```dart
// ✅ GOOD: Separate interfaces for separate concerns

/// Clients needing stats depend ONLY on this
abstract class HomeAggregationRepository {
  Future<Either<Failure, HomeStats>> getStats();
  Future<Either<Failure, HomeStats>> refreshStats();
  Future<Either<Failure, Map<String, dynamic>>> getHealthStatus();
}

/// Clients needing notifications depend ONLY on this
abstract class NotificationRepository {
  Future<Either<Failure, int>> getUnreadCount();
  Future<Either<Failure, List<NotificationSummary>>> getRecentNotifications();
  Future<Either<Failure, bool>> hasUrgentAlerts();
}

/// Clients needing dashboard depend ONLY on this
abstract class DashboardRepository {
  Future<Either<Failure, DashboardStatus>> getStatus();
  Future<Either<Failure, bool>> checkOnlineStatus();
  Future<Either<Failure, void>>> refresh();
}

/// Now client depends ONLY on what it needs
class StatsWidget extends StatelessWidget {
  final HomeAggregationRepository repo; // Only stats interface
  
  @override
  Widget build(context) {
    // repo can only access stats methods
    // Type-safe: won't accidentally use notification methods
  }
}

/// Single implementation provides all interfaces
class HomeRepositoryImpl 
    implements 
      HomeAggregationRepository,
      NotificationRepository,
      DashboardRepository {
  // Implements all three interfaces
}
```

**Benefits**:
- Clients depend on ONLY what they need
- Changes to one interface don't affect unrelated clients
- Type-safe: IDE autocomplete shows only relevant methods
- Easier to mock for testing
- Clear responsibility boundaries

---

## 5. DIP (Dependency Inversion Principle) Pattern

**Goal**: Depend on abstractions, not concrete implementations

### Before: Direct Dependency Anti-Pattern

```dart
// ❌ BAD: Direct dependency on concrete LoggingService
class WeightsCrudNotifier extends StateNotifier<List<Weight>> {
  WeightsCrudNotifier(this._repo) : super([]);
  
  final WeightRepository _repo;
  
  Future<void> addWeight(Weight w) async {
    // Direct singleton access - hard to test
    LoggingService.instance.log('Adding weight: $w');
    
    // Direct dependency - can't mock
    final result = await _repo.addWeight(w);
    
    LoggingService.instance.log('Add result: $result');
  }
}
```

### After: DIP Pattern - Inversion via Riverpod Providers

```dart
// ✅ GOOD: Depend on providers, not concrete implementations

/// Abstraction for logging
abstract class LoggingService {
  void log(String message);
  void error(String message, [StackTrace? trace]);
}

/// Provider provides the abstraction, not the concrete class
@riverpod
LoggingService loggingService(LoggingServiceRef ref) {
  return LoggingServiceImpl();
}

/// Notifier depends on provider (abstraction), not concrete class
class WeightsCrudNotifier extends StateNotifier<List<Weight>> {
  WeightsCrudNotifier(
    this._repo,
    this._loggingService, // Injected abstraction
  ) : super([]);
  
  final WeightRepository _repo;
  final LoggingService _loggingService;
  
  Future<void> addWeight(Weight w) async {
    _loggingService.log('Adding weight: $w');
    
    final result = await _repo.addWeight(w);
    
    _loggingService.log('Add result: $result');
  }
}

/// Provider setup - manages dependency inversion
@riverpod
WeightsCrudNotifier weightsCrudNotifier(WeightsCrudNotifierRef ref) {
  return WeightsCrudNotifier(
    ref.watch(weightRepositoryProvider),
    ref.watch(loggingServiceProvider), // Provides abstraction
  );
}

/// For testing: provide mock implementation
test('should log add weight', () async {
  final mockLogger = MockLoggingService();
  
  final container = ProviderContainer(
    overrides: [
      loggingServiceProvider.overrideWithValue(mockLogger),
    ],
  );
  
  final notifier = container.read(weightsCrudNotifierProvider.notifier);
  await notifier.addWeight(testWeight);
  
  verify(() => mockLogger.log(any())).called(1);
});
```

**Benefits**:
- Tests don't depend on concrete implementations
- Easy to swap implementations (mock, stub, real)
- Changes to implementation don't break notifiers
- Clear dependency flow via providers

---

## Summary: Pattern Hierarchy

```
DIP (Foundation)
├─ Provides abstractions for other patterns
├─ All concrete classes inject dependencies
└─ Enables testing via mock implementations

LSP (Contract Enforcement)
├─ All implementations honor contracts
├─ Predictable behavior across implementations
└─ No breaking substitutions

ISP (Interface Design)
├─ Segregate interfaces by responsibility
├─ Clients depend on what they use
└─ Clear boundaries between features

OCP (Extensibility)
├─ Extend via inheritance, not modification
├─ Base classes remain closed
└─ New features add subclasses

SRP (Granularity)
├─ Each class has ONE reason to change
├─ Single responsibility at class level
└─ Foundation for all other principles
```

---

## Practical Checklist

Before implementing a feature, verify:

- [ ] **SRP**: Does each notifier/service have only ONE responsibility?
- [ ] **OCP**: Can I extend features without modifying existing classes?
- [ ] **LSP**: Do all implementations honor their contracts?
- [ ] **ISP**: Does each client depend ONLY on what it uses?
- [ ] **DIP**: Are dependencies injected via providers, not singletons?

If any answer is "No", refactor before implementing.
