
import '../../../../core/utils/date_utils.dart';
import '../../../fuel/domain/entities/fuel_record_entity.dart';
import 'fuel_efficiency_analyzer.dart';


class FuelEfficiencyAnalyzerImpl implements FuelEfficiencyAnalyzer {
  const FuelEfficiencyAnalyzerImpl(this._dateUtils);
  
  final DateUtils _dateUtils;

  @override
  Future<Map<String, dynamic>> analyzeTrends(
    String vehicleId,
    int months,
    List<FuelRecordEntity> fuelRecords,
  ) async {
    final endDate = DateTime.now();
    final startDate = _dateUtils.calculateSafeStartDate(endDate, months);

    final filteredRecords = _filterRecordsByDateRange(fuelRecords, startDate, endDate);

    if (filteredRecords.length < 2) {
      return {
        'trend': 'insufficient_data',
        'efficiency_change': 0.0,
        'monthly_averages': <Map<String, dynamic>>[],
        'period_months': months,
      };
    }

    final monthlyData = _groupRecordsByMonth(filteredRecords);
    final monthlyAverages = _calculateMonthlyAverages(monthlyData);
    final trendAnalysis = _analyzeTrendDirection(monthlyAverages);

    return {
      'trend': trendAnalysis['trend'],
      'efficiency_change': trendAnalysis['efficiency_change'],
      'monthly_averages': monthlyAverages,
      'period_months': months,
    };
  }

  List<FuelRecordEntity> _filterRecordsByDateRange(
    List<FuelRecordEntity> records,
    DateTime startDate,
    DateTime endDate,
  ) {
    return records.where((record) {
      return record.date.isAfter(startDate) && record.date.isBefore(endDate);
    }).toList();
  }

  Map<String, List<double>> _groupRecordsByMonth(List<FuelRecordEntity> records) {
    final monthlyData = <String, List<double>>{};

    for (final record in records) {
      if (record.consumption != null && record.consumption! > 0) {
        final monthKey = _dateUtils.generateMonthKey(record.date);
        monthlyData[monthKey] ??= [];
        monthlyData[monthKey]!.add(record.consumption!);
      }
    }

    return monthlyData;
  }

  List<Map<String, dynamic>> _calculateMonthlyAverages(Map<String, List<double>> monthlyData) {
    final monthlyAverages = <Map<String, dynamic>>[];

    for (final entry in monthlyData.entries) {
      final average = entry.value.fold(0.0, (a, b) => a + b) / entry.value.length;
      monthlyAverages.add({
        'month': entry.key,
        'average_consumption': average,
        'records_count': entry.value.length,
      });
    }

    monthlyAverages.sort((a, b) => (a['month'] as String).compareTo(b['month'] as String));
    return monthlyAverages;
  }

  Map<String, dynamic> _analyzeTrendDirection(List<Map<String, dynamic>> monthlyAverages) {
    if (monthlyAverages.length < 2) {
      return {
        'trend': 'insufficient_data',
        'efficiency_change': 0.0,
      };
    }

    final firstMonthAvg = monthlyAverages.first['average_consumption'] as double;
    final lastMonthAvg = monthlyAverages.last['average_consumption'] as double;

    if (firstMonthAvg <= 0) {
      return {
        'trend': 'stable',
        'efficiency_change': 0.0,
      };
    }

    final efficiencyChange = ((lastMonthAvg - firstMonthAvg) / firstMonthAvg) * 100;

    String trend = 'stable';
    if (efficiencyChange > 5) {
      trend = 'improving';
    } else if (efficiencyChange < -5) {
      trend = 'declining';
    }

    return {
      'trend': trend,
      'efficiency_change': efficiencyChange,
    };
  }
}
