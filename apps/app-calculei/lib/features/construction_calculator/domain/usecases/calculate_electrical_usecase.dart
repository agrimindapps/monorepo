import 'package:core/core.dart';
import 'package:uuid/uuid.dart';
import 'dart:math' as math;

import '../entities/electrical_calculation.dart';

/// Parameters for electrical calculation
class CalculateElectricalParams {
  final double totalPower;
  final double voltage;
  final String circuitType;
  final double cableLength;
  final int numberOfCircuits;

  const CalculateElectricalParams({
    required this.totalPower,
    required this.voltage,
    this.circuitType = 'Monofásico',
    this.cableLength = 10.0,
    this.numberOfCircuits = 1,
  });
}

/// Use case for calculating electrical installation
///
/// Handles all business logic for electrical calculation including:
/// - Input validation
/// - Current calculation (single-phase, two-phase, three-phase)
/// - Wire gauge sizing based on current
/// - Breaker sizing (next standard size above current)
/// - Voltage drop calculation
class CalculateElectricalUseCase {
  const CalculateElectricalUseCase();

  Future<Either<Failure, ElectricalCalculation>> call(
    CalculateElectricalParams params,
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
  ValidationFailure? _validate(CalculateElectricalParams params) {
    if (params.totalPower <= 0) {
      return const ValidationFailure(
        'Potência total deve ser maior que zero',
      );
    }

    if (params.totalPower > 1000000) {
      return const ValidationFailure(
        'Potência total não pode ser maior que 1.000.000 W (1 MW)',
      );
    }

    if (params.voltage != 127 && params.voltage != 220) {
      return const ValidationFailure(
        'Tensão deve ser 127V ou 220V',
      );
    }

    if (params.cableLength <= 0) {
      return const ValidationFailure(
        'Comprimento do cabo deve ser maior que zero',
      );
    }

    if (params.cableLength > 1000) {
      return const ValidationFailure(
        'Comprimento do cabo não pode ser maior que 1000 metros',
      );
    }

    if (params.numberOfCircuits <= 0) {
      return const ValidationFailure(
        'Número de circuitos deve ser maior que zero',
      );
    }

    final validCircuitTypes = ['Monofásico', 'Bifásico', 'Trifásico'];
    if (!validCircuitTypes.contains(params.circuitType)) {
      return const ValidationFailure(
        'Tipo de circuito inválido',
      );
    }

    return null;
  }

  /// Perform the actual electrical calculation
  ElectricalCalculation _performCalculation(CalculateElectricalParams params) {
    // Calculate current based on circuit type
    final totalCurrent = _calculateCurrent(
      params.totalPower,
      params.voltage,
      params.circuitType,
    );

    // Determine wire gauge based on current
    final wireGauge = _getWireGauge(totalCurrent);

    // Determine breaker size (next standard size above current)
    final breakerSize = _getBreakerSize(totalCurrent);

    // Calculate voltage drop (optional safety check)
    final voltageDrop = _calculateVoltageDrop(
      totalCurrent,
      params.cableLength,
      wireGauge,
      params.voltage,
    );

    return ElectricalCalculation(
      id: const Uuid().v4(),
      totalPower: params.totalPower,
      voltage: params.voltage,
      circuitType: params.circuitType,
      totalCurrent: totalCurrent,
      recommendedBreakerSize: breakerSize,
      wireGauge: wireGauge,
      estimatedCableLength: params.cableLength,
      numberOfCircuits: params.numberOfCircuits,
      voltageDrop: voltageDrop,
      calculatedAt: DateTime.now(),
    );
  }

  /// Calculate current based on power, voltage, and circuit type
  double _calculateCurrent(
    double power,
    double voltage,
    String circuitType,
  ) {
    switch (circuitType) {
      case 'Trifásico':
        // I = P / (V × √3 × PF)
        // Assuming power factor (PF) = 0.92 for residential
        return power / (voltage * math.sqrt(3) * 0.92);

      case 'Bifásico':
        // I = P / (V × 2 × PF)
        // Bifásico uses two phases at 220V
        return power / (voltage * 2 * 0.92);

      case 'Monofásico':
      default:
        // I = P / (V × PF)
        return power / (voltage * 0.92);
    }
  }

  /// Get wire gauge based on maximum current
  /// Based on NBR 5410 (Brazilian electrical standards)
  double _getWireGauge(double current) {
    if (current <= 10) {
      return 1.5; // 1.5 mm²
    } else if (current <= 16) {
      return 2.5; // 2.5 mm²
    } else if (current <= 25) {
      return 4.0; // 4 mm²
    } else if (current <= 32) {
      return 6.0; // 6 mm²
    } else if (current <= 40) {
      return 10.0; // 10 mm²
    } else if (current <= 50) {
      return 16.0; // 16 mm²
    } else if (current <= 63) {
      return 25.0; // 25 mm²
    } else if (current <= 80) {
      return 35.0; // 35 mm²
    } else if (current <= 100) {
      return 50.0; // 50 mm²
    } else if (current <= 125) {
      return 70.0; // 70 mm²
    } else {
      return 95.0; // 95 mm²
    }
  }

  /// Get breaker size (next standard size above current)
  /// Standard breaker sizes: 10A, 16A, 20A, 25A, 32A, 40A, 50A, 63A, 80A, 100A
  int _getBreakerSize(double current) {
    const standardSizes = [10, 16, 20, 25, 32, 40, 50, 63, 80, 100, 125, 150, 200];
    
    for (final size in standardSizes) {
      if (current <= size) {
        return size;
      }
    }
    
    // For very high currents
    return (current * 1.25).ceil();
  }

  /// Calculate voltage drop percentage
  /// Formula: ΔV = (2 × L × I × ρ) / S
  /// where: L = length (m), I = current (A), ρ = resistivity (Ω·mm²/m), S = section (mm²)
  double _calculateVoltageDrop(
    double current,
    double length,
    double wireSection,
    double voltage,
  ) {
    // Copper resistivity at 20°C: 0.0172 Ω·mm²/m
    const copperResistivity = 0.0172;

    // Voltage drop in volts
    final voltageDropVolts =
        (2 * length * current * copperResistivity) / wireSection;

    // Voltage drop percentage
    final voltageDropPercentage = (voltageDropVolts / voltage) * 100;

    return voltageDropPercentage;
  }
}
