import 'package:core/core.dart';
import 'package:uuid/uuid.dart';

import '../entities/mortar_calculation.dart';

/// Parameters for mortar calculation
class CalculateMortarParams {
  final double area;
  final double thickness;
  final String mortarType;

  const CalculateMortarParams({
    required this.area,
    required this.thickness,
    this.mortarType = 'Assentamento',
  });
}

/// Use case for calculating mortar volume and materials
///
/// Handles all business logic for mortar calculation including:
/// - Input validation
/// - Volume calculation
/// - Material quantities (cement, sand, water)
class CalculateMortarUseCase {
  const CalculateMortarUseCase();

  Future<Either<Failure, MortarCalculation>> call(
    CalculateMortarParams params,
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
  ValidationFailure? _validate(CalculateMortarParams params) {
    if (params.area <= 0) {
      return const ValidationFailure(
        'Área deve ser maior que zero',
      );
    }

    if (params.area > 100000) {
      return const ValidationFailure(
        'Área não pode ser maior que 100.000 m²',
      );
    }

    if (params.thickness <= 0) {
      return const ValidationFailure(
        'Espessura deve ser maior que zero',
      );
    }

    if (params.thickness > 100) {
      return const ValidationFailure(
        'Espessura não pode ser maior que 100 cm',
      );
    }

    return null;
  }

  /// Perform the actual mortar calculation
  MortarCalculation _performCalculation(CalculateMortarParams params) {
    // Convert thickness from cm to meters
    final thicknessMeters = params.thickness / 100;

    // Calculate volume in cubic meters
    final volume = params.area * thicknessMeters;

    // Get material ratios based on mortar type
    final ratios = _getMaterialRatios(params.mortarType);

    // Calculate materials based on volume
    // Material consumption varies by mortar type
    // Standard proportions (traço):
    // - Assentamento: 1:6 (cement:sand) - laying bricks/blocks
    // - Reboco: 1:5 (cement:sand) - plastering walls
    // - Contrapiso: 1:4 (cement:sand) - floor screed
    // - Chapisco: 1:3 (cement:sand) - roughcast/primer coat

    final cementKg = volume * ratios['cement']!;
    final cementBags = (cementKg / 50).ceil(); // 50kg bags

    final sandCubicMeters = volume * ratios['sand']!;
    final waterLiters = volume * ratios['water']!;

    return MortarCalculation(
      id: const Uuid().v4(),
      area: params.area,
      thickness: params.thickness,
      mortarType: params.mortarType,
      mortarVolume: volume,
      cementBags: cementBags,
      sandCubicMeters: sandCubicMeters,
      waterLiters: waterLiters,
      calculatedAt: DateTime.now(),
    );
  }

  /// Get material ratios based on mortar type
  ///
  /// Returns consumption per m³ of mortar:
  /// - cement: kg per m³
  /// - sand: m³ per m³
  /// - water: liters per m³
  Map<String, double> _getMaterialRatios(String mortarType) {
    switch (mortarType) {
      case 'Assentamento':
        // Laying mortar - 1:6 (cement:sand)
        // Approx. 250kg cement per m³
        return {
          'cement': 250.0,
          'sand': 1.05,  // With expansion factor
          'water': 150.0,
        };

      case 'Reboco':
        // Plaster mortar - 1:5 (cement:sand)
        // Approx. 300kg cement per m³
        return {
          'cement': 300.0,
          'sand': 1.05,
          'water': 180.0,
        };

      case 'Contrapiso':
        // Floor screed - 1:4 (cement:sand)
        // Approx. 350kg cement per m³
        return {
          'cement': 350.0,
          'sand': 1.0,
          'water': 200.0,
        };

      case 'Chapisco':
        // Roughcast - 1:3 (cement:sand)
        // Approx. 450kg cement per m³
        return {
          'cement': 450.0,
          'sand': 0.95,
          'water': 250.0,
        };

      default:
        // Default to laying mortar
        return {
          'cement': 250.0,
          'sand': 1.05,
          'water': 150.0,
        };
    }
  }
}
