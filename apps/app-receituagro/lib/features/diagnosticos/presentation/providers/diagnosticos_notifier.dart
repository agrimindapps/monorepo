import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../domain/entities/diagnostico_entity.dart';
import '../../domain/usecases/get_diagnosticos_usecase.dart';

part 'diagnosticos_notifier.g.dart';

/// Diagnosticos state
class DiagnosticosState {
  // CORREÇÃO: Separação de listas para evitar conflito entre dados completos e filtros
  final List<DiagnosticoEntity> allDiagnosticos; // Dados completos sempre em memória
  final List<DiagnosticoEntity> filteredDiagnosticos; // Dados filtrados ou completos
  final List<DiagnosticoEntity> searchResults; // Resultados de busca de texto
  final String searchQuery; // Query de busca atual

  final DiagnosticosStats? stats;
  final DiagnosticoFiltersData? filtersData;
  final DiagnosticoSearchFilters currentFilters;
  final String? contextoCultura;
  final String? contextoPraga;
  final String? contextoDefensivo;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;

  const DiagnosticosState({
    required this.allDiagnosticos,
    required this.filteredDiagnosticos,
    this.searchResults = const [],
    this.searchQuery = '',
    this.stats,
    this.filtersData,
    required this.currentFilters,
    this.contextoCultura,
    this.contextoPraga,
    this.contextoDefensivo,
    required this.isLoading,
    required this.isLoadingMore,
    this.errorMessage,
  });

  factory DiagnosticosState.initial() {
    return const DiagnosticosState(
      allDiagnosticos: [],
      filteredDiagnosticos: [],
      searchResults: [],
      searchQuery: '',
      stats: null,
      filtersData: null,
      currentFilters: DiagnosticoSearchFilters(),
      contextoCultura: null,
      contextoPraga: null,
      contextoDefensivo: null,
      isLoading: false,
      isLoadingMore: false,
      errorMessage: null,
    );
  }

  // BACKWARD COMPATIBILITY: getter para código legado que usa 'diagnosticos'
  List<DiagnosticoEntity> get diagnosticos {
    if (searchQuery.isNotEmpty) return searchResults;
    if (contextoDefensivo != null || contextoCultura != null || contextoPraga != null) {
      return filteredDiagnosticos;
    }
    return allDiagnosticos;
  }

