import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/categoria.dart';
import '../../domain/entities/termo.dart';
import '../../domain/repositories/termos_repository.dart';
import '../../domain/usecases/abrir_termo_externo.dart';
import '../../domain/usecases/carregar_termos.dart';
import '../../domain/usecases/compartilhar_termo.dart';
import '../../domain/usecases/copiar_termo.dart';
import '../../domain/usecases/get_categoria_atual.dart';
import '../../domain/usecases/get_favoritos.dart';
import '../../domain/usecases/set_categoria.dart';
import '../../domain/usecases/toggle_favorito.dart';
import '../../data/datasources/local/database_datasource.dart';
import '../../data/datasources/local/termos_local_datasource.dart';
import '../../data/repositories/termos_repository_impl.dart';
import '../../../../core/services/localstorage_service.dart';

part 'termos_providers.g.dart';

// ============================================================================
// Service Providers
// ============================================================================

@riverpod
LocalStorageService localStorageService(Ref ref) {
  return LocalStorageService();
}

// ============================================================================
// Data Source Providers
// ============================================================================

@riverpod
DatabaseDataSource databaseDataSource(Ref ref) {
  return DatabaseDataSourceImpl();
}

@riverpod
TermosLocalDataSource termosLocalDataSource(Ref ref) {
  final databaseDataSource = ref.watch(databaseDataSourceProvider);
  final localStorageService = ref.watch(localStorageServiceProvider);
  return TermosLocalDataSourceImpl(databaseDataSource, localStorageService);
}

// ============================================================================
// Repository Provider
// ============================================================================

@riverpod
TermosRepository termosRepository(Ref ref) {
  final dataSource = ref.watch(termosLocalDataSourceProvider);
  return TermosRepositoryImpl(dataSource);
}

// ============================================================================
// Use Case Providers
// ============================================================================

@riverpod
CarregarTermos carregarTermosUseCase(Ref ref) {
  final repository = ref.watch(termosRepositoryProvider);
  return CarregarTermos(repository);
}

@riverpod
ToggleFavorito toggleFavoritoUseCase(Ref ref) {
  final repository = ref.watch(termosRepositoryProvider);
  return ToggleFavorito(repository);
}

@riverpod
GetCategoriaAtual getCategoriaAtualUseCase(Ref ref) {
  final repository = ref.watch(termosRepositoryProvider);
  return GetCategoriaAtual(repository);
}

@riverpod
SetCategoria setCategoriaUseCase(Ref ref) {
  final repository = ref.watch(termosRepositoryProvider);
  return SetCategoria(repository);
}

@riverpod
GetFavoritos getFavoritosUseCase(Ref ref) {
  final repository = ref.watch(termosRepositoryProvider);
  return GetFavoritos(repository);
}

@riverpod
CompartilharTermo compartilharTermoUseCase(Ref ref) {
  return CompartilharTermo();
}

@riverpod
CopiarTermo copiarTermoUseCase(Ref ref) {
  return CopiarTermo();
}

@riverpod
AbrirTermoExterno abrirTermoExternoUseCase(Ref ref) {
  return AbrirTermoExterno();
}

// ============================================================================
// State Notifier - Lista de Termos
// ============================================================================

@riverpod
class TermosNotifier extends _$TermosNotifier {
  @override
  Future<List<Termo>> build() async {
    return _loadTermos();
  }

  Future<List<Termo>> _loadTermos() async {
    final useCase = ref.read(carregarTermosUseCaseProvider);
    final result = await useCase();

    return result.fold(
      (failure) => throw Exception(failure.message),
      (termos) => termos,
    );
  }

  /// Toggle favorite status for a termo
  Future<void> toggleFavorito(String termoId) async {
    // Get current state
    final currentTermos = state.value ?? [];

    // Optimistic update
    final updatedTermos = currentTermos.map((termo) {
      if (termo.id == termoId) {
        return termo.copyWith(favorito: !termo.favorito);
      }
      return termo;
    }).toList();

    state = AsyncValue.data(updatedTermos);

    // Perform actual toggle
    final useCase = ref.read(toggleFavoritoUseCaseProvider);
    final result = await useCase(termoId);

    result.fold(
      (failure) {
        // Revert on failure
        state = AsyncValue.data(currentTermos);
        throw Exception(failure.message);
      },
      (isFavorited) {
        // Success - state already updated optimistically
      },
    );
  }

  /// Refresh the termos list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadTermos());
  }

  /// Compartilhar termo
  Future<void> compartilhar(Termo termo) async {
    final useCase = ref.read(compartilharTermoUseCaseProvider);
    final result = await useCase(termo);

    result.fold(
      (failure) => throw Exception(failure.message),
      (_) => null,
    );
  }

  /// Copiar termo
  Future<void> copiar(Termo termo) async {
    final useCase = ref.read(copiarTermoUseCaseProvider);
    final result = await useCase(termo);

    result.fold(
      (failure) => throw Exception(failure.message),
      (_) => null,
    );
  }

  /// Abrir termo em navegador externo
  Future<void> abrirExterno(Termo termo) async {
    final useCase = ref.read(abrirTermoExternoUseCaseProvider);
    final result = await useCase(termo);

    result.fold(
      (failure) => throw Exception(failure.message),
      (_) => null,
    );
  }
}

// ============================================================================
// State Notifier - Categoria Atual
// ============================================================================

@riverpod
class CategoriaAtualNotifier extends _$CategoriaAtualNotifier {
  @override
  Future<Categoria> build() async {
    final useCase = ref.read(getCategoriaAtualUseCaseProvider);
    final result = await useCase();

    return result.fold(
      (failure) => throw Exception(failure.message),
      (categoria) => categoria,
    );
  }

  /// Set the current category
  Future<void> setCategoria(Categoria categoria) async {
    state = const AsyncValue.loading();

    final useCase = ref.read(setCategoriaUseCaseProvider);
    final result = await useCase(categoria);

    state = await AsyncValue.guard(() async {
      return result.fold(
        (failure) => throw Exception(failure.message),
        (_) => categoria,
      );
    });

    // Refresh termos list when category changes
    ref.invalidate(termosNotifierProvider);
  }
}

// ============================================================================
// Derived State - Favoritos
// ============================================================================

@riverpod
Future<List<Termo>> favoritosTermos(Ref ref) async {
  final termosAsync = ref.watch(termosNotifierProvider);

  return termosAsync.when(
    data: (termos) => termos.where((termo) => termo.favorito).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
}

// ============================================================================
// Derived State - Categorias List
// ============================================================================

@riverpod
Future<List<Categoria>> categoriasList(Ref ref) async {
  final repository = ref.watch(termosRepositoryProvider);
  final result = await repository.getCategorias();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (categorias) => categorias,
  );
}

// ============================================================================
// Derived State - Termos por Categoria
// ============================================================================

@riverpod
List<Termo> termosPorCategoria(Ref ref, String categoria) {
  final termosAsync = ref.watch(termosNotifierProvider);

  return termosAsync.when(
    data: (termos) =>
        termos.where((termo) => termo.categoria == categoria).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
}

// ============================================================================
// Derived State - Search
// ============================================================================

@riverpod
List<Termo> searchTermos(Ref ref, String query) {
  final termosAsync = ref.watch(termosNotifierProvider);

  if (query.trim().isEmpty) {
    return termosAsync.value ?? [];
  }

  final lowerQuery = query.toLowerCase();

  return termosAsync.when(
    data: (termos) => termos.where((termo) {
      return termo.termo.toLowerCase().contains(lowerQuery) ||
          termo.descricao.toLowerCase().contains(lowerQuery);
    }).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
}
