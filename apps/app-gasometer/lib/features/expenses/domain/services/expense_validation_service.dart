import '../entities/expense_entity.dart';
import '../../../vehicles/domain/entities/vehicle_entity.dart';
import '../../core/constants/expense_constants.dart';

/// Serviço avançado para validação contextual de registros de despesas
class ExpenseValidationService {
  static final ExpenseValidationService _instance = ExpenseValidationService._internal();
  factory ExpenseValidationService() => _instance;
  ExpenseValidationService._internal();

  /// Valida consistência entre registros de despesas
  ValidationResult validateExpenseRecord(
    ExpenseEntity record,
    VehicleEntity vehicle,
    List<ExpenseEntity> previousExpenses,
  ) {
    final errors = <String, String>{};
    final warnings = <String, String>{};

    // Validar compatibilidade com o veículo
    _validateVehicleCompatibility(record, vehicle, errors);

    // Validar sequência de odômetro
    _validateOdometerSequence(record, vehicle, previousExpenses, errors, warnings);

    // Validar padrões de valor por tipo
    _validateValuePatterns(record, previousExpenses, warnings);

    // Validar duplicatas por data e tipo
    _validateDuplicates(record, previousExpenses, errors, warnings);

    // Validar frequência de despesas recorrentes
    _validateRecurringExpenses(record, previousExpenses, warnings);

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Valida compatibilidade entre registro e veículo
  void _validateVehicleCompatibility(
    ExpenseEntity record,
    VehicleEntity vehicle,
    Map<String, String> errors,
  ) {
    // Verificar se o veículo está ativo
    if (!vehicle.isActive) {
      errors['vehicle'] = 'Veículo está inativo';
    }

    // Verificar se o odômetro não regrediu muito
    if (record.odometer < vehicle.currentOdometer - 1000) {
      errors['odometer'] = 
          'Odômetro muito abaixo do atual do veículo (${vehicle.currentOdometer.toStringAsFixed(0)} km)';
    }
  }

  /// Valida sequência lógica do odômetro
  void _validateOdometerSequence(
    ExpenseEntity record,
    VehicleEntity vehicle,
    List<ExpenseEntity> previousExpenses,
    Map<String, String> errors,
    Map<String, String> warnings,
  ) {
    if (previousExpenses.isEmpty) return;

    // Ordenar por data para encontrar o registro mais próximo
    final sortedExpenses = List<ExpenseEntity>.from(previousExpenses)
      ..sort((a, b) => b.date.compareTo(a.date));

    final lastExpense = sortedExpenses.first;

    // Verificar se odômetro não regrediu
    if (record.odometer < lastExpense.odometer) {
      errors['odometer'] = 
          'Odômetro menor que a última despesa (${lastExpense.odometer.toStringAsFixed(0)} km)';
      return;
    }

    // Verificar diferença suspeita
    final difference = record.odometer - lastExpense.odometer;
    final daysDifference = record.date.difference(lastExpense.date).inDays.abs();

    if (difference > ExpenseConstants.maxOdometerDifference) {
      warnings['odometer'] = 
          'Diferença muito grande desde última despesa: ${difference.toStringAsFixed(0)} km';
    }

    // Alertar para rodagem muito alta em pouco tempo
    if (daysDifference > 0 && daysDifference < 30 && difference / daysDifference > 300) {
      warnings['odometer'] = 
          'Média diária muito alta: ${(difference / daysDifference).toStringAsFixed(0)} km/dia';
    }
  }

  /// Valida padrões de valor por tipo de despesa
  void _validateValuePatterns(
    ExpenseEntity record,
    List<ExpenseEntity> previousExpenses,
    Map<String, String> warnings,
  ) {
    final sameType = previousExpenses.where((expense) => 
        expense.type == record.type && 
        expense.id != record.id
    ).toList();

    if (sameType.isEmpty) return;

    // Para despesas recorrentes, verificar se o valor está muito diferente da média
    if (record.type.isRecurring && sameType.length >= 2) {
      final avgAmount = sameType.fold<double>(0, (sum, expense) => sum + expense.amount) / sameType.length;
      final variation = (record.amount - avgAmount).abs() / avgAmount;

      if (variation > ExpenseConstants.maxAmountVariationPercent) {
        final percentDiff = (variation * 100).toStringAsFixed(0);
        warnings['amount'] = 
            'Valor ${record.amount > avgAmount ? 'acima' : 'abaixo'} da média ($percentDiff% de diferença)';
      }
    }

    // Verificar valores extremos por categoria
    final typeProperties = record.type.properties;
    if (typeProperties.maxExpectedValue != null && record.amount > typeProperties.maxExpectedValue!) {
      warnings['amount'] = 
          'Valor alto para ${record.type.displayName} (esperado até R\$ ${typeProperties.maxExpectedValue!.toStringAsFixed(2)})';
    }
    if (typeProperties.minExpectedValue != null && record.amount < typeProperties.minExpectedValue!) {
      warnings['amount'] = 
          'Valor baixo para ${record.type.displayName} (esperado mínimo R\$ ${typeProperties.minExpectedValue!.toStringAsFixed(2)})';
    }
  }

  /// Valida duplicatas por data e tipo
  void _validateDuplicates(
    ExpenseEntity record,
    List<ExpenseEntity> previousExpenses,
    Map<String, String> errors,
    Map<String, String> warnings,
  ) {
    final sameDate = previousExpenses.where((expense) => 
        expense.type == record.type &&
        expense.date.day == record.date.day &&
        expense.date.month == record.date.month &&
        expense.date.year == record.date.year &&
        expense.id != record.id
    );

    if (sameDate.isNotEmpty) {
      // Para despesas não recorrentes, isso pode ser um erro
      if (!record.type.isRecurring) {
        warnings['date'] = 
            'Já existe despesa de ${record.type.displayName} nesta data';
      }
      
      // Para despesas de mesmo tipo, valor e data, pode ser duplicata
      final exactDuplicates = sameDate.where((expense) => 
          (expense.amount - record.amount).abs() < 0.01 &&
          expense.description.toLowerCase() == record.description.toLowerCase()
      );
      
      if (exactDuplicates.isNotEmpty) {
        errors['duplicate'] = 'Possível despesa duplicada encontrada';
      }
    }
  }

  /// Valida frequência de despesas recorrentes
  void _validateRecurringExpenses(
    ExpenseEntity record,
    List<ExpenseEntity> previousExpenses,
    Map<String, String> warnings,
  ) {
    if (!record.type.isRecurring) return;

    final sameType = previousExpenses.where((expense) => 
        expense.type == record.type &&
        expense.id != record.id
    ).toList();

    if (sameType.isEmpty) return;

    // Ordenar por data
    sameType.sort((a, b) => b.date.compareTo(a.date));
    final lastSameType = sameType.first;

    final monthsDifference = _calculateMonthsDifference(record.date, lastSameType.date);

    // Alertas baseados no tipo de despesa
    switch (record.type) {
      case ExpenseType.insurance:
        if (monthsDifference < 11) {
          warnings['frequency'] = 'Seguro registrado há menos de 1 ano';
        }
        break;
      
      case ExpenseType.ipva:
        if (monthsDifference < 11) {
          warnings['frequency'] = 'IPVA registrado há menos de 1 ano';
        }
        break;
      
      case ExpenseType.licensing:
        if (monthsDifference < 11) {
          warnings['frequency'] = 'Licenciamento registrado há menos de 1 ano';
        }
        break;
      
      default:
        break;
    }
  }

  /// Análise de padrões de despesas para um veículo
  ExpensePatternAnalysis analyzeExpensePatterns(
    List<ExpenseEntity> expenses,
    VehicleEntity vehicle,
  ) {
    if (expenses.isEmpty) {
      return ExpensePatternAnalysis.empty();
    }

    final sortedExpenses = List<ExpenseEntity>.from(expenses)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Calcular estatísticas gerais
    final totalAmount = sortedExpenses.fold<double>(0, (sum, e) => sum + e.amount);
    final averageAmount = totalAmount / sortedExpenses.length;
    
    // Agrupar por tipo
    final expensesByType = <ExpenseType, List<ExpenseEntity>>{};
    for (final expense in sortedExpenses) {
      expensesByType.putIfAbsent(expense.type, () => []).add(expense);
    }

    // Calcular gastos por tipo
    final expensesByTypeAmount = expensesByType.map(
      (type, expenses) => MapEntry(
        type, 
        expenses.fold<double>(0, (sum, e) => sum + e.amount)
      )
    );

    // Detectar anomalias
    final anomalies = _detectExpenseAnomalies(sortedExpenses);

    // Calcular tendências
    final trends = _calculateExpenseTrends(sortedExpenses);

    return ExpensePatternAnalysis(
      totalRecords: sortedExpenses.length,
      totalAmount: totalAmount,
      averageAmount: averageAmount,
      expensesByType: expensesByTypeAmount,
      anomalies: anomalies,
      trends: trends,
      lastExpense: sortedExpenses.last,
      firstExpense: sortedExpenses.first,
      period: sortedExpenses.last.date.difference(sortedExpenses.first.date),
    );
  }

  /// Detecta anomalias nos registros de despesas
  List<ExpenseAnomaly> _detectExpenseAnomalies(List<ExpenseEntity> expenses) {
    final anomalies = <ExpenseAnomaly>[];
    
    // Calcular médias por tipo
    final typeAverages = <ExpenseType, double>{};
    final typeGroups = <ExpenseType, List<ExpenseEntity>>{};
    
    for (final expense in expenses) {
      typeGroups.putIfAbsent(expense.type, () => []).add(expense);
    }
    
    typeGroups.forEach((type, expenses) {
      typeAverages[type] = expenses.fold<double>(0, (sum, e) => sum + e.amount) / expenses.length;
    });

    // Detectar outliers de valor
    for (final expense in expenses) {
      final average = typeAverages[expense.type]!;
      final deviation = (expense.amount - average).abs() / average;
      
      if (deviation > 1.0) { // Mais de 100% de desvio
        anomalies.add(ExpenseAnomaly(
          expenseId: expense.id,
          type: AnomalyType.valueOutlier,
          description: 'Valor muito ${expense.amount > average ? 'alto' : 'baixo'} '
                      'para ${expense.type.displayName} (${deviation.toStringAsFixed(1)}x da média)',
          severity: deviation > 2.0 ? AnomalySeverity.high : AnomalySeverity.medium,
        ));
      }
    }

    // Detectar frequência anômala
    final recurringTypes = expenses.where((e) => e.type.isRecurring).toList();
    final frequencyMap = <ExpenseType, List<ExpenseEntity>>{};
    
    for (final expense in recurringTypes) {
      frequencyMap.putIfAbsent(expense.type, () => []).add(expense);
    }
    
    frequencyMap.forEach((type, typeExpenses) {
      if (typeExpenses.length < 2) return;
      
      typeExpenses.sort((a, b) => a.date.compareTo(b.date));
      
      for (int i = 1; i < typeExpenses.length; i++) {
        final monthsDiff = _calculateMonthsDifference(
          typeExpenses[i].date, 
          typeExpenses[i-1].date
        );
        
        if (monthsDiff < 6) { // Menos de 6 meses entre despesas anuais
          anomalies.add(ExpenseAnomaly(
            expenseId: typeExpenses[i].id,
            type: AnomalyType.frequencyAnomaly,
            description: 'Despesa recorrente registrada muito cedo (${monthsDiff} meses)',
            severity: AnomalySeverity.medium,
          ));
        }
      }
    });

    return anomalies;
  }

  /// Calcula tendências de gastos
  Map<String, dynamic> _calculateExpenseTrends(List<ExpenseEntity> expenses) {
    if (expenses.length < 2) return {};

    // Agrupar por mês
    final monthlyTotals = <String, double>{};
    
    for (final expense in expenses) {
      final monthKey = '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + expense.amount;
    }

    final months = monthlyTotals.keys.toList()..sort();
    if (months.length < 2) return {};

    // Calcular tendência (simples: comparar últimos 3 meses com 3 anteriores)
    final recentMonths = months.length >= 6 ? months.sublist(months.length - 3) : months.sublist((months.length / 2).ceil());
    final olderMonths = months.length >= 6 ? months.sublist(months.length - 6, months.length - 3) : months.sublist(0, (months.length / 2).floor());

    final recentAverage = recentMonths.fold<double>(0, (sum, month) => sum + monthlyTotals[month]!) / recentMonths.length;
    final olderAverage = olderMonths.fold<double>(0, (sum, month) => sum + monthlyTotals[month]!) / olderMonths.length;

    final trendPercentage = olderAverage > 0 ? ((recentAverage - olderAverage) / olderAverage) * 100 : 0;

    return {
      'trend': trendPercentage > 5 ? 'increasing' : trendPercentage < -5 ? 'decreasing' : 'stable',
      'trendPercentage': trendPercentage,
      'recentAverage': recentAverage,
      'olderAverage': olderAverage,
    };
  }

  /// Calcula diferença em meses entre duas datas
  int _calculateMonthsDifference(DateTime date1, DateTime date2) {
    final months = (date1.year - date2.year) * 12 + (date1.month - date2.month);
    return months.abs();
  }
}

/// Resultado de validação de despesa
class ValidationResult {
  final bool isValid;
  final Map<String, String> errors;
  final Map<String, String> warnings;

  ValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasErrors => errors.isNotEmpty;
}

/// Análise de padrões de despesas
class ExpensePatternAnalysis {
  final int totalRecords;
  final double totalAmount;
  final double averageAmount;
  final Map<ExpenseType, double> expensesByType;
  final List<ExpenseAnomaly> anomalies;
  final Map<String, dynamic> trends;
  final ExpenseEntity lastExpense;
  final ExpenseEntity firstExpense;
  final Duration period;

  ExpensePatternAnalysis({
    required this.totalRecords,
    required this.totalAmount,
    required this.averageAmount,
    required this.expensesByType,
    required this.anomalies,
    required this.trends,
    required this.lastExpense,
    required this.firstExpense,
    required this.period,
  });

  factory ExpensePatternAnalysis.empty() {
    final now = DateTime.now();
    final dummyExpense = ExpenseEntity(
      id: '', userId: '', vehicleId: '', type: ExpenseType.other,
      description: '', amount: 0, date: now, odometer: 0,
      createdAt: now, updatedAt: now,
    );
    
    return ExpensePatternAnalysis(
      totalRecords: 0,
      totalAmount: 0,
      averageAmount: 0,
      expensesByType: {},
      anomalies: [],
      trends: {},
      lastExpense: dummyExpense,
      firstExpense: dummyExpense,
      period: Duration.zero,
    );
  }

  bool get hasAnomalies => anomalies.isNotEmpty;
  String get totalAmountFormatted => 'R\$ ${totalAmount.toStringAsFixed(2)}';
  String get averageAmountFormatted => 'R\$ ${averageAmount.toStringAsFixed(2)}';
  int get periodInDays => period.inDays;
  double get monthlyAverage => periodInDays > 0 ? totalAmount / (periodInDays / 30.44) : 0;
}

/// Anomalia detectada em despesas
class ExpenseAnomaly {
  final String expenseId;
  final AnomalyType type;
  final String description;
  final AnomalySeverity severity;

  ExpenseAnomaly({
    required this.expenseId,
    required this.type,
    required this.description,
    required this.severity,
  });
}

enum AnomalyType {
  valueOutlier,
  frequencyAnomaly,
  sequenceError,
  duplicateExpense,
}

enum AnomalySeverity {
  low,
  medium,
  high,
  critical,
}