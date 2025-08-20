// Project imports:
import '../../../../models/pluviometros_models.dart';

/// Tipos de filtro disponíveis
enum FilterType {
  descricao,
  quantidade,
  dataCreated,
  grupo,
  coordenadas,
}

/// Operadores de comparação para filtros
enum FilterOperator {
  equals,
  contains,
  startsWith,
  endsWith,
  greaterThan,
  lessThan,
  between,
  isEmpty,
  isNotEmpty,
}

/// Modelo para um filtro individual
class FilterCriteria {
  final FilterType type;
  final FilterOperator operator;
  final dynamic value;
  final dynamic secondValue; // Para operador between
  final bool isActive;

  const FilterCriteria({
    required this.type,
    required this.operator,
    required this.value,
    this.secondValue,
    this.isActive = true,
  });

  FilterCriteria copyWith({
    FilterType? type,
    FilterOperator? operator,
    dynamic value,
    dynamic secondValue,
    bool? isActive,
  }) {
    return FilterCriteria(
      type: type ?? this.type,
      operator: operator ?? this.operator,
      value: value ?? this.value,
      secondValue: secondValue ?? this.secondValue,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Aplica o filtro a um pluviômetro
  bool apply(Pluviometro pluviometro) {
    if (!isActive) return true;

    switch (type) {
      case FilterType.descricao:
        return _applyStringFilter(pluviometro.descricao, value, operator);
      case FilterType.quantidade:
        final quantidade = pluviometro.getQuantidadeAsDouble();
        return _applyNumericFilter(quantidade, value, secondValue, operator);
      case FilterType.dataCreated:
        final date = DateTime.fromMillisecondsSinceEpoch(pluviometro.createdAt);
        return _applyDateFilter(date, value, secondValue, operator);
      case FilterType.grupo:
        return _applyStringFilter(pluviometro.fkGrupo ?? '', value, operator);
      case FilterType.coordenadas:
        return _applyCoordinatesFilter(pluviometro);
    }
  }

  bool _applyStringFilter(
      String fieldValue, dynamic filterValue, FilterOperator operator) {
    if (filterValue == null || filterValue.isEmpty) return true;

    final field = fieldValue.toLowerCase();
    final filter = filterValue.toString().toLowerCase();

    switch (operator) {
      case FilterOperator.equals:
        return field == filter;
      case FilterOperator.contains:
        return field.contains(filter);
      case FilterOperator.startsWith:
        return field.startsWith(filter);
      case FilterOperator.endsWith:
        return field.endsWith(filter);
      case FilterOperator.isEmpty:
        return field.isEmpty;
      case FilterOperator.isNotEmpty:
        return field.isNotEmpty;
      default:
        return true;
    }
  }

  bool _applyNumericFilter(double fieldValue, dynamic filterValue,
      dynamic secondValue, FilterOperator operator) {
    if (filterValue == null) return true;

    final filter = _parseDouble(filterValue);
    if (filter == null) return true;

    switch (operator) {
      case FilterOperator.equals:
        return fieldValue == filter;
      case FilterOperator.greaterThan:
        return fieldValue > filter;
      case FilterOperator.lessThan:
        return fieldValue < filter;
      case FilterOperator.between:
        final secondFilter = _parseDouble(secondValue);
        if (secondFilter == null) return fieldValue >= filter;
        return fieldValue >= filter && fieldValue <= secondFilter;
      default:
        return true;
    }
  }

  bool _applyDateFilter(DateTime fieldValue, dynamic filterValue,
      dynamic secondValue, FilterOperator operator) {
    if (filterValue == null) return true;

    final filter = filterValue as DateTime;

    switch (operator) {
      case FilterOperator.equals:
        return _isSameDay(fieldValue, filter);
      case FilterOperator.greaterThan:
        return fieldValue.isAfter(filter);
      case FilterOperator.lessThan:
        return fieldValue.isBefore(filter);
      case FilterOperator.between:
        final secondFilter = secondValue as DateTime?;
        if (secondFilter == null) return fieldValue.isAfter(filter);
        return fieldValue.isAfter(filter) && fieldValue.isBefore(secondFilter);
      default:
        return true;
    }
  }

  bool _applyCoordinatesFilter(Pluviometro pluviometro) {
    switch (operator) {
      case FilterOperator.isEmpty:
        return (pluviometro.latitude == null ||
                pluviometro.latitude!.isEmpty) &&
            (pluviometro.longitude == null || pluviometro.longitude!.isEmpty);
      case FilterOperator.isNotEmpty:
        return (pluviometro.latitude != null &&
                pluviometro.latitude!.isNotEmpty) &&
            (pluviometro.longitude != null &&
                pluviometro.longitude!.isNotEmpty);
      default:
        return true;
    }
  }

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Converte para string legível
  String toDisplayString() {
    final typeStr = _getTypeDisplayName();
    final operatorStr = _getOperatorDisplayName();
    final valueStr = _getValueDisplayString();

    return '$typeStr $operatorStr $valueStr';
  }

  String _getTypeDisplayName() {
    switch (type) {
      case FilterType.descricao:
        return 'Descrição';
      case FilterType.quantidade:
        return 'Quantidade';
      case FilterType.dataCreated:
        return 'Data de Criação';
      case FilterType.grupo:
        return 'Grupo';
      case FilterType.coordenadas:
        return 'Coordenadas';
    }
  }

  String _getOperatorDisplayName() {
    switch (operator) {
      case FilterOperator.equals:
        return 'igual a';
      case FilterOperator.contains:
        return 'contém';
      case FilterOperator.startsWith:
        return 'inicia com';
      case FilterOperator.endsWith:
        return 'termina com';
      case FilterOperator.greaterThan:
        return 'maior que';
      case FilterOperator.lessThan:
        return 'menor que';
      case FilterOperator.between:
        return 'entre';
      case FilterOperator.isEmpty:
        return 'está vazio';
      case FilterOperator.isNotEmpty:
        return 'não está vazio';
    }
  }

  String _getValueDisplayString() {
    if (value == null) return '';

    if (operator == FilterOperator.between && secondValue != null) {
      return '$value e $secondValue';
    }

    if (operator == FilterOperator.isEmpty ||
        operator == FilterOperator.isNotEmpty) {
      return '';
    }

    if (type == FilterType.dataCreated && value is DateTime) {
      final date = value as DateTime;
      return '${date.day}/${date.month}/${date.year}';
    }

    return value.toString();
  }
}

/// Modelo para conjunto de filtros
class FilterSet {
  final List<FilterCriteria> filters;
  final String? searchQuery;
  final bool combineWithAnd; // true = AND, false = OR

  const FilterSet({
    this.filters = const [],
    this.searchQuery,
    this.combineWithAnd = true,
  });

  FilterSet copyWith({
    List<FilterCriteria>? filters,
    String? searchQuery,
    bool? combineWithAnd,
  }) {
    return FilterSet(
      filters: filters ?? this.filters,
      searchQuery: searchQuery,
      combineWithAnd: combineWithAnd ?? this.combineWithAnd,
    );
  }

  /// Aplica todos os filtros a uma lista de pluviômetros
  List<Pluviometro> applyFilters(List<Pluviometro> pluviometros) {
    List<Pluviometro> result = pluviometros;

    // Aplicar busca por texto primeiro
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      result =
          result.where((p) => _matchesSearchQuery(p, searchQuery!)).toList();
    }

    // Aplicar filtros
    if (filters.isNotEmpty) {
      result = result.where((pluviometro) {
        final activeFilters = filters.where((f) => f.isActive).toList();
        if (activeFilters.isEmpty) return true;

        if (combineWithAnd) {
          return activeFilters.every((filter) => filter.apply(pluviometro));
        } else {
          return activeFilters.any((filter) => filter.apply(pluviometro));
        }
      }).toList();
    }

    return result;
  }

  bool _matchesSearchQuery(Pluviometro pluviometro, String query) {
    final searchTerms = query.toLowerCase().split(' ');
    final searchableText = [
      pluviometro.descricao,
      pluviometro.quantidade,
      pluviometro.fkGrupo ?? '',
      pluviometro.latitude ?? '',
      pluviometro.longitude ?? '',
    ].join(' ').toLowerCase();

    return searchTerms.every((term) => searchableText.contains(term));
  }

  /// Verifica se existem filtros ativos
  bool get hasActiveFilters {
    return (searchQuery != null && searchQuery!.isNotEmpty) ||
        filters.any((f) => f.isActive);
  }

  /// Obtém contagem de filtros ativos
  int get activeFilterCount {
    int count = 0;
    if (searchQuery != null && searchQuery!.isNotEmpty) count++;
    count += filters.where((f) => f.isActive).length;
    return count;
  }

  /// Limpa todos os filtros
  FilterSet clearAll() {
    return FilterSet(
      filters: filters.map((f) => f.copyWith(isActive: false)).toList(),
      searchQuery: null,
      combineWithAnd: combineWithAnd,
    );
  }
}

/// Filtros predefinidos comuns
class PresetFilters {
  static const FilterCriteria quantidadeAlta = FilterCriteria(
    type: FilterType.quantidade,
    operator: FilterOperator.greaterThan,
    value: 50.0,
  );

