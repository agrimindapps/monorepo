# New Feature Implementation Checklist

Complete this checklist before implementing any new feature in app-petiveti to maintain SOLID principles and architectural consistency.

---

## 📋 Pre-Implementation Planning (5 min)

- [ ] **Feature Scope**: Document what the feature does (1-2 sentences)
- [ ] **User Stories**: List the main user interactions
- [ ] **Data Model**: Sketch the entities (draw on paper or in Figma)
- [ ] **Dependencies**: Identify what APIs/databases are needed
- [ ] **Validation Rules**: List business logic validation rules

**Example for "Pet Weight Tracking"**:
```
Scope: Allow users to log and track pet weights over time
User Stories:
  - As a user, I can log a weight entry for a pet
  - As a user, I can view weight history with trends
  - As a user, I can set weight goals
Entities: Weight, Pet, WeightGoal
Dependencies: Drift database, Firebase sync
Validation: Weight > 0, Date <= today, Pet must exist
```

---

## 🏗️ Architecture Setup (10 min)

### Directory Structure
```
Create feature directory:
lib/features/[feature_name]/
├── domain/
│   ├── entities/
│   │   └── [entity].dart
│   ├── repositories/
│   │   └── [feature]_repository.dart
│   └── usecases/
│       └── [action]_[entity]_usecase.dart
├── data/
│   ├── models/
│   │   └── [entity]_model.dart
│   ├── datasources/
│   │   ├── local/
│   │   │   └── [feature]_local_datasource.dart
│   │   └── remote/
│   │       └── [feature]_remote_datasource.dart
│   └── repositories/
│       └── [feature]_repository_impl.dart
└── presentation/
    ├── providers/
    │   └── [feature]_providers.dart
    ├── notifiers/
    │   └── [feature]_notifier.dart
    ├── pages/
    │   └── [feature]_page.dart
    └── widgets/
        └── [feature]_widget.dart
```

### Create Files in Order

- [ ] **Domain Entities** (`domain/entities/[entity].dart`)
  ```dart
  import 'package:equatable/equatable.dart';

  class MyEntity extends Equatable {
    final String id;
    final String name;
    // ... other fields
    
    const MyEntity({required this.id, required this.name});
    
    @override
    List<Object?> get props => [id, name];
  }
  ```

- [ ] **Repository Interface** (`domain/repositories/[feature]_repository.dart`)
  ```dart
  import 'package:either_dart/either.dart';
  import '../entities/[entity].dart';

  abstract class [Feature]Repository {
    Future<Either<Failure, List<MyEntity>>> getItems();
    Future<Either<Failure, MyEntity>> getItemById(String id);
    Future<Either<Failure, void>> addItem(MyEntity item);
    Future<Either<Failure, void>> updateItem(MyEntity item);
    Future<Either<Failure, void>> deleteItem(String id);
  }
  ```

- [ ] **Use Cases** (`domain/usecases/[action]_[entity]_usecase.dart`)
  ```dart
  import 'package:either_dart/either.dart';
  import '../repositories/[feature]_repository.dart';

  class Get[Entity]sUseCase {
    final [Feature]Repository _repository;
    
    Get[Entity]sUseCase(this._repository);
    
    Future<Either<Failure, List<MyEntity>>> call() {
      return _repository.getItems();
    }
  }
  ```

---

## 🗄️ Data Layer Implementation (15 min)

- [ ] **Model** (`data/models/[entity]_model.dart`)
  ```dart
  import 'package:drift/drift.dart';
  import '../../domain/entities/[entity].dart';

  class MyEntityModel extends MyEntity {
    const MyEntityModel({
      required super.id,
      required super.name,
    });
    
    // JSON serialization
    factory MyEntityModel.fromJson(Map<String, dynamic> json) {
      return MyEntityModel(
        id: json['id'],
        name: json['name'],
      );
    }
    
    Map<String, dynamic> toJson() => {
      'id': id,
      'name': name,
    };
  }
  ```

- [ ] **Local DataSource** (`data/datasources/local/[feature]_local_datasource.dart`)
  - Uses Drift DAO for database operations
  - Implements offlineLocal persistence
  - Never throws exceptions (returns Either)

- [ ] **Remote DataSource** (`data/datasources/remote/[feature]_remote_datasource.dart`)
  - Uses Firebase or REST API
  - Handles network errors gracefully
  - Never throws exceptions (returns Either)

