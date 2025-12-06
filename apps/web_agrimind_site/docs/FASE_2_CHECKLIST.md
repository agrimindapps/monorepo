# FASE 2: Code Generation and Repository Setup

## Estimated Time: 2-3 hours

---

## Prerequisites
- ✅ FASE 1 completed (dependencies, structure, core files)
- ✅ `build_runner` dependency installed
- ✅ `injectable_generator` and `riverpod_generator` installed

---

## Tasks Checklist

### 1. Code Generation Setup (30min)

#### 1.1 Enable Riverpod Annotations
- [ ] Uncomment `@riverpod` annotations in `culturas_provider.dart`
- [ ] Uncomment `part 'culturas_provider.g.dart';` directive
- [ ] Update provider functions to use proper `Ref` types

#### 1.2 Run Build Runner
```bash
cd /Users/agrimindsolucoes/Documents/GitHub/monorepo/apps/web_agrimind_site
dart run build_runner build --delete-conflicting-outputs
```

**Expected Outputs:**
- [ ] `lib/core/di/injection.config.dart` generated
- [ ] `lib/features/culturas/presentation/providers/culturas_provider.g.dart` generated
- [ ] 0 code generation errors

#### 1.3 Uncomment DI Configuration
- [ ] Uncomment `import 'injection.config.dart';` in `lib/core/di/injection.dart`
- [ ] Uncomment `getIt.init();` call in `configureDependencies()`

---

### 2. Repository Interfaces (Domain Layer) (45min)

Create repository interfaces following the pattern:

#### 2.1 Culturas Repository Interface
**File**: `lib/features/culturas/domain/repositories/culturas_repository.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/cultura_entity.dart';

abstract class CulturasRepository {
  Future<Either<Failure, List<CulturaEntity>>> getCulturas();
  Future<Either<Failure, CulturaEntity>> getCulturaById(String id);
  Future<Either<Failure, List<CulturaEntity>>> searchCulturas(String query);
}
```

- [ ] Create `culturas_repository.dart` interface
- [ ] All methods return `Either<Failure, T>`
- [ ] Use entity types (not models)

#### 2.2 Other Repository Interfaces (Placeholders)
- [ ] Create `defensivos_repository.dart` interface
- [ ] Create `pragas_repository.dart` interface
- [ ] Create `fitossanitarios_repository.dart` interface
- [ ] Create `diagnostico_repository.dart` interface

---

### 3. Data Models (Data Layer) (45min)

#### 3.1 Cultura Model
**File**: `lib/features/culturas/data/models/cultura_model.dart`

Features needed:
- [ ] Extends/implements `CulturaEntity`
- [ ] Freezed annotation for immutability
- [ ] JSON serialization (`fromJson`, `toJson`)
- [ ] `toEntity()` method to convert to domain entity
- [ ] `fromEntity()` factory constructor

**Pattern to follow:**
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/cultura_entity.dart';

part 'cultura_model.freezed.dart';
part 'cultura_model.g.dart';

