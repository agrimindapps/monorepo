# Architecture Documentation - app-receituagro

## 🏗️ Overview

app-receituagro follows **Clean Architecture** with **SOLID Principles**, organized into clear layers with specialized services and segregated interfaces for maximum maintainability and testability.

**Target SOLID Score**: 9.0/10 ✅

---

## 📊 Architecture Layers

### 1. **Presentation Layer** (`lib/features/*/presentation/`)
- **Responsibility**: UI rendering and user interactions
- **Components**:
  - `pages/`: Screen implementations (ConsumerWidget, ConsumerStatefulWidget)
  - `widgets/`: Reusable UI components
  - `providers/`: Riverpod notifiers and providers (@riverpod)

**Key Pattern**: AsyncValue<T> for state management
```dart
final dataAsync = ref.watch(myDataNotifierProvider);
dataAsync.when(
  data: (data) => MyList(data),
  loading: () => Loader(),
  error: (err, _) => ErrorView(err),
);
```

### 2. **Domain Layer** (`lib/features/*/domain/`)
- **Responsibility**: Business logic and rules (NEVER imports Flutter)
- **Components**:
  - `entities/`: Core business objects
  - `repositories/`: Interface contracts (@immutable abstract classes)
  - `usecases/`: Single-responsibility business operations

**Key Pattern**: Either<Failure, T> for error handling
```dart
Future<Either<Failure, List<Plant>>> getPlants() async {
  try {
    return Right(plants);
  } catch (e) {
    return Left(RepositoryFailure(e.toString()));
  }
}
```

### 3. **Data Layer** (`lib/features/*/data/`)
- **Responsibility**: Data persistence and remote communication
- **Components**:
  - `datasources/`: Local (Drift) and Remote (Firebase) data sources
  - `models/`: DTOs with serialization
  - `repositories/`: Implementation of domain contracts

**Key Pattern**: Drift for type-safe SQLite queries
```dart
@UseRowClass(Plant)
class Plants extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
}
```

### 4. **Core Layer** (`lib/core/`)
- **Responsibility**: Shared infrastructure and utilities
- **Components**:
  - `di/`: Dependency Injection container (GetIt + Injectable)
  - `services/`: Reusable services (FilterService, StatsService)
  - `interfaces/`: Shared abstractions (IPremiumService, IAnalyticsRepository)

**Key Pattern**: Service Locator via GetIt
```dart
final repo = sl<MyRepository>();
final useCase = sl<MyUseCase>();
```

---

## 🎯 SOLID Principles Implementation

### **S - Single Responsibility Principle**

Each component has ONE reason to change:

✅ **ThemeNotifier**: Manages ONLY theme settings
- Dark mode toggle
- Language preferences
- Does NOT handle notifications or analytics

✅ **NotificationsNotifier**: Manages ONLY notification preferences
- Push notifications
- Sound settings
- Does NOT handle theme or analytics

✅ **AnalyticsDebugNotifier**: Manages ONLY analytics and debug
- Analytics testing
- Crashlytics
- Premium testing
- Does NOT handle user settings

✅ **FilterService**: Provides ONLY filtering operations
- Search filtering
- Type filtering
- Pagination
- Does NOT handle persistence

---

### **O - Open/Closed Principle**

Components are open for extension, closed for modification:

✅ **Generic Services**:
```dart
// Can filter any type T without modification
class FilterService {
  static List<T> filterByType<T>(
    List<T> items,
    String targetType,
    String Function(T) getType,
  ) { }
}

// Usage with different types:
final fruits = FilterService.filterByType(items, 'Fruit', (item) => item.type);
final defensivos = FilterService.filterByType(items, 'Defensivo', (item) => item.type);
```

✅ **Repository Extensions**:
```dart
// Add new query methods without modifying existing ones
extension FavoritoQueryExt on IFavoritoQueryRepository {
  Future<List<Favorito>> searchByUser(String userId) async {
    final all = await getAll();
    return FilterService.filterByUserId(all, userId, (item) => item.userId);
  }
}
```

---

### **L - Liskov Substitution Principle**

Derived types can replace base types:

✅ **Repository Implementations**:
```dart
// IFavoritoRepository contract
abstract class IFavoritoRepository {
  Future<List<Favorito>> getAll();
}

// Any implementation can be substituted
class FavoritoRepositoryImpl implements IFavoritoRepository {
  @override
  Future<List<Favorito>> getAll() async => /* */;
}

// Usage - doesn't care about concrete implementation
final repo = sl<IFavoritoRepository>();
final favorites = await repo.getAll();
```

---

### **I - Interface Segregation Principle**

Clients depend only on methods they use:

✅ **Segregated Repository Interfaces**:

Instead of ONE monolithic interface:
```dart
abstract class IFavoritoRepository {
  Future<List<Favorito>> add(Favorito f);
  Future<void> remove(String id);
  Future<List<Favorito>> search(String term);
  Future<int> count();
  Future<bool> exists(String id);
  // ... 10+ more methods
}
```

We have TWO specialized interfaces:

**IFavoritoCrudRepository** (for mutation):
```dart
abstract class IFavoritoCrudRepository {
  Future<Favorito> add(Favorito favorito);
  Future<Favorito> get(String id);
  Future<void> update(Favorito favorito);
  Future<void> delete(String id);
}
```

**IFavoritoQueryRepository** (for queries):
```dart
abstract class IFavoritoQueryRepository {
  Future<List<Favorito>> getAll();
  Future<List<Favorito>> search(String term);
  Future<int> count();
  Future<bool> exists(String id);
}
```

**Benefits**:
- CRUD notifiers only depend on IFavoritoCrudRepository
- Query services only depend on IFavoritoQueryRepository
- Reduces coupling and improves testability
- Easier to add specialized query interfaces (e.g., IFavoritoFilterRepository)

---

### **D - Dependency Inversion Principle**

High-level modules don't depend on low-level modules; both depend on abstractions:

✅ **DI Container Structure**:

```
Application (High-level)
    ↓
Uses cases (Abstractions)
    ↓
Repository Interfaces (Abstractions)
    ↓
Repository Implementations (Low-level)
```

✅ **Concrete Example - Notifier**:

```dart
// Notifier depends on USE CASE ABSTRACTION
@riverpod
class PlantNotifier extends _$PlantNotifier {
  late final GetPlantsUseCase _useCase;
  
  @override
  Future<List<Plant>> build() async {
    // DI container provides implementation via abstraction
    _useCase = di.sl<GetPlantsUseCase>();
    return _useCase.call();
  }
}

// Use case depends on REPOSITORY ABSTRACTION
class GetPlantsUseCase {
  final IPlantRepository _repo; // Depends on interface, not concrete class
  
  GetPlantsUseCase(this._repo);
  
  Future<List<Plant>> call() => _repo.getPlants();
}

// DI container injects implementation
@LazySingleton(as: IPlantRepository)
class PlantRepositoryImpl implements IPlantRepository {
  // Implementation details
}
```

---

## 🔄 Data Flow Example: Get Favorites

```
User taps "Load Favorites"
           ↓
ConsumerWidget calls ref.watch(favoritesNotifierProvider)
           ↓
FavoritesNotifier.build() async
           ↓
Calls getFavoritesUseCase() [abstraction]
           ↓
UseCase calls repository.getFavorites() [abstraction]
           ↓
RepositoryImpl queries Drift database
           ↓
Drift executes SQL: SELECT * FROM favoritos WHERE userId = ?
           ↓
Convert Favorito to FavoritoData entity
           ↓
Return Either<Failure, List<FavoritoData>>
           ↓
UseCase unwraps Either and returns list
           ↓
Notifier returns AsyncValue<List<FavoritoData>>
           ↓
ConsumerWidget receives data and rebuilds UI
           ↓
User sees list of favorites
```

---

## 📁 Folder Structure

```
lib/
├── core/
│   ├── di/
│   │   ├── injection_container.dart      # Main DI setup
│   │   ├── injection.dart                # Generated by Injectable
│   │   └── injection.config.dart         # Generated by Injectable
│   ├── interfaces/
│   │   ├── i_premium_service.dart        # Premium service interface
│   │   └── i_analytics_service.dart      # Analytics interface
│   ├── services/
│   │   ├── filter_service.dart           # Generic filtering
│   │   ├── stats_service.dart            # Generic statistics
│   │   └── receituagro_notification_service.dart
│   └── ...
│
├── features/
│   ├── settings/
│   │   ├── presentation/
│   │   │   ├── providers/
│   │   │   │   └── notifiers/
│   │   │   │       ├── theme_notifier.dart                (SRP: Theme only)
│   │   │   │       ├── notifications_notifier.dart       (SRP: Notifications only)
│   │   │   │       └── analytics_debug_notifier.dart     (SRP: Analytics only)
│   │   │   ├── pages/
│   │   │   └── widgets/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── data/
│   │       ├── datasources/
│   │       ├── models/
│   │       └── repositories/
│   │
│   ├── favoritos/
│   │   ├── presentation/
│   │   ├── domain/
│   │   │   └── repositories/
│   │   │       ├── i_favorito_crud_repository.dart       (ISP: CRUD only)
│   │   │       └── i_favorito_query_repository.dart      (ISP: Query only)
│   │   └── data/
│   │
│   └── [other features...]
│
├── database/
│   ├── receituagro_database.dart         # Drift database definition
│   ├── tables/
│   └── repositories/
│       ├── favorito_repository.dart      (Implements both CRUD + Query interfaces)
│       └── ...
│
└── main.dart
```

