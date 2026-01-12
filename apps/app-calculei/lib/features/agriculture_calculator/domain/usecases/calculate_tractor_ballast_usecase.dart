import 'package:core/core.dart';
import 'package:uuid/uuid.dart';

import '../entities/tractor_ballast_calculation.dart';

/// Parameters for tractor ballast calculation
class CalculateTractorBallastParams {
  final double tractorWeight;
  final String tractorType;
  final double implementWeight;
  final String operationType;

  const CalculateTractorBallastParams({
    required this.tractorWeight,
    required this.tractorType,
    required this.implementWeight,
    required this.operationType,
  });
}

/// Use case for calculating tractor ballast and weight distribution
///
/// Handles all business logic for tractor ballast calculation including:
/// - Input validation
/// - Weight distribution calculation based on tractor type
/// - Ballast requirements calculation
/// - Ballast weight count (40kg units)
/// - Safety recommendations
class CalculateTractorBallastUseCase {
  const CalculateTractorBallastUseCase();

  Future<Either<Failure, TractorBallastCalculation>> call(
    CalculateTractorBallastParams params,
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
  ValidationFailure? _validate(CalculateTractorBallastParams params) {
    // Validate tractor type
    final validTractorTypes = ['4x2', '4x4', 'Esteira'];
    if (!validTractorTypes.contains(params.tractorType)) {
      return const ValidationFailure(
        'Tipo de trator inválido',
      );
    }

    // Validate operation type
    final validOperationTypes = [
      'Preparo Pesado',
      'Preparo Leve',
      'Plantio',
      'Transporte',
    ];
    if (!validOperationTypes.contains(params.operationType)) {
      return const ValidationFailure(
        'Tipo de operação inválido',
      );
    }

    // Validate tractor weight
    if (params.tractorWeight <= 0) {
      return const ValidationFailure(
        'Peso do trator deve ser maior que zero',
      );
    }

    if (params.tractorWeight < 1000) {
      return const ValidationFailure(
        'Peso do trator muito baixo (mínimo 1000 kg)',
      );
    }

    if (params.tractorWeight > 30000) {
      return const ValidationFailure(
        'Peso do trator excede limite (máximo 30000 kg)',
      );
    }

    // Validate implement weight
    if (params.implementWeight < 0) {
      return const ValidationFailure(
        'Peso do implemento não pode ser negativo',
      );
    }

    if (params.implementWeight > params.tractorWeight * 2) {
      return const ValidationFailure(
        'Peso do implemento muito alto em relação ao trator',
      );
    }

    return null;
  }

  /// Perform the actual tractor ballast calculation
  TractorBallastCalculation _performCalculation(
    CalculateTractorBallastParams params,
  ) {
    // Get weight distribution percentages based on tractor type
    final distribution = _getWeightDistribution(params.tractorType);
    final frontPercent = distribution['front']!;
    final rearPercent = distribution['rear']!;

    // Calculate total operating weight (tractor + implement)
    final totalOperatingWeight = params.tractorWeight + params.implementWeight;

    // Calculate ideal weight distribution
    var idealFrontWeight = totalOperatingWeight * frontPercent;
    var idealRearWeight = totalOperatingWeight * rearPercent;

    // Adjust for operation type (heavy implements add more front weight)
    final operationAdjustment = _getOperationAdjustment(params.operationType);
    idealFrontWeight += operationAdjustment * params.implementWeight;
    idealRearWeight -= operationAdjustment * params.implementWeight;

    // Calculate current weight distribution (assuming implement on rear)
    // This is a simplified model - in reality, implement position varies
    final currentFrontWeight = params.tractorWeight * 0.35; // Average tractor front weight
    final currentRearWeight = params.tractorWeight * 0.65 + params.implementWeight;

    // Calculate ballast needed
    final frontBallastNeeded = idealFrontWeight - currentFrontWeight.clamp(0.0, double.infinity);
    final rearBallastNeeded = idealRearWeight - currentRearWeight.clamp(0.0, double.infinity);

    // Calculate total ballast needed
    final totalBallastNeeded = frontBallastNeeded + rearBallastNeeded;

    // Calculate number of 40kg weights needed
    final numberOfFrontWeights = (frontBallastNeeded / 40).ceil();
    final numberOfRearWeights = (rearBallastNeeded / 40).ceil();

    // Calculate actual weight percentages with ballast
    final totalWeightWithBallast = totalOperatingWeight + totalBallastNeeded;
    final actualFrontWeightPercent = 
        (currentFrontWeight + frontBallastNeeded) / totalWeightWithBallast * 100;
    final actualRearWeightPercent = 
        (currentRearWeight + rearBallastNeeded) / totalWeightWithBallast * 100;

    return TractorBallastCalculation(
      id: const Uuid().v4(),
      tractorWeight: params.tractorWeight,
      tractorType: params.tractorType,
      implementWeight: params.implementWeight,
      operationType: params.operationType,
      idealFrontWeight: double.parse(idealFrontWeight.toStringAsFixed(2)),
      idealRearWeight: double.parse(idealRearWeight.toStringAsFixed(2)),
      frontBallastNeeded: double.parse(frontBallastNeeded.toStringAsFixed(2)),
      rearBallastNeeded: double.parse(rearBallastNeeded.toStringAsFixed(2)),
      frontWeightPercent: double.parse(actualFrontWeightPercent.toStringAsFixed(1)),
      rearWeightPercent: double.parse(actualRearWeightPercent.toStringAsFixed(1)),
      numberOfFrontWeights: numberOfFrontWeights,
      numberOfRearWeights: numberOfRearWeights,
      totalWeight: double.parse(totalWeightWithBallast.toStringAsFixed(2)),
      totalBallastNeeded: double.parse(totalBallastNeeded.toStringAsFixed(2)),
      calculatedAt: DateTime.now(),
    );
  }

  /// Get ideal weight distribution percentages by tractor type
  ///
  /// Reference values for optimal traction and stability:
  /// - 4x2 (2WD): Front 30-35%, Rear 65-70%
  /// - 4x4 (4WD): Front 40-45%, Rear 55-60%
  /// - Esteira (Track): Front 40-45%, Rear 55-60%
  Map<String, double> _getWeightDistribution(String tractorType) {
    switch (tractorType) {
      case '4x2':
        return {
          'front': 0.325, // 32.5% (middle of 30-35% range)
          'rear': 0.675,  // 67.5% (middle of 65-70% range)
        };

      case '4x4':
        return {
          'front': 0.425, // 42.5% (middle of 40-45% range)
          'rear': 0.575,  // 57.5% (middle of 55-60% range)
        };

      case 'Esteira':
        return {
          'front': 0.425, // 42.5% (middle of 40-45% range)
          'rear': 0.575,  // 57.5% (middle of 55-60% range)
        };

      default:
        return {
          'front': 0.40,
          'rear': 0.60,
        };
    }
  }

  /// Get operation adjustment factor
  ///
  /// Heavy implements require more front ballast for safety and control
  /// Returns percentage of implement weight to add to front
  double _getOperationAdjustment(String operationType) {
    switch (operationType) {
      case 'Preparo Pesado': // Heavy soil preparation
        return 0.15; // Add 15% of implement weight to front

      case 'Preparo Leve': // Light soil preparation
        return 0.10; // Add 10% of implement weight to front

      case 'Plantio': // Planting
        return 0.08; // Add 8% of implement weight to front

      case 'Transporte': // Transport
        return 0.05; // Add 5% of implement weight to front

      default:
        return 0.10;
    }
  }
}
