import '../entities/vehicle_entity.dart';

/// Service para filtros de veículos (SRP - Single Responsibility)
/// Separa lógica de filtro do Notifier
abstract class VehicleFilterService {
  /// Filtra veículos por tipo
  List<VehicleEntity> filterByType(
    List<VehicleEntity> vehicles,
    VehicleType type,
  );

  /// Filtra veículos por tipo de combustível
  List<VehicleEntity> filterByFuelType(
    List<VehicleEntity> vehicles,
    FuelType fuelType,
  );

  /// Retorna apenas veículos ativos
  List<VehicleEntity> filterActive(List<VehicleEntity> vehicles);

  /// Busca veículos por query (nome, marca, modelo, placa)
  List<VehicleEntity> search(List<VehicleEntity> vehicles, String query);
}

/// Implementação do VehicleFilterService
class VehicleFilterServiceImpl implements VehicleFilterService {
  @override
  List<VehicleEntity> filterByType(
    List<VehicleEntity> vehicles,
    VehicleType type,
  ) {
    return vehicles.where((v) => v.type == type && v.isActive).toList();
  }

  @override
  List<VehicleEntity> filterByFuelType(
    List<VehicleEntity> vehicles,
    FuelType fuelType,
  ) {
    return vehicles
        .where((v) => v.supportedFuels.contains(fuelType) && v.isActive)
        .toList();
  }

  @override
  List<VehicleEntity> filterActive(List<VehicleEntity> vehicles) {
    return vehicles.where((v) => v.isActive).toList();
  }

  @override
  List<VehicleEntity> search(List<VehicleEntity> vehicles, String query) {
    if (query.isEmpty) return vehicles;

    final normalizedQuery = query.toLowerCase().trim();
    return vehicles.where((v) {
      final searchText = '${v.name} ${v.brand} ${v.model} ${v.licensePlate}'
          .toLowerCase();
      return searchText.contains(normalizedQuery);
    }).toList();
  }
}
