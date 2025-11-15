# New Feature Checklist for app-plantis

This guide walks you through adding a new feature to app-plantis while maintaining SOLID principles and app-plantis quality standards.

## Pre-Development

### 1. Feature Definition ✓
- [ ] Write feature specification with use cases
- [ ] Define user stories
- [ ] Identify data entities
- [ ] Plan API/data source needs
- [ ] Document error scenarios

### 2. Architecture Planning ✓
- [ ] Draw data flow diagram
- [ ] Identify domain entities
- [ ] Plan repository interfaces
- [ ] List use cases
- [ ] Identify shared services needed

---

## Domain Layer Development

### 3. Create Entities ✓

**File**: `lib/features/[feature]/domain/entities/[entity].dart`

```dart
import 'package:core/core.dart';

/// [EntityName] - Core business entity
///
/// Represents [what this entity is about]
class EntityName extends Equatable {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const EntityName({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, name, createdAt, updatedAt];

  /// Creates a copy with optional field overrides
  EntityName copyWith({
    String? name,
    DateTime? updatedAt,
  }) {
    return EntityName(
      id: id,
      name: name ?? this.name,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
```

**Checklist**:
- [ ] No Flutter imports
- [ ] Extends `Equatable`
- [ ] Has `copyWith()` method
- [ ] Has `props` getter
- [ ] Has clear documentation

### 4. Create Repository Interfaces ✓

**File**: `lib/features/[feature]/domain/repositories/[feature]_crud_repository.dart`

```dart
import 'package:dartz/dartz.dart';
import 'package:core/core.dart';

/// ISG: Interface Segregation - Separate CRUD from Query
abstract class I[Feature]CrudRepository {
  /// Create
  Future<Either<Failure, Entity>> add[Entity](Entity entity);
  
  /// Update
  Future<Either<Failure, Entity>> update[Entity](Entity entity);
  
  /// Delete
  Future<Either<Failure, void>> delete[Entity](String id);
}
```

**File**: `lib/features/[feature]/domain/repositories/[feature]_query_repository.dart`

```dart
import 'package:dartz/dartz.dart';
import 'package:core/core.dart';

/// ISG: Interface Segregation - Query operations only
abstract class I[Feature]QueryRepository {
  /// Read all
  Future<Either<Failure, List<Entity>>> get[Entities]();
  
  /// Read by ID
  Future<Either<Failure, Entity>> get[Entity]ById(String id);
  
  /// Search
  Future<Either<Failure, List<Entity>>> search[Entities](String query);
  
  /// Get statistics
  Future<Either<Failure, Map<String, dynamic>>> getStatistics();
}
```

**Checklist**:
- [ ] Segregated CRUD and Query interfaces (ISP)
- [ ] All methods return `Either<Failure, T>`
- [ ] Clear, specific method names
- [ ] No implementation details
- [ ] Documented with /// comments

### 5. Create Domain Services (if needed) ✓

**File**: `lib/features/[feature]/domain/services/[service_name]_service.dart`

```dart
/// I[ServiceName]Service - Handles [responsibility]
///
/// Responsibilities (SRP):
/// - [responsibility 1]
/// - [responsibility 2]
///
/// Injected via Riverpod (DIP)
abstract class I[ServiceName]Service {
  /// [Method description]
  [ReturnType] [methodName]([parameters]);
}

class [ServiceName]Service implements I[ServiceName]Service {
  @override
  [ReturnType] [methodName]([parameters]) {
    // Implementation
  }
}
```

**Checklist**:
- [ ] SRP: One service per responsibility
- [ ] Interface with abstract class
- [ ] Less than 250 lines
- [ ] Clear documentation of responsibilities
- [ ] No business logic duplication

### 6. Create Use Cases ✓

**File**: `lib/features/[feature]/domain/usecases/[operation]_usecase.dart`

