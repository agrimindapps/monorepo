import 'package:core/core.dart';
import 'package:uuid/uuid.dart';

import '../entities/concrete_calculation.dart';

/// Parameters for concrete calculation
class CalculateConcreteParams {
  final double length;
  final double width;
  final double height;
  final String concreteType;
  final String concreteStrength;

  const CalculateConcreteParams({
    required this.length,
    required this.width,
    required this.height,
    this.concreteType = 'Estrutural',
    this.concreteStrength = '25 MPa',
  });
}

/// Use case for calculating concrete volume and materials
///
/// Handles all business logic for concrete calculation including:
/// - Input validation
/// - Volume calculation
/// - Material quantities (cement, sand, gravel, water)
class CalculateConcreteUseCase {
  const CalculateConcreteUseCase();

  Future<Either<Failure, ConcreteCalculation>> call(
    CalculateConcreteParams params,
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
  ValidationFailure? _validate(CalculateConcreteParams params) {
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

    if (params.height <= 0) {
      return const ValidationFailure(
        'Altura/espessura deve ser maior que zero',
      );
    }

    if (params.height > 100) {
      return const ValidationFailure(
        'Altura/espessura não pode ser maior que 100 metros',
      );
    }

    return null;
  }

  /// Perform the actual concrete calculation
  ConcreteCalculation _performCalculation(CalculateConcreteParams params) {
    // Calculate volume in cubic meters
    final volume = params.length * params.width * params.height;

    // Get material ratios based on concrete type and strength
    final ratios = _getMaterialRatios(params.concreteType, params.concreteStrength);

    // Calculate materials based on volume
    // Standard proportions for structural concrete (traço):
    // 1:2:3 (cement:sand:gravel) with 0.5 water/cement ratio
    
    // Each m³ of concrete needs approximately:
    // - 350 kg of cement (7 bags of 50kg) for standard structural concrete
    // - 700 L of sand (0.7 m³)
    // - 1050 L of gravel (1.05 m³)
    // - 175 L of water

    final cementKg = volume * ratios['cement']!;
    final cementBags = (cementKg / 50).ceil(); // 50kg bags

    final sandCubicMeters = volume * ratios['sand']!;
    final gravelCubicMeters = volume * ratios['gravel']!;
    final waterLiters = volume * ratios['water']!;

    return ConcreteCalculation(
      id: const Uuid().v4(),
      length: params.length,
      width: params.width,
      height: params.height,
      volume: volume,
      cementBags: cementBags,
      sandCubicMeters: sandCubicMeters,
      gravelCubicMeters: gravelCubicMeters,
      waterLiters: waterLiters,
      concreteType: params.concreteType,
      concreteStrength: params.concreteStrength,
      calculatedAt: DateTime.now(),
    );
  }

  /// Get material ratios based on concrete type and strength
  Map<String, double> _getMaterialRatios(String concreteType, String strength) {
    // Different concrete mixtures have different proportions
    // These are approximations for common concrete types
    
    switch (concreteType) {
      case 'Magro':
        // Lean concrete (lower cement content)
        return {
          'cement': 250.0, // kg per m³
          'sand': 0.8,     // m³ per m³
          'gravel': 1.0,   // m³ per m³
          'water': 150.0,  // liters per m³
        };
      
      case 'Bombeável':
        // Pumpable concrete (more sand, smaller gravel)
        return {
          'cement': 380.0,
          'sand': 0.75,
          'gravel': 0.95,
          'water': 190.0,
        };
      
      case 'Alta Resistência':
        // High strength concrete
        return {
          'cement': 450.0,
          'sand': 0.6,
          'gravel': 0.9,
          'water': 180.0,
        };
      
      case 'Estrutural':
      default:
        // Standard structural concrete
        // Adjust based on strength
        final cementMultiplier = _getCementMultiplier(strength);
        return {
          'cement': 350.0 * cementMultiplier,
          'sand': 0.7,
          'gravel': 1.05,
          'water': 175.0 * cementMultiplier,
        };
    }
  }

  /// Get cement multiplier based on concrete strength
  double _getCementMultiplier(String strength) {
    switch (strength) {
      case '15 MPa':
        return 0.85;
      case '20 MPa':
        return 0.95;
      case '25 MPa':
        return 1.0;
      case '30 MPa':
        return 1.1;
      case '35 MPa':
        return 1.2;
      case '40 MPa':
        return 1.35;
      default:
        return 1.0;
    }
  }
}
