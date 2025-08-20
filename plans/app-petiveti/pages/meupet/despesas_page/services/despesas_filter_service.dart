// Project imports:
import '../../../../models/13_despesa_model.dart';

enum DespesaSortBy {
  data,
  valor,
  tipo,
  descricao,
}

enum SortOrder {
  ascending,
  descending,
}

class DespesasFilterService {
  List<DespesaVet> applyFilters({
    required List<DespesaVet> despesas,
    String? searchText,
    DateTime? dataInicial,
    DateTime? dataFinal,
    String? tipoFilter,
    double? valorMinimo,
    double? valorMaximo,
  }) {
    List<DespesaVet> filtered = List.from(despesas);

    // Filtro por texto de busca
    if (searchText != null && searchText.isNotEmpty) {
      filtered = filterBySearchText(filtered, searchText);
    }

    // Filtro por range de datas
    if (dataInicial != null && dataFinal != null) {
      filtered = filterByDateRange(filtered, dataInicial, dataFinal);
    }

    // Filtro por tipo
    if (tipoFilter != null && tipoFilter.isNotEmpty) {
      filtered = filterByTipo(filtered, tipoFilter);
    }

    // Filtro por valor mínimo
    if (valorMinimo != null) {
      filtered = filterByValorMinimo(filtered, valorMinimo);
    }

    // Filtro por valor máximo
    if (valorMaximo != null) {
      filtered = filterByValorMaximo(filtered, valorMaximo);
    }

    return filtered;
  }

