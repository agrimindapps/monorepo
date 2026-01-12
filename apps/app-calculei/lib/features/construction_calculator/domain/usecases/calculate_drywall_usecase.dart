import 'package:core/core.dart';
import 'package:uuid/uuid.dart';

import '../entities/drywall_calculation.dart';

/// Parameters for drywall calculation
class CalculateDrywallParams {
  final double length;
  final double height;
  final String wallType;

  const CalculateDrywallParams({
    required this.length,
    required this.height,
    this.wallType = 'Simples',
  });
}

/// Use case for calculating drywall materials
///
/// Handles all business logic for drywall calculation including:
/// - Input validation
/// - Area calculation
/// - Material quantities (panels, profiles, screws, joint tape, compound)
class CalculateDrywallUseCase {
  const CalculateDrywallUseCase();

  Future<Either<Failure, DrywallCalculation>> call(
    CalculateDrywallParams params,
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
  ValidationFailure? _validate(CalculateDrywallParams params) {
    if (params.length <= 0) {
      return const ValidationFailure(
        'Comprimento deve ser maior que zero',
      );
    }

    if (params.length > 100) {
      return const ValidationFailure(
        'Comprimento não pode ser maior que 100 metros',
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

    if (!['Simples', 'Dupla', 'Acústica'].contains(params.wallType)) {
      return const ValidationFailure(
        'Tipo de parede inválido',
      );
    }

    return null;
  }

  /// Perform the actual drywall calculation
  DrywallCalculation _performCalculation(CalculateDrywallParams params) {
    // Calculate wall area
    final wallArea = params.length * params.height;

    // Calculate number of panels
    // Standard panel size: 1.20m × 2.40m = 2.88m²
    // Add 10% waste
    const panelArea = 2.88; // m²
    final panelsNeeded = wallArea / panelArea;
    final numberOfPanels = (panelsNeeded * 1.10).ceil(); // +10% waste

    // Calculate montantes (vertical profiles)
    // Montantes every 0.60m (40cm or 60cm spacing - using 60cm)
    final numberOfMontantes = (params.length / 0.60).ceil() + 1; // +1 for end
    final montantesMeters = numberOfMontantes * params.height;

    // Calculate guias (horizontal profiles - top + bottom)
    // Double the length for top and bottom
    final guiasMeters = params.length * 2;

    // Total profiles
    final profilesMeters = montantesMeters + guiasMeters;

    // Calculate screws
    // Simple wall: 25 screws per m²
    // Double wall: 50 screws per m² (25 per side)
    // Acoustic wall: 50 screws per m² (same as double)
    final screwsPerSqm = _getScrewsPerSqm(params.wallType);
    final screwsCount = (wallArea * screwsPerSqm).ceil();

    // Calculate joint tape
    // Perimeter of wall
    final perimeter = (params.length + params.height) * 2;
    
    // Add vertical joints between panels (1.20m spacing)
    final verticalJoints = (params.length / 1.20).floor() * params.height;
    
    // Add horizontal joints (if wall height > 2.40m)
    final horizontalJoints = params.height > 2.40 
        ? (params.height / 2.40).floor() * params.length 
        : 0.0;
    
    final jointTapeMeters = perimeter + verticalJoints + horizontalJoints;

    // Calculate joint compound
    // 0.5 kg per m² of wall area
    final jointCompoundKg = wallArea * 0.5;

    return DrywallCalculation(
      id: const Uuid().v4(),
      length: params.length,
      height: params.height,
      wallArea: wallArea,
      wallType: params.wallType,
      numberOfPanels: numberOfPanels,
      montantesMeters: montantesMeters,
      guiasMeters: guiasMeters,
      profilesMeters: profilesMeters,
      screwsCount: screwsCount,
      jointTapeMeters: jointTapeMeters,
      jointCompoundKg: jointCompoundKg,
      calculatedAt: DateTime.now(),
    );
  }

  /// Get screws per square meter based on wall type
  double _getScrewsPerSqm(String wallType) {
    switch (wallType) {
      case 'Simples':
        return 25.0; // Single layer: 25 screws/m²
      case 'Dupla':
        return 50.0; // Double layer: 50 screws/m² (25 per side)
      case 'Acústica':
        return 50.0; // Acoustic: 50 screws/m² (denser fixing)
      default:
        return 25.0;
    }
  }
}
