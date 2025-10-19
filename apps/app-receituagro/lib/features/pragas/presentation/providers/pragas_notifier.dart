import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/services/access_history_service.dart';
import '../../../../core/services/random_selection_service.dart';
import '../../domain/entities/praga_entity.dart';
import '../../domain/usecases/get_pragas_usecase.dart';
import 'pragas_state.dart';

part 'pragas_notifier.g.dart';

/// Notifier para gerenciar estado das pragas (Presentation Layer)
/// Princípios: Single Responsibility + Dependency Inversion
@Riverpod(keepAlive: true)
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
    _getPragasUseCase = di.sl<GetPragasUseCase>();
    _getPragasByTipoUseCase = di.sl<GetPragasByTipoUseCase>();
    _getPragaByIdUseCase = di.sl<GetPragaByIdUseCase>();
    _getPragasByCulturaUseCase = di.sl<GetPragasByCulturaUseCase>();
    _searchPragasUseCase = di.sl<SearchPragasUseCase>();
    _getRecentPragasUseCase = di.sl<GetRecentPragasUseCase>();
    _getSuggestedPragasUseCase = di.sl<GetSuggestedPragasUseCase>();
    _getPragasStatsUseCase = di.sl<GetPragasStatsUseCase>();
    _historyService = AccessHistoryService();
    return await _loadInitialData();
  }

  /// Load initial data
  Future<PragasState> _loadInitialData() async {
    try {
      final results = await Future.wait([
        _loadRecentPragasData(),
        _loadSuggestedPragasData(limit: 10),
        _loadStatsData(),
      ]);

      final recentPragas = results[0] as List<PragaEntity>;
      final suggestedPragas = results[1] as List<PragaEntity>;
      final stats = results[2] as PragasStats?;

      return PragasState(
        pragas: const [],
        recentPragas: recentPragas,
        suggestedPragas: suggestedPragas,
        stats: stats,
        isLoading: false,
      );
    } catch (e) {
      return PragasState(
        pragas: const [],
        recentPragas: const [],
        suggestedPragas: const [],
        stats: null,
        isLoading: false,
        errorMessage: 'Erro ao carregar dados das pragas: $e',
      );
    }
  }

  /// Load recent pragas data
  /// Usa fallback aleatório apenas na primeira vez (quando não há histórico)
  Future<List<PragaEntity>> _loadRecentPragasData() async {
    try {
      final allPragasResult = await _getPragasUseCase.execute();

      return await allPragasResult.fold(
        (failure) async => <PragaEntity>[],
        (allPragas) async {
          if (allPragas.isEmpty) {
            return <PragaEntity>[];
          }

          final historyItems = await _historyService.getPragasHistory();
          final historicPragas = <PragaEntity>[];

          // Buscar até 7 itens do histórico
          for (final historyItem in historyItems.take(7)) {
            final praga = allPragas.firstWhere(
              (p) => p.idReg == historyItem['id'] ||
                     p.nomeComum == historyItem['nomeComum'],
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

          // SEMPRE retorna exatamente 7 registros
          // Se histórico < 7, completa com aleatórios excluindo os do histórico
          final recentPragas = RandomSelectionService.fillHistoryToCount<PragaEntity>(
            historyItems: historicPragas,
            allItems: allPragas,
            targetCount: 7,
            areEqual: (a, b) => a.idReg == b.idReg,
          );

          return recentPragas;
        },
      );
    } catch (e) {
      return <PragaEntity>[];
    }
  }

  /// Load suggested pragas data
  Future<List<PragaEntity>> _loadSuggestedPragasData({int limit = 10}) async {
    try {
      final result = await _getSuggestedPragasUseCase.execute(limit: limit);
      return await result.fold(
        (failure) async {
          final allPragasResult = await _getPragasUseCase.execute();
          return allPragasResult.fold(
            (failure) => <PragaEntity>[],
            (allPragas) => RandomSelectionService.selectSuggestedPragas(
              allPragas,
              count: limit,
            ),
          );
        },
        (pragas) async {
          if (pragas.isEmpty) {
            final allPragasResult = await _getPragasUseCase.execute();
            return allPragasResult.fold(
              (failure) => <PragaEntity>[],
              (allPragas) => RandomSelectionService.selectSuggestedPragas(
                allPragas,
                count: limit,
              ),
            );
          }
          return pragas;
        },
      );
    } catch (e) {
      return <PragaEntity>[];
    }
  }

  /// Load stats data
  Future<PragasStats?> _loadStatsData() async {
    try {
      final result = await _getPragasStatsUseCase.execute();
      return result.fold((failure) => null, (stats) => stats);
    } catch (e) {
      return null;
    }
  }

  /// Inicialização
  Future<void> initialize() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(isLoading: true).clearError(),
    );

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

    state = AsyncValue.data(
      currentState.copyWith(isLoading: true).clearError(),
    );

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
          pragas.sort((a, b) => a.nomeComum.compareTo(b.nomeComum));
          state = AsyncValue.data(
            currentState
                .copyWith(isLoading: false, pragas: pragas)
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

  /// Carrega pragas por tipo
  Future<void> loadPragasByTipo(String tipo) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(isLoading: true).clearError(),
    );

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
          pragas.sort((a, b) => a.nomeComum.compareTo(b.nomeComum));
          state = AsyncValue.data(
            currentState
                .copyWith(isLoading: false, pragas: pragas)
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

  /// Seleciona uma praga por ID
  Future<void> selectPragaById(String id) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(isLoading: true).clearError(),
    );

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
            currentState
                .copyWith(isLoading: false, selectedPraga: praga)
                .clearError(),
          );
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

    state = AsyncValue.data(
      currentState.copyWith(isLoading: true).clearError(),
    );

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
          pragas.sort((a, b) => a.nomeComum.compareTo(b.nomeComum));
          state = AsyncValue.data(
            currentState
                .copyWith(isLoading: false, pragas: pragas)
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

  /// Pesquisa pragas por nome
  Future<void> searchPragas(String searchTerm) async {
    final currentState = state.value;
    if (currentState == null) return;

    final trimmedTerm = searchTerm.trim();
    if (trimmedTerm.isEmpty) {
      state = AsyncValue.data(currentState.copyWith(pragas: []));
      return;
    }

    state = AsyncValue.data(
      currentState.copyWith(isLoading: true).clearError(),
    );

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
          state = AsyncValue.data(
            currentState
                .copyWith(isLoading: false, pragas: pragas)
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

  /// Carrega pragas recentes
  Future<void> loadRecentPragas() async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      final historyItems = await _historyService.getPragasHistory();

      final historicPragas = <PragaEntity>[];
      final allPragasResult = await _getPragasUseCase.execute();
      allPragasResult.fold((failure) => throw Exception(failure.message), (
        allPragas,
      ) {
        // Buscar até 7 itens do histórico
        for (final historyItem in historyItems.take(7)) {
          final praga = allPragas.firstWhere(
            (p) =>
                p.idReg == historyItem.id || p.nomeComum == historyItem.name,
            orElse:
                () => const PragaEntity(
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

        // SEMPRE retorna exatamente 7 registros
        // Se histórico < 7, completa com aleatórios excluindo os do histórico
        final recentPragas = RandomSelectionService.fillHistoryToCount<PragaEntity>(
          historyItems: historicPragas,
          allItems: allPragas,
          targetCount: 7,
          areEqual: (a, b) => a.idReg == b.idReg,
        );

        state = AsyncValue.data(
          currentState.copyWith(recentPragas: recentPragas),
        );
      });
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(errorMessage: e.toString()),
      );
    }
  }

  /// Carrega pragas sugeridas
  Future<void> loadSuggestedPragas({int limit = 10}) async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      try {
        final result = await _getSuggestedPragasUseCase.execute(limit: limit);
        await result.fold((failure) async => throw Exception(failure.message), (
          pragas,
        ) async {
          if (pragas.isEmpty) {
            final allPragasResult = await _getPragasUseCase.execute();
            allPragasResult.fold(
              (failure) => throw Exception(failure.message),
              (allPragas) {
                final suggested = RandomSelectionService.selectSuggestedPragas(
                  allPragas,
                  count: limit,
                );
                state = AsyncValue.data(
                  currentState.copyWith(suggestedPragas: suggested),
                );
              },
            );
          } else {
            state = AsyncValue.data(
              currentState.copyWith(suggestedPragas: pragas),
            );
          }
        });
      } catch (e) {
        final allPragasResult = await _getPragasUseCase.execute();
        allPragasResult.fold((failure) => throw Exception(failure.message), (
          allPragas,
        ) {
          final suggested = RandomSelectionService.selectSuggestedPragas(
            allPragas,
            count: limit,
          );
          state = AsyncValue.data(
            currentState.copyWith(suggestedPragas: suggested),
          );
        });
      }
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(errorMessage: e.toString()),
      );
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
          state = AsyncValue.data(
            currentState.copyWith(errorMessage: failure.message),
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
