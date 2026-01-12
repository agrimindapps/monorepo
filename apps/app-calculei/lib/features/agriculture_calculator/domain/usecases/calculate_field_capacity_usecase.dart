import 'package:core/core.dart';
import 'package:uuid/uuid.dart';

import '../entities/field_capacity_calculation.dart';

/// Parameters for field capacity calculation
class CalculateFieldCapacityParams {
  final double workingWidth;
  final double workingSpeed;
  final double? fieldEfficiency; // Optional - will use default based on operation
  final String operationType;

  const CalculateFieldCapacityParams({
    required this.workingWidth,
    required this.workingSpeed,
    this.fieldEfficiency,
    this.operationType = 'Preparo',
  });
}

/// Use case for calculating field capacity of agricultural machinery
///
/// Handles all business logic for field capacity calculation including:
/// - Input validation
/// - Theoretical capacity calculation: (width × speed) / 10
/// - Effective capacity calculation: theoretical × efficiency
/// - Work hours and daily productivity estimation
/// - Default efficiency values by operation type
class CalculateFieldCapacityUseCase {
  const CalculateFieldCapacityUseCase();

  Future<Either<Failure, FieldCapacityCalculation>> call(
    CalculateFieldCapacityParams params,
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
  ValidationFailure? _validate(CalculateFieldCapacityParams params) {
    // Validate working width
    if (params.workingWidth <= 0) {
      return const ValidationFailure(
        'Largura de trabalho deve ser maior que zero',
      );
    }

    if (params.workingWidth > 50) {
      return const ValidationFailure(
        'Largura de trabalho não pode ser maior que 50 metros',
      );
    }

    // Validate working speed
    if (params.workingSpeed <= 0) {
      return const ValidationFailure(
        'Velocidade deve ser maior que zero',
      );
    }

    if (params.workingSpeed > 30) {
      return const ValidationFailure(
        'Velocidade não pode ser maior que 30 km/h',
      );
    }

    // Validate field efficiency if provided
    if (params.fieldEfficiency != null) {
      if (params.fieldEfficiency! < 0 || params.fieldEfficiency! > 100) {
        return const ValidationFailure(
          'Eficiência deve estar entre 0 e 100%',
        );
      }
    }

    // Validate operation type
    final validOperationTypes = [
      'Preparo',
      'Plantio',
      'Pulverização',
      'Colheita',
    ];
    if (!validOperationTypes.contains(params.operationType)) {
      return const ValidationFailure(
        'Tipo de operação inválido',
      );
    }

    return null;
  }

  /// Perform the actual field capacity calculation
  FieldCapacityCalculation _performCalculation(
    CalculateFieldCapacityParams params,
  ) {
    // Get efficiency - use provided or default based on operation type
    final efficiency = params.fieldEfficiency ?? 
        _getDefaultEfficiency(params.operationType);

    // 1. Calculate theoretical capacity
    // Formula: Ct = (L × V) / 10
    // where:
    //   L = working width in meters
    //   V = working speed in km/h
    //   Result in ha/h
    final theoreticalCapacity = (params.workingWidth * params.workingSpeed) / 10.0;

    // 2. Calculate effective capacity
    // Formula: Ce = Ct × (E / 100)
    // where:
    //   E = field efficiency in percentage
    final effectiveCapacity = theoreticalCapacity * (efficiency / 100.0);

    // 3. Calculate hours per hectare
    // Formula: h/ha = 1 / Ce
    final hoursPerHectare = effectiveCapacity > 0 
        ? 1.0 / effectiveCapacity 
        : 0.0;

    // 4. Calculate daily productivity
    // 8 hour workday
    final hectaresPerDay8h = effectiveCapacity * 8.0;
    
    // 10 hour workday
    final hectaresPerDay10h = effectiveCapacity * 10.0;

    return FieldCapacityCalculation(
      id: const Uuid().v4(),
      workingWidth: params.workingWidth,
      workingSpeed: params.workingSpeed,
      fieldEfficiency: efficiency,
      operationType: params.operationType,
      theoreticalCapacity: _roundToDecimal(theoreticalCapacity, 2),
      effectiveCapacity: _roundToDecimal(effectiveCapacity, 2),
      hoursPerHectare: _roundToDecimal(hoursPerHectare, 2),
      hectaresPerDay8h: _roundToDecimal(hectaresPerDay8h, 2),
      hectaresPerDay10h: _roundToDecimal(hectaresPerDay10h, 2),
      calculatedAt: DateTime.now(),
    );
  }

  /// Get default field efficiency based on operation type
  ///
  /// These are standard values used in agricultural engineering:
  /// - Preparo (Tillage): 75% - operations like plowing, harrowing
  /// - Plantio (Planting): 70% - seeding operations
  /// - Pulverização (Spraying): 65% - pesticide/fertilizer application
  /// - Colheita (Harvesting): 70% - crop harvesting operations
  double _getDefaultEfficiency(String operationType) {
    switch (operationType) {
      case 'Preparo':
        return 75.0; // Soil preparation operations

      case 'Plantio':
        return 70.0; // Planting/seeding operations

      case 'Pulverização':
        return 65.0; // Spraying operations (lower due to overlaps)

      case 'Colheita':
        return 70.0; // Harvesting operations

      default:
        return 70.0; // General default
    }
  }

  /// Round number to specified decimal places
  double _roundToDecimal(double value, int decimals) {
    return double.parse(value.toStringAsFixed(decimals));
  }
}
