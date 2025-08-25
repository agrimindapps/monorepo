import 'package:flutter/foundation.dart';

import '../../domain/entities/defensivo_entity.dart';
import '../../domain/usecases/get_defensivos_usecase.dart';

/// Provider para gerenciar estado dos defensivos (Presentation Layer)
/// Segue Clean Architecture com Use Cases
class DefensivosProvider extends ChangeNotifier {
  // Use Cases injetados via DI
  final GetDefensivosUseCase _getDefensivosUseCase;
  final GetActiveDefensivosUseCase _getActiveDefensivosUseCase;
  final GetElegibleDefensivosUseCase _getElegibleDefensivosUseCase;
  final GetDefensivoByIdUseCase _getDefensivoByIdUseCase;
  final SearchDefensivosByNomeUseCase _searchByNomeUseCase;
  final SearchDefensivosByIngredienteUseCase _searchByIngredienteUseCase;
  final SearchDefensivosByFabricanteUseCase _searchByFabricanteUseCase;
  final SearchDefensivosByClasseUseCase _searchByClasseUseCase;
  final SearchDefensivosAdvancedUseCase _searchAdvancedUseCase;
  final GetDefensivosStatsUseCase _getStatsUseCase;
  final GetDefensivosFiltersUseCase _getFiltersUseCase;
  final GetRelatedDefensivosUseCase _getRelatedUseCase;
  final GetPopularDefensivosUseCase _getPopularUseCase;
  final GetRecentDefensivosUseCase? _getRecentUseCase;

  // Estados
  List<DefensivoEntity> _defensivos = [];
  List<DefensivoEntity> _recentDefensivos = [];
  List<DefensivoEntity> _popularDefensivos = [];
  List<DefensivoEntity> _relatedDefensivos = [];
  DefensivoEntity? _selectedDefensivo;
  DefensivosStats? _stats;
  DefensivosFiltersData? _filtersData;
  DefensivoSearchFilters _currentFilters = const DefensivoSearchFilters();
  
  bool _isLoading = false;
  String? _errorMessage;

  DefensivosProvider({
    required GetDefensivosUseCase getDefensivosUseCase,
    required GetActiveDefensivosUseCase getActiveDefensivosUseCase,
    required GetElegibleDefensivosUseCase getElegibleDefensivosUseCase,
    required GetDefensivoByIdUseCase getDefensivoByIdUseCase,
    required SearchDefensivosByNomeUseCase searchByNomeUseCase,
    required SearchDefensivosByIngredienteUseCase searchByIngredienteUseCase,
    required SearchDefensivosByFabricanteUseCase searchByFabricanteUseCase,
    required SearchDefensivosByClasseUseCase searchByClasseUseCase,
    required SearchDefensivosAdvancedUseCase searchAdvancedUseCase,
    required GetDefensivosStatsUseCase getStatsUseCase,
    required GetDefensivosFiltersUseCase getFiltersUseCase,
    required GetRelatedDefensivosUseCase getRelatedUseCase,
    required GetPopularDefensivosUseCase getPopularUseCase,
    GetRecentDefensivosUseCase? getRecentUseCase,
  }) : _getDefensivosUseCase = getDefensivosUseCase,
       _getActiveDefensivosUseCase = getActiveDefensivosUseCase,
       _getElegibleDefensivosUseCase = getElegibleDefensivosUseCase,
       _getDefensivoByIdUseCase = getDefensivoByIdUseCase,
       _searchByNomeUseCase = searchByNomeUseCase,
       _searchByIngredienteUseCase = searchByIngredienteUseCase,
       _searchByFabricanteUseCase = searchByFabricanteUseCase,
       _searchByClasseUseCase = searchByClasseUseCase,
       _searchAdvancedUseCase = searchAdvancedUseCase,
       _getStatsUseCase = getStatsUseCase,
       _getFiltersUseCase = getFiltersUseCase,
       _getRelatedUseCase = getRelatedUseCase,
       _getPopularUseCase = getPopularUseCase,
       _getRecentUseCase = getRecentUseCase;

