import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/favoritos_repository_simplified.dart';
import '../../domain/entities/favorito_entity.dart';
import '../../favoritos_di.dart';

part 'favoritos_notifier.g.dart';

/// Estado dos favoritos para Riverpod
class FavoritosState {
  final List<FavoritoEntity> allFavoritos;
  final List<FavoritoDefensivoEntity> defensivos;
  final List<FavoritoPragaEntity> pragas;
  final List<FavoritoDiagnosticoEntity> diagnosticos;
  final List<FavoritoCulturaEntity> culturas;
  final FavoritosStats? stats;
  final bool isLoading;
  final String? errorMessage;
  final String currentFilter;

  const FavoritosState({
    this.allFavoritos = const [],
    this.defensivos = const [],
    this.pragas = const [],
    this.diagnosticos = const [],
    this.culturas = const [],
    this.stats,
    this.isLoading = false,
    this.errorMessage,
    this.currentFilter = TipoFavorito.defensivo,
  });

  // Getters de conveniência
  bool get hasDefensivos => defensivos.isNotEmpty;
  bool get hasPragas => pragas.isNotEmpty;
  bool get hasDiagnosticos => diagnosticos.isNotEmpty;
  bool get hasCulturas => culturas.isNotEmpty;
  bool get hasAnyFavoritos => allFavoritos.isNotEmpty;

  FavoritosState copyWith({
    List<FavoritoEntity>? allFavoritos,
    List<FavoritoDefensivoEntity>? defensivos,
    List<FavoritoPragaEntity>? pragas,
    List<FavoritoDiagnosticoEntity>? diagnosticos,
    List<FavoritoCulturaEntity>? culturas,
    FavoritosStats? stats,
    bool? isLoading,
    String? errorMessage,
    String? currentFilter,
  }) {
    return FavoritosState(
      allFavoritos: allFavoritos ?? this.allFavoritos,
      defensivos: defensivos ?? this.defensivos,
      pragas: pragas ?? this.pragas,
      diagnosticos: diagnosticos ?? this.diagnosticos,
      culturas: culturas ?? this.culturas,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }

  /// Obtém favoritos do tipo atual
  List<FavoritoEntity> getCurrentTypeFavoritos() {
    switch (currentFilter) {
      case TipoFavorito.defensivo:
        return defensivos;
      case TipoFavorito.praga:
        return pragas;
      case TipoFavorito.diagnostico:
        return diagnosticos;
      case TipoFavorito.cultura:
        return culturas;
      default:
        return allFavoritos;
    }
  }

  /// Estados específicos para UI
  FavoritosViewState get viewState {
    if (isLoading) return FavoritosViewState.loading;
    if (errorMessage != null) return FavoritosViewState.error;
    if (!hasAnyFavoritos) return FavoritosViewState.empty;
    return FavoritosViewState.loaded;
  }

  FavoritosViewState getViewStateForType(String tipo) {
    if (isLoading) return FavoritosViewState.loading;
    if (errorMessage != null) return FavoritosViewState.error;

    switch (tipo) {
      case TipoFavorito.defensivo:
        return hasDefensivos ? FavoritosViewState.loaded : FavoritosViewState.empty;
      case TipoFavorito.praga:
        return hasPragas ? FavoritosViewState.loaded : FavoritosViewState.empty;
      case TipoFavorito.diagnostico:
        return hasDiagnosticos ? FavoritosViewState.loaded : FavoritosViewState.empty;
      case TipoFavorito.cultura:
        return hasCulturas ? FavoritosViewState.loaded : FavoritosViewState.empty;
      default:
        return hasAnyFavoritos ? FavoritosViewState.loaded : FavoritosViewState.empty;
    }
  }

  String getEmptyMessageForType(String tipo) {
    switch (tipo) {
      case TipoFavorito.defensivo:
        return 'Nenhum defensivo favoritado';
      case TipoFavorito.praga:
        return 'Nenhuma praga favoritada';
      case TipoFavorito.diagnostico:
        return 'Nenhum diagnóstico favoritado';
      case TipoFavorito.cultura:
        return 'Nenhuma cultura favoritada';
      default:
        return 'Nenhum favorito encontrado';
    }
  }

  int getCountForType(String tipo) {
    switch (tipo) {
      case TipoFavorito.defensivo:
        return defensivos.length;
      case TipoFavorito.praga:
        return pragas.length;
      case TipoFavorito.diagnostico:
        return diagnosticos.length;
      case TipoFavorito.cultura:
        return culturas.length;
      default:
        return allFavoritos.length;
    }
  }
}

/// Estados específicos para UI
enum FavoritosViewState {
  initial,
  loading,
  loaded,
  error,
  empty,
}

/// Notifier Riverpod para gerenciar estado dos favoritos
@riverpod
class FavoritosNotifier extends _$FavoritosNotifier {
  late final FavoritosRepositorySimplified _repository;

  @override
  FavoritosState build() {
    _repository = FavoritosDI.get<FavoritosRepositorySimplified>();
    return const FavoritosState();
  }

  /// Inicialização
  Future<void> initialize() async {
    await Future.wait([
      loadAllFavoritos(),
      loadStats(),
    ]);
  }

  /// Carrega todos os favoritos
  Future<void> loadAllFavoritos() async {
    await _executeOperation(() async {
      final favoritos = await _repository.getAll();
      state = state.copyWith(
        allFavoritos: favoritos,
      );
      _separateByType(favoritos);
    });
  }

