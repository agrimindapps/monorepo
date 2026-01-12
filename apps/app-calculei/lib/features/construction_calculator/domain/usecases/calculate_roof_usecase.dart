import 'package:core/core.dart';
import 'package:uuid/uuid.dart';

import '../entities/roof_calculation.dart';

/// Parameters for roof calculation
class CalculateRoofParams {
  final double length;
  final double width;
  final double roofSlope;
  final String roofType;

  const CalculateRoofParams({
    required this.length,
    required this.width,
    this.roofSlope = 30.0,
    this.roofType = 'Colonial',
  });
}

/// Use case for calculating roof area, tiles, and materials
///
/// Handles all business logic for roof calculation including:
/// - Input validation
/// - Roof area calculation (considering slope)
/// - Tile quantity calculation by roof type
/// - Wood frame calculation (ripas, caibros, terças)
class CalculateRoofUseCase {
  const CalculateRoofUseCase();

  Future<Either<Failure, RoofCalculation>> call(
    CalculateRoofParams params,
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
  ValidationFailure? _validate(CalculateRoofParams params) {
    if (params.length <= 0) {
      return const ValidationFailure(
        'Comprimento deve ser maior que zero',
      );
    }

    if (params.length > 1000) {
      return const ValidationFailure(
        'Comprimento não pode ser maior que 1000 metros',
      );
    }

    if (params.width <= 0) {
      return const ValidationFailure(
        'Largura deve ser maior que zero',
      );
    }

    if (params.width > 1000) {
      return const ValidationFailure(
        'Largura não pode ser maior que 1000 metros',
      );
    }

    if (params.roofSlope < 0) {
      return const ValidationFailure(
        'Inclinação deve ser maior ou igual a zero',
      );
    }

    if (params.roofSlope > 100) {
      return const ValidationFailure(
        'Inclinação não pode ser maior que 100%',
      );
    }

    final validRoofTypes = [
      'Colonial',
      'Romana',
      'Portuguesa',
      'Fibrocimento',
      'Metálica',
    ];

    if (!validRoofTypes.contains(params.roofType)) {
      return ValidationFailure(
        'Tipo de telha inválido. Use: ${validRoofTypes.join(", ")}',
      );
    }

    return null;
  }

  /// Perform the actual roof calculation
  RoofCalculation _performCalculation(CalculateRoofParams params) {
    // 1. Calculate base area
    final baseArea = params.length * params.width;

    // 2. Calculate actual roof area considering slope
    // Formula: area × (1 + slope/100)
    // Example: 10% slope = area × 1.10
    final roofArea = baseArea * (1 + params.roofSlope / 100);

    // 3. Calculate number of tiles based on roof type
    final tilesPerM2 = _getTilesPerSquareMeter(params.roofType);
    final numberOfTiles = (roofArea * tilesPerM2).ceil();

    // 4. Calculate ridge tiles
    // Ridge tiles are placed along the ridge (length of roof)
    // Typically 3 ridge tiles per linear meter
    final ridgeTilesCount = (params.length * 3).ceil();

    // 5. Calculate wood frame
    // Ripas (battens): placed every 33cm (0.33m)
    // Caibros (rafters): placed every 50cm (0.50m)
    // Terças (purlins): placed every 150cm (1.50m)

    // Ripas: perpendicular to length, spaced 0.33m
    // Number of ripas = width / 0.33
    // Total meters = number of ripas × length
    final numberOfRipas = (params.width / 0.33).ceil();
    final ripasMeters = numberOfRipas * params.length;

    // Caibros: perpendicular to width, spaced 0.50m
    // Number of caibros = length / 0.50
    // Total meters = number of caibros × width
    final numberOfCaibros = (params.length / 0.50).ceil();
    final caibrosMeters = numberOfCaibros * params.width;

    // Terças: perpendicular to width, spaced 1.50m
    // Number of terças = length / 1.50
    // Total meters = number of terças × width
    final numberOfTercas = (params.length / 1.50).ceil();
    final tercasMeters = numberOfTercas * params.width;

    final woodFrameMeters = ripasMeters + caibrosMeters + tercasMeters;

    return RoofCalculation(
      id: const Uuid().v4(),
      length: params.length,
      width: params.width,
      roofSlope: params.roofSlope,
      roofType: params.roofType,
      roofArea: roofArea,
      numberOfTiles: numberOfTiles,
      ridgeTilesCount: ridgeTilesCount,
      ripasMeters: ripasMeters,
      caibrosMeters: caibrosMeters,
      tercasMeters: tercasMeters,
      woodFrameMeters: woodFrameMeters,
      calculatedAt: DateTime.now(),
    );
  }

  /// Get tiles per square meter based on roof type
  double _getTilesPerSquareMeter(String roofType) {
    switch (roofType) {
      case 'Colonial':
        return 24.0; // 24 tiles per m²
      case 'Romana':
        return 16.0; // 16 tiles per m²
      case 'Portuguesa':
        return 17.0; // 17 tiles per m²
      case 'Fibrocimento':
        return 5.0; // 5 sheets per m²
      case 'Metálica':
        return 1.1; // 1.1 sheets per m² (10% waste)
      default:
        return 24.0; // Default to Colonial
    }
  }
}
