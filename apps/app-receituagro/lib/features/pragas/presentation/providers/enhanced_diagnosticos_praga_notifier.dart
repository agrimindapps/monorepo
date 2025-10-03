import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/services/diagnostico_compatibility_service.dart';
import '../../../../core/services/diagnostico_entity_resolver.dart';
import '../../../../core/services/diagnostico_grouping_service.dart';
import '../../../diagnosticos/domain/entities/diagnostico_entity.dart';
import '../../../diagnosticos/domain/repositories/i_diagnosticos_repository.dart';

part 'enhanced_diagnosticos_praga_notifier.g.dart';

/// Classe para estatísticas dos diagnósticos
class DiagnosticosStats {
  final int total;
  final int filtered;
  final int groups;
  final double avgGroupSize;
  final bool hasFilters;
  final double cacheHitRate;

  const DiagnosticosStats({
    required this.total,
    required this.filtered,
    required this.groups,
    required this.avgGroupSize,
    required this.hasFilters,
    required this.cacheHitRate,
  });

  @override
  String toString() {
    return 'DiagnosticosStats{total: $total, filtered: $filtered, '
        'groups: $groups, hitRate: ${cacheHitRate.toStringAsFixed(1)}%}';
  }
}

/// Enhanced Diagnosticos Praga state
class EnhancedDiagnosticosPragaState {
  final List<DiagnosticoEntity> diagnosticos;
  final String searchQuery;
  final String selectedCultura;
  final List<String> availableCulturas;
  final Map<String, List<DiagnosticoEntity>> cachedGrouping;
  final DateTime? lastGroupingUpdate;
  final String? currentPragaId;
  final String? currentPragaName;
  final bool isLoading;
  final bool isLoadingFilters;
  final String? errorMessage;

  const EnhancedDiagnosticosPragaState({
    required this.diagnosticos,
    required this.searchQuery,
    required this.selectedCultura,
    required this.availableCulturas,
    required this.cachedGrouping,
    this.lastGroupingUpdate,
    this.currentPragaId,
    this.currentPragaName,
    required this.isLoading,
    required this.isLoadingFilters,
    this.errorMessage,
  });

  factory EnhancedDiagnosticosPragaState.initial() {
    return const EnhancedDiagnosticosPragaState(
      diagnosticos: [],
      searchQuery: '',
      selectedCultura: 'Todas',
      availableCulturas: ['Todas'],
      cachedGrouping: {},
      lastGroupingUpdate: null,
      currentPragaId: null,
      currentPragaName: null,
      isLoading: false,
      isLoadingFilters: false,
      errorMessage: null,
    );
  }

