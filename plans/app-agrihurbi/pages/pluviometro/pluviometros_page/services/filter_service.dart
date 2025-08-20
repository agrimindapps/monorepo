// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../../../models/pluviometros_models.dart';
import '../models/filter_models.dart';

/// Service para gerenciar filtros e busca
class FilterService extends ChangeNotifier {
  FilterSet _filterSet = const FilterSet();
  SortConfiguration _sortConfiguration = const SortConfiguration(
    type: SortType.descricao,
    direction: SortDirection.ascending,
  );

  Timer? _debounceTimer;
  static const Duration _debounceDelay = Duration(milliseconds: 300);

  /// Getters
  FilterSet get filterSet => _filterSet;
  SortConfiguration get sortConfiguration => _sortConfiguration;

  bool get hasActiveFilters => _filterSet.hasActiveFilters;
  int get activeFilterCount => _filterSet.activeFilterCount;

  /// Aplica filtros e ordenação a uma lista de pluviômetros
  List<Pluviometro> applyFiltersAndSort(List<Pluviometro> pluviometros) {
    List<Pluviometro> result = _filterSet.applyFilters(pluviometros);
    result = _sortConfiguration.applySort(result);
    return result;
  }

  /// Atualiza query de busca com debounce
  void updateSearchQuery(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
      _filterSet = _filterSet.copyWith(searchQuery: query);
      notifyListeners();
    });
  }

  /// Atualiza query de busca imediatamente
  void updateSearchQueryImmediate(String query) {
    _debounceTimer?.cancel();
    _filterSet = _filterSet.copyWith(searchQuery: query);
    notifyListeners();
  }

  /// Adiciona um filtro
  void addFilter(FilterCriteria filter) {
    final existingFilters = List<FilterCriteria>.from(_filterSet.filters);

    // Remove filtro duplicado se existir
    existingFilters.removeWhere((f) =>
        f.type == filter.type &&
        f.operator == filter.operator &&
        f.value == filter.value);

    existingFilters.add(filter);

    _filterSet = _filterSet.copyWith(filters: existingFilters);
    notifyListeners();
  }

  /// Remove um filtro
  void removeFilter(FilterCriteria filter) {
    final existingFilters = List<FilterCriteria>.from(_filterSet.filters);
    existingFilters.removeWhere((f) =>
        f.type == filter.type &&
        f.operator == filter.operator &&
        f.value == filter.value);

    _filterSet = _filterSet.copyWith(filters: existingFilters);
    notifyListeners();
  }

  /// Ativa/desativa um filtro
  void toggleFilter(FilterCriteria filter) {
    final existingFilters = _filterSet.filters.map((f) {
      if (f.type == filter.type &&
          f.operator == filter.operator &&
          f.value == filter.value) {
        return f.copyWith(isActive: !f.isActive);
      }
      return f;
    }).toList();

    _filterSet = _filterSet.copyWith(filters: existingFilters);
    notifyListeners();
  }

  /// Limpa todos os filtros
  void clearAllFilters() {
    _debounceTimer?.cancel();
    _filterSet = const FilterSet();
    notifyListeners();
  }

  /// Limpa apenas a busca
  void clearSearch() {
    _debounceTimer?.cancel();
    _filterSet = _filterSet.copyWith(searchQuery: null);
    notifyListeners();
  }

  /// Atualiza configuração de ordenação
  void updateSortConfiguration(SortConfiguration config) {
    _sortConfiguration = config;
    notifyListeners();
  }

  /// Alterna direção da ordenação
  void toggleSortDirection() {
    final newDirection = _sortConfiguration.direction == SortDirection.ascending
        ? SortDirection.descending
        : SortDirection.ascending;

    _sortConfiguration = _sortConfiguration.copyWith(direction: newDirection);
    notifyListeners();
  }

  /// Altera tipo de ordenação
  void updateSortType(SortType type) {
    _sortConfiguration = _sortConfiguration.copyWith(type: type);
    notifyListeners();
  }

  /// Altera lógica de combinação dos filtros (AND/OR)
  void updateFilterCombination(bool useAnd) {
    _filterSet = _filterSet.copyWith(combineWithAnd: useAnd);
    notifyListeners();
  }

  /// Aplica preset de filtros
  void applyPresetFilters(List<FilterCriteria> presets) {
    final existingFilters = List<FilterCriteria>.from(_filterSet.filters);

    for (final preset in presets) {
      // Remove filtros duplicados
      existingFilters.removeWhere(
          (f) => f.type == preset.type && f.operator == preset.operator);

      existingFilters.add(preset);
    }

    _filterSet = _filterSet.copyWith(filters: existingFilters);
    notifyListeners();
  }

  /// Salva configuração atual (para persistência)
  Map<String, dynamic> toJson() {
    return {
      'searchQuery': _filterSet.searchQuery,
      'combineWithAnd': _filterSet.combineWithAnd,
      'sortType': _sortConfiguration.type.name,
      'sortDirection': _sortConfiguration.direction.name,
      'filters': _filterSet.filters
          .map((f) => {
                'type': f.type.name,
                'operator': f.operator.name,
                'value': f.value,
                'secondValue': f.secondValue,
                'isActive': f.isActive,
              })
          .toList(),
    };
  }

  /// Carrega configuração salva
  void fromJson(Map<String, dynamic> json) {
    try {
      final filters = (json['filters'] as List?)?.map((f) {
            return FilterCriteria(
              type: FilterType.values.firstWhere(
                (t) => t.name == f['type'],
                orElse: () => FilterType.descricao,
              ),
              operator: FilterOperator.values.firstWhere(
                (o) => o.name == f['operator'],
                orElse: () => FilterOperator.contains,
              ),
              value: f['value'],
              secondValue: f['secondValue'],
              isActive: f['isActive'] ?? true,
            );
          }).toList() ??
          [];

      _filterSet = FilterSet(
        searchQuery: json['searchQuery'],
        combineWithAnd: json['combineWithAnd'] ?? true,
        filters: filters,
      );

      _sortConfiguration = SortConfiguration(
        type: SortType.values.firstWhere(
          (t) => t.name == json['sortType'],
          orElse: () => SortType.descricao,
        ),
        direction: SortDirection.values.firstWhere(
          (d) => d.name == json['sortDirection'],
          orElse: () => SortDirection.ascending,
        ),
      );

      notifyListeners();
    } catch (e) {
      // Se falhar ao carregar, usar configuração padrão
      _filterSet = const FilterSet();
      _sortConfiguration = const SortConfiguration(
        type: SortType.descricao,
        direction: SortDirection.ascending,
      );
    }
  }

  /// Obtém estatísticas dos filtros aplicados
  FilterStats getFilterStats(List<Pluviometro> originalList) {
    final filteredList = applyFiltersAndSort(originalList);

    return FilterStats(
      totalItems: originalList.length,
      filteredItems: filteredList.length,
      filterCount: activeFilterCount,
      hasSearch: _filterSet.searchQuery?.isNotEmpty ?? false,
    );
  }

  /// Obtém sugestões de filtros baseado nos dados
  List<FilterCriteria> getSuggestedFilters(List<Pluviometro> pluviometros) {
    final suggestions = <FilterCriteria>[];

    if (pluviometros.isEmpty) return suggestions;

    // Sugestões baseadas em quantidade
    final quantidades =
        pluviometros.map((p) => p.getQuantidadeAsDouble()).toList();
    quantidades.sort();

    if (quantidades.isNotEmpty) {
      final max = quantidades.last;
      final min = quantidades.first;
      final avg = quantidades.reduce((a, b) => a + b) / quantidades.length;

      if (max > 50) {
        suggestions.add(PresetFilters.quantidadeAlta);
      }
      if (min < 10) {
        suggestions.add(PresetFilters.quantidadeBaixa);
      }
      if (avg > 20) {
        suggestions.add(PresetFilters.quantidadeEntre(avg * 0.8, avg * 1.2));
      }
    }

    // Sugestões baseadas em coordenadas
    final semCoordenadas = pluviometros
        .where((p) =>
            (p.latitude == null || p.latitude!.isEmpty) ||
            (p.longitude == null || p.longitude!.isEmpty))
        .length;

    if (semCoordenadas > 0) {
      suggestions.add(PresetFilters.semCoordenadas);
    }

    if (semCoordenadas < pluviometros.length) {
      suggestions.add(PresetFilters.comCoordenadas);
    }

    // Sugestões baseadas em data
    final now = DateTime.now();
    final recentes = pluviometros.where((p) {
      final created = DateTime.fromMillisecondsSinceEpoch(p.createdAt);
      return created.isAfter(now.subtract(const Duration(days: 7)));
    }).length;

    if (recentes > 0) {
      suggestions.add(PresetFilters.criadosUltimaSemana());
    }

    return suggestions;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// Estatísticas dos filtros
class FilterStats {
  final int totalItems;
  final int filteredItems;
  final int filterCount;
  final bool hasSearch;

  const FilterStats({
    required this.totalItems,
    required this.filteredItems,
    required this.filterCount,
    required this.hasSearch,
  });

  int get hiddenItems => totalItems - filteredItems;
  double get filterEfficiency =>
      totalItems > 0 ? filteredItems / totalItems : 0.0;

  String get displayText {
    if (filterCount == 0 && !hasSearch) {
      return 'Exibindo $totalItems itens';
    }

    return 'Exibindo $filteredItems de $totalItems itens';
  }
}
