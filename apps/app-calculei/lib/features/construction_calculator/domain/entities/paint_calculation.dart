import 'package:equatable/equatable.dart';

/// Pure domain entity - Paint consumption calculation result
///
/// Represents the calculation of paint needed for a given area
class PaintCalculation extends Equatable {
  /// Unique identifier for this calculation
  final String id;

  /// Total wall area in square meters
  final double wallArea;

  /// Door/window area to subtract in square meters
  final double openingsArea;

  /// Net area to paint in square meters
  final double netArea;

  /// Number of paint coats
  final int coats;

  /// Paint yield (m² per liter)
  final double paintYield;

  /// Total paint needed in liters
  final double paintLiters;

  /// Paint cans needed (3.6L cans)
  final int smallCans;

  /// Paint cans needed (18L cans)
  final int largeCans;

  /// Recommended option (best cost-benefit)
  final String recommendedOption;

  /// Paint type (e.g., "Acrílica", "Látex", "Esmalte")
  final String paintType;

  /// Estimated cost (optional)
  final double? estimatedCost;

  /// Calculation timestamp
  final DateTime calculatedAt;

  const PaintCalculation({
    required this.id,
    required this.wallArea,
    required this.openingsArea,
    required this.netArea,
    required this.coats,
    required this.paintYield,
    required this.paintLiters,
    required this.smallCans,
    required this.largeCans,
    required this.recommendedOption,
    required this.paintType,
    this.estimatedCost,
    required this.calculatedAt,
  });

  /// Create empty calculation
  factory PaintCalculation.empty() {
    return PaintCalculation(
      id: '',
      wallArea: 0,
      openingsArea: 0,
      netArea: 0,
      coats: 2,
      paintYield: 10,
      paintLiters: 0,
      smallCans: 0,
      largeCans: 0,
      recommendedOption: '',
      paintType: 'Acrílica',
      calculatedAt: DateTime.now(),
    );
  }

  PaintCalculation copyWith({
    String? id,
    double? wallArea,
    double? openingsArea,
    double? netArea,
    int? coats,
    double? paintYield,
    double? paintLiters,
    int? smallCans,
    int? largeCans,
    String? recommendedOption,
    String? paintType,
    double? estimatedCost,
    DateTime? calculatedAt,
  }) {
    return PaintCalculation(
      id: id ?? this.id,
      wallArea: wallArea ?? this.wallArea,
      openingsArea: openingsArea ?? this.openingsArea,
      netArea: netArea ?? this.netArea,
      coats: coats ?? this.coats,
      paintYield: paintYield ?? this.paintYield,
      paintLiters: paintLiters ?? this.paintLiters,
      smallCans: smallCans ?? this.smallCans,
      largeCans: largeCans ?? this.largeCans,
      recommendedOption: recommendedOption ?? this.recommendedOption,
      paintType: paintType ?? this.paintType,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        wallArea,
        openingsArea,
        netArea,
        coats,
        paintYield,
        paintLiters,
        smallCans,
        largeCans,
        recommendedOption,
        paintType,
        estimatedCost,
        calculatedAt,
      ];
}