- [ ] **Repository Implementation** (`data/repositories/[feature]_repository_impl.dart`)
  ```dart
  class [Feature]RepositoryImpl implements [Feature]Repository {
    final [Feature]LocalDataSource _local;
    final [Feature]RemoteDataSource _remote;
    
    [Feature]RepositoryImpl(this._local, this._remote);
    
    @override
    Future<Either<Failure, List<MyEntity>>> getItems() async {
      try {
        // Try remote first
        final remote = await _remote.getItems();
        await _local.cacheItems(remote);
        return Right(remote);
      } catch (e) {
        // Fall back to local
        try {
          final cached = await _local.getItems();
          return Right(cached);
        } catch (_) {
          return Left(ServerFailure('No data available'));
        }
      }
    }
  }
  ```

---

## 📊 Presentation Layer Setup (10 min)

- [ ] **State Class** (if needed)
  - Extend `AsyncStateBase<T>` for async operations
  - Extend `PaginatedStateBase<T>` for lists
  - Include domain-specific properties

- [ ] **Notifier** (`presentation/notifiers/[feature]_notifier.dart`)
  ```dart
  @riverpod
  class [Feature]Notifier extends _$[Feature]Notifier {
    @override
    FutureOr<List<MyEntity>> build() async {
      // Load initial data
      final result = await ref.read([featureRepositoryProvider]).getItems();
      
      return result.fold(
        (failure) => throw Exception(failure.message),
        (items) => items,
      );
    }
    
    // Action methods
    Future<void> addItem(MyEntity item) async {
      // Implementation
    }
  }
  ```

- [ ] **Provider Setup** (`presentation/providers/[feature]_providers.dart`)
  ```dart
  @riverpod
  [Feature]Repository [featureRepository]([FeatureRepositoryRef] ref) {
    return [Feature]RepositoryImpl(
      ref.watch([featureLocalDataSourceProvider]),
      ref.watch([featureRemoteDataSourceProvider]),
    );
  }
  ```

- [ ] **Page/Widget** (`presentation/pages/[feature]_page.dart`)
  - Use `ConsumerWidget` or `ConsumerStatefulWidget`
  - Watch providers for state
  - Handle loading/error/data states via `.when()`

---

## 🧪 Testing Setup (5 min)

- [ ] **Create Test Files**
  ```
  test/
  └── features/
      └── [feature]/
          ├── domain/
          │   └── usecases/
          │       └── [action]_[entity]_usecase_test.dart
          ├── data/
          │   ├── datasources/
          │   │   └── [feature]_local_datasource_test.dart
          │   └── repositories/
          │       └── [feature]_repository_impl_test.dart
          └── presentation/
              └── notifiers/
                  └── [feature]_notifier_test.dart
  ```

- [ ] **Unit Test Notifier** (minimum)
  ```dart
  void main() {
    test('should load items successfully', () async {
      final mockRepo = Mock[Feature]Repository();
      when(mockRepo.getItems()).thenAnswer(
        (_) async => Right([mockItem1, mockItem2]),
      );
      
      final container = ProviderContainer(
        overrides: [
          [featureRepositoryProvider].overrideWithValue(mockRepo),
        ],
      );
      
      final result = await container.read([featureNotifierProvider].future);
      expect(result, [mockItem1, mockItem2]);
    });
  }
  ```

---

## ✅ SOLID Compliance Checklist

Before marking feature as complete:

### Single Responsibility (SRP)
- [ ] Each notifier handles ONE type of operation (CRUD, Filter, Sort, etc.)
- [ ] Each repository interface has ONE concern
- [ ] Each service has ONE responsibility
- [ ] Each use case does ONE thing

**Ask**: "How many reasons would this class need to change?"
**Answer**: Should be only ONE

### Open/Closed (OCP)
- [ ] State classes extend base classes (AsyncStateBase, etc.)
- [ ] Services use generic types or inheritance
- [ ] Can add new features without modifying existing ones
- [ ] New feature variants extend, not modify

**Ask**: "Can I add new types without changing existing code?"
**Answer**: Should be YES

### Liskov Substitution (LSP)
- [ ] All repository implementations return `Either<Failure, T>`
- [ ] All notifiers follow same state pattern
- [ ] All data sources return consistent types
- [ ] No breaking implementations

**Ask**: "Can any implementation be substituted for its interface?"
**Answer**: Should be YES - no surprises

### Interface Segregation (ISP)
- [ ] Repositories have narrow, focused interfaces
- [ ] Clients don't depend on methods they don't use
- [ ] Split large repositories into multiple small ones if needed
- [ ] Each use case depends ONLY on needed methods

**Ask**: "Does my client need ALL methods in this interface?"
**Answer**: Should be YES - if not, split interface

### Dependency Inversion (DIP)
- [ ] Zero direct singleton access (no `.instance`)
- [ ] All dependencies injected via providers
- [ ] Can easily replace with mock implementations
- [ ] Provider overrides work for testing

