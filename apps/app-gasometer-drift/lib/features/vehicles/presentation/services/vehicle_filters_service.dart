import '../../domain/entities/vehicle_entity.dart';

/// Service responsible for vehicle filtering logic
///
/// Follows SRP by handling only filter concerns
class VehicleFiltersService {
  /// Filters vehicles by type
  List<VehicleEntity> filterByType(
    List<VehicleEntity> vehicles,
    VehicleType type,
  ) {
    return vehicles.where((v) => v.type == type && v.isActive).toList();
  }

  /// Filters vehicles by fuel type
  List<VehicleEntity> filterByFuelType(
    List<VehicleEntity> vehicles,
    FuelType fuelType,
  ) {
    return vehicles
        .where((v) => v.supportedFuels.contains(fuelType) && v.isActive)
        .toList();
  }

  /// Filters only active vehicles
  List<VehicleEntity> filterActive(List<VehicleEntity> vehicles) {
    return vehicles.where((v) => v.isActive).toList();
  }

  /// Filters only inactive vehicles
  List<VehicleEntity> filterInactive(List<VehicleEntity> vehicles) {
    return vehicles.where((v) => !v.isActive).toList();
  }

  /// Searches vehicles by query (name, brand, model, licensePlate)
  List<VehicleEntity> searchVehicles(
    List<VehicleEntity> vehicles,
    String query,
  ) {
    if (query.trim().isEmpty) {
      return vehicles;
    }

    final queryLower = query.toLowerCase();

    return vehicles.where((vehicle) {
      return vehicle.name.toLowerCase().contains(queryLower) ||
          vehicle.brand.toLowerCase().contains(queryLower) ||
          vehicle.model.toLowerCase().contains(queryLower) ||
          vehicle.licensePlate.toLowerCase().contains(queryLower);
    }).toList();
  }

  /// Sorts vehicles by name
  List<VehicleEntity> sortByName(List<VehicleEntity> vehicles,
      {bool ascending = true}) {
    final sorted = List<VehicleEntity>.from(vehicles);
    sorted.sort((a, b) {
      final comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      return ascending ? comparison : -comparison;
    });
    return sorted;
  }

  /// Sorts vehicles by brand/model
  List<VehicleEntity> sortByBrandModel(List<VehicleEntity> vehicles,
      {bool ascending = true}) {
    final sorted = List<VehicleEntity>.from(vehicles);
    sorted.sort((a, b) {
      final aBrand = '${a.brand} ${a.model}'.toLowerCase();
      final bBrand = '${b.brand} ${b.model}'.toLowerCase();
      final comparison = aBrand.compareTo(bBrand);
      return ascending ? comparison : -comparison;
    });
    return sorted;
  }

  /// Sorts vehicles by year
  List<VehicleEntity> sortByYear(List<VehicleEntity> vehicles,
      {bool ascending = true}) {
    final sorted = List<VehicleEntity>.from(vehicles);
    sorted.sort((a, b) {
      final comparison = a.year.compareTo(b.year);
      return ascending ? comparison : -comparison;
    });
    return sorted;
  }

  /// Sorts vehicles by odometer
  List<VehicleEntity> sortByOdometer(List<VehicleEntity> vehicles,
      {bool ascending = true}) {
    final sorted = List<VehicleEntity>.from(vehicles);
    sorted.sort((a, b) {
      final comparison = a.currentOdometer.compareTo(b.currentOdometer);
      return ascending ? comparison : -comparison;
    });
    return sorted;
  }
}
