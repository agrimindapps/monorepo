import '../entities/expense_entity.dart';
import '../../../vehicles/domain/entities/vehicle_entity.dart';
import 'expense_formatter_service.dart';

/// Serviço especializado para calcular estatísticas de despesas
class ExpenseStatisticsService {
  final ExpenseFormatterService _formatter = ExpenseFormatterService();

  /// Calcula estatísticas completas de uma lista de despesas
  Map<String, dynamic> calculateStats(List<ExpenseEntity> expenses) {
    if (expenses.isEmpty) {
      return _emptyStats();
    }

    final totalAmount = expenses.fold<double>(0, (sum, e) => sum + e.amount);
    final averageAmount = totalAmount / expenses.length;
    
    // Agrupar por tipo
    final byType = <ExpenseType, double>{};
    final countByType = <ExpenseType, int>{};
    
    for (final expense in expenses) {
      byType[expense.type] = (byType[expense.type] ?? 0) + expense.amount;
      countByType[expense.type] = (countByType[expense.type] ?? 0) + 1;
    }

    // Encontrar tipo mais caro
    ExpenseType? mostExpensiveType;
    double maxTypeAmount = 0;
    byType.forEach((type, amount) {
      if (amount > maxTypeAmount) {
        maxTypeAmount = amount;
        mostExpensiveType = type;
      }
    });

    // Calcular médias mensais se tiver dados suficientes
    double monthlyAmount = 0;
    if (expenses.length >= 2) {
      final sortedByDate = List<ExpenseEntity>.from(expenses)
        ..sort((a, b) => a.date.compareTo(b.date));
      
      final firstDate = sortedByDate.first.date;
      final lastDate = sortedByDate.last.date;
      final monthsDiff = ((lastDate.year - firstDate.year) * 12 + lastDate.month - firstDate.month) + 1;
      
      if (monthsDiff > 0) {
        monthlyAmount = totalAmount / monthsDiff;
      }
    }

    return {
      'totalRecords': expenses.length,
      'totalAmount': totalAmount,
      'totalAmountFormatted': _formatter.formatAmount(totalAmount),
      'averageAmount': averageAmount,
      'averageAmountFormatted': _formatter.formatAmount(averageAmount),
      'monthlyAmount': monthlyAmount,
      'monthlyAmountFormatted': _formatter.formatAmount(monthlyAmount),
      'byType': byType.map((k, v) => MapEntry(k.displayName, v)),
      'byTypeFormatted': byType.map((k, v) => MapEntry(k.displayName, _formatter.formatAmount(v))),
      'countByType': countByType.map((k, v) => MapEntry(k.displayName, v)),
      'mostExpensiveType': mostExpensiveType?.displayName,
      'mostExpensiveTypeAmount': maxTypeAmount,
      'mostExpensiveTypeAmountFormatted': _formatter.formatAmount(maxTypeAmount),
      'highestExpense': expenses.reduce((a, b) => a.amount > b.amount ? a : b).amount,
      'lowestExpense': expenses.reduce((a, b) => a.amount < b.amount ? a : b).amount,
      'highestExpenseFormatted': _formatter.formatAmount(expenses.reduce((a, b) => a.amount > b.amount ? a : b).amount),
      'lowestExpenseFormatted': _formatter.formatAmount(expenses.reduce((a, b) => a.amount < b.amount ? a : b).amount),
    };
  }

