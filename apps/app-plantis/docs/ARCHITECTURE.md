# app-plantis Architecture Guide

## Overview

app-plantis follows a **Clean Architecture** approach combined with **SOLID principles** to maintain high code quality, testability, and maintainability. This document outlines the architecture patterns used throughout the application.

## Architecture Layers

### 1. **Domain Layer** (Pure Business Logic)
- **Location**: `lib/features/[feature]/domain/`
- **No external dependencies** (no Flutter, no frameworks)
- **Core responsibility**: Define business rules and contracts

**Key Components:**
- **Entities**: Pure data objects representing core business concepts
  ```dart
  // Example: Plant entity
  class Plant extends Equatable {
    final String id;
    final String name;
    final String? species;
    // No database or UI concerns
  }
  ```

- **Repositories (Interfaces)**: Abstract contracts
  ```dart
  abstract class IPlantsRepository {
    Future<Either<Failure, List<Plant>>> getPlants();
    Future<Either<Failure, Plant>> addPlant(Plant plant);
  }
  ```

- **Use Cases**: Single responsibility operations
  ```dart
  class AddPlantUseCase {
    // One job: validate and add a plant
  }
  ```

- **Services (Interfaces)**: Business logic helpers
  ```dart
  abstract class IScheduleService {
    DateTime? calculateNextDueDate(...);
    bool isOverdue(DateTime? dueDate);
  }
  ```

- **Failures**: Typed error handling with Either<Failure, T>
  ```dart
  abstract class Failure extends Equatable {
    final String message;
  }
  ```

### 2. **Data Layer** (External Data Sources)
- **Location**: `lib/features/[feature]/data/`
- **Responsibilities**: Fetching and caching data
- **Implements domain contracts**

**Key Components:**
- **Models**: DTOs with serialization
  ```dart
  class PlantModel extends Plant {
    factory PlantModel.fromJson(Map<String, dynamic> json) { }
    Map<String, dynamic> toJson() { }
  }
  ```

- **Data Sources**: 
  - **Local**: Drift ORM (SQL type-safe)
  - **Remote**: Firebase/REST API

- **Repositories**: Implement domain interfaces
  ```dart
  class PlantsRepositoryImpl implements IPlantsRepository {
    @override
    Future<Either<Failure, List<Plant>>> getPlants() async {
      // Offline-first: try local, sync with remote
    }
  }
  ```

### 3. **Presentation Layer** (UI + State Management)
- **Location**: `lib/features/[feature]/presentation/`
- **Only layer with Flutter imports**
- **State management**: Riverpod with code generation

**Key Components:**
- **Notifiers**: State management with `@riverpod`
  ```dart
  @riverpod
  class PlantsNotifier extends _$PlantsNotifier {
    @override
    FutureOr<List<Plant>> build() async {
      // Manage state lifecycle
    }
  }
  ```

- **Pages**: Screen widgets
- **Widgets**: Reusable UI components
- **Providers**: Riverpod dependency injection

## SOLID Principles Implementation

### 1. **Single Responsibility Principle (SRP)**

Each class has ONE reason to change:

```dart
// ✅ GOOD: Specialized notifiers
@riverpod
class TasksCrudNotifier { }       // CREATE, READ, UPDATE, DELETE
@riverpod
class TasksQueryNotifier { }      // SEARCH, FILTER, SORT
@riverpod
class TasksScheduleNotifier { }   // RECURRING, REMINDERS

// ❌ BAD: God object handling everything
@riverpod
class TasksNotifier {
  // CRUD + Query + Schedule = 3 reasons to change
}
```

**Service Pattern** (SRP for Business Logic):
```dart
// Each service has ONE responsibility
abstract class IScheduleService {
  DateTime? calculateNextDueDate(...);
  bool isOverdue(DateTime? dueDate);
}

abstract class ITaskFilterService {
  List<Task> applyFilters(...);
}

abstract class ITaskRecommendationService {
  List<Task> getHighPriorityTasks(...);
}
```

