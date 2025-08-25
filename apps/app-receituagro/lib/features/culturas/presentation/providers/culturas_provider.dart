import 'package:flutter/foundation.dart';

import '../../domain/entities/cultura_entity.dart';
import '../../domain/usecases/get_culturas_usecase.dart';

/// Provider para gerenciar estado das culturas usando Clean Architecture
/// Segue princípios de separação de responsabilidades e usa Use Cases
class CulturasProvider extends ChangeNotifier {
  // Use Cases injetados
  final GetCulturasUseCase _getCulturasUseCase;
  final GetActiveCulturasUseCase _getActiveCulturasUseCase;
  final GetCulturaByIdUseCase _getCulturaByIdUseCase;
  final GetCulturaByNomeUseCase _getCulturaByNomeUseCase;
  final SearchCulturasByNomeUseCase _searchCulturasByNomeUseCase;
  final SearchCulturasByFamiliaUseCase _searchCulturasByFamiliaUseCase;
  final SearchCulturasByTipoUseCase _searchCulturasByTipoUseCase;
  final SearchCulturasWithFiltersUseCase _searchCulturasWithFiltersUseCase;
  final GetCulturaStatsUseCase _getCulturaStatsUseCase;
  final GetPopularCulturasUseCase _getPopularCulturasUseCase;
  final GetRelatedCulturasUseCase _getRelatedCulturasUseCase;
  final CheckCulturaExistsUseCase _checkCulturaExistsUseCase;
  final CheckCulturaExistsByNomeUseCase _checkCulturaExistsByNomeUseCase;
  final GetCulturaFiltersDataUseCase _getCulturaFiltersDataUseCase;
  final ValidateCulturaDataUseCase _validateCulturaDataUseCase;
  final SearchCulturasByPatternUseCase _searchCulturasByPatternUseCase;

  CulturasProvider({
    required GetCulturasUseCase getCulturasUseCase,
    required GetActiveCulturasUseCase getActiveCulturasUseCase,
    required GetCulturaByIdUseCase getCulturaByIdUseCase,
    required GetCulturaByNomeUseCase getCulturaByNomeUseCase,
    required SearchCulturasByNomeUseCase searchCulturasByNomeUseCase,
    required SearchCulturasByFamiliaUseCase searchCulturasByFamiliaUseCase,
    required SearchCulturasByTipoUseCase searchCulturasByTipoUseCase,
    required SearchCulturasWithFiltersUseCase searchCulturasWithFiltersUseCase,
    required GetCulturaStatsUseCase getCulturaStatsUseCase,
    required GetPopularCulturasUseCase getPopularCulturasUseCase,
    required GetRelatedCulturasUseCase getRelatedCulturasUseCase,
    required CheckCulturaExistsUseCase checkCulturaExistsUseCase,
    required CheckCulturaExistsByNomeUseCase checkCulturaExistsByNomeUseCase,
    required GetCulturaFiltersDataUseCase getCulturaFiltersDataUseCase,
    required ValidateCulturaDataUseCase validateCulturaDataUseCase,
    required SearchCulturasByPatternUseCase searchCulturasByPatternUseCase,
  }) : _getCulturasUseCase = getCulturasUseCase,
       _getActiveCulturasUseCase = getActiveCulturasUseCase,
       _getCulturaByIdUseCase = getCulturaByIdUseCase,
       _getCulturaByNomeUseCase = getCulturaByNomeUseCase,
       _searchCulturasByNomeUseCase = searchCulturasByNomeUseCase,
       _searchCulturasByFamiliaUseCase = searchCulturasByFamiliaUseCase,
       _searchCulturasByTipoUseCase = searchCulturasByTipoUseCase,
       _searchCulturasWithFiltersUseCase = searchCulturasWithFiltersUseCase,
       _getCulturaStatsUseCase = getCulturaStatsUseCase,
       _getPopularCulturasUseCase = getPopularCulturasUseCase,
       _getRelatedCulturasUseCase = getRelatedCulturasUseCase,
       _checkCulturaExistsUseCase = checkCulturaExistsUseCase,
       _checkCulturaExistsByNomeUseCase = checkCulturaExistsByNomeUseCase,
       _getCulturaFiltersDataUseCase = getCulturaFiltersDataUseCase,
       _validateCulturaDataUseCase = validateCulturaDataUseCase,
       _searchCulturasByPatternUseCase = searchCulturasByPatternUseCase;