  /// Calcula estatísticas por período
  Map<String, dynamic> calculateStatsByPeriod(
    List<ExpenseEntity> expenses, 
    DateTime start, 
    DateTime end,
  ) {
    final periodExpenses = expenses.where((e) {
      return e.date.isAfter(start.subtract(const Duration(days: 1))) &&
             e.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();

    if (periodExpenses.isEmpty) return _emptyStats();

    final baseStats = calculateStats(periodExpenses);
    final totalAmount = baseStats['totalAmount'] as double;
    final days = end.difference(start).inDays + 1;
    
    return {
      ...baseStats,
      'period': _formatter.formatPeriod(start),
      'days': days,
      'averageDailyAmount': totalAmount / days,
      'averageDailyAmountFormatted': _formatter.formatAmount(totalAmount / days),
    };
  }

  /// Calcula estatísticas de crescimento/tendências
  Map<String, dynamic> calculateGrowthStats(List<ExpenseEntity> expenses) {
    if (expenses.length < 2) {
      return {
        'hasGrowthData': false,
        'growthPercentage': 0.0,
        'trend': 'stable',
      };
    }

    // Ordenar por data
    final sorted = List<ExpenseEntity>.from(expenses)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Dividir em dois períodos
    final midPoint = sorted.length ~/ 2;
    final firstHalf = sorted.take(midPoint).toList();
    final secondHalf = sorted.skip(midPoint).toList();

    final firstHalfTotal = firstHalf.fold<double>(0, (sum, e) => sum + e.amount);
    final secondHalfTotal = secondHalf.fold<double>(0, (sum, e) => sum + e.amount);

    final firstHalfAvg = firstHalfTotal / firstHalf.length;
    final secondHalfAvg = secondHalfTotal / secondHalf.length;

    final growthPercentage = ((secondHalfAvg - firstHalfAvg) / firstHalfAvg) * 100;

    String trend;
    if (growthPercentage > 10) {
      trend = 'increasing';
    } else if (growthPercentage < -10) {
      trend = 'decreasing';
    } else {
      trend = 'stable';
    }

    return {
      'hasGrowthData': true,
      'growthPercentage': growthPercentage,
      'growthPercentageFormatted': '${growthPercentage.toStringAsFixed(1)}%',
      'trend': trend,
      'firstPeriodAverage': firstHalfAvg,
      'secondPeriodAverage': secondHalfAvg,
      'firstPeriodAverageFormatted': _formatter.formatAmount(firstHalfAvg),
      'secondPeriodAverageFormatted': _formatter.formatAmount(secondHalfAvg),
    };
  }

  /// Calcula estatísticas de anomalias
  Map<String, dynamic> calculateAnomalies(List<ExpenseEntity> expenses) {
    if (expenses.length < 3) {
      return {
        'hasAnomalies': false,
        'anomalousExpenses': <ExpenseEntity>[],
        'thresholdAmount': 0.0,
      };
    }

    // Calcular média e desvio padrão
    final amounts = expenses.map((e) => e.amount).toList();
    final mean = amounts.reduce((a, b) => a + b) / amounts.length;
    final variance = amounts.map((x) => (x - mean) * (x - mean)).reduce((a, b) => a + b) / amounts.length;
    final standardDeviation = variance.sqrt();

    // Definir threshold para anomalias (2 desvios padrão)
    final thresholdAmount = mean + (2 * standardDeviation);
    
    final anomalousExpenses = expenses.where((e) => e.amount > thresholdAmount).toList();

    return {
      'hasAnomalies': anomalousExpenses.isNotEmpty,
      'anomalousExpenses': anomalousExpenses,
      'thresholdAmount': thresholdAmount,
      'thresholdAmountFormatted': _formatter.formatAmount(thresholdAmount),
      'anomaliesCount': anomalousExpenses.length,
      'meanAmount': mean,
      'meanAmountFormatted': _formatter.formatAmount(mean),
      'standardDeviation': standardDeviation,
      'standardDeviationFormatted': _formatter.formatAmount(standardDeviation),
    };
  }

  /// Estatísticas por veículo
  Map<String, dynamic> calculateVehicleStats(
    List<ExpenseEntity> expenses, 
    VehicleEntity vehicle,
  ) {
    final vehicleExpenses = expenses.where((e) => e.vehicleId == vehicle.id).toList();
    
    if (vehicleExpenses.isEmpty) {
      return _emptyVehicleStats(vehicle);
    }

    final baseStats = calculateStats(vehicleExpenses);
    final totalAmount = baseStats['totalAmount'] as double;
    
    // Calcular custo por quilômetro se possível
    double? costPerKm;
    if (vehicle.currentOdometer > 0) {
      costPerKm = totalAmount / vehicle.currentOdometer;
    }

    return {
      ...baseStats,
      'vehicle': vehicle,
      'vehicleName': vehicle.name,
      'currentOdometer': vehicle.currentOdometer,
      'costPerKm': costPerKm,
      'costPerKmFormatted': costPerKm != null ? _formatter.formatAmount(costPerKm) : null,
    };
  }

  /// Comparação entre períodos
  Map<String, dynamic> comparePeriods(
    List<ExpenseEntity> expenses,
    DateTime period1Start,
    DateTime period1End,
    DateTime period2Start,
    DateTime period2End,
  ) {
    final period1Stats = calculateStatsByPeriod(expenses, period1Start, period1End);
    final period2Stats = calculateStatsByPeriod(expenses, period2Start, period2End);

    final period1Total = period1Stats['totalAmount'] as double;
    final period2Total = period2Stats['totalAmount'] as double;

    final difference = period2Total - period1Total;
    final percentageChange = period1Total > 0 ? (difference / period1Total) * 100 : 0;

    return {
      'period1': period1Stats,
      'period2': period2Stats,
      'difference': difference,
      'differenceFormatted': _formatter.formatAmount(difference.abs()),
      'percentageChange': percentageChange,
      'percentageChangeFormatted': '${percentageChange.toStringAsFixed(1)}%',
      'isIncrease': difference > 0,
      'isDecrease': difference < 0,
      'isStable': difference.abs() < (period1Total * 0.05), // 5% threshold
    };
  }

  /// Estatísticas vazias
  Map<String, dynamic> _emptyStats() {
    return {
      'totalRecords': 0,
      'totalAmount': 0.0,
      'totalAmountFormatted': _formatter.formatAmount(0.0),
      'averageAmount': 0.0,
      'averageAmountFormatted': _formatter.formatAmount(0.0),
      'monthlyAmount': 0.0,
      'monthlyAmountFormatted': _formatter.formatAmount(0.0),
      'byType': <String, double>{},
      'byTypeFormatted': <String, String>{},
      'countByType': <String, int>{},
      'mostExpensiveType': null,
      'mostExpensiveTypeAmount': 0.0,
      'mostExpensiveTypeAmountFormatted': _formatter.formatAmount(0.0),
      'highestExpense': 0.0,
      'lowestExpense': 0.0,
      'highestExpenseFormatted': _formatter.formatAmount(0.0),
      'lowestExpenseFormatted': _formatter.formatAmount(0.0),
    };
  }

  /// Estatísticas vazias para veículo
  Map<String, dynamic> _emptyVehicleStats(VehicleEntity vehicle) {
    return {
      ..._emptyStats(),
      'vehicle': vehicle,
      'vehicleName': vehicle.name,
      'currentOdometer': vehicle.currentOdometer,
      'costPerKm': null,
      'costPerKmFormatted': null,
    };
  }
}

extension _DoubleExtensions on double {
  double sqrt() => this < 0 ? 0 : this;
}