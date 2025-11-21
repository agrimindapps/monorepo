import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/diagnostico_entity.dart';

part 'diagnosticos_state.freezed.dart';

/// Estados da view de diagnósticos
enum DiagnosticosViewState { initial, loading, loaded, empty, error }

/// State imutável para gerenciamento de diagnósticos
///
/// Migrado para @freezed para type-safety, imutabilidade e código gerado
@freezed
class DiagnosticosState with _$DiagnosticosState {
  const DiagnosticosState._();

  const factory DiagnosticosState({
    /// Dados completos sempre em memória
    @Default([]) List<DiagnosticoEntity> allDiagnosticos,

    /// Dados filtrados ou completos
    @Default([]) List<DiagnosticoEntity> filteredDiagnosticos,

    /// Resultados de busca de texto
    @Default([]) List<DiagnosticoEntity> searchResults,

    /// Query de busca atual
    @Default('') String searchQuery,

    /// Estatísticas dos diagnósticos
    DiagnosticosStats? stats,

    /// Dados para filtros
    DiagnosticoFiltersData? filtersData,

    /// Filtros atualmente aplicados
    @Default(DiagnosticoSearchFilters()) DiagnosticoSearchFilters currentFilters,

    /// Contexto de cultura (navegação)
    String? contextoCultura,

    /// Contexto de praga (navegação)
    String? contextoPraga,

    /// Contexto de defensivo (navegação)
    String? contextoDefensivo,

    /// Loading state
    @Default(false) bool isLoading,

    /// Loading more (pagination)
    @Default(false) bool isLoadingMore,

    /// Mensagem de erro
    String? errorMessage,
  }) = _DiagnosticosState;

  /// Factory para estado inicial
  factory DiagnosticosState.initial() => const DiagnosticosState();

  // ========== Computed Properties ==========

  /// BACKWARD COMPATIBILITY: getter para código legado que usa 'diagnosticos'
  ///
  /// Prioridade de retorno:
  /// 1. searchResults (se há busca ativa)
  /// 2. filteredDiagnosticos (se há contexto/filtros)
  /// 3. allDiagnosticos (padrão)
  List<DiagnosticoEntity> get diagnosticos {
    if (searchQuery.isNotEmpty) return searchResults;
    if (hasContext) return filteredDiagnosticos;
    return filteredDiagnosticos.isNotEmpty ? filteredDiagnosticos : allDiagnosticos;
  }

  /// Verifica se há dados
  bool get hasData => diagnosticos.isNotEmpty;

  /// Verifica se há erro
  bool get hasError => errorMessage != null;

  /// Verifica se há contexto de navegação ativo
  bool get hasContext =>
      contextoCultura != null ||
      contextoPraga != null ||
      contextoDefensivo != null;

  /// Estado da view baseado nos dados
  DiagnosticosViewState get viewState {
    if (isLoading) return DiagnosticosViewState.loading;
    if (hasError) return DiagnosticosViewState.error;
    if (diagnosticos.isEmpty) return DiagnosticosViewState.empty;
    return DiagnosticosViewState.loaded;
  }

  /// Resumo da busca/filtro atual
  String get searchSummary {
    if (hasContext) {
      final parts = <String>[];
      if (contextoDefensivo != null) parts.add('Defensivo: $contextoDefensivo');
      if (contextoCultura != null) parts.add('Cultura: $contextoCultura');
      if (contextoPraga != null) parts.add('Praga: $contextoPraga');

      return '${diagnosticos.length} recomendações para ${parts.join(' + ')}';
    }

    if (stats != null) {
      return 'Mostrando ${diagnosticos.length} de ${stats!.total} diagnósticos';
    }
    return 'Mostrando ${diagnosticos.length} diagnósticos';
  }
}

/// Extension para métodos de transformação do state
extension DiagnosticosStateX on DiagnosticosState {
  /// Limpa mensagem de erro
  DiagnosticosState clearError() => copyWith(errorMessage: null);

  /// Limpa contexto de navegação e busca
  DiagnosticosState clearContext() {
    return copyWith(
      contextoCultura: null,
      contextoPraga: null,
      contextoDefensivo: null,
      searchQuery: '',
      searchResults: [],
    );
  }

  /// Atualiza com lógica inteligente de filteredDiagnosticos
  ///
  /// Se não há filtros/contextos ativos e allDiagnosticos foi fornecido,
  /// então filteredDiagnosticos = allDiagnosticos automaticamente
  DiagnosticosState smartCopyWith({
    List<DiagnosticoEntity>? allDiagnosticos,
    List<DiagnosticoEntity>? filteredDiagnosticos,
    List<DiagnosticoEntity>? searchResults,
    String? searchQuery,
    DiagnosticosStats? stats,
    DiagnosticoFiltersData? filtersData,
    DiagnosticoSearchFilters? currentFilters,
    String? contextoCultura,
    String? contextoPraga,
    String? contextoDefensivo,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearContextFlag = false,
  }) {
    final newAllDiagnosticos = allDiagnosticos ?? this.allDiagnosticos;
    final newSearchQuery = searchQuery ?? this.searchQuery;
    final newContextoCultura =
        clearContextFlag ? null : (contextoCultura ?? this.contextoCultura);
    final newContextoPraga =
        clearContextFlag ? null : (contextoPraga ?? this.contextoPraga);
    final newContextoDefensivo =
        clearContextFlag ? null : (contextoDefensivo ?? this.contextoDefensivo);

    // LÓGICA INTELIGENTE: Se filteredDiagnosticos não foi fornecido e não há filtros/contextos ativos,
    // então filteredDiagnosticos deve ser igual a allDiagnosticos
    final hasActiveFilters =
        newSearchQuery.isNotEmpty ||
        newContextoCultura != null ||
        newContextoPraga != null ||
        newContextoDefensivo != null;

    final newFilteredDiagnosticos =
        filteredDiagnosticos ??
        (allDiagnosticos != null && !hasActiveFilters
            ? newAllDiagnosticos
            : this.filteredDiagnosticos);

    return copyWith(
      allDiagnosticos: newAllDiagnosticos,
      filteredDiagnosticos: newFilteredDiagnosticos,
      searchResults: searchResults ?? this.searchResults,
      searchQuery: newSearchQuery,
      stats: stats ?? this.stats,
      filtersData: filtersData ?? this.filtersData,
      currentFilters: currentFilters ?? this.currentFilters,
      contextoCultura: newContextoCultura,
      contextoPraga: newContextoPraga,
      contextoDefensivo: newContextoDefensivo,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