  // Getters
  List<DefensivoEntity> get defensivos => List.unmodifiable(_defensivos);
  List<DefensivoEntity> get recentDefensivos => List.unmodifiable(_recentDefensivos);
  List<DefensivoEntity> get popularDefensivos => List.unmodifiable(_popularDefensivos);
  List<DefensivoEntity> get relatedDefensivos => List.unmodifiable(_relatedDefensivos);
  DefensivoEntity? get selectedDefensivo => _selectedDefensivo;
  DefensivosStats? get stats => _stats;
  DefensivosFiltersData? get filtersData => _filtersData;
  DefensivoSearchFilters get currentFilters => _currentFilters;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Getters de conveniência
  List<DefensivoEntity> get activeDefensivos => _defensivos.where((d) => d.isActive).toList();
  List<DefensivoEntity> get elegibleDefensivos => _defensivos.where((d) => d.isElegible).toList();
  bool get hasData => _defensivos.isNotEmpty;
  bool get hasRecentDefensivos => _recentDefensivos.isNotEmpty;
  bool get hasPopularDefensivos => _popularDefensivos.isNotEmpty;
  bool get hasSelectedDefensivo => _selectedDefensivo != null;

  /// Inicialização
  Future<void> initialize() async {
    await Future.wait([
      loadFiltersData(),
      loadPopularDefensivos(),
      loadRecentDefensivos(),
      loadStats(),
    ]);
  }

  /// Carrega todos os defensivos
  Future<void> loadAllDefensivos({int? limit, int? offset}) async {
    await _executeUseCase(() async {
      final result = await _getDefensivosUseCase.call(limit: limit, offset: offset);
      result.fold(
        (failure) => throw Exception(failure.message),
        (defensivos) => _defensivos = defensivos,
      );
    });
  }

  /// Carrega defensivos ativos
  Future<void> loadActiveDefensivos() async {
    await _executeUseCase(() async {
      final result = await _getActiveDefensivosUseCase.call();
      result.fold(
        (failure) => throw Exception(failure.message),
        (defensivos) => _defensivos = defensivos,
      );
    });
  }

  /// Carrega defensivos elegíveis
  Future<void> loadElegibleDefensivos() async {
    await _executeUseCase(() async {
      final result = await _getElegibleDefensivosUseCase.call();
      result.fold(
        (failure) => throw Exception(failure.message),
        (defensivos) => _defensivos = defensivos,
      );
    });
  }

  /// Seleciona defensivo por ID
  Future<void> selectDefensivoById(String id) async {
    await _executeUseCase(() async {
      final result = await _getDefensivoByIdUseCase.call(id);
      result.fold(
        (failure) => throw Exception(failure.message),
        (defensivo) {
          _selectedDefensivo = defensivo;
          
          // Carrega relacionados se encontrado
          if (defensivo != null) {
            _loadRelatedDefensivos(id);
          }
        },
      );
    });
  }

  /// Busca por nome comum
  Future<void> searchByNome(String searchTerm) async {
    await _executeUseCase(() async {
      final result = await _searchByNomeUseCase.call(searchTerm);
      result.fold(
        (failure) => throw Exception(failure.message),
        (defensivos) => _defensivos = defensivos,
      );
    });
  }

  /// Busca por ingrediente ativo
  Future<void> searchByIngrediente(String searchTerm) async {
    await _executeUseCase(() async {
      final result = await _searchByIngredienteUseCase.call(searchTerm);
      result.fold(
        (failure) => throw Exception(failure.message),
        (defensivos) => _defensivos = defensivos,
      );
    });
  }

  /// Busca por fabricante
  Future<void> searchByFabricante(String fabricante) async {
    await _executeUseCase(() async {
      final result = await _searchByFabricanteUseCase.call(fabricante);
      result.fold(
        (failure) => throw Exception(failure.message),
        (defensivos) => _defensivos = defensivos,
      );
    });
  }