  EnhancedDiagnosticosPragaState copyWith({
    List<DiagnosticoEntity>? diagnosticos,
    String? searchQuery,
    String? selectedCultura,
    List<String>? availableCulturas,
    Map<String, List<DiagnosticoEntity>>? cachedGrouping,
    DateTime? lastGroupingUpdate,
    String? currentPragaId,
    String? currentPragaName,
    bool? isLoading,
    bool? isLoadingFilters,
    String? errorMessage,
  }) {
    return EnhancedDiagnosticosPragaState(
      diagnosticos: diagnosticos ?? this.diagnosticos,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCultura: selectedCultura ?? this.selectedCultura,
      availableCulturas: availableCulturas ?? this.availableCulturas,
      cachedGrouping: cachedGrouping ?? this.cachedGrouping,
      lastGroupingUpdate: lastGroupingUpdate ?? this.lastGroupingUpdate,
      currentPragaId: currentPragaId ?? this.currentPragaId,
      currentPragaName: currentPragaName ?? this.currentPragaName,
      isLoading: isLoading ?? this.isLoading,
      isLoadingFilters: isLoadingFilters ?? this.isLoadingFilters,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  EnhancedDiagnosticosPragaState clearError() {
    return copyWith(errorMessage: null);
  }

  EnhancedDiagnosticosPragaState invalidateGroupingCache() {
    return copyWith(
      cachedGrouping: {},
      lastGroupingUpdate: null,
    );
  }

  // Getters de conveniência
  bool get hasData => diagnosticos.isNotEmpty;
  bool get hasError => errorMessage != null;
  bool get hasFilters => searchQuery.isNotEmpty || selectedCultura != 'Todas';

  int get totalDiagnosticos => diagnosticos.length;
  int get filteredCount => _applyFilters().length;
  int get cultureGroupsCount => cachedGrouping.length;

  List<DiagnosticoEntity> _applyFilters() {
    var filtered = List<DiagnosticoEntity>.from(diagnosticos);

    // Filtro por texto
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((diag) {
        final query = searchQuery.toLowerCase();
        return (diag.nomeDefensivo?.toLowerCase().contains(query) ?? false) ||
            (diag.nomeCultura?.toLowerCase().contains(query) ?? false) ||
            (diag.nomePraga?.toLowerCase().contains(query) ?? false) ||
            diag.idDefensivo.toLowerCase().contains(query);
      }).toList();
    }

    // Filtro por cultura
    if (selectedCultura != 'Todas') {
      filtered = filtered.where((diag) {
        final culturaNome = diag.nomeCultura ?? '';
        return culturaNome == selectedCultura;
      }).toList();
    }

    return filtered;
  }

  List<DiagnosticoEntity> get filteredDiagnosticos => _applyFilters();

  Map<String, List<DiagnosticoEntity>> get groupedDiagnosticos => cachedGrouping;

  DiagnosticosStats get stats {
    final grouping = groupedDiagnosticos;

    return DiagnosticosStats(
      total: totalDiagnosticos,
      filtered: filteredCount,
      groups: grouping.length,
      avgGroupSize: grouping.isNotEmpty
          ? grouping.values.map((list) => list.length).reduce((a, b) => a + b) / grouping.length
          : 0.0,
      hasFilters: hasFilters,
      cacheHitRate: 0.0,
    );
  }

  bool isGroupingCacheValid() {
    const cacheTTL = Duration(minutes: 5);
    return lastGroupingUpdate != null &&
        DateTime.now().difference(lastGroupingUpdate!) < cacheTTL;
  }
}

/// Provider aprimorado para gerenciar diagnósticos relacionados à praga
/// Utiliza os novos serviços centralizados
@riverpod
class EnhancedDiagnosticosPragaNotifier extends _$EnhancedDiagnosticosPragaNotifier {
  late final IDiagnosticosRepository _repository;
  late final DiagnosticoEntityResolver _resolver;
  late final DiagnosticoGroupingService _groupingService;
  late final DiagnosticoCompatibilityService _compatibilityService;

  @override
  Future<EnhancedDiagnosticosPragaState> build() async {
    // Get dependencies from DI
    _repository = di.sl<IDiagnosticosRepository>();
    _resolver = DiagnosticoEntityResolver.instance;
    _groupingService = DiagnosticoGroupingService.instance;
    _compatibilityService = DiagnosticoCompatibilityService.instance;

    return EnhancedDiagnosticosPragaState.initial();
  }

  /// Inicializa o provider
  Future<void> initialize() async {
    try {
      // Inicialização de serviços se necessário
    } catch (e) {
      // Initialization errors are logged internally
    }
  }

