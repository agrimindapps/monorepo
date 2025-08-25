import 'package:flutter/foundation.dart';

import '../../domain/entities/diagnostico_entity.dart';
import '../../domain/usecases/get_diagnosticos_usecase.dart';

/// Provider para gerenciar estado dos diagnósticos usando Clean Architecture
/// Especializado em recomendações defensivo-cultura-praga
class DiagnosticosProvider extends ChangeNotifier {
  // Use Cases injetados
  final GetDiagnosticosUseCase _getDiagnosticosUseCase;
  final GetDiagnosticoByIdUseCase _getDiagnosticoByIdUseCase;
  final GetRecomendacoesUseCase _getRecomendacoesUseCase;
  final GetDiagnosticosByDefensivoUseCase _getDiagnosticosByDefensivoUseCase;
  final GetDiagnosticosByCulturaUseCase _getDiagnosticosByCulturaUseCase;
  final GetDiagnosticosByPragaUseCase _getDiagnosticosByPragaUseCase;
  final SearchDiagnosticosWithFiltersUseCase _searchDiagnosticosWithFiltersUseCase;
  final GetDiagnosticoStatsUseCase _getDiagnosticoStatsUseCase;
  final ValidateCompatibilidadeUseCase _validateCompatibilidadeUseCase;
  final SearchDiagnosticosByPatternUseCase _searchDiagnosticosByPatternUseCase;
  final GetDiagnosticoFiltersDataUseCase _getDiagnosticoFiltersDataUseCase;

  DiagnosticosProvider({
    required GetDiagnosticosUseCase getDiagnosticosUseCase,
    required GetDiagnosticoByIdUseCase getDiagnosticoByIdUseCase,
    required GetRecomendacoesUseCase getRecomendacoesUseCase,
    required GetDiagnosticosByDefensivoUseCase getDiagnosticosByDefensivoUseCase,
    required GetDiagnosticosByCulturaUseCase getDiagnosticosByCulturaUseCase,
    required GetDiagnosticosByPragaUseCase getDiagnosticosByPragaUseCase,
    required SearchDiagnosticosWithFiltersUseCase searchDiagnosticosWithFiltersUseCase,
    required GetDiagnosticoStatsUseCase getDiagnosticoStatsUseCase,
    required ValidateCompatibilidadeUseCase validateCompatibilidadeUseCase,
    required SearchDiagnosticosByPatternUseCase searchDiagnosticosByPatternUseCase,
    required GetDiagnosticoFiltersDataUseCase getDiagnosticoFiltersDataUseCase,
  }) : _getDiagnosticosUseCase = getDiagnosticosUseCase,
       _getDiagnosticoByIdUseCase = getDiagnosticoByIdUseCase,
       _getRecomendacoesUseCase = getRecomendacoesUseCase,
       _getDiagnosticosByDefensivoUseCase = getDiagnosticosByDefensivoUseCase,
       _getDiagnosticosByCulturaUseCase = getDiagnosticosByCulturaUseCase,
       _getDiagnosticosByPragaUseCase = getDiagnosticosByPragaUseCase,
       _searchDiagnosticosWithFiltersUseCase = searchDiagnosticosWithFiltersUseCase,
       _getDiagnosticoStatsUseCase = getDiagnosticoStatsUseCase,
       _validateCompatibilidadeUseCase = validateCompatibilidadeUseCase,
       _searchDiagnosticosByPatternUseCase = searchDiagnosticosByPatternUseCase,
       _getDiagnosticoFiltersDataUseCase = getDiagnosticoFiltersDataUseCase;

  // Estado
  List<DiagnosticoEntity> _diagnosticos = [];
  DiagnosticosViewState _viewState = DiagnosticosViewState.initial;
  String? _errorMessage;
  DiagnosticosStats? _stats;
  DiagnosticoFiltersData? _filtersData;
  DiagnosticoSearchFilters _currentFilters = const DiagnosticoSearchFilters();
  bool _isLoadingMore = false;

  // Contexto da consulta atual (para UI especializada)
  String? _contextoCultura;
  String? _contextoPraga;
  String? _contextoDefensivo;

  // Getters
  List<DiagnosticoEntity> get diagnosticos => _diagnosticos;
  DiagnosticosViewState get viewState => _viewState;
  String? get errorMessage => _errorMessage;
  DiagnosticosStats? get stats => _stats;
  DiagnosticoFiltersData? get filtersData => _filtersData;
  DiagnosticoSearchFilters get currentFilters => _currentFilters;
  bool get isLoadingMore => _isLoadingMore;
  bool get isLoading => _viewState == DiagnosticosViewState.loading;
  bool get hasData => _diagnosticos.isNotEmpty;
  bool get hasError => _viewState == DiagnosticosViewState.error;

  // Contexto da consulta
  String? get contextoCultura => _contextoCultura;
  String? get contextoPraga => _contextoPraga;
  String? get contextoDefensivo => _contextoDefensivo;
  
