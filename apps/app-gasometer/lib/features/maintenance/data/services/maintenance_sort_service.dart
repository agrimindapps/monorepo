import 'package:injectable/injectable.dart';

import '../../domain/entities/maintenance_entity.dart';

/// Service responsible for sorting maintenance records
/// Follows SRP by handling only sorting logic
@lazySingleton
class MaintenanceSortService {
  /// Sort records by service date
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

  /// Sort records by odometer reading
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

  /// Sort records by next service date (upcoming first)
  List<MaintenanceEntity> sortByNextServiceDate(
    List<MaintenanceEntity> records,
  ) {
    final withNextService =
        records.where((r) => r.nextServiceDate != null).toList()
          ..sort((a, b) => a.nextServiceDate!.compareTo(b.nextServiceDate!));

    final withoutNextService = records
        .where((r) => r.nextServiceDate == null)
        .toList();

    return [...withNextService, ...withoutNextService];
  }

  /// Sort records by creation date
  List<MaintenanceEntity> sortByCreatedAt(
    List<MaintenanceEntity> records, {
    bool descending = true,
  }) {
    final sorted = List<MaintenanceEntity>.from(records);
    if (descending) {
      sorted.sort((a, b) {
        final aDate = a.createdAt ?? DateTime(1970);
        final bDate = b.createdAt ?? DateTime(1970);
        return bDate.compareTo(aDate);
      });
    } else {
      sorted.sort((a, b) {
        final aDate = a.createdAt ?? DateTime(1970);
        final bDate = b.createdAt ?? DateTime(1970);
        return aDate.compareTo(bDate);
      });
    }
    return sorted;
  }

  /// Sort records by update date
  List<MaintenanceEntity> sortByUpdatedAt(
    List<MaintenanceEntity> records, {
    bool descending = true,
  }) {
    final sorted = List<MaintenanceEntity>.from(records);
    if (descending) {
      sorted.sort((a, b) {
        final aDate = a.updatedAt ?? DateTime(1970);
        final bDate = b.updatedAt ?? DateTime(1970);
        return bDate.compareTo(aDate);
      });
    } else {
      sorted.sort((a, b) {
        final aDate = a.updatedAt ?? DateTime(1970);
        final bDate = b.updatedAt ?? DateTime(1970);
        return aDate.compareTo(bDate);
      });
    }
    return sorted;
  }

  /// Sort records by type (following a predefined order)
  List<MaintenanceEntity> sortByType(
    List<MaintenanceEntity> records, {
    bool descending = false,
  }) {
    final typeOrder = {
      MaintenanceType.emergency: 0,
      MaintenanceType.corrective: 1,
      MaintenanceType.preventive: 2,
      MaintenanceType.inspection: 3,
    };

    final sorted = List<MaintenanceEntity>.from(records);
    if (descending) {
      sorted.sort(
        (a, b) =>
            (typeOrder[b.type] ?? 999).compareTo(typeOrder[a.type] ?? 999),
      );
    } else {
      sorted.sort(
        (a, b) =>
            (typeOrder[a.type] ?? 999).compareTo(typeOrder[b.type] ?? 999),
      );
    }
    return sorted;
  }

  /// Sort records by status (following a predefined order)
  List<MaintenanceEntity> sortByStatus(
    List<MaintenanceEntity> records, {
    bool descending = false,
  }) {
    final statusOrder = {
      MaintenanceStatus.inProgress: 0,
      MaintenanceStatus.pending: 1,
      MaintenanceStatus.completed: 2,
      MaintenanceStatus.cancelled: 3,
    };

    final sorted = List<MaintenanceEntity>.from(records);
    if (descending) {
      sorted.sort(
        (a, b) => (statusOrder[b.status] ?? 999).compareTo(
          statusOrder[a.status] ?? 999,
        ),
      );
    } else {
      sorted.sort(
        (a, b) => (statusOrder[a.status] ?? 999).compareTo(
          statusOrder[b.status] ?? 999,
        ),
      );
    }
    return sorted;
  }

  /// Sort records by title (alphabetically)
  List<MaintenanceEntity> sortByTitle(
    List<MaintenanceEntity> records, {
    bool descending = false,
  }) {
    final sorted = List<MaintenanceEntity>.from(records);
    if (descending) {
      sorted.sort((a, b) => b.title.compareTo(a.title));
    } else {
      sorted.sort((a, b) => a.title.compareTo(b.title));
    }
    return sorted;
  }

  /// Sort records by workshop name (alphabetically)
  List<MaintenanceEntity> sortByWorkshop(
    List<MaintenanceEntity> records, {
    bool descending = false,
  }) {
    final sorted = List<MaintenanceEntity>.from(records);
    if (descending) {
      sorted.sort((a, b) {
        final aName = a.workshopName ?? '';
        final bName = b.workshopName ?? '';
        return bName.compareTo(aName);
      });
    } else {
      sorted.sort((a, b) {
        final aName = a.workshopName ?? '';
        final bName = b.workshopName ?? '';
        return aName.compareTo(bName);
      });
    }
    return sorted;
  }

  /// Sort records using a custom comparator
  List<MaintenanceEntity> sortCustom(
    List<MaintenanceEntity> records,
    int Function(MaintenanceEntity a, MaintenanceEntity b) comparator,
  ) {
    final sorted = List<MaintenanceEntity>.from(records);
    sorted.sort(comparator);
    return sorted;
  }

  /// Sort by multiple criteria
  /// Example: sort by status first, then by date
  List<MaintenanceEntity> sortMultiple(
    List<MaintenanceEntity> records,
    List<int Function(MaintenanceEntity a, MaintenanceEntity b)> comparators,
  ) {
    final sorted = List<MaintenanceEntity>.from(records);
    sorted.sort((a, b) {
      for (final comparator in comparators) {
        final result = comparator(a, b);
        if (result != 0) return result;
      }
      return 0;
    });
    return sorted;
  }

  /// Get a comparator for date sorting
  int Function(MaintenanceEntity, MaintenanceEntity) dateComparator({
    bool descending = true,
  }) {
    return (a, b) => descending
        ? b.serviceDate.compareTo(a.serviceDate)
        : a.serviceDate.compareTo(b.serviceDate);
  }

  /// Get a comparator for cost sorting
  int Function(MaintenanceEntity, MaintenanceEntity) costComparator({
    bool descending = true,
  }) {
    return (a, b) =>
        descending ? b.cost.compareTo(a.cost) : a.cost.compareTo(b.cost);
  }

  /// Get a comparator for type sorting
  int Function(MaintenanceEntity, MaintenanceEntity) typeComparator({
    bool descending = false,
  }) {
    final typeOrder = {
      MaintenanceType.emergency: 0,
      MaintenanceType.corrective: 1,
      MaintenanceType.preventive: 2,
      MaintenanceType.inspection: 3,
    };

    return (a, b) {
      final aOrder = typeOrder[a.type] ?? 999;
      final bOrder = typeOrder[b.type] ?? 999;
      return descending ? bOrder.compareTo(aOrder) : aOrder.compareTo(bOrder);
    };
  }

  /// Get a comparator for status sorting
  int Function(MaintenanceEntity, MaintenanceEntity) statusComparator({
    bool descending = false,
  }) {
    final statusOrder = {
      MaintenanceStatus.inProgress: 0,
      MaintenanceStatus.pending: 1,
      MaintenanceStatus.completed: 2,
      MaintenanceStatus.cancelled: 3,
    };

    return (a, b) {
      final aOrder = statusOrder[a.status] ?? 999;
      final bOrder = statusOrder[b.status] ?? 999;
      return descending ? bOrder.compareTo(aOrder) : aOrder.compareTo(bOrder);
    };
  }
}
