import 'package:equatable/equatable.dart';

/// Pure domain entity - Rebar (steel reinforcement) calculation result
///
/// Represents the complete calculation of steel reinforcement needed
/// for construction structures (slabs, beams, columns, foundations)
class RebarCalculation extends Equatable {
  /// Unique identifier for this calculation
  final String id;

  /// Structure type (Laje, Viga, Pilar, Fundação)
  final String structureType;

  /// Concrete volume in cubic meters (m³)
  final double concreteVolume;

  /// Rebar diameter in millimeters (5mm, 6.3mm, 8mm, 10mm, 12.5mm, 16mm, 20mm)
  final String rebarDiameter;

  /// Steel consumption rate in kg/m³ (varies by structure type)
  final double steelRate;

  /// Total steel weight needed in kilograms
  final double totalWeight;

  /// Total linear length of rebar needed in meters
  final double totalLength;

  /// Number of 12-meter steel bars needed
  final int numberOfBars;

  /// Weight per meter for the selected diameter (kg/m)
  final double weightPerMeter;

  /// Estimated cost (optional)
  final double? estimatedCost;

  /// Calculation timestamp
  final DateTime calculatedAt;

  const RebarCalculation({
    required this.id,
    required this.structureType,
    required this.concreteVolume,
    required this.rebarDiameter,
    required this.steelRate,
    required this.totalWeight,
    required this.totalLength,
    required this.numberOfBars,
    required this.weightPerMeter,
    this.estimatedCost,
    required this.calculatedAt,
  });

  /// Create empty calculation
  factory RebarCalculation.empty() {
    return RebarCalculation(
      id: '',
      structureType: 'Laje',
      concreteVolume: 0,
      rebarDiameter: '8mm',
      steelRate: 0,
      totalWeight: 0,
      totalLength: 0,
      numberOfBars: 0,
      weightPerMeter: 0,
      calculatedAt: DateTime.now(),
    );
  }

  RebarCalculation copyWith({
    String? id,
    String? structureType,
    double? concreteVolume,
    String? rebarDiameter,
    double? steelRate,
    double? totalWeight,
    double? totalLength,
    int? numberOfBars,
    double? weightPerMeter,
    double? estimatedCost,
    DateTime? calculatedAt,
  }) {
    return RebarCalculation(
      id: id ?? this.id,
      structureType: structureType ?? this.structureType,
      concreteVolume: concreteVolume ?? this.concreteVolume,
      rebarDiameter: rebarDiameter ?? this.rebarDiameter,
      steelRate: steelRate ?? this.steelRate,
      totalWeight: totalWeight ?? this.totalWeight,
      totalLength: totalLength ?? this.totalLength,
      numberOfBars: numberOfBars ?? this.numberOfBars,
      weightPerMeter: weightPerMeter ?? this.weightPerMeter,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        structureType,
        concreteVolume,
        rebarDiameter,
        steelRate,
        totalWeight,
        totalLength,
        numberOfBars,
        weightPerMeter,
        estimatedCost,
        calculatedAt,
      ];
}
