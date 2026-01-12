import 'package:core/core.dart';
import 'package:uuid/uuid.dart';

import '../entities/plumbing_calculation.dart';

/// Parameters for plumbing calculation
class CalculatePlumbingParams {
  final String systemType;
  final String pipeDiameter;
  final double totalLength;
  final int numberOfElbows;
  final int numberOfTees;
  final int numberOfCouplings;

  const CalculatePlumbingParams({
    required this.systemType,
    required this.pipeDiameter,
    required this.totalLength,
    this.numberOfElbows = 0,
    this.numberOfTees = 0,
    this.numberOfCouplings = 0,
  });
}

/// Use case for calculating plumbing pipes and materials
///
/// Handles all business logic for plumbing calculation including:
/// - Input validation
/// - Diameter compatibility validation per system type
/// - Pipe quantity calculation (6m standard tubes)
/// - Glue amount calculation based on joints
class CalculatePlumbingUseCase {
  const CalculatePlumbingUseCase();

  Future<Either<Failure, PlumbingCalculation>> call(
    CalculatePlumbingParams params,
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
  ValidationFailure? _validate(CalculatePlumbingParams params) {
    if (params.totalLength <= 0) {
      return const ValidationFailure(
        'Comprimento total deve ser maior que zero',
      );
    }

    if (params.totalLength > 1000) {
      return const ValidationFailure(
        'Comprimento não pode ser maior que 1000 metros',
      );
    }

    if (params.numberOfElbows < 0) {
      return const ValidationFailure(
        'Número de joelhos não pode ser negativo',
      );
    }

    if (params.numberOfTees < 0) {
      return const ValidationFailure(
        'Número de Ts não pode ser negativo',
      );
    }

    if (params.numberOfCouplings < 0) {
      return const ValidationFailure(
        'Número de luvas não pode ser negativo',
      );
    }

    // Validate diameter compatibility with system type
    final compatibilityError = _validateDiameterCompatibility(
      params.systemType,
      params.pipeDiameter,
    );
    if (compatibilityError != null) {
      return compatibilityError;
    }

    return null;
  }

  /// Validate if diameter is compatible with system type
  ValidationFailure? _validateDiameterCompatibility(
    String systemType,
    String diameter,
  ) {
    final diameterValue = int.tryParse(diameter.replaceAll('mm', ''));
    if (diameterValue == null) {
      return const ValidationFailure('Diâmetro inválido');
    }

    switch (systemType) {
      case 'Água Fria':
      case 'Água Quente':
        // Water systems typically use 20mm to 50mm
        if (diameterValue > 50) {
          return ValidationFailure(
            'Para $systemType, use diâmetros até 50mm',
          );
        }
        break;

      case 'Esgoto':
        // Sewage systems typically use 40mm to 100mm
        if (diameterValue < 40) {
          return const ValidationFailure(
            'Para Esgoto, use diâmetros a partir de 40mm',
          );
        }
        break;

      case 'Pluvial':
        // Rainwater systems typically use 75mm to 100mm
        if (diameterValue < 75) {
          return const ValidationFailure(
            'Para Pluvial, use diâmetros a partir de 75mm',
          );
        }
        break;
    }

    return null;
  }

  /// Perform the actual plumbing calculation
  PlumbingCalculation _performCalculation(CalculatePlumbingParams params) {
    // Calculate pipe count with 10% waste factor
    // Standard PVC pipe length is 6 meters
    const standardPipeLength = 6.0;
    const wasteFactor = 1.10; // 10% waste

    final pipeCountExact = (params.totalLength / standardPipeLength) * wasteFactor;
    final pipeCount = pipeCountExact.ceil();

    // Calculate total number of joints
    // Each pipe connection, elbow, tee, and coupling needs glue
    final totalJoints = 
        (pipeCount - 1) + // Connections between pipes
        (params.numberOfElbows * 2) + // Elbows have 2 joints each
        (params.numberOfTees * 3) + // Tees have 3 joints each
        (params.numberOfCouplings * 2); // Couplings have 2 joints each

    // Calculate glue amount based on diameter
    final gluePerJoint = _getGluePerJoint(params.pipeDiameter);
    final glueAmount = totalJoints * gluePerJoint;

    return PlumbingCalculation(
      id: const Uuid().v4(),
      systemType: params.systemType,
      pipeDiameter: params.pipeDiameter,
      totalLength: params.totalLength,
      numberOfElbows: params.numberOfElbows,
      numberOfTees: params.numberOfTees,
      numberOfCouplings: params.numberOfCouplings,
      pipeCount: pipeCount,
      glueAmount: glueAmount,
      calculatedAt: DateTime.now(),
    );
  }

  /// Get glue amount per joint based on pipe diameter (in ml)
  double _getGluePerJoint(String diameter) {
    final diameterValue = int.tryParse(diameter.replaceAll('mm', '')) ?? 25;

    // Glue consumption increases with diameter
    // These are approximations based on industry standards
    if (diameterValue <= 25) {
      return 3.0; // Small diameter - 3ml per joint
    } else if (diameterValue <= 40) {
      return 5.0; // Medium diameter - 5ml per joint
    } else if (diameterValue <= 60) {
      return 8.0; // Large diameter - 8ml per joint
    } else {
      return 12.0; // Extra large diameter - 12ml per joint
    }
  }
}
