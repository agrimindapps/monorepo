import 'package:flutter/foundation.dart';

import '../../data/repositories/favoritos_repository_simplified.dart';
import '../../domain/entities/favorito_entity.dart';

/// Provider Simplificado para gerenciar estado dos favoritos
/// Princípio: Usar repository diretamente, eliminando use cases desnecessários
class FavoritosProviderSimplified extends ChangeNotifier {
  final FavoritosRepositorySimplified _repository;

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

  FavoritosProviderSimplified({
    required FavoritosRepositorySimplified repository,
  }) : _repository = repository;

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

  /// Carrega todos os favoritos usando repository diretamente
  Future<void> loadAllFavoritos() async {
    await _executeOperation(() async {
      _allFavoritos = await _repository.getAll();
      _separateByType();
    });
  }

  /// Carrega favoritos por tipo específico
  Future<void> loadFavoritosByTipo(String tipo) async {
    await _executeOperation(() async {
      switch (tipo) {
        case TipoFavorito.defensivo:
          _defensivos = await _repository.getDefensivos();
          break;
        case TipoFavorito.praga:
          _pragas = await _repository.getPragas();
          break;
        case TipoFavorito.diagnostico:
          _diagnosticos = await _repository.getDiagnosticos();
          break;
        case TipoFavorito.cultura:
          _culturas = await _repository.getCulturas();
          break;
      }
      _currentFilter = tipo;
    });
  }

  /// Carrega defensivos favoritos
  Future<void> loadDefensivos() async {
    await _executeOperation(() async {
      _defensivos = await _repository.getDefensivos();
    });
  }

  /// Carrega pragas favoritas
  Future<void> loadPragas() async {
    await _executeOperation(() async {
      _pragas = await _repository.getPragas();
    });
  }

  /// Carrega diagnósticos favoritos
  Future<void> loadDiagnosticos() async {
    await _executeOperation(() async {
      _diagnosticos = await _repository.getDiagnosticos();
    });
  }

  /// Carrega culturas favoritas
  Future<void> loadCulturas() async {
    await _executeOperation(() async {
      _culturas = await _repository.getCulturas();
    });
  }

  /// Verifica se um item é favorito usando repository diretamente
  Future<bool> isFavorito(String tipo, String id) async {
    try {
      debugPrint('🔍 [PROVIDER-SIMPLIFIED] Verificando se é favorito - tipo: $tipo, id: $id');
      final result = await _repository.isFavorito(tipo, id);
      debugPrint('🔍 [PROVIDER-SIMPLIFIED] Resultado: $result');
      return result;
    } catch (e) {
      debugPrint('❌ [PROVIDER-SIMPLIFIED] Erro ao verificar favorito: $e');
      return false;
    }
  }

  /// Alterna favorito usando repository diretamente
  Future<bool> toggleFavorito(String tipo, String id) async {
    try {
      debugPrint('🔄 [PROVIDER-SIMPLIFIED] Iniciando toggleFavorito');
      debugPrint('🔄 [PROVIDER-SIMPLIFIED] tipo: $tipo, id: $id');

      _setLoading(true);

      final result = await _repository.toggleFavorito(tipo, id);
      debugPrint('🔄 [PROVIDER-SIMPLIFIED] Resultado repository: $result');

      if (result) {
        // Recarrega os dados após mudança
        debugPrint('🔄 [PROVIDER-SIMPLIFIED] Recarregando dados após toggle...');
        await _reloadAfterToggle(tipo);
        debugPrint('✅ [PROVIDER-SIMPLIFIED] Toggle completado com sucesso');
      } else {
        debugPrint('❌ [PROVIDER-SIMPLIFIED] Repository retornou false');
      }

      return result;
    } catch (e) {
      debugPrint('❌ [PROVIDER-SIMPLIFIED] Erro ao alterar favorito: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      _setError('Erro ao alterar favorito: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Adiciona favorito usando repository diretamente
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

  /// Remove favorito usando repository diretamente
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

  /// Pesquisa favoritos usando repository diretamente
  Future<void> searchFavoritos(String query) async {
    await _executeOperation(() async {
      if (query.trim().isEmpty) {
        await loadAllFavoritos();
      } else {
        _allFavoritos = await _repository.search(query);
        _separateByType();
      }
    });
  }

  /// Carrega estatísticas usando repository diretamente
  Future<void> loadStats() async {
    await _executeOperation(() async {
      _stats = await _repository.getStats();
    });
  }

  /// Limpa favoritos por tipo usando repository diretamente
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

  /// Limpa todos os favoritos usando repository diretamente
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

  /// Sincroniza favoritos usando repository diretamente
  Future<void> syncFavorites() async {
    await _executeOperation(() async {
      await _repository.syncFavorites();
      await loadAllFavoritos();
      await loadStats();
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

  // ========== MÉTODOS HELPER PRIVADOS ==========

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
extension FavoritosProviderSimplifiedUI on FavoritosProviderSimplified {
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