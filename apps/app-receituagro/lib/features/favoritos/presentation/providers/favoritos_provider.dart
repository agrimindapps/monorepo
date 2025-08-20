import 'package:flutter/foundation.dart';

import '../../domain/entities/favorito_entity.dart';
import '../../domain/usecases/favoritos_usecases.dart';

/// Provider para gerenciar estado dos favoritos (Presentation Layer)
/// Princípios: Single Responsibility + Dependency Inversion
class FavoritosProvider extends ChangeNotifier {
  // Use Cases injetados via DI
  final GetAllFavoritosUseCase _getAllFavoritosUseCase;
  final GetDefensivosFavoritosUseCase _getDefensivosFavoritosUseCase;
  final GetPragasFavoritosUseCase _getPragasFavoritosUseCase;
  final GetDiagnosticosFavoritosUseCase _getDiagnosticosFavoritosUseCase;
  final GetCulturasFavoritosUseCase _getCulturasFavoritosUseCase;
  final IsFavoritoUseCase _isFavoritoUseCase;
  final ToggleFavoritoUseCase _toggleFavoritoUseCase;
  final SearchFavoritosUseCase _searchFavoritosUseCase;
  final GetFavoritosStatsUseCase _getFavoritosStatsUseCase;

  // Estados
  List<FavoritoEntity> _allFavoritos = [];
  List<FavoritoDefensivoEntity> _defensivos = [];
  List<FavoritoPragaEntity> _pragas = [];
  List<FavoritoDiagnosticoEntity> _diagnosticos = [];
  List<FavoritoCulturaEntity> _culturas = [];
  FavoritosStats? _stats;
  
  bool _isLoading = false;
  String? _errorMessage;
  String _currentFilter = TipoFavorito.defensivo;

  FavoritosProvider({
    required GetAllFavoritosUseCase getAllFavoritosUseCase,
    required GetDefensivosFavoritosUseCase getDefensivosFavoritosUseCase,
    required GetPragasFavoritosUseCase getPragasFavoritosUseCase,
    required GetDiagnosticosFavoritosUseCase getDiagnosticosFavoritosUseCase,
    required GetCulturasFavoritosUseCase getCulturasFavoritosUseCase,
    required IsFavoritoUseCase isFavoritoUseCase,
    required ToggleFavoritoUseCase toggleFavoritoUseCase,
    required SearchFavoritosUseCase searchFavoritosUseCase,
    required GetFavoritosStatsUseCase getFavoritosStatsUseCase,
  }) : _getAllFavoritosUseCase = getAllFavoritosUseCase,
       _getDefensivosFavoritosUseCase = getDefensivosFavoritosUseCase,
       _getPragasFavoritosUseCase = getPragasFavoritosUseCase,
       _getDiagnosticosFavoritosUseCase = getDiagnosticosFavoritosUseCase,
       _getCulturasFavoritosUseCase = getCulturasFavoritosUseCase,
       _isFavoritoUseCase = isFavoritoUseCase,
       _toggleFavoritoUseCase = toggleFavoritoUseCase,
       _searchFavoritosUseCase = searchFavoritosUseCase,
       _getFavoritosStatsUseCase = getFavoritosStatsUseCase;

  // Getters
  List<FavoritoEntity> get allFavoritos => List.unmodifiable(_allFavoritos);
  List<FavoritoDefensivoEntity> get defensivos => List.unmodifiable(_defensivos);
  List<FavoritoPragaEntity> get pragas => List.unmodifiable(_pragas);
  List<FavoritoDiagnosticoEntity> get diagnosticos => List.unmodifiable(_diagnosticos);
  List<FavoritoCulturaEntity> get culturas => List.unmodifiable(_culturas);
  FavoritosStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentFilter => _currentFilter;

  // Getters de conveniência
  bool get hasDefensivos => _defensivos.isNotEmpty;
  bool get hasPragas => _pragas.isNotEmpty;
  bool get hasDiagnosticos => _diagnosticos.isNotEmpty;
  bool get hasCulturas => _culturas.isNotEmpty;
  bool get hasAnyFavoritos => _allFavoritos.isNotEmpty;

