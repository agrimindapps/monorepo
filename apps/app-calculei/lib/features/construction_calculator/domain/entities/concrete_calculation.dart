import 'package:equatable/equatable.dart';

/// Pure domain entity - Concrete calculation result
///
/// Represents the complete calculation of concrete volume and materials
/// needed for construction projects (slabs, foundations, pillars, etc.)
class ConcreteCalculation extends Equatable {
  /// Unique identifier for this calculation
  final String id;

  /// Length in meters
  final double length;

  /// Width in meters
  final double width;

  /// Height/thickness in meters
  final double height;

  /// Total volume in cubic meters (m³)
  final double volume;

  /// Cement bags (50kg) needed
  final int cementBags;

  /// Sand in cubic meters
  final double sandCubicMeters;

  /// Gravel in cubic meters
  final double gravelCubicMeters;

  /// Water in liters
  final double waterLiters;

  /// Concrete type (e.g., "Estrutural", "Magro", "Bombeável")
  final String concreteType;

  /// Concrete strength (e.g., "20 MPa", "25 MPa", "30 MPa")
  final String concreteStrength;

  /// Estimated cost (optional)
  final double? estimatedCost;

  /// Calculation timestamp
  final DateTime calculatedAt;

  const ConcreteCalculation({
    required this.id,
    required this.length,
    required this.width,
    required this.height,
    required this.volume,
    required this.cementBags,
    required this.sandCubicMeters,
    required this.gravelCubicMeters,
    required this.waterLiters,
    required this.concreteType,
    required this.concreteStrength,
    this.estimatedCost,
    required this.calculatedAt,
  });

  /// Create empty calculation
  factory ConcreteCalculation.empty() {
    return ConcreteCalculation(
      id: '',
      length: 0,
      width: 0,
      height: 0,
      volume: 0,
      cementBags: 0,
      sandCubicMeters: 0,
      gravelCubicMeters: 0,
      waterLiters: 0,
      concreteType: 'Estrutural',
      concreteStrength: '25 MPa',
      calculatedAt: DateTime.now(),
    );
  }

  ConcreteCalculation copyWith({
    String? id,
    double? length,
    double? width,
    double? height,
    double? volume,
    int? cementBags,
    double? sandCubicMeters,
    double? gravelCubicMeters,
    double? waterLiters,
    String? concreteType,
    String? concreteStrength,
    double? estimatedCost,
    DateTime? calculatedAt,
  }) {
    return ConcreteCalculation(
      id: id ?? this.id,
      length: length ?? this.length,
      width: width ?? this.width,
      height: height ?? this.height,
      volume: volume ?? this.volume,
      cementBags: cementBags ?? this.cementBags,
      sandCubicMeters: sandCubicMeters ?? this.sandCubicMeters,
      gravelCubicMeters: gravelCubicMeters ?? this.gravelCubicMeters,
      waterLiters: waterLiters ?? this.waterLiters,
      concreteType: concreteType ?? this.concreteType,
      concreteStrength: concreteStrength ?? this.concreteStrength,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        length,
        width,
        height,
        volume,
        cementBags,
        sandCubicMeters,
        gravelCubicMeters,
        waterLiters,
        concreteType,
        concreteStrength,
        estimatedCost,
        calculatedAt,
      ];
}
