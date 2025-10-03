import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../data/services/defensivos_grouping_service.dart';
import '../../domain/entities/defensivo_entity.dart';
import '../../domain/entities/defensivo_group_entity.dart';
import '../../domain/entities/drill_down_navigation_state.dart';

part 'defensivos_drill_down_notifier.g.dart';

/// Defensivos drill-down state
class DefensivosDrillDownState {
  final DrillDownNavigationState navigationState;
  final List<DefensivoEntity> allDefensivos;
  final List<DefensivoGroupEntity> groups;
  final List<DefensivoGroupEntity> filteredGroups;
  final List<DefensivoEntity> currentGroupItems;
  final bool isLoading;
  final String? errorMessage;

  const DefensivosDrillDownState({
    required this.navigationState,
    required this.allDefensivos,
    required this.groups,
    required this.filteredGroups,
    required this.currentGroupItems,
    required this.isLoading,
    this.errorMessage,
  });

  factory DefensivosDrillDownState.initial({String tipoAgrupamento = 'fabricante'}) {
    final navigationState = DrillDownNavigationState.initial(tipoAgrupamento: tipoAgrupamento);
    return DefensivosDrillDownState(
      navigationState: navigationState,
      allDefensivos: [],
      groups: [],
      filteredGroups: [],
      currentGroupItems: [],
      isLoading: false,
      errorMessage: null,
    );
  }

