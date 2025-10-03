import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/services/access_history_service.dart';
import '../../../../core/services/random_selection_service.dart';
import '../../domain/entities/praga_entity.dart';
import '../../domain/usecases/get_pragas_usecase.dart';

part 'pragas_notifier.g.dart';

/// Pragas state
class PragasState {
  final List<PragaEntity> pragas;
  final List<PragaEntity> recentPragas;
  final List<PragaEntity> suggestedPragas;
  final PragaEntity? selectedPraga;
  final PragasStats? stats;
  final bool isLoading;
  final String? errorMessage;

  const PragasState({
    required this.pragas,
    required this.recentPragas,
    required this.suggestedPragas,
    this.selectedPraga,
    this.stats,
    required this.isLoading,
    this.errorMessage,
  });

  factory PragasState.initial() {
    return const PragasState(
      pragas: [],
      recentPragas: [],
      suggestedPragas: [],
      selectedPraga: null,
      stats: null,
      isLoading: false,
      errorMessage: null,
    );
  }

  PragasState copyWith({
    List<PragaEntity>? pragas,
    List<PragaEntity>? recentPragas,
    List<PragaEntity>? suggestedPragas,
    PragaEntity? selectedPraga,
    PragasStats? stats,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PragasState(
      pragas: pragas ?? this.pragas,
      recentPragas: recentPragas ?? this.recentPragas,
      suggestedPragas: suggestedPragas ?? this.suggestedPragas,
      selectedPraga: selectedPraga ?? this.selectedPraga,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  PragasState clearError() {
    return copyWith(errorMessage: null);
  }

  PragasState clearSelection() {
    return copyWith(selectedPraga: null);
  }

  // Getters de conveniência por tipo
  List<PragaEntity> get insetos => pragas.where((p) => p.isInseto).toList();
  List<PragaEntity> get doencas => pragas.where((p) => p.isDoenca).toList();
  List<PragaEntity> get plantas => pragas.where((p) => p.isPlanta).toList();

  // UI helpers
  bool get hasData => pragas.isNotEmpty;
  bool get hasRecentPragas => recentPragas.isNotEmpty;
  bool get hasSuggestedPragas => suggestedPragas.isNotEmpty;
  bool get hasSelectedPraga => selectedPraga != null;

  PragasViewState get viewState {
    if (isLoading) return PragasViewState.loading;
    if (errorMessage != null) return PragasViewState.error;
    if (pragas.isEmpty) return PragasViewState.empty;
    return PragasViewState.loaded;
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

/// Notifier para gerenciar estado das pragas (Presentation Layer)
/// Princípios: Single Responsibility + Dependency Inversion
@riverpod
class PragasNotifier extends _$PragasNotifier {
  late final GetPragasUseCase _getPragasUseCase;
  late final GetPragasByTipoUseCase _getPragasByTipoUseCase;
  late final GetPragaByIdUseCase _getPragaByIdUseCase;
  late final GetPragasByCulturaUseCase _getPragasByCulturaUseCase;
  late final SearchPragasUseCase _searchPragasUseCase;
  late final GetRecentPragasUseCase _getRecentPragasUseCase;
  late final GetSuggestedPragasUseCase _getSuggestedPragasUseCase;
  late final GetPragasStatsUseCase _getPragasStatsUseCase;
  late final AccessHistoryService _historyService;

  @override
  Future<PragasState> build() async {
    // Get use cases from DI
    _getPragasUseCase = di.sl<GetPragasUseCase>();
    _getPragasByTipoUseCase = di.sl<GetPragasByTipoUseCase>();
    _getPragaByIdUseCase = di.sl<GetPragaByIdUseCase>();
    _getPragasByCulturaUseCase = di.sl<GetPragasByCulturaUseCase>();
    _searchPragasUseCase = di.sl<SearchPragasUseCase>();
    _getRecentPragasUseCase = di.sl<GetRecentPragasUseCase>();
    _getSuggestedPragasUseCase = di.sl<GetSuggestedPragasUseCase>();
    _getPragasStatsUseCase = di.sl<GetPragasStatsUseCase>();
    _historyService = AccessHistoryService();

    return PragasState.initial();
  }

  /// Inicialização
  Future<void> initialize() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isLoading: true).clearError());

    try {
      await Future.wait([
        loadRecentPragas(),
        loadSuggestedPragas(),
        loadStats(),
      ]);
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          errorMessage: 'Erro ao inicializar dados das pragas: $e',
        ),
      );
    }
  }

