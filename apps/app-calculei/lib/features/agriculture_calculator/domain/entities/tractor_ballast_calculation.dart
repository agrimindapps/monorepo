import 'package:equatable/equatable.dart';

/// Pure domain entity - Tractor ballast calculation result
///
/// Represents the complete calculation for tractor weight distribution
/// and ballast requirements for optimal performance and safety
class TractorBallastCalculation extends Equatable {
  /// Unique identifier for this calculation
  final String id;

  /// Tractor weight in kilograms (kg)
  final double tractorWeight;

  /// Tractor type (4x2, 4x4, Esteira)
  final String tractorType;

  /// Implement weight in kilograms (kg)
  final double implementWeight;

  /// Operation type (Preparo Pesado, Preparo Leve, Plantio, Transporte)
  final String operationType;

  /// Ideal front weight in kilograms (kg)
  final double idealFrontWeight;

  /// Ideal rear weight in kilograms (kg)
  final double idealRearWeight;

  /// Front ballast needed in kilograms (kg)
  final double frontBallastNeeded;

  /// Rear ballast needed in kilograms (kg)
  final double rearBallastNeeded;

  /// Front weight percentage (%)
  final double frontWeightPercent;

  /// Rear weight percentage (%)
  final double rearWeightPercent;

  /// Number of front weights (40kg each)
  final int numberOfFrontWeights;

  /// Number of rear weights (40kg each)
  final int numberOfRearWeights;

  /// Total weight with ballast in kilograms (kg)
  final double totalWeight;

  /// Total ballast needed in kilograms (kg)
  final double totalBallastNeeded;

  /// Calculation timestamp
  final DateTime calculatedAt;

  const TractorBallastCalculation({
    required this.id,
    required this.tractorWeight,
    required this.tractorType,
    required this.implementWeight,
    required this.operationType,
    required this.idealFrontWeight,
    required this.idealRearWeight,
    required this.frontBallastNeeded,
    required this.rearBallastNeeded,
    required this.frontWeightPercent,
    required this.rearWeightPercent,
    required this.numberOfFrontWeights,
    required this.numberOfRearWeights,
    required this.totalWeight,
    required this.totalBallastNeeded,
    required this.calculatedAt,
  });

  /// Create empty calculation
  factory TractorBallastCalculation.empty() {
    return TractorBallastCalculation(
      id: '',
      tractorWeight: 0,
      tractorType: '4x2',
      implementWeight: 0,
      operationType: 'Preparo Pesado',
      idealFrontWeight: 0,
      idealRearWeight: 0,
      frontBallastNeeded: 0,
      rearBallastNeeded: 0,
      frontWeightPercent: 0,
      rearWeightPercent: 0,
      numberOfFrontWeights: 0,
      numberOfRearWeights: 0,
      totalWeight: 0,
      totalBallastNeeded: 0,
      calculatedAt: DateTime.now(),
    );
  }

  TractorBallastCalculation copyWith({
    String? id,
    double? tractorWeight,
    String? tractorType,
    double? implementWeight,
    String? operationType,
    double? idealFrontWeight,
    double? idealRearWeight,
    double? frontBallastNeeded,
    double? rearBallastNeeded,
    double? frontWeightPercent,
    double? rearWeightPercent,
    int? numberOfFrontWeights,
    int? numberOfRearWeights,
    double? totalWeight,
    double? totalBallastNeeded,
    DateTime? calculatedAt,
  }) {
    return TractorBallastCalculation(
      id: id ?? this.id,
      tractorWeight: tractorWeight ?? this.tractorWeight,
      tractorType: tractorType ?? this.tractorType,
      implementWeight: implementWeight ?? this.implementWeight,
      operationType: operationType ?? this.operationType,
      idealFrontWeight: idealFrontWeight ?? this.idealFrontWeight,
      idealRearWeight: idealRearWeight ?? this.idealRearWeight,
      frontBallastNeeded: frontBallastNeeded ?? this.frontBallastNeeded,
      rearBallastNeeded: rearBallastNeeded ?? this.rearBallastNeeded,
      frontWeightPercent: frontWeightPercent ?? this.frontWeightPercent,
      rearWeightPercent: rearWeightPercent ?? this.rearWeightPercent,
      numberOfFrontWeights: numberOfFrontWeights ?? this.numberOfFrontWeights,
      numberOfRearWeights: numberOfRearWeights ?? this.numberOfRearWeights,
      totalWeight: totalWeight ?? this.totalWeight,
      totalBallastNeeded: totalBallastNeeded ?? this.totalBallastNeeded,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        tractorWeight,
        tractorType,
        implementWeight,
        operationType,
        idealFrontWeight,
        idealRearWeight,
        frontBallastNeeded,
        rearBallastNeeded,
        frontWeightPercent,
        rearWeightPercent,
        numberOfFrontWeights,
        numberOfRearWeights,
        totalWeight,
        totalBallastNeeded,
        calculatedAt,
      ];
}
