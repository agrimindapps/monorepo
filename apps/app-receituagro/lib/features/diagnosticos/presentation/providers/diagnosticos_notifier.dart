import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/services/failure_message_service.dart';
import '../../domain/entities/diagnostico_entity.dart';
import '../../domain/services/filtering/i_diagnosticos_filter_service.dart';
import '../../domain/services/metadata/i_diagnosticos_metadata_service.dart';
import '../../domain/services/search/i_diagnosticos_search_service.dart';
import '../../domain/services/stats/i_diagnosticos_stats_service.dart';
import '../../domain/usecases/get_diagnosticos_params.dart';
import '../../domain/usecases/get_diagnosticos_usecase.dart';
import 'diagnosticos_state.dart';

part 'diagnosticos_notifier.g.dart';

/// Notifier para gerenciar estado dos diagnósticos (Presentation Layer)
/// Especializado em recomendações defensivo-cultura-praga
///
/// IMPORTANTE: keepAlive mantém o state mesmo quando não há listeners
/// Isso previne perda de dados ao navegar entre tabs ou fazer rebuilds temporários
///
/// REFACTORING: Migrated to use Specialized Services (SOLID principles)
/// - DiagnosticosFilterService: filtering operations
/// - DiagnosticosSearchService: search operations
/// - DiagnosticosMetadataService: metadata extraction
/// - DiagnosticosStatsService: analytics and statistics
/// - FailureMessageService: error message handling
@Riverpod(keepAlive: true)
class DiagnosticosNotifier extends _$DiagnosticosNotifier {
  // ========== Specialized Services (New Architecture) ==========
  late final IDiagnosticosFilterService _filterService;
  late final IDiagnosticosSearchService _searchService;
  late final IDiagnosticosMetadataService _metadataService;
  late final IDiagnosticosStatsService _statsService;
  late final FailureMessageService _failureMessageService;

  // ========== Use Cases (Kept for backward compatibility) ==========
  late final GetDiagnosticosUseCase _getDiagnosticosUseCase;
  late final GetDiagnosticoByIdUseCase _getDiagnosticoByIdUseCase;
  late final GetRecomendacoesUseCase _getRecomendacoesUseCase;
  late final ValidateCompatibilidadeUseCase _validateCompatibilidadeUseCase;

  @override
  Future<DiagnosticosState> build() async {
    // ========== Inject Specialized Services (New Architecture) ==========
    _filterService = di.sl<IDiagnosticosFilterService>();
    _searchService = di.sl<IDiagnosticosSearchService>();
    _metadataService = di.sl<IDiagnosticosMetadataService>();
    _statsService = di.sl<IDiagnosticosStatsService>();
    _failureMessageService = di.sl<FailureMessageService>();

    // ========== Inject Use Cases (Kept for backward compatibility) ==========
    _getDiagnosticosUseCase = di.sl<GetDiagnosticosUseCase>();
    _getDiagnosticoByIdUseCase = di.sl<GetDiagnosticoByIdUseCase>();
    _getRecomendacoesUseCase = di.sl<GetRecomendacoesUseCase>();
    _validateCompatibilidadeUseCase = di.sl<ValidateCompatibilidadeUseCase>();

    return DiagnosticosState.initial();
  }

