# 📚 CONSOLIDATED USECASE PATTERN - DEVELOPER GUIDE

**Purpose**: Quick reference for developers using the new consolidated usecase pattern  
**Applies To**: Defensivos, Pragas, Busca, Diagnósticos, Culturas

---

## Quick Start Example

### Using Consolidated Culturas Usecase

```dart
// ✅ NEW PATTERN - Consolidated

// 1. Inject the usecase
late final GetCulturasUseCase _getCulturasUseCase;

// 2. Call with typed params
final result = await _getCulturasUseCase.call(const GetAllCulturasParams());

// 3. Handle result
result.fold(
  (Failure failure) => print('Error: ${failure.message}'),
  (List<CulturaEntity> culturas) => print('Loaded ${culturas.length} culturas'),
);
```

---

## Pattern Structure

### 1️⃣ Params Classes (`get_[feature]_params.dart`)

```dart
// Abstract base class
abstract class Get[Feature]Params extends Equatable {
  const Get[Feature]Params();
}

// Operation 1: Get All
class GetAll[Feature]Params extends Get[Feature]Params {
  const GetAll[Feature]Params();
  
  @override
  List<Object?> get props => [];
}

// Operation 2: Get by ID
class Get[Feature]ByIdParams extends Get[Feature]Params {
  final String id;
  const Get[Feature]ByIdParams(this.id);
  
  @override
  List<Object?> get props => [id];
}

// Operation 3: Search
class Search[Feature]Params extends Get[Feature]Params {
  final String query;
  const Search[Feature]Params(this.query);
  
  @override
  List<Object?> get props => [query];
}
```

### 2️⃣ Consolidated Usecase (`get_[feature]_usecase.dart`)

```dart
class Get[Feature]Usecase implements UseCase<dynamic, Get[Feature]Params> {
  final [Feature]Repository repository;
  
  Get[Feature]Usecase(this.repository);

  @override
  Future<Either<Failure, dynamic>> call(Get[Feature]Params params) async {
    return switch (params) {
      GetAll[Feature]Params _ => 
        await repository.getAll(),
      
      Get[Feature]ByIdParams p => 
        await repository.getById(p.id),
      
      Search[Feature]Params p => 
        await repository.search(p.query),
      
      // Handle all cases - compiler ensures exhaustiveness
    };
  }
}
```

### 3️⃣ Injection Setup (Auto via @injectable)

```dart
// get_it configuration (automatic)
@injectable
class Get[Feature]Usecase extends UseCase<dynamic, Get[Feature]Params> {
  // ...
}

// Usage in notifier
late final Get[Feature]Usecase _getUsecase;

@override
Future<State> build() async {
  _getUsecase = di.sl<Get[Feature]Usecase>();
  // ...
}
```

---

## Common Use Cases

### Add a New Operation

**Scenario**: You need a new operation `GetByCategory(category)`

**Steps**:

1. **Add param class** to `get_[feature]_params.dart`:
```dart
class Get[Feature]ByCategoryParams extends Get[Feature]Params {
  final String category;
  const Get[Feature]ByCategoryParams(this.category);
  
  @override
  List<Object?> get props => [category];
}
```

2. **Add case to switch** in `get_[feature]_usecase.dart`:
```dart
@override
Future<Either<Failure, dynamic>> call(Get[Feature]Params params) async {
  return switch (params) {
    GetAll[Feature]Params _ => await repository.getAll(),
    Get[Feature]ByCategoryParams p => await repository.getByCategory(p.category),
    // ... other cases
  };
}
```

3. **Use in notifier**:
```dart
Future<void> filterByCategory(String category) async {
  final result = await _getUsecase.call(Get[Feature]ByCategoryParams(category));
  // ...
}
```

**That's it!** No need to create new usecase class.

---

## Calling Patterns

### Pattern 1: Simple Call with No Parameters
```dart
final result = await _getCulturasUseCase.call(const GetAllCulturasParams());
```

### Pattern 2: Call with Single String Parameter
```dart
final result = await _getCulturasUseCase.call(
  SearchCulturasParams('tomate')
);
```

### Pattern 3: Call with Multiple Parameters
```dart
final result = await _getCulturasUseCase.call(
  GetAdvancedSearchParams(
    query: 'tomate',
    category: 'Vegetais',
    minPrice: 10.0,
    maxPrice: 50.0,
  )
);
```