  static const FilterCriteria quantidadeBaixa = FilterCriteria(
    type: FilterType.quantidade,
    operator: FilterOperator.lessThan,
    value: 10.0,
  );

  static const FilterCriteria semCoordenadas = FilterCriteria(
    type: FilterType.coordenadas,
    operator: FilterOperator.isEmpty,
    value: null,
  );

  static const FilterCriteria comCoordenadas = FilterCriteria(
    type: FilterType.coordenadas,
    operator: FilterOperator.isNotEmpty,
    value: null,
  );

  static FilterCriteria criadosRecentemente() {
    final oneDayAgo = DateTime.now().subtract(const Duration(days: 1));
    return FilterCriteria(
      type: FilterType.dataCreated,
      operator: FilterOperator.greaterThan,
      value: oneDayAgo,
    );
  }

  static FilterCriteria criadosUltimaSemana() {
    final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
    return FilterCriteria(
      type: FilterType.dataCreated,
      operator: FilterOperator.greaterThan,
      value: oneWeekAgo,
    );
  }

  static FilterCriteria quantidadeEntre(double min, double max) {
    return FilterCriteria(
      type: FilterType.quantidade,
      operator: FilterOperator.between,
      value: min,
      secondValue: max,
    );
  }
}

/// Configuração de ordenação
enum SortType {
  descricao,
  quantidade,
  dataCreated,
  dataUpdated,
}

enum SortDirection {
  ascending,
  descending,
}

class SortConfiguration {
  final SortType type;
  final SortDirection direction;

