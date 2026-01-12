import 'package:equatable/equatable.dart';

/// Pure domain entity - Plumbing calculation result
///
/// Represents the complete calculation of PVC pipes and fittings
/// needed for plumbing systems (water supply, sewage, drainage)
class PlumbingCalculation extends Equatable {
  /// Unique identifier for this calculation
  final String id;

  /// System type (e.g., "Água Fria", "Água Quente", "Esgoto", "Pluvial")
  final String systemType;

  /// Pipe diameter (e.g., "20mm", "25mm", "32mm", "40mm", "50mm", "75mm", "100mm")
  final String pipeDiameter;

  /// Total length needed in meters
  final double totalLength;

  /// Number of 90° elbows
  final int numberOfElbows;

  /// Number of T-junctions (tees)
  final int numberOfTees;

  /// Number of straight couplings
  final int numberOfCouplings;

  /// Total number of pipe tubes (6m standard)
  final int pipeCount;

  /// Total glue amount needed in ml
  final double glueAmount;

  /// Estimated cost (optional)
  final double? estimatedCost;

  /// Calculation timestamp
  final DateTime calculatedAt;

  const PlumbingCalculation({
    required this.id,
    required this.systemType,
    required this.pipeDiameter,
    required this.totalLength,
    required this.numberOfElbows,
    required this.numberOfTees,
    required this.numberOfCouplings,
    required this.pipeCount,
    required this.glueAmount,
    this.estimatedCost,
    required this.calculatedAt,
  });

  /// Create empty calculation
  factory PlumbingCalculation.empty() {
    return PlumbingCalculation(
      id: '',
      systemType: 'Água Fria',
      pipeDiameter: '25mm',
      totalLength: 0,
      numberOfElbows: 0,
      numberOfTees: 0,
      numberOfCouplings: 0,
      pipeCount: 0,
      glueAmount: 0,
      calculatedAt: DateTime.now(),
    );
  }

  PlumbingCalculation copyWith({
    String? id,
    String? systemType,
    String? pipeDiameter,
    double? totalLength,
    int? numberOfElbows,
    int? numberOfTees,
    int? numberOfCouplings,
    int? pipeCount,
    double? glueAmount,
    double? estimatedCost,
    DateTime? calculatedAt,
  }) {
    return PlumbingCalculation(
      id: id ?? this.id,
      systemType: systemType ?? this.systemType,
      pipeDiameter: pipeDiameter ?? this.pipeDiameter,
      totalLength: totalLength ?? this.totalLength,
      numberOfElbows: numberOfElbows ?? this.numberOfElbows,
      numberOfTees: numberOfTees ?? this.numberOfTees,
      numberOfCouplings: numberOfCouplings ?? this.numberOfCouplings,
      pipeCount: pipeCount ?? this.pipeCount,
      glueAmount: glueAmount ?? this.glueAmount,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        systemType,
        pipeDiameter,
        totalLength,
        numberOfElbows,
        numberOfTees,
        numberOfCouplings,
        pipeCount,
        glueAmount,
        estimatedCost,
        calculatedAt,
      ];
}