```dart
import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../entities/entity.dart';
import '../repositories/repository.dart';

/// Add[Entity]Params - Input parameters (Params pattern)
class Add[Entity]Params extends Equatable {
  final String name;
  final String? description;
  
  const Add[Entity]Params({
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [name, description];
}

/// Add[Entity]UseCase - SRP: Only adds [entity]
class Add[Entity]UseCase {
  final I[Feature]CrudRepository _repository;
  
  Add[Entity]UseCase(this._repository);
  
  Future<Either<Failure, Entity>> call(Add[Entity]Params params) async {
    // 1. Validate
    if (params.name.trim().isEmpty) {
      return const Left(ValidationFailure('Name cannot be empty'));
    }
    
    if (params.name.trim().length < 2) {
      return const Left(
        ValidationFailure('Name must be at least 2 characters'),
      );
    }
    
    try {
      // 2. Create entity
      final entity = Entity(
        id: const Uuid().v4(),
        name: params.name.trim(),
        description: params.description?.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // 3. Persist
      return await _repository.add[Entity](entity);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
```

**Checklist**:
- [ ] SRP: One operation per use case
- [ ] Input: Params class extending Equatable
- [ ] Output: Either<Failure, T>
- [ ] Has validation
- [ ] Handles errors with Either
- [ ] Clear documentation

---

## Data Layer Development

### 7. Create Models ✓

**File**: `lib/features/[feature]/data/models/[entity]_model.dart`

```dart
import 'package:core/core.dart';
import '../../domain/entities/entity.dart';

/// [Entity]Model - Data Transfer Object for [entity]
class [Entity]Model extends Entity {
  const [Entity]Model({
    required super.id,
    required super.name,
    required super.createdAt,
    required super.updatedAt,
  });

  factory [Entity]Model.fromJson(Map<String, dynamic> json) {
    return [Entity]Model(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  /// Convert model to entity
  Entity toEntity() => Entity(
    id: id,
    name: name,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
```

**Checklist**:
- [ ] Extends domain Entity
- [ ] Has `fromJson()` constructor
- [ ] Has `toJson()` method
- [ ] Has `toEntity()` conversion
- [ ] Proper type safety

### 8. Create Data Sources ✓

**File**: `lib/features/[feature]/data/datasources/local/[entity]_local_datasource.dart`

```dart
abstract class I[Entity]LocalDataSource {
  Future<List<[Entity]Model>> get[Entities]();
  Future<[Entity]Model> add[Entity]([Entity]Model model);
  Future<[Entity]Model> update[Entity]([Entity]Model model);
  Future<void> delete[Entity](String id);
}

class [Entity]LocalDataSourceImpl implements I[Entity]LocalDataSource {
  final PlantisDatabase _database;
  
  [Entity]LocalDataSourceImpl(this._database);
  
  @override
  Future<List<[Entity]Model>> get[Entities]() async {
    // Drift query implementation
  }
  
  @override
  Future<[Entity]Model> add[Entity]([Entity]Model model) async {
    // Drift insert implementation
  }
  
  // ... other methods
}
```

**Checklist**:
- [ ] Interfaces defined
- [ ] Local and Remote data sources
- [ ] Proper error handling
- [ ] Type-safe queries (Drift)

### 9. Create Repository Implementations ✓

**File**: `lib/features/[feature]/data/repositories/[feature]_crud_repository_impl.dart`

```dart
import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../../domain/repositories/[feature]_crud_repository.dart';
import '../datasources/[entity]_local_datasource.dart';
import '../models/[entity]_model.dart';

class [Feature]CrudRepositoryImpl implements I[Feature]CrudRepository {
  final I[Entity]LocalDataSource _localDataSource;
  
  [Feature]CrudRepositoryImpl(this._localDataSource);
  
  @override
  Future<Either<Failure, Entity>> add[Entity](Entity entity) async {
    try {
      final model = [Entity]Model.fromEntity(entity);
      final result = await _localDataSource.add[Entity](model);
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  // ... other methods
}
```

**Checklist**:
- [ ] Implements domain repository interface
- [ ] All methods return Either<Failure, T>
- [ ] Handles errors gracefully
- [ ] Converts Model ↔ Entity

---

## Presentation Layer Development

### 10. Create Riverpod Providers ✓