  /// Carrega favoritos por tipo específico
  Future<void> loadFavoritosByTipo(String tipo) async {
    await _executeOperation(() async {
      switch (tipo) {
        case TipoFavorito.defensivo:
          final defensivos = await _repository.getDefensivos();
          state = state.copyWith(defensivos: defensivos);
          break;
        case TipoFavorito.praga:
          final pragas = await _repository.getPragas();
          state = state.copyWith(pragas: pragas);
          break;
        case TipoFavorito.diagnostico:
          final diagnosticos = await _repository.getDiagnosticos();
          state = state.copyWith(diagnosticos: diagnosticos);
          break;
        case TipoFavorito.cultura:
          final culturas = await _repository.getCulturas();
          state = state.copyWith(culturas: culturas);
          break;
      }
      state = state.copyWith(currentFilter: tipo);
    });
  }

  /// Carrega defensivos favoritos
  Future<void> loadDefensivos() async {
    await _executeOperation(() async {
      final defensivos = await _repository.getDefensivos();
      state = state.copyWith(defensivos: defensivos);
    });
  }

  /// Carrega pragas favoritas
  Future<void> loadPragas() async {
    await _executeOperation(() async {
      final pragas = await _repository.getPragas();
      state = state.copyWith(pragas: pragas);
    });
  }

  /// Carrega diagnósticos favoritos
  Future<void> loadDiagnosticos() async {
    await _executeOperation(() async {
      final diagnosticos = await _repository.getDiagnosticos();
      state = state.copyWith(diagnosticos: diagnosticos);
    });
  }

  /// Carrega culturas favoritas
  Future<void> loadCulturas() async {
    await _executeOperation(() async {
      final culturas = await _repository.getCulturas();
      state = state.copyWith(culturas: culturas);
    });
  }

  /// Verifica se um item é favorito
  Future<bool> isFavorito(String tipo, String id) async {
    try {
      return await _repository.isFavorito(tipo, id);
    } catch (e) {
      return false;
    }
  }

  /// Alterna favorito
  Future<bool> toggleFavorito(String tipo, String id) async {
    try {
      _setLoading(true);

      final result = await _repository.toggleFavorito(tipo, id);

      if (result) {
        await _reloadAfterToggle(tipo);
      }

      return result;
    } catch (e) {
      _setError('Erro ao alterar favorito: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Adiciona favorito
  Future<bool> addFavorito(String tipo, String id) async {
    try {
      _setLoading(true);

      final result = await _repository.addFavorito(tipo, id);

      if (result) {
        await _reloadAfterToggle(tipo);
      }

      return result;
    } catch (e) {
      _setError('Erro ao adicionar favorito: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Remove favorito
  Future<bool> removeFavorito(String tipo, String id) async {
    try {
      _setLoading(true);

      final result = await _repository.removeFavorito(tipo, id);

      if (result) {
        await _reloadAfterToggle(tipo);
      }

      return result;
    } catch (e) {
      _setError('Erro ao remover favorito: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Pesquisa favoritos
  Future<void> searchFavoritos(String query) async {
    await _executeOperation(() async {
      if (query.trim().isEmpty) {
        await loadAllFavoritos();
      } else {
        final favoritos = await _repository.search(query);
        state = state.copyWith(allFavoritos: favoritos);
        _separateByType(favoritos);
      }
    });
  }

  /// Carrega estatísticas
  Future<void> loadStats() async {
    await _executeOperation(() async {
      final stats = await _repository.getStats();
      state = state.copyWith(stats: stats);
    });
  }

  /// Limpa favoritos por tipo
  Future<void> clearFavorites(String tipo) async {
    try {
      _setLoading(true);

      await _repository.clearFavorites(tipo);
      await _reloadAfterToggle(tipo);
    } catch (e) {
      _setError('Erro ao limpar favoritos: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Limpa todos os favoritos
  Future<void> clearAllFavorites() async {
    try {
      _setLoading(true);

      await _repository.clearAllFavorites();
      await loadAllFavoritos();
      await loadStats();
    } catch (e) {
      _setError('Erro ao limpar todos os favoritos: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Sincroniza favoritos
  Future<void> syncFavorites() async {
    await _executeOperation(() async {
      await _repository.syncFavorites();
      await loadAllFavoritos();
      await loadStats();
    });
  }

  /// Define filtro atual
  void setCurrentFilter(String tipo) {
    if (TipoFavorito.isValid(tipo) && state.currentFilter != tipo) {
      state = state.copyWith(currentFilter: tipo);
    }
  }

  /// Limpa busca
  void clearSearch() {
    loadAllFavoritos();
  }

  /// Limpa erro
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  // ========== MÉTODOS HELPER PRIVADOS ==========

  void _separateByType(List<FavoritoEntity> favoritos) {
    state = state.copyWith(
      defensivos: favoritos.whereType<FavoritoDefensivoEntity>().toList(),
      pragas: favoritos.whereType<FavoritoPragaEntity>().toList(),
      diagnosticos: favoritos.whereType<FavoritoDiagnosticoEntity>().toList(),
      culturas: favoritos.whereType<FavoritoCulturaEntity>().toList(),
    );
  }

  Future<void> _reloadAfterToggle(String tipo) async {
    switch (tipo) {
      case TipoFavorito.defensivo:
        await loadDefensivos();
        break;
      case TipoFavorito.praga:
        await loadPragas();
        break;
      case TipoFavorito.diagnostico:
        await loadDiagnosticos();
        break;
      case TipoFavorito.cultura:
        await loadCulturas();
        break;
    }

    // Atualiza estatísticas
    await loadStats();
  }

  Future<void> _executeOperation(Future<void> Function() operation) async {
    try {
      _setLoading(true);
      _clearError();

      await operation();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void _setError(String error) {
    state = state.copyWith(errorMessage: error);
  }

  void _clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