  List<DespesaVet> filterBySearchText(List<DespesaVet> despesas, String query) {
    if (query.isEmpty) return despesas;
    
    final lowercaseQuery = query.toLowerCase();
    return despesas.where((despesa) {
      return despesa.descricao.toLowerCase().contains(lowercaseQuery) ||
             despesa.tipo.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  List<DespesaVet> filterByDateRange(
    List<DespesaVet> despesas,
    DateTime startDate,
    DateTime endDate,
  ) {
    return despesas.where((despesa) {
      final despesaDate = DateTime.fromMillisecondsSinceEpoch(despesa.dataDespesa);
      return despesaDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
             despesaDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  List<DespesaVet> filterByTipo(List<DespesaVet> despesas, String tipo) {
    return despesas.where((despesa) => despesa.tipo == tipo).toList();
  }

  List<DespesaVet> filterByValorMinimo(List<DespesaVet> despesas, double valorMinimo) {
    return despesas.where((despesa) => despesa.valor >= valorMinimo).toList();
  }

  List<DespesaVet> filterByValorMaximo(List<DespesaVet> despesas, double valorMaximo) {
    return despesas.where((despesa) => despesa.valor <= valorMaximo).toList();
  }

  List<DespesaVet> filterByPeriod(
    List<DespesaVet> despesas,
    DateTime startDate,
    DateTime endDate,
  ) {
    return filterByDateRange(despesas, startDate, endDate);
  }

  List<DespesaVet> filterByMonth(List<DespesaVet> despesas, DateTime month) {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);
    return filterByDateRange(despesas, startOfMonth, endOfMonth);
  }

  List<DespesaVet> filterByYear(List<DespesaVet> despesas, int year) {
    return despesas.where((despesa) {
      final data = DateTime.fromMillisecondsSinceEpoch(despesa.dataDespesa);
      return data.year == year;
    }).toList();
  }

  List<DespesaVet> filterByCurrentMonth(List<DespesaVet> despesas) {
    return filterByMonth(despesas, DateTime.now());
  }

  List<DespesaVet> filterByCurrentYear(List<DespesaVet> despesas) {
    return filterByYear(despesas, DateTime.now().year);
  }

  List<DespesaVet> filterByLastDays(List<DespesaVet> despesas, int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return despesas.where((despesa) {
      final data = DateTime.fromMillisecondsSinceEpoch(despesa.dataDespesa);
      return data.isAfter(cutoffDate);
    }).toList();
  }

  List<DespesaVet> filterByRecent(List<DespesaVet> despesas, {int days = 7}) {
    return filterByLastDays(despesas, days);
  }

  List<DespesaVet> filterByValueRange(
    List<DespesaVet> despesas,
    double minValue,
    double maxValue,
  ) {
    return despesas.where((despesa) {
      return despesa.valor >= minValue && despesa.valor <= maxValue;
    }).toList();
  }

  List<DespesaVet> sortDespesas(
    List<DespesaVet> despesas,
    DespesaSortBy sortBy, {
    SortOrder order = SortOrder.descending,
  }) {
    final sorted = List<DespesaVet>.from(despesas);
    final ascending = order == SortOrder.ascending;

    switch (sortBy) {
      case DespesaSortBy.data:
        sorted.sort((a, b) {
          final comparison = a.dataDespesa.compareTo(b.dataDespesa);
          return ascending ? comparison : -comparison;
        });
        break;
      case DespesaSortBy.valor:
        sorted.sort((a, b) {
          final comparison = a.valor.compareTo(b.valor);
          return ascending ? comparison : -comparison;
        });
        break;
      case DespesaSortBy.tipo:
        sorted.sort((a, b) {
          final comparison = a.tipo.compareTo(b.tipo);
          return ascending ? comparison : -comparison;
        });
        break;
      case DespesaSortBy.descricao:
        sorted.sort((a, b) {
          final comparison = a.descricao.compareTo(b.descricao);
          return ascending ? comparison : -comparison;
        });
        break;
    }

    return sorted;
  }

  List<DespesaVet> sortByDate(
    List<DespesaVet> despesas, {
    bool ascending = false,
  }) {
    return sortDespesas(
      despesas,
      DespesaSortBy.data,
      order: ascending ? SortOrder.ascending : SortOrder.descending,
    );
  }

  List<DespesaVet> sortByValue(
    List<DespesaVet> despesas, {
    bool ascending = false,
  }) {
    return sortDespesas(
      despesas,
      DespesaSortBy.valor,
      order: ascending ? SortOrder.ascending : SortOrder.descending,
    );
  }

  List<DespesaVet> sortByType(
    List<DespesaVet> despesas, {
    bool ascending = true,
  }) {
    return sortDespesas(
      despesas,
      DespesaSortBy.tipo,
      order: ascending ? SortOrder.ascending : SortOrder.descending,
    );
  }

  List<String> getAvailableTypes(List<DespesaVet> despesas) {
    return despesas.map((d) => d.tipo).toSet().toList()..sort();
  }

  Map<String, int> getTypeCount(List<DespesaVet> despesas) {
    final counts = <String, int>{};
    for (final despesa in despesas) {
      counts[despesa.tipo] = (counts[despesa.tipo] ?? 0) + 1;
    }
    return counts;
  }

  List<DespesaVet> getTopExpenses(
    List<DespesaVet> despesas, {
    int limit = 10,
  }) {
    return sortByValue(despesas, ascending: false).take(limit).toList();
  }

  List<DespesaVet> getRecentExpenses(
    List<DespesaVet> despesas, {
    int limit = 10,
  }) {
    return sortByDate(despesas, ascending: false).take(limit).toList();
  }

  double getTotalForPeriod(
    List<DespesaVet> despesas,
    DateTime startDate,
    DateTime endDate,
  ) {
    final filtered = filterByDateRange(despesas, startDate, endDate);
    return filtered.fold(0.0, (sum, despesa) => sum + despesa.valor);
  }

  Map<String, double> getMonthlyTotals(List<DespesaVet> despesas) {
    final monthlyTotals = <String, double>{};
    
    for (final despesa in despesas) {
      final data = DateTime.fromMillisecondsSinceEpoch(despesa.dataDespesa);
      final monthKey = '${data.month.toString().padLeft(2, '0')}/${data.year}';
      monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + despesa.valor;
    }
    
    return monthlyTotals;
  }

  Map<String, double> getYearlyTotals(List<DespesaVet> despesas) {
    final yearlyTotals = <String, double>{};
    
    for (final despesa in despesas) {
      final data = DateTime.fromMillisecondsSinceEpoch(despesa.dataDespesa);
      final yearKey = data.year.toString();
      yearlyTotals[yearKey] = (yearlyTotals[yearKey] ?? 0) + despesa.valor;
    }
    
    return yearlyTotals;
  }

  List<DespesaVet> getExpensesAboveAverage(List<DespesaVet> despesas) {
    if (despesas.isEmpty) return [];
    
    final total = despesas.fold(0.0, (sum, despesa) => sum + despesa.valor);
    final average = total / despesas.length;
    
    return despesas.where((despesa) => despesa.valor > average).toList();
  }

  List<DespesaVet> getExpensesBelowAverage(List<DespesaVet> despesas) {
    if (despesas.isEmpty) return [];
    
    final total = despesas.fold(0.0, (sum, despesa) => sum + despesa.valor);
    final average = total / despesas.length;
    
    return despesas.where((despesa) => despesa.valor < average).toList();
  }

  bool hasExpensesInPeriod(
    List<DespesaVet> despesas,
    DateTime startDate,
    DateTime endDate,
  ) {
    return filterByDateRange(despesas, startDate, endDate).isNotEmpty;
  }

  List<DespesaVet> searchByDescription(
    List<DespesaVet> despesas,
    String searchTerm,
  ) {
    if (searchTerm.isEmpty) return despesas;
    
    final lowercaseTerm = searchTerm.toLowerCase();
    return despesas.where((despesa) {
      return despesa.descricao.toLowerCase().contains(lowercaseTerm);
    }).toList();
  }

  List<DespesaVet> searchByType(
    List<DespesaVet> despesas,
    String searchTerm,
  ) {
    if (searchTerm.isEmpty) return despesas;
    
    final lowercaseTerm = searchTerm.toLowerCase();
    return despesas.where((despesa) {
      return despesa.tipo.toLowerCase().contains(lowercaseTerm);
    }).toList();
  }

  List<DespesaVet> combinedSearch(
    List<DespesaVet> despesas,
    String searchTerm,
  ) {
    if (searchTerm.isEmpty) return despesas;
    
    final lowercaseTerm = searchTerm.toLowerCase();
    return despesas.where((despesa) {
      return despesa.descricao.toLowerCase().contains(lowercaseTerm) ||
             despesa.tipo.toLowerCase().contains(lowercaseTerm);
    }).toList();
  }

  Map<String, List<DespesaVet>> groupByType(List<DespesaVet> despesas) {
    final grouped = <String, List<DespesaVet>>{};
    
    for (final despesa in despesas) {
      grouped.putIfAbsent(despesa.tipo, () => []).add(despesa);
    }
    
    return grouped;
  }

  Map<String, List<DespesaVet>> groupByMonth(List<DespesaVet> despesas) {
    final grouped = <String, List<DespesaVet>>{};
    
    for (final despesa in despesas) {
      final data = DateTime.fromMillisecondsSinceEpoch(despesa.dataDespesa);
      final monthKey = '${data.month.toString().padLeft(2, '0')}/${data.year}';
      grouped.putIfAbsent(monthKey, () => []).add(despesa);
    }
    
    return grouped;
  }
}
