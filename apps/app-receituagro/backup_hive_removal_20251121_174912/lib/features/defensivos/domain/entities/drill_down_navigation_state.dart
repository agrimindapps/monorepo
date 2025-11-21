import 'package:core/core.dart' hide Column;

import 'defensivo_group_entity.dart';

/// Representa o estado da navegação drill-down
/// Gerencia níveis de navegação e histórico
enum DrillDownLevel {
  groups,    // Vista de grupos
  items,     // Vista de itens dentro do grupo
}

/// Estado de navegação para drill-down de defensivos
class DrillDownNavigationState extends Equatable {
  final DrillDownLevel currentLevel;
  final String tipoAgrupamento;
  final DefensivoGroupEntity? currentGroup;
  final List<String> breadcrumbs;
  final String searchText;
  final bool isAscending;

  const DrillDownNavigationState({
    required this.currentLevel,
    required this.tipoAgrupamento,
    this.currentGroup,
    required this.breadcrumbs,
    this.searchText = '',
    this.isAscending = true,
  });

  /// Estado inicial - mostrando grupos
  factory DrillDownNavigationState.initial({
    required String tipoAgrupamento,
  }) {
    return DrillDownNavigationState(
      currentLevel: DrillDownLevel.groups,
      tipoAgrupamento: tipoAgrupamento,
      currentGroup: null,
      breadcrumbs: [_getTipoAgrupamentoDisplayName(tipoAgrupamento)],
      searchText: '',
      isAscending: true,
    );
  }

  /// Verifica se está no nível de grupos
  bool get isAtGroupLevel => currentLevel == DrillDownLevel.groups;

  /// Verifica se está no nível de itens
  bool get isAtItemLevel => currentLevel == DrillDownLevel.items;

  /// Verifica se pode voltar
  bool get canGoBack => currentLevel == DrillDownLevel.items;

  /// Verifica se tem filtro de busca ativo
  bool get hasSearchFilter => searchText.isNotEmpty;

  /// Nome do tipo de agrupamento para exibição
  String get displayTipoAgrupamento => _getTipoAgrupamentoDisplayName(tipoAgrupamento);

  /// Título da página atual
  String get pageTitle {
    switch (currentLevel) {
      case DrillDownLevel.groups:
        return displayTipoAgrupamento;
      case DrillDownLevel.items:
        return currentGroup?.displayName ?? 'Defensivos';
    }
  }

  /// Subtítulo da página atual
  String get pageSubtitle {
    switch (currentLevel) {
      case DrillDownLevel.groups:
        return 'Agrupados por $displayTipoAgrupamento';
      case DrillDownLevel.items:
        return currentGroup?.displayCount ?? '';
    }
  }

  /// Navegar para um grupo específico
  DrillDownNavigationState drillDownToGroup(DefensivoGroupEntity group) {
    return copyWith(
      currentLevel: DrillDownLevel.items,
      currentGroup: group,
      breadcrumbs: [
        ...breadcrumbs,
        group.displayName,
      ],
    );
  }

  /// Voltar para o nível de grupos
  DrillDownNavigationState goBackToGroups() {
    if (!canGoBack) return this;

    return copyWith(
      currentLevel: DrillDownLevel.groups,
      currentGroup: null,
      breadcrumbs: breadcrumbs.length > 1
          ? breadcrumbs.sublist(0, breadcrumbs.length - 1)
          : breadcrumbs,
    );
  }

  /// Atualizar filtro de busca
  DrillDownNavigationState updateSearch(String searchText) {
    return copyWith(searchText: searchText);
  }

  /// Limpar filtro de busca
  DrillDownNavigationState clearSearch() {
    return copyWith(searchText: '');
  }

  /// Toggle ordenação
  DrillDownNavigationState toggleSort() {
    return copyWith(isAscending: !isAscending);
  }

  /// Reset para estado inicial
  DrillDownNavigationState reset() {
    return DrillDownNavigationState.initial(tipoAgrupamento: tipoAgrupamento);
  }

  /// CopyWith method
  DrillDownNavigationState copyWith({
    DrillDownLevel? currentLevel,
    String? tipoAgrupamento,
    DefensivoGroupEntity? currentGroup,
    List<String>? breadcrumbs,
    String? searchText,
    bool? isAscending,
  }) {
    return DrillDownNavigationState(
      currentLevel: currentLevel ?? this.currentLevel,
      tipoAgrupamento: tipoAgrupamento ?? this.tipoAgrupamento,
      currentGroup: currentGroup ?? this.currentGroup,
      breadcrumbs: breadcrumbs ?? this.breadcrumbs,
      searchText: searchText ?? this.searchText,
      isAscending: isAscending ?? this.isAscending,
    );
  }

  /// Helper para obter nome de exibição do tipo de agrupamento
  static String _getTipoAgrupamentoDisplayName(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'fabricante':
      case 'fabricantes':
        return 'Fabricante';
      case 'modo_acao':
      case 'modoacao':
      case 'modoAcao':
        return 'Modo de Ação';
      case 'ingrediente_ativo':
      case 'ingredienteativo':
      case 'ingredienteAtivo':
        return 'Ingrediente Ativo';
      case 'classe':
      case 'classe_agronomica':
      case 'classeagronomica':
        return 'Classe Agronômica';
      case 'categoria':
        return 'Categoria';
      case 'toxico':
      case 'toxicidade':
        return 'Toxicidade';
      default:
        return tipo.substring(0, 1).toUpperCase() + tipo.substring(1);
    }
  }

  @override
  List<Object?> get props => [
        currentLevel,
        tipoAgrupamento,
        currentGroup,
        breadcrumbs,
        searchText,
        isAscending,
      ];

  @override
  String toString() {
    return 'DrillDownNavigationState(currentLevel: $currentLevel, tipoAgrupamento: $tipoAgrupamento, currentGroup: ${currentGroup?.nome})';
  }
}
