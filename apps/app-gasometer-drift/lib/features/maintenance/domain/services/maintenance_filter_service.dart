import 'package:core/core.dart' show injectable;

import '../entities/maintenance_entity.dart';

/// Filters for maintenance records
class MaintenanceFilters {
  const MaintenanceFilters({
    this.vehicleId,
    this.type,
    this.status,
    this.startDate,
    this.endDate,
    this.searchQuery = '',
    this.minCost,
    this.maxCost,
    this.urgencyLevel = 'all', // all, overdue, urgent, soon, normal
  });
  final String? vehicleId;
  final MaintenanceType? type;
  final MaintenanceStatus? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final String searchQuery;
  final double? minCost;
  final double? maxCost;
  final String urgencyLevel;

  MaintenanceFilters copyWith({
    String? vehicleId,
    MaintenanceType? type,
    MaintenanceStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    double? minCost,
    double? maxCost,
    String? urgencyLevel,
    bool clearVehicleId = false,
    bool clearType = false,
    bool clearStatus = false,
    bool clearDateRange = false,
    bool clearCostRange = false,
  }) {
    return MaintenanceFilters(
      vehicleId: clearVehicleId ? null : (vehicleId ?? this.vehicleId),
      type: clearType ? null : (type ?? this.type),
      status: clearStatus ? null : (status ?? this.status),
      startDate: clearDateRange ? null : (startDate ?? this.startDate),
      endDate: clearDateRange ? null : (endDate ?? this.endDate),
      searchQuery: searchQuery ?? this.searchQuery,
      minCost: clearCostRange ? null : (minCost ?? this.minCost),
      maxCost: clearCostRange ? null : (maxCost ?? this.maxCost),
      urgencyLevel: urgencyLevel ?? this.urgencyLevel,
    );
  }

  bool get hasActiveFilters {
    return vehicleId != null ||
        type != null ||
        status != null ||
        startDate != null ||
        endDate != null ||
        searchQuery.isNotEmpty ||
        minCost != null ||
        maxCost != null ||
        urgencyLevel != 'all';
  }

  /// Empty filters (no filtering applied)
  static const empty = MaintenanceFilters();
}

/// Sorting options for maintenance records
enum MaintenanceSortField {
  serviceDate,
  cost,
  type,
  status,
  odometer,
  title,
  urgency,
}

class MaintenanceSorting {
  const MaintenanceSorting({
    this.field = MaintenanceSortField.serviceDate,
    this.ascending = false, // Most recent first by default
  });
  final MaintenanceSortField field;
  final bool ascending;

  MaintenanceSorting copyWith({MaintenanceSortField? field, bool? ascending}) {
    return MaintenanceSorting(
      field: field ?? this.field,
      ascending: ascending ?? this.ascending,
    );
  }

  /// Toggle sort direction for same field, or set new field with default direction
  MaintenanceSorting toggleOrSet(MaintenanceSortField newField) {
    if (field == newField) {
      return copyWith(ascending: !ascending);
    } else {
      return MaintenanceSorting(
        field: newField,
        ascending: _getDefaultAscending(newField),
      );
    }
  }

  bool _getDefaultAscending(MaintenanceSortField field) {
    switch (field) {
      case MaintenanceSortField.serviceDate:
        return false; // Most recent first
      case MaintenanceSortField.cost:
        return false; // Highest cost first
      case MaintenanceSortField.urgency:
        return false; // Most urgent first
      case MaintenanceSortField.odometer:
        return false; // Highest odometer first
      case MaintenanceSortField.type:
      case MaintenanceSortField.status:
      case MaintenanceSortField.title:
        return true; // Alphabetical
    }
  }
}

