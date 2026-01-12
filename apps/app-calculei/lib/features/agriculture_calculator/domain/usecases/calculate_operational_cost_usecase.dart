import 'package:core/core.dart';
import 'package:uuid/uuid.dart';

import '../entities/operational_cost_calculation.dart';

/// Parameters for operational cost calculation
class CalculateOperationalCostParams {
  final String operationType;
  final double fuelConsumption;
  final double fuelPrice;
  final double laborHours;
  final double laborCost;
  final double machineryValue;
  final double usefulLife;
  final double maintenanceFactor;
  final double areaWorked;

  const CalculateOperationalCostParams({
    this.operationType = 'Preparo',
    required this.fuelConsumption,
    required this.fuelPrice,
    required this.laborHours,
    required this.laborCost,
    required this.machineryValue,
    required this.usefulLife,
    required this.maintenanceFactor,
    required this.areaWorked,
  });
}

/// Use case for calculating operational costs of agricultural machinery
///
/// Handles all business logic for operational cost calculation including:
/// - Input validation
/// - Fuel cost calculation: consumption × price
/// - Labor cost calculation: hours × hourly_rate
/// - Machinery cost calculation: (value / useful_life) × (1 + maintenance%) / field_capacity
/// - Total cost aggregation and per-hectare calculations
class CalculateOperationalCostUseCase {
  const CalculateOperationalCostUseCase();

  Future<Either<Failure, OperationalCostCalculation>> call(
    CalculateOperationalCostParams params,
  ) async {
    // 1. VALIDATION
    final validationError = _validate(params);
    if (validationError != null) {
      return Left(validationError);
    }

    try {
      // 2. CALCULATION
      final calculation = _performCalculation(params);

      return Right(calculation);
    } catch (e) {
      return Left(ValidationFailure('Erro no cálculo: $e'));
    }
  }

  /// Validate input parameters
  ValidationFailure? _validate(CalculateOperationalCostParams params) {
    // Validate operation type
    final validOperationTypes = [
      'Preparo',
      'Plantio',
      'Pulverização',
      'Colheita',
    ];
    if (!validOperationTypes.contains(params.operationType)) {
      return const ValidationFailure(
        'Tipo de operação inválido',
      );
    }

    // Validate fuel consumption
    if (params.fuelConsumption < 0) {
      return const ValidationFailure(
        'Consumo de combustível não pode ser negativo',
      );
    }

    if (params.fuelConsumption > 100) {
      return const ValidationFailure(
        'Consumo de combustível muito alto (máximo 100 L/ha)',
      );
    }

    // Validate fuel price
    if (params.fuelPrice <= 0) {
      return const ValidationFailure(
        'Preço do combustível deve ser maior que zero',
      );
    }

    if (params.fuelPrice > 50) {
      return const ValidationFailure(
        'Preço do combustível muito alto (máximo R\$ 50/L)',
      );
    }

    // Validate labor hours
    if (params.laborHours < 0) {
      return const ValidationFailure(
        'Horas de mão de obra não podem ser negativas',
      );
    }

    if (params.laborHours > 24) {
      return const ValidationFailure(
        'Horas de mão de obra muito altas (máximo 24 h/ha)',
      );
    }

    // Validate labor cost
    if (params.laborCost < 0) {
      return const ValidationFailure(
        'Custo de mão de obra não pode ser negativo',
      );
    }

    if (params.laborCost > 1000) {
      return const ValidationFailure(
        'Custo de mão de obra muito alto (máximo R\$ 1.000/h)',
      );
    }

    // Validate machinery value
    if (params.machineryValue <= 0) {
      return const ValidationFailure(
        'Valor da máquina deve ser maior que zero',
      );
    }

    if (params.machineryValue > 10000000) {
      return const ValidationFailure(
        'Valor da máquina muito alto (máximo R\$ 10.000.000)',
      );
    }

    // Validate useful life
    if (params.usefulLife <= 0) {
      return const ValidationFailure(
        'Vida útil deve ser maior que zero',
      );
    }

    if (params.usefulLife > 100000) {
      return const ValidationFailure(
        'Vida útil muito alta (máximo 100.000 horas)',
      );
    }

    // Validate maintenance factor
    if (params.maintenanceFactor < 0) {
      return const ValidationFailure(
        'Fator de manutenção não pode ser negativo',
      );
    }

    if (params.maintenanceFactor > 200) {
      return const ValidationFailure(
        'Fator de manutenção muito alto (máximo 200%)',
      );
    }

    // Validate area worked
    if (params.areaWorked <= 0) {
      return const ValidationFailure(
        'Área trabalhada deve ser maior que zero',
      );
    }

    if (params.areaWorked > 100000) {
      return const ValidationFailure(
        'Área trabalhada muito alta (máximo 100.000 ha)',
      );
    }

    return null;
  }