### Pattern 4: Handle Result with Fold
```dart
result.fold(
  (Failure failure) {
    // Handle error
    print('Error: ${failure.message}');
  },
  (dynamic data) {
    // Handle success - cast if needed
    if (data is List<CulturaEntity>) {
      print('Got ${data.length} culturas');
    }
  },
);
```

### Pattern 5: Handle Result with Pattern Matching
```dart
// Alternative to fold
final response = await _getCulturasUseCase.call(const GetAllCulturasParams());
if (response case Right(value: final culturas)) {
  print('Got ${culturas.length} culturas');
} else if (response case Left(value: final failure)) {
  print('Error: ${failure.message}');
}
```

---

## Type Casting Tips

### Safe List Casting
```dart
// ❌ DON'T: Will fail with dynamic
final list = await _getCulturasUseCase.call(...);
list.forEach((c) => print(c.nome)); // Type error!

// ✅ DO: Cast safely
final result = await _getCulturasUseCase.call(...);
result.fold(
  (failure) => print('Error'),
  (dynamic data) {
    if (data is List<CulturaEntity>) {
      data.forEach((c) => print(c.nome));
    }
  },
);
```

### Safe Map Casting
```dart
// For complex return types
result.fold(
  (failure) => print('Error'),
  (dynamic data) {
    if (data is Map<String, dynamic>) {
      final culturas = data['culturas'] is List
        ? (data['culturas'] as List).cast<CulturaEntity>()
        : <CulturaEntity>[];
      print('Got ${culturas.length} culturas');
    }
  },
);
```

---

## Testing Pattern

### Mocking Consolidated Usecase

```dart
// OLD: Had to mock 4 usecases
MockGetCulturasUseCase mockGetAll;
MockGetCulturasByGrupoUseCase mockByGrupo;
MockSearchCulturasUseCase mockSearch;
MockGetGruposCulturasUseCase mockGetGrupos;

// NEW: Mock one usecase
MockGetCulturasUsecase mockGetCulturas;

void main() {
  setUp(() {
    // Set up single mock
    mockGetCulturas = MockGetCulturasUsecase();
    
    when(mockGetCulturas.call(const GetAllCulturasParams()))
      .thenAnswer((_) async => Right(testCulturas));
    
    when(mockGetCulturas.call(SearchCulturasParams('test')))
      .thenAnswer((_) async => Right(searchResults));
  });

  test('loadCulturas should fetch all culturas', () async {
    // Test implementation
  });
}
```

### Testing Multiple Params
```dart
test('Each param type returns correct data', () async {
  // GetAll case
  when(mockGetCulturas.call(const GetAllCulturasParams()))
    .thenAnswer((_) async => Right(allCulturas));
  
  // ByGrupo case
  when(mockGetCulturas.call(GetCulturasByGrupoParams('Vegetais')))
    .thenAnswer((_) async => Right(vegetalsCulturas));
  
  // Search case
  when(mockGetCulturas.call(SearchCulturasParams('tomate')))
    .thenAnswer((_) async => Right(tomatoResults));
  
  // Verify all cases were called correctly
  verify(mockGetCulturas.call(const GetAllCulturasParams())).called(1);
  verify(mockGetCulturas.call(GetCulturasByGrupoParams('Vegetais'))).called(1);
  verify(mockGetCulturas.call(SearchCulturasParams('tomate'))).called(1);
});
```

---

## Backward Compatibility

### Using Old Usecases (Deprecated but Still Working)

```dart
// ❌ OLD: Deprecated but still works for backward compatibility
final result = await _oldGetCulturasByGrupoUseCase.call(grupo);

// ⚠️ MIGRATION: Replace with new pattern
final result = await _getCulturasUseCase.call(GetCulturasByGrupoParams(grupo));
```

### Gradual Migration Strategy

1. **Phase 1**: Deploy consolidated usecases (domain layer)
2. **Phase 2**: Update notifiers incrementally
   - Can coexist: new and old patterns work together
   - Test thoroughly before removing @deprecated usecases
3. **Phase 3**: Remove @deprecated old usecases (breaking change)

---

## Troubleshooting

### Issue 1: "The type 'CulturaEntity' isn't defined"
**Cause**: Missing import  
**Solution**:
```dart
import '../../domain/entities/cultura_entity.dart';
```

