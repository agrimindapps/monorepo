import '../../domain/entities/fuel_record_entity.dart';

/// Statistics model for fuel records
class FuelStatistics {
  const FuelStatistics({
    required this.totalLiters,
    required this.totalCost,
    required this.averagePrice,
    required this.averageConsumption,
    required this.totalRecords,
    required this.lastUpdated,
  });

  final double totalLiters;
  final double totalCost;
  final double averagePrice;
  final double averageConsumption;
  final int totalRecords;
  final DateTime lastUpdated;

  bool get needsRecalculation {
    final now = DateTime.now();
    const maxCacheTime = Duration(minutes: 5);
    return now.difference(lastUpdated) > maxCacheTime;
  }
}

/// Service responsible for calculating fuel statistics
///
/// Follows SRP by handling only statistical calculations
class FuelStatisticsService {
  /// Calculates comprehensive statistics for fuel records
  FuelStatistics calculateStatistics(List<FuelRecordEntity> records) {
    if (records.isEmpty) {
      return FuelStatistics(
        totalLiters: 0.0,
        totalCost: 0.0,
        averagePrice: 0.0,
        averageConsumption: 0.0,
        totalRecords: 0,
        lastUpdated: DateTime.now(),
      );
    }

    final totalLiters = records.fold<double>(
      0,
      (sum, record) => sum + record.liters,
    );

    final totalCost = records.fold<double>(
      0,
      (sum, record) => sum + record.totalPrice,
    );

    final averagePrice = records.fold<double>(
      0,
      (sum, record) => sum + record.pricePerLiter,
    ) / records.length;
    double averageConsumption = 0.0;
    final recordsWithConsumption = records
        .where((r) => r.consumption != null && r.consumption! > 0)
        .toList();

    if (recordsWithConsumption.isNotEmpty) {
      averageConsumption = recordsWithConsumption.fold<double>(
        0,
        (sum, record) => sum + record.consumption!,
      ) / recordsWithConsumption.length;
    }

    return FuelStatistics(
      totalLiters: totalLiters,
      totalCost: totalCost,
      averagePrice: averagePrice,
      averageConsumption: averageConsumption,
      totalRecords: records.length,
      lastUpdated: DateTime.now(),
    );
  }

  /// Calculates total spent in a date range
  double getTotalSpentInDateRange(
    List<FuelRecordEntity> records,
    DateTime startDate,
    DateTime endDate,
  ) {
    final recordsInRange = records.where((record) {
      return record.date.isAfter(startDate) && record.date.isBefore(endDate);
    }).toList();

    return recordsInRange
        .map((r) => r.totalPrice)
        .fold(0.0, (a, b) => a + b);
  }

  /// Calculates total liters in a date range
  double getTotalLitersInDateRange(
    List<FuelRecordEntity> records,
    DateTime startDate,
    DateTime endDate,
  ) {
    final recordsInRange = records.where((record) {
      return record.date.isAfter(startDate) && record.date.isBefore(endDate);
    }).toList();

    return recordsInRange
        .map((r) => r.liters)
        .fold(0.0, (a, b) => a + b);
  }
}