/// Service for filtering and sorting maintenance records
@injectable
class MaintenanceFilterService {
  /// Apply filters to a list of maintenance records
  List<MaintenanceEntity> applyFilters(
    List<MaintenanceEntity> records,
    MaintenanceFilters filters,
  ) {
    var filteredRecords = records;
    if (filters.vehicleId != null) {
      filteredRecords =
          filteredRecords
              .where((record) => record.vehicleId == filters.vehicleId)
              .toList();
    }
    if (filters.type != null) {
      filteredRecords =
          filteredRecords
              .where((record) => record.type == filters.type)
              .toList();
    }
    if (filters.status != null) {
      filteredRecords =
          filteredRecords
              .where((record) => record.status == filters.status)
              .toList();
    }
    if (filters.startDate != null) {
      final startOfDay = DateTime(
        filters.startDate!.year,
        filters.startDate!.month,
        filters.startDate!.day,
      );
      filteredRecords =
          filteredRecords
              .where(
                (record) => record.serviceDate.isAfter(
                  startOfDay.subtract(const Duration(days: 1)),
                ),
              )
              .toList();
    }

    if (filters.endDate != null) {
      final endOfDay = DateTime(
        filters.endDate!.year,
        filters.endDate!.month,
        filters.endDate!.day,
        23,
        59,
        59,
      );
      filteredRecords =
          filteredRecords
              .where((record) => record.serviceDate.isBefore(endOfDay))
              .toList();
    }
    if (filters.minCost != null) {
      filteredRecords =
          filteredRecords
              .where((record) => record.cost >= filters.minCost!)
              .toList();
    }

    if (filters.maxCost != null) {
      filteredRecords =
          filteredRecords
              .where((record) => record.cost <= filters.maxCost!)
              .toList();
    }
    if (filters.urgencyLevel != 'all') {
      filteredRecords =
          filteredRecords
              .where((record) => record.urgencyLevel == filters.urgencyLevel)
              .toList();
    }
    if (filters.searchQuery.isNotEmpty) {
      final query = filters.searchQuery.toLowerCase();
      filteredRecords =
          filteredRecords.where((record) {
            return record.title.toLowerCase().contains(query) ||
                record.description.toLowerCase().contains(query) ||
                record.type.displayName.toLowerCase().contains(query) ||
                (record.workshopName?.toLowerCase().contains(query) == true) ||
                (record.notes?.toLowerCase().contains(query) == true);
          }).toList();
    }

    return filteredRecords;
  }

  /// Apply sorting to a list of maintenance records
  List<MaintenanceEntity> applySorting(
    List<MaintenanceEntity> records,
    MaintenanceSorting sorting,
  ) {
    final sortedRecords = List<MaintenanceEntity>.from(records);

    sortedRecords.sort((a, b) {
      int comparison = 0;

      switch (sorting.field) {
        case MaintenanceSortField.serviceDate:
          comparison = a.serviceDate.compareTo(b.serviceDate);
          break;
        case MaintenanceSortField.cost:
          comparison = a.cost.compareTo(b.cost);
          break;
        case MaintenanceSortField.type:
          comparison = a.type.displayName.compareTo(b.type.displayName);
          break;
        case MaintenanceSortField.status:
          comparison = a.status.displayName.compareTo(b.status.displayName);
          break;
        case MaintenanceSortField.odometer:
          comparison = a.odometer.compareTo(b.odometer);
          break;
        case MaintenanceSortField.title:
          comparison = a.title.compareTo(b.title);
          break;
        case MaintenanceSortField.urgency:
          comparison = _compareUrgency(a.urgencyLevel, b.urgencyLevel);
          break;
      }

      return sorting.ascending ? comparison : -comparison;
    });

    return sortedRecords;
  }

  /// Apply both filters and sorting
  List<MaintenanceEntity> applyFiltersAndSorting(
    List<MaintenanceEntity> records,
    MaintenanceFilters filters,
    MaintenanceSorting sorting,
  ) {
    final filteredRecords = applyFilters(records, filters);
    return applySorting(filteredRecords, sorting);
  }

  /// Get records by specific criteria
  List<MaintenanceEntity> getRecordsByType(
    List<MaintenanceEntity> records,
    MaintenanceType type,
  ) {
    return records.where((record) => record.type == type).toList();
  }

  List<MaintenanceEntity> getRecordsByStatus(
    List<MaintenanceEntity> records,
    MaintenanceStatus status,
  ) {
    return records.where((record) => record.status == status).toList();
  }

  List<MaintenanceEntity> getRecordsByUrgency(
    List<MaintenanceEntity> records,
    String urgencyLevel,
  ) {
    return records
        .where((record) => record.urgencyLevel == urgencyLevel)
        .toList();
  }

