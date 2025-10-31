import 'package:injectable/injectable.dart';

import '../../domain/entities/maintenance_entity.dart';

/// Service responsible for calculating maintenance statistics
/// Follows SRP by handling only statistics calculations
@lazySingleton
class MaintenanceStatisticsCalculator {
  /// Calculate total cost of all maintenance records
  double calculateTotalCost(List<MaintenanceEntity> records) {
    if (records.isEmpty) return 0.0;
    return records.fold(0.0, (sum, record) => sum + record.cost);
  }

  /// Calculate average cost per maintenance
  double calculateAverageCost(List<MaintenanceEntity> records) {
    if (records.isEmpty) return 0.0;
    final total = calculateTotalCost(records);
    return total / records.length;
  }

  /// Calculate total cost by maintenance type
  Map<MaintenanceType, double> calculateCostByType(
    List<MaintenanceEntity> records,
  ) {
    final costByType = <MaintenanceType, double>{};

    for (final record in records) {
      costByType[record.type] = (costByType[record.type] ?? 0.0) + record.cost;
    }

    return costByType;
  }

  /// Calculate count of maintenance by type
  Map<MaintenanceType, int> calculateCountByType(
    List<MaintenanceEntity> records,
  ) {
    final countByType = <MaintenanceType, int>{};

    for (final record in records) {
      countByType[record.type] = (countByType[record.type] ?? 0) + 1;
    }

    return countByType;
  }

  /// Calculate count of maintenance by status
  Map<MaintenanceStatus, int> calculateCountByStatus(
    List<MaintenanceEntity> records,
  ) {
    final countByStatus = <MaintenanceStatus, int>{};

    for (final record in records) {
      countByStatus[record.status] = (countByStatus[record.status] ?? 0) + 1;
    }

    return countByStatus;
  }

  /// Calculate maintenance frequency (average days between maintenance)
  double calculateMaintenanceFrequency(List<MaintenanceEntity> records) {
    if (records.length < 2) return 0.0;

    final sortedRecords = List<MaintenanceEntity>.from(records)
      ..sort((a, b) => a.serviceDate.compareTo(b.serviceDate));

    var totalDays = 0;
    for (var i = 1; i < sortedRecords.length; i++) {
      final daysBetween = sortedRecords[i].serviceDate
          .difference(sortedRecords[i - 1].serviceDate)
          .inDays;
      totalDays += daysBetween;
    }

    return totalDays / (sortedRecords.length - 1);
  }

  /// Calculate cost per kilometer
  double calculateCostPerKm(List<MaintenanceEntity> records) {
    if (records.isEmpty) return 0.0;

    final sortedRecords = List<MaintenanceEntity>.from(records)
      ..sort((a, b) => a.odometer.compareTo(b.odometer));

    if (sortedRecords.length < 2) return 0.0;

    final firstOdometer = sortedRecords.first.odometer;
    final lastOdometer = sortedRecords.last.odometer;
    final totalKm = lastOdometer - firstOdometer;

    if (totalKm <= 0) return 0.0;

    final totalCost = calculateTotalCost(records);
    return totalCost / totalKm;
  }

  /// Calculate monthly maintenance cost
  Map<String, double> calculateMonthlyCost(List<MaintenanceEntity> records) {
    final monthlyCost = <String, double>{};

    for (final record in records) {
      final monthKey =
          '${record.serviceDate.year}-${record.serviceDate.month.toString().padLeft(2, '0')}';
      monthlyCost[monthKey] = (monthlyCost[monthKey] ?? 0.0) + record.cost;
    }

    return monthlyCost;
  }

  /// Get the most expensive maintenance record
  MaintenanceEntity? getMostExpensiveMaintenance(
    List<MaintenanceEntity> records,
  ) {
    if (records.isEmpty) return null;

    return records.reduce(
      (current, next) => current.cost > next.cost ? current : next,
    );
  }

  /// Get the least expensive maintenance record
  MaintenanceEntity? getLeastExpensiveMaintenance(
    List<MaintenanceEntity> records,
  ) {
    if (records.isEmpty) return null;

    return records.reduce(
      (current, next) => current.cost < next.cost ? current : next,
    );
  }

