import '../entities/expense_entity.dart';

/// Configuração de filtros para despesas
class ExpenseFiltersConfig {
  final String? vehicleId;
  final ExpenseType? type;
  final DateTime? startDate;
  final DateTime? endDate;
  final String searchQuery;
  final String sortBy;
  final bool sortAscending;

  const ExpenseFiltersConfig({
    this.vehicleId,
    this.type,
    this.startDate,
    this.endDate,
    this.searchQuery = '',
    this.sortBy = 'date',
    this.sortAscending = false,
  });

  /// Cria nova configuração com valores atualizados
  ExpenseFiltersConfig copyWith({
    String? vehicleId,
    ExpenseType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    String? sortBy,
    bool? sortAscending,
    bool clearVehicleId = false,
    bool clearType = false,
    bool clearDates = false,
  }) {
    return ExpenseFiltersConfig(
      vehicleId: clearVehicleId ? null : (vehicleId ?? this.vehicleId),
      type: clearType ? null : (type ?? this.type),
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }

  /// Verifica se há filtros ativos
  bool get hasActiveFilters {
    return vehicleId != null || 
           type != null || 
           startDate != null || 
           endDate != null || 
           searchQuery.isNotEmpty;
  }

  /// Limpa todos os filtros
  ExpenseFiltersConfig cleared() {
    return const ExpenseFiltersConfig();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpenseFiltersConfig &&
           other.vehicleId == vehicleId &&
           other.type == type &&
           other.startDate == startDate &&
           other.endDate == endDate &&
           other.searchQuery == searchQuery &&
           other.sortBy == sortBy &&
           other.sortAscending == sortAscending;
  }

  @override
  int get hashCode {
    return Object.hash(
      vehicleId,
      type,
      startDate,
      endDate,
      searchQuery,
      sortBy,
      sortAscending,
    );
  }
}

/// Serviço especializado para filtrar e ordenar despesas
class ExpenseFiltersService {
  /// Aplica filtros e ordenação à lista de despesas
  List<ExpenseEntity> applyFilters(
    List<ExpenseEntity> expenses,
    ExpenseFiltersConfig config,
  ) {
    var filtered = List<ExpenseEntity>.from(expenses);

    // Aplicar filtros
    filtered = _applyAllFilters(filtered, config);

    // Aplicar ordenação
    filtered = _applySort(filtered, config.sortBy, config.sortAscending);

    return filtered;
  }