@freezed
class CulturaModel with _$CulturaModel {
  const factory CulturaModel({
    required String id,
    required String nome,
    String? nomeComum,
    String? nomeCientifico,
    String? descricao,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _CulturaModel;

  factory CulturaModel.fromJson(Map<String, dynamic> json) =>
      _$CulturaModelFromJson(json);
}

extension CulturaModelX on CulturaModel {
  CulturaEntity toEntity() => CulturaEntity(
        id: id,
        nome: nome,
        nomeComum: nomeComum,
        nomeCientifico: nomeCientifico,
        descricao: descricao,
        imageUrl: imageUrl,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
```

- [ ] Create `cultura_model.dart` with Freezed
- [ ] Add JSON serialization
- [ ] Add `toEntity()` extension method
- [ ] Run build_runner to generate `.freezed.dart` and `.g.dart`

---

### 4. Data Sources (Data Layer) (30min)

#### 4.1 Culturas Remote Data Source (Supabase)
**File**: `lib/features/culturas/data/datasources/culturas_remote_datasource.dart`

- [ ] Create abstract class `CulturasRemoteDataSource`
- [ ] Create implementation `CulturasRemoteDataSourceImpl`
- [ ] Inject Supabase client via Injectable
- [ ] Methods throw exceptions (not Either)
- [ ] Return models (not entities)

**Pattern:**
```dart
abstract class CulturasRemoteDataSource {
  Future<List<CulturaModel>> getCulturas();
  Future<CulturaModel> getCulturaById(String id);
  Future<List<CulturaModel>> searchCulturas(String query);
}

@LazySingleton(as: CulturasRemoteDataSource)
class CulturasRemoteDataSourceImpl implements CulturasRemoteDataSource {
  final SupabaseClient _supabase;

  CulturasRemoteDataSourceImpl(this._supabase);

  @override
  Future<List<CulturaModel>> getCulturas() async {
    try {
      final response = await _supabase
          .from('culturas')
          .select()
          .order('nome');

      return (response as List)
          .map((json) => CulturaModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException('Failed to fetch culturas: $e');
    }
  }
}
```

- [ ] Create remote data source interface
- [ ] Create remote data source implementation
- [ ] Add `@LazySingleton` annotation
- [ ] All methods throw exceptions on error

#### 4.2 Culturas Local Data Source (Optional - Cache)
**File**: `lib/features/culturas/data/datasources/culturas_local_datasource.dart`

- [ ] Create if caching is needed (SharedPreferences or Hive)
- [ ] Otherwise, skip for now (can add in FASE 3)

---

### 5. Repository Implementation (Data Layer) (30min)

#### 5.1 Culturas Repository Implementation
**File**: `lib/features/culturas/data/repositories/culturas_repository_impl.dart`

- [ ] Implements `CulturasRepository` interface
- [ ] Injects data sources via Injectable
- [ ] Converts exceptions to Failures
- [ ] Returns `Either<Failure, T>`
- [ ] Converts models to entities

**Pattern:**
```dart
@LazySingleton(as: CulturasRepository)
class CulturasRepositoryImpl implements CulturasRepository {
  final CulturasRemoteDataSource _remoteDataSource;

  CulturasRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<CulturaEntity>>> getCulturas() async {
    try {
      final models = await _remoteDataSource.getCulturas();
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: $e'));
    }
  }
}
```

- [ ] Create repository implementation
- [ ] Add `@LazySingleton` annotation
- [ ] Implement all interface methods
- [ ] Convert models to entities
- [ ] Handle all exception types

---

### 6. Injectable Modules Setup (15min)

#### 6.1 Supabase Module
**File**: `lib/core/di/modules/supabase_module.dart`

```dart
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@module
abstract class SupabaseModule {
  @lazySingleton
  SupabaseClient get supabaseClient => Supabase.instance.client;
}
```

- [ ] Create Supabase module
- [ ] Provide `SupabaseClient` instance
- [ ] Add `@module` and `@lazySingleton` annotations

#### 6.2 Firebase Module (Optional)
- [ ] Create if Firebase services are needed
- [ ] Provide `FirebaseAnalytics`, `FirebaseAuth`, etc.

---

### 7. Validation (15min)

#### 7.1 Run Build Runner Again
```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] All files generate successfully
- [ ] No code generation errors

#### 7.2 Run Flutter Analyze
```bash
flutter analyze
```

- [ ] 0 errors in new files
- [ ] Verify dependency injection is working

#### 7.3 Test DI Configuration
Add temporary test in `main.dart`:
```dart
void main() async {
  // ... existing initialization ...

  await configureDependencies();

  // Test DI - should not throw
  final repo = getIt<CulturasRepository>();
  print('✅ DI working: ${repo.runtimeType}');

  runApp(...);
}
```

- [ ] App starts without errors
- [ ] DI resolves repository successfully
- [ ] Remove test code after validation

---

## Deliverables Checklist

- [ ] `injection.config.dart` generated and working
- [ ] `culturas_provider.g.dart` generated
- [ ] All repository interfaces created (5 features)
- [ ] `CulturaModel` with Freezed + JSON serialization
- [ ] `CulturasRemoteDataSource` + implementation
- [ ] `CulturasRepositoryImpl` working
- [ ] Supabase module providing client
- [ ] 0 analyzer errors in all new files
- [ ] DI configuration tested and working

---

## Next: FASE 3

After completing FASE 2, proceed to FASE 3:
- Use cases implementation
- Provider logic implementation
- Business validation
- Error handling

---

**Estimated Total Time**: 2-3 hours
**Complexity**: Medium (code generation + dependency setup)
