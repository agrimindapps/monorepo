import 'dart:math' as math;

import 'package:core/core.dart';
import 'package:uuid/uuid.dart';

import '../entities/tire_pressure_calculation.dart';

/// Parameters for tire pressure calculation
class CalculateTirePressureParams {
  final String tireType;
  final double axleLoad;
  final String tireSize;
  final String operationType;

  const CalculateTirePressureParams({
    required this.tireType,
    required this.axleLoad,
    required this.tireSize,
    this.operationType = 'Campo',
  });
}

/// Use case for calculating recommended tire pressure for agricultural machinery
///
/// Handles all business logic for tire pressure calculation including:
/// - Input validation
/// - Base pressure calculation based on load and tire type
/// - Operation type adjustments (Campo: -15%, Estrada: +15%, Misto: 0%)
/// - Tire type adjustments (Radial: -12% vs Diagonal)
/// - Minimum and maximum safe pressure ranges
/// - Footprint length estimation for field verification
class CalculateTirePressureUseCase {
  const CalculateTirePressureUseCase();

  Future<Either<Failure, TirePressureCalculation>> call(
    CalculateTirePressureParams params,
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
  ValidationFailure? _validate(CalculateTirePressureParams params) {
    // Validate tire type
    final validTireTypes = [
      'Agrícola Diagonal',
      'Agrícola Radial',
      'Implemento',
    ];
    if (!validTireTypes.contains(params.tireType)) {
      return const ValidationFailure(
        'Tipo de pneu inválido',
      );
    }

    // Validate axle load
    if (params.axleLoad <= 0) {
      return const ValidationFailure(
        'Carga no eixo deve ser maior que zero',
      );
    }

    if (params.axleLoad > 20000) {
      return const ValidationFailure(
        'Carga no eixo não pode ser maior que 20.000 kg',
      );
    }

    // Validate tire size
    if (params.tireSize.trim().isEmpty) {
      return const ValidationFailure(
        'Tamanho do pneu é obrigatório',
      );
    }

    // Validate tire size format (basic)
    if (!_isValidTireSize(params.tireSize)) {
      return const ValidationFailure(
        'Formato de pneu inválido. Use formato como 18.4-34 ou 14.9-28',
      );
    }

    // Validate operation type
    final validOperationTypes = ['Campo', 'Estrada', 'Misto'];
    if (!validOperationTypes.contains(params.operationType)) {
      return const ValidationFailure(
        'Tipo de operação inválido',
      );
    }

    return null;
  }

  /// Validate tire size format
  bool _isValidTireSize(String tireSize) {
    // Accept formats like: 18.4-34, 14.9-28, 12.4/11-28, 480/80R46
    final patterns = [
      RegExp(r'^\d+\.?\d*-\d+$'), // 18.4-34
      RegExp(r'^\d+\.?\d*/\d+-\d+$'), // 12.4/11-28
      RegExp(r'^\d+/\d+R?\d+$'), // 480/80R46
    ];

    return patterns.any((pattern) => pattern.hasMatch(tireSize.trim()));
  }

  /// Perform the actual tire pressure calculation
  TirePressureCalculation _performCalculation(
    CalculateTirePressureParams params,
  ) {
    // 1. Calculate base pressure from load
    // Formula based on agricultural tire load tables
    // Simplified: Base PSI = (Load in kg / Load Index Factor) + Minimum Base
    final basePressurePsi = _calculateBasePressure(
      params.axleLoad,
      params.tireType,
    );

    // 2. Apply tire type adjustment
    final tireTypeAdjustment = _getTireTypeAdjustment(params.tireType);
    final pressureAfterTireType = basePressurePsi * tireTypeAdjustment;

    // 3. Apply operation type adjustment
    final operationAdjustment = _getOperationAdjustment(params.operationType);
    final recommendedPressurePsi =
        pressureAfterTireType * operationAdjustment;

    // 4. Convert to BAR (1 PSI = 0.0689476 BAR)
    const psiToBar = 0.0689476;
    final recommendedPressureBar = recommendedPressurePsi * psiToBar;

    // 5. Calculate safe pressure range (±20% for agricultural tires)
    final minPressurePsi = recommendedPressurePsi * 0.80;
    final maxPressurePsi = recommendedPressurePsi * 1.20;
    final minPressureBar = minPressurePsi * psiToBar;
    final maxPressureBar = maxPressurePsi * psiToBar;

    // 6. Calculate expected footprint length
    // Formula: Footprint Length (cm) = K × √(Load / Pressure)
    // where K is a tire-dependent constant (approximated)
    final footprintLength = _calculateFootprintLength(
      params.axleLoad,
      recommendedPressurePsi,
      params.tireSize,
    );

    return TirePressureCalculation(
      id: const Uuid().v4(),
      tireType: params.tireType,
      axleLoad: params.axleLoad,
      tireSize: params.tireSize,
      operationType: params.operationType,
      recommendedPressurePsi: _roundToDecimal(recommendedPressurePsi, 1),
      recommendedPressureBar: _roundToDecimal(recommendedPressureBar, 2),
      minPressurePsi: _roundToDecimal(minPressurePsi, 1),
      minPressureBar: _roundToDecimal(minPressureBar, 2),
      maxPressurePsi: _roundToDecimal(maxPressurePsi, 1),
      maxPressureBar: _roundToDecimal(maxPressureBar, 2),
      footprintLength: _roundToDecimal(footprintLength, 1),
      basePressurePsi: _roundToDecimal(basePressurePsi, 1),
      operationAdjustment: operationAdjustment,
      tireTypeAdjustment: tireTypeAdjustment,
      calculatedAt: DateTime.now(),
    );
  }

  /// Calculate base pressure from axle load
  ///
  /// Simplified formula based on agricultural tire load tables
  /// Real implementation would use manufacturer load/pressure tables
  double _calculateBasePressure(double axleLoad, String tireType) {
    // Base minimum pressure (PSI)
    const minBasePressure = 12.0;

    // Load factor varies by tire type
    // Diagonal tires: Higher pressure needed for same load
    // Radial tires: Lower pressure due to better load distribution
    // Implement tires: Medium pressure requirements
    double loadFactor;
    switch (tireType) {
      case 'Agrícola Diagonal':
        loadFactor = 80.0; // kg per PSI
      case 'Agrícola Radial':
        loadFactor = 100.0; // Better load distribution
      case 'Implemento':
        loadFactor = 90.0;
      default:
        loadFactor = 85.0;
    }

    // Calculate base pressure
    // Formula: PSI = (Load / LoadFactor) + MinBase
    final basePressure = (axleLoad / loadFactor) + minBasePressure;

    // Cap at reasonable maximum (40 PSI for agricultural tires)
    return math.min(basePressure, 40.0);
  }

  /// Get tire type adjustment factor
  ///
  /// Radial tires can operate at 10-15% lower pressure than diagonal
  /// for the same load due to better load distribution
  double _getTireTypeAdjustment(String tireType) {
    switch (tireType) {
      case 'Agrícola Diagonal':
        return 1.00; // Baseline

      case 'Agrícola Radial':
        return 0.88; // 12% reduction - better load distribution

      case 'Implemento':
        return 0.95; // 5% reduction - lighter duty

      default:
        return 1.00;
    }
  }

  /// Get operation type adjustment factor
  ///
  /// Campo (Field): -15% pressure for better traction and less compaction
  /// Estrada (Road): +15% pressure for less wear and better fuel economy
  /// Misto (Mixed): No adjustment (baseline)
  double _getOperationAdjustment(String operationType) {
    switch (operationType) {
      case 'Campo':
        return 0.85; // 15% reduction for field work

      case 'Estrada':
        return 1.15; // 15% increase for road transport

      case 'Misto':
        return 1.00; // No adjustment

      default:
        return 1.00;
    }
  }

  /// Calculate expected tire footprint length for field verification
  ///
  /// Formula: Footprint Length (cm) = K × √(Load / Pressure)
  /// where K depends on tire width (extracted from tire size)
  double _calculateFootprintLength(
    double axleLoad,
    double pressurePsi,
    String tireSize,
  ) {
    // Extract approximate tire width from size string
    // Example: "18.4-34" -> width ≈ 18.4 inches
    final tireWidth = _extractTireWidth(tireSize);

    // K factor based on tire width (empirical)
    // Wider tires = longer footprint
    final kFactor = 3.5 + (tireWidth * 0.15);

    // Calculate footprint length in cm
    // Formula accounts for load distribution
    final footprintCm = kFactor * math.sqrt(axleLoad / pressurePsi);

    // Reasonable bounds: 20-80 cm for agricultural tires
    return math.max(20.0, math.min(footprintCm, 80.0));
  }

  /// Extract tire width from tire size string
  double _extractTireWidth(String tireSize) {
    // Try to extract first number (usually width in inches)
    final match = RegExp(r'^(\d+\.?\d*)').firstMatch(tireSize.trim());
    if (match != null) {
      return double.tryParse(match.group(1) ?? '15') ?? 15.0;
    }
    return 15.0; // Default width if parsing fails
  }

  /// Round number to specified decimal places
  double _roundToDecimal(double value, int decimals) {
    return double.parse(value.toStringAsFixed(decimals));
  }
}
