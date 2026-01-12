import 'package:core/core.dart';
import 'package:uuid/uuid.dart';

import '../entities/harvester_setup_calculation.dart';

/// Parameters for harvester setup calculation
class CalculateHarvesterSetupParams {
  final String cropType;
  final double productivity;
  final double moisture;
  final double harvestSpeed;
  final double platformWidth;

  const CalculateHarvesterSetupParams({
    required this.cropType,
    required this.productivity,
    required this.moisture,
    this.harvestSpeed = 5.0, // Default speed km/h
    this.platformWidth = 6.0, // Default platform width 6m
  });
}

/// Use case for calculating harvester setup and regulation
///
/// Handles all business logic for harvester setup calculation including:
/// - Input validation
/// - Crop-specific settings recommendations
/// - Loss calculation and quality assessment
/// - Harvest capacity calculation
/// - Moisture adjustment factors
class CalculateHarvesterSetupUseCase {
  const CalculateHarvesterSetupUseCase();

  Future<Either<Failure, HarvesterSetupCalculation>> call(
    CalculateHarvesterSetupParams params,
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
  ValidationFailure? _validate(CalculateHarvesterSetupParams params) {
    // Validate crop type
    final validCropTypes = ['Soja', 'Milho', 'Trigo', 'Arroz', 'Feijão'];
    if (!validCropTypes.contains(params.cropType)) {
      return const ValidationFailure(
        'Tipo de cultura inválido',
      );
    }

    // Validate productivity
    if (params.productivity <= 0) {
      return const ValidationFailure(
        'Produtividade deve ser maior que zero',
      );
    }

    final productivityRanges = _getProductivityRange(params.cropType);
    if (params.productivity < productivityRanges['min']! ||
        params.productivity > productivityRanges['max']!) {
      return ValidationFailure(
        'Produtividade fora da faixa típica para ${params.cropType}: '
        '${productivityRanges['min']!.toInt()} - ${productivityRanges['max']!.toInt()} sc/ha',
      );
    }

    // Validate moisture
    if (params.moisture <= 0 || params.moisture > 40) {
      return const ValidationFailure(
        'Umidade deve estar entre 0 e 40%',
      );
    }

    final moistureRange = _getIdealMoistureRange(params.cropType);
    if (params.moisture < moistureRange['min']! - 5 ||
        params.moisture > moistureRange['max']! + 5) {
      return ValidationFailure(
        'Umidade muito distante do ideal para ${params.cropType}: '
        '${moistureRange['min']!.toInt()} - ${moistureRange['max']!.toInt()}%',
      );
    }

    // Validate harvest speed
    if (params.harvestSpeed <= 0) {
      return const ValidationFailure(
        'Velocidade de colheita deve ser maior que zero',
      );
    }

    if (params.harvestSpeed < 2 || params.harvestSpeed > 10) {
      return const ValidationFailure(
        'Velocidade de colheita deve estar entre 2 e 10 km/h',
      );
    }

    // Validate platform width
    if (params.platformWidth <= 0) {
      return const ValidationFailure(
        'Largura da plataforma deve ser maior que zero',
      );
    }

    if (params.platformWidth < 3 || params.platformWidth > 15) {
      return const ValidationFailure(
        'Largura da plataforma deve estar entre 3 e 15 metros',
      );
    }

    return null;
  }

  /// Perform the actual harvester setup calculation
  HarvesterSetupCalculation _performCalculation(
    CalculateHarvesterSetupParams params,
  ) {
    // Get crop-specific settings
    final settings = _getCropSettings(params.cropType);

    // Apply moisture adjustment factor
    final moistureAdjustment = _getMoistureAdjustmentFactor(
      params.cropType,
      params.moisture,
    );

    // Calculate adjusted settings
    final cylinderSpeed = (settings['cylinderSpeed']! * moistureAdjustment)
        .clamp(settings['cylinderMin']!, settings['cylinderMax']!);

    final concaveOpening = (settings['concaveOpening']! * moistureAdjustment)
        .clamp(settings['concaveMin']!, settings['concaveMax']!);

    final fanSpeed = (settings['fanSpeed']! * moistureAdjustment)
        .clamp(settings['fanMin']!, settings['fanMax']!);

    final sieveOpening = settings['sieveOpening']!;

    // Calculate harvest capacity
    // Formula: Capacity (ha/h) = (Width × Speed × Efficiency) / 10
    // Efficiency typically 70-85% depending on conditions
    const efficiency = 0.75; // 75% field efficiency
    final harvestCapacity =
        (params.platformWidth * params.harvestSpeed * efficiency) / 10;

    // Calculate estimated losses
    // Base loss percentage from speed and settings
    final baseLoss = _calculateBaseLoss(
      params.harvestSpeed,
      params.productivity,
      cylinderSpeed,
      settings['cylinderSpeed']!,
    );

    // Convert loss percentage to kg/ha
    // 1 sack (sc) = 60 kg for most grains
    const kgPerSack = 60.0;
    final estimatedLossKgHa = (baseLoss / 100) * params.productivity * kgPerSack;

    // Determine quality status
    final acceptableLoss = _getAcceptableLoss(params.cropType);
    final qualityStatus = _getQualityStatus(
      baseLoss,
      acceptableLoss,
      params.moisture,
      _getIdealMoistureRange(params.cropType),
    );

    // Build recommendation ranges
    final cylinderSpeedRange =
        '${settings['cylinderMin']!.toInt()}-${settings['cylinderMax']!.toInt()} RPM';
    final concaveOpeningRange =
        '${settings['concaveMin']!.toInt()}-${settings['concaveMax']!.toInt()} mm';
    final fanSpeedRange =
        '${settings['fanMin']!.toInt()}-${settings['fanMax']!.toInt()} RPM';
    final sieveOpeningRange =
        '${settings['sieveMin']!.toInt()}-${settings['sieveMax']!.toInt()} mm';

    return HarvesterSetupCalculation(
      id: const Uuid().v4(),
      cropType: params.cropType,
      productivity: params.productivity,
      moisture: params.moisture,
      harvestSpeed: params.harvestSpeed,
      platformWidth: params.platformWidth,
      cylinderSpeed: double.parse(cylinderSpeed.toStringAsFixed(0)),
      concaveOpening: double.parse(concaveOpening.toStringAsFixed(1)),
      fanSpeed: double.parse(fanSpeed.toStringAsFixed(0)),
      sieveOpening: double.parse(sieveOpening.toStringAsFixed(1)),
      acceptableLoss: acceptableLoss,
      estimatedLoss: double.parse(estimatedLossKgHa.toStringAsFixed(2)),
      harvestCapacity: double.parse(harvestCapacity.toStringAsFixed(2)),
      cylinderSpeedRange: cylinderSpeedRange,
      concaveOpeningRange: concaveOpeningRange,
      fanSpeedRange: fanSpeedRange,
      sieveOpeningRange: sieveOpeningRange,
      qualityStatus: qualityStatus,
      calculatedAt: DateTime.now(),
    );
  }

  /// Get crop-specific harvester settings
  ///
  /// Returns recommended settings for cylinder, concave, fan, and sieves
  Map<String, double> _getCropSettings(String cropType) {
    switch (cropType) {
      case 'Soja':
        return {
          // Cylinder/Rotor Speed
          'cylinderSpeed': 450.0, // Base RPM
          'cylinderMin': 350.0,
          'cylinderMax': 550.0,
          // Concave Opening
          'concaveOpening': 15.0, // Base mm
          'concaveMin': 12.0,
          'concaveMax': 20.0,
          // Fan Speed
          'fanSpeed': 950.0, // Base RPM
          'fanMin': 850.0,
          'fanMax': 1100.0,
          // Sieve Opening
          'sieveOpening': 13.0, // mm
          'sieveMin': 11.0,
          'sieveMax': 15.0,
        };

      case 'Milho':
        return {
          'cylinderSpeed': 350.0,
          'cylinderMin': 280.0,
          'cylinderMax': 450.0,
          'concaveOpening': 25.0,
          'concaveMin': 20.0,
          'concaveMax': 32.0,
          'fanSpeed': 800.0,
          'fanMin': 700.0,
          'fanMax': 950.0,
          'sieveOpening': 19.0,
          'sieveMin': 16.0,
          'sieveMax': 22.0,
        };

      case 'Trigo':
        return {
          'cylinderSpeed': 800.0,
          'cylinderMin': 700.0,
          'cylinderMax': 950.0,
          'concaveOpening': 8.0,
          'concaveMin': 6.0,
          'concaveMax': 12.0,
          'fanSpeed': 1100.0,
          'fanMin': 1000.0,
          'fanMax': 1250.0,
          'sieveOpening': 10.0,
          'sieveMin': 8.0,
          'sieveMax': 12.0,
        };

      case 'Arroz':
        return {
          'cylinderSpeed': 750.0,
          'cylinderMin': 650.0,
          'cylinderMax': 900.0,
          'concaveOpening': 10.0,
          'concaveMin': 8.0,
          'concaveMax': 14.0,
          'fanSpeed': 1000.0,
          'fanMin': 900.0,
          'fanMax': 1150.0,
          'sieveOpening': 9.0,
          'sieveMin': 7.0,
          'sieveMax': 11.0,
        };

      case 'Feijão':
        return {
          'cylinderSpeed': 400.0,
          'cylinderMin': 320.0,
          'cylinderMax': 500.0,
          'concaveOpening': 12.0,
          'concaveMin': 10.0,
          'concaveMax': 16.0,
          'fanSpeed': 900.0,
          'fanMin': 800.0,
          'fanMax': 1050.0,
          'sieveOpening': 11.0,
          'sieveMin': 9.0,
          'sieveMax': 13.0,
        };

      default:
        return {
          'cylinderSpeed': 450.0,
          'cylinderMin': 350.0,
          'cylinderMax': 550.0,
          'concaveOpening': 15.0,
          'concaveMin': 12.0,
          'concaveMax': 20.0,
          'fanSpeed': 950.0,
          'fanMin': 850.0,
          'fanMax': 1100.0,
          'sieveOpening': 13.0,
          'sieveMin': 11.0,
          'sieveMax': 15.0,
        };
    }
  }

  /// Get productivity range for validation
  Map<String, double> _getProductivityRange(String cropType) {
    switch (cropType) {
      case 'Soja':
        return {'min': 20.0, 'max': 120.0}; // sc/ha

      case 'Milho':
        return {'min': 30.0, 'max': 250.0}; // sc/ha

      case 'Trigo':
        return {'min': 15.0, 'max': 100.0}; // sc/ha

      case 'Arroz':
        return {'min': 40.0, 'max': 200.0}; // sc/ha

      case 'Feijão':
        return {'min': 15.0, 'max': 80.0}; // sc/ha

      default:
        return {'min': 10.0, 'max': 300.0};
    }
  }

  /// Get ideal moisture range for each crop
  Map<String, double> _getIdealMoistureRange(String cropType) {
    switch (cropType) {
      case 'Soja':
        return {'min': 12.0, 'max': 14.0}; // %

      case 'Milho':
        return {'min': 14.0, 'max': 16.0}; // %

      case 'Trigo':
        return {'min': 12.0, 'max': 13.0}; // %

      case 'Arroz':
        return {'min': 18.0, 'max': 22.0}; // %

      case 'Feijão':
        return {'min': 13.0, 'max': 15.0}; // %

      default:
        return {'min': 12.0, 'max': 14.0};
    }
  }

  /// Calculate moisture adjustment factor
  ///
  /// Adjusts settings based on grain moisture
  /// Higher moisture = slower cylinder, wider concave, higher fan
  double _getMoistureAdjustmentFactor(String cropType, double moisture) {
    final idealRange = _getIdealMoistureRange(cropType);
    final idealMid = (idealRange['min']! + idealRange['max']!) / 2;

    // For every 1% above ideal, reduce cylinder speed by 2%
    // For every 1% below ideal, increase cylinder speed by 2%
    final moistureDiff = moisture - idealMid;
    final adjustmentFactor = 1.0 - (moistureDiff * 0.02);

    // Clamp between 0.85 and 1.15 (±15%)
    return adjustmentFactor.clamp(0.85, 1.15);
  }

  /// Calculate base loss percentage
  ///
  /// Considers speed, productivity, and cylinder settings
  double _calculateBaseLoss(
    double speed,
    double productivity,
    double actualCylinderSpeed,
    double recommendedCylinderSpeed,
  ) {
    // Base loss increases with speed
    // Speed factor: 2-4 km/h = 0.5%, 4-6 km/h = 1.0%, 6-8 km/h = 1.5%, >8 km/h = 2.5%
    var speedLoss = 0.5;
    if (speed > 8.0) {
      speedLoss = 2.5;
    } else if (speed > 6.0) {
      speedLoss = 1.5;
    } else if (speed > 4.0) {
      speedLoss = 1.0;
    }

    // Productivity factor: Higher yields = higher potential loss
    // For every 10 sc/ha above 50, add 0.1% loss
    final productivityLoss = productivity > 50 ? (productivity - 50) / 100 : 0.0;

    // Settings factor: Deviation from recommended settings increases loss
    final cylinderDeviation =
        (actualCylinderSpeed - recommendedCylinderSpeed).abs() /
            recommendedCylinderSpeed;
    final settingsLoss = cylinderDeviation * 0.5; // 0.5% per 10% deviation

    // Total loss
    final totalLoss = speedLoss + productivityLoss + settingsLoss;

    return totalLoss.clamp(0.3, 5.0); // Minimum 0.3%, maximum 5%
  }

  /// Get acceptable loss percentage for crop
  double _getAcceptableLoss(String cropType) {
    switch (cropType) {
      case 'Soja':
        return 2.0; // 2% acceptable

      case 'Milho':
        return 2.5; // 2.5% acceptable

      case 'Trigo':
        return 1.5; // 1.5% acceptable

      case 'Arroz':
        return 3.0; // 3.0% acceptable

      case 'Feijão':
        return 2.0; // 2.0% acceptable

      default:
        return 2.0;
    }
  }

  /// Determine quality status based on losses and moisture
  String _getQualityStatus(
    double estimatedLoss,
    double acceptableLoss,
    double moisture,
    Map<String, double> idealMoisture,
  ) {
    final moistureOk = moisture >= idealMoisture['min']! - 2 &&
        moisture <= idealMoisture['max']! + 2;

    if (estimatedLoss <= acceptableLoss && moistureOk) {
      return 'Excelente';
    } else if (estimatedLoss <= acceptableLoss * 1.5) {
      return 'Boa';
    } else if (estimatedLoss <= acceptableLoss * 2) {
      return 'Regular';
    } else {
      return 'Necessita Ajustes';
    }
  }
}
