import 'package:core/core.dart';
import 'package:uuid/uuid.dart';

import '../entities/glass_calculation.dart';

/// Parameters for glass calculation
class CalculateGlassParams {
  final double width;
  final double height;
  final String glassType;
  final int glassThickness;
  final int numberOfPanels;

  const CalculateGlassParams({
    required this.width,
    required this.height,
    this.glassType = 'Comum',
    this.glassThickness = 6,
    this.numberOfPanels = 1,
  });
}

/// Use case for calculating glass area and weight
///
/// Handles all business logic for glass calculation including:
/// - Input validation
/// - Area calculation
/// - Weight calculation based on glass type and thickness
class CalculateGlassUseCase {
  const CalculateGlassUseCase();

  Future<Either<Failure, GlassCalculation>> call(
    CalculateGlassParams params,
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
  ValidationFailure? _validate(CalculateGlassParams params) {
    if (params.width <= 0) {
      return const ValidationFailure(
        'Largura deve ser maior que zero',
      );
    }

    if (params.width > 10) {
      return const ValidationFailure(
        'Largura não pode ser maior que 10 metros',
      );
    }

    if (params.height <= 0) {
      return const ValidationFailure(
        'Altura deve ser maior que zero',
      );
    }

    if (params.height > 10) {
      return const ValidationFailure(
        'Altura não pode ser maior que 10 metros',
      );
    }

    if (params.numberOfPanels <= 0) {
      return const ValidationFailure(
        'Quantidade de painéis deve ser maior que zero',
      );
    }

    if (params.numberOfPanels > 1000) {
      return const ValidationFailure(
        'Quantidade não pode ser maior que 1000 painéis',
      );
    }

    final validThicknesses = [4, 6, 8, 10];
    if (!validThicknesses.contains(params.glassThickness)) {
      return const ValidationFailure(
        'Espessura inválida. Utilize 4mm, 6mm, 8mm ou 10mm',
      );
    }

    return null;
  }

  /// Perform the actual glass calculation
  GlassCalculation _performCalculation(CalculateGlassParams params) {
    // Calculate area per panel in square meters
    final areaPerPanel = params.width * params.height;
    
    // Calculate total area
    final totalArea = areaPerPanel * params.numberOfPanels;

    // Calculate weight
    // Formula: Weight = Area (m²) × Thickness (mm) × 2.5 kg/m²/mm
    // This is the standard density for common glass
    final weightMultiplier = _getWeightMultiplier(params.glassType);
    final weightPerPanel = areaPerPanel * params.glassThickness * 2.5 * weightMultiplier;
    final estimatedWeight = weightPerPanel * params.numberOfPanels;

    return GlassCalculation(
      id: const Uuid().v4(),
      width: params.width,
      height: params.height,
      glassType: params.glassType,
      glassThickness: params.glassThickness,
      numberOfPanels: params.numberOfPanels,
      totalArea: totalArea,
      estimatedWeight: estimatedWeight,
      calculatedAt: DateTime.now(),
    );
  }

  /// Get weight multiplier based on glass type
  /// Different glass types have different densities
  double _getWeightMultiplier(String glassType) {
    switch (glassType) {
      case 'Comum':
        return 1.0; // Standard float glass
      case 'Temperado':
        return 1.0; // Same density as common, just heat-treated
      case 'Laminado':
        return 1.15; // Slightly heavier due to PVB interlayer
      case 'Fumê':
        return 1.0; // Tinted glass, same density as common
      default:
        return 1.0;
    }
  }
}
