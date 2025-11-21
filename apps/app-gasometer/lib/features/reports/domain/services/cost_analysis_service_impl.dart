
import '../../../../core/utils/date_utils.dart';
import '../../../fuel/domain/entities/fuel_record_entity.dart';
import 'cost_analysis_service.dart';


class CostAnalysisServiceImpl implements CostAnalysisService {
  const CostAnalysisServiceImpl(this._dateUtils);
  
  final DateUtils _dateUtils;

  @override
  Future<Map<String, dynamic>> analyzeCosts(
    String vehicleId,
    DateTime startDate,
    DateTime endDate,
    List<FuelRecordEntity> fuelRecords,
  ) async {
    final filteredRecords = _filterRecordsByDateRange(fuelRecords, startDate, endDate);

    if (filteredRecords.isEmpty) {
      return _createEmptyCostAnalysis();
    }

    filteredRecords.sort((a, b) => a.date.compareTo(b.date));

    final totalCost = _calculateTotalCost(filteredRecords);
    final averageCostPerFill = totalCost / filteredRecords.length;
    final priceTrends = _analyzePriceTrends(filteredRecords);

    return {
      'total_cost': totalCost,
      'average_cost_per_fill': averageCostPerFill,
      'cost_breakdown': {
        'fuel_cost': totalCost,
        'maintenance_cost': 0.0,
        'other_expenses': 0.0,
      },
      'price_trends': priceTrends,
      'records_analyzed': filteredRecords.length,
    };
  }

  List<FuelRecordEntity> _filterRecordsByDateRange(
    List<FuelRecordEntity> records,
    DateTime startDate,
    DateTime endDate,
  ) {
    return records.where((record) {
      return record.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          record.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  double _calculateTotalCost(List<FuelRecordEntity> records) {
    return records.map((r) => r.totalPrice).fold(0.0, (a, b) => a + b);
  }

  List<Map<String, dynamic>> _analyzePriceTrends(List<FuelRecordEntity> records) {
    final monthlyPrices = <String, List<double>>{};

    for (final record in records) {
      final monthKey = _dateUtils.generateMonthKey(record.date);
      monthlyPrices[monthKey] ??= [];
      monthlyPrices[monthKey]!.add(record.pricePerLiter);
    }

    final priceTrends = <Map<String, dynamic>>[];

    for (final entry in monthlyPrices.entries) {
      final average = entry.value.fold(0.0, (a, b) => a + b) / entry.value.length;
      priceTrends.add({
        'month': entry.key,
        'average_price': average,
        'min_price': entry.value.reduce((a, b) => a < b ? a : b),
        'max_price': entry.value.reduce((a, b) => a > b ? a : b),
      });
    }

    priceTrends.sort((a, b) => (a['month'] as String).compareTo(b['month'] as String));
    return priceTrends;
  }

  Map<String, dynamic> _createEmptyCostAnalysis() {
    return {
      'total_cost': 0.0,
      'average_cost_per_fill': 0.0,
      'cost_breakdown': <String, dynamic>{},
      'price_trends': <Map<String, dynamic>>[],
      'records_analyzed': 0,
    };
  }
}