  /// Inicialização
  Future<void> initialize() async {
    await Future.wait([
      loadAllFavoritos(),
      loadStats(),
    ]);
  }

  /// Carrega todos os favoritos
  Future<void> loadAllFavoritos() async {
    await _executeUseCase(() async {
      _allFavoritos = await _getAllFavoritosUseCase.execute();
      _separateByType();
    });
  }

  /// Carrega favoritos por tipo específico
  Future<void> loadFavoritosByTipo(String tipo) async {
    await _executeUseCase(() async {
      switch (tipo) {
        case TipoFavorito.defensivo:
          _defensivos = await _getDefensivosFavoritosUseCase.execute();
          break;
        case TipoFavorito.praga:
          _pragas = await _getPragasFavoritosUseCase.execute();
          break;
        case TipoFavorito.diagnostico:
          _diagnosticos = await _getDiagnosticosFavoritosUseCase.execute();
          break;
        case TipoFavorito.cultura:
          _culturas = await _getCulturasFavoritosUseCase.execute();
          break;
      }
      _currentFilter = tipo;
    });
  }

  /// Carrega defensivos favoritos
  Future<void> loadDefensivos() async {
    await _executeUseCase(() async {
      _defensivos = await _getDefensivosFavoritosUseCase.execute();
    });
  }

  /// Carrega pragas favoritas
  Future<void> loadPragas() async {
    await _executeUseCase(() async {
      _pragas = await _getPragasFavoritosUseCase.execute();
    });
  }

  /// Carrega diagnósticos favoritos
  Future<void> loadDiagnosticos() async {
    await _executeUseCase(() async {
      _diagnosticos = await _getDiagnosticosFavoritosUseCase.execute();
    });
  }

  /// Carrega culturas favoritas
  Future<void> loadCulturas() async {
    await _executeUseCase(() async {
      _culturas = await _getCulturasFavoritosUseCase.execute();
    });
  }

  /// Verifica se um item é favorito
  Future<bool> isFavorito(String tipo, String id) async {
    try {
      return await _isFavoritoUseCase.execute(tipo, id);
    } catch (e) {
      debugPrint('Erro ao verificar favorito: $e');
      return false;
    }
  }

  /// Alterna favorito (adiciona/remove)
  Future<bool> toggleFavorito(String tipo, String id) async {
    try {
      _setLoading(true);
      
      final result = await _toggleFavoritoUseCase.execute(tipo, id);
      
      if (result) {
        // Recarrega os dados após mudança
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

  /// Pesquisa favoritos
  Future<void> searchFavoritos(String query) async {
    await _executeUseCase(() async {
      if (query.trim().isEmpty) {
        await loadAllFavoritos();
      } else {
        _allFavoritos = await _searchFavoritosUseCase.execute(query);
        _separateByType();
      }
    });
  }

  /// Carrega estatísticas
  Future<void> loadStats() async {
    await _executeUseCase(() async {
      _stats = await _getFavoritosStatsUseCase.execute();
    });
  }

  /// Define filtro atual
  void setCurrentFilter(String tipo) {
    if (TipoFavorito.isValid(tipo) && _currentFilter != tipo) {
      _currentFilter = tipo;
      notifyListeners();
    }
  }

  /// Limpa busca
  void clearSearch() {
    loadAllFavoritos();
  }

  /// Limpa erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Obtém favoritos do tipo atual
  List<FavoritoEntity> getCurrentTypeFavoritos() {
    switch (_currentFilter) {
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

  /// Métodos helper privados
  void _separateByType() {
    _defensivos = _allFavoritos.whereType<FavoritoDefensivoEntity>().toList();
    _pragas = _allFavoritos.whereType<FavoritoPragaEntity>().toList();
    _diagnosticos = _allFavoritos.whereType<FavoritoDiagnosticoEntity>().toList();
    _culturas = _allFavoritos.whereType<FavoritoCulturaEntity>().toList();
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

  Future<void> _executeUseCase(Future<void> Function() useCase) async {
    try {
      _setLoading(true);
      _clearError();
      
      await useCase();
      
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
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

/// Extension para facilitar uso na UI
extension FavoritosProviderUI on FavoritosProvider {
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