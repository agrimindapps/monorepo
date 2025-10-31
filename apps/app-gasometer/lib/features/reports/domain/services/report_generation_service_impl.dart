import 'package:injectable/injectable.dart';

import '../../../fuel/domain/entities/fuel_record_entity.dart';
import '../entities/report_summary_entity.dart';
import 'report_generation_service.dart';

@LazySingleton(as: ReportGenerationService)
class ReportGenerationServiceImpl implements ReportGenerationService {
  @override
  Future<ReportSummaryEntity> generateReport(
    String vehicleId,
    DateTime startDate,
    DateTime endDate,
    String period,
    List<FuelRecordEntity> fuelRecords,
  ) async {
    final filteredRecords = _filterRecordsByDateRange(fuelRecords, startDate, endDate);

    if (filteredRecords.isEmpty) {
      return _createEmptyReport(vehicleId, startDate, endDate, period);
    }

    filteredRecords.sort((a, b) => a.date.compareTo(b.date));

    final totalFuelSpent = _calculateTotalFuelSpent(filteredRecords);
    final totalFuelLiters = _calculateTotalFuelLiters(filteredRecords);
    final averageFuelPrice = _calculateAverageFuelPrice(totalFuelSpent, totalFuelLiters);
    final fuelRecordsCount = filteredRecords.length;
    final totalDistanceTraveled = _calculateTotalDistance(filteredRecords);
    final firstOdometerReading = filteredRecords.first.odometer;
    final lastOdometerReading = filteredRecords.last.odometer;
    final averageConsumption = _calculateAverageConsumption(totalDistanceTraveled, totalFuelLiters);
    final costPerKm = _calculateCostPerKm(totalFuelSpent, totalDistanceTraveled);
    final trends = _calculateBasicTrends();

    return ReportSummaryEntity(
      vehicleId: vehicleId,
      startDate: startDate,
      endDate: endDate,
      period: period,
      totalFuelSpent: totalFuelSpent,
      totalFuelLiters: totalFuelLiters,
      averageFuelPrice: averageFuelPrice,
      fuelRecordsCount: fuelRecordsCount,
      totalDistanceTraveled: totalDistanceTraveled,
      averageConsumption: averageConsumption,
      lastOdometerReading: lastOdometerReading,
      firstOdometerReading: firstOdometerReading,
      costPerKm: costPerKm,
      trends: trends,
      metadata: {
        'generated_at': DateTime.now().toIso8601String(),
        'calculation_method': 'fuel_records_based',
      },
    );
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

  double _calculateTotalFuelSpent(List<FuelRecordEntity> records) {
    return records.map((r) => r.totalPrice).fold(0.0, (a, b) => a + b);
  }

  double _calculateTotalFuelLiters(List<FuelRecordEntity> records) {
    return records.map((r) => r.liters).fold(0.0, (a, b) => a + b);
  }

  double _calculateAverageFuelPrice(double totalSpent, double totalLiters) {
    return totalLiters > 0 ? totalSpent / totalLiters : 0.0;
  }

  double _calculateTotalDistance(List<FuelRecordEntity> records) {
    if (records.length < 2) return 0.0;

    final sortedRecords = [...records]..sort((a, b) => a.date.compareTo(b.date));

    double totalDistance = 0.0;
    for (int i = 1; i < sortedRecords.length; i++) {
      final distance = sortedRecords[i].odometer - sortedRecords[i - 1].odometer;
      if (distance > 0 && distance < 10000) {
        totalDistance += distance;
      }
    }

    return totalDistance;
  }

  double _calculateAverageConsumption(double totalDistance, double totalLiters) {
    return totalDistance > 0 && totalLiters > 0 ? totalDistance / totalLiters : 0.0;
  }

  double _calculateCostPerKm(double totalSpent, double totalDistance) {
    return totalDistance > 0 ? totalSpent / totalDistance : 0.0;
  }

  Map<String, dynamic> _calculateBasicTrends() {
    return {
      'fuel_efficiency': 'stable',
      'cost_trend': 'stable',
      'usage_pattern': 'consistent',
    };
  }

  ReportSummaryEntity _createEmptyReport(
    String vehicleId,
    DateTime startDate,
    DateTime endDate,
    String period,
  ) {
    return ReportSummaryEntity(
      vehicleId: vehicleId,
      startDate: startDate,
      endDate: endDate,
      period: period,
      totalFuelSpent: 0.0,
      totalFuelLiters: 0.0,
      averageFuelPrice: 0.0,
      fuelRecordsCount: 0,
      totalDistanceTraveled: 0.0,
      averageConsumption: 0.0,
      lastOdometerReading: 0.0,
      firstOdometerReading: 0.0,
      costPerKm: 0.0,
      metadata: {
        'generated_at': DateTime.now().toIso8601String(),
        'calculation_method': 'empty_report',
      },
    );
  }
}
