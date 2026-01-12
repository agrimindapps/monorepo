import 'package:equatable/equatable.dart';

/// Pure domain entity - Slab calculation result
///
/// Represents the complete calculation of slab volume and materials
/// needed for different types of slabs (Maciça, Treliçada, Pré-moldada, Nervurada)
class SlabCalculation extends Equatable {
  /// Unique identifier for this calculation
  final String id;

  /// Length in meters
  final double length;

  /// Width in meters
  final double width;

  /// Thickness in centimeters
  final double thickness;

  /// Slab type (Maciça, Treliçada, Pré-moldada, Nervurada)
  final String slabType;

  /// Total concrete volume in cubic meters (m³)
  final double concreteVolume;

  /// Cement bags (50kg) needed
  final int cementBags;

  /// Sand in cubic meters
  final double sandCubicMeters;

  /// Gravel in cubic meters
  final double gravelCubicMeters;

  /// Steel weight in kilograms (80 kg/m³ for slabs)
  final double steelWeight;

  /// Number of blocks needed (for Treliçada, Pré-moldada, Nervurada)
  final int numberOfBlocks;

  /// Water in liters
  final double waterLiters;

  /// Estimated cost (optional)
  final double? estimatedCost;

  /// Calculation timestamp
  final DateTime calculatedAt;

  const SlabCalculation({
    required this.id,
    required this.length,
    required this.width,
    required this.thickness,
    required this.slabType,
    required this.concreteVolume,
    required this.cementBags,
    required this.sandCubicMeters,
    required this.gravelCubicMeters,
    required this.steelWeight,
    required this.numberOfBlocks,
    required this.waterLiters,
    this.estimatedCost,
    required this.calculatedAt,
  });

  /// Create empty calculation
  factory SlabCalculation.empty() {
    return SlabCalculation(
      id: '',
      length: 0,
      width: 0,
      thickness: 0,
      slabType: 'Maciça',
      concreteVolume: 0,
      cementBags: 0,
      sandCubicMeters: 0,
      gravelCubicMeters: 0,
      steelWeight: 0,
      numberOfBlocks: 0,
      waterLiters: 0,
      calculatedAt: DateTime.now(),
    );
  }

  SlabCalculation copyWith({
    String? id,
    double? length,
    double? width,
    double? thickness,
    String? slabType,
    double? concreteVolume,
    int? cementBags,
    double? sandCubicMeters,
    double? gravelCubicMeters,
    double? steelWeight,
    int? numberOfBlocks,
    double? waterLiters,
    double? estimatedCost,
    DateTime? calculatedAt,
  }) {
    return SlabCalculation(
      id: id ?? this.id,
      length: length ?? this.length,
      width: width ?? this.width,
      thickness: thickness ?? this.thickness,
      slabType: slabType ?? this.slabType,
      concreteVolume: concreteVolume ?? this.concreteVolume,
      cementBags: cementBags ?? this.cementBags,
      sandCubicMeters: sandCubicMeters ?? this.sandCubicMeters,
      gravelCubicMeters: gravelCubicMeters ?? this.gravelCubicMeters,
      steelWeight: steelWeight ?? this.steelWeight,
      numberOfBlocks: numberOfBlocks ?? this.numberOfBlocks,
      waterLiters: waterLiters ?? this.waterLiters,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        length,
        width,
        thickness,
        slabType,
        concreteVolume,
        cementBags,
        sandCubicMeters,
        gravelCubicMeters,
        steelWeight,
        numberOfBlocks,
        waterLiters,
        estimatedCost,
        calculatedAt,
      ];
}
