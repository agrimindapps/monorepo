import 'package:core/core.dart';
import 'package:uuid/uuid.dart';

import '../entities/flooring_calculation.dart';

/// Parameters for flooring calculation
class CalculateFlooringParams {
  final double roomLength;
  final double roomWidth;
  final double tileLength;
  final double tileWidth;
  final int tilesPerBox;
  final double wastePercentage;
  final String flooringType;

  const CalculateFlooringParams({
    required this.roomLength,
    required this.roomWidth,
    this.tileLength = 60,
    this.tileWidth = 60,
    this.tilesPerBox = 6,
    this.wastePercentage = 10,
    this.flooringType = 'Porcelanato',
  });
}

/// Use case for calculating flooring/tile materials
///
/// Handles all business logic for flooring calculation including:
/// - Input validation
/// - Area calculation
/// - Tile quantity with waste consideration
/// - Box calculation
/// - Grout and mortar estimates
class CalculateFlooringUseCase {
  const CalculateFlooringUseCase();

  Future<Either<Failure, FlooringCalculation>> call(
    CalculateFlooringParams params,
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
  ValidationFailure? _validate(CalculateFlooringParams params) {
    if (params.roomLength <= 0) {
      return const ValidationFailure(
        'Comprimento do ambiente deve ser maior que zero',
      );
    }

    if (params.roomLength > 1000) {
      return const ValidationFailure(
        'Comprimento não pode ser maior que 1000 metros',
      );
    }

    if (params.roomWidth <= 0) {
      return const ValidationFailure(
        'Largura do ambiente deve ser maior que zero',
      );
    }

    if (params.roomWidth > 1000) {
      return const ValidationFailure(
        'Largura não pode ser maior que 1000 metros',
      );
    }

    if (params.tileLength <= 0 || params.tileWidth <= 0) {
      return const ValidationFailure(
        'Dimensões da peça devem ser maiores que zero',
      );
    }

    if (params.tileLength > 300 || params.tileWidth > 300) {
      return const ValidationFailure(
        'Dimensões da peça não podem ser maiores que 300 cm',
      );
    }

    if (params.tilesPerBox < 1 || params.tilesPerBox > 50) {
      return const ValidationFailure(
        'Peças por caixa deve estar entre 1 e 50',
      );
    }

    if (params.wastePercentage < 0 || params.wastePercentage > 50) {
      return const ValidationFailure(
        'Percentual de perda deve estar entre 0% e 50%',
      );
    }

    return null;
  }

  /// Perform the actual flooring calculation
  FlooringCalculation _performCalculation(CalculateFlooringParams params) {
    // Calculate room area in m²
    final roomArea = params.roomLength * params.roomWidth;

    // Calculate tile area in m² (convert from cm to m)
    final tileArea = (params.tileLength / 100) * (params.tileWidth / 100);

    // Calculate tiles needed (without waste)
    final tilesNeeded = (roomArea / tileArea).ceil();

    // Calculate tiles with waste
    final wasteMultiplier = 1 + (params.wastePercentage / 100);
    final tilesWithWaste = (tilesNeeded * wasteMultiplier).ceil();

    // Calculate boxes needed
    final boxesNeeded = (tilesWithWaste / params.tilesPerBox).ceil();

    // Calculate grout needed
    // Approximate: 0.2 to 0.5 kg per m² depending on tile size
    final groutKgPerSqm = _getGroutConsumption(params.tileLength, params.tileWidth);
    final groutKg = roomArea * groutKgPerSqm * wasteMultiplier;

    // Calculate mortar/adhesive needed
    // Approximate: 4 to 6 kg per m² depending on tile type
    final mortarKgPerSqm = _getMortarConsumption(params.flooringType);
    final mortarKg = roomArea * mortarKgPerSqm * wasteMultiplier;

    return FlooringCalculation(
      id: const Uuid().v4(),
      roomLength: params.roomLength,
      roomWidth: params.roomWidth,
      roomArea: roomArea,
      tileLength: params.tileLength,
      tileWidth: params.tileWidth,
      tileArea: tileArea,
      wastePercentage: params.wastePercentage,
      tilesNeeded: tilesNeeded,
      tilesWithWaste: tilesWithWaste,
      boxesNeeded: boxesNeeded,
      tilesPerBox: params.tilesPerBox,
      groutKg: groutKg,
      mortarKg: mortarKg,
      flooringType: params.flooringType,
      calculatedAt: DateTime.now(),
    );
  }

  /// Get grout consumption based on tile size (kg per m²)
  double _getGroutConsumption(double tileLength, double tileWidth) {
    // Larger tiles = less grout, smaller tiles = more grout
    final avgSize = (tileLength + tileWidth) / 2;
    
    if (avgSize >= 80) {
      return 0.15; // Large format tiles
    } else if (avgSize >= 50) {
      return 0.25; // Standard tiles
    } else if (avgSize >= 30) {
      return 0.35; // Medium tiles
    } else {
      return 0.50; // Small tiles/mosaics
    }
  }

  /// Get mortar/adhesive consumption based on flooring type (kg per m²)
  double _getMortarConsumption(String flooringType) {
    switch (flooringType) {
      case 'Porcelanato':
        return 5.0; // AC-III adhesive
      case 'Cerâmica':
        return 4.0; // AC-II adhesive
      case 'Porcelanato Polido':
        return 5.5; // AC-III adhesive, more careful application
      case 'Piso Vinílico':
        return 0.5; // Special adhesive
      case 'Laminado':
        return 0.0; // No adhesive (floating floor)
      case 'Pedra Natural':
        return 6.0; // Heavy material, more adhesive
      default:
        return 4.5;
    }
  }
}