  /// Inicializa o provider
  Future<void> initialize() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(isLoading: true).clearError(),
    );

    try {
      await Future.wait([_loadStats(), _loadFiltersData()]);
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
      state = AsyncValue.data(
        currentState.clearContext().copyWith(isLoading: true).clearError(),
      );
    } else {
      state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));
    }

    try {
      final result = await _getDiagnosticosUseCase(GetAllDiagnosticosParams());
      result.fold(
        (failure) {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              isLoadingMore: false,
              errorMessage: _failureMessageService.mapFailureToMessage(failure),
            ),
          );
        },
        (diagnosticos) {
          final List<DiagnosticoEntity> updatedList;
          if (offset == null || offset == 0) {
            updatedList = diagnosticos as List<DiagnosticoEntity>;
          } else {
            updatedList = [
              ...currentState.allDiagnosticos,
              ...?diagnosticos as List<DiagnosticoEntity>?,
            ];
          }

          // CORREÇÃO: loadAllDiagnosticos atualiza tanto allDiagnosticos quanto filteredDiagnosticos
          state = AsyncValue.data(
            currentState
                .copyWith(
                  isLoading: false,
                  isLoadingMore: false,
                  allDiagnosticos: updatedList,
                  filteredDiagnosticos: updatedList,
                )
                .clearError(),
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
              errorMessage: _failureMessageService.mapFailureToMessage(failure),
            ),
          );
        },
        (diagnosticos) {
          state = AsyncValue.data(
            currentState
                .copyWith(
                  isLoading: false,
                  filteredDiagnosticos: diagnosticos,
                  // CORREÇÃO: Sempre atualiza allDiagnosticos quando há contexto
                  allDiagnosticos: diagnosticos,
                )
                .clearError(),
          );
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(isLoading: false, errorMessage: e.toString()),
      );
    }
  }

  /// Busca diagnósticos por defensivo
  /// REFACTORED: Now uses DiagnosticosFilterService
  Future<void> getDiagnosticosByDefensivo(
    String idDefensivo, {
    String? nomeDefensivo,
  }) async {
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
      // REFACTORED: Use DiagnosticosFilterService instead of use case
      final result = await _filterService.filterByDefensivo(idDefensivo);

      result.fold(
        (failure) {
          final updatedState = state.requireValue;
          state = AsyncValue.data(
            updatedState.copyWith(
              isLoading: false,
              errorMessage: _failureMessageService.mapFailureToMessage(failure),
            ),
          );
        },
        (diagnosticos) {
          final updatedState = state.requireValue;

          // CORREÇÃO: Atualiza filteredDiagnosticos com os resultados filtrados por defensivo
          // IMPORTANTE: SEMPRE atualiza allDiagnosticos para garantir que o getter funcione
          // CRÍTICO: MANTÉM o contextoDefensivo que foi definido no início do método
          state = AsyncValue.data(
            updatedState
                .copyWith(
                  isLoading: false,
                  filteredDiagnosticos: diagnosticos,
                  // CORREÇÃO: Sempre atualiza allDiagnosticos (não passa null)
                  allDiagnosticos: diagnosticos,
                  // CRÍTICO: Reforça o contextoDefensivo para garantir que não seja perdido
                  contextoDefensivo: nomeDefensivo ?? idDefensivo,
                )
                .clearError(),
          );
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[DiagnosticosNotifier] Error in getDiagnosticosByDefensivo: $e',
        );
      }
      final updatedState = state.requireValue;
      state = AsyncValue.data(
        updatedState.copyWith(isLoading: false, errorMessage: e.toString()),
      );
    }
  }

  /// Busca diagnósticos por cultura
  /// REFACTORED: Now uses DiagnosticosFilterService
  Future<void> getDiagnosticosByCultura(
    String idCultura, {
    String? nomeCultura,
  }) async {
    // CORREÇÃO: Aguarda a inicialização do provider
    await future;

    final currentState = state.requireValue;

    state = AsyncValue.data(
      currentState
          .copyWith(contextoCultura: nomeCultura ?? idCultura, isLoading: true)
          .clearError(),
    );

    try {
      // REFACTORED: Use DiagnosticosFilterService instead of use case
      final result = await _filterService.filterByCultura(idCultura);
      result.fold(
        (failure) {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              errorMessage: _failureMessageService.mapFailureToMessage(failure),
            ),
          );
        },
        (diagnosticos) {
          state = AsyncValue.data(
            currentState
                .copyWith(
                  isLoading: false,
                  filteredDiagnosticos: diagnosticos,
                  // CORREÇÃO: Sempre atualiza allDiagnosticos quando há contexto
                  allDiagnosticos: diagnosticos,
                )
                .clearError(),
          );
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(isLoading: false, errorMessage: e.toString()),
      );
    }
  }

  /// Busca diagnósticos por praga
  /// REFACTORED: Now uses DiagnosticosFilterService
  Future<void> getDiagnosticosByPraga(
    String idPraga, {
    String? nomePraga,
  }) async {
    // CORREÇÃO: Aguarda a inicialização do provider
    await future;

    final currentState = state.requireValue;

    state = AsyncValue.data(
      currentState
          .copyWith(contextoPraga: nomePraga ?? idPraga, isLoading: true)
          .clearError(),
    );

    try {
      // REFACTORED: Use DiagnosticosFilterService instead of use case
      final result = await _filterService.filterByPraga(idPraga);
      result.fold(
        (failure) {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              errorMessage: _failureMessageService.mapFailureToMessage(failure),
            ),
          );
        },
        (diagnosticos) {
          state = AsyncValue.data(
            currentState
                .copyWith(
                  isLoading: false,
                  filteredDiagnosticos: diagnosticos,
                  // CORREÇÃO: Sempre atualiza allDiagnosticos quando há contexto
                  allDiagnosticos: diagnosticos,
                )
                .clearError(),
          );
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(isLoading: false, errorMessage: e.toString()),
      );
    }
  }

  /// Busca com filtros
  /// REFACTORED: Now uses DiagnosticosSearchService
  Future<void> searchWithFilters(DiagnosticoSearchFilters filters) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState
          .clearContext()
          .copyWith(currentFilters: filters, isLoading: true)
          .clearError(),
    );

    try {
      // REFACTORED: Use DiagnosticosSearchService instead of use case
      final result = await _searchService.searchWithFilters(filters);
      result.fold(
        (failure) {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              errorMessage: _failureMessageService.mapFailureToMessage(failure),
            ),
          );
        },
        (diagnosticos) {
          state = AsyncValue.data(
            currentState
                .copyWith(
                  isLoading: false,
                  filteredDiagnosticos: diagnosticos,
                  // CORREÇÃO: Sempre atualiza allDiagnosticos quando há contexto
                  allDiagnosticos: diagnosticos,
                )
                .clearError(),
          );
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(isLoading: false, errorMessage: e.toString()),
      );
    }
  }

  /// Filtra diagnósticos por cultura (client-side)
  void filterByCultura(String? culturaNome) {
    final currentState = state.value;
    if (currentState == null) return;

    if (culturaNome == null || culturaNome == 'Todas') {
      // Restaurar todos os diagnósticos do contexto atual
      state = AsyncValue.data(
        currentState.copyWith(
          contextoCultura: null,
          filteredDiagnosticos: currentState.allDiagnosticos,
        ),
      );
      return;
    }

    // Filtrar localmente por cultura
    final filtered = currentState.allDiagnosticos.where((diag) {
      final nomeCulturaLower = diag.nomeCultura?.toLowerCase() ?? '';
      final culturaNomeLower = culturaNome.toLowerCase();
      return nomeCulturaLower == culturaNomeLower;
    }).toList();

    state = AsyncValue.data(
      currentState.copyWith(
        contextoCultura: culturaNome,
        filteredDiagnosticos: filtered,
      ),
    );
  }

  /// Busca por padrão geral
  /// REFACTORED: Now uses DiagnosticosSearchService (client-side optimization)
  Future<void> searchByPattern(String pattern) async {
    final currentState = state.value;
    if (currentState == null) return;

    // Se a busca está vazia, limpa os resultados e volta para filteredDiagnosticos
    if (pattern.trim().isEmpty) {
      state = AsyncValue.data(
        currentState.copyWith(
          searchQuery: '',
          searchResults: [],
          // NÃO limpa contexto - preserva filtro de defensivo/cultura/praga
        ),
      );
      return;
    }

    // NÃO usa clearContext() - preserva contexto de defensivo/cultura/praga
    state = AsyncValue.data(
      currentState.copyWith(searchQuery: pattern, isLoading: true).clearError(),
    );

    try {
      // CORREÇÃO: Busca localmente em filteredDiagnosticos (que contém o contexto)
      // ao invés de allDiagnosticos
      final diagnosticosParaBusca = currentState.filteredDiagnosticos.isNotEmpty
          ? currentState.filteredDiagnosticos
          : currentState.allDiagnosticos;

      if (diagnosticosParaBusca.isNotEmpty) {
        // REFACTORED: Use client-side search from DiagnosticosSearchService
        final localResults = _searchService.searchInList(
          diagnosticosParaBusca,
          pattern,
        );

        state = AsyncValue.data(
          currentState
              .copyWith(
                searchQuery: pattern,
                searchResults: localResults,
                isLoading: false,
              )
              .clearError(),
        );
        return;
      }

      // Fallback: busca remota se não há dados locais
      // REFACTORED: Use DiagnosticosSearchService instead of use case
      final result = await _searchService.searchByPattern(pattern);
      result.fold(
        (failure) {
          state = AsyncValue.data(
            currentState.copyWith(
              searchQuery: pattern,
              isLoading: false,
              errorMessage: _failureMessageService.mapFailureToMessage(failure),
            ),
          );
        },
        (diagnosticos) {
          state = AsyncValue.data(
            currentState
                .copyWith(
                  searchQuery: pattern,
                  searchResults: diagnosticos,
                  isLoading: false,
                )
                .clearError(),
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
      return result.fold((failure) {
        final currentState = state.value;
        if (currentState != null) {
          state = AsyncValue.data(
            currentState.copyWith(
              errorMessage: _failureMessageService.mapFailureToMessage(failure),
            ),
          );
        }
        return null;
      }, (diagnostico) => diagnostico);
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
      return result.fold((failure) {
        final currentState = state.value;
        if (currentState != null) {
          state = AsyncValue.data(
            currentState.copyWith(
              errorMessage: _failureMessageService.mapFailureToMessage(failure),
            ),
          );
        }
        return false;
      }, (isCompatible) => isCompatible);
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
  /// REFACTORED: Now uses DiagnosticosFilterService (client-side)
  void filterByTipoAplicacao(TipoAplicacao tipo) {
    final currentState = state.value;
    if (currentState == null) return;

    // REFACTORED: Use client-side filter from DiagnosticosFilterService
    final filtered = _filterService.filterListByTipoAplicacao(
      currentState.filteredDiagnosticos,
      tipo,
    );

    state = AsyncValue.data(
      currentState.copyWith(filteredDiagnosticos: filtered),
    );
  }

  /// Filtra diagnósticos carregados por completude
  /// REFACTORED: Now uses DiagnosticosFilterService (client-side)
  void filterByCompletude(DiagnosticoCompletude completude) {
    final currentState = state.value;
    if (currentState == null) return;

    // REFACTORED: Use client-side filter from DiagnosticosFilterService
    final filtered = _filterService.filterListByCompletude(
      currentState.filteredDiagnosticos,
      completude,
    );

    state = AsyncValue.data(
      currentState.copyWith(filteredDiagnosticos: filtered),
    );
  }

  /// Ordena diagnósticos por dosagem
  void sortByDosagem({bool ascending = true}) {
    final currentState = state.value;
    if (currentState == null || currentState.filteredDiagnosticos.isEmpty) {
      return;
    }

    final sortedDiagnosticos = List<DiagnosticoEntity>.from(
      currentState.filteredDiagnosticos,
    );
    sortedDiagnosticos.sort((a, b) {
      final dosageA = a.dosagem.dosageAverage;
      final dosageB = b.dosagem.dosageAverage;

      return ascending
          ? dosageA.compareTo(dosageB)
          : dosageB.compareTo(dosageA);
    });

    state = AsyncValue.data(
      currentState.copyWith(filteredDiagnosticos: sortedDiagnosticos),
    );
  }

  /// Ordena diagnósticos por completude
  void sortByCompletude() {
    final currentState = state.value;
    if (currentState == null || currentState.filteredDiagnosticos.isEmpty) {
      return;
    }

    final sortedDiagnosticos = List<DiagnosticoEntity>.from(
      currentState.filteredDiagnosticos,
    );
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
  /// REFACTORED: Now uses DiagnosticosStatsService
  Future<void> _loadStats() async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      // REFACTORED: Use DiagnosticosStatsService instead of use case
      final result = await _statsService.getStatistics();
      result.fold(
        (failure) {
          state = AsyncValue.data(
            currentState.copyWith(
              errorMessage: _failureMessageService.mapFailureToMessage(failure),
            ),
          );
        },
        (stats) {
          state = AsyncValue.data(currentState.copyWith(stats: stats));
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(errorMessage: e.toString()),
      );
    }
  }

  /// Carrega dados para filtros
  /// REFACTORED: Now uses DiagnosticosMetadataService
  Future<void> _loadFiltersData() async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      // REFACTORED: Use DiagnosticosMetadataService instead of use case
      final result = await _metadataService.getFiltersData();
      result.fold(
        (failure) {
          state = AsyncValue.data(
            currentState.copyWith(
              errorMessage: _failureMessageService.mapFailureToMessage(failure),
            ),
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

    // CORREÇÃO CRÍTICA: Não limpar contextos de navegação (defensivo/cultura/praga)
    // Apenas limpar filtros de busca
    // Isso previne perda de contexto quando o usuário interage com filtros na UI
    state = AsyncValue.data(
      currentState.copyWith(
        currentFilters: const DiagnosticoSearchFilters(),
        searchQuery: '',
        searchResults: [],
        // NÃO chamar clearContext() - preserva contextoDefensivo/contextoCultura/contextoPraga
        // filteredDiagnosticos permanece com os dados do contexto atual
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
