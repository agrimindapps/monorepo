import '../../domain/entities/fuel_record_entity.dart';

/// Service responsible for fuel record validation
///
/// Follows SRP by handling only validation logic
class FuelValidationService {
  /// Validates a complete fuel record
  Map<String, String> validateFuelRecord(FuelRecordEntity record) {
    final errors = <String, String>{};

    // Validate vehicle
    if (record.vehicleId.isEmpty) {
      errors['vehicleId'] = 'Veículo é obrigatório';
    }

    // Validate liters
    if (record.liters <= 0) {
      errors['liters'] = 'Litros deve ser maior que zero';
    } else if (record.liters > 1000) {
      errors['liters'] = 'Valor muito alto (máximo 1000 litros)';
    }

    // Validate price per liter
    if (record.pricePerLiter <= 0) {
      errors['pricePerLiter'] = 'Preço deve ser maior que zero';
    } else if (record.pricePerLiter > 50) {
      errors['pricePerLiter'] = 'Preço muito alto (máximo R\$ 50/litro)';
    }

    // Validate total price
    if (record.totalPrice <= 0) {
      errors['totalPrice'] = 'Valor total deve ser maior que zero';
    } else if (record.totalPrice > 50000) {
      errors['totalPrice'] = 'Valor muito alto';
    }

    // Validate price consistency
    final calculatedTotal = record.liters * record.pricePerLiter;
    final priceDifference = (calculatedTotal - record.totalPrice).abs();
    if (priceDifference > 0.10) {
      errors['totalPrice'] = 'Valor total inconsistente (esperado: R\$ ${calculatedTotal.toStringAsFixed(2)})';
    }

    // Validate odometer
    if (record.odometer < 0) {
      errors['odometer'] = 'Odômetro não pode ser negativo';
    } else if (record.odometer > 9999999) {
      errors['odometer'] = 'Valor muito alto';
    }

    // Validate previous odometer
    if (record.previousOdometer != null) {
      if (record.previousOdometer! < 0) {
        errors['previousOdometer'] = 'Odômetro anterior não pode ser negativo';
      } else if (record.previousOdometer! >= record.odometer) {
        errors['previousOdometer'] = 'Odômetro anterior deve ser menor que o atual';
      }
    }

    // Validate distance traveled
    if (record.distanceTraveled != null) {
      if (record.distanceTraveled! < 0) {
        errors['distanceTraveled'] = 'Distância não pode ser negativa';
      } else if (record.distanceTraveled! > 100000) {
        errors['distanceTraveled'] = 'Distância muito alta';
      }
    }

    // Validate consumption
    if (record.consumption != null) {
      if (record.consumption! < 0) {
        errors['consumption'] = 'Consumo não pode ser negativo';
      } else if (record.consumption! > 100) {
        errors['consumption'] = 'Consumo muito alto (máximo 100 km/l)';
      } else if (record.consumption! < 1) {
        errors['consumption'] = 'Consumo muito baixo (mínimo 1 km/l)';
      }
    }

    // Validate date
    final now = DateTime.now();
    if (record.date.isAfter(now)) {
      errors['date'] = 'Data não pode ser futura';
    }

    final twoYearsAgo = now.subtract(const Duration(days: 365 * 2));
    if (record.date.isBefore(twoYearsAgo)) {
      errors['date'] = 'Data muito antiga (mais de 2 anos)';
    }

    // Validate gas station name (optional)
    if (record.gasStationName != null && record.gasStationName!.trim().isNotEmpty) {
      if (record.gasStationName!.trim().length < 2) {
        errors['gasStationName'] = 'Nome do posto muito curto';
      } else if (record.gasStationName!.trim().length > 100) {
        errors['gasStationName'] = 'Nome do posto muito longo';
      }
    }

    // Validate notes (optional)
    if (record.notes != null && record.notes!.trim().isNotEmpty) {
      if (record.notes!.trim().length > 500) {
        errors['notes'] = 'Observações muito longas (máximo 500 caracteres)';
      }
    }

    // Validate coordinates (optional)
    if (record.latitude != null) {
      if (record.latitude! < -90 || record.latitude! > 90) {
        errors['latitude'] = 'Latitude inválida';
      }
    }

    if (record.longitude != null) {
      if (record.longitude! < -180 || record.longitude! > 180) {
        errors['longitude'] = 'Longitude inválida';
      }
    }

    return errors;
  }

  /// Validates fuel liters
  String? validateLiters(double liters) {
    if (liters <= 0) {
      return 'Litros deve ser maior que zero';
    } else if (liters > 1000) {
      return 'Valor muito alto (máximo 1000 litros)';
    }
    return null;
  }

  /// Validates price per liter
  String? validatePricePerLiter(double price) {
    if (price <= 0) {
      return 'Preço deve ser maior que zero';
    } else if (price > 50) {
      return 'Preço muito alto (máximo R\$ 50/litro)';
    }
    return null;
  }

  /// Validates total price
  String? validateTotalPrice(double totalPrice, double liters, double pricePerLiter) {
    if (totalPrice <= 0) {
      return 'Valor total deve ser maior que zero';
    }

    final calculatedTotal = liters * pricePerLiter;
    final priceDifference = (calculatedTotal - totalPrice).abs();
    if (priceDifference > 0.10) {
      return 'Valor inconsistente (esperado: R\$ ${calculatedTotal.toStringAsFixed(2)})';
    }

    return null;
  }

  /// Validates odometer reading
  String? validateOdometer(double odometer, {double? previousOdometer}) {
    if (odometer < 0) {
      return 'Odômetro não pode ser negativo';
    } else if (odometer > 9999999) {
      return 'Valor muito alto';
    }

    if (previousOdometer != null && odometer <= previousOdometer) {
      return 'Odômetro deve ser maior que o anterior ($previousOdometer km)';
    }

    return null;
  }

  /// Validates consumption
  String? validateConsumption(double? consumption) {
    if (consumption == null) return null;

    if (consumption < 0) {
      return 'Consumo não pode ser negativo';
    } else if (consumption < 1) {
      return 'Consumo muito baixo (mínimo 1 km/l)';
    } else if (consumption > 100) {
      return 'Consumo muito alto (máximo 100 km/l)';
    }

    return null;
  }

  /// Validates if fuel record is a duplicate
  bool isDuplicate(
    FuelRecordEntity record,
    List<FuelRecordEntity> existingRecords,
  ) {
    return existingRecords.any((existing) {
      if (existing.id == record.id) return false; // Same record

      // Check if same vehicle, date, and odometer within 1 km
      final sameVehicle = existing.vehicleId == record.vehicleId;
      final sameDate = existing.date.difference(record.date).inMinutes.abs() < 60;
      final sameOdometer = (existing.odometer - record.odometer).abs() < 1;

      return sameVehicle && sameDate && sameOdometer;
    });
  }

  /// Validates if odometer reading is consistent with previous records
  bool isOdometerConsistent(
    double odometer,
    String vehicleId,
    List<FuelRecordEntity> existingRecords,
  ) {
    final vehicleRecords = existingRecords
        .where((r) => r.vehicleId == vehicleId)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (vehicleRecords.isEmpty) return true;

    final latestRecord = vehicleRecords.last;

    // Odometer should not decrease
    if (odometer < latestRecord.odometer) {
      return false;
    }

    // Check for unrealistic jumps (>5000 km in one fill-up)
    final distance = odometer - latestRecord.odometer;
    if (distance > 5000) {
      return false;
    }

    return true;
  }

  /// Calculates and validates consumption
  Map<String, dynamic> calculateConsumption({
    required double currentOdometer,
    required double previousOdometer,
    required double liters,
  }) {
    final distance = currentOdometer - previousOdometer;

    if (distance <= 0) {
      return {
        'isValid': false,
        'error': 'Distância inválida',
      };
    }

    if (liters <= 0) {
      return {
        'isValid': false,
        'error': 'Litros inválido',
      };
    }

    final consumption = distance / liters;

    if (consumption < 1 || consumption > 100) {
      return {
        'isValid': false,
        'error': 'Consumo calculado fora da faixa esperada',
        'consumption': consumption,
      };
    }

    return {
      'isValid': true,
      'consumption': consumption,
      'distance': distance,
    };
  }
}
