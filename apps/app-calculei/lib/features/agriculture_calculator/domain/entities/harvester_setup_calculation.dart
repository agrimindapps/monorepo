import 'package:equatable/equatable.dart';

/// Pure domain entity - Harvester setup calculation result
///
/// Represents the complete calculation for harvester setup/regulation
/// including technical adjustments, loss estimates, and capacity metrics
class HarvesterSetupCalculation extends Equatable {
  /// Unique identifier for this calculation
  final String id;

  /// Crop type (Soja, Milho, Trigo, Arroz, Feijão)
  final String cropType;

  /// Productivity in sacks per hectare (sc/ha)
  final double productivity;

  /// Grain moisture percentage (%)
  final double moisture;

  /// Harvest speed in kilometers per hour (km/h)
  final double harvestSpeed;

  /// Platform/header width in meters (m)
  final double platformWidth;

  /// Cylinder/rotor speed in RPM
  final double cylinderSpeed;

  /// Concave opening in millimeters (mm)
  final double concaveOpening;

  /// Fan speed in RPM
  final double fanSpeed;

  /// Sieve opening in millimeters (mm)
  final double sieveOpening;

  /// Acceptable grain loss percentage (%)
  final double acceptableLoss;

  /// Estimated grain loss in kg per hectare (kg/ha)
  final double estimatedLoss;

  /// Harvest capacity in hectares per hour (ha/h)
  final double harvestCapacity;

  /// Recommended cylinder speed range (min-max RPM)
  final String cylinderSpeedRange;

  /// Recommended concave opening range (min-max mm)
  final String concaveOpeningRange;

  /// Recommended fan speed range (min-max RPM)
  final String fanSpeedRange;

  /// Recommended sieve opening range (min-max mm)
  final String sieveOpeningRange;

  /// Quality status based on settings and losses
  final String qualityStatus;

  /// Calculation timestamp
  final DateTime calculatedAt;

  const HarvesterSetupCalculation({
    required this.id,
    required this.cropType,
    required this.productivity,
    required this.moisture,
    required this.harvestSpeed,
    required this.platformWidth,
    required this.cylinderSpeed,
    required this.concaveOpening,
    required this.fanSpeed,
    required this.sieveOpening,
    required this.acceptableLoss,
    required this.estimatedLoss,
    required this.harvestCapacity,
    required this.cylinderSpeedRange,
    required this.concaveOpeningRange,
    required this.fanSpeedRange,
    required this.sieveOpeningRange,
    required this.qualityStatus,
    required this.calculatedAt,
  });

  /// Create empty calculation
  factory HarvesterSetupCalculation.empty() {
    return HarvesterSetupCalculation(
      id: '',
      cropType: 'Soja',
      productivity: 0,
      moisture: 13.0,
      harvestSpeed: 5.0,
      platformWidth: 6.0,
      cylinderSpeed: 0,
      concaveOpening: 0,
      fanSpeed: 0,
      sieveOpening: 0,
      acceptableLoss: 2.0,
      estimatedLoss: 0,
      harvestCapacity: 0,
      cylinderSpeedRange: '',
      concaveOpeningRange: '',
      fanSpeedRange: '',
      sieveOpeningRange: '',
      qualityStatus: '',
      calculatedAt: DateTime.now(),
    );
  }

  HarvesterSetupCalculation copyWith({
    String? id,
    String? cropType,
    double? productivity,
    double? moisture,
    double? harvestSpeed,
    double? platformWidth,
    double? cylinderSpeed,
    double? concaveOpening,
    double? fanSpeed,
    double? sieveOpening,
    double? acceptableLoss,
    double? estimatedLoss,
    double? harvestCapacity,
    String? cylinderSpeedRange,
    String? concaveOpeningRange,
    String? fanSpeedRange,
    String? sieveOpeningRange,
    String? qualityStatus,
    DateTime? calculatedAt,
  }) {
    return HarvesterSetupCalculation(
      id: id ?? this.id,
      cropType: cropType ?? this.cropType,
      productivity: productivity ?? this.productivity,
      moisture: moisture ?? this.moisture,
      harvestSpeed: harvestSpeed ?? this.harvestSpeed,
      platformWidth: platformWidth ?? this.platformWidth,
      cylinderSpeed: cylinderSpeed ?? this.cylinderSpeed,
      concaveOpening: concaveOpening ?? this.concaveOpening,
      fanSpeed: fanSpeed ?? this.fanSpeed,
      sieveOpening: sieveOpening ?? this.sieveOpening,
      acceptableLoss: acceptableLoss ?? this.acceptableLoss,
      estimatedLoss: estimatedLoss ?? this.estimatedLoss,
      harvestCapacity: harvestCapacity ?? this.harvestCapacity,
      cylinderSpeedRange: cylinderSpeedRange ?? this.cylinderSpeedRange,
      concaveOpeningRange: concaveOpeningRange ?? this.concaveOpeningRange,
      fanSpeedRange: fanSpeedRange ?? this.fanSpeedRange,
      sieveOpeningRange: sieveOpeningRange ?? this.sieveOpeningRange,
      qualityStatus: qualityStatus ?? this.qualityStatus,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        cropType,
        productivity,
        moisture,
        harvestSpeed,
        platformWidth,
        cylinderSpeed,
        concaveOpening,
        fanSpeed,
        sieveOpening,
        acceptableLoss,
        estimatedLoss,
        harvestCapacity,
        cylinderSpeedRange,
        concaveOpeningRange,
        fanSpeedRange,
        sieveOpeningRange,
        qualityStatus,
        calculatedAt,
      ];
}
