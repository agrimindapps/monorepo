import 'package:core/core.dart';
import 'package:uuid/uuid.dart';

import '../entities/planter_setup_calculation.dart';

/// Parameters for planter setup calculation
class CalculatePlanterSetupParams {
  final String cropType;
  final double targetPopulation;
  final double rowSpacing;
  final double germination;
  final int discHoles;

  const CalculatePlanterSetupParams({
    required this.cropType,
    required this.targetPopulation,
    required this.rowSpacing,
    required this.germination,
    this.discHoles = 28, // Default planter disc holes
  });
}

/// Use case for calculating planter setup and calibration
///
/// Handles all business logic for planter setup calculation including:
/// - Input validation
/// - Seeds per meter calculation
/// - Population density calculation
/// - Disc and wheel calibration
/// - Seed weight estimation
class CalculatePlanterSetupUseCase {
  const CalculatePlanterSetupUseCase();

  Future<Either<Failure, PlanterSetupCalculation>> call(
    CalculatePlanterSetupParams params,
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
  ValidationFailure? _validate(CalculatePlanterSetupParams params) {
    // Validate crop type
    final validCropTypes = ['Soja', 'Milho', 'Feijão', 'Algodão', 'Girassol'];
    if (!validCropTypes.contains(params.cropType)) {
      return const ValidationFailure(
        'Tipo de cultura inválido',
      );
    }

    // Validate population
    if (params.targetPopulation <= 0) {
      return const ValidationFailure(
        'População alvo deve ser maior que zero',
      );
    }

    final populationRanges = _getRecommendedPopulation(params.cropType);
    if (params.targetPopulation < populationRanges['min']! ||
        params.targetPopulation > populationRanges['max']!) {
      return ValidationFailure(
        'População fora da faixa recomendada para ${params.cropType}: '
        '${populationRanges['min']!.toInt()} - ${populationRanges['max']!.toInt()} plantas/ha',
      );
    }

    // Validate row spacing
    if (params.rowSpacing <= 0) {
      return const ValidationFailure(
        'Espaçamento entre linhas deve ser maior que zero',
      );
    }

    if (params.rowSpacing < 20 || params.rowSpacing > 100) {
      return const ValidationFailure(
        'Espaçamento entre linhas deve estar entre 20 e 100 cm',
      );
    }

    // Validate germination
    if (params.germination <= 0 || params.germination > 100) {
      return const ValidationFailure(
        'Germinação deve estar entre 0 e 100%',
      );
    }

    if (params.germination < 70) {
      return const ValidationFailure(
        'Germinação muito baixa (mínimo 70%). Verifique a qualidade das sementes',
      );
    }

    // Validate disc holes
    if (params.discHoles <= 0) {
      return const ValidationFailure(
        'Número de furos do disco deve ser maior que zero',
      );
    }

    final validDiscHoles = [20, 24, 28, 32, 36, 40];
    if (!validDiscHoles.contains(params.discHoles)) {
      return const ValidationFailure(
        'Número de furos do disco inválido (use: 20, 24, 28, 32, 36 ou 40)',
      );
    }

    return null;
  }

  /// Perform the actual planter setup calculation
  PlanterSetupCalculation _performCalculation(
    CalculatePlanterSetupParams params,
  ) {
    // Get thousand seed weight for the crop
    final thousandSeedWeight = _getThousandSeedWeight(params.cropType);

    // Convert germination from percentage to decimal
    final germinationDecimal = params.germination / 100;

    // Convert row spacing from cm to meters
    final rowSpacingInMeters = params.rowSpacing / 100;

    // Formula: Seeds/m = (Population/ha ÷ 10000 m²/ha) × RowSpacing(m) ÷ Germination
    // This gives us the target population per linear meter of row
    final seedsPerMeter = (params.targetPopulation / 10000) *
        rowSpacingInMeters /
        germinationDecimal;

    // Calculate total seeds per hectare
    // Seeds/ha = Seeds/m × Meters of row per hectare
    // Meters of row per hectare = 10000 m² / RowSpacing(m)
    final seedsPerHectare = seedsPerMeter * (10000 / rowSpacingInMeters);

    // Calculate wheel turns for calibration test
    // Standard test: measure seeds dropped in specific number of wheel turns
    // Recommended: 10 turns for 28-hole disc
    final wheelTurns = _calculateWheelTurns(params.discHoles);

    // Calculate seed weight in kg/ha
    // Weight = (SeedsPerHectare ÷ 1000 seeds) × (ThousandSeedWeight grams) ÷ 1000 (g to kg)
    // Simplified: Weight = (SeedsPerHectare × ThousandSeedWeight) / 1,000,000
    final seedWeight = (seedsPerHectare * thousandSeedWeight) / 1000000;

    return PlanterSetupCalculation(
      id: const Uuid().v4(),
      cropType: params.cropType,
      targetPopulation: params.targetPopulation,
      rowSpacing: params.rowSpacing,
      germination: params.germination,
      seedsPerMeter: double.parse(seedsPerMeter.toStringAsFixed(2)),
      seedsPerHectare: double.parse(seedsPerHectare.toStringAsFixed(0)),
      discHoles: params.discHoles,
      wheelTurns: wheelTurns,
      seedWeight: double.parse(seedWeight.toStringAsFixed(2)),
      thousandSeedWeight: thousandSeedWeight,
      calculatedAt: DateTime.now(),
    );
  }

  /// Get thousand seed weight (TSW) in grams for each crop
  ///
  /// Reference values for common crops in Brazil
  double _getThousandSeedWeight(String cropType) {
    switch (cropType) {
      case 'Soja':
        return 180.0; // 150-200g typical range

      case 'Milho':
        return 350.0; // 300-400g typical range

      case 'Feijão':
        return 250.0; // 200-300g typical range

      case 'Algodão':
        return 120.0; // 100-140g typical range

      case 'Girassol':
        return 60.0; // 50-70g typical range

      default:
        return 180.0;
    }
  }

  /// Get recommended population range for each crop
  ///
  /// Returns min and max population in plants/ha
  Map<String, double> _getRecommendedPopulation(String cropType) {
    switch (cropType) {
      case 'Soja':
        return {
          'min': 200000.0, // 200k plants/ha
          'max': 400000.0, // 400k plants/ha
        };

      case 'Milho':
        return {
          'min': 50000.0, // 50k plants/ha
          'max': 80000.0, // 80k plants/ha
        };

      case 'Feijão':
        return {
          'min': 200000.0, // 200k plants/ha
          'max': 350000.0, // 350k plants/ha
        };

      case 'Algodão':
        return {
          'min': 80000.0, // 80k plants/ha
          'max': 150000.0, // 150k plants/ha
        };

      case 'Girassol':
        return {
          'min': 40000.0, // 40k plants/ha
          'max': 60000.0, // 60k plants/ha
        };

      default:
        return {
          'min': 100000.0,
          'max': 500000.0,
        };
    }
  }

  /// Calculate recommended wheel turns for calibration test
  ///
  /// Based on disc holes and standard test distance
  double _calculateWheelTurns(int discHoles) {
    // Standard calibration test distance: 10-20 meters
    // More holes = fewer turns needed
    switch (discHoles) {
      case 20:
        return 15.0;
      case 24:
        return 12.0;
      case 28:
        return 10.0;
      case 32:
        return 8.0;
      case 36:
        return 7.0;
      case 40:
        return 6.0;
      default:
        return 10.0;
    }
  }
}
