import '../entities/expense_entity.dart';

/// Resultado de validação de despesa
class ValidationResult {
  ValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });
  final bool isValid;
  final Map<String, String> errors;
  final Map<String, String> warnings;

  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasErrors => errors.isNotEmpty;
}

/// Análise de padrões de despesas
class ExpensePatternAnalysis {
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
      id: '',
      userId: '',
      vehicleId: '',
      type: ExpenseType.other,
      description: '',
      amount: 0,
      date: now,
      odometer: 0,
      createdAt: now,
      updatedAt: now,
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
  final int totalRecords;
  final double totalAmount;
  final double averageAmount;
  final Map<ExpenseType, double> expensesByType;
  final List<ExpenseAnomaly> anomalies;
  final Map<String, dynamic> trends;
  final ExpenseEntity lastExpense;
  final ExpenseEntity firstExpense;
  final Duration period;

  bool get hasAnomalies => anomalies.isNotEmpty;
  String get totalAmountFormatted => 'R\$ ${totalAmount.toStringAsFixed(2)}';
  String get averageAmountFormatted =>
      'R\$ ${averageAmount.toStringAsFixed(2)}';
  int get periodInDays => period.inDays;
  double get monthlyAverage =>
      periodInDays > 0 ? totalAmount / (periodInDays / 30.44) : 0;
}

/// Anomalia detectada em despesas
class ExpenseAnomaly {
  ExpenseAnomaly({
    required this.expenseId,
    required this.type,
    required this.description,
    required this.severity,
  });
  final String expenseId;
  final AnomalyType type;
  final String description;
  final AnomalySeverity severity;
}

enum AnomalyType {
  valueOutlier,
  frequencyAnomaly,
  sequenceError,
  duplicateExpense,
}

enum AnomalySeverity { low, medium, high, critical }
