---
mode: agent
---
# Implementar Feature Completa (Clean Architecture)

Você será guiado através da implementação de uma feature completa seguindo Clean Architecture e os padrões do monorepo.

## 📋 INFORMAÇÕES NECESSÁRIAS

**Antes de começar, responda:**

1. **Nome da Feature**: [ex: "Sistema de Favoritos", "Chat em Tempo Real"]
2. **App Target**: [app-plantis, app-gasometer, app-receituagro, etc]
3. **Descrição**: [breve descrição do que a feature faz]
4. **Complexidade**: [Simples / Média / Alta]
5. **Cross-App?**: [Esta feature será usada em outros apps? S/N]

## 🏗️ ESTRUTURA A SER CRIADA

### 1. Domain Layer (Business Logic)
```
lib/domain/
├── entities/
│   └── [feature_name].dart          # Modelo de domínio puro
├── repositories/
│   └── [feature_name]_repository.dart  # Interface do repository
├── usecases/
│   ├── get_[feature].dart           # Use case de leitura
│   ├── create_[feature].dart        # Use case de criação
│   └── delete_[feature].dart        # Use cases adicionais
└── failures/
    └── [feature_name]_failure.dart  # Tipos de erro específicos
```

### 2. Data Layer (Implementation)
```
lib/data/
├── models/
│   └── [feature_name]_model.dart    # Model com JSON serialization
├── datasources/
│   ├── [feature_name]_local_datasource.dart   # Hive/SQLite
│   └── [feature_name]_remote_datasource.dart  # Firebase/API
└── repositories/
    └── [feature_name]_repository_impl.dart    # Implementação
```

### 3. Presentation Layer (UI + State)
```
lib/presentation/
├── providers/
│   └── [feature_name]_provider.dart  # Riverpod provider/notifier
├── pages/
│   ├── [feature_name]_list_page.dart
│   ├── [feature_name]_detail_page.dart
│   └── [feature_name]_form_page.dart
└── widgets/
    ├── [feature_name]_card.dart
    └── [feature_name]_loading.dart
```

### 4. Testing
```
test/
├── domain/
│   └── usecases/
│       └── get_[feature]_test.dart
├── data/
│   └── repositories/
│       └── [feature_name]_repository_impl_test.dart
└── presentation/
    └── providers/
        └── [feature_name]_provider_test.dart
```

## 📝 TEMPLATE DE IMPLEMENTAÇÃO

### Passo 1: Criar Entity (Domain)
```dart
// lib/domain/entities/favorite.dart
import 'package:equatable/equatable.dart';

class Favorite extends Equatable {
  final String id;
  final String userId;
  final String itemId;
  final DateTime createdAt;

  const Favorite({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, itemId, createdAt];
}
```

### Passo 2: Criar Repository Interface (Domain)
```dart
// lib/domain/repositories/favorite_repository.dart
import 'package:dartz/dartz.dart';
import '../../core/failures/failure.dart';
import '../entities/favorite.dart';

abstract class FavoriteRepository {
  Future<Either<Failure, List<Favorite>>> getFavorites(String userId);
  Future<Either<Failure, Favorite>> addFavorite(String userId, String itemId);
  Future<Either<Failure, void>> removeFavorite(String favoriteId);
  Future<Either<Failure, bool>> isFavorite(String userId, String itemId);
}
```

### Passo 3: Criar Use Case (Domain)
```dart
// lib/domain/usecases/get_favorites.dart
import 'package:dartz/dartz.dart';
import '../../core/failures/failure.dart';
import '../../core/usecases/usecase.dart';
import '../entities/favorite.dart';
import '../repositories/favorite_repository.dart';

class GetFavorites implements UseCase<List<Favorite>, String> {
  final FavoriteRepository repository;

  GetFavorites(this.repository);

  @override
  Future<Either<Failure, List<Favorite>>> call(String userId) async {
    return await repository.getFavorites(userId);
  }
}
```

