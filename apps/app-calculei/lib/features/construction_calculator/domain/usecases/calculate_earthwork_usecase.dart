import 'package:core/core.dart';
import 'package:uuid/uuid.dart';

import '../entities/earthwork_calculation.dart';

/// Parameters for earthwork calculation
class CalculateEarthworkParams {
  final double length;
  final double width;
  final double depth;
  final String operationType;
  final String soilType;

  const CalculateEarthworkParams({
    required this.length,
    required this.width,
    required this.depth,
    this.operationType = 'Escavação',
    this.soilType = 'Areia',
  });
}

/// Use case for calculating earthwork volume and logistics
///
/// Handles all business logic for earthwork calculation including:
/// - Input validation
/// - Volume calculation
/// - Compaction and expansion factors
/// - Truck load estimation
/// - Work hours estimation
class CalculateEarthworkUseCase {
  const CalculateEarthworkUseCase();

  Future<Either<Failure, EarthworkCalculation>> call(
    CalculateEarthworkParams params,
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
  ValidationFailure? _validate(CalculateEarthworkParams params) {
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

    if (params.depth <= 0) {
      return const ValidationFailure(
        'Profundidade deve ser maior que zero',
      );
    }

    if (params.depth > 100) {
      return const ValidationFailure(
        'Profundidade não pode ser maior que 100 metros',
      );
    }

    // Validate operation type
    final validOperationTypes = ['Escavação', 'Aterro', 'Corte e Aterro'];
    if (!validOperationTypes.contains(params.operationType)) {
      return const ValidationFailure(
        'Tipo de operação inválido',
      );
    }

    // Validate soil type
    final validSoilTypes = ['Areia', 'Argila', 'Saibro', 'Pedregoso'];
    if (!validSoilTypes.contains(params.soilType)) {
      return const ValidationFailure(
        'Tipo de solo inválido',
      );
    }

    return null;
  }

  /// Perform the actual earthwork calculation
  EarthworkCalculation _performCalculation(CalculateEarthworkParams params) {
    // Calculate base volume in cubic meters
    final baseVolume = params.length * params.width * params.depth;

    // Get soil-specific factors
    final compactionFactor = _getCompactionFactor(params.soilType);
    final expansionFactor = _getExpansionFactor(params.soilType);

    // Calculate adjusted volume based on operation type
    double totalVolume;
    double compactedVolume;

    switch (params.operationType) {
      case 'Escavação':
        // For excavation, soil expands when removed
        totalVolume = baseVolume;
        compactedVolume = baseVolume * expansionFactor;
        break;

      case 'Aterro':
        // For fill, soil compacts when placed
        totalVolume = baseVolume;
        compactedVolume = baseVolume * compactionFactor;
        break;

      case 'Corte e Aterro':
        // For cut-and-fill, average of both operations
        totalVolume = baseVolume;
        compactedVolume = baseVolume * ((expansionFactor + compactionFactor) / 2);
        break;

      default:
        totalVolume = baseVolume;
        compactedVolume = baseVolume;
    }

    // Calculate truck loads (8m³ per truck standard)
    const truckCapacity = 8.0; // m³
    final truckLoads = (compactedVolume / truckCapacity).ceil();

    // Calculate estimated hours based on volume and soil type
    final estimatedHours = _calculateEstimatedHours(
      compactedVolume,
      params.soilType,
      params.operationType,
    );

    return EarthworkCalculation(
      id: const Uuid().v4(),
      length: params.length,
      width: params.width,
      depth: params.depth,
      operationType: params.operationType,
      soilType: params.soilType,
      totalVolume: totalVolume,
      compactedVolume: compactedVolume,
      truckLoads: truckLoads,
      estimatedHours: estimatedHours,
      expansionFactor: expansionFactor,
      compactionFactor: compactionFactor,
      calculatedAt: DateTime.now(),
    );
  }

  /// Get compaction factor based on soil type
  ///
  /// Compaction factor represents how much the soil reduces in volume
  /// when compacted during fill operations
  double _getCompactionFactor(String soilType) {
    switch (soilType) {
      case 'Areia':
        return 1.0; // Sand compacts minimally

      case 'Argila':
        return 0.85; // Clay compacts significantly

      case 'Saibro':
        return 0.90; // Sandy clay moderate compaction

      case 'Pedregoso':
        return 0.95; // Rocky soil minimal compaction

      default:
        return 1.0;
    }
  }

  /// Get expansion factor based on soil type
  ///
  /// Expansion factor represents how much the soil increases in volume
  /// when excavated and loosened
  double _getExpansionFactor(String soilType) {
    switch (soilType) {
      case 'Areia':
        return 1.10; // Sand expands slightly

      case 'Argila':
        return 1.30; // Clay expands significantly

      case 'Saibro':
        return 1.20; // Sandy clay moderate expansion

      case 'Pedregoso':
        return 1.40; // Rocky soil expands most

      default:
        return 1.25;
    }
  }

  /// Calculate estimated work hours
  ///
  /// Based on volume, soil type, and operation type
  /// Assumes standard equipment (excavator + trucks)
  double _calculateEstimatedHours(
    double volume,
    String soilType,
    String operationType,
  ) {
    // Base productivity: m³ per hour
    double baseProductivity;

    switch (soilType) {
      case 'Areia':
        baseProductivity = 25.0; // Easy to work with
        break;

      case 'Argila':
        baseProductivity = 15.0; // Slower due to cohesion
        break;

      case 'Saibro':
        baseProductivity = 20.0; // Moderate difficulty
        break;

      case 'Pedregoso':
        baseProductivity = 10.0; // Slowest due to rocks
        break;

      default:
        baseProductivity = 18.0;
    }

    // Adjust for operation type
    double operationMultiplier;

    switch (operationType) {
      case 'Escavação':
        operationMultiplier = 1.0; // Base rate
        break;

      case 'Aterro':
        operationMultiplier = 1.3; // Fill takes longer (compaction)
        break;

      case 'Corte e Aterro':
        operationMultiplier = 1.5; // Both operations
        break;

      default:
        operationMultiplier = 1.0;
    }

    // Calculate hours
    final hours = (volume / baseProductivity) * operationMultiplier;

    // Round to 1 decimal place
    return double.parse(hours.toStringAsFixed(1));
  }
}
