# New Feature Checklist - How to Add Features to app-receituagro

This guide ensures all new features follow SOLID principles and the established architecture.

---

## 📋 Feature Development Checklist

### **Phase 1: Planning**

- [ ] **Define Use Case**: What is the feature doing? (Single responsibility)
- [ ] **Identify Entities**: What data models are needed?
- [ ] **Plan Repository Interface**: What CRUD/Query operations are needed?
- [ ] **Identify Failures**: What can go wrong? (Validation, Network, Cache, etc.)
- [ ] **Design Services**: Do I need specialized services? (Filtering, Stats, etc.)

**Example: "Add Plant Favorites"**
- Use Case: Allow users to mark plants as favorites
- Entity: `Favorito { id, userId, itemId, itemType, createdAt }`
- Repository: `IFavoritoCrudRepository`, `IFavoritoQueryRepository`
- Failures: `ValidationFailure`, `RepositoryFailure`
- Services: `FilterService` (search favorites)

---

### **Phase 2: Domain Layer** (`lib/features/[feature]/domain/`)

- [ ] Create `entities/` folder
  - [ ] Define core entity with `@immutable` and `Equatable`
  - [ ] Implement `copyWith()` method
  - [ ] Example: `lib/features/favoritos/domain/entities/favorito_entity.dart`

```dart
@immutable
class FavoritoEntity extends Equatable {
  final String id;
  final String userId;
  final String itemId;
  final String itemType;
  final DateTime createdAt;
  
  const FavoritoEntity({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.itemType,
    required this.createdAt,
  });
  
  FavoritoEntity copyWith({
    String? userId,
    String? itemId,
    String? itemType,
  }) => FavoritoEntity(
    id: id,
    userId: userId ?? this.userId,
    itemId: itemId ?? this.itemId,
    itemType: itemType ?? this.itemType,
    createdAt: createdAt,
  );
  
  @override
  List<Object?> get props => [id, userId, itemId, itemType, createdAt];
}
```

- [ ] Create `repositories/` folder
  - [ ] Define repository interface(s) - apply ISP!
  - [ ] Create separate CRUD and Query interfaces if needed
  - [ ] Example: `lib/features/favoritos/domain/repositories/i_favorito_repository.dart`

```dart
// ISP: Separate CRUD and Query concerns
abstract class IFavoritoCrudRepository {
  Future<Either<Failure, Favorito>> add(Favorito favorito);
  Future<Either<Failure, void>> delete(String id);
  Future<Either<Failure, List<Favorito>>> getAll();
}

abstract class IFavoritoQueryRepository {
  Future<Either<Failure, List<Favorito>>> search(String term);
  Future<Either<Failure, int>> count();
  Future<Either<Failure, bool>> exists(String id);
}
```

- [ ] Create `failures/` folder (if not in core)
  - [ ] Define specific failure types
  - [ ] Example: `ValidationFailure`, `RepositoryFailure`

```dart
abstract class Failure {
  final String message;
  Failure(this.message);
}

class ValidationFailure extends Failure {
  ValidationFailure(String message) : super(message);
}

class RepositoryFailure extends Failure {
  RepositoryFailure(String message) : super(message);
}
```

- [ ] Create `usecases/` folder
  - [ ] One use case per file (SRP)
  - [ ] Implement validation in use cases
  - [ ] Return `Either<Failure, T>`
  - [ ] Example: `lib/features/favoritos/domain/usecases/add_favorito_usecase.dart`

```dart
class AddFavoritoUseCase {
  final IFavoritoCrudRepository _repository;
  
  AddFavoritoUseCase(this._repository);
  
  Future<Either<Failure, Favorito>> call(Favorito favorito) async {
    // Validate
    if (favorito.userId.isEmpty) {
      return Left(ValidationFailure('User ID is required'));
    }
    if (favorito.itemId.isEmpty) {
      return Left(ValidationFailure('Item ID is required'));
    }
    
    // Execute
    return _repository.add(favorito);
  }
}
```

---

### **Phase 3: Data Layer** (`lib/features/[feature]/data/`)

- [ ] Create `models/` folder
  - [ ] Create DTO with `fromJson()` and `toJson()`
  - [ ] Extends domain entity
  - [ ] Example: `lib/features/favoritos/data/models/favorito_model.dart`

```dart
@immutable
class FavoritoModel extends FavoritoEntity {
  const FavoritoModel({
    required String id,
    required String userId,
    required String itemId,
    required String itemType,
    required DateTime createdAt,
  }) : super(
    id: id,
    userId: userId,
    itemId: itemId,
    itemType: itemType,
    createdAt: createdAt,
  );
  
  factory FavoritoModel.fromJson(Map<String, dynamic> json) =>
      FavoritoModel(
        id: json['id'],
        userId: json['userId'],
        itemId: json['itemId'],
        itemType: json['itemType'],
        createdAt: DateTime.parse(json['createdAt']),
      );
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'itemId': itemId,
    'itemType': itemType,
    'createdAt': createdAt.toIso8601String(),
  };
}
```