  bool get hasContext => _contextoCultura != null || _contextoPraga != null || _contextoDefensivo != null;

  // Resumo para UI
  String get searchSummary {
    if (hasContext) {
      final parts = <String>[];
      if (_contextoDefensivo != null) parts.add('Defensivo: $_contextoDefensivo');
      if (_contextoCultura != null) parts.add('Cultura: $_contextoCultura');
      if (_contextoPraga != null) parts.add('Praga: $_contextoPraga');
      
      return '${_diagnosticos.length} recomendações para ${parts.join(' + ')}';
    }
    
    if (_stats != null) {
      return 'Mostrando ${_diagnosticos.length} de ${_stats!.total} diagnósticos';
    }
    return 'Mostrando ${_diagnosticos.length} diagnósticos';
  }

  /// Inicializa o provider
  Future<void> initialize() async {
    await _executeUseCase(() async {
      _setViewState(DiagnosticosViewState.loading);
      
      final futures = await Future.wait([
        _loadStats(),
        _loadFiltersData(),
      ]);

      final success = futures.every((result) => result);
      if (!success) {
        throw Exception('Falha ao inicializar dados dos diagnósticos');
      }
    });
  }

  /// Carrega todos os diagnósticos
  Future<void> loadAllDiagnosticos({int? limit, int? offset}) async {
    _clearContext();
    
    if (offset == null || offset == 0) {
      _setViewState(DiagnosticosViewState.loading);
    } else {
      _isLoadingMore = true;
      notifyListeners();
    }

    await _executeUseCase(() async {
      final result = await _getDiagnosticosUseCase(limit: limit, offset: offset);
      result.fold(
        (failure) => throw Exception(failure.message),
        (diagnosticos) {
          if (offset == null || offset == 0) {
            _diagnosticos = diagnosticos;
          } else {
            _diagnosticos.addAll(diagnosticos);
          }
          _setViewState(diagnosticos.isEmpty && _diagnosticos.isEmpty
              ? DiagnosticosViewState.empty 
              : DiagnosticosViewState.loaded);
        },
      );
    });

    if (offset != null && offset > 0) {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Busca recomendações por cultura e praga
  Future<void> getRecomendacoesPara({
    required String idCultura,
    required String idPraga,
    String? nomeCultura,
    String? nomePraga,
    int limit = 10,
  }) async {
    _setContext(cultura: nomeCultura ?? idCultura, praga: nomePraga ?? idPraga);
    
    await _executeUseCase(() async {
      final result = await _getRecomendacoesUseCase(
        idCultura: idCultura,
        idPraga: idPraga,
        limit: limit,
      );
      result.fold(
        (failure) => throw Exception(failure.message),
        (diagnosticos) {
          _diagnosticos = diagnosticos;
          _setViewState(diagnosticos.isEmpty 
              ? DiagnosticosViewState.empty 
              : DiagnosticosViewState.loaded);
        },
      );
    });
  }

  /// Busca diagnósticos por defensivo
  Future<void> getDiagnosticosByDefensivo(String idDefensivo, {String? nomeDefensivo}) async {
    _setContext(defensivo: nomeDefensivo ?? idDefensivo);
    
    await _executeUseCase(() async {
      final result = await _getDiagnosticosByDefensivoUseCase(idDefensivo);
      result.fold(
        (failure) => throw Exception(failure.message),
        (diagnosticos) {
          _diagnosticos = diagnosticos;
          _setViewState(diagnosticos.isEmpty 
              ? DiagnosticosViewState.empty 
              : DiagnosticosViewState.loaded);
        },
      );
    });
  }

  /// Busca diagnósticos por cultura
  Future<void> getDiagnosticosByCultura(String idCultura, {String? nomeCultura}) async {
    _setContext(cultura: nomeCultura ?? idCultura);
    
    await _executeUseCase(() async {
      final result = await _getDiagnosticosByCulturaUseCase(idCultura);
      result.fold(
        (failure) => throw Exception(failure.message),
        (diagnosticos) {
          _diagnosticos = diagnosticos;
          _setViewState(diagnosticos.isEmpty 
              ? DiagnosticosViewState.empty 
              : DiagnosticosViewState.loaded);
        },
      );
    });
  }

  /// Busca diagnósticos por praga
  Future<void> getDiagnosticosByPraga(String idPraga, {String? nomePraga}) async {
    _setContext(praga: nomePraga ?? idPraga);
    
    await _executeUseCase(() async {
      final result = await _getDiagnosticosByPragaUseCase(idPraga);
      result.fold(
        (failure) => throw Exception(failure.message),
        (diagnosticos) {
          _diagnosticos = diagnosticos;
          _setViewState(diagnosticos.isEmpty 
              ? DiagnosticosViewState.empty 
              : DiagnosticosViewState.loaded);
        },
      );
    });
  }

  /// Busca com filtros
  Future<void> searchWithFilters(DiagnosticoSearchFilters filters) async {
    _currentFilters = filters;
    _clearContext();
    
    await _executeUseCase(() async {
      final result = await _searchDiagnosticosWithFiltersUseCase(filters);
      result.fold(
        (failure) => throw Exception(failure.message),
        (diagnosticos) {
          _diagnosticos = diagnosticos;
          _setViewState(diagnosticos.isEmpty 
              ? DiagnosticosViewState.empty 
              : DiagnosticosViewState.loaded);
        },
      );
    });
  }

  /// Busca por padrão geral
  Future<void> searchByPattern(String pattern) async {
    _clearContext();
    
    await _executeUseCase(() async {
      final result = await _searchDiagnosticosByPatternUseCase(pattern);
      result.fold(
        (failure) => throw Exception(failure.message),
        (diagnosticos) {
          _diagnosticos = diagnosticos;
          _setViewState(diagnosticos.isEmpty 
              ? DiagnosticosViewState.empty 
              : DiagnosticosViewState.loaded);
        },
      );
    });
  }

  /// Busca diagnóstico por ID
  Future<DiagnosticoEntity?> getDiagnosticoById(String id) async {
    final result = await _getDiagnosticoByIdUseCase(id);
    return result.fold(
      (failure) {
        _setError(failure.message);
        return null;
      },
      (diagnostico) => diagnostico,
    );
  }

  /// Valida compatibilidade entre defensivo, cultura e praga
  Future<bool> validateCompatibilidade({
    required String idDefensivo,
    required String idCultura,
    required String idPraga,
  }) async {
    final result = await _validateCompatibilidadeUseCase(
      idDefensivo: idDefensivo,
      idCultura: idCultura,
      idPraga: idPraga,
    );
    return result.fold(
      (failure) {
        _setError(failure.message);
        return false;
      },
      (isCompatible) => isCompatible,
    );
  }

  /// Filtra diagnósticos carregados por tipo de aplicação
  void filterByTipoAplicacao(TipoAplicacao tipo) {
    final filtered = _diagnosticos.where((d) => 
        d.aplicacao.tiposDisponiveis.contains(tipo)).toList();
    
    _diagnosticos = filtered;
    _setViewState(filtered.isEmpty 
        ? DiagnosticosViewState.empty 
        : DiagnosticosViewState.loaded);
  }

  /// Filtra diagnósticos carregados por completude
  void filterByCompletude(DiagnosticoCompletude completude) {
    final filtered = _diagnosticos.where((d) => d.completude == completude).toList();
    
    _diagnosticos = filtered;
    _setViewState(filtered.isEmpty 
        ? DiagnosticosViewState.empty 
        : DiagnosticosViewState.loaded);
  }

  /// Ordena diagnósticos por dosagem
  void sortByDosagem({bool ascending = true}) {
    _diagnosticos.sort((a, b) {
      final dosageA = a.dosagem.dosageAverage;
      final dosageB = b.dosagem.dosageAverage;
      
      return ascending 
          ? dosageA.compareTo(dosageB)
          : dosageB.compareTo(dosageA);
    });
    
    notifyListeners();
  }

  /// Ordena diagnósticos por completude
  void sortByCompletude() {
    _diagnosticos.sort((a, b) {
      // Completos primeiro, depois parciais, depois incompletos
      final scoreA = a.completude.index;
      final scoreB = b.completude.index;
      return scoreA.compareTo(scoreB);
    });
    
    notifyListeners();
  }

  /// Define contexto da consulta para UI especializada
  void _setContext({String? defensivo, String? cultura, String? praga}) {
    _contextoDefensivo = defensivo;
    _contextoCultura = cultura;
    _contextoPraga = praga;
  }

  /// Limpa contexto da consulta
  void _clearContext() {
    _contextoDefensivo = null;
    _contextoCultura = null;
    _contextoPraga = null;
  }

  /// Carrega estatísticas
  Future<bool> _loadStats() async {
    final result = await _getDiagnosticoStatsUseCase();
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
    final result = await _getDiagnosticoFiltersDataUseCase();
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
    _currentFilters = const DiagnosticoSearchFilters();
    _clearContext();
    loadAllDiagnosticos();
  }

  /// Limpa erro
  void clearError() {
    _errorMessage = null;
    if (_viewState == DiagnosticosViewState.error) {
      _setViewState(DiagnosticosViewState.initial);
    }
  }

  /// Helper para execução de use cases
  Future<void> _executeUseCase(Future<void> Function() useCase) async {
    try {
      _clearError();
      await useCase();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Define estado da view
  void _setViewState(DiagnosticosViewState state) {
    _viewState = state;
    notifyListeners();
  }

  /// Define erro
  void _setError(String message) {
    _errorMessage = message;
    _setViewState(DiagnosticosViewState.error);
  }

  /// Limpa erro
  void _clearError() {
    _errorMessage = null;
  }

}

/// Estados da view de diagnósticos
enum DiagnosticosViewState {
  initial,
  loading,
  loaded,
  empty,
  error,
}