import '../../domain/entities/vehicle_entity.dart';

/// Service responsible for vehicle data formatting
///
/// Follows SRP by handling only formatting concerns
class VehicleFormatterService {
  /// Formats vehicle display name
  String formatVehicleName(VehicleEntity vehicle) {
    return '${vehicle.brand} ${vehicle.model} (${vehicle.year})';
  }

  /// Formats vehicle short name
  String formatVehicleShortName(VehicleEntity vehicle) {
    return vehicle.name.isEmpty ? formatVehicleName(vehicle) : vehicle.name;
  }

  /// Formats odometer reading with unit
  String formatOdometer(double odometer) {
    return '${odometer.toStringAsFixed(0)} km';
  }

  /// Formats vehicle type for display
  String formatVehicleType(VehicleType type) {
    switch (type) {
      case VehicleType.car:
        return 'Carro';
      case VehicleType.motorcycle:
        return 'Moto';
      case VehicleType.truck:
        return 'Caminhão';
      case VehicleType.van:
        return 'Van';
      case VehicleType.bus:
        return 'Ônibus';
    }
  }

  /// Formats fuel type for display
  String formatFuelType(FuelType fuelType) {
    switch (fuelType) {
      case FuelType.gasoline:
        return 'Gasolina';
      case FuelType.ethanol:
        return 'Etanol';
      case FuelType.diesel:
        return 'Diesel';
      case FuelType.gas:
        return 'Gás';
      case FuelType.hybrid:
        return 'Híbrido';
      case FuelType.electric:
        return 'Elétrico';
    }
  }

  /// Formats supported fuels list
  String formatSupportedFuels(List<FuelType> fuels) {
    if (fuels.isEmpty) return 'Nenhum';
    return fuels.map((f) => formatFuelType(f)).join(', ');
  }

  /// Formats vehicle status
  String formatVehicleStatus(VehicleEntity vehicle) {
    return vehicle.isActive ? 'Ativo' : 'Inativo';
  }

  /// Formats vehicle license plate
  String formatLicensePlate(String licensePlate) {
    if (licensePlate.isEmpty) return 'Sem placa';
    final cleanPlate = licensePlate.replaceAll(RegExp(r'[^A-Z0-9]'), '').toUpperCase();

    if (cleanPlate.length == 7) {
      if (RegExp(r'^[A-Z]{3}\d[A-Z]\d{2}$').hasMatch(cleanPlate)) {
        return '${cleanPlate.substring(0, 3)}-${cleanPlate.substring(3)}';
      }
      return '${cleanPlate.substring(0, 3)}-${cleanPlate.substring(3)}';
    }

    return licensePlate;
  }
}