**Ask**: "Can I test this without hitting real APIs?"
**Answer**: Should be YES - mock via providers

---

## 📝 Code Quality Checklist

- [ ] **Analyzer**: `flutter analyze` shows zero errors for this feature
- [ ] **Naming**: Classes/methods clearly describe responsibility
- [ ] **Comments**: Only critical sections have inline comments
- [ ] **Max Length**: Files max 500 lines, methods max 50 lines
- [ ] **Imports**: No circular dependencies
- [ ] **Constants**: Magic numbers extracted to named constants
- [ ] **Error Handling**: All exceptions return Either<Failure, T>
- [ ] **Formatting**: Code formatted with `dart format .`

---

## 📚 Documentation Checklist

- [ ] **README**: Feature brief (2-3 sentences) if complex
- [ ] **Inline Comments**: Critical SOLID patterns explained
- [ ] **Patterns**: Follow patterns from PATTERNS.md
- [ ] **Examples**: Code matches examples in ARCHITECTURE.md

---

## 🚀 Integration Checklist

- [ ] **Navigation**: Routes added to router if needed
- [ ] **Di Module**: Feature module registered if using GetIt
- [ ] **Exports**: Barrel exports created if public API
- [ ] **Dependencies**: pubspec.yaml updated if new packages
- [ ] **Localization**: i18n strings added if user-facing text
- [ ] **Theming**: Uses app theme (colors, typography)
- [ ] **Analytics**: Track key user actions

---

## 🧪 Pre-Submission Checklist

- [ ] Feature implemented from top (domain) to bottom (UI)
- [ ] All tests pass: `flutter test`
- [ ] No analyzer errors: `flutter analyze`
- [ ] Code formatted: `dart format lib/`
- [ ] Screenshots/GIFs added (if UI feature)
- [ ] Tested on both Android and iOS
- [ ] Works offline (if applicable)
- [ ] Tested with large datasets
- [ ] No console warnings/errors
- [ ] Commit message follows conventions

---

## 📋 Final Review Checklist

When submitting PR:

1. **Architecture**
   - [ ] Follows Clean Architecture pattern
   - [ ] Domain layer has no Flutter dependencies
   - [ ] Data layer independent of UI layer
   - [ ] Presentation layer uses providers

2. **SOLID Principles**
   - [ ] SRP: Each class has one responsibility
   - [ ] OCP: Extended, not modified existing code
   - [ ] LSP: Implementations honor contracts
   - [ ] ISP: Segregated interfaces
   - [ ] DIP: Dependencies injected via providers

3. **Code Quality**
   - [ ] No analyzer errors
   - [ ] No code comments needed (code is self-explanatory)
   - [ ] > 80% test coverage for domain/data
   - [ ] Consistent naming conventions
   - [ ] No code duplication

4. **Testing**
   - [ ] Unit tests for use cases (100% coverage)
   - [ ] Unit tests for repository (happy path + error cases)
   - [ ] Widget tests for key pages
   - [ ] Manual testing on device
   - [ ] Tested error scenarios

5. **Documentation**
   - [ ] ARCHITECTURE.md updated if patterns changed
   - [ ] Inline comments for complex logic
   - [ ] CHANGELOG entry if applicable

---

## 🔗 Quick Reference Links

- **Architecture Guide**: [ARCHITECTURE.md](./ARCHITECTURE.md)
- **SOLID Patterns**: [PATTERNS.md](./PATTERNS.md)
- **app-plantis Gold Standard**: Refer to `/apps/app-plantis` for 10/10 reference
- **Riverpod Docs**: https://riverpod.dev
- **Clean Architecture**: https://www.freecodecamp.org/news/clean-architecture-in-android-development/

---

## 💡 Common Mistakes to Avoid

1. ❌ **Mixing Layers**: Domain depends on Flutter → Should have no Flutter imports
2. ❌ **God Objects**: Notifier handles CRUD + Filter + Sort → Split into separate notifiers
3. ❌ **Direct Singleton Access**: `LoggingService.instance` → Should inject via provider
4. ❌ **Throwing Exceptions**: `throw Exception()` in repositories → Return `Left(Failure)`
5. ❌ **UI Logic in Repository**: Formatting strings, colors → Belongs in presentation
6. ❌ **Circular Dependencies**: Feature A imports Feature B which imports Feature A
7. ❌ **No Error Handling**: Assume everything succeeds → Must handle failures
8. ❌ **Hardcoded Values**: Magic strings/numbers → Extract to constants
9. ❌ **Massive Methods**: 100+ line methods → Max 50 lines
10. ❌ **Over-Engineering**: Simple feature with 20 files → Keep it simple

---

## ✨ Example: Complete "Add Animal" Feature

Follow this complete example to implement "Add Animal" feature:

### Step 1: Domain Entities
```dart
// lib/features/animals/domain/entities/animal.dart
class Animal extends Equatable {
  final String id;
  final String name;
  final String species;
  final DateTime createdAt;
  
  const Animal({
    required this.id,
    required this.name,
    required this.species,
    required this.createdAt,
  });
  
  @override
  List<Object?> get props => [id, name, species, createdAt];
}
```

### Step 2: Repository Interface
```dart
// lib/features/animals/domain/repositories/animal_crud_repository.dart
abstract class AnimalCrudRepository {
  Future<Either<Failure, void>> addAnimal(Animal animal);
}
```

### Step 3: Use Case
```dart
// lib/features/animals/domain/usecases/add_animal_usecase.dart
class AddAnimalUseCase {
  final AnimalCrudRepository _repository;
  
  AddAnimalUseCase(this._repository);
  
  Future<Either<Failure, void>> call(Animal animal) {
    // Validation
    if (animal.name.isEmpty) {
      return Left(ValidationFailure('Name cannot be empty'));
    }
    return _repository.addAnimal(animal);
  }
}
```

### Step 4: Repository Implementation
```dart
// lib/features/animals/data/repositories/animal_repository_impl.dart
class AnimalRepositoryImpl implements AnimalCrudRepository {
  final AnimalLocalDataSource _local;
  final AnimalRemoteDataSource _remote;
  
  @override
  Future<Either<Failure, void>> addAnimal(Animal animal) async {
    try {
      await _local.addAnimal(animal);
      if (await _isOnline()) {
        await _remote.addAnimal(animal);
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
```

### Step 5: Notifier
```dart
// lib/features/animals/presentation/notifiers/animals_crud_notifier.dart
@riverpod
class AnimalsCrudNotifier extends _$AnimalsCrudNotifier {
  @override
  Future<void> build() async {}
  
  Future<void> addAnimal(Animal animal) async {
    final useCase = ref.read(addAnimalUseCaseProvider);
    final result = await useCase(animal);
    
    result.fold(
      (failure) => throw Exception(failure.message),
      (_) => ref.invalidate(animalsNotifierProvider),
    );
  }
}
```

### Step 6: Provider
```dart
// lib/features/animals/presentation/providers/animals_providers.dart
@riverpod
AddAnimalUseCase addAnimalUseCase(AddAnimalUseCaseRef ref) {
  return AddAnimalUseCase(ref.watch(animalRepositoryProvider));
}
```

### Step 7: Widget
```dart
// lib/features/animals/presentation/pages/add_animal_page.dart
class AddAnimalPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Animal')),
      body: AddAnimalForm(),
    );
  }
}

class AddAnimalForm extends ConsumerStatefulWidget {
  @override
  ConsumerState<AddAnimalForm> createState() => _AddAnimalFormState();
}

class _AddAnimalFormState extends ConsumerState<AddAnimalForm> {
  final _nameController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Animal Name'),
          ),
          ElevatedButton(
            onPressed: _submit,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _submit() async {
    final animal = Animal(
      id: const Uuid().v4(),
      name: _nameController.text,
      species: 'Dog',
      createdAt: DateTime.now(),
    );
    
    await ref.read(animalsCrudNotifierProvider.notifier).addAnimal(animal);
    
    if (mounted) Navigator.pop(context);
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
```

### Step 8: Test
```dart
// test/features/animals/domain/usecases/add_animal_usecase_test.dart
void main() {
  late AddAnimalUseCase useCase;
  late MockAnimalCrudRepository mockRepository;
  
  setUp(() {
    mockRepository = MockAnimalCrudRepository();
    useCase = AddAnimalUseCase(mockRepository);
  });
  
  test('should add animal successfully', () async {
    final animal = Animal(
      id: '1',
      name: 'Fluffy',
      species: 'Dog',
      createdAt: DateTime.now(),
    );
    
    when(mockRepository.addAnimal(animal))
        .thenAnswer((_) async => const Right(null));
    
    final result = await useCase(animal);
    
    expect(result.isRight(), true);
    verify(mockRepository.addAnimal(animal)).called(1);
  });
  
  test('should return ValidationFailure for empty name', () async {
    final animal = Animal(
      id: '1',
      name: '',
      species: 'Dog',
      createdAt: DateTime.now(),
    );
    
    final result = await useCase(animal);
    
    expect(result.isLeft(), true);
    expect(result.fold((f) => f, (_) => null), isA<ValidationFailure>());
    verifyNever(mockRepository.addAnimal(any()));
  });
}
```

---

**That's it! Follow this checklist for every new feature and you'll maintain 9.5/10 SOLID compliance.**
