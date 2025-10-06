import '../../domain/entities/maintenance_entity.dart';

/// Statistics model for maintenance records
class MaintenanceStatistics {
  const MaintenanceStatistics({
    required this.totalCost,
    required this.preventiveCount,
    required this.correctiveCount,
    required this.inspectionCount,
    required this.emergencyCount,
    required this.totalRecords,
    required this.recentRecords,
    required this.lastUpdated,
  });

  final double totalCost;
  final int preventiveCount;
  final int correctiveCount;
  final int inspectionCount;
  final int emergencyCount;
  final int totalRecords;
  final List<MaintenanceEntity> recentRecords;
  final DateTime lastUpdated;

  bool get needsRecalculation {
    final now = DateTime.now();
    const maxCacheTime = Duration(minutes: 5);
    return now.difference(lastUpdated) > maxCacheTime;
  }

  String get formattedTotalCost => 'R\$ ${totalCost.toStringAsFixed(2)}';

  String get maintenanceCountSummary {
    return '$preventiveCount preventivas, $correctiveCount corretivas, $inspectionCount revisões, $emergencyCount emergenciais';
  }
}

/// Service responsible for calculating maintenance statistics
///
/// Follows SRP by handling only statistical calculations
class MaintenanceStatisticsService {
  /// Calculates comprehensive statistics for maintenance records
  MaintenanceStatistics calculateStatistics(List<MaintenanceEntity> records) {
    if (records.isEmpty) {
      return MaintenanceStatistics(
        totalCost: 0.0,
        preventiveCount: 0,
        correctiveCount: 0,
        inspectionCount: 0,
        emergencyCount: 0,
        totalRecords: 0,
        recentRecords: [],
        lastUpdated: DateTime.now(),
      );
    }

    final totalCost = records.fold<double>(
      0.0,
      (sum, record) => sum + record.cost,
    );

    int preventiveCount = 0;
    int correctiveCount = 0;
    int inspectionCount = 0;
    int emergencyCount = 0;

    for (final record in records) {
      switch (record.type) {
        case MaintenanceType.preventive:
          preventiveCount++;
          break;
        case MaintenanceType.corrective:
          correctiveCount++;
          break;
        case MaintenanceType.inspection:
          inspectionCount++;
          break;
        case MaintenanceType.emergency:
          emergencyCount++;
          break;
      }
    }
    final sortedRecords = List<MaintenanceEntity>.from(records);
    sortedRecords.sort((a, b) => b.serviceDate.compareTo(a.serviceDate));
    final recentRecords = sortedRecords.take(5).toList();

    return MaintenanceStatistics(
      totalCost: totalCost,
      preventiveCount: preventiveCount,
      correctiveCount: correctiveCount,
      inspectionCount: inspectionCount,
      emergencyCount: emergencyCount,
      totalRecords: records.length,
      recentRecords: recentRecords,
      lastUpdated: DateTime.now(),
    );
  }

  /// Gets maintenance count by type as a map
  Map<MaintenanceType, int> getMaintenanceCountByType(
    MaintenanceStatistics stats,
  ) {
    return {
      MaintenanceType.preventive: stats.preventiveCount,
      MaintenanceType.corrective: stats.correctiveCount,
      MaintenanceType.inspection: stats.inspectionCount,
      MaintenanceType.emergency: stats.emergencyCount,
    };
  }

  /// Gets overdue maintenance records
  List<MaintenanceEntity> getOverdueMaintenance(
    List<MaintenanceEntity> records,
  ) {
    final now = DateTime.now();
    return records.where((record) {
      if (record.nextServiceDate == null) return false;
      return record.nextServiceDate!.isBefore(now);
    }).toList();
  }

  /// Gets pending maintenance records
  List<MaintenanceEntity> getPendingMaintenance(
    List<MaintenanceEntity> records,
  ) {
    return records
        .where((record) => record.status == MaintenanceStatus.pending)
        .toList();
  }

  /// Gets completed maintenance records
  List<MaintenanceEntity> getCompletedMaintenance(
    List<MaintenanceEntity> records,
  ) {
    return records
        .where((record) => record.status == MaintenanceStatus.completed)
        .toList();
  }
}
