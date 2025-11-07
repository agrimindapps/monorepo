import '../../domain/entities/maintenance_entity.dart';

/// Service responsible for filtering and searching maintenance records
///
/// Follows SRP by handling only filtering logic
class MaintenanceFiltersService {
  /// Filters records by type
  List<MaintenanceEntity> filterByType(
    List<MaintenanceEntity> records,
    MaintenanceType type,
  ) {
    return records.where((r) => r.type == type).toList();
  }

  /// Filters records by status
  List<MaintenanceEntity> filterByStatus(
    List<MaintenanceEntity> records,
    MaintenanceStatus status,
  ) {
    return records.where((r) => r.status == status).toList();
  }

  /// Filters records by vehicle
  List<MaintenanceEntity> filterByVehicle(
    List<MaintenanceEntity> records,
    String vehicleId,
  ) {
    return records.where((r) => r.vehicleId == vehicleId).toList();
  }

  /// Filters completed records
  List<MaintenanceEntity> filterCompleted(List<MaintenanceEntity> records) {
    return records.where((r) => r.status == MaintenanceStatus.completed).toList();
  }

  /// Filters pending records
  List<MaintenanceEntity> filterPending(List<MaintenanceEntity> records) {
    return records.where((r) => r.status == MaintenanceStatus.pending).toList();
  }

  /// Filters in-progress records
  List<MaintenanceEntity> filterInProgress(List<MaintenanceEntity> records) {
    return records.where((r) => r.status == MaintenanceStatus.inProgress).toList();
  }

  /// Filters overdue maintenance records
  List<MaintenanceEntity> filterOverdue(List<MaintenanceEntity> records) {
    final now = DateTime.now();
    return records.where((record) {
      if (record.nextServiceDate == null) return false;
      return record.nextServiceDate!.isBefore(now);
    }).toList();
  }

  /// Filters upcoming maintenance (next 30 days)
  List<MaintenanceEntity> filterUpcoming(
    List<MaintenanceEntity> records, {
    int days = 30,
  }) {
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days));

    return records.where((record) {
      if (record.nextServiceDate == null) return false;
      return record.nextServiceDate!.isAfter(now) &&
          record.nextServiceDate!.isBefore(futureDate);
    }).toList();
  }

  /// Filters records by date range
  List<MaintenanceEntity> filterByDateRange(
    List<MaintenanceEntity> records,
    DateTime startDate,
    DateTime endDate,
  ) {
    return records.where((record) {
      return record.serviceDate.isAfter(startDate) &&
          record.serviceDate.isBefore(endDate);
    }).toList();
  }

  /// Filters high-cost maintenance (>= R$ 1000)
  List<MaintenanceEntity> filterHighCost(List<MaintenanceEntity> records) {
    return records.where((r) => r.cost >= 1000.0).toList();
  }

  /// Filters low-cost maintenance (< R$ 100)
  List<MaintenanceEntity> filterLowCost(List<MaintenanceEntity> records) {
    return records.where((r) => r.cost < 100.0).toList();
  }

  /// Filters records with workshop info
  List<MaintenanceEntity> filterWithWorkshop(List<MaintenanceEntity> records) {
    return records.where((r) => r.hasWorkshopInfo).toList();
  }

  /// Filters records with photos
  List<MaintenanceEntity> filterWithPhotos(List<MaintenanceEntity> records) {
    return records.where((r) => r.hasPhotos).toList();
  }

  /// Filters records with invoices
  List<MaintenanceEntity> filterWithInvoices(List<MaintenanceEntity> records) {
    return records.where((r) => r.hasInvoices).toList();
  }

  /// Search records by query (title, description, workshop)
  List<MaintenanceEntity> searchRecords(
    List<MaintenanceEntity> records,
    String query,
  ) {
    if (query.isEmpty) return records;

    final lowerQuery = query.toLowerCase();
    return records.where((record) {
      return record.title.toLowerCase().contains(lowerQuery) ||
          record.description.toLowerCase().contains(lowerQuery) ||
          (record.workshopName?.toLowerCase().contains(lowerQuery) ?? false) ||
          (record.notes?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// Sorts records by date (most recent first)
  List<MaintenanceEntity> sortByDate(
    List<MaintenanceEntity> records, {
    bool ascending = false,
  }) {
    final sorted = List<MaintenanceEntity>.from(records);
    sorted.sort((a, b) {
      final comparison = a.serviceDate.compareTo(b.serviceDate);
      return ascending ? comparison : -comparison;
    });
    return sorted;
  }

  /// Sorts records by cost
  List<MaintenanceEntity> sortByCost(
    List<MaintenanceEntity> records, {
    bool ascending = true,
  }) {
    final sorted = List<MaintenanceEntity>.from(records);
    sorted.sort((a, b) {
      final comparison = a.cost.compareTo(b.cost);
      return ascending ? comparison : -comparison;
    });
    return sorted;
  }

  /// Sorts records by type
  List<MaintenanceEntity> sortByType(
    List<MaintenanceEntity> records, {
    bool ascending = true,
  }) {
    final sorted = List<MaintenanceEntity>.from(records);
    sorted.sort((a, b) {
      final comparison = a.type.name.compareTo(b.type.name);
      return ascending ? comparison : -comparison;
    });
    return sorted;
  }

  /// Sorts records by status
  List<MaintenanceEntity> sortByStatus(
    List<MaintenanceEntity> records, {
    bool ascending = true,
  }) {
    final sorted = List<MaintenanceEntity>.from(records);
    sorted.sort((a, b) {
      final comparison = a.status.name.compareTo(b.status.name);
      return ascending ? comparison : -comparison;
    });
    return sorted;
  }

  /// Applies multiple filters
  List<MaintenanceEntity> applyFilters(
    List<MaintenanceEntity> records, {
    MaintenanceType? type,
    MaintenanceStatus? status,
    String? vehicleId,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    bool? highCostOnly,
    bool? withWorkshopOnly,
  }) {
    var filtered = List<MaintenanceEntity>.from(records);

    if (type != null) {
      filtered = filterByType(filtered, type);
    }

    if (status != null) {
      filtered = filterByStatus(filtered, status);
    }

    if (vehicleId != null && vehicleId.isNotEmpty) {
      filtered = filterByVehicle(filtered, vehicleId);
    }

    if (startDate != null && endDate != null) {
      filtered = filterByDateRange(filtered, startDate, endDate);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      filtered = searchRecords(filtered, searchQuery);
    }

    if (highCostOnly == true) {
      filtered = filterHighCost(filtered);
    }

    if (withWorkshopOnly == true) {
      filtered = filterWithWorkshop(filtered);
    }

    return filtered;
  }
}
