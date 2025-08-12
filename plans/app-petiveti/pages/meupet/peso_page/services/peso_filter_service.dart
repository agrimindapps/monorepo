// Project imports:
import '../../../../models/17_peso_model.dart';
import '../models/peso_page_state.dart';

/// Service for filtering and sorting peso data
class PesoFilterService {
  
  /// Filter pesos based on search query and sort criteria
  List<PesoAnimal> filterPesos(
    List<PesoAnimal> pesos, {
    String searchQuery = '',
    PesoSortType sortType = PesoSortType.date,
    bool sortAscending = false,
    int? dataInicial,
    int? dataFinal,
    double? minPeso,
    double? maxPeso,
  }) {
    List<PesoAnimal> filtered = List.from(pesos);

    // Apply text search
    if (searchQuery.isNotEmpty) {
      filtered = _filterBySearchQuery(filtered, searchQuery);
    }

    // Apply date range filter
    if (dataInicial != null || dataFinal != null) {
      filtered = _filterByDateRange(filtered, dataInicial, dataFinal);
    }

    // Apply peso range filter
    if (minPeso != null || maxPeso != null) {
      filtered = _filterByPesoRange(filtered, minPeso, maxPeso);
    }

    // Apply sorting
    filtered = _sortPesos(filtered, sortType, sortAscending);

    return filtered;
  }

  /// Filter pesos by search query (observations, peso value)
  List<PesoAnimal> _filterBySearchQuery(List<PesoAnimal> pesos, String query) {
    final lowerQuery = query.toLowerCase();
    
    return pesos.where((peso) {
      // Search in observations
      if (peso.observacoes != null && 
          peso.observacoes!.toLowerCase().contains(lowerQuery)) {
        return true;
      }
      
      // Search in peso value
      if (peso.peso.toString().contains(lowerQuery)) {
        return true;
      }
      
      // Search in formatted peso
      if ('${peso.peso.toStringAsFixed(1)} kg'.toLowerCase().contains(lowerQuery)) {
        return true;
      }
      
      return false;
    }).toList();
  }

  /// Filter pesos by date range
  List<PesoAnimal> _filterByDateRange(
    List<PesoAnimal> pesos,
    int? dataInicial,
    int? dataFinal,
  ) {
    return pesos.where((peso) {
      if (dataInicial != null && peso.dataPesagem < dataInicial) {
        return false;
      }
      
      if (dataFinal != null && peso.dataPesagem > dataFinal) {
        return false;
      }
      
      return true;
    }).toList();
  }

  /// Filter pesos by weight range
  List<PesoAnimal> _filterByPesoRange(
    List<PesoAnimal> pesos,
    double? minPeso,
    double? maxPeso,
  ) {
    return pesos.where((peso) {
      if (minPeso != null && peso.peso < minPeso) {
        return false;
      }
      
      if (maxPeso != null && peso.peso > maxPeso) {
        return false;
      }
      
      return true;
    }).toList();
  }

  /// Sort pesos by specified criteria
  List<PesoAnimal> _sortPesos(
    List<PesoAnimal> pesos,
    PesoSortType sortType,
    bool ascending,
  ) {
    final sorted = List<PesoAnimal>.from(pesos);
    
    switch (sortType) {
      case PesoSortType.date:
        sorted.sort((a, b) => a.dataPesagem.compareTo(b.dataPesagem));
        break;
        
      case PesoSortType.weight:
        sorted.sort((a, b) => a.peso.compareTo(b.peso));
        break;
        
      case PesoSortType.animalName:
        // This would need animal name lookup, for now sort by animal ID
        sorted.sort((a, b) => a.animalId.compareTo(b.animalId));
        break;
    }
    
    return ascending ? sorted : sorted.reversed.toList();
  }

  /// Get available sort options
  List<SortOption> getSortOptions() {
    return [
      const SortOption(
        type: PesoSortType.date,
        label: 'Data de Pesagem',
        icon: 'calendar',
      ),
      const SortOption(
        type: PesoSortType.weight,
        label: 'Peso',
        icon: 'scale',
      ),
      const SortOption(
        type: PesoSortType.animalName,
        label: 'Nome do Animal',
        icon: 'pet',
      ),
    ];
  }