  DefensivosDrillDownState copyWith({
    DrillDownNavigationState? navigationState,
    List<DefensivoEntity>? allDefensivos,
    List<DefensivoGroupEntity>? groups,
    List<DefensivoGroupEntity>? filteredGroups,
    List<DefensivoEntity>? currentGroupItems,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DefensivosDrillDownState(
      navigationState: navigationState ?? this.navigationState,
      allDefensivos: allDefensivos ?? this.allDefensivos,
      groups: groups ?? this.groups,
      filteredGroups: filteredGroups ?? this.filteredGroups,
      currentGroupItems: currentGroupItems ?? this.currentGroupItems,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  DefensivosDrillDownState clearError() {
    return copyWith(errorMessage: null);
  }

  // Getters de conveniência
  bool get hasError => errorMessage != null;
  bool get isAtGroupLevel => navigationState.isAtGroupLevel;
  bool get isAtItemLevel => navigationState.isAtItemLevel;
  bool get canGoBack => navigationState.canGoBack;
  String get pageTitle => navigationState.pageTitle;
  String get pageSubtitle => navigationState.pageSubtitle;
  List<String> get breadcrumbs => navigationState.breadcrumbs;
}

/// Notifier para gerenciar estado de drill-down de defensivos
/// Gerencia navegação entre grupos e itens
/// Integra com DefensivosUnificadoNotifier para dados
@riverpod
class DefensivosDrillDownNotifier extends _$DefensivosDrillDownNotifier {
  late final DefensivosGroupingService _groupingService;

  @override
  Future<DefensivosDrillDownState> build() async {
    // Get dependencies from DI
    _groupingService = di.sl<DefensivosGroupingService>();

    return DefensivosDrillDownState.initial();
  }

  /// Inicializa provider com dados de defensivos
  void initializeWithDefensivos({
    required List<DefensivoEntity> defensivos,
    required String tipoAgrupamento,
  }) {
    final currentState = state.value;
    if (currentState == null) return;

    final navigationState = DrillDownNavigationState.initial(tipoAgrupamento: tipoAgrupamento);
    final groups = _generateGroups(defensivos, tipoAgrupamento);
    final filteredGroups = _applyFilters(groups, navigationState);

    state = AsyncValue.data(
      currentState.copyWith(
        allDefensivos: defensivos,
        navigationState: navigationState,
        groups: groups,
        filteredGroups: filteredGroups,
      ).clearError(),
    );
  }

  /// Navegar para drill-down de um grupo
  void drillDownToGroup(DefensivoGroupEntity group) {
    final currentState = state.value;
    if (currentState == null) return;

    final navigationState = currentState.navigationState.drillDownToGroup(group);
    final currentGroupItems = _updateCurrentGroupItems(group, navigationState);

    state = AsyncValue.data(
      currentState.copyWith(
        navigationState: navigationState,
        currentGroupItems: currentGroupItems,
      ),
    );
  }

  /// Voltar para vista de grupos
  void goBackToGroups() {
    final currentState = state.value;
    if (currentState == null) return;

    if (!currentState.navigationState.canGoBack) return;

    final navigationState = currentState.navigationState.goBackToGroups();

    state = AsyncValue.data(
      currentState.copyWith(
        navigationState: navigationState,
        currentGroupItems: [],
      ),
    );
  }

  /// Atualizar filtro de busca
  void updateSearchFilter(String searchText) {
    final currentState = state.value;
    if (currentState == null) return;

    final navigationState = currentState.navigationState.updateSearch(searchText);
    final filteredGroups = _applyFilters(currentState.groups, navigationState);

    state = AsyncValue.data(
      currentState.copyWith(
        navigationState: navigationState,
        filteredGroups: filteredGroups,
      ),
    );
  }

  /// Limpar filtro de busca
  void clearSearchFilter() {
    final currentState = state.value;
    if (currentState == null) return;

    final navigationState = currentState.navigationState.clearSearch();
    final filteredGroups = _applyFilters(currentState.groups, navigationState);

    state = AsyncValue.data(
      currentState.copyWith(
        navigationState: navigationState,
        filteredGroups: filteredGroups,
      ),
    );
  }

  /// Toggle ordenação
  void toggleSort() {
    final currentState = state.value;
    if (currentState == null) return;

    final navigationState = currentState.navigationState.toggleSort();
    final filteredGroups = _applySorting(currentState.filteredGroups, navigationState);

    state = AsyncValue.data(
      currentState.copyWith(
        navigationState: navigationState,
        filteredGroups: filteredGroups,
      ),
    );
  }

  /// Atualizar defensivos
  void updateDefensivos(List<DefensivoEntity> defensivos) {
    final currentState = state.value;
    if (currentState == null) return;

    final groups = _generateGroups(defensivos, currentState.navigationState.tipoAgrupamento);
    final filteredGroups = _applyFilters(groups, currentState.navigationState);

    // Se estava em um grupo, atualizar itens
    final currentGroupItems = currentState.navigationState.isAtItemLevel && currentState.navigationState.currentGroup != null
        ? _updateCurrentGroupItems(currentState.navigationState.currentGroup!, currentState.navigationState)
        : <DefensivoEntity>[];

    state = AsyncValue.data(
      currentState.copyWith(
        allDefensivos: defensivos,
        groups: groups,
        filteredGroups: filteredGroups,
        currentGroupItems: currentGroupItems,
      ),
    );
  }

  /// Reset para estado inicial
  void reset() {
    final currentState = state.value;
    if (currentState == null) return;

    final navigationState = currentState.navigationState.reset();
    final filteredGroups = _applyFilters(currentState.groups, navigationState);

    state = AsyncValue.data(
      currentState.copyWith(
        navigationState: navigationState,
        currentGroupItems: [],
        filteredGroups: filteredGroups,
      ),
    );
  }

  /// Obter estatísticas dos grupos
  Map<String, dynamic> getGroupStatistics() {
    final currentState = state.value;
    if (currentState == null) return {};

    return _groupingService.obterEstatisticas(grupos: currentState.groups);
  }

  /// Definir estado de carregamento
  void setLoading(bool loading) {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(isLoading: loading).clearError(),
    );
  }

  /// Definir erro
  void setError(String error) {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(isLoading: false, errorMessage: error),
    );
  }

  /// Limpar erro
  void clearError() {
    final currentState = state.value;
    if (currentState == null) return;

    if (currentState.errorMessage != null) {
      state = AsyncValue.data(currentState.clearError());
    }
  }

  /// Navegar para um grupo específico por nome
  void navigateToGroupByName(String groupName) {
    final currentState = state.value;
    if (currentState == null) return;

    final group = currentState.groups.firstWhere(
      (g) => g.nome == groupName,
      orElse: () => DefensivoGroupEntity.empty(
        tipoAgrupamento: currentState.navigationState.tipoAgrupamento,
        nomeGrupo: groupName,
      ),
    );

    if (group.hasItems) {
      drillDownToGroup(group);
    }
  }

  /// Obter grupo por ID
  DefensivoGroupEntity? getGroupById(String groupId) {
    final currentState = state.value;
    if (currentState == null) return null;

    try {
      return currentState.groups.firstWhere((g) => g.id == groupId);
    } catch (e) {
      return null;
    }
  }

  /// Verificar se tipo de agrupamento é válido
  bool isValidGroupingType(String type) {
    return _groupingService.isValidTipoAgrupamento(type);
  }

  // Private methods

  /// Gera grupos a partir dos defensivos
  List<DefensivoGroupEntity> _generateGroups(List<DefensivoEntity> defensivos, String tipoAgrupamento) {
    try {
      return _groupingService.agruparDefensivos(
        defensivos: defensivos,
        tipoAgrupamento: tipoAgrupamento,
      );
    } catch (e) {
      setError('Erro ao agrupar defensivos: $e');
      return [];
    }
  }

  /// Aplica filtros atuais
  List<DefensivoGroupEntity> _applyFilters(
    List<DefensivoGroupEntity> groups,
    DrillDownNavigationState navigationState,
  ) {
    try {
      // Primeiro, filtrar grupos com nomes muito curtos
      var filteredGroups = groups.where((group) {
        return group.nome.length >= 3;
      }).toList();

      if (navigationState.hasSearchFilter) {
        filteredGroups = _groupingService.filtrarGrupos(
          grupos: filteredGroups,
          filtroTexto: navigationState.searchText,
        );
      }

      return _applySorting(filteredGroups, navigationState);
    } catch (e) {
      setError('Erro ao filtrar grupos: $e');
      return [];
    }
  }

  /// Aplica ordenação
  List<DefensivoGroupEntity> _applySorting(
    List<DefensivoGroupEntity> groups,
    DrillDownNavigationState navigationState,
  ) {
    try {
      return _groupingService.ordenarGrupos(
        grupos: groups,
        ascending: navigationState.isAscending,
      );
    } catch (e) {
      setError('Erro ao ordenar grupos: $e');
      return groups;
    }
  }

  /// Atualiza itens do grupo atual
  List<DefensivoEntity> _updateCurrentGroupItems(
    DefensivoGroupEntity currentGroup,
    DrillDownNavigationState navigationState,
  ) {
    try {
      // Aplicar filtros aos itens do grupo
      var items = List<DefensivoEntity>.from(currentGroup.itens);

      // Filtrar itens com descrição menor que 3 caracteres
      items = items.where((item) {
        return item.displayName.length >= 3;
      }).toList();

      if (navigationState.hasSearchFilter) {
        final filtroLower = navigationState.searchText.toLowerCase();
        items = items.where((item) {
          return item.displayName.toLowerCase().contains(filtroLower) ||
              item.displayIngredient.toLowerCase().contains(filtroLower) ||
              item.displayFabricante.toLowerCase().contains(filtroLower) ||
              item.displayClass.toLowerCase().contains(filtroLower);
        }).toList();
      }

      // Ordenar itens
      items.sort((a, b) {
        final comparison = a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
        return navigationState.isAscending ? comparison : -comparison;
      });

      return items;
    } catch (e) {
      setError('Erro ao atualizar itens do grupo: $e');
      return [];
    }
  }
}