  /// Busca por classe agronômica
  Future<void> searchByClasse(String classe) async {
    await _executeUseCase(() async {
      final result = await _searchByClasseUseCase.call(classe);
      result.fold(
        (failure) => throw Exception(failure.message),
        (defensivos) => _defensivos = defensivos,
      );
    });
  }

  /// Busca avançada com filtros
  Future<void> searchAdvanced(DefensivoSearchFilters filters) async {
    await _executeUseCase(() async {
      _currentFilters = filters;
      final result = await _searchAdvancedUseCase.call(filters);
      result.fold(
        (failure) => throw Exception(failure.message),
        (defensivos) => _defensivos = defensivos,
      );
    });
  }

  /// Carrega dados dos filtros
  Future<void> loadFiltersData() async {
    await _executeUseCase(() async {
      final result = await _getFiltersUseCase.call();
      result.fold(
        (failure) => throw Exception(failure.message),
        (filtersData) => _filtersData = filtersData,
      );
    });
  }

  /// Carrega estatísticas
  Future<void> loadStats() async {
    await _executeUseCase(() async {
      final result = await _getStatsUseCase.call();
      result.fold(
        (failure) => throw Exception(failure.message),
        (stats) => _stats = stats,
      );
    });
  }

  /// Carrega defensivos populares
  Future<void> loadPopularDefensivos({int limit = 10}) async {
    await _executeUseCase(() async {
      final result = await _getPopularUseCase.call(limit: limit);
      result.fold(
        (failure) => throw Exception(failure.message),
        (defensivos) => _popularDefensivos = defensivos,
      );
    });
  }

  /// Carrega defensivos recentes
  Future<void> loadRecentDefensivos({int limit = 10}) async {
    if (_getRecentUseCase == null) return;
    
    await _executeUseCase(() async {
      final result = await _getRecentUseCase!.call(limit: limit);
      result.fold(
        (failure) => throw Exception(failure.message),
        (defensivos) => _recentDefensivos = defensivos,
      );
    });
  }

  /// Carrega defensivos relacionados (método privado)
  Future<void> _loadRelatedDefensivos(String defensivoId, {int limit = 5}) async {
    try {
      final result = await _getRelatedUseCase.call(defensivoId, limit: limit);
      result.fold(
        (failure) => _relatedDefensivos = [],
        (defensivos) {
          _relatedDefensivos = defensivos;
          notifyListeners();
        },
      );
    } catch (e) {
      _relatedDefensivos = [];
      notifyListeners();
    }
  }

  /// Limpa seleção atual
  void clearSelection() {
    _selectedDefensivo = null;
    _relatedDefensivos.clear();
    notifyListeners();
  }

  /// Limpa resultados de pesquisa
  void clearSearch() {
    _defensivos.clear();
    _currentFilters = const DefensivoSearchFilters();
    notifyListeners();
  }

  /// Limpa filtros
  void clearFilters() {
    _currentFilters = const DefensivoSearchFilters();
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
enum DefensivosViewState {
  initial,
  loading,
  loaded,
  error,
  empty,
}

/// Extension para facilitar uso na UI
extension DefensivosProviderUI on DefensivosProvider {
  DefensivosViewState get viewState {
    if (isLoading) return DefensivosViewState.loading;
    if (errorMessage != null) return DefensivosViewState.error;
    if (defensivos.isEmpty) return DefensivosViewState.empty;
    return DefensivosViewState.loaded;
  }

  bool get canLoadMore => defensivos.isNotEmpty && defensivos.length % 50 == 0;
  
  int get totalPages => (stats?.total ?? 0) ~/ 50;
  
  String get searchSummary {
    if (currentFilters.hasFilters) {
      return 'Filtros aplicados: ${defensivos.length} resultados';
    }
    return '${defensivos.length} defensivos encontrados';
  }
}