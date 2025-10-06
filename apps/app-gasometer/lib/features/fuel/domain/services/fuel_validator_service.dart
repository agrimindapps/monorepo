import '../../../vehicles/domain/entities/vehicle_entity.dart';

/// Serviço especializado para validação contextual de campos de combustível
class FuelValidatorService {
  factory FuelValidatorService() => _instance;
  FuelValidatorService._internal();
  static final FuelValidatorService _instance = FuelValidatorService._internal();

  /// Valida quantidade de litros
  String? validateLiters(String? value, {double? tankCapacity}) {
    if (value == null || value.trim().isEmpty) {
      return 'Quantidade de litros é obrigatória';
    }

    final cleanValue = value.replaceAll(',', '.');
    final liters = double.tryParse(cleanValue);

    if (liters == null) {
      return 'Valor inválido';
    }

    if (liters <= 0) {
      return 'Quantidade deve ser maior que zero';
    }

    if (liters > 999.999) {
      return 'Quantidade muito alta';
    }
    if (tankCapacity != null && liters > tankCapacity * 1.1) {
      return 'Quantidade excede capacidade do tanque';
    }

    return null;
  }

  /// Valida preço por litro
  String? validatePricePerLiter(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Preço por litro é obrigatório';
    }

    final cleanValue = value.replaceAll(',', '.');
    final price = double.tryParse(cleanValue);

    if (price == null) {
      return 'Valor inválido';
    }

    if (price <= 0) {
      return 'Preço deve ser maior que zero';
    }

    if (price < 0.1) {
      return 'Preço muito baixo (mínimo R\$ 0,10)';
    }

    if (price > 9.999) {
      return 'Preço muito alto';
    }

    return null;
  }

  /// Valida valor total
  String? validateTotalPrice(double? totalPrice, {double? maxExpected}) {
    if (totalPrice == null || totalPrice <= 0) {
      return 'Valor total inválido';
    }

    if (totalPrice > 9999.99) {
      return 'Valor muito alto';
    }
    if (maxExpected != null && totalPrice > maxExpected * 2) {
      return 'Valor parece muito alto para este veículo';
    }

    return null;
  }

  /// Valida odômetro com contexto do veículo
  String? validateOdometer(String? value, {
    double? initialOdometer,
    double? currentOdometer,
    double? lastRecordOdometer,
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'Odômetro é obrigatório';
    }

    final cleanValue = value.replaceAll(',', '.');
    final odometer = double.tryParse(cleanValue);

    if (odometer == null) {
      return 'Valor inválido';
    }

    if (odometer < 0) {
      return 'Odômetro não pode ser negativo';
    }

    if (odometer > 9999999) {
      return 'Valor muito alto';
    }
    if (initialOdometer != null && odometer < initialOdometer) {
      return 'Odômetro não pode ser menor que o inicial (${initialOdometer.toStringAsFixed(0)} km)';
    }
    if (currentOdometer != null && odometer < currentOdometer - 1000) {
      return 'Odômetro muito abaixo do atual';
    }
    if (lastRecordOdometer != null) {
      if (odometer < lastRecordOdometer) {
        return 'Odômetro menor que o último registro';
      }
      if (odometer - lastRecordOdometer > 2000) {
        return 'Diferença muito grande desde o último registro';
      }
    }

    return null;
  }

  /// Valida tipo de combustível
  String? validateFuelType(FuelType? value) {
    if (value == null) {
      return 'Tipo de combustível é obrigatório';
    }
    return null;
  }

  /// Valida data do abastecimento
  String? validateDate(DateTime? date) {
    if (date == null) {
      return 'Data é obrigatória';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(date.year, date.month, date.day);

    if (selectedDate.isAfter(today)) {
      return 'Data não pode ser futura';
    }
    final fiveYearsAgo = today.subtract(const Duration(days: 365 * 5));
    if (selectedDate.isBefore(fiveYearsAgo)) {
      return 'Data muito antiga';
    }

    return null;
  }

  /// Valida nome do posto (opcional)
  String? validateGasStationName(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      if (value.trim().length < 2) {
        return 'Nome muito curto';
      }
      if (value.trim().length > 100) {
        return 'Nome muito longo';
      }
      if (!RegExp(r'^[a-zA-ZÀ-ÿ0-9\s\-\.&]+$').hasMatch(value.trim())) {
        return 'Caracteres inválidos no nome';
      }
    }
    return null;
  }

  /// Valida observações (opcional)
  String? validateNotes(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      if (value.trim().length > 500) {
        return 'Observação muito longa (máximo 500 caracteres)';
      }
    }
    return null;
  }

  /// Validação contextual completa do formulário
  Map<String, String> validateCompleteForm({
    required String? liters,
    required String? pricePerLiter,
    required String? odometer,
    required FuelType? fuelType,
    required DateTime? date,
    String? gasStationName,
    String? notes,
    VehicleEntity? vehicle,
    double? lastRecordOdometer,
  }) {
    final errors = <String, String>{};
    final litersError = validateLiters(
      liters,
      tankCapacity: vehicle?.tankCapacity,
    );
    if (litersError != null) errors['liters'] = litersError;
    final priceError = validatePricePerLiter(pricePerLiter);
    if (priceError != null) errors['pricePerLiter'] = priceError;
    final odometerError = validateOdometer(
      odometer,
      initialOdometer: 0, // Assuming initial odometer is 0 for now
      currentOdometer: vehicle?.currentOdometer,
      lastRecordOdometer: lastRecordOdometer,
    );
    if (odometerError != null) errors['odometer'] = odometerError;
    final fuelTypeError = validateFuelType(fuelType);
    if (fuelTypeError != null) errors['fuelType'] = fuelTypeError;
    final dateError = validateDate(date);
    if (dateError != null) errors['date'] = dateError;
    final gasStationError = validateGasStationName(gasStationName);
    if (gasStationError != null) errors['gasStationName'] = gasStationError;

    final notesError = validateNotes(notes);
    if (notesError != null) errors['notes'] = notesError;

    return errors;
  }

  /// Calcula valor total e valida consistência
  double calculateTotalPrice(double liters, double pricePerLiter) {
    if (liters <= 0 || pricePerLiter <= 0) return 0.0;
    return liters * pricePerLiter;
  }

  /// Valida se o cálculo de valor total está correto
  String? validateCalculatedTotal(
    double liters,
    double pricePerLiter,
    double totalPrice,
  ) {
    final calculated = calculateTotalPrice(liters, pricePerLiter);
    final difference = (calculated - totalPrice).abs();
    if (difference > 0.01) {
      return 'Valor total não confere com o cálculo';
    }

    return null;
  }
}