  /// Aplica todos os filtros
  List<ExpenseEntity> _applyAllFilters(
    List<ExpenseEntity> expenses,
    ExpenseFiltersConfig config,
  ) {
    return expenses.where((expense) {
      // Filtro por veículo
      if (config.vehicleId != null && expense.vehicleId != config.vehicleId) {
        return false;
      }

      // Filtro por tipo
      if (config.type != null && expense.type != config.type) {
        return false;
      }

      // Filtro por período
      if (config.startDate != null) {
        final startOfDay = DateTime(
          config.startDate!.year,
          config.startDate!.month,
          config.startDate!.day,
        );
        if (expense.date.isBefore(startOfDay)) return false;
      }
      
      if (config.endDate != null) {
        final endOfDay = DateTime(
          config.endDate!.year,
          config.endDate!.month,
          config.endDate!.day,
          23,
          59,
          59,
        );
        if (expense.date.isAfter(endOfDay)) return false;
      }

      // Filtro por busca de texto
      if (config.searchQuery.isNotEmpty) {
        final query = config.searchQuery.toLowerCase();
        if (!expense.title.toLowerCase().contains(query) &&
            !expense.description.toLowerCase().contains(query) &&
            !expense.type.displayName.toLowerCase().contains(query) &&
            (!expense.establishmentName.toLowerCase().contains(query)) &&
            (expense.notes == null || !expense.notes!.toLowerCase().contains(query))) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Aplica ordenação
  List<ExpenseEntity> _applySort(
    List<ExpenseEntity> expenses,
    String sortBy,
    bool sortAscending,
  ) {
    expenses.sort((a, b) {
      int comparison = 0;
      
      switch (sortBy) {
        case 'date':
          comparison = a.date.compareTo(b.date);
          break;
        case 'amount':
          comparison = a.amount.compareTo(b.amount);
          break;
        case 'type':
          comparison = a.type.displayName.compareTo(b.type.displayName);
          break;
        case 'odometer':
          comparison = a.odometer.compareTo(b.odometer);
          break;
        case 'title':
          comparison = a.title.compareTo(b.title);
          break;
        case 'establishment':
          final aName = a.establishmentName ?? '';
          final bName = b.establishmentName ?? '';
          comparison = aName.compareTo(bName);
          break;
        default:
          comparison = a.date.compareTo(b.date);
      }

      return sortAscending ? comparison : -comparison;
    });

    return expenses;
  }

  /// Filtra por veículo específico
  List<ExpenseEntity> filterByVehicle(
    List<ExpenseEntity> expenses,
    String vehicleId,
  ) {
    return expenses.where((e) => e.vehicleId == vehicleId).toList();
  }

  /// Filtra por tipo específico
  List<ExpenseEntity> filterByType(
    List<ExpenseEntity> expenses,
    ExpenseType type,
  ) {
    return expenses.where((e) => e.type == type).toList();
  }

  /// Filtra por período
  List<ExpenseEntity> filterByPeriod(
    List<ExpenseEntity> expenses,
    DateTime start,
    DateTime end,
  ) {
    final startOfDay = DateTime(start.year, start.month, start.day);
    final endOfDay = DateTime(end.year, end.month, end.day, 23, 59, 59);
    
    return expenses.where((e) {
      return e.date.isAfter(startOfDay.subtract(const Duration(milliseconds: 1))) &&
             e.date.isBefore(endOfDay.add(const Duration(milliseconds: 1)));
    }).toList();
  }

  /// Busca por texto
  List<ExpenseEntity> searchByText(
    List<ExpenseEntity> expenses,
    String query,
  ) {
    if (query.isEmpty) return expenses;
    
    final lowerQuery = query.toLowerCase();
    return expenses.where((e) {
      return e.title.toLowerCase().contains(lowerQuery) ||
             e.description.toLowerCase().contains(lowerQuery) ||
             e.type.displayName.toLowerCase().contains(lowerQuery) ||
             (e.establishmentName.toLowerCase().contains(lowerQuery) == true) ||
             (e.notes?.toLowerCase().contains(lowerQuery) == true);
    }).toList();
  }

  /// Obtém despesas de alto valor (acima do threshold)
  List<ExpenseEntity> getHighValueExpenses(
    List<ExpenseEntity> expenses,
    {double threshold = ExpenseConstants.reportAmountThousands}
  ) {
    return expenses.where((e) => e.amount >= threshold).toList();
  }

  /// Obtém despesas recorrentes (mesmo tipo e valor similar)
  List<ExpenseEntity> getRecurringExpenses(
    List<ExpenseEntity> expenses,
    {double amountTolerance = 0.1} // 10% de tolerância
  ) {
    final recurring = <ExpenseEntity>[];
    
    for (int i = 0; i < expenses.length; i++) {
      final expense = expenses[i];
      final similar = expenses.where((e) {
        if (e.id == expense.id) return false;
        
        final amountDiff = (e.amount - expense.amount).abs();
        final toleranceAmount = expense.amount * amountTolerance;
        
        return e.type == expense.type &&
               e.vehicleId == expense.vehicleId &&
               amountDiff <= toleranceAmount;
      }).toList();
      
      if (similar.isNotEmpty && !recurring.contains(expense)) {
        recurring.add(expense);
      }
    }
    
    return recurring;
  }

  /// Obtém despesas por faixa de valores
  Map<String, List<ExpenseEntity>> groupByValueRange(
    List<ExpenseEntity> expenses,
  ) {
    final ranges = <String, List<ExpenseEntity>>{
      'Até R\$ 100': [],
      'R\$ 100 - R\$ 500': [],
      'R\$ 500 - R\$ 1.000': [],
      'R\$ 1.000 - R\$ 5.000': [],
      'Acima de R\$ 5.000': [],
    };
    
    for (final expense in expenses) {
      if (expense.amount <= 100) {
        ranges['Até R\$ 100']!.add(expense);
      } else if (expense.amount <= 500) {
        ranges['R\$ 100 - R\$ 500']!.add(expense);
      } else if (expense.amount <= 1000) {
        ranges['R\$ 500 - R\$ 1.000']!.add(expense);
      } else if (expense.amount <= 5000) {
        ranges['R\$ 1.000 - R\$ 5.000']!.add(expense);
      } else {
        ranges['Acima de R\$ 5.000']!.add(expense);
      }
    }
    
    return ranges;
  }

  /// Obtém despesas agrupadas por mês
  Map<String, List<ExpenseEntity>> groupByMonth(
    List<ExpenseEntity> expenses,
  ) {
    final grouped = <String, List<ExpenseEntity>>{};
    
    for (final expense in expenses) {
      final key = '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(expense);
    }
    
    return grouped;
  }

  /// Obtém despesas agrupadas por tipo
  Map<ExpenseType, List<ExpenseEntity>> groupByType(
    List<ExpenseEntity> expenses,
  ) {
    final grouped = <ExpenseType, List<ExpenseEntity>>{};
    
    for (final expense in expenses) {
      if (!grouped.containsKey(expense.type)) {
        grouped[expense.type] = [];
      }
      grouped[expense.type]!.add(expense);
    }
    
    return grouped;
  }

  /// Opções de ordenação disponíveis
  static const List<String> sortOptions = [
    'date',
    'amount',
    'type',
    'odometer',
    'title',
    'establishment',
  ];

  /// Labels para as opções de ordenação
  static const Map<String, String> sortLabels = {
    'date': 'Data',
    'amount': 'Valor',
    'type': 'Tipo',
    'odometer': 'Odômetro',
    'title': 'Título',
    'establishment': 'Estabelecimento',
  };
}