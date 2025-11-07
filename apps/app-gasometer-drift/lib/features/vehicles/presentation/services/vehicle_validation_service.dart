import '../../domain/entities/vehicle_entity.dart';

/// Service responsible for vehicle validation logic
///
/// Follows SRP by handling only validation concerns
class VehicleValidationService {
  /// Validates a vehicle entity
  Map<String, String> validateVehicle(VehicleEntity vehicle) {
    final errors = <String, String>{};
    if (vehicle.name.trim().isEmpty) {
      errors['name'] = 'Nome é obrigatório';
    } else if (vehicle.name.trim().length < 2) {
      errors['name'] = 'Nome deve ter pelo menos 2 caracteres';
    }
    if (vehicle.brand.trim().isEmpty) {
      errors['brand'] = 'Marca é obrigatória';
    }
    if (vehicle.model.trim().isEmpty) {
      errors['model'] = 'Modelo é obrigatório';
    }
    final currentYear = DateTime.now().year;
    if (vehicle.year < 1900 || vehicle.year > currentYear + 1) {
      errors['year'] = 'Ano inválido';
    }
    if (vehicle.supportedFuels.isEmpty) {
      errors['supportedFuels'] = 'Selecione pelo menos um tipo de combustível';
    }
    if (vehicle.currentOdometer < 0) {
      errors['currentOdometer'] = 'Odômetro não pode ser negativo';
    }

    return errors;
  }

  /// Checks if vehicle name is unique
  bool isNameUnique(String name, List<VehicleEntity> existingVehicles, {String? excludeId}) {
    final normalizedName = name.trim().toLowerCase();
    return !existingVehicles.any((vehicle) =>
        vehicle.id != excludeId &&
        vehicle.name.trim().toLowerCase() == normalizedName);
  }

  /// Validates vehicle before adding
  Map<String, String> validateForAdd(
    VehicleEntity vehicle,
    List<VehicleEntity> existingVehicles,
  ) {
    final errors = validateVehicle(vehicle);
    if (!isNameUnique(vehicle.name, existingVehicles)) {
      errors['name'] = 'Já existe um veículo com este nome';
    }

    return errors;
  }

  /// Validates vehicle before updating
  Map<String, String> validateForUpdate(
    VehicleEntity vehicle,
    List<VehicleEntity> existingVehicles,
  ) {
    final errors = validateVehicle(vehicle);
    if (!isNameUnique(vehicle.name, existingVehicles, excludeId: vehicle.id)) {
      errors['name'] = 'Já existe um veículo com este nome';
    }

    return errors;
  }
}