### Issue 2: "The argument type 'dynamic' can't be assigned..."
**Cause**: Not casting dynamic result  
**Solution**:
```dart
// ❌ Wrong
final culturas = data; // Compiler error

// ✅ Right
final culturas = data is List 
  ? (data as List).cast<CulturaEntity>() 
  : <CulturaEntity>[];
```

### Issue 3: "No case matches this value"
**Cause**: Missing case in switch statement  
**Solution**: Add the missing case:
```dart
return switch (params) {
  GetAll[Feature]Params _ => ...,
  Get[Feature]ByIdParams p => ...,
  NewOperationParams p => ..., // Add this!
};
```

### Issue 4: "Unnecessary cast" warning
**Cause**: Redundant `as List` wrapper  
**Solution**:
```dart
// ❌ Unnecessary
(culturas as List).cast<CulturaEntity>()

// ✅ Better
culturas is List ? culturas.cast<CulturaEntity>() : []
```

---

## Best Practices

### ✅ DO

1. **Keep params immutable**
   ```dart
   class SearchParams extends GetFeatureParams {
     final String query;
     const SearchParams(this.query); // const constructor
   }
   ```

2. **Make simple operations have simple params**
   ```dart
   class GetAllParams extends GetFeatureParams {
     const GetAllParams(); // No fields needed
   }
   ```

3. **Use clear naming**
   ```dart
   Get[Feature]ByIdParams // Clear intent
   Search[Feature]WithFiltersParams // Descriptive
   ```

4. **Document complex operations**
   ```dart
   /// Search for [feature] matching [query]
   /// 
   /// Returns up to [limit] results, sorted by relevance
   class Search[Feature]Params extends Get[Feature]Params {
     final String query;
     final int limit;
     
     const Search[Feature]Params({
       required this.query,
       this.limit = 10,
     });
   }
   ```

### ❌ DON'T

1. **Don't mix concerns in params**
   ```dart
   // ❌ Bad: Too many unrelated fields
   class GetCulturasParams {
     final String? searchQuery;
     final String? filterGrupo;
     final bool includeStats;
     final String sortBy;
   }
   
   // ✅ Better: Separate params for each operation
   class SearchCulturasParams { final String query; }
   class GetCulturasByGrupoParams { final String grupo; }
   class GetCulturaStatsParams { }
   ```

2. **Don't put logic in params**
   ```dart
   // ❌ Bad
   class SearchParams {
     String query;
     String get normalizedQuery => query.toLowerCase().trim();
   }
   
   // ✅ Better: Keep params simple
   class SearchParams {
     final String query;
   }
   ```

3. **Don't forget type annotations**
   ```dart
   // ❌ Bad
   final result = await _usecase.call(params);
   
   // ✅ Better
   final result = await _usecase.call(SearchCulturasParams(query));
   ```

---

## Feature-Specific Examples

### Culturas
```dart
// File: culturas/presentation/providers/culturas_notifier.dart

Future<void> loadCulturas() async {
  final result = await _getCulturasUseCase.call(const GetAllCulturasParams());
  
  result.fold(
    (Failure failure) => _handleError(failure),
    (dynamic data) {
      final culturas = data is List ? data.cast<CulturaEntity>() : [];
      // Update state
    },
  );
}

Future<void> searchCulturas(String query) async {
  final result = await _getCulturasUseCase.call(SearchCulturasParams(query));
  // Handle...
}

Future<void> filterByGrupo(String grupo) async {
  final result = await _getCulturasUseCase.call(GetCulturasByGrupoParams(grupo));
  // Handle...
}
```

### Defensivos
```dart
// File: defensivos/presentation/providers/defensivos_notifier.dart

Future<void> searchDefensivos(String query) async {
  final result = await _getDefensivosUseCase.call(SearchDefensivosParams(query));
  // Handle...
}

Future<void> filterByClasse(String classe) async {
  final result = await _getDefensivosUseCase.call(GetDefensivosByClasseParams(classe));
  // Handle...
}
```

---

## Summary

The consolidated usecase pattern provides:
- ✅ **Type safety** via typed params
- ✅ **Scalability** via sealed-like switch matching
- ✅ **Maintainability** via single point of change
- ✅ **Testing** via one mock per feature
- ✅ **Clarity** via explicit operation names

**Use it for all new [Feature] operations going forward!**

---

**Generated**: Session Active  
**System**: Monorepo Consolidation Pattern Guide