  /// Carrega diagnósticos para uma praga específica por ID
  Future<void> loadDiagnosticos(String pragaId) async {
    final currentState = state.value;
    if (currentState == null) return;

    final pragaName = await _resolver.resolvePragaNome(idPraga: pragaId);

    state = AsyncValue.data(
      currentState.copyWith(
        isLoading: true,
        currentPragaId: pragaId,
        currentPragaName: pragaName,
      ).clearError(),
    );

    try {
      final result = await _repository.getByPraga(pragaId);

      await result.fold(
        (failure) async {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              errorMessage: 'Erro ao carregar diagnósticos: ${failure.toString()}',
            ),
          );
        },
        (entities) async {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              diagnosticos: entities,
            ).clearError(),
          );
          await _updateAvailableCulturas();
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          errorMessage: 'Erro ao carregar diagnósticos: $e',
        ),
      );
    }
  }

  /// Busca diagnósticos por texto usando cache otimizado
  Future<void> searchByText(String query) async {
    final currentState = state.value;
    if (currentState == null) return;

    if (query.trim().isEmpty) {
      updateSearchQuery('');
      return;
    }

    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      final diagnosticos = await _repository.searchByPattern(query);
      final diagnosticosHive = diagnosticos.fold(
        (failure) => <DiagnosticoEntity>[],
        (data) => data,
      );

      if (diagnosticosHive.isNotEmpty) {
        final ids = diagnosticosHive.map((d) => d.id).toList();
        final filteredResults = <DiagnosticoEntity>[];

        for (final id in ids) {
          final result = await _repository.getById(id);
          result.fold(
            (failure) => null,
            (entity) {
              if (entity != null) filteredResults.add(entity);
            },
          );
        }

        state = AsyncValue.data(
          currentState.copyWith(
            isLoading: false,
            diagnosticos: filteredResults,
          ).clearError(),
        );
        await _updateAvailableCulturas();
        updateSearchQuery(query);
      } else {
        state = AsyncValue.data(
          currentState.copyWith(
            isLoading: false,
            diagnosticos: [],
          ).clearError(),
        );
        updateSearchQuery(query);
      }
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          errorMessage: 'Erro na busca por texto: $e',
        ),
      );
    }
  }

  /// Atualiza query de pesquisa
  void updateSearchQuery(String query) {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(
        searchQuery: query,
        isLoadingFilters: false,
      ).invalidateGroupingCache(),
    );
  }

  /// Atualiza cultura selecionada
  void updateSelectedCultura(String cultura) {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(
        selectedCultura: cultura,
        isLoadingFilters: false,
      ).invalidateGroupingCache(),
    );
  }

  /// Atualiza agrupamentos de forma assíncrona
  Future<void> updateGroupings() async {
    final currentState = state.value;
    if (currentState == null) return;

    // Verifica cache de agrupamento
    if (currentState.isGroupingCacheValid() && currentState.cachedGrouping.isNotEmpty) {
      return;
    }

    // Gera novo agrupamento usando serviço centralizado
    final filtered = currentState.filteredDiagnosticos;
    final grouped = await _groupingService.groupDiagnosticoEntitiesByCultura(
      filtered,
      sortByRelevance: true,
    );

    state = AsyncValue.data(
      currentState.copyWith(
        cachedGrouping: grouped,
        lastGroupingUpdate: DateTime.now(),
      ),
    );
  }

  /// Atualiza lista de culturas disponíveis
  Future<void> _updateAvailableCulturas() async {
    final currentState = state.value;
    if (currentState == null) return;

    final culturas = <String>{'Todas'};

    for (final diag in currentState.diagnosticos) {
      if (diag.idCultura.isNotEmpty) {
        final culturaNome = await _resolver.resolveCulturaNome(
          idCultura: diag.idCultura,
        );
        if (culturaNome.isNotEmpty && culturaNome != 'Cultura não especificada') {
          culturas.add(culturaNome);
        }
      }
    }

    final sortedCulturas = culturas.toList()..sort();

    state = AsyncValue.data(
      currentState.copyWith(availableCulturas: sortedCulturas),
    );
  }

  /// Valida compatibilidade para um diagnóstico específico
  Future<CompatibilityValidation?> validateCompatibility(DiagnosticoEntity diagnostico) async {
    final currentState = state.value;
    if (currentState == null || currentState.currentPragaId?.isNotEmpty != true) return null;

    try {
      return await _compatibilityService.validateFullCompatibility(
        idDefensivo: diagnostico.idDefensivo,
        idCultura: diagnostico.idCultura,
        idPraga: currentState.currentPragaId!,
        includeAlternatives: false,
      );
    } catch (e) {
      return null;
    }
  }

  /// Obtém sugestões de busca (cache temporariamente desabilitado)
  List<String> getSuggestions(String partialQuery) {
    return [];
  }

  /// Limpa todos os dados e filtros
  void clear() {
    state = AsyncValue.data(EnhancedDiagnosticosPragaState.initial());
  }

  /// Limpa apenas filtros
  void clearFilters() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(
        searchQuery: '',
        selectedCultura: 'Todas',
        isLoadingFilters: false,
      ).invalidateGroupingCache(),
    );
  }

  /// Limpa mensagem de erro
  void clearError() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.clearError());
  }

  /// Força recarregamento dos dados
  Future<void> refresh() async {
    final currentState = state.value;
    if (currentState == null || currentState.currentPragaId?.isNotEmpty != true) return;

    await loadDiagnosticos(currentState.currentPragaId!);
  }
}
