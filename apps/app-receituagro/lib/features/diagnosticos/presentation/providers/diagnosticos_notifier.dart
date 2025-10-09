import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../domain/entities/diagnostico_entity.dart';
import '../../domain/usecases/get_diagnosticos_usecase.dart';

part 'diagnosticos_notifier.g.dart';

/// Diagnosticos state
class DiagnosticosState {
  final List<DiagnosticoEntity> diagnosticos;
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
    required this.diagnosticos,
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
      diagnosticos: [],
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

  DiagnosticosState copyWith({
    List<DiagnosticoEntity>? diagnosticos,
    DiagnosticosStats? stats,
    DiagnosticoFiltersData? filtersData,
    DiagnosticoSearchFilters? currentFilters,
    String? contextoCultura,
    String? contextoPraga,
    String? contextoDefensivo,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
  }) {
    return DiagnosticosState(
      diagnosticos: diagnosticos ?? this.diagnosticos,
      stats: stats ?? this.stats,
      filtersData: filtersData ?? this.filtersData,
      currentFilters: currentFilters ?? this.currentFilters,
      contextoCultura: contextoCultura ?? this.contextoCultura,
      contextoPraga: contextoPraga ?? this.contextoPraga,
      contextoDefensivo: contextoDefensivo ?? this.contextoDefensivo,
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
      contextoCultura: null,
      contextoPraga: null,
      contextoDefensivo: null,
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
            updatedList = [...currentState.diagnosticos, ...diagnosticos];
          }

          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              isLoadingMore: false,
              diagnosticos: updatedList,
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
              diagnosticos: diagnosticos,
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
    print('🔍 [DEBUG] getDiagnosticosByDefensivo - idDefensivo: $idDefensivo');
    print('🔍 [DEBUG] getDiagnosticosByDefensivo - nomeDefensivo: $nomeDefensivo');

    // CORREÇÃO: Aguarda a inicialização do provider
    await future;

    final currentState = state.requireValue;
    print('✅ [DEBUG] State inicializado corretamente');

    state = AsyncValue.data(
      currentState
          .copyWith(
            contextoDefensivo: nomeDefensivo ?? idDefensivo,
            isLoading: true,
          )
          .clearError(),
    );

    try {
      print('🔍 [DEBUG] Chamando use case _getDiagnosticosByDefensivoUseCase...');
      final result = await _getDiagnosticosByDefensivoUseCase(idDefensivo);
      print('✅ [DEBUG] Use case retornou resultado');

      result.fold(
        (failure) {
          print('❌ [DEBUG] Failure: ${failure.message}');
          final updatedState = state.requireValue;
          state = AsyncValue.data(
            updatedState.copyWith(
              isLoading: false,
              errorMessage: failure.message,
            ),
          );
        },
        (diagnosticos) {
          print('✅ [DEBUG] Success: ${diagnosticos.length} diagnósticos encontrados');
          final updatedState = state.requireValue;
          state = AsyncValue.data(
            updatedState.copyWith(
              isLoading: false,
              diagnosticos: diagnosticos,
            ).clearError(),
          );
        },
      );
    } catch (e) {
      print('❌ [DEBUG] Exception: $e');
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
              diagnosticos: diagnosticos,
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
              diagnosticos: diagnosticos,
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
              diagnosticos: diagnosticos,
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

    state = AsyncValue.data(currentState.clearContext().copyWith(isLoading: true).clearError());

    try {
      final result = await _searchDiagnosticosByPatternUseCase(pattern);
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
              diagnosticos: diagnosticos,
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

    final filtered = currentState.diagnosticos
        .where((d) => d.aplicacao.tiposDisponiveis.contains(tipo))
        .toList();

    state = AsyncValue.data(
      currentState.copyWith(diagnosticos: filtered),
    );
  }

  /// Filtra diagnósticos carregados por completude
  void filterByCompletude(DiagnosticoCompletude completude) {
    final currentState = state.value;
    if (currentState == null) return;

    final filtered = currentState.diagnosticos
        .where((d) => d.completude == completude)
        .toList();

    state = AsyncValue.data(
      currentState.copyWith(diagnosticos: filtered),
    );
  }

  /// Ordena diagnósticos por dosagem
  void sortByDosagem({bool ascending = true}) {
    final currentState = state.value;
    if (currentState == null || currentState.diagnosticos.isEmpty) return;

    final sortedDiagnosticos = List<DiagnosticoEntity>.from(currentState.diagnosticos);
    sortedDiagnosticos.sort((a, b) {
      final dosageA = a.dosagem.dosageAverage;
      final dosageB = b.dosagem.dosageAverage;

      return ascending ? dosageA.compareTo(dosageB) : dosageB.compareTo(dosageA);
    });

    state = AsyncValue.data(
      currentState.copyWith(diagnosticos: sortedDiagnosticos),
    );
  }

  /// Ordena diagnósticos por completude
  void sortByCompletude() {
    final currentState = state.value;
    if (currentState == null || currentState.diagnosticos.isEmpty) return;

    final sortedDiagnosticos = List<DiagnosticoEntity>.from(currentState.diagnosticos);
    sortedDiagnosticos.sort((a, b) {
      final scoreA = a.completude.index;
      final scoreB = b.completude.index;
      return scoreA.compareTo(scoreB);
    });

    state = AsyncValue.data(
      currentState.copyWith(diagnosticos: sortedDiagnosticos),
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

    state = AsyncValue.data(
      currentState.clearContext().copyWith(
            currentFilters: const DiagnosticoSearchFilters(),
          ),
    );
    loadAllDiagnosticos();
  }

  /// Limpa erro
  void clearError() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.clearError());
  }
}
