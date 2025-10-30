import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/favoritos_repository_simplified.dart';
import '../../domain/entities/favorito_entity.dart';
import '../../favoritos_di.dart';

part 'favoritos_notifier.g.dart';

/// Estado dos favoritos para Riverpod
///
/// **REFACTORED (Task 4):**
/// - Antes: 5 listas separadas (allFavoritos, defensivos, pragas, diagnosticos, culturas)
/// - Depois: 1 lista genérica (favoritos) + filtro por tipo
///
/// **Benefício:** Eliminação de estado redundante, menor chance de inconsistência
class FavoritosState {
  /// Lista única com todos os favoritos (consolidado)
  /// Substitui: allFavoritos, defensivos, pragas, diagnosticos, culturas
  final List<FavoritoEntity> favoritos;

  final FavoritosStats? stats;
  final bool isLoading;
  final String? errorMessage;

  /// Tipo de favorito sendo exibido (filtro para UI)
  final String currentFilter;

  const FavoritosState({
    this.favoritos = const [],
    this.stats,
    this.isLoading = false,
    this.errorMessage,
    this.currentFilter = TipoFavorito.defensivo,
  });

  // ===== GETTERS PARA COMPATIBILIDADE =====

  /// Verifica se há favoritos do tipo específico
  bool hasType(String tipo) => favoritos.any((f) => f.tipo == tipo);

  bool get hasDefensivos => hasType(TipoFavorito.defensivo);
  bool get hasPragas => hasType(TipoFavorito.praga);
  bool get hasDiagnosticos => hasType(TipoFavorito.diagnostico);
  bool get hasCulturas => hasType(TipoFavorito.cultura);
  bool get hasAnyFavoritos => favoritos.isNotEmpty;

  // ===== MÉTODOS NOVO/CONSOLIDATED =====

  /// Filtra favoritos por tipo com type-safety genérico
  ///
  /// **Novo padrão (recomendado):**
  /// ```dart
  /// final defensivos = state.getFavoritosByTipo<FavoritoDefensivoEntity>(
  ///   TipoFavorito.defensivo
  /// );
  /// ```
  List<T> getFavoritosByTipo<T extends FavoritoEntity>(String tipo) {
    return favoritos.whereType<T>().where((f) => f.tipo == tipo).toList();
  }

  /// Filtra favoritos do tipo atual (currentFilter)
  List<FavoritoEntity> getCurrentTypeFavoritos() {
    return favoritos.where((f) => f.tipo == currentFilter).toList();
  }

  /// Busca favorito por ID e tipo
  FavoritoEntity? findFavorito(String tipo, String id) {
    try {
      return favoritos.firstWhere((f) => f.tipo == tipo && f.id == id);
    } catch (e) {
      return null;
    }
  }

  FavoritosState copyWith({
    List<FavoritoEntity>? favoritos,
    FavoritosStats? stats,
    bool? isLoading,
    String? errorMessage,
    String? currentFilter,
  }) {
    return FavoritosState(
      favoritos: favoritos ?? this.favoritos,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      currentFilter: currentFilter ?? this.currentFilter,
    );
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

    final hasType = favoritos.any((f) => f.tipo == tipo);
    return hasType ? FavoritosViewState.loaded : FavoritosViewState.empty;
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
    return favoritos.where((f) => f.tipo == tipo).length;
  }
}

/// Estados específicos para UI
enum FavoritosViewState { initial, loading, loaded, error, empty }

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
    await Future.wait([loadAllFavoritos(), loadStats()]);
  }

  /// Carrega todos os favoritos
  /// Novo padrão: Carrega uma única lista genérica em vez de 5 separadas
  Future<void> loadAllFavoritos() async {
    await _executeOperation(() async {
      final favoritos = await _repository.getAll();
      state = state.copyWith(favoritos: favoritos);
    });
  }

  /// Carrega favoritos por tipo específico
  /// Novo padrão: Carrega todos e filtra conforme currentFilter
  Future<void> loadFavoritosByTipo(String tipo) async {
    await _executeOperation(() async {
      state = state.copyWith(currentFilter: tipo);
      // Os favoritos já estão em memory, apenas atualiza o filtro
      // Se precisar recarregar, chama loadAllFavoritos()
    });
  }

  /// Carrega defensivos favoritos
  /// @Deprecated Use loadAllFavoritos() + state.defensivos getter em vez disso
  Future<void> loadDefensivos() async {
    await loadAllFavoritos();
  }

  /// Carrega pragas favoritas
  /// @Deprecated Use loadAllFavoritos() + state.pragas getter em vez disso
  Future<void> loadPragas() async {
    await loadAllFavoritos();
  }

  /// Carrega diagnósticos favoritos
  /// @Deprecated Use loadAllFavoritos() + state.diagnosticos getter em vez disso
  Future<void> loadDiagnosticos() async {
    await loadAllFavoritos();
  }

  /// Carrega culturas favoritas
  /// @Deprecated Use loadAllFavoritos() + state.culturas getter em vez disso
  Future<void> loadCulturas() async {
    await loadAllFavoritos();
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
        await loadAllFavoritos(); // Recarrega após toggle
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
  /// @Deprecated Use addFavoritoUseCase(FavoritoEntity) em vez disso
  Future<bool> addFavorito(String tipo, String id) async {
    try {
      _setLoading(true);

      // Usa os métodos específicos ainda disponíveis
      bool result;
      switch (tipo) {
        case TipoFavorito.defensivo:
          result = await _repository.addDefensivo(id);
          break;
        case TipoFavorito.praga:
          result = await _repository.addPraga(id);
          break;
        case TipoFavorito.diagnostico:
          result = await _repository.addDiagnostico(id);
          break;
        case TipoFavorito.cultura:
          result = await _repository.addCultura(id);
          break;
        default:
          result = false;
      }

      if (result) {
        await loadAllFavoritos(); // Recarrega após adicionar
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
        await loadAllFavoritos(); // Recarrega após remover
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
        state = state.copyWith(favoritos: favoritos);
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

  /// @Deprecated Método removido - use loadAllFavoritos() em vez disso
  @Deprecated('Não é mais necessário - todos os favoritos já estão em memória')
  Future<void> _reloadAfterToggle(String tipo) async {
    // Apenas recarrega tudo (consolidado)
    await loadAllFavoritos();
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
