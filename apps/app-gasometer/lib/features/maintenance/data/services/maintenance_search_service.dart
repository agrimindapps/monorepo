import 'package:injectable/injectable.dart';

import '../../domain/entities/maintenance_entity.dart';

/// Service responsible for searching and filtering maintenance records
/// Follows SRP by handling only search and filter logic
@lazySingleton
class MaintenanceSearchService {
  /// Search maintenance records by query string
  /// Searches in: title, description, workshop name, notes
  List<MaintenanceEntity> searchRecords(
    List<MaintenanceEntity> records,
    String query,
  ) {
    if (query.trim().isEmpty) return records;

    final lowerQuery = query.toLowerCase().trim();

    return records.where((record) {
      return _matchesQuery(record, lowerQuery);
    }).toList();
  }

  /// Filter records by vehicle ID
  List<MaintenanceEntity> filterByVehicle(
    List<MaintenanceEntity> records,
    String vehicleId,
  ) {
    return records.where((record) => record.vehicleId == vehicleId).toList();
  }

  /// Filter records by maintenance type
  List<MaintenanceEntity> filterByType(
    List<MaintenanceEntity> records,
    MaintenanceType type,
  ) {
    return records.where((record) => record.type == type).toList();
  }

  /// Filter records by status
  List<MaintenanceEntity> filterByStatus(
    List<MaintenanceEntity> records,
    MaintenanceStatus status,
  ) {
    return records.where((record) => record.status == status).toList();
  }

  /// Filter records by date range
  List<MaintenanceEntity> filterByDateRange(
    List<MaintenanceEntity> records,
    DateTime startDate,
    DateTime endDate,
  ) {
    return records.where((record) {
      return record.serviceDate.isAfter(
            startDate.subtract(const Duration(days: 1)),
          ) &&
          record.serviceDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Filter records by cost range
  List<MaintenanceEntity> filterByCostRange(
    List<MaintenanceEntity> records,
    double minCost,
    double maxCost,
  ) {
    return records.where((record) {
      return record.cost >= minCost && record.cost <= maxCost;
    }).toList();
  }

  /// Get upcoming maintenance records (next service date in future)
  List<MaintenanceEntity> getUpcomingMaintenance(
    List<MaintenanceEntity> records,
  ) {
    final now = DateTime.now();
    return records.where((record) {
        return record.nextServiceDate != null &&
            record.nextServiceDate!.isAfter(now);
      }).toList()
      ..sort((a, b) => a.nextServiceDate!.compareTo(b.nextServiceDate!));
  }

  /// Get overdue maintenance records (next service date in past)
  List<MaintenanceEntity> getOverdueMaintenance(
    List<MaintenanceEntity> records,
  ) {
    final now = DateTime.now();
    return records.where((record) {
        return record.nextServiceDate != null &&
            record.nextServiceDate!.isBefore(now) &&
            record.status != MaintenanceStatus.completed;
      }).toList()
      ..sort((a, b) => a.nextServiceDate!.compareTo(b.nextServiceDate!));
  }

  /// Get pending maintenance records
  List<MaintenanceEntity> getPendingMaintenance(
    List<MaintenanceEntity> records,
  ) {
    return records
        .where((record) => record.status == MaintenanceStatus.pending)
        .toList();
  }

  /// Get completed maintenance records
  List<MaintenanceEntity> getCompletedMaintenance(
    List<MaintenanceEntity> records,
  ) {
    return records
        .where((record) => record.status == MaintenanceStatus.completed)
        .toList();
  }

  /// Sort records by date (descending by default)
  List<MaintenanceEntity> sortByDate(
    List<MaintenanceEntity> records, {
    bool descending = true,
  }) {
    final sorted = List<MaintenanceEntity>.from(records);
    if (descending) {
      sorted.sort((a, b) => b.serviceDate.compareTo(a.serviceDate));
    } else {
      sorted.sort((a, b) => a.serviceDate.compareTo(b.serviceDate));
    }
    return sorted;
  }

  /// Sort records by cost
  List<MaintenanceEntity> sortByCost(
    List<MaintenanceEntity> records, {
    bool descending = true,
  }) {
    final sorted = List<MaintenanceEntity>.from(records);
    if (descending) {
      sorted.sort((a, b) => b.cost.compareTo(a.cost));
    } else {
      sorted.sort((a, b) => a.cost.compareTo(b.cost));
    }
    return sorted;
  }

  /// Sort records by odometer
  List<MaintenanceEntity> sortByOdometer(
    List<MaintenanceEntity> records, {
    bool descending = true,
  }) {
    final sorted = List<MaintenanceEntity>.from(records);
    if (descending) {
      sorted.sort((a, b) => b.odometer.compareTo(a.odometer));
    } else {
      sorted.sort((a, b) => a.odometer.compareTo(b.odometer));
    }
    return sorted;
  }

  /// Apply multiple filters at once
  List<MaintenanceEntity> applyFilters(
    List<MaintenanceEntity> records, {
    String? query,
    String? vehicleId,
    MaintenanceType? type,
    MaintenanceStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    double? minCost,
    double? maxCost,
  }) {
    var filtered = records;

    if (query != null && query.isNotEmpty) {
      filtered = searchRecords(filtered, query);
    }

    if (vehicleId != null) {
      filtered = filterByVehicle(filtered, vehicleId);
    }

    if (type != null) {
      filtered = filterByType(filtered, type);
    }

    if (status != null) {
      filtered = filterByStatus(filtered, status);
    }

    if (startDate != null && endDate != null) {
      filtered = filterByDateRange(filtered, startDate, endDate);
    }

    if (minCost != null && maxCost != null) {
      filtered = filterByCostRange(filtered, minCost, maxCost);
    }

    return filtered;
  }

  // Private helper method
  bool _matchesQuery(MaintenanceEntity record, String query) {
    return record.title.toLowerCase().contains(query) ||
        record.description.toLowerCase().contains(query) ||
        record.workshopName?.toLowerCase().contains(query) == true ||
        record.notes?.toLowerCase().contains(query) == true;
  }
}