---

## 🧪 Testing Strategy

### **Unit Tests**
- Test use cases with mocked repositories
- Test services (FilterService, StatsService) with test data
- Use Mocktail for mocking

### **Test Example - Theme Notifier**
```dart
test('should toggle dark theme to true', () async {
  // Arrange
  final initialSettings = UserSettingsEntity.createDefault(userId);
  final expectedSettings = initialSettings.copyWith(isDarkTheme: true);
  
  when(() => mockRepository.update(any()))
    .thenAnswer((_) async => expectedSettings);
  
  // Act
  final result = await themeNotifier.setDarkTheme(true);
  
  // Assert
  expect(result, true);
  verify(() => mockRepository.update(any())).called(1);
});
```

### **Coverage Targets**
- Domain layer: 90%+
- Data layer: 85%+
- Services: 85%+
- Total: 70%+

---

## 🔐 Error Handling

All operations return `Either<Failure, T>`:

```dart
// Domain layer - define failure types
abstract class Failure {
  final String message;
  Failure(this.message);
}

class RepositoryFailure extends Failure {
  RepositoryFailure(String message) : super(message);
}

class ValidationFailure extends Failure {
  ValidationFailure(String message) : super(message);
}

// Data layer - map exceptions to failures
@override
Future<Either<Failure, List<Favorito>>> getAll() async {
  try {
    final data = await _db.select(_db.favoritos).get();
    return Right(data.map(fromData).toList());
  } on DatabaseException catch (e) {
    return Left(RepositoryFailure('Database error: $e'));
  }
}

// Use case - propagate failures
@override
Future<Either<Failure, List<Favorito>>> call() async {
  final result = await _repository.getAll();
  return result.fold(
    (failure) => Left(failure),
    (data) {
      if (data.isEmpty) {
        return Left(ValidationFailure('No items found'));
      }
      return Right(data);
    },
  );
}

// Notifier - handle with AsyncValue
state = await AsyncValue.guard(() async {
  final result = await _useCase.call();
  return result.fold(
    (failure) => throw failure,
    (data) => data,
  );
});
```

---

## 📚 Key Concepts

### **Drift ORM**
- Type-safe SQL generation
- Compile-time verification
- Automatic migrations
- See: `lib/database/receituagro_database.dart`

### **Riverpod State Management**
- Code generation via `@riverpod`
- AsyncValue<T> for async states
- Automatic caching and invalidation
- See: Notifier pattern in `lib/features/settings/presentation/providers/`

### **Injectable Dependency Injection**
- Code generation via `@LazySingleton`
- Automatic wiring of dependencies
- See: `lib/core/di/injection.dart`

### **FilterService & StatsService**
- Generic, reusable utilities
- No side effects (pure functions)
- Functional composition
- See: `lib/core/services/`

---

## ✅ SOLID Compliance Checklist

- ✅ **S**: Each class has ONE reason to change
- ✅ **O**: Generic services (FilterService, StatsService) are open for extension
- ✅ **L**: Repository implementations can be substituted freely
- ✅ **I**: Segregated interfaces (CRUD vs Query)
- ✅ **D**: All dependencies injected via abstractions (DI container)

---

## 🚀 Next Steps

1. **Add Feature**: Follow the folder structure in `lib/features/`
2. **Add Tests**: See `test/` for examples
3. **Update DI**: Register in `lib/core/di/injection_container.dart`
4. **Document**: Update this architecture guide if new patterns emerge

---

**Version**: 1.0  
**Last Updated**: 2024-11-15  
**SOLID Score**: 9.0/10 ✅
