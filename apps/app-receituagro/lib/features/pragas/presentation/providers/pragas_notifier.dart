import 'package:app_receituagro/core/di/injection.dart' as di;
import 'package:core/core.dart' hide Column;

import '../../../../database/repositories/pragas_repository.dart';
import '../../../../core/services/access_history_service.dart';
import '../../data/mappers/praga_mapper.dart';
import '../../domain/entities/praga_entity.dart';
import '../../domain/services/i_pragas_error_message_service.dart';
import 'pragas_state.dart';

part 'pragas_notifier.g.dart';

/// Notifier para gerenciar estado das pragas (Presentation Layer)
/// Princípios: Single Responsibility + Dependency Inversion
@Riverpod(keepAlive: true)
class PragasNotifier extends _$PragasNotifier {
  late final AccessHistoryService _historyService;
  late final IPragasErrorMessageService _errorService;
  late final PragasRepository _pragasRepository;

  @override
  Future<PragasState> build() async {
    _historyService = AccessHistoryService();
    _errorService = di.getIt<IPragasErrorMessageService>();
    _pragasRepository = GetIt.instance<PragasRepository>();
    return await _loadInitialData();
  }

  /// Load initial data
  Future<PragasState> _loadInitialData() async {
    try {
      // Carregar todas as pragas
      final pragasDrift = await _pragasRepository.findAll();
      final pragas = PragaMapper.fromDriftToEntityList(pragasDrift);

      return PragasState(
        pragas: pragas,
        recentPragas: const [],
        suggestedPragas: const [],
        isLoading: false,
      );
    } catch (e) {
      return PragasState(
        pragas: const [],
        recentPragas: const [],
        suggestedPragas: const [],
        isLoading: false,
        errorMessage: _errorService.getLoadInitialError(e.toString()),
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
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          errorMessage: _errorService.getInitializeError(e.toString()),
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
        final pragasDrift = await _pragasRepository.findAll();
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
    await _historyService.recordPragaAccess(
      id: praga.idReg,
      nomeComum: praga.nomeComum,
      nomeCientifico: praga.nomeCientifico,
      tipoPraga: praga.tipoPraga,
    );
  }
}
