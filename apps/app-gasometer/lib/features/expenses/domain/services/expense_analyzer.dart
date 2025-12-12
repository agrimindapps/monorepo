import '../../../vehicles/domain/entities/vehicle_entity.dart';
import '../entities/expense_entity.dart';
import 'expense_validation_types.dart';

class ExpenseAnalyzer {
  const ExpenseAnalyzer();

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
    final totalAmount = sortedExpenses.fold<double>(
      0,
      (sum, e) => sum + e.amount,
    );
    final averageAmount = totalAmount / sortedExpenses.length;
    final expensesByType = <ExpenseType, List<ExpenseEntity>>{};
    for (final expense in sortedExpenses) {
      expensesByType.putIfAbsent(expense.type, () => []).add(expense);
    }
    final expensesByTypeAmount = expensesByType.map(
      (type, expenses) =>
          MapEntry(type, expenses.fold<double>(0, (sum, e) => sum + e.amount)),
    );
    final anomalies = _detectExpenseAnomalies(sortedExpenses);
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
    final typeAverages = <ExpenseType, double>{};
    final typeGroups = <ExpenseType, List<ExpenseEntity>>{};

    for (final expense in expenses) {
      typeGroups.putIfAbsent(expense.type, () => []).add(expense);
    }

    typeGroups.forEach((type, expenses) {
      typeAverages[type] =
          expenses.fold<double>(0, (sum, e) => sum + e.amount) /
          expenses.length;
    });
    for (final expense in expenses) {
      final average = typeAverages[expense.type]!;
      final deviation = (expense.amount - average).abs() / average;

      if (deviation > 1.0) {
        anomalies.add(
          ExpenseAnomaly(
            expenseId: expense.id,
            type: AnomalyType.valueOutlier,
            description:
                'Valor muito ${expense.amount > average ? 'alto' : 'baixo'} '
                'para ${expense.type.displayName} (${deviation.toStringAsFixed(1)}x da média)',
            severity:
                deviation > 2.0 ? AnomalySeverity.high : AnomalySeverity.medium,
          ),
        );
      }
    }
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
          typeExpenses[i - 1].date,
        );

        if (monthsDiff < 6) {
          anomalies.add(
            ExpenseAnomaly(
              expenseId: typeExpenses[i].id,
              type: AnomalyType.frequencyAnomaly,
              description:
                  'Despesa recorrente registrada muito cedo ($monthsDiff meses)',
              severity: AnomalySeverity.medium,
            ),
          );
        }
      }
    });

    return anomalies;
  }

  /// Calcula tendências de gastos
  Map<String, dynamic> _calculateExpenseTrends(List<ExpenseEntity> expenses) {
    if (expenses.length < 2) return {};
    final monthlyTotals = <String, double>{};

    for (final expense in expenses) {
      final monthKey =
          '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + expense.amount;
    }

    final months = monthlyTotals.keys.toList()..sort();
    if (months.length < 2) return {};
    final recentMonths =
        months.length >= 6
            ? months.sublist(months.length - 3)
            : months.sublist((months.length / 2).ceil());
    final olderMonths =
        months.length >= 6
            ? months.sublist(months.length - 6, months.length - 3)
            : months.sublist(0, (months.length / 2).floor());

    final recentAverage =
        recentMonths.fold<double>(
          0,
          (sum, month) => sum + monthlyTotals[month]!,
        ) /
        recentMonths.length;
    final olderAverage =
        olderMonths.fold<double>(
          0,
          (sum, month) => sum + monthlyTotals[month]!,
        ) /
        olderMonths.length;

    final trendPercentage =
        olderAverage > 0
            ? ((recentAverage - olderAverage) / olderAverage) * 100
            : 0;

    return {
      'trend':
          trendPercentage > 5
              ? 'increasing'
              : trendPercentage < -5
              ? 'decreasing'
              : 'stable',
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
