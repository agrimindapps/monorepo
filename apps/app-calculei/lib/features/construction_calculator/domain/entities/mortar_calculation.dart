import 'package:equatable/equatable.dart';

/// Pure domain entity - Mortar calculation result
///
/// Represents the complete calculation of mortar volume and materials
/// needed for construction projects (masonry, plaster, screed, etc.)
class MortarCalculation extends Equatable {
  /// Unique identifier for this calculation
  final String id;

  /// Area in square meters (m²)
  final double area;

  /// Thickness in centimeters (cm)
  final double thickness;

  /// Mortar type (Assentamento, Reboco, Contrapiso, Chapisco)
  final String mortarType;

  /// Total mortar volume in cubic meters (m³)
  final double mortarVolume;

  /// Cement bags (50kg) needed
  final int cementBags;

  /// Sand in cubic meters
  final double sandCubicMeters;

  /// Water in liters
  final double waterLiters;

  /// Estimated cost (optional)
  final double? estimatedCost;

  /// Calculation timestamp
  final DateTime calculatedAt;

  const MortarCalculation({
    required this.id,
    required this.area,
    required this.thickness,
    required this.mortarType,
    required this.mortarVolume,
    required this.cementBags,
    required this.sandCubicMeters,
    required this.waterLiters,
    this.estimatedCost,
    required this.calculatedAt,
  });

  /// Create empty calculation
  factory MortarCalculation.empty() {
    return MortarCalculation(
      id: '',
      area: 0,
      thickness: 0,
      mortarType: 'Assentamento',
      mortarVolume: 0,
      cementBags: 0,
      sandCubicMeters: 0,
      waterLiters: 0,
      calculatedAt: DateTime.now(),
    );
  }

  MortarCalculation copyWith({
    String? id,
    double? area,
    double? thickness,
    String? mortarType,
    double? mortarVolume,
    int? cementBags,
    double? sandCubicMeters,
    double? waterLiters,
    double? estimatedCost,
    DateTime? calculatedAt,
  }) {
    return MortarCalculation(
      id: id ?? this.id,
      area: area ?? this.area,
      thickness: thickness ?? this.thickness,
      mortarType: mortarType ?? this.mortarType,
      mortarVolume: mortarVolume ?? this.mortarVolume,
      cementBags: cementBags ?? this.cementBags,
      sandCubicMeters: sandCubicMeters ?? this.sandCubicMeters,
      waterLiters: waterLiters ?? this.waterLiters,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        area,
        thickness,
        mortarType,
        mortarVolume,
        cementBags,
        sandCubicMeters,
        waterLiters,
        estimatedCost,
        calculatedAt,
      ];
}