  const SortConfiguration({
    required this.type,
    required this.direction,
  });

  SortConfiguration copyWith({
    SortType? type,
    SortDirection? direction,
  }) {
    return SortConfiguration(
      type: type ?? this.type,
      direction: direction ?? this.direction,
    );
  }

  /// Aplica ordenação a uma lista de pluviômetros
  List<Pluviometro> applySort(List<Pluviometro> pluviometros) {
    final sorted = List<Pluviometro>.from(pluviometros);

    sorted.sort((a, b) {
      int comparison;

      switch (type) {
        case SortType.descricao:
          comparison = a.descricao.compareTo(b.descricao);
          break;
        case SortType.quantidade:
          comparison =
              a.getQuantidadeAsDouble().compareTo(b.getQuantidadeAsDouble());
          break;
        case SortType.dataCreated:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case SortType.dataUpdated:
          comparison = a.updatedAt.compareTo(b.updatedAt);
          break;
      }

      return direction == SortDirection.ascending ? comparison : -comparison;
    });

    return sorted;
  }

  String toDisplayString() {
    final typeStr = _getTypeDisplayName();
    final directionStr =
        direction == SortDirection.ascending ? 'Crescente' : 'Decrescente';
    return '$typeStr ($directionStr)';
  }

  String _getTypeDisplayName() {
    switch (type) {
      case SortType.descricao:
        return 'Descrição';
      case SortType.quantidade:
        return 'Quantidade';
      case SortType.dataCreated:
        return 'Data de Criação';
      case SortType.dataUpdated:
        return 'Data de Atualização';
    }
  }
}