  // Estado
  List<CulturaEntity> _culturas = [];
  CulturasViewState _viewState = CulturasViewState.initial;
  String? _errorMessage;
  CulturasStats? _stats;
  CulturaFiltersData? _filtersData;
  CulturaSearchFilters _currentFilters = const CulturaSearchFilters();
  bool _isLoadingMore = false;

  // Getters
  List<CulturaEntity> get culturas => _culturas;
  CulturasViewState get viewState => _viewState;
  String? get errorMessage => _errorMessage;
  CulturasStats? get stats => _stats;
  CulturaFiltersData? get filtersData => _filtersData;
  CulturaSearchFilters get currentFilters => _currentFilters;
  bool get isLoadingMore => _isLoadingMore;
  bool get isLoading => _viewState == CulturasViewState.loading;
  bool get hasData => _culturas.isNotEmpty;
  bool get hasError => _viewState == CulturasViewState.error;

  // Resumo para UI
  String get searchSummary {
    if (_stats != null) {
      return 'Mostrando ${_culturas.length} de ${_stats!.total} culturas';
    }
    return 'Mostrando ${_culturas.length} culturas';
  }

  /// Inicializa o provider carregando dados básicos
  Future<void> initialize() async {
    await _executeUseCase(() async {
      _setViewState(CulturasViewState.loading);
      
      // Carrega dados em paralelo
      final futures = await Future.wait([
        _loadStats(),
        _loadFiltersData(),
      ]);

      final success = futures.every((result) => result);
      if (!success) {
        throw Exception('Falha ao inicializar dados das culturas');
      }
    });
  }

  /// Carrega culturas ativas
  Future<void> loadActiveCulturas() async {
    await _executeUseCase(() async {
      final result = await _getActiveCulturasUseCase();
      result.fold(
        (failure) => throw Exception(failure.message),
        (culturas) {
          _culturas = culturas;
          _setViewState(culturas.isEmpty 
              ? CulturasViewState.empty 
              : CulturasViewState.loaded);
        },
      );
    });
  }

