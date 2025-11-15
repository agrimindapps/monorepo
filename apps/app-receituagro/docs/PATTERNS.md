# SOLID Patterns & Before/After Examples

## 🎯 Single Responsibility Principle (SRP)

### ❌ BEFORE: Monolithic Notifier

```dart
@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  late final GetUserSettingsUseCase _getSettings;
  late final UpdateUserSettingsUseCase _updateSettings;
  late final IAnalyticsRepository _analytics;
  late final ICrashlyticsRepository _crashlytics;
  late final IAppRatingRepository _appRating;
  late final ReceitaAgroNotificationService _notifications;

  @override
  Future<UserSettingsEntity?> build() async {
    // Manages EVERYTHING: theme, notifications, analytics, debug, premium
    // This is too much responsibility!
    return null;
  }

  // Theme methods
  Future<bool> setDarkTheme(bool isDark) async { }
  Future<bool> setLanguage(String lang) async { }

  // Notification methods
  Future<bool> setNotificationsEnabled(bool enabled) async { }
  Future<bool> setSoundEnabled(bool enabled) async { }
  Future<void> openNotificationSettings() async { }

  // Analytics methods
  Future<bool> testAnalytics() async { }
  Future<bool> testCrashlytics() async { }
  Future<bool> showRateAppDialog() async { }
  
  // Premium methods
  Future<bool> generateTestLicense() async { }
  Future<bool> removeTestLicense() async { }
}
```

**Problems**:
- Single change could affect multiple features
- Hard to test (too many mocks)
- Reusing parts is impossible
- Clear violation of SRP

### ✅ AFTER: Specialized Notifiers

```dart
// 1. Theme-only notifier
@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  late final GetUserSettingsUseCase _getUserSettings;
  late final UpdateUserSettingsUseCase _updateSettings;

  @override
  Future<UserSettingsEntity?> build() async {
    _getUserSettings = di.sl<GetUserSettingsUseCase>();
    _updateSettings = di.sl<UpdateUserSettingsUseCase>();
    return null;
  }

  Future<bool> setDarkTheme(bool isDark) async { }
  Future<bool> setLanguage(String lang) async { }
}

// 2. Notifications-only notifier
@riverpod
class NotificationsNotifier extends _$NotificationsNotifier {
  late final GetUserSettingsUseCase _getUserSettings;
  late final UpdateUserSettingsUseCase _updateSettings;
  late final ReceitaAgroNotificationService _notificationService;

  @override
  Future<UserSettingsEntity?> build() async {
    _getUserSettings = di.sl<GetUserSettingsUseCase>();
    _updateSettings = di.sl<UpdateUserSettingsUseCase>();
    _notificationService = di.sl<ReceitaAgroNotificationService>();
    
    ref.onDispose(() async {
      await _notificationService.cancelAllNotifications();
    });
    
    return null;
  }

  Future<bool> setNotificationsEnabled(bool enabled) async { }
  Future<bool> setSoundEnabled(bool enabled) async { }
  Future<void> openNotificationSettings() async { }
}

// 3. Analytics/Debug-only notifier
@riverpod
class AnalyticsDebugNotifier extends _$AnalyticsDebugNotifier {
  late final IAnalyticsRepository _analytics;
  late final ICrashlyticsRepository _crashlytics;
  late final IAppRatingRepository _appRating;
  late final IPremiumService _premium;

  @override
  Future<void> build() async {
    _analytics = di.sl<IAnalyticsRepository>();
    _crashlytics = di.sl<ICrashlyticsRepository>();
    _appRating = di.sl<IAppRatingRepository>();
    _premium = di.sl<IPremiumService>();
  }

  Future<bool> testAnalytics() async { }
  Future<bool> testCrashlytics() async { }
  Future<bool> showRateAppDialog() async { }
  Future<bool> generateTestLicense() async { }
  Future<bool> removeTestLicense() async { }
}
```

**Benefits**:
- Each notifier has ONE reason to change
- Easier to test (fewer mocks per test)
- Can reuse ThemeNotifier without analytics code
- Clear separation of concerns

---

## 🏗️ Interface Segregation Principle (ISP)

### ❌ BEFORE: Monolithic Interface

```dart
abstract class IFavoritoRepository {
  // CRUD methods
  Future<Favorito> add(Favorito favorito);
  Future<Favorito> get(String id);
  Future<Favorito> update(Favorito favorito);
  Future<void> delete(String id);
  Future<List<Favorito>> getAll();
  
  // Query methods
  Future<List<Favorito>> search(String term);
  Future<List<Favorito>> findByUserAndType(String userId, String type);
  Future<int> count();
  Future<bool> exists(String id);
  Future<List<Favorito>> findByCategory(String category);
  
  // Advanced queries
  Future<Map<String, int>> countByType();
  Future<List<String>> getAllUsers();
  Future<List<Favorito>> getPaginatedFavorites(int page, int pageSize);
  
  // Export/Import
  Future<Map<String, dynamic>> export();
  Future<void> import(Map<String, dynamic> data);
}

// Problem: Service that only needs CRUD depends on ALL 14+ methods
class FavoritoService {
  final IFavoritoRepository _repo;
  
  // Only uses: add, get, update, delete
  // But depends on: search, count, export, etc. that it never calls
  
  FavoritoService(this._repo);
  
  Future<Favorito> addFavorite(Favorito f) => _repo.add(f);
  Future<void> removeFavorite(String id) => _repo.delete(id);
}

// Problem: QueryService depends on methods it doesn't use
class FavoritoQueryService {
  final IFavoritoRepository _repo;
  
  // Only uses: search, count, findByUserAndType
  // But depends on: add, update, delete, export, etc.
  
  FavoritoQueryService(this._repo);
  
  Future<List<Favorito>> searchFavorites(String term) => _repo.search(term);
}
```

**Problems**:
- Clients depend on methods they never use
- Unclear which methods should be used where
- Hard to mock (need to implement all 14+ methods)
- Violates ISP

### ✅ AFTER: Segregated Interfaces

```dart
// Interface 1: CRUD operations only
abstract class IFavoritoCrudRepository {
  Future<Favorito> add(Favorito favorito);
  Future<Favorito> get(String id);
  Future<Favorito> update(Favorito favorito);
  Future<void> delete(String id);
  Future<List<Favorito>> getAll();
}

// Interface 2: Query operations only
abstract class IFavoritoQueryRepository {
  Future<List<Favorito>> search(String term);
  Future<List<Favorito>> findByUserAndType(String userId, String type);
  Future<int> count();
  Future<bool> exists(String id);
  Future<List<Favorito>> findByCategory(String category);
  Future<Map<String, int>> countByType();
  Future<List<Favorito>> getPaginatedFavorites(int page, int pageSize);
}

// Now Services depend only on what they use
class FavoritoService {
  final IFavoritoCrudRepository _repo;
  
  // Clear: This service only uses CRUD methods
  // Don't confuse it with query methods
  
  FavoritoService(this._repo);
  
  Future<Favorito> addFavorite(Favorito f) => _repo.add(f);
  Future<void> removeFavorite(String id) => _repo.delete(id);
}

class FavoritoQueryService {
  final IFavoritoQueryRepository _repo;
  
  // Clear: This service only uses Query methods
  // Don't try to add/delete here
  
  FavoritoQueryService(this._repo);
  
  Future<List<Favorito>> searchFavorites(String term) => _repo.search(term);
  Future<int> countFavorites() => _repo.count();
}

// Implementation implements both
@lazySingleton
class FavoritoRepository
    implements IFavoritoCrudRepository, IFavoritoQueryRepository {
  // Implements all methods from both interfaces
  
  @override
  Future<Favorito> add(Favorito favorito) async { }
  
  @override
  Future<List<Favorito>> search(String term) async { }
  
  // ... all other methods
}

// Easy to mock in tests
class MockCrudRepository extends Mock implements IFavoritoCrudRepository {}
class MockQueryRepository extends Mock implements IFavoritoQueryRepository {}

// Test CRUD service with minimal mock
test('should add favorite', () {
  final mockRepo = MockCrudRepository();
  when(() => mockRepo.add(any())).thenAnswer((_) async => testFavorito);
  
  final service = FavoritoService(mockRepo);
  // ... test
});

// Test Query service with minimal mock
test('should search favorites', () {
  final mockRepo = MockQueryRepository();
  when(() => mockRepo.search(any())).thenAnswer((_) async => [testFavorito]);
  
  final service = FavoritoQueryService(mockRepo);
  // ... test
});
```

**Benefits**:
- Each client depends only on the methods it needs
- Smaller, focused interfaces
- Easier to mock (fewer methods to mock)
- Clear what each service can do
- Can extend with specialized queries (e.g., IFavoritoAdvancedQueryRepository)

---

## 🔌 Dependency Inversion Principle (DIP)

### ❌ BEFORE: High-level depends on Low-level

```dart
// Low-level: Database implementation
class FavoritoRepositoryImpl {
  Future<List<Favorito>> getAll() async {
    // Direct database access
  }
}

// High-level: Notifier depends on concrete class
@riverpod
class FavoritesNotifier extends _$FavoritesNotifier {
  late final FavoritoRepositoryImpl _repo; // ❌ Concrete implementation!
  
  @override
  Future<List<Favorito>> build() async {
    // Hard to test, hard to swap implementations
    _repo = FavoritoRepositoryImpl(); // ❌ Creating concrete class directly
    return _repo.getAll();
  }
}

// Problem: If we need to change how FavoritoRepositoryImpl works,
// we must modify the high-level Notifier
// If we need to use a different database, we're stuck
```

**Problems**:
- Notifier depends on concrete class, not abstraction
- Can't swap implementations for testing
- High-level code can't exist independently of low-level code

### ✅ AFTER: Both depend on Abstractions

```dart
// Abstraction: Repository interface
abstract class IFavoritoRepository {
  Future<List<Favorito>> getAll();
}

// Low-level: Concrete implementation
@lazySingleton(as: IFavoritoRepository)
class FavoritoRepositoryImpl implements IFavoritoRepository {
  final ReceituagroDatabase _db;
  
  FavoritoRepositoryImpl(this._db);
  
  @override
  Future<List<Favorito>> getAll() async {
    // Implementation
  }
}

// High-level: Depends on abstraction
@riverpod
class FavoritesNotifier extends _$FavoritesNotifier {
  late final IFavoritoRepository _repo; // ✅ Abstraction!
  
  @override
  Future<List<Favorito>> build() async {
    // DI container provides implementation
    _repo = di.sl<IFavoritoRepository>();
    return _repo.getAll();
  }
}

// Easy to test with mock implementation
class MockFavoritoRepository extends Mock implements IFavoritoRepository {}

test('should load favorites', () {
  final mockRepo = MockFavoritoRepository();
  when(() => mockRepo.getAll()).thenAnswer((_) async => testFavorites);
  
  // ✅ Easy to inject mock
  final container = ProviderContainer(
    overrides: [/* override with mock */],
  );
  
  // Test notifier with mock
});
```

**Benefits**:
- Notifier doesn't know implementation details
- Can swap implementations without changing notifier
- Easy to test with mocks
- Both high-level and low-level depend on shared abstraction

---

## 🏭 Generic Services Pattern

### ❌ BEFORE: Duplicated Filtering Logic

```dart
// In FavoritoNotifier
Future<List<Favorito>> searchFavorites(String query) async {
  final all = await _repo.getAll();
  final lowerQuery = query.toLowerCase();
  return all.where((fav) {
    return fav.name.toLowerCase().contains(lowerQuery);
  }).toList();
}

// In PlagueNotifier (duplicated!)
Future<List<Plague>> searchPlaguesFavorites(String query) async {
  final all = await _repo.getAll();
  final lowerQuery = query.toLowerCase();
  return all.where((plague) {
    return plague.name.toLowerCase().contains(lowerQuery);
  }).toList();
}

// In DefensiveNotifier (duplicated again!)
Future<List<Defensive>> searchDefensiveFavorites(String query) async {
  final all = await _repo.getAll();
  final lowerQuery = query.toLowerCase();
  return all.where((def) {
    return def.name.toLowerCase().contains(lowerQuery);
  }).toList();
}

// Problem: Same logic repeated 3 times!
// If we need to fix a bug, we fix in 3 places
// If we need to add new feature, we implement 3 times
```

