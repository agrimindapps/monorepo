import 'package:injectable/injectable.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../fuel/domain/entities/fuel_record_entity.dart';
import 'usage_pattern_analyzer.dart';

@LazySingleton(as: UsagePatternAnalyzer)
class UsagePatternAnalyzerImpl implements UsagePatternAnalyzer {
  const UsagePatternAnalyzerImpl(this._dateUtils);
  
  final DateUtils _dateUtils;

  @override
  Future<Map<String, dynamic>> analyzePatterns(
    String vehicleId,
    int months,
    List<FuelRecordEntity> fuelRecords,
  ) async {
    final endDate = DateTime.now();
    final startDate = _dateUtils.calculateSafeStartDate(endDate, months);

    final filteredRecords = _filterRecordsByDateRange(fuelRecords, startDate, endDate);

    if (filteredRecords.length < 2) {
      return {
        'usage_frequency': 'low',
        'average_days_between_fills': 0,
        'monthly_usage': <Map<String, dynamic>>[],
        'usage_trend': 'insufficient_data',
        'analysis_period_months': months,
      };
    }

    filteredRecords.sort((a, b) => a.date.compareTo(b.date));

    final averageDaysBetween = _calculateAverageDaysBetweenFills(filteredRecords);
    final monthlyUsageList = _calculateMonthlyUsage(filteredRecords);
    final usageFrequency = _classifyUsageFrequency(averageDaysBetween);
    final usageTrend = _analyzeTrendDirection(monthlyUsageList);

    return {
      'usage_frequency': usageFrequency,
      'average_days_between_fills': averageDaysBetween.round(),
      'monthly_usage': monthlyUsageList,
      'usage_trend': usageTrend,
      'analysis_period_months': months,
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

  double _calculateAverageDaysBetweenFills(List<FuelRecordEntity> sortedRecords) {
    final daysBetween = <int>[];

    for (int i = 1; i < sortedRecords.length; i++) {
      final days = sortedRecords[i].date.difference(sortedRecords[i - 1].date).inDays;
      if (days > 0) daysBetween.add(days);
    }

    if (daysBetween.isEmpty) return 0;
    return daysBetween.fold(0, (a, b) => a + b) / daysBetween.length;
  }

  List<Map<String, dynamic>> _calculateMonthlyUsage(List<FuelRecordEntity> records) {
    final monthlyUsage = <String, int>{};

    for (final record in records) {
      final monthKey = _dateUtils.generateMonthKey(record.date);
      monthlyUsage[monthKey] = (monthlyUsage[monthKey] ?? 0) + 1;
    }

    final monthlyUsageList = monthlyUsage.entries.map((entry) => {
      'month': entry.key,
      'fill_ups': entry.value,
    }).toList();

    monthlyUsageList.sort((a, b) => (a['month'] as String).compareTo(b['month'] as String));
    return monthlyUsageList;
  }

  String _classifyUsageFrequency(double averageDays) {
    if (averageDays < 7) return 'high';
    if (averageDays > 21) return 'low';
    return 'medium';
  }

  String _analyzeTrendDirection(List<Map<String, dynamic>> monthlyUsage) {
    if (monthlyUsage.length < 2) return 'stable';

    final firstMonth = monthlyUsage.first['fill_ups'] as int;
    final lastMonth = monthlyUsage.last['fill_ups'] as int;

    if (lastMonth > firstMonth * 1.2) return 'increasing';
    if (lastMonth < firstMonth * 0.8) return 'decreasing';
    return 'stable';
  }
}