  /// Carrega todas as culturas com paginação
  Future<void> loadAllCulturas({int? limit, int? offset}) async {
    if (offset == null || offset == 0) {
      _setViewState(CulturasViewState.loading);
    } else {
      _isLoadingMore = true;
      notifyListeners();
    }

    await _executeUseCase(() async {
      final result = await _getCulturasUseCase(limit: limit, offset: offset);
      result.fold(
        (failure) => throw Exception(failure.message),
        (culturas) {
          if (offset == null || offset == 0) {
            _culturas = culturas;
          } else {
            _culturas.addAll(culturas);
          }
          _setViewState(culturas.isEmpty && _culturas.isEmpty
              ? CulturasViewState.empty 
              : CulturasViewState.loaded);
        },
      );
    });

    if (offset != null && offset > 0) {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Busca por nome
  Future<void> searchByNome(String nome) async {
    await _executeUseCase(() async {
      final result = await _searchCulturasByNomeUseCase(nome);
      result.fold(
        (failure) => throw Exception(failure.message),
        (culturas) {
          _culturas = culturas;
          _setViewState(culturas.isEmpty 
              ? CulturasViewState.empty 
              : CulturasViewState.loaded);
        },
      );
    });
  }

  /// Busca por família
  Future<void> searchByFamilia(String familia) async {
    await _executeUseCase(() async {
      final result = await _searchCulturasByFamiliaUseCase(familia);
      result.fold(
        (failure) => throw Exception(failure.message),
        (culturas) {
          _culturas = culturas;
          _setViewState(culturas.isEmpty 
              ? CulturasViewState.empty 
              : CulturasViewState.loaded);
        },
      );
    });
  }

  /// Busca por tipo
  Future<void> searchByTipo(CulturaTipo tipo) async {
    await _executeUseCase(() async {
      final result = await _searchCulturasByTipoUseCase(tipo);
      result.fold(
        (failure) => throw Exception(failure.message),
        (culturas) {
          _culturas = culturas;
          _setViewState(culturas.isEmpty 
              ? CulturasViewState.empty 
              : CulturasViewState.loaded);
        },
      );
    });
  }

  /// Busca com filtros
  Future<void> searchWithFilters(CulturaSearchFilters filters) async {
    _currentFilters = filters;
    
    await _executeUseCase(() async {
      final result = await _searchCulturasWithFiltersUseCase(filters);
      result.fold(
        (failure) => throw Exception(failure.message),
        (culturas) {
          _culturas = culturas;
          _setViewState(culturas.isEmpty 
              ? CulturasViewState.empty 
              : CulturasViewState.loaded);
        },
      );
    });
  }

  /// Busca por padrão geral
  Future<void> searchByPattern(String pattern) async {
    await _executeUseCase(() async {
      final result = await _searchCulturasByPatternUseCase(pattern);
      result.fold(
        (failure) => throw Exception(failure.message),
        (culturas) {
          _culturas = culturas;
          _setViewState(culturas.isEmpty 
              ? CulturasViewState.empty 
              : CulturasViewState.loaded);
        },
      );
    });
  }

  /// Busca cultura por ID
  Future<CulturaEntity?> getCulturaById(String id) async {
    final result = await _getCulturaByIdUseCase(id);
    return result.fold(
      (failure) {
        _setError(failure.message);
        return null;
      },
      (cultura) => cultura,
    );
  }

  /// Busca cultura por nome exato
  Future<CulturaEntity?> getCulturaByNome(String nome) async {
    final result = await _getCulturaByNomeUseCase(nome);
    return result.fold(
      (failure) {
        _setError(failure.message);
        return null;
      },
      (cultura) => cultura,
    );
  }

  /// Carrega culturas relacionadas
  Future<List<CulturaEntity>> getRelatedCulturas(String culturaId) async {
    final result = await _getRelatedCulturasUseCase(culturaId);
    return result.fold(
      (failure) {
        _setError(failure.message);
        return <CulturaEntity>[];
      },
      (culturas) => culturas,
    );
  }

  /// Verifica se cultura existe
  Future<bool> culturaExists(String id) async {
    final result = await _checkCulturaExistsUseCase(id);
    return result.fold(
      (failure) => false,
      (exists) => exists,
    );
  }

  /// Verifica se cultura existe por nome
  Future<bool> culturaExistsByNome(String nome) async {
    final result = await _checkCulturaExistsByNomeUseCase(nome);
    return result.fold(
      (failure) => false,
      (exists) => exists,
    );
  }

  /// Valida dados da cultura
  Future<bool> validateCulturaData(CulturaEntity cultura) async {
    final result = await _validateCulturaDataUseCase(cultura);
    return result.fold(
      (failure) {
        _setError(failure.message);
        return false;
      },
      (isValid) => isValid,
    );
  }

  /// Carrega estatísticas
  Future<bool> _loadStats() async {
    final result = await _getCulturaStatsUseCase();
    return result.fold(
      (failure) {
        _setError(failure.message);
        return false;
      },
      (stats) {
        _stats = stats;
        return true;
      },
    );
  }

  /// Carrega dados para filtros
  Future<bool> _loadFiltersData() async {
    final result = await _getCulturaFiltersDataUseCase();
    return result.fold(
      (failure) {
        _setError(failure.message);
        return false;
      },
      (filtersData) {
        _filtersData = filtersData;
        return true;
      },
    );
  }

  /// Limpa filtros
  void clearFilters() {
    _currentFilters = const CulturaSearchFilters();
    loadActiveCulturas();
  }

  /// Limpa erro
  void clearError() {
    _errorMessage = null;
    if (_viewState == CulturasViewState.error) {
      _setViewState(CulturasViewState.initial);
    }
  }

  /// Helper para execução de use cases com tratamento de erro
  Future<void> _executeUseCase(Future<void> Function() useCase) async {
    try {
      _clearError();
      await useCase();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Define estado da view
  void _setViewState(CulturasViewState state) {
    _viewState = state;
    notifyListeners();
  }

  /// Define erro
  void _setError(String message) {
    _errorMessage = message;
    _setViewState(CulturasViewState.error);
  }

  /// Limpa erro
  void _clearError() {
    _errorMessage = null;
  }

}

/// Estados da view de culturas
enum CulturasViewState {
  initial,
  loading,
  loaded,
  empty,
  error,
}