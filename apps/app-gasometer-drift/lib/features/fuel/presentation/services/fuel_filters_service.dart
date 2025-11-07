import '../../domain/entities/fuel_record_entity.dart';

/// Service responsible for filtering fuel records
///
/// Follows SRP by handling only filter logic
class FuelFiltersService {
  /// Applies search query to fuel records
  List<FuelRecordEntity> applySearchFilter(
    List<FuelRecordEntity> records,
    String searchQuery,
  ) {
    if (searchQuery.isEmpty) {
      return records;
    }

    final searchLower = searchQuery.toLowerCase();

    return records.where((record) {
      return record.gasStationName?.toLowerCase().contains(searchLower) == true ||
          record.gasStationBrand?.toLowerCase().contains(searchLower) == true ||
          record.notes?.toLowerCase().contains(searchLower) == true ||
          record.fuelType.displayName.toLowerCase().contains(searchLower);
    }).toList();
  }

  /// Filters records by vehicle ID
  List<FuelRecordEntity> filterByVehicle(
    List<FuelRecordEntity> records,
    String vehicleId,
  ) {
    if (vehicleId.isEmpty) {
      return records;
    }

    return records.where((record) => record.vehicleId == vehicleId).toList();
  }

  /// Applies combined filters (search + vehicle)
  List<FuelRecordEntity> applyFilters(
    List<FuelRecordEntity> records, {
    String? searchQuery,
    String? vehicleId,
  }) {
    var filtered = records;

    if (vehicleId != null && vehicleId.isNotEmpty) {
      filtered = filterByVehicle(filtered, vehicleId);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      filtered = applySearchFilter(filtered, searchQuery);
    }

    return filtered;
  }
}