  /// Perform the actual operational cost calculation
  OperationalCostCalculation _performCalculation(
    CalculateOperationalCostParams params,
  ) {
    // 1. Calculate fuel cost per hectare
    // Formula: Fuel Cost/ha = consumption (L/ha) × price (R$/L)
    final fuelCostPerHa = params.fuelConsumption * params.fuelPrice;

    // 2. Calculate labor cost per hectare
    // Formula: Labor Cost/ha = hours (h/ha) × hourly_rate (R$/h)
    final laborCostPerHa = params.laborHours * params.laborCost;

    // 3. Calculate machinery cost per hectare
    // Formula: Machinery Cost/ha = (value / useful_life) × (1 + maintenance%) / field_capacity
    //
    // Field capacity is derived from labor hours: 1 / laborHours gives ha/h
    // If laborHours is 0, we assume 1 ha/h capacity
    final fieldCapacityHaPerH = params.laborHours > 0 
        ? 1.0 / params.laborHours 
        : 1.0;
    
    // Hourly depreciation cost
    final hourlyDepreciation = params.machineryValue / params.usefulLife;
    
    // Apply maintenance factor (e.g., 50% means 1.5x the depreciation)
    final maintenanceMultiplier = 1.0 + (params.maintenanceFactor / 100.0);
    
    // Total hourly cost including maintenance
    final totalHourlyCost = hourlyDepreciation * maintenanceMultiplier;
    
    // Cost per hectare based on field capacity
    final machineryCostPerHa = fieldCapacityHaPerH > 0
        ? totalHourlyCost / fieldCapacityHaPerH
        : totalHourlyCost;

    // 4. Calculate total cost per hectare
    final totalCostPerHa = fuelCostPerHa + laborCostPerHa + machineryCostPerHa;

    // 5. Calculate total cost for the entire area
    final totalCost = totalCostPerHa * params.areaWorked;

    return OperationalCostCalculation(
      id: const Uuid().v4(),
      operationType: params.operationType,
      fuelConsumption: params.fuelConsumption,
      fuelPrice: params.fuelPrice,
      laborHours: params.laborHours,
      laborCost: params.laborCost,
      machineryValue: params.machineryValue,
      usefulLife: params.usefulLife,
      maintenanceFactor: params.maintenanceFactor,
      areaWorked: params.areaWorked,
      fuelCostPerHa: _roundToDecimal(fuelCostPerHa, 2),
      laborCostPerHa: _roundToDecimal(laborCostPerHa, 2),
      machineryCostPerHa: _roundToDecimal(machineryCostPerHa, 2),
      totalCostPerHa: _roundToDecimal(totalCostPerHa, 2),
      totalCost: _roundToDecimal(totalCost, 2),
      calculatedAt: DateTime.now(),
    );
  }

  /// Round number to specified decimal places
  double _roundToDecimal(double value, int decimals) {
    return double.parse(value.toStringAsFixed(decimals));
  }
}
