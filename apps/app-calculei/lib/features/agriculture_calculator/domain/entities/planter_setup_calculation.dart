import 'package:equatable/equatable.dart';

/// Pure domain entity - Planter setup calculation result
///
/// Represents the complete calculation for planter setup/calibration
/// including seed rate, population, and technical adjustments
class PlanterSetupCalculation extends Equatable {
  /// Unique identifier for this calculation
  final String id;

  /// Crop type (Soja, Milho, Feijão, Algodão, Girassol)
  final String cropType;

  /// Target plant population per hectare (plantas/ha)
  final double targetPopulation;

  /// Row spacing in centimeters
  final double rowSpacing;

  /// Seed germination percentage (0-100)
  final double germination;

  /// Calculated seeds per linear meter
  final double seedsPerMeter;

  /// Calculated total seeds per hectare
  final double seedsPerHectare;

  /// Number of holes/cells in planter disc
  final int discHoles;

  /// Number of wheel turns for calibration test
  final double wheelTurns;

  /// Seed weight in kg per hectare (based on 1000-seed weight)
  final double seedWeight;

  /// 1000-seed weight in grams (TSW - Thousand Seed Weight)
  final double thousandSeedWeight;

  /// Calculation timestamp
  final DateTime calculatedAt;

  const PlanterSetupCalculation({
    required this.id,
    required this.cropType,
    required this.targetPopulation,
    required this.rowSpacing,
    required this.germination,
    required this.seedsPerMeter,
    required this.seedsPerHectare,
    required this.discHoles,
    required this.wheelTurns,
    required this.seedWeight,
    required this.thousandSeedWeight,
    required this.calculatedAt,
  });

  /// Create empty calculation
  factory PlanterSetupCalculation.empty() {
    return PlanterSetupCalculation(
      id: '',
      cropType: 'Soja',
      targetPopulation: 0,
      rowSpacing: 50,
      germination: 90,
      seedsPerMeter: 0,
      seedsPerHectare: 0,
      discHoles: 0,
      wheelTurns: 0,
      seedWeight: 0,
      thousandSeedWeight: 180,
      calculatedAt: DateTime.now(),
    );
  }

  PlanterSetupCalculation copyWith({
    String? id,
    String? cropType,
    double? targetPopulation,
    double? rowSpacing,
    double? germination,
    double? seedsPerMeter,
    double? seedsPerHectare,
    int? discHoles,
    double? wheelTurns,
    double? seedWeight,
    double? thousandSeedWeight,
    DateTime? calculatedAt,
  }) {
    return PlanterSetupCalculation(
      id: id ?? this.id,
      cropType: cropType ?? this.cropType,
      targetPopulation: targetPopulation ?? this.targetPopulation,
      rowSpacing: rowSpacing ?? this.rowSpacing,
      germination: germination ?? this.germination,
      seedsPerMeter: seedsPerMeter ?? this.seedsPerMeter,
      seedsPerHectare: seedsPerHectare ?? this.seedsPerHectare,
      discHoles: discHoles ?? this.discHoles,
      wheelTurns: wheelTurns ?? this.wheelTurns,
      seedWeight: seedWeight ?? this.seedWeight,
      thousandSeedWeight: thousandSeedWeight ?? this.thousandSeedWeight,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        cropType,
        targetPopulation,
        rowSpacing,
        germination,
        seedsPerMeter,
        seedsPerHectare,
        discHoles,
        wheelTurns,
        seedWeight,
        thousandSeedWeight,
        calculatedAt,
      ];
}