  List<MaintenanceEntity> getHighCostRecords(
    List<MaintenanceEntity> records, {
    double threshold = 1000.0,
  }) {
    return records.where((record) => record.cost >= threshold).toList();
  }

  List<MaintenanceEntity> getRecentRecords(
    List<MaintenanceEntity> records, {
    int days = 30,
  }) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return records
        .where((record) => record.serviceDate.isAfter(cutoff))
        .toList();
  }

  List<MaintenanceEntity> getUpcomingRecords(
    List<MaintenanceEntity> records, {
    int days = 30,
  }) {
    final cutoff = DateTime.now().add(Duration(days: days));
    return records
        .where(
          (record) =>
              record.nextServiceDate != null &&
              record.nextServiceDate!.isBefore(cutoff) &&
              record.nextServiceDate!.isAfter(DateTime.now()),
        )
        .toList();
  }

  List<MaintenanceEntity> getOverdueRecords(
    List<MaintenanceEntity> records, {
    double? currentOdometer,
  }) {
    final now = DateTime.now();
    return records.where((record) {
      if (record.nextServiceDate != null &&
          record.nextServiceDate!.isBefore(now)) {
        return true;
      }
      if (currentOdometer != null &&
          record.nextServiceOdometer != null &&
          currentOdometer >= record.nextServiceOdometer!) {
        return true;
      }

      return false;
    }).toList();
  }

  /// Search records by text query
  List<MaintenanceEntity> searchRecords(
    List<MaintenanceEntity> records,
    String query,
  ) {
    if (query.trim().isEmpty) return records;

    final lowerQuery = query.toLowerCase().trim();
    return records.where((record) {
      return record.title.toLowerCase().contains(lowerQuery) ||
          record.description.toLowerCase().contains(lowerQuery) ||
          record.type.displayName.toLowerCase().contains(lowerQuery) ||
          record.status.displayName.toLowerCase().contains(lowerQuery) ||
          (record.workshopName?.toLowerCase().contains(lowerQuery) == true) ||
          (record.notes?.toLowerCase().contains(lowerQuery) == true);
    }).toList();
  }

  /// Get records within date range
  List<MaintenanceEntity> getRecordsByDateRange(
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

  /// Get records within cost range
  List<MaintenanceEntity> getRecordsByCostRange(
    List<MaintenanceEntity> records,
    double minCost,
    double maxCost,
  ) {
    return records.where((record) {
      return record.cost >= minCost && record.cost <= maxCost;
    }).toList();
  }

  int _compareUrgency(String a, String b) {
    const urgencyOrder = {
      'overdue': 0,
      'urgent': 1,
      'soon': 2,
      'normal': 3,
      'none': 4,
    };

    final aOrder = urgencyOrder[a] ?? 5;
    final bOrder = urgencyOrder[b] ?? 5;

    return aOrder.compareTo(bOrder);
  }

  /// Calculate statistics for filtered records
  Map<String, dynamic> calculateStatistics(List<MaintenanceEntity> records) {
    if (records.isEmpty) {
      return {
        'totalRecords': 0,
        'totalCost': 0.0,
        'averageCost': 0.0,
        'byType': <String, int>{},
        'byStatus': <String, int>{},
        'byUrgency': <String, int>{},
      };
    }

    final totalCost = records.fold<double>(
      0,
      (sum, record) => sum + record.cost,
    );
    final averageCost = totalCost / records.length;
    final byType = <String, int>{};
    final byStatus = <String, int>{};
    final byUrgency = <String, int>{};

    for (final record in records) {
      byType[record.type.displayName] =
          (byType[record.type.displayName] ?? 0) + 1;
      byStatus[record.status.displayName] =
          (byStatus[record.status.displayName] ?? 0) + 1;
      byUrgency[record.urgencyLevel] =
          (byUrgency[record.urgencyLevel] ?? 0) + 1;
    }

    return {
      'totalRecords': records.length,
      'totalCost': totalCost,
      'averageCost': averageCost,
      'byType': byType,
      'byStatus': byStatus,
      'byUrgency': byUrgency,
      'highestCost': records.map((r) => r.cost).reduce((a, b) => a > b ? a : b),
      'lowestCost': records.map((r) => r.cost).reduce((a, b) => a < b ? a : b),
    };
  }
}
