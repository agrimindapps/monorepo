import 'package:core/core.dart';
import 'package:uuid/uuid.dart';

import '../entities/slab_calculation.dart';

/// Parameters for slab calculation
class CalculateSlabParams {
  final double length;
  final double width;
  final double thickness;
  final String slabType;

  const CalculateSlabParams({
    required this.length,
    required this.width,
    required this.thickness,
    this.slabType = 'Maciça',
  });
}

/// Use case for calculating slab volume and materials
///
/// Handles all business logic for slab calculation including:
/// - Input validation
/// - Volume calculation based on slab type
/// - Material quantities (cement, sand, gravel, steel, blocks)
/// - Different calculations for: Maciça, Treliçada, Pré-moldada, Nervurada
class CalculateSlabUseCase {
  const CalculateSlabUseCase();

  Future<Either<Failure, SlabCalculation>> call(
    CalculateSlabParams params,
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
  ValidationFailure? _validate(CalculateSlabParams params) {
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

    if (params.thickness <= 0) {
      return const ValidationFailure(
        'Espessura deve ser maior que zero',
      );
    }

    if (params.thickness > 100) {
      return const ValidationFailure(
        'Espessura não pode ser maior que 100 centímetros',
      );
    }

    final validTypes = ['Maciça', 'Treliçada', 'Pré-moldada', 'Nervurada'];
    if (!validTypes.contains(params.slabType)) {
      return ValidationFailure(
        'Tipo de laje inválido. Use: ${validTypes.join(", ")}',
      );
    }

    return null;
  }

  /// Perform the actual slab calculation
  SlabCalculation _performCalculation(CalculateSlabParams params) {
    // Convert thickness from cm to meters
    final thicknessInMeters = params.thickness / 100;

    // Calculate total volume of the slab area
    final totalVolume = params.length * params.width * thicknessInMeters;

    // Get volume and block data based on slab type
    final slabData = _getSlabTypeData(
      params.slabType,
      totalVolume,
      params.length,
      params.width,
    );

    // Calculate concrete volume (varies by slab type)
    final concreteVolume = slabData['concreteVolume'] as double;

    // Calculate materials based on concrete volume
    // Standard proportions for structural slab concrete:
    // - 350 kg of cement per m³ (7 bags of 50kg)
    // - 0.7 m³ of sand per m³
    // - 1.05 m³ of gravel per m³
    // - 175 L of water per m³

    final cementKg = concreteVolume * 350.0;
    final cementBags = (cementKg / 50).ceil(); // 50kg bags

    final sandCubicMeters = concreteVolume * 0.7;
    final gravelCubicMeters = concreteVolume * 1.05;
    final waterLiters = concreteVolume * 175.0;

    // Calculate steel weight (80 kg/m³ for slabs)
    final steelWeight = totalVolume * 80.0;

    // Get number of blocks
    final numberOfBlocks = slabData['numberOfBlocks'] as int;

    return SlabCalculation(
      id: const Uuid().v4(),
      length: params.length,
      width: params.width,
      thickness: params.thickness,
      slabType: params.slabType,
      concreteVolume: concreteVolume,
      cementBags: cementBags,
      sandCubicMeters: sandCubicMeters,
      gravelCubicMeters: gravelCubicMeters,
      steelWeight: steelWeight,
      numberOfBlocks: numberOfBlocks,
      waterLiters: waterLiters,
      calculatedAt: DateTime.now(),
    );
  }

  /// Get slab type specific data
  ///
  /// Returns concrete volume and number of blocks based on slab type:
  /// - Maciça: 100% concrete, no blocks
  /// - Treliçada: 60% concrete + blocks (EPS/ceramic blocks between joists)
  /// - Pré-moldada: 40% concrete + blocks (pre-fabricated beams)
  /// - Nervurada: 50% concrete + blocks (ribs with blocks)
  Map<String, dynamic> _getSlabTypeData(
    String slabType,
    double totalVolume,
    double length,
    double width,
  ) {
    // Calculate slab area
    final area = length * width;

    switch (slabType) {
      case 'Maciça':
        // Solid slab - full concrete volume
        return {
          'concreteVolume': totalVolume,
          'numberOfBlocks': 0,
        };

      case 'Treliçada':
        // Joist slab - 60% concrete, 40% blocks
        // Block calculation: approximately 5 blocks per m² (19x19x16cm blocks)
        return {
          'concreteVolume': totalVolume * 0.60,
          'numberOfBlocks': (area * 5).ceil(),
        };

      case 'Pré-moldada':
        // Pre-cast slab - 40% concrete, 60% blocks
        // Block calculation: approximately 6 blocks per m² (smaller spacing)
        return {
          'concreteVolume': totalVolume * 0.40,
          'numberOfBlocks': (area * 6).ceil(),
        };

      case 'Nervurada':
        // Ribbed slab - 50% concrete, 50% blocks
        // Block calculation: approximately 5.5 blocks per m²
        return {
          'concreteVolume': totalVolume * 0.50,
          'numberOfBlocks': (area * 5.5).ceil(),
        };

      default:
        // Default to solid slab
        return {
          'concreteVolume': totalVolume,
          'numberOfBlocks': 0,
        };
    }
  }
}