  /// Get filter summary text
  String getFilterSummary({
    String searchQuery = '',
    int? dataInicial,
    int? dataFinal,
    double? minPeso,
    double? maxPeso,
    PesoSortType sortType = PesoSortType.date,
    bool sortAscending = false,
  }) {
    final filters = <String>[];

    if (searchQuery.isNotEmpty) {
      filters.add('Busca: "$searchQuery"');
    }

    if (dataInicial != null || dataFinal != null) {
      final start = dataInicial != null 
          ? _formatDate(dataInicial) 
          : 'início';
      final end = dataFinal != null 
          ? _formatDate(dataFinal) 
          : 'hoje';
      filters.add('Período: $start - $end');
    }

    if (minPeso != null || maxPeso != null) {
      final min = minPeso?.toStringAsFixed(1) ?? '0';
      final max = maxPeso?.toStringAsFixed(1) ?? '∞';
      filters.add('Peso: ${min}kg - ${max}kg');
    }

    final sortDirection = sortAscending ? 'crescente' : 'decrescente';
    final sortLabel = _getSortLabel(sortType);
    filters.add('Ordem: $sortLabel ($sortDirection)');

    return filters.join(' • ');
  }

  /// Check if any filters are active
  bool hasActiveFilters({
    String searchQuery = '',
    int? dataInicial,
    int? dataFinal,
    double? minPeso,
    double? maxPeso,
  }) {
    return searchQuery.isNotEmpty ||
           dataInicial != null ||
           dataFinal != null ||
           minPeso != null ||
           maxPeso != null;
  }

  /// Group pesos by date range
  Map<String, List<PesoAnimal>> groupPesosByPeriod(
    List<PesoAnimal> pesos,
    PeriodGrouping grouping,
  ) {
    final groups = <String, List<PesoAnimal>>{};
    
    for (final peso in pesos) {
      final date = DateTime.fromMillisecondsSinceEpoch(peso.dataPesagem);
      final key = _getGroupKey(date, grouping);
      
      groups.putIfAbsent(key, () => []).add(peso);
    }
    
    return groups;
  }

  /// Get peso statistics for filtered data
  FilterStatistics getFilterStatistics(List<PesoAnimal> pesos) {
    if (pesos.isEmpty) {
      return FilterStatistics.empty();
    }

    final weights = pesos.map((p) => p.peso).toList();
    weights.sort();

    final sum = weights.reduce((a, b) => a + b);
    final average = sum / weights.length;
    final min = weights.first;
    final max = weights.last;

    // Get date range
    final dates = pesos.map((p) => p.dataPesagem).toList();
    dates.sort();
    final earliestDate = dates.first;
    final latestDate = dates.last;

    return FilterStatistics(
      totalRecords: pesos.length,
      averageWeight: average,
      minWeight: min,
      maxWeight: max,
      dateRange: DateRange(earliestDate, latestDate),
    );
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getSortLabel(PesoSortType sortType) {
    switch (sortType) {
      case PesoSortType.date:
        return 'Data';
      case PesoSortType.weight:
        return 'Peso';
      case PesoSortType.animalName:
        return 'Animal';
    }
  }

  String _getGroupKey(DateTime date, PeriodGrouping grouping) {
    switch (grouping) {
      case PeriodGrouping.daily:
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      case PeriodGrouping.weekly:
        final weekOfYear = _getWeekOfYear(date);
        return 'Semana $weekOfYear/${date.year}';
      case PeriodGrouping.monthly:
        return '${date.month.toString().padLeft(2, '0')}/${date.year}';
      case PeriodGrouping.yearly:
        return date.year.toString();
    }
  }

  int _getWeekOfYear(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }
}

/// Sort option configuration
class SortOption {
  final PesoSortType type;
  final String label;
  final String icon;

  const SortOption({
    required this.type,
    required this.label,
    required this.icon,
  });
}

/// Period grouping options
enum PeriodGrouping {
  daily,
  weekly,
  monthly,
  yearly,
}

/// Filter statistics
class FilterStatistics {
  final int totalRecords;
  final double averageWeight;
  final double minWeight;
  final double maxWeight;
  final DateRange dateRange;

  const FilterStatistics({
    required this.totalRecords,
    required this.averageWeight,
    required this.minWeight,
    required this.maxWeight,
    required this.dateRange,
  });

  factory FilterStatistics.empty() {
    return const FilterStatistics(
      totalRecords: 0,
      averageWeight: 0,
      minWeight: 0,
      maxWeight: 0,
      dateRange: DateRange(0, 0),
    );
  }
}

/// Date range helper
class DateRange {
  final int start;
  final int end;

  const DateRange(this.start, this.end);

  Duration get duration {
    return DateTime.fromMillisecondsSinceEpoch(end)
        .difference(DateTime.fromMillisecondsSinceEpoch(start));
  }

  int get durationInDays => duration.inDays;
}
