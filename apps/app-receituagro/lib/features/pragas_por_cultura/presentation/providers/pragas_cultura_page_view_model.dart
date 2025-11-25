import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/services/pragas_cultura_data_service.dart';
import '../../data/services/pragas_cultura_query_service.dart';
import '../../data/services/pragas_cultura_sort_service.dart';
import '../../data/services/pragas_cultura_statistics_service.dart';
import '../../domain/entities/pragas_cultura_filter.dart';
import '../../domain/entities/pragas_cultura_statistics.dart';
import '../services/pragas_cultura_error_message_service.dart';
import 'pragas_cultura_providers.dart';

part 'pragas_cultura_page_view_model.g.dart';

/// State class para o ViewModel
class PragasCulturaPageState {
  final List<Map<String, dynamic>> pragasOriginais;
  final List<Map<String, dynamic>> pragasFiltradasOrdenadas;
  final List<Map<String, dynamic>> culturas;
  final PragasCulturaFilter filtroAtual;
  final PragasCulturaStatistics? estatisticas;
  final bool isLoading;
  final String? erro;

  const PragasCulturaPageState({
    this.pragasOriginais = const [],
    this.pragasFiltradasOrdenadas = const [],
    this.culturas = const [],
    this.filtroAtual = const PragasCulturaFilter(),
    this.estatisticas,
    this.isLoading = false,
    this.erro,
  });

  PragasCulturaPageState copyWith({
    List<Map<String, dynamic>>? pragasOriginais,
    List<Map<String, dynamic>>? pragasFiltradasOrdenadas,
    List<Map<String, dynamic>>? culturas,
    PragasCulturaFilter? filtroAtual,
    PragasCulturaStatistics? estatisticas,
    bool? isLoading,
    String? erro,
  }) {
    return PragasCulturaPageState(
      pragasOriginais: pragasOriginais ?? this.pragasOriginais,
      pragasFiltradasOrdenadas:
          pragasFiltradasOrdenadas ?? this.pragasFiltradasOrdenadas,
      culturas: culturas ?? this.culturas,
      filtroAtual: filtroAtual ?? this.filtroAtual,
      estatisticas: estatisticas ?? this.estatisticas,
      isLoading: isLoading ?? this.isLoading,
      erro: erro,
    );
  }
}

/// ViewModel para gerenciar estado e lógica da página de Pragas por Cultura
@riverpod
class PragasCulturaPageViewModel extends _$PragasCulturaPageViewModel {
  late final IPragasCulturaDataService dataService;
  late final IPragasCulturaQueryService queryService;
  late final IPragasCulturaSortService sortService;
  late final IPragasCulturaStatisticsService statisticsService;
  late final PragasCulturaErrorMessageService errorService;

  @override
  Future<PragasCulturaPageState> build() async {
    dataService = ref.watch(pragasCulturaDataServiceProvider);
    queryService = ref.watch(pragasCulturaQueryServiceProvider);
    sortService = ref.watch(pragasCulturaSortServiceProvider);
    statisticsService = ref.watch(pragasCulturaStatisticsServiceProvider);
    errorService = ref.watch(pragasCulturaErrorServiceProvider);

    return const PragasCulturaPageState();
  }

  /// Carrega pragas para uma cultura
  Future<void> loadPragasForCultura(String culturaId) async {
    state = AsyncValue.data(state.value!.copyWith(isLoading: true, erro: null));

    try {
      final pragas = await dataService.getPragasForCultura(culturaId);
      _applyFiltersAndSort(pragas);
    } catch (e) {
      state = AsyncValue.data(
        state.value!.copyWith(
          isLoading: false,
          erro: errorService.getLoadPragasError(e.toString()),
        ),
      );
    }
  }

  /// Carrega todas as culturas
  Future<void> loadCulturas() async {
    try {
      final culturas = await dataService.getAllCulturas();
      state = AsyncValue.data(state.value!.copyWith(culturas: culturas));
    } catch (e) {
      state = AsyncValue.data(
        state.value!.copyWith(
          erro: errorService.getLoadCulturasError(e.toString()),
        ),
      );
    }
  }

  /// Aplica filtro de criticidade
  void filterByCriticidade({required bool? onlyCriticas}) {
    final currentState = state.value;
    if (currentState == null) return;

    final novoFiltro = currentState.filtroAtual.copyWith(
      onlyCriticas: onlyCriticas ?? false,
      onlyNormais: onlyCriticas == false,
    );
    _applyFilter(novoFiltro);
  }

  /// Aplica filtro de tipo
  void filterByTipo(String? tipoPraga) {
    final currentState = state.value;
    if (currentState == null) return;

    final novoFiltro = currentState.filtroAtual.copyWith(tipoPraga: tipoPraga);
    _applyFilter(novoFiltro);
  }

  /// Aplica ordenação
  void sortPragas(String sortBy) {
    final currentState = state.value;
    if (currentState == null) return;

    final novoFiltro = currentState.filtroAtual.copyWith(sortBy: sortBy);
    _applyFilter(novoFiltro);
  }

  void clearFilters() {
    _applyFilter(const PragasCulturaFilter());
  }

  /// Aplica filtro e atualiza estado
  void _applyFilter(PragasCulturaFilter novoFiltro) {
    final currentState = state.value;
    if (currentState == null) return;

    var pragasFiltradasOrdenadas = currentState.pragasOriginais;

    // Apply filters
    pragasFiltradasOrdenadas = queryService.applyFilters(
      pragasFiltradasOrdenadas,
      novoFiltro,
    );

    // Apply sorting
    pragasFiltradasOrdenadas = sortService.sortBy(
      pragasFiltradasOrdenadas,
      novoFiltro.sortBy,
      ascending: true,
    );

    // Calculate statistics
    final estatisticas = statisticsService.calculateStatistics(
      pragasFiltradasOrdenadas,
    );

    state = AsyncValue.data(
      currentState.copyWith(
        filtroAtual: novoFiltro,
        pragasFiltradasOrdenadas: pragasFiltradasOrdenadas,
        estatisticas: estatisticas,
        isLoading: false,
      ),
    );
  }

  /// Aplica filtros e ordenação às pragas carregadas
  void _applyFiltersAndSort(List<Map<String, dynamic>> pragas) {
    final currentState = state.value;
    if (currentState == null) return;

    var pragasFiltradasOrdenadas = pragas;

    // Apply filters
    pragasFiltradasOrdenadas = queryService.applyFilters(
      pragasFiltradasOrdenadas,
      currentState.filtroAtual,
    );

    // Apply sorting
    pragasFiltradasOrdenadas = sortService.sortBy(
      pragasFiltradasOrdenadas,
      currentState.filtroAtual.sortBy,
      ascending: true,
    );

    // Calculate statistics
    final estatisticas = statisticsService.calculateStatistics(pragas);

    state = AsyncValue.data(
      currentState.copyWith(
        pragasOriginais: pragas,
        pragasFiltradasOrdenadas: pragasFiltradasOrdenadas,
        estatisticas: estatisticas,
        isLoading: false,
      ),
    );
  }

  /// Limpa cache
  Future<void> refreshData() async {
    await dataService.clearCache();
  }
}