### ✅ AFTER: Reusable FilterService

```dart
// Generic, reusable service
class FilterService {
  static List<T> filterBySearchTerm<T>(
    List<T> items,
    String searchTerm,
    String Function(T) getDisplayText,
  ) {
    if (searchTerm.isEmpty) return items;
    
    final lowerSearchTerm = searchTerm.toLowerCase();
    return items.where((item) {
      final displayText = getDisplayText(item).toLowerCase();
      return displayText.contains(lowerSearchTerm);
    }).toList();
  }
}

// In FavoritoNotifier
Future<List<Favorito>> searchFavorites(String query) async {
  final all = await _repo.getAll();
  return FilterService.filterBySearchTerm(
    all,
    query,
    (fav) => fav.name,
  );
}

// In PlagueNotifier
Future<List<Plague>> searchPlaguesFavorites(String query) async {
  final all = await _repo.getAll();
  return FilterService.filterBySearchTerm(
    all,
    query,
    (plague) => plague.name,
  );
}

// In DefensiveNotifier
Future<List<Defensive>> searchDefensiveFavorites(String query) async {
  final all = await _repo.getAll();
  return FilterService.filterBySearchTerm(
    all,
    query,
    (def) => def.name,
  );
}

// Benefits:
// - Logic is defined once
// - Works with ANY type T
// - If we fix a bug, it's fixed everywhere
// - New types automatically get same filtering
// - No code duplication
```

---

## 🧪 Testing Patterns

### ✅ Specialized Notifier Testing

```dart
// Test only ThemeNotifier (not notifications, not analytics)
void main() {
  group('ThemeNotifier', () {
    late MockGetUserSettingsUseCase mockGetSettings;
    late MockUpdateUserSettingsUseCase mockUpdateSettings;
    
    setUp(() {
      mockGetSettings = MockGetUserSettingsUseCase();
      mockUpdateSettings = MockUpdateUserSettingsUseCase();
    });
    
    test('should toggle dark theme', () async {
      // Arrange
      final initial = UserSettingsEntity.createDefault('user-1');
      final expected = initial.copyWith(isDarkTheme: true);
      
      when(() => mockUpdateSettings(any()))
          .thenAnswer((_) async => expected);
      
      // Act & Assert
      // ... test only theme functionality
    });
  });
}

// Test only NotificationsNotifier (not theme, not analytics)
void main() {
  group('NotificationsNotifier', () {
    late MockGetUserSettingsUseCase mockGetSettings;
    late MockUpdateUserSettingsUseCase mockUpdateSettings;
    late MockReceitaAgroNotificationService mockNotificationService;
    
    // Notice: We DON'T need IAnalyticsRepository or IPremiumService mocks
    // Because this notifier doesn't use them!
    
    test('should enable notifications', () async {
      // Arrange
      final initial = UserSettingsEntity.createDefault('user-1')
          .copyWith(notificationsEnabled: false);
      final expected = initial.copyWith(notificationsEnabled: true);
      
      when(() => mockUpdateSettings(any()))
          .thenAnswer((_) async => expected);
      
      // Act & Assert
      // ... test only notification functionality
    });
  });
}
```

---

## 📊 SOLID Score Improvement

| Principle | Before | After | Improvement |
|-----------|--------|-------|-------------|
| **S** (SRP) | 5/10 | 9/10 | Specialized notifiers |
| **O** (OCP) | 4/10 | 8/10 | Generic services (FilterService, StatsService) |
| **L** (LSP) | 7/10 | 9/10 | Repository implementations |
| **I** (ISP) | 3/10 | 9/10 | Segregated repository interfaces |
| **D** (DIP) | 5/10 | 9/10 | DI container + abstractions |
| **TOTAL** | **4.8/10** | **8.8/10** | **+4.0 points** ✅ |

---

## 🎯 Key Takeaways

1. **SRP**: One class = One reason to change
2. **OCP**: Use generics for open-closed principle
3. **LSP**: Implementations are interchangeable
4. **ISP**: Small, focused interfaces
5. **DIP**: Depend on abstractions, not concrete classes

---

**Version**: 1.0  
**Last Updated**: 2024-11-15
