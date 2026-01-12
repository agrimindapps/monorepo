import 'package:core/core.dart';
import 'package:uuid/uuid.dart';

import '../entities/rebar_calculation.dart';

/// Parameters for rebar calculation
class CalculateRebarParams {
  final String structureType;
  final double concreteVolume;
  final String rebarDiameter;

  const CalculateRebarParams({
    required this.structureType,
    required this.concreteVolume,
    this.rebarDiameter = '8mm',
  });
}

/// Use case for calculating steel reinforcement (rebar) for construction
///
/// Handles all business logic for rebar calculation including:
/// - Input validation
/// - Steel rate calculation based on structure type
/// - Weight and length calculation based on diameter
/// - Number of 12m bars calculation
class CalculateRebarUseCase {
  const CalculateRebarUseCase();

  Future<Either<Failure, RebarCalculation>> call(
    CalculateRebarParams params,
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
  ValidationFailure? _validate(CalculateRebarParams params) {
    if (params.concreteVolume <= 0) {
      return const ValidationFailure(
        'Volume de concreto deve ser maior que zero',
      );
    }

    if (params.concreteVolume > 10000) {
      return const ValidationFailure(
        'Volume de concreto não pode ser maior que 10000 m³',
      );
    }

    final validStructureTypes = ['Laje', 'Viga', 'Pilar', 'Fundação'];
    if (!validStructureTypes.contains(params.structureType)) {
      return const ValidationFailure(
        'Tipo de estrutura inválido',
      );
    }

    final validDiameters = [
      '5mm',
      '6.3mm',
      '8mm',
      '10mm',
      '12.5mm',
      '16mm',
      '20mm',
    ];
    if (!validDiameters.contains(params.rebarDiameter)) {
      return const ValidationFailure(
        'Diâmetro de ferragem inválido',
      );
    }

    return null;
  }

  /// Perform the actual rebar calculation
  RebarCalculation _performCalculation(CalculateRebarParams params) {
    // Get steel consumption rate based on structure type (kg/m³)
    final steelRate = _getSteelRate(params.structureType);

    // Calculate total weight needed
    final totalWeight = params.concreteVolume * steelRate;

    // Get weight per meter for the selected diameter
    final weightPerMeter = _getWeightPerMeter(params.rebarDiameter);

    // Calculate total length needed
    final totalLength = totalWeight / weightPerMeter;

    // Calculate number of 12-meter bars needed (rounded up)
    final numberOfBars = (totalLength / 12).ceil();

    return RebarCalculation(
      id: const Uuid().v4(),
      structureType: params.structureType,
      concreteVolume: params.concreteVolume,
      rebarDiameter: params.rebarDiameter,
      steelRate: steelRate,
      totalWeight: totalWeight,
      totalLength: totalLength,
      numberOfBars: numberOfBars,
      weightPerMeter: weightPerMeter,
      calculatedAt: DateTime.now(),
    );
  }

  /// Get steel consumption rate based on structure type
  /// 
  /// Standard rates in kg/m³:
  /// - Laje (Slab): 80 kg/m³
  /// - Viga (Beam): 120 kg/m³
  /// - Pilar (Column): 150 kg/m³
  /// - Fundação (Foundation): 60 kg/m³
  double _getSteelRate(String structureType) {
    switch (structureType) {
      case 'Laje':
        return 80.0;
      case 'Viga':
        return 120.0;
      case 'Pilar':
        return 150.0;
      case 'Fundação':
        return 60.0;
      default:
        return 80.0;
    }
  }

  /// Get weight per meter for each rebar diameter
  /// 
  /// Formula: Weight (kg/m) = (π × diameter² × 7850) / 4000000
  /// Where 7850 is steel density in kg/m³
  /// 
  /// Standard values:
  /// - 5.0mm: 0.154 kg/m
  /// - 6.3mm: 0.245 kg/m
  /// - 8.0mm: 0.395 kg/m
  /// - 10.0mm: 0.617 kg/m
  /// - 12.5mm: 0.963 kg/m
  /// - 16.0mm: 1.578 kg/m
  /// - 20.0mm: 2.466 kg/m
  double _getWeightPerMeter(String diameter) {
    switch (diameter) {
      case '5mm':
        return 0.154;
      case '6.3mm':
        return 0.245;
      case '8mm':
        return 0.395;
      case '10mm':
        return 0.617;
      case '12.5mm':
        return 0.963;
      case '16mm':
        return 1.578;
      case '20mm':
        return 2.466;
      default:
        return 0.395; // Default to 8mm
    }
  }
}