- [ ] Create `datasources/` folder
  - [ ] `local_datasource.dart`: Drift queries
  - [ ] `remote_datasource.dart`: Firebase/API calls
  - [ ] Example: `lib/features/favoritos/data/datasources/`

```dart
abstract class IFavoritoLocalDataSource {
  Future<List<FavoritoModel>> getAll();
  Future<FavoritoModel> add(FavoritoModel model);
  Future<void> delete(String id);
}

@LazySingleton(as: IFavoritoLocalDataSource)
class FavoritoLocalDataSource implements IFavoritoLocalDataSource {
  final ReceituagroDatabase _db;
  
  FavoritoLocalDataSource(this._db);
  
  @override
  Future<List<FavoritoModel>> getAll() async {
    final data = await _db.select(_db.favoritos).get();
    return data.map((raw) => FavoritoModel(
      id: raw.id,
      userId: raw.userId,
      // ... mapping
    )).toList();
  }
  
  // ... other methods
}
```

- [ ] Create `repositories/` folder
  - [ ] Implement domain repository interface
  - [ ] Use datasources (local first, then remote if needed)
  - [ ] Apply ISP (implement both CRUD and Query if needed)
  - [ ] Apply DIP (inject datasources via constructor)
  - [ ] Example: `lib/features/favoritos/data/repositories/favorito_repository_impl.dart`

```dart
@LazySingleton(as: IFavoritoCrudRepository)
class FavoritoCrudRepositoryImpl implements IFavoritoCrudRepository {
  final IFavoritoLocalDataSource _localDataSource;
  final IFavoritoRemoteDataSource _remoteDataSource;
  
  FavoritoCrudRepositoryImpl(this._localDataSource, this._remoteDataSource);
  
  @override
  Future<Either<Failure, Favorito>> add(Favorito favorito) async {
    try {
      final model = FavoritoModel(...favorito);
      await _localDataSource.add(model);
      
      // Sync with remote
      if (await _isConnected()) {
        await _remoteDataSource.add(model);
      }
      
      return Right(model);
    } catch (e) {
      return Left(RepositoryFailure('Failed to add: $e'));
    }
  }
  
  // ... other methods
}
```

---

### **Phase 4: Presentation Layer** (`lib/features/[feature]/presentation/`)

- [ ] Create `providers/` folder
  - [ ] Create Riverpod notifiers with `@riverpod`
  - [ ] Apply SRP: One notifier = One concern
  - [ ] Example: `lib/features/favoritos/presentation/providers/favoritos_notifier.dart`

```dart
@riverpod
class FavoritosNotifier extends _$FavoritosNotifier {
  late final GetFavoritosUseCase _getFavoritosUseCase;
  late final AddFavoritoUseCase _addFavoritoUseCase;
  late final DeleteFavoritoUseCase _deleteFavoritoUseCase;
  
  @override
  Future<List<Favorito>> build() async {
    _getFavoritosUseCase = di.sl<GetFavoritosUseCase>();
    _addFavoritoUseCase = di.sl<AddFavoritoUseCase>();
    _deleteFavoritoUseCase = di.sl<DeleteFavoritoUseCase>();
    
    final result = await _getFavoritosUseCase(userId);
    return result.fold(
      (failure) => throw failure,
      (favoritos) => favoritos,
    );
  }
  
  Future<void> addFavorito(Favorito favorito) async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      final result = await _addFavoritoUseCase(favorito);
      return result.fold(
        (failure) => throw failure,
        (_) async {
          // Reload list
          return await _getFavoritosUseCase(userId);
        },
      );
    });
  }
}
```

- [ ] Create `pages/` folder
  - [ ] Create screen with `ConsumerWidget` or `ConsumerStatefulWidget`
  - [ ] Use `ref.watch()` for async state
  - [ ] Example: `lib/features/favoritos/presentation/pages/favoritos_page.dart`

```dart
class FavoritosPage extends ConsumerWidget {
  const FavoritosPage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritosAsync = ref.watch(favoritosNotifierProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Favoritos')),
      body: favoritosAsync.when(
        data: (favoritos) {
          if (favoritos.isEmpty) {
            return const Center(child: Text('Nenhum favorito'));
          }
          return ListView.builder(
            itemCount: favoritos.length,
            itemBuilder: (context, index) {
              final favorito = favoritos[index];
              return ListTile(
                title: Text(favorito.name),
                onTap: () => _navigateToDetail(context, favorito.id),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
```

- [ ] Create `widgets/` folder
  - [ ] Create reusable UI components
  - [ ] Keep components focused (SRP)
  - [ ] Example: `lib/features/favoritos/presentation/widgets/favorito_card.dart`

---

### **Phase 5: Testing** (`test/features/[feature]/`)

- [ ] Create unit tests for use cases
  - [ ] Mock repository
  - [ ] Test validation
  - [ ] Test error handling
  - [ ] 80%+ coverage target
  - [ ] Example: `test/features/favoritos/domain/usecases/add_favorito_usecase_test.dart`

```dart
void main() {
  group('AddFavoritoUseCase', () {
    late MockIFavoritoCrudRepository mockRepository;
    late AddFavoritoUseCase useCase;
    
    setUp(() {
      mockRepository = MockIFavoritoCrudRepository();
      useCase = AddFavoritoUseCase(mockRepository);
    });
    
    test('should add favorito when data is valid', () async {
      // Arrange
      final favorito = Favorito(id: '1', userId: 'user-1', ...);
      when(() => mockRepository.add(favorito))
          .thenAnswer((_) async => Right(favorito));
      
      // Act
      final result = await useCase(favorito);
      
      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepository.add(favorito)).called(1);
    });
    
    test('should return ValidationFailure when userId is empty', () async {
      // Arrange
      final invalidFavorito = Favorito(id: '1', userId: '', ...);
      
      // Act
      final result = await useCase(invalidFavorito);
      
      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Should not succeed'),
      );
    });
  });
}
```

- [ ] Create widget tests
  - [ ] Test UI interactions
  - [ ] Mock notifiers
  - [ ] Example: `test/features/favoritos/presentation/pages/favoritos_page_test.dart`

- [ ] Create integration tests (optional)
  - [ ] Test full flow
  - [ ] Real database + UI

---

### **Phase 6: Dependency Injection** (`lib/core/di/`)

- [ ] Register use cases in `injection_container.dart`
  - [ ] Use `@LazySingleton` annotations (auto-registered via Injectable)
  - [ ] Or manual registration in `injection_container.dart`

```dart
// In use case file (automatic via Injectable)
@lazySingleton
class GetFavoritosUseCase {
  final IFavoritoCrudRepository _repository;
  
  GetFavoritosUseCase(this._repository);
  
  Future<Either<Failure, List<Favorito>>> call(String userId) async { }
}

// Or manual registration
sl.registerLazySingleton<AddFavoritoUseCase>(
  () => AddFavoritoUseCase(sl<IFavoritoCrudRepository>()),
);
```

---

### **Phase 7: Documentation**

- [ ] Add inline comments to complex sections
  - [ ] Explain SRP/ISP/DIP choices
  - [ ] Document error handling
  - [ ] Add usage examples

- [ ] Update `docs/ARCHITECTURE.md`
  - [ ] Add feature to folder structure
  - [ ] Document any new patterns

- [ ] Create `README.md` in feature folder (if complex)
  - [ ] Explain feature purpose
  - [ ] Document configuration
  - [ ] Provide usage examples

---

### **Phase 8: Code Quality**

- [ ] Run analyzer: `flutter analyze`
  - [ ] Fix all errors
  - [ ] Warnings to 0 if possible
  - [ ] Max 500 lines per file
  - [ ] Max 50 lines per method

- [ ] Format code: `dart format lib/`

- [ ] Run tests: `flutter test`
  - [ ] All tests pass
  - [ ] Coverage 70%+

- [ ] Run build_runner: `dart run build_runner watch --delete-conflicting-outputs`
  - [ ] Generate code for `@riverpod`, `@LazySingleton`, etc.

---

## 🎯 SOLID Checklist for New Features

- [ ] **Single Responsibility**: 
  - [ ] Each class has ONE reason to change
  - [ ] One notifier per concern (theme, notifications, analytics)
  - [ ] One use case per operation

- [ ] **Open/Closed**: 
  - [ ] Use generic services (FilterService, StatsService)
  - [ ] Don't modify existing code, extend instead

- [ ] **Liskov Substitution**: 
  - [ ] Repository implementations are interchangeable
  - [ ] Mock implementations work just like real ones

- [ ] **Interface Segregation**: 
  - [ ] Split large interfaces (CRUD vs Query)
  - [ ] Clients depend only on methods they use

- [ ] **Dependency Inversion**: 
  - [ ] Depend on abstractions (interfaces)
  - [ ] Use DI container (GetIt)
  - [ ] Never create concrete classes directly

---

## 📊 Feature Complexity Guidelines

### **Simple Feature** (1-2 use cases)
Example: Toggle dark mode
- Time: 2-3 hours
- Files: ~8 (1 notifier, 1 use case, 1 entity, etc.)

### **Medium Feature** (3-5 use cases)
Example: Manage favorites (add, remove, search)
- Time: 6-12 hours
- Files: ~20 (multiple use cases, segregated interfaces, services)

### **Complex Feature** (5+ use cases)
Example: Advanced filtering + analytics
- Time: 16-24+ hours
- Files: 30+ (multiple notifiers, specialized services, complex domain logic)

---

## ✅ Pre-Submit Checklist

Before submitting a new feature:

- [ ] All tests pass (`flutter test`)
- [ ] Zero analyzer errors (`flutter analyze`)
- [ ] Code formatted (`dart format lib/`)
- [ ] Build passes (`flutter build apk` or `flutter build ios`)
- [ ] SOLID principles followed
- [ ] Documentation updated
- [ ] Code comments added for complex sections
- [ ] Coverage 70%+
- [ ] No breaking changes to existing APIs

---

**Version**: 1.0  
**Last Updated**: 2024-11-15
