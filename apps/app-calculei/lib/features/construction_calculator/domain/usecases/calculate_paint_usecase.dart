import 'package:core/core.dart';
import 'package:uuid/uuid.dart';

import '../entities/paint_calculation.dart';

/// Parameters for paint calculation
class CalculatePaintParams {
  final double wallArea;
  final double openingsArea;
  final int coats;
  final String paintType;
  final double? customYield;

  const CalculatePaintParams({
    required this.wallArea,
    this.openingsArea = 0,
    this.coats = 2,
    this.paintType = 'Acrílica',
    this.customYield,
  });
}

/// Use case for calculating paint consumption
///
/// Handles all business logic for paint calculation including:
/// - Input validation
/// - Net area calculation (wall - openings)
/// - Paint quantity based on yield and coats
/// - Can recommendations (3.6L and 18L)
class CalculatePaintUseCase {
  const CalculatePaintUseCase();

  Future<Either<Failure, PaintCalculation>> call(
    CalculatePaintParams params,
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
  ValidationFailure? _validate(CalculatePaintParams params) {
    if (params.wallArea <= 0) {
      return const ValidationFailure(
        'Área da parede deve ser maior que zero',
      );
    }

    if (params.wallArea > 100000) {
      return const ValidationFailure(
        'Área da parede não pode ser maior que 100.000 m²',
      );
    }

    if (params.openingsArea < 0) {
      return const ValidationFailure(
        'Área de aberturas não pode ser negativa',
      );
    }

    if (params.openingsArea >= params.wallArea) {
      return const ValidationFailure(
        'Área de aberturas deve ser menor que a área da parede',
      );
    }

    if (params.coats < 1 || params.coats > 5) {
      return const ValidationFailure(
        'Número de demãos deve estar entre 1 e 5',
      );
    }

    if (params.customYield != null && params.customYield! <= 0) {
      return const ValidationFailure(
        'Rendimento deve ser maior que zero',
      );
    }

    return null;
  }

  /// Perform the actual paint calculation
  PaintCalculation _performCalculation(CalculatePaintParams params) {
    // Calculate net area
    final netArea = params.wallArea - params.openingsArea;

    // Get paint yield based on type
    final paintYield = params.customYield ?? _getPaintYield(params.paintType);

    // Calculate total paint needed (area * coats / yield)
    final paintLiters = (netArea * params.coats) / paintYield;

    // Calculate cans needed
    // Small can: 3.6L, Large can: 18L
    const smallCanSize = 3.6;
    const largeCanSize = 18.0;

    // Calculate optimal combination
    final (smallCans, largeCans, recommendedOption) = 
        _calculateOptimalCans(paintLiters, smallCanSize, largeCanSize);

    return PaintCalculation(
      id: const Uuid().v4(),
      wallArea: params.wallArea,
      openingsArea: params.openingsArea,
      netArea: netArea,
      coats: params.coats,
      paintYield: paintYield,
      paintLiters: paintLiters,
      smallCans: smallCans,
      largeCans: largeCans,
      recommendedOption: recommendedOption,
      paintType: params.paintType,
      calculatedAt: DateTime.now(),
    );
  }

  /// Get paint yield based on type (m² per liter)
  double _getPaintYield(String paintType) {
    switch (paintType) {
      case 'Látex PVA':
        return 8.0; // Economy paint, lower yield
      case 'Acrílica':
        return 10.0; // Standard acrylic
      case 'Acrílica Premium':
        return 12.0; // Premium with better coverage
      case 'Esmalte':
        return 10.0; // Enamel paint
      case 'Esmalte Sintético':
        return 9.0; // Synthetic enamel
      case 'Textura':
        return 3.0; // Textured paint (lower yield)
      case 'Impermeabilizante':
        return 6.0; // Waterproof paint
      default:
        return 10.0;
    }
  }

  /// Calculate optimal combination of paint cans
  (int, int, String) _calculateOptimalCans(
    double litersNeeded,
    double smallCanSize,
    double largeCanSize,
  ) {
    // Strategy 1: Only small cans
    final onlySmall = (litersNeeded / smallCanSize).ceil();
    final smallOnlyTotal = onlySmall * smallCanSize;

    // Strategy 2: Only large cans
    final onlyLarge = (litersNeeded / largeCanSize).ceil();
    final largeOnlyTotal = onlyLarge * largeCanSize;

    // Strategy 3: Combination (maximize large, fill with small)
    final largeCans = (litersNeeded / largeCanSize).floor();
    final remaining = litersNeeded - (largeCans * largeCanSize);
    final smallCans = remaining > 0 ? (remaining / smallCanSize).ceil() : 0;
    final comboTotal = (largeCans * largeCanSize) + (smallCans * smallCanSize);

    // Determine best option (minimize waste)
    final smallOnlyWaste = smallOnlyTotal - litersNeeded;
    final largeOnlyWaste = largeOnlyTotal - litersNeeded;
    final comboWaste = comboTotal - litersNeeded;

    // Find minimum waste
    String recommendedOption;
    int finalSmall;
    int finalLarge;

    if (comboWaste <= smallOnlyWaste && comboWaste <= largeOnlyWaste) {
      finalSmall = smallCans;
      finalLarge = largeCans;
      recommendedOption = largeCans > 0 
          ? '$largeCans lata(s) de 18L + $smallCans lata(s) de 3,6L'
          : '$smallCans lata(s) de 3,6L';
    } else if (smallOnlyWaste <= largeOnlyWaste) {
      finalSmall = onlySmall;
      finalLarge = 0;
      recommendedOption = '$onlySmall lata(s) de 3,6L';
    } else {
      finalSmall = 0;
      finalLarge = onlyLarge;
      recommendedOption = '$onlyLarge lata(s) de 18L';
    }

    return (finalSmall, finalLarge, recommendedOption);
  }
}
