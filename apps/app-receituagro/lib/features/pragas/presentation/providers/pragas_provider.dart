import 'package:flutter/foundation.dart';

import '../../domain/entities/praga_entity.dart';
import '../../domain/usecases/get_pragas_usecase.dart';

/// Provider para gerenciar estado das pragas (Presentation Layer)
/// Princípios: Single Responsibility + Dependency Inversion
class PragasProvider extends ChangeNotifier {
  // Use Cases injetados via DI
  final GetPragasUseCase _getPragasUseCase;
  final GetPragasByTipoUseCase _getPragasByTipoUseCase;
  final GetPragaByIdUseCase _getPragaByIdUseCase;
  final GetPragasByCulturaUseCase _getPragasByCulturaUseCase;
  final SearchPragasUseCase _searchPragasUseCase;
  final GetRecentPragasUseCase _getRecentPragasUseCase;
  final GetSuggestedPragasUseCase _getSuggestedPragasUseCase;
  final GetPragasStatsUseCase _getPragasStatsUseCase;

  // Estados
  List<PragaEntity> _pragas = [];
  List<PragaEntity> _recentPragas = [];
  List<PragaEntity> _suggestedPragas = [];
  PragaEntity? _selectedPraga;
  PragasStats? _stats;
  
  bool _isLoading = false;
  String? _errorMessage;

  PragasProvider({
    required GetPragasUseCase getPragasUseCase,
    required GetPragasByTipoUseCase getPragasByTipoUseCase,
    required GetPragaByIdUseCase getPragaByIdUseCase,
    required GetPragasByCulturaUseCase getPragasByCulturaUseCase,
    required SearchPragasUseCase searchPragasUseCase,
    required GetRecentPragasUseCase getRecentPragasUseCase,
    required GetSuggestedPragasUseCase getSuggestedPragasUseCase,
    required GetPragasStatsUseCase getPragasStatsUseCase,
  }) : _getPragasUseCase = getPragasUseCase,
       _getPragasByTipoUseCase = getPragasByTipoUseCase,
       _getPragaByIdUseCase = getPragaByIdUseCase,
       _getPragasByCulturaUseCase = getPragasByCulturaUseCase,
       _searchPragasUseCase = searchPragasUseCase,
       _getRecentPragasUseCase = getRecentPragasUseCase,
       _getSuggestedPragasUseCase = getSuggestedPragasUseCase,
       _getPragasStatsUseCase = getPragasStatsUseCase;

  // Getters
  List<PragaEntity> get pragas => List.unmodifiable(_pragas);
  List<PragaEntity> get recentPragas => List.unmodifiable(_recentPragas);
  List<PragaEntity> get suggestedPragas => List.unmodifiable(_suggestedPragas);
  PragaEntity? get selectedPraga => _selectedPraga;
  PragasStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Getters de conveniência por tipo
  List<PragaEntity> get insetos => _pragas.where((p) => p.isInseto).toList();
  List<PragaEntity> get doencas => _pragas.where((p) => p.isDoenca).toList();
  List<PragaEntity> get plantas => _pragas.where((p) => p.isPlanta).toList();

  /// Inicialização
  Future<void> initialize() async {
    await Future.wait([
      loadRecentPragas(),
      loadSuggestedPragas(),
      loadStats(),
    ]);
  }

  /// Carrega todas as pragas
  Future<void> loadAllPragas() async {
    await _executeUseCase(() async {
      final result = await _getPragasUseCase.execute();
      result.fold(
        (failure) => throw Exception(failure.message),
        (pragas) {
          // Ordena alfabeticamente por nome comum
          pragas.sort((a, b) => a.nomeComum.compareTo(b.nomeComum));
          _pragas = pragas;
        },
      );
    });
  }

  /// Carrega pragas por tipo
  Future<void> loadPragasByTipo(String tipo) async {
    await _executeUseCase(() async {
      final result = await _getPragasByTipoUseCase.execute(tipo);
      result.fold(
        (failure) => throw Exception(failure.message),
        (pragas) {
          // Ordena alfabeticamente por nome comum
          pragas.sort((a, b) => a.nomeComum.compareTo(b.nomeComum));
          _pragas = pragas;
        },
      );
    });
  }

  /// Seleciona uma praga por ID
  Future<void> selectPragaById(String id) async {
    await _executeUseCase(() async {
      _selectedPraga = await _getPragaByIdUseCase.execute(id);
      
      // Atualiza lista de recentes após acessar
      if (_selectedPraga != null) {
        await loadRecentPragas();
      }
    });
  }

  /// Carrega pragas por cultura
  Future<void> loadPragasByCultura(String culturaId) async {
    await _executeUseCase(() async {
      _pragas = await _getPragasByCulturaUseCase.execute(culturaId);
      // Ordena alfabeticamente por nome comum
      _pragas.sort((a, b) => a.nomeComum.compareTo(b.nomeComum));
    });
  }

  /// Pesquisa pragas por nome
  Future<void> searchPragas(String searchTerm) async {
    await _executeUseCase(() async {
      _pragas = await _searchPragasUseCase.execute(searchTerm);
      // Ordena resultados da busca alfabeticamente
      _pragas.sort((a, b) => a.nomeComum.compareTo(b.nomeComum));
    });
  }

  /// Carrega pragas recentes
  Future<void> loadRecentPragas() async {
    await _executeUseCase(() async {
      _recentPragas = await _getRecentPragasUseCase.execute();
    });
  }

  /// Carrega pragas sugeridas
  Future<void> loadSuggestedPragas({int limit = 5}) async {
    await _executeUseCase(() async {
      _suggestedPragas = await _getSuggestedPragasUseCase.execute(limit: limit);
    });
  }

  /// Carrega estatísticas
  Future<void> loadStats() async {
    await _executeUseCase(() async {
      _stats = await _getPragasStatsUseCase.execute();
    });
  }

  /// Limpa seleção atual
  void clearSelection() {
    _selectedPraga = null;
    notifyListeners();
  }

  /// Limpa resultados de pesquisa
  void clearSearch() {
    _pragas.clear();
    notifyListeners();
  }

  /// Limpa erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Método helper para executar use cases com tratamento de erro
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
enum PragasViewState {
  initial,
  loading,
  loaded,
  error,
  empty,
}

/// Extension para facilitar uso na UI
extension PragasProviderUI on PragasProvider {
  PragasViewState get viewState {
    if (isLoading) return PragasViewState.loading;
    if (errorMessage != null) return PragasViewState.error;
    if (pragas.isEmpty) return PragasViewState.empty;
    return PragasViewState.loaded;
  }

  bool get hasData => pragas.isNotEmpty;
  bool get hasRecentPragas => recentPragas.isNotEmpty;
  bool get hasSuggestedPragas => suggestedPragas.isNotEmpty;
  bool get hasSelectedPraga => selectedPraga != null;
}