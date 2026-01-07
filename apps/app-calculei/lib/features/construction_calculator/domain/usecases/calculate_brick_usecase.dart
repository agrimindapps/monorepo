import 'package:core/core.dart';
import 'package:uuid/uuid.dart';

import '../entities/brick_calculation.dart';

/// Parameters for brick/block calculation
class CalculateBrickParams {
  final double wallLength;
  final double wallHeight;
  final double openingsArea;
  final BrickType brickType;
  final double wastePercentage;

  const CalculateBrickParams({
    required this.wallLength,
    required this.wallHeight,
    this.openingsArea = 0,
    this.brickType = BrickType.ceramic6Holes,
    this.wastePercentage = 5,
  });
}

/// Use case for calculating bricks/blocks for wall construction
///
/// Handles all business logic for brick calculation including:
/// - Input validation
/// - Wall area calculation
/// - Brick/block quantity with waste
/// - Mortar and materials estimates
class CalculateBrickUseCase {
  const CalculateBrickUseCase();

  Future<Either<Failure, BrickCalculation>> call(
    CalculateBrickParams params,
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
  ValidationFailure? _validate(CalculateBrickParams params) {
    if (params.wallLength <= 0) {
      return const ValidationFailure(
        'Comprimento da parede deve ser maior que zero',
      );
    }

    if (params.wallLength > 1000) {
      return const ValidationFailure(
        'Comprimento não pode ser maior que 1000 metros',
      );
    }

    if (params.wallHeight <= 0) {
      return const ValidationFailure(
        'Altura da parede deve ser maior que zero',
      );
    }

    if (params.wallHeight > 50) {
      return const ValidationFailure(
        'Altura não pode ser maior que 50 metros',
      );
    }

    if (params.openingsArea < 0) {
      return const ValidationFailure(
        'Área de aberturas não pode ser negativa',
      );
    }

    final wallArea = params.wallLength * params.wallHeight;
    if (params.openingsArea >= wallArea) {
      return const ValidationFailure(
        'Área de aberturas deve ser menor que a área da parede',
      );
    }

    if (params.wastePercentage < 0 || params.wastePercentage > 30) {
      return const ValidationFailure(
        'Percentual de perda deve estar entre 0% e 30%',
      );
    }

    return null;
  }

  /// Perform the actual brick calculation
  BrickCalculation _performCalculation(CalculateBrickParams params) {
    // Calculate wall area
    final wallArea = params.wallLength * params.wallHeight;
    
    // Calculate net area (minus openings)
    final netArea = wallArea - params.openingsArea;

    // Get units per square meter for the brick type
    final unitsPerSqm = params.brickType.unitsPerSquareMeter;

    // Calculate bricks needed (without waste)
    final bricksNeeded = (netArea * unitsPerSqm).ceil();

    // Calculate bricks with waste
    final wasteMultiplier = 1 + (params.wastePercentage / 100);
    final bricksWithWaste = (bricksNeeded * wasteMultiplier).ceil();

    // Calculate mortar needs
    // Approximately 15-20 kg of mortar per m² of wall
    final mortarKgPerSqm = _getMortarConsumption(params.brickType);
    final totalMortarKg = netArea * mortarKgPerSqm;
    
    // Mortar bags (typically 20kg or 50kg)
    final mortarBags = (totalMortarKg / 20).ceil();

    // Calculate sand needed for mortar
    // Approximately 0.025 m³ of sand per m² of wall
    final sandCubicMeters = netArea * 0.025 * wasteMultiplier;

    // Calculate cement bags needed
    // Approximately 1 bag (50kg) per 8-10 m² of wall
    final cementBags = (netArea / 9).ceil();

    return BrickCalculation(
      id: const Uuid().v4(),
      wallLength: params.wallLength,
      wallHeight: params.wallHeight,
      wallArea: wallArea,
      openingsArea: params.openingsArea,
      netArea: netArea,
      brickType: params.brickType,
      bricksNeeded: bricksNeeded,
      wastePercentage: params.wastePercentage,
      bricksWithWaste: bricksWithWaste,
      mortarBags: mortarBags,
      sandCubicMeters: sandCubicMeters,
      cementBags: cementBags,
      calculatedAt: DateTime.now(),
    );
  }

  /// Get mortar consumption based on brick type (kg per m²)
  double _getMortarConsumption(BrickType brickType) {
    switch (brickType) {
      case BrickType.ceramic6Holes:
        return 15.0;
      case BrickType.ceramic8Holes:
        return 14.0;
      case BrickType.concreteBlock14:
        return 12.0;
      case BrickType.concreteBlock19:
        return 12.0;
      case BrickType.solidBrick:
        return 25.0; // More mortar for smaller bricks
      case BrickType.structuralCeramic:
        return 10.0; // Less mortar for structural blocks
    }
  }
}