### Passo 4: Criar Model (Data)
```dart
// lib/data/models/favorite_model.dart
import '../../domain/entities/favorite.dart';

class FavoriteModel extends Favorite {
  const FavoriteModel({
    required super.id,
    required super.userId,
    required super.itemId,
    required super.createdAt,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      itemId: json['itemId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'itemId': itemId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FavoriteModel.fromEntity(Favorite favorite) {
    return FavoriteModel(
      id: favorite.id,
      userId: favorite.userId,
      itemId: favorite.itemId,
      createdAt: favorite.createdAt,
    );
  }
}
```

### Passo 5: Implementar Repository (Data)
```dart
// lib/data/repositories/favorite_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../core/failures/failure.dart';
import '../../domain/entities/favorite.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../datasources/favorite_local_datasource.dart';
import '../datasources/favorite_remote_datasource.dart';
import '../models/favorite_model.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final FavoriteLocalDataSource localDataSource;
  final FavoriteRemoteDataSource remoteDataSource;

  FavoriteRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<Favorite>>> getFavorites(String userId) async {
    try {
      // Try remote first
      final remoteFavorites = await remoteDataSource.getFavorites(userId);
      // Cache locally
      await localDataSource.cacheFavorites(remoteFavorites);
      return Right(remoteFavorites);
    } catch (e) {
      // Fallback to cache
      try {
        final cachedFavorites = await localDataSource.getCachedFavorites(userId);
        return Right(cachedFavorites);
      } catch (e) {
        return Left(CacheFailure('Failed to load favorites'));
      }
    }
  }

  @override
  Future<Either<Failure, Favorite>> addFavorite(String userId, String itemId) async {
    try {
      final favorite = await remoteDataSource.addFavorite(userId, itemId);
      await localDataSource.cacheFavorite(favorite);
      return Right(favorite);
    } catch (e) {
      return Left(ServerFailure('Failed to add favorite'));
    }
  }

  @override
  Future<Either<Failure, void>> removeFavorite(String favoriteId) async {
    try {
      await remoteDataSource.removeFavorite(favoriteId);
      await localDataSource.removeCachedFavorite(favoriteId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to remove favorite'));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite(String userId, String itemId) async {
    try {
      // Check cache first (faster)
      final isCached = await localDataSource.isCachedFavorite(userId, itemId);
      return Right(isCached);
    } catch (e) {
      return Left(CacheFailure('Failed to check favorite status'));
    }
  }
}
```

### Passo 6: Criar Provider (Presentation)
```dart
// lib/presentation/providers/favorite_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/favorite.dart';
import '../../domain/usecases/get_favorites.dart';
import '../../domain/usecases/add_favorite.dart';
import '../../domain/usecases/remove_favorite.dart';
import '../../di/injection.dart';

part 'favorite_provider.g.dart';

@riverpod
class FavoriteNotifier extends _$FavoriteNotifier {
  @override
  FutureOr<List<Favorite>> build(String userId) async {
    final getFavorites = ref.read(getFavoritesProvider);
    final result = await getFavorites(userId);
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (favorites) => favorites,
    );
  }

  Future<void> addFavorite(String itemId) async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      final addFavoriteUseCase = ref.read(addFavoriteProvider);
      final result = await addFavoriteUseCase(AddFavoriteParams(
        userId: userId,
        itemId: itemId,
      ));
      
      return result.fold(
        (failure) => throw Exception(failure.message),
        (_) async {
          // Reload favorites
          final getFavorites = ref.read(getFavoritesProvider);
          final reloadResult = await getFavorites(userId);
          return reloadResult.fold(
            (failure) => throw Exception(failure.message),
            (favorites) => favorites,
          );
        },
      );
    });
  }

  Future<void> removeFavorite(String favoriteId) async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      final removeFavoriteUseCase = ref.read(removeFavoriteProvider);
      final result = await removeFavoriteUseCase(favoriteId);
      
      return result.fold(
        (failure) => throw Exception(failure.message),
        (_) async {
          // Reload favorites
          final getFavorites = ref.read(getFavoritesProvider);
          final reloadResult = await getFavorites(userId);
          return reloadResult.fold(
            (failure) => throw Exception(failure.message),
            (favorites) => favorites,
          );
        },
      );
    });
  }
}

// Helper provider para checar se item é favorito
@riverpod
bool isFavorite(IsFavoriteRef ref, String userId, String itemId) {
  final favoritesAsync = ref.watch(favoriteNotifierProvider(userId));
  
  return favoritesAsync.when(
    data: (favorites) => favorites.any((f) => f.itemId == itemId),
    loading: () => false,
    error: (_, __) => false,
  );
}
```