  DiagnosticosState copyWith({
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
    bool clearContext = false,
  }) {
    final newAllDiagnosticos = allDiagnosticos ?? this.allDiagnosticos;
    final newSearchQuery = searchQuery ?? this.searchQuery;
    final newContextoCultura = clearContext ? null : (contextoCultura ?? this.contextoCultura);
    final newContextoPraga = clearContext ? null : (contextoPraga ?? this.contextoPraga);
    final newContextoDefensivo = clearContext ? null : (contextoDefensivo ?? this.contextoDefensivo);

    // LÓGICA INTELIGENTE: Se filteredDiagnosticos não foi fornecido e não há filtros/contextos ativos,
    // então filteredDiagnosticos deve ser igual a allDiagnosticos
    final hasActiveFilters = newSearchQuery.isNotEmpty ||
                            newContextoCultura != null ||
                            newContextoPraga != null ||
                            newContextoDefensivo != null;

    final newFilteredDiagnosticos = filteredDiagnosticos ??
        (allDiagnosticos != null && !hasActiveFilters
            ? newAllDiagnosticos
            : this.filteredDiagnosticos);

    return DiagnosticosState(
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

  DiagnosticosState clearError() {
    return copyWith(errorMessage: null);
  }

  DiagnosticosState clearContext() {
    return copyWith(
      clearContext: true,
      searchQuery: '',
      searchResults: [],
    );
  }
  bool get hasData => diagnosticos.isNotEmpty;
  bool get hasError => errorMessage != null;
  bool get hasContext => contextoCultura != null || contextoPraga != null || contextoDefensivo != null;

  DiagnosticosViewState get viewState {
    if (isLoading) return DiagnosticosViewState.loading;
    if (hasError) return DiagnosticosViewState.error;
    if (diagnosticos.isEmpty) return DiagnosticosViewState.empty;
    return DiagnosticosViewState.loaded;
  }
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

/// Estados da view de diagnósticos
enum DiagnosticosViewState {
  initial,
  loading,
  loaded,
  empty,
  error,
}

/// Notifier para gerenciar estado dos diagnósticos (Presentation Layer)
/// Especializado em recomendações defensivo-cultura-praga
@riverpod
class DiagnosticosNotifier extends _$DiagnosticosNotifier {
  late final GetDiagnosticosUseCase _getDiagnosticosUseCase;
  late final GetDiagnosticoByIdUseCase _getDiagnosticoByIdUseCase;
  late final GetRecomendacoesUseCase _getRecomendacoesUseCase;
  late final GetDiagnosticosByDefensivoUseCase _getDiagnosticosByDefensivoUseCase;
  late final GetDiagnosticosByCulturaUseCase _getDiagnosticosByCulturaUseCase;
  late final GetDiagnosticosByPragaUseCase _getDiagnosticosByPragaUseCase;
  late final SearchDiagnosticosWithFiltersUseCase _searchDiagnosticosWithFiltersUseCase;
  late final GetDiagnosticoStatsUseCase _getDiagnosticoStatsUseCase;
  late final ValidateCompatibilidadeUseCase _validateCompatibilidadeUseCase;
  late final SearchDiagnosticosByPatternUseCase _searchDiagnosticosByPatternUseCase;
  late final GetDiagnosticoFiltersDataUseCase _getDiagnosticoFiltersDataUseCase;

  @override
  Future<DiagnosticosState> build() async {
    _getDiagnosticosUseCase = di.sl<GetDiagnosticosUseCase>();
    _getDiagnosticoByIdUseCase = di.sl<GetDiagnosticoByIdUseCase>();
    _getRecomendacoesUseCase = di.sl<GetRecomendacoesUseCase>();
    _getDiagnosticosByDefensivoUseCase = di.sl<GetDiagnosticosByDefensivoUseCase>();
    _getDiagnosticosByCulturaUseCase = di.sl<GetDiagnosticosByCulturaUseCase>();
    _getDiagnosticosByPragaUseCase = di.sl<GetDiagnosticosByPragaUseCase>();
    _searchDiagnosticosWithFiltersUseCase = di.sl<SearchDiagnosticosWithFiltersUseCase>();
    _getDiagnosticoStatsUseCase = di.sl<GetDiagnosticoStatsUseCase>();
    _validateCompatibilidadeUseCase = di.sl<ValidateCompatibilidadeUseCase>();
    _searchDiagnosticosByPatternUseCase = di.sl<SearchDiagnosticosByPatternUseCase>();
    _getDiagnosticoFiltersDataUseCase = di.sl<GetDiagnosticoFiltersDataUseCase>();

    return DiagnosticosState.initial();
  }

  /// Inicializa o provider
  Future<void> initialize() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isLoading: true).clearError());

    try {
      await Future.wait([
        _loadStats(),
        _loadFiltersData(),
      ]);
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          errorMessage: 'Falha ao inicializar dados dos diagnósticos: $e',
        ),
      );
    }
  }

  /// Carrega todos os diagnósticos
  Future<void> loadAllDiagnosticos({int? limit, int? offset}) async {
    final currentState = state.value;
    if (currentState == null) return;

    if (offset == null || offset == 0) {
      state = AsyncValue.data(currentState.clearContext().copyWith(isLoading: true).clearError());
    } else {
      state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));
    }

    try {
      final result = await _getDiagnosticosUseCase(limit: limit, offset: offset);
      result.fold(
        (failure) {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              isLoadingMore: false,
              errorMessage: failure.message,
            ),
          );
        },
        (diagnosticos) {
          final List<DiagnosticoEntity> updatedList;
          if (offset == null || offset == 0) {
            updatedList = diagnosticos;
          } else {
            updatedList = [...currentState.allDiagnosticos, ...diagnosticos];
          }

          // CORREÇÃO: loadAllDiagnosticos atualiza tanto allDiagnosticos quanto filteredDiagnosticos
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              isLoadingMore: false,
              allDiagnosticos: updatedList,
              filteredDiagnosticos: updatedList,
            ).clearError(),
          );
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          isLoadingMore: false,
          errorMessage: e.toString(),
        ),
      );
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
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState
          .copyWith(
            contextoCultura: nomeCultura ?? idCultura,
            contextoPraga: nomePraga ?? idPraga,
            isLoading: true,
          )
          .clearError(),
    );

    try {
      final result = await _getRecomendacoesUseCase(
        idCultura: idCultura,
        idPraga: idPraga,
        limit: limit,
      );
      result.fold(
        (failure) {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              errorMessage: failure.message,
            ),
          );
        },
        (diagnosticos) {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              filteredDiagnosticos: diagnosticos,
              // CORREÇÃO: Sempre atualiza allDiagnosticos quando há contexto
              allDiagnosticos: diagnosticos,
            ).clearError(),
          );
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Busca diagnósticos por defensivo
  Future<void> getDiagnosticosByDefensivo(String idDefensivo, {String? nomeDefensivo}) async {
    // CORREÇÃO: Aguarda a inicialização do provider
    await future;

    final currentState = state.requireValue;

    state = AsyncValue.data(
      currentState
          .copyWith(
            contextoDefensivo: nomeDefensivo ?? idDefensivo,
            isLoading: true,
          )
          .clearError(),
    );

    try {
      final result = await _getDiagnosticosByDefensivoUseCase(idDefensivo);

      result.fold(
        (failure) {
          final updatedState = state.requireValue;
          state = AsyncValue.data(
            updatedState.copyWith(
              isLoading: false,
              errorMessage: failure.message,
            ),
          );
        },
        (diagnosticos) {
          final updatedState = state.requireValue;

          // CORREÇÃO: Atualiza filteredDiagnosticos com os resultados filtrados por defensivo
          // IMPORTANTE: SEMPRE atualiza allDiagnosticos para garantir que o getter funcione
          state = AsyncValue.data(
            updatedState.copyWith(
              isLoading: false,
              filteredDiagnosticos: diagnosticos,
              // CORREÇÃO: Sempre atualiza allDiagnosticos (não passa null)
              allDiagnosticos: diagnosticos,
            ).clearError(),
          );
        },
      );
    } catch (e) {
      final updatedState = state.requireValue;
      state = AsyncValue.data(
        updatedState.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Busca diagnósticos por cultura
  Future<void> getDiagnosticosByCultura(String idCultura, {String? nomeCultura}) async {
    // CORREÇÃO: Aguarda a inicialização do provider
    await future;

    final currentState = state.requireValue;

    state = AsyncValue.data(
      currentState
          .copyWith(
            contextoCultura: nomeCultura ?? idCultura,
            isLoading: true,
          )
          .clearError(),
    );

    try {
      final result = await _getDiagnosticosByCulturaUseCase(idCultura);
      result.fold(
        (failure) {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              errorMessage: failure.message,
            ),
          );
        },
        (diagnosticos) {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              filteredDiagnosticos: diagnosticos,
              // CORREÇÃO: Sempre atualiza allDiagnosticos quando há contexto
              allDiagnosticos: diagnosticos,
            ).clearError(),
          );
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Busca diagnósticos por praga
  Future<void> getDiagnosticosByPraga(String idPraga, {String? nomePraga}) async {
    // CORREÇÃO: Aguarda a inicialização do provider
    await future;

    final currentState = state.requireValue;

    state = AsyncValue.data(
      currentState
          .copyWith(
            contextoPraga: nomePraga ?? idPraga,
            isLoading: true,
          )
          .clearError(),
    );

    try {
      final result = await _getDiagnosticosByPragaUseCase(idPraga);
      result.fold(
        (failure) {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              errorMessage: failure.message,
            ),
          );
        },
        (diagnosticos) {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              filteredDiagnosticos: diagnosticos,
              // CORREÇÃO: Sempre atualiza allDiagnosticos quando há contexto
              allDiagnosticos: diagnosticos,
            ).clearError(),
          );
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Busca com filtros
  Future<void> searchWithFilters(DiagnosticoSearchFilters filters) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.clearContext().copyWith(
            currentFilters: filters,
            isLoading: true,
          ).clearError(),
    );

    try {
      final result = await _searchDiagnosticosWithFiltersUseCase(filters);
      result.fold(
        (failure) {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              errorMessage: failure.message,
            ),
          );
        },
        (diagnosticos) {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              filteredDiagnosticos: diagnosticos,
              // CORREÇÃO: Sempre atualiza allDiagnosticos quando há contexto
              allDiagnosticos: diagnosticos,
            ).clearError(),
          );
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Busca por padrão geral
  Future<void> searchByPattern(String pattern) async {
    final currentState = state.value;
    if (currentState == null) return;

    // Se a busca está vazia, limpa os resultados e volta para allDiagnosticos
    if (pattern.trim().isEmpty) {
      state = AsyncValue.data(
        currentState.copyWith(
          searchQuery: '',
          searchResults: [],
          clearContext: true,
        ),
      );
      return;
    }

    state = AsyncValue.data(
      currentState.clearContext().copyWith(
        searchQuery: pattern,
        isLoading: true,
      ).clearError(),
    );

    try {
      // CORREÇÃO: Busca primeiro localmente em allDiagnosticos se disponível
      if (currentState.allDiagnosticos.isNotEmpty) {
        final lowerPattern = pattern.toLowerCase();
        final localResults = currentState.allDiagnosticos.where((diag) {
          final nomeDefensivo = diag.nomeDefensivo?.toLowerCase() ?? '';
          final nomeCultura = diag.nomeCultura?.toLowerCase() ?? '';
          final nomePraga = diag.nomePraga?.toLowerCase() ?? '';
          return nomeDefensivo.contains(lowerPattern) ||
                 nomeCultura.contains(lowerPattern) ||
                 nomePraga.contains(lowerPattern);
        }).toList();

        state = AsyncValue.data(
          currentState.copyWith(
            searchQuery: pattern,
            searchResults: localResults,
            isLoading: false,
          ).clearError(),
        );
        return;
      }

      // Fallback: busca remota se não há dados locais
      final result = await _searchDiagnosticosByPatternUseCase(pattern);
      result.fold(
        (failure) {
          state = AsyncValue.data(
            currentState.copyWith(
              searchQuery: pattern,
              isLoading: false,
              errorMessage: failure.message,
            ),
          );
        },
        (diagnosticos) {
          state = AsyncValue.data(
            currentState.copyWith(
              searchQuery: pattern,
              searchResults: diagnosticos,
              isLoading: false,
            ).clearError(),
          );
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          searchQuery: pattern,
          isLoading: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Busca diagnóstico por ID
  Future<DiagnosticoEntity?> getDiagnosticoById(String id) async {
    try {
      final result = await _getDiagnosticoByIdUseCase(id);
      return result.fold(
        (failure) {
          final currentState = state.value;
          if (currentState != null) {
            state = AsyncValue.data(
              currentState.copyWith(errorMessage: failure.message),
            );
          }
          return null;
        },
        (diagnostico) => diagnostico,
      );
    } catch (e) {
      final currentState = state.value;
      if (currentState != null) {
        state = AsyncValue.data(
          currentState.copyWith(errorMessage: e.toString()),
        );
      }
      return null;
    }
  }

  /// Valida compatibilidade entre defensivo, cultura e praga
  Future<bool> validateCompatibilidade({
    required String idDefensivo,
    required String idCultura,
    required String idPraga,
  }) async {
    try {
      final result = await _validateCompatibilidadeUseCase(
        idDefensivo: idDefensivo,
        idCultura: idCultura,
        idPraga: idPraga,
      );
      return result.fold(
        (failure) {
          final currentState = state.value;
          if (currentState != null) {
            state = AsyncValue.data(
              currentState.copyWith(errorMessage: failure.message),
            );
          }
          return false;
        },
        (isCompatible) => isCompatible,
      );
    } catch (e) {
      final currentState = state.value;
      if (currentState != null) {
        state = AsyncValue.data(
          currentState.copyWith(errorMessage: e.toString()),
        );
      }
      return false;
    }
  }

  /// Filtra diagnósticos carregados por tipo de aplicação
  void filterByTipoAplicacao(TipoAplicacao tipo) {
    final currentState = state.value;
    if (currentState == null) return;

    final filtered = currentState.filteredDiagnosticos
        .where((DiagnosticoEntity d) => d.aplicacao.tiposDisponiveis.contains(tipo))
        .toList();

    state = AsyncValue.data(
      currentState.copyWith(filteredDiagnosticos: filtered),
    );
  }

  /// Filtra diagnósticos carregados por completude
  void filterByCompletude(DiagnosticoCompletude completude) {
    final currentState = state.value;
    if (currentState == null) return;

    final filtered = currentState.filteredDiagnosticos
        .where((DiagnosticoEntity d) => d.completude == completude)
        .toList();

    state = AsyncValue.data(
      currentState.copyWith(filteredDiagnosticos: filtered),
    );
  }

  /// Ordena diagnósticos por dosagem
  void sortByDosagem({bool ascending = true}) {
    final currentState = state.value;
    if (currentState == null || currentState.filteredDiagnosticos.isEmpty) return;

    final sortedDiagnosticos = List<DiagnosticoEntity>.from(currentState.filteredDiagnosticos);
    sortedDiagnosticos.sort((a, b) {
      final dosageA = a.dosagem.dosageAverage;
      final dosageB = b.dosagem.dosageAverage;

      return ascending ? dosageA.compareTo(dosageB) : dosageB.compareTo(dosageA);
    });

    state = AsyncValue.data(
      currentState.copyWith(filteredDiagnosticos: sortedDiagnosticos),
    );
  }

  /// Ordena diagnósticos por completude
  void sortByCompletude() {
    final currentState = state.value;
    if (currentState == null || currentState.filteredDiagnosticos.isEmpty) return;

    final sortedDiagnosticos = List<DiagnosticoEntity>.from(currentState.filteredDiagnosticos);
    sortedDiagnosticos.sort((a, b) {
      final scoreA = a.completude.index;
      final scoreB = b.completude.index;
      return scoreA.compareTo(scoreB);
    });

    state = AsyncValue.data(
      currentState.copyWith(filteredDiagnosticos: sortedDiagnosticos),
    );
  }

  /// Carrega estatísticas
  Future<void> _loadStats() async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      final result = await _getDiagnosticoStatsUseCase();
      result.fold(
        (failure) {
          state = AsyncValue.data(
            currentState.copyWith(errorMessage: failure.message),
          );
        },
        (stats) {
          state = AsyncValue.data(
            currentState.copyWith(stats: stats),
          );
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(errorMessage: e.toString()),
      );
    }
  }

  /// Carrega dados para filtros
  Future<void> _loadFiltersData() async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      final result = await _getDiagnosticoFiltersDataUseCase();
      result.fold(
        (failure) {
          state = AsyncValue.data(
            currentState.copyWith(errorMessage: failure.message),
          );
        },
        (filtersData) {
          state = AsyncValue.data(
            currentState.copyWith(filtersData: filtersData),
          );
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(errorMessage: e.toString()),
      );
    }
  }

  /// Limpa filtros
  void clearFilters() {
    final currentState = state.value;
    if (currentState == null) return;

    // CORREÇÃO: Não recarrega do banco, apenas reseta para allDiagnosticos
    state = AsyncValue.data(
      currentState.clearContext().copyWith(
        currentFilters: const DiagnosticoSearchFilters(),
        searchQuery: '',
        searchResults: [],
        // filteredDiagnosticos será auto-sincronizado com allDiagnosticos via copyWith()
      ),
    );
  }

  /// Limpa erro
  void clearError() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.clearError());
  }
}