  /// Calculate maintenance statistics summary
  MaintenanceStatisticsSummary calculateSummary(
    List<MaintenanceEntity> records,
  ) {
    return MaintenanceStatisticsSummary(
      totalRecords: records.length,
      totalCost: calculateTotalCost(records),
      averageCost: calculateAverageCost(records),
      costByType: calculateCostByType(records),
      countByType: calculateCountByType(records),
      countByStatus: calculateCountByStatus(records),
      maintenanceFrequency: calculateMaintenanceFrequency(records),
      costPerKm: calculateCostPerKm(records),
      mostExpensive: getMostExpensiveMaintenance(records),
      leastExpensive: getLeastExpensiveMaintenance(records),
    );
  }

  /// Calculate cost trend (increasing, decreasing, stable)
  MaintenanceCostTrend calculateCostTrend(List<MaintenanceEntity> records) {
    if (records.length < 3) return MaintenanceCostTrend.stable;

    final sortedRecords = List<MaintenanceEntity>.from(records)
      ..sort((a, b) => a.serviceDate.compareTo(b.serviceDate));

    final recentRecords = sortedRecords.length > 6
        ? sortedRecords.sublist(sortedRecords.length - 6)
        : sortedRecords;

    final midpoint = recentRecords.length ~/ 2;
    final firstHalf = recentRecords.sublist(0, midpoint);
    final secondHalf = recentRecords.sublist(midpoint);

    final firstHalfAvg = calculateAverageCost(firstHalf);
    final secondHalfAvg = calculateAverageCost(secondHalf);

    final difference = secondHalfAvg - firstHalfAvg;
    final percentageChange = (difference / firstHalfAvg) * 100;

    if (percentageChange > 15) {
      return MaintenanceCostTrend.increasing;
    } else if (percentageChange < -15) {
      return MaintenanceCostTrend.decreasing;
    } else {
      return MaintenanceCostTrend.stable;
    }
  }

  /// Calculate upcoming maintenance count
  int calculateUpcomingCount(List<MaintenanceEntity> records) {
    final now = DateTime.now();
    return records.where((record) {
      return record.nextServiceDate != null &&
          record.nextServiceDate!.isAfter(now);
    }).length;
  }

  /// Calculate overdue maintenance count
  int calculateOverdueCount(List<MaintenanceEntity> records) {
    final now = DateTime.now();
    return records.where((record) {
      return record.nextServiceDate != null &&
          record.nextServiceDate!.isBefore(now) &&
          record.status != MaintenanceStatus.completed;
    }).length;
  }
}

/// Summary of maintenance statistics
class MaintenanceStatisticsSummary {
  final int totalRecords;
  final double totalCost;
  final double averageCost;
  final Map<MaintenanceType, double> costByType;
  final Map<MaintenanceType, int> countByType;
  final Map<MaintenanceStatus, int> countByStatus;
  final double maintenanceFrequency;
  final double costPerKm;
  final MaintenanceEntity? mostExpensive;
  final MaintenanceEntity? leastExpensive;

  const MaintenanceStatisticsSummary({
    required this.totalRecords,
    required this.totalCost,
    required this.averageCost,
    required this.costByType,
    required this.countByType,
    required this.countByStatus,
    required this.maintenanceFrequency,
    required this.costPerKm,
    this.mostExpensive,
    this.leastExpensive,
  });
}

/// Cost trend for maintenance
enum MaintenanceCostTrend { increasing, decreasing, stable }

extension MaintenanceCostTrendExtension on MaintenanceCostTrend {
  String get displayName {
    switch (this) {
      case MaintenanceCostTrend.increasing:
        return 'Aumentando';
      case MaintenanceCostTrend.decreasing:
        return 'Diminuindo';
      case MaintenanceCostTrend.stable:
        return 'Estável';
    }
  }

  String get description {
    switch (this) {
      case MaintenanceCostTrend.increasing:
        return 'Os custos de manutenção estão aumentando';
      case MaintenanceCostTrend.decreasing:
        return 'Os custos de manutenção estão diminuindo';
      case MaintenanceCostTrend.stable:
        return 'Os custos de manutenção estão estáveis';
    }
  }
}
