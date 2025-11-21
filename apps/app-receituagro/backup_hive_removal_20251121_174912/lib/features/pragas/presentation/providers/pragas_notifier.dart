import 'package:core/core.dart' hide Column;

import '../../data/mappers/praga_mapper.dart';
import '../../domain/entities/praga_entity.dart';
import 'pragas_providers.dart';
import 'pragas_state.dart';

part 'pragas_notifier.g.dart';

/// Notifier para gerenciar estado das pragas (Presentation Layer)
/// Princípios: Single Responsibility + Dependency Inversion
@Riverpod(keepAlive: true)
class PragasNotifier extends _$PragasNotifier {
  @override
  Future<PragasState> build() async {
    return await _loadInitialData();
  }

  /// Load initial data
  Future<PragasState> _loadInitialData() async {
    try {
      // Carregar todas as pragas
      final pragasRepository = ref.read(pragasRepositoryProvider);
      final pragasDrift = await pragasRepository.findAll();
      final pragas = PragaMapper.fromDriftToEntityList(pragasDrift);

      return PragasState(
        pragas: pragas,
        recentPragas: const [],
        suggestedPragas: const [],
        isLoading: false,
      );
    } catch (e) {
      final errorService = ref.read(pragasErrorMessageServiceProvider);
      return PragasState(
        pragas: const [],
        recentPragas: const [],
        suggestedPragas: const [],
        isLoading: false,
        errorMessage: errorService.getLoadInitialError(e.toString()),
      );
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
      final errorService = ref.read(pragasErrorMessageServiceProvider);
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          errorMessage: errorService.getInitializeError(e.toString()),
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
      state = AsyncValue.data(
        currentState.copyWith(isLoading: false).clearError(),
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
      state = AsyncValue.data(
        currentState.copyWith(isLoading: false).clearError(),
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
      state = AsyncValue.data(
        currentState.copyWith(isLoading: false).clearError(),
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
      state = AsyncValue.data(currentState.copyWith(recentPragas: []));
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
      state = AsyncValue.data(currentState.copyWith(suggestedPragas: []));
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(errorMessage: e.toString()),
      );
    }
  }

  /// Carrega estatísticas (pragas por tipo)
  Future<void> loadStats() async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      // Se pragas já foram carregadas, apenas atualiza o estado
      // As propriedades computed (insetos, doencas, plantas) são calculadas automaticamente
      if (currentState.pragas.isEmpty) {
        final pragasRepository = ref.read(pragasRepositoryProvider);
        final pragasDrift = await pragasRepository.findAll();
        final pragas = PragaMapper.fromDriftToEntityList(pragasDrift);

        state = AsyncValue.data(currentState.copyWith(pragas: pragas));
      } else {
        state = AsyncValue.data(currentState);
      }
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
    final historyService = ref.read(accessHistoryServiceProvider);
    await historyService.recordPragaAccess(
      id: praga.idReg,
      nomeComum: praga.nomeComum,
      nomeCientifico: praga.nomeCientifico,
      tipoPraga: praga.tipoPraga,
    );
  }
}