  /// Carrega todas as pragas
  Future<void> loadAllPragas() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isLoading: true).clearError());

    try {
      final result = await _getPragasUseCase.execute();
      result.fold(
        (failure) {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              errorMessage: failure.message,
            ),
          );
        },
        (pragas) {
          // Ordena alfabeticamente por nome comum
          pragas.sort((a, b) => a.nomeComum.compareTo(b.nomeComum));
          state = AsyncValue.data(
            currentState.copyWith(isLoading: false, pragas: pragas).clearError(),
          );
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(isLoading: false, errorMessage: e.toString()),
      );
    }
  }

  /// Carrega pragas por tipo
  Future<void> loadPragasByTipo(String tipo) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isLoading: true).clearError());

    try {
      final result = await _getPragasByTipoUseCase.execute(tipo);
      result.fold(
        (failure) {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              errorMessage: failure.message,
            ),
          );
        },
        (pragas) {
          // Ordena alfabeticamente por nome comum
          pragas.sort((a, b) => a.nomeComum.compareTo(b.nomeComum));
          state = AsyncValue.data(
            currentState.copyWith(isLoading: false, pragas: pragas).clearError(),
          );
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(isLoading: false, errorMessage: e.toString()),
      );
    }
  }

  /// Seleciona uma praga por ID
  Future<void> selectPragaById(String id) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isLoading: true).clearError());

    try {
      final result = await _getPragaByIdUseCase.execute(id);
      await result.fold(
        (failure) async {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              errorMessage: failure.message,
            ),
          );
        },
        (praga) async {
          state = AsyncValue.data(
            currentState.copyWith(isLoading: false, selectedPraga: praga).clearError(),
          );

          // Atualiza lista de recentes após acessar
          await loadRecentPragas();
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(isLoading: false, errorMessage: e.toString()),
      );
    }
  }

  /// Carrega pragas por cultura
  Future<void> loadPragasByCultura(String culturaId) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isLoading: true).clearError());

    try {
      final result = await _getPragasByCulturaUseCase.execute(culturaId);
      result.fold(
        (failure) {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              errorMessage: failure.message,
            ),
          );
        },
        (pragas) {
          // Ordena alfabeticamente por nome comum
          pragas.sort((a, b) => a.nomeComum.compareTo(b.nomeComum));
          state = AsyncValue.data(
            currentState.copyWith(isLoading: false, pragas: pragas).clearError(),
          );
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(isLoading: false, errorMessage: e.toString()),
      );
    }
  }

  /// Pesquisa pragas por nome
  Future<void> searchPragas(String searchTerm) async {
    final currentState = state.value;
    if (currentState == null) return;

    final trimmedTerm = searchTerm.trim();

    // Early return for empty search
    if (trimmedTerm.isEmpty) {
      state = AsyncValue.data(currentState.copyWith(pragas: []));
      return;
    }

    state = AsyncValue.data(currentState.copyWith(isLoading: true).clearError());

    try {
      final result = await _searchPragasUseCase.execute(trimmedTerm);
      result.fold(
        (failure) {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              errorMessage: failure.message,
            ),
          );
        },
        (pragas) {
          // Results are already sorted by relevance in repository
          state = AsyncValue.data(
            currentState.copyWith(isLoading: false, pragas: pragas).clearError(),
          );
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(isLoading: false, errorMessage: e.toString()),
      );
    }
  }

  /// Carrega pragas recentes
  Future<void> loadRecentPragas() async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      // Tenta carregar do histórico primeiro
      final historyItems = await _historyService.getPragasHistory();

      if (historyItems.isNotEmpty) {
        // Converte histórico para PragaEntity
        final historicPragas = <PragaEntity>[];

        // Para fazer a conversão, precisamos carregar todas as pragas uma vez
        final allPragasResult = await _getPragasUseCase.execute();
        allPragasResult.fold(
          (failure) => throw Exception(failure.message),
          (allPragas) {
            for (final historyItem in historyItems.take(10)) {
              final praga = allPragas.firstWhere(
                (p) => p.idReg == historyItem.id || p.nomeComum == historyItem.name,
                orElse: () => const PragaEntity(
                  idReg: '',
                  nomeComum: '',
                  nomeCientifico: '',
                  tipoPraga: '1',
                ),
              );

              if (praga.idReg.isNotEmpty) {
                historicPragas.add(praga);
              }
            }

            // Combina histórico com seleção aleatória se necessário
            final recentPragas = RandomSelectionService.combineHistoryWithRandom<PragaEntity>(
              historicPragas,
              allPragas,
              RandomSelectionService.selectRandomPragas,
              count: 10,
            );

            state = AsyncValue.data(currentState.copyWith(recentPragas: recentPragas));
          },
        );
      } else {
        // Fallback para use case original se não há histórico
        final result = await _getRecentPragasUseCase.execute();
        result.fold(
          (failure) {
            state = AsyncValue.data(
              currentState.copyWith(errorMessage: failure.message),
            );
          },
          (pragas) {
            state = AsyncValue.data(currentState.copyWith(recentPragas: pragas));
          },
        );
      }
    } catch (e) {
      state = AsyncValue.data(currentState.copyWith(errorMessage: e.toString()));
    }
  }

  /// Carrega pragas sugeridas
  Future<void> loadSuggestedPragas({int limit = 10}) async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      // Tenta usar o use case original, mas com fallback para seleção aleatória
      try {
        final result = await _getSuggestedPragasUseCase.execute(limit: limit);
        await result.fold(
          (failure) async => throw Exception(failure.message),
          (pragas) async {
            // Se não retornou sugestões, usa seleção aleatória inteligente
            if (pragas.isEmpty) {
              final allPragasResult = await _getPragasUseCase.execute();
              allPragasResult.fold(
                (failure) => throw Exception(failure.message),
                (allPragas) {
                  final suggested = RandomSelectionService.selectSuggestedPragas(
                    allPragas,
                    count: limit,
                  );
                  state = AsyncValue.data(currentState.copyWith(suggestedPragas: suggested));
                },
              );
            } else {
              state = AsyncValue.data(currentState.copyWith(suggestedPragas: pragas));
            }
          },
        );
      } catch (e) {
        // Em caso de erro, usa seleção aleatória como fallback
        final allPragasResult = await _getPragasUseCase.execute();
        allPragasResult.fold(
          (failure) => throw Exception(failure.message),
          (allPragas) {
            final suggested = RandomSelectionService.selectSuggestedPragas(
              allPragas,
              count: limit,
            );
            state = AsyncValue.data(currentState.copyWith(suggestedPragas: suggested));
          },
        );
      }
    } catch (e) {
      state = AsyncValue.data(currentState.copyWith(errorMessage: e.toString()));
    }
  }

  /// Carrega estatísticas
  Future<void> loadStats() async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      final result = await _getPragasStatsUseCase.execute();
      result.fold(
        (failure) {
          state = AsyncValue.data(currentState.copyWith(errorMessage: failure.message));
        },
        (stats) {
          state = AsyncValue.data(currentState.copyWith(stats: stats));
        },
      );
    } catch (e) {
      state = AsyncValue.data(currentState.copyWith(errorMessage: e.toString()));
    }
  }

  /// Limpa seleção atual
  void clearSelection() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.clearSelection());
  }

  /// Ordena a lista atual de pragas alfabeticamente
  void sortPragas(bool isAscending) {
    final currentState = state.value;
    if (currentState == null || currentState.pragas.isEmpty) return;

    final sortedPragas = List<PragaEntity>.from(currentState.pragas);
    sortedPragas.sort((a, b) {
      final comparison = a.nomeComum.compareTo(b.nomeComum);
      return isAscending ? comparison : -comparison;
    });

    state = AsyncValue.data(currentState.copyWith(pragas: sortedPragas));
  }

  /// Limpa resultados de pesquisa e recarrega dados iniciais
  Future<void> clearSearch() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(pragas: []).clearError());
  }

  /// Limpa erro
  void clearError() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.clearError());
  }

  /// Inicia estado de loading (para evitar flash de empty state)
  void startInitialLoading() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isLoading: true));
  }

  /// Registra acesso a uma praga
  Future<void> recordPragaAccess(PragaEntity praga) async {
    await _historyService.recordPragaAccess(
      id: praga.idReg,
      nomeComum: praga.nomeComum,
      nomeCientifico: praga.nomeCientifico,
      tipoPraga: praga.tipoPraga,
    );
  }
}