### 2. **Open/Closed Principle (OCP)**

Classes are:
- **Open for extension**: Can add new behaviors
- **Closed for modification**: Don't change existing code

```dart
// ✅ GOOD: Use polymorphism instead of if/else
abstract class TaskFilter {
  List<Task> filter(List<Task> tasks);
}

class PriorityFilter extends TaskFilter { }
class StatusFilter extends TaskFilter { }
class PlantFilter extends TaskFilter { }

// Adding new filter doesn't modify existing code
class DateRangeFilter extends TaskFilter { }

// ❌ BAD: Modify existing code to add behavior
List<Task> filterTasks(List<Task> tasks, String filterType) {
  if (filterType == 'priority') { }
  else if (filterType == 'status') { }
  else if (filterType == 'plant') { }
  // Need to add else if for new filters
}
```

### 3. **Liskov Substitution Principle (LSP)**

Subtypes must be substitutable for base types:

```dart
// ✅ GOOD: Can use any TaskFilterService
abstract class ITaskFilterService {
  List<Task> applyFilters(...);
}

// Both can be used interchangeably
class TaskFilterService implements ITaskFilterService { }
class AdvancedTaskFilterService implements ITaskFilterService { }

// Consumer doesn't know/care about implementation
final notifier = TasksQueryNotifier(ref.watch(taskFilterServiceProvider));
```

### 4. **Interface Segregation Principle (ISP)**

Clients depend on specific interfaces, not general ones:

```dart
// ✅ GOOD: Segregated interfaces
abstract class ITasksCrudRepository {
  Future<Either<Failure, void>> addTask(Task task);
  Future<Either<Failure, void>> updateTask(Task task);
  Future<Either<Failure, void>> deleteTask(String id);
}

abstract class ITasksQueryRepository {
  Future<Either<Failure, List<Task>>> getTasks();
  Future<Either<Failure, List<Task>>> searchTasks(String query);
  Future<Either<Failure, Task>> getTaskById(String id);
}

// ❌ BAD: Fat interface
abstract class ITasksRepository {
  Future<Either<Failure, void>> addTask(Task task);
  Future<Either<Failure, void>> updateTask(Task task);
  Future<Either<Failure, void>> deleteTask(String id);
  Future<Either<Failure, List<Task>>> getTasks();
  Future<Either<Failure, List<Task>>> searchTasks(String query);
}
```

### 5. **Dependency Inversion Principle (DIP)**

Depend on abstractions, not concretions:

```dart
// ✅ GOOD: Injected through Riverpod (DIP)
@riverpod
ITaskFilterService taskFilterServiceProvider(TaskFilterServiceRef ref) {
  return TaskFilterService();
}

@riverpod
class TasksQueryNotifier extends _$TasksQueryNotifier {
  late final ITaskFilterService _filterService;

  @override
  TasksState build() {
    _filterService = ref.read(taskFilterServiceProvider);
    return TasksState.initial();
  }
}

// ❌ BAD: Hard-coded dependency
class TasksQueryNotifier {
  final _filterService = TaskFilterService(); // Tight coupling
}
```

## Data Flow Pattern

```
User Interaction
      ↓
Riverpod Provider/Notifier (Presentation)
      ↓
Use Case (Domain)
      ↓
Repository (Domain interface → Data implementation)
      ↓
Data Source (Local/Remote)
      ↓
Model → Entity Conversion
      ↓
Either<Failure, T> Result
      ↓
State Update & UI Rebuild
```

## Error Handling Pattern

**Always use Either<Failure, T>**:

```dart
// Domain/Use Cases
Future<Either<Failure, Plant>> addPlant(Plant plant) async {
  // Validation
  if (plant.name.isEmpty) {
    return Left(ValidationFailure('Name cannot be empty'));
  }
  
  try {
    final result = await repository.addPlant(plant);
    return result.fold(
      (failure) => Left(failure),
      (plant) => Right(plant),
    );
  } catch (e) {
    return Left(ServerFailure(e.toString()));
  }
}

// UI Layer
plantsAsync.when(
  data: (plants) => PlantList(plants),
  loading: () => CircularProgressIndicator(),
  error: (error, _) => ErrorWidget(error: error),
);
```

## Failure Types Hierarchy

```dart
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}

class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(String message) : super(message);
}
```

## Key Design Patterns

### 1. **Repository Pattern**
Abstracts data sources and provides a clean interface to domain layer.

### 2. **Dependency Injection via Riverpod**
All dependencies are provided through Riverpod, enabling:
- Easy testing with overrides
- Lazy initialization
- Clear dependency graph

### 3. **Async State Management**
```dart
// AsyncValue handles loading/error/data automatically
final plantsAsync = ref.watch(plantsNotifierProvider);
plantsAsync.when(
  data: (plants) => PlantList(plants),
  loading: () => LoadingWidget(),
  error: (error, stack) => ErrorWidget(error),
);
```

### 4. **Specialized Services**
Each service handles ONE domain concern:
- ScheduleService: Task scheduling logic
- TaskFilterService: Filtering and search logic
- TaskRecommendationService: Smart recommendations
- TaskOwnershipValidator: Data ownership validation

## Testing Architecture

```
Test Structure:
├── test/
│   ├── features/
│   │   ├── tasks/
│   │   │   ├── domain/
│   │   │   │   ├── usecases/     (UseCase unit tests)
│   │   │   │   ├── services/     (Service unit tests)
│   │   │   │   └── repositories/ (Repository unit tests)
│   │   │   ├── data/
│   │   │   │   └── repositories/ (Implementation tests)
│   │   │   └── presentation/
│   │   │       └── notifiers/    (Notifier unit tests)
│   │   └── plants/
│   └── helpers/
│       ├── mocks.dart
│       └── test_fixtures.dart
```

**Testing Principles:**
- Use `ProviderContainer` for Riverpod testing
- Mock repositories with `mocktail`
- Use `TestFixtures` for consistent test data
- Aim for >80% coverage in domain/data layers

## File Organization Standards

```
lib/features/tasks/
├── domain/                    # Pure business logic
│   ├── entities/             # Core business models
│   │   └── task.dart
│   ├── repositories/         # Business contracts
│   │   ├── tasks_crud_repository.dart
│   │   └── tasks_query_repository.dart
│   ├── usecases/            # Business operations
│   │   ├── add_task_usecase.dart
│   │   └── complete_task_usecase.dart
│   └── services/            # Business helpers
│       ├── schedule_service.dart
│       ├── task_filter_service.dart
│       └── task_recommendation_service.dart
├── data/                    # Data access layer
│   ├── datasources/         # Local/Remote
│   │   ├── local/
│   │   └── remote/
│   ├── models/             # DTOs
│   ├── mappers/            # Entity ↔ Model conversion
│   └── repositories/       # Repository implementations
└── presentation/           # UI + State
    ├── notifiers/          # Riverpod state
    ├── pages/              # Screens
    ├── widgets/            # Components
    ├── providers/          # Provider setup
    └── state/              # Local state classes
```

## Code Quality Metrics

**Target Metrics for Gold Standard (9.5/10):**
- **Lines per file**: Max 500
- **Lines per method**: Max 50
- **Test coverage**: ≥80% (domain + data)
- **Cyclomatic complexity**: <5 average per method
- **Dependencies**: Minimal coupling between features
- **Analyzer issues**: 0 errors, <10 warnings

## Summary

The architecture ensures:
1. **Testability**: All layers can be tested independently
2. **Maintainability**: Clear separation of concerns
3. **Extensibility**: Easy to add new features without modifying existing code
4. **Reusability**: Domain logic can be shared across apps
5. **Reliability**: Strong typing with Either<Failure, T> pattern