### Passo 7: Criar UI (Presentation)
```dart
// lib/presentation/pages/favorites_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/favorite_provider.dart';
import '../widgets/favorite_card.dart';

class FavoritesPage extends ConsumerWidget {
  final String userId;

  const FavoritesPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoriteNotifierProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: favoritesAsync.when(
        data: (favorites) {
          if (favorites.isEmpty) {
            return const Center(
              child: Text('No favorites yet'),
            );
          }
          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              return FavoriteCard(
                favorite: favorites[index],
                onRemove: () async {
                  await ref
                      .read(favoriteNotifierProvider(userId).notifier)
                      .removeFavorite(favorites[index].id);
                },
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
```

### Passo 8: Testes (Test)
```dart
// test/domain/usecases/get_favorites_test.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFavoriteRepository extends Mock implements FavoriteRepository {}

void main() {
  late GetFavorites usecase;
  late MockFavoriteRepository mockRepository;

  setUp(() {
    mockRepository = MockFavoriteRepository();
    usecase = GetFavorites(mockRepository);
  });

  const tUserId = 'user-123';
  final tFavorites = [
    Favorite(
      id: '1',
      userId: tUserId,
      itemId: 'item-1',
      createdAt: DateTime(2024, 1, 1),
    ),
  ];

  test('should return list of favorites when repository succeeds', () async {
    // Arrange
    when(() => mockRepository.getFavorites(any()))
        .thenAnswer((_) async => Right(tFavorites));

    // Act
    final result = await usecase(tUserId);

    // Assert
    expect(result, Right(tFavorites));
    verify(() => mockRepository.getFavorites(tUserId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository fails', () async {
    // Arrange
    final tFailure = ServerFailure('Server error');
    when(() => mockRepository.getFavorites(any()))
        .thenAnswer((_) async => Left(tFailure));

    // Act
    final result = await usecase(tUserId);

    // Assert
    expect(result, Left(tFailure));
    verify(() => mockRepository.getFavorites(tUserId)).called(1);
  });
}
```

## ✅ CHECKLIST DE CONCLUSÃO

Após implementação, valide:

- [ ] Entity criada com Equatable
- [ ] Repository interface definida (retorna Either<Failure, T>)
- [ ] Use cases implementados
- [ ] Model com JSON serialization
- [ ] Repository implementation com cache strategy
- [ ] Riverpod provider com code generation
- [ ] UI com AsyncValue.when()
- [ ] Testes unitários (use cases + repository)
- [ ] Build runner executado: `flutter pub run build_runner build`
- [ ] Analyzer limpo: `flutter analyze`
- [ ] Testes passando: `flutter test`

## 🎯 OBSERVAÇÕES FINAIS

- **Either<Failure, T>** é OBRIGATÓRIO em toda domain layer
- **AsyncValue<T>** para todos os states assíncronos
- **Code generation** para todos os providers (@riverpod)
- **Testes unitários** para TODOS os use cases
- Se feature for **cross-app**, considere mover repository para **packages/core**

Boa implementação! 🚀