**File**: `lib/features/[feature]/presentation/providers/[feature]_providers.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/[feature]_crud_repository.dart';
import '../../domain/repositories/[feature]_query_repository.dart';
import '../../data/repositories/[feature]_crud_repository_impl.dart';
import '../../data/repositories/[feature]_query_repository_impl.dart';
import '../../data/datasources/[entity]_local_datasource.dart';

// Datasource providers
@riverpod
I[Entity]LocalDataSource [entity]LocalDataSource(Ref ref) {
  final database = ref.watch(plantisDatabase);
  return [Entity]LocalDataSourceImpl(database);
}

// Repository providers
@riverpod
I[Feature]CrudRepository [feature]CrudRepository(Ref ref) {
  return [Feature]CrudRepositoryImpl(
    ref.watch([entity]LocalDataSourceProvider),
  );
}

@riverpod
I[Feature]QueryRepository [feature]QueryRepository(Ref ref) {
  return [Feature]QueryRepositoryImpl(
    ref.watch([entity]LocalDataSourceProvider),
  );
}

// UseCase providers
@riverpod
Add[Entity]UseCase add[Entity]UseCaseProvider(Ref ref) {
  return Add[Entity]UseCase(
    ref.watch([feature]CrudRepositoryProvider),
  );
}
```

**Checklist**:
- [ ] All providers use `@riverpod`
- [ ] Proper provider naming
- [ ] DIP: Depends on abstractions
- [ ] Clear dependency chain

### 11. Create Notifiers ✓

**File**: `lib/features/[feature]/presentation/notifiers/[feature]_notifier.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart' hide Column;

/// [Feature][Operation]Notifier - Handles [responsibility]
///
/// Responsibilities (SRP):
/// - [responsibility 1]
/// - [responsibility 2]
///
/// Does NOT handle:
/// - [other responsibility]
@riverpod
class [Feature][Operation]Notifier extends _$[Feature][Operation]Notifier {
  @override
  FutureOr<[State]> build() async {
    return [State].initial();
  }
  
  // Operations
  Future<void> [operation]() async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      final result = await _useCase(...);
      return result.fold(
        (failure) => throw failure,
        (data) => state.value?.copyWith(...),
      );
    });
  }
}
```

**Checklist**:
- [ ] SRP: One notifier per responsibility
- [ ] Uses AsyncValue for state
- [ ] Proper error handling
- [ ] Clear operation names
- [ ] Documentation of responsibilities

### 12. Create Pages/Widgets ✓

**File**: `lib/features/[feature]/presentation/pages/[feature]_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/[feature]_providers.dart';

class [Feature]Page extends ConsumerWidget {
  const [Feature]Page({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final [state]Async = ref.watch([featureNotifierProvider]);
    
    return Scaffold(
      appBar: AppBar(title: const Text('[Feature]')),
      body: [state]Async.when(
        data: (data) => [Widget](data),
        loading: () => const CircularProgressIndicator(),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
```

**Checklist**:
- [ ] Uses ConsumerWidget
- [ ] Watches appropriate providers
- [ ] Uses AsyncValue.when()
- [ ] Proper error handling
- [ ] Accessible design

---

## Testing

### 13. Create Unit Tests ✓

**File**: `test/features/[feature]/domain/usecases/[operation]_usecase_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

void main() {
  late [Operation]UseCase useCase;
  late MockRepository mockRepository;
  
  setUp(() {
    mockRepository = MockRepository();
    useCase = [Operation]UseCase(mockRepository);
  });
  
  group('[Operation]UseCase', () {
    test('should [success case]', () async {
      // Arrange
      when(() => mockRepository.[method]()).thenAnswer(
        (_) async => Right(expectedData),
      );
      
      // Act
      final result = await useCase(params);
      
      // Assert
      expect(result, Right(expectedData));
      verify(() => mockRepository.[method]()).called(1);
    });
    
    test('should [error case]', () async {
      // Arrange
      when(() => mockRepository.[method]()).thenAnswer(
        (_) async => const Left(failure),
      );
      
      // Act
      final result = await useCase(params);
      
      // Assert
      expect(result, const Left(failure));
    });
  });
}
```

**Checklist**:
- [ ] Unit tests for domain layer
- [ ] Repository tests
- [ ] UseCase tests
- [ ] Service tests
- [ ] At least 70% coverage
- [ ] Tests for success and error paths
- [ ] Edge case testing

### 14. Create Test Fixtures ✓

**File**: `test/helpers/test_fixtures.dart` (add to existing)

```dart
class TestFixtures {
  static [Entity] createTest[Entity]({
    String id = 'test-[entity]-1',
    String name = 'Test [Entity]',
    // ... other fields
  }) {
    return [Entity](
      id: id,
      name: name,
      // ... assign fields
    );
  }
  
  static List<[Entity]> createTest[Entities]({int count = 3}) {
    return List.generate(
      count,
      (index) => createTest[Entity](
        id: '[entity]-$index',
        name: 'Test [Entity] $index',
      ),
    );
  }
}
```

**Checklist**:
- [ ] Shared test data
- [ ] Consistent test data
- [ ] Helper methods for complex objects

---

## Documentation

### 15. Add Code Comments ✓

**Key areas to comment:**
- [ ] Complex business logic in services
- [ ] SRP explanations in notifiers
- [ ] ISP comments in repositories
- [ ] Non-obvious validation rules
- [ ] Edge cases handled

Example:
```dart
/// TasksCrudNotifier - Handles CREATE, READ, UPDATE, DELETE operations
///
/// Responsibilities (SRP):
/// - addTask() - Add new task with offline support
/// - completeTask() - Complete task with ownership validation
/// - deleteTask() - Delete task
///
/// Does NOT handle:
/// - Listing, filtering, searching (see TasksQueryNotifier)
/// - Recurring/scheduling (see TasksScheduleNotifier)
@riverpod
class TasksCrudNotifier extends _$TasksCrudNotifier {
  // ...
}
```

### 16. Update README ✓

**File**: `README.md`

Add to features section:
```markdown
### [Feature Name]
- [Brief description]
- [Key entities]
- [Main operations]
- [Relevant files]
```

**Checklist**:
- [ ] Feature described
- [ ] Key components listed
- [ ] Example usage if applicable

---

## Final Validation

### 17. Code Quality Checks ✓

```bash
# Run analyzer
flutter analyze

# Run tests
flutter test

# Check coverage
flutter test --coverage

# Format code
dart format lib/features/[feature]
```

**Checklist**:
- [ ] 0 analyzer errors
- [ ] All tests passing
- [ ] >70% coverage
- [ ] Code properly formatted
- [ ] No unused imports

### 18. SOLID Principles Review ✓

- [ ] **SRP**: Each class has ONE reason to change
- [ ] **OCP**: Open for extension, closed for modification
- [ ] **LSP**: All implementations honor contracts
- [ ] **ISP**: Interfaces are specific and focused
- [ ] **DIP**: Dependencies injected via Riverpod

### 19. Architecture Review ✓

- [ ] Domain layer: 0 external dependencies
- [ ] Data layer: Implements domain interfaces
- [ ] Presentation layer: Uses Riverpod providers
- [ ] Error handling: Either<Failure, T> everywhere
- [ ] State management: AsyncValue for async operations

---

## Troubleshooting

**Common Issues:**

1. **"Analyzer errors about missing implementations"**
   - Ensure repository implementations have all required methods
   - Check interface signatures match implementation

2. **"Tests not finding mocks"**
   - Register fallback values: `registerFallbackValue(...)`
   - Ensure mock classes extend Mock

3. **"Widget not rebuilding on state change"**
   - Use `ref.watch()` not `ref.read()` in widgets
   - Check provider keys are correct

4. **"Type errors in models"**
   - Ensure JSON keys match field names
   - Add explicit type casting if needed

---

## Summary Checklist

- [ ] Domain: Entities, Repositories, UseCases, Services (No Flutter)
- [ ] Data: Models, DataSources, Repository Implementations
- [ ] Presentation: Providers, Notifiers, Pages, Widgets
- [ ] Tests: >70% coverage, All layers tested
- [ ] Documentation: Architecture, Patterns, README updated
- [ ] Quality: 0 errors, SOLID principles applied
- [ ] Code comments: Non-obvious logic documented

You're ready to merge! 🎉
