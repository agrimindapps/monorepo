import 'package:equatable/equatable.dart';

/// Pure domain entity - Glass/Window calculation result
///
/// Represents the complete calculation of glass panels needed
/// for windows, doors, facades, and other glazing projects
class GlassCalculation extends Equatable {
  /// Unique identifier for this calculation
  final String id;

  /// Width in meters
  final double width;

  /// Height in meters
  final double height;

  /// Type of glass (Comum/Temperado/Laminado/Fumê)
  final String glassType;

  /// Glass thickness in mm (4mm, 6mm, 8mm, 10mm)
  final int glassThickness;

  /// Number of panels
  final int numberOfPanels;

  /// Total area in square meters (m²)
  final double totalArea;

  /// Estimated weight in kilograms
  final double estimatedWeight;

  /// Estimated cost (optional)
  final double? estimatedCost;

  /// Calculation timestamp
  final DateTime calculatedAt;

  const GlassCalculation({
    required this.id,
    required this.width,
    required this.height,
    required this.glassType,
    required this.glassThickness,
    required this.numberOfPanels,
    required this.totalArea,
    required this.estimatedWeight,
    this.estimatedCost,
    required this.calculatedAt,
  });

  /// Create empty calculation
  factory GlassCalculation.empty() {
    return GlassCalculation(
      id: '',
      width: 0,
      height: 0,
      glassType: 'Comum',
      glassThickness: 6,
      numberOfPanels: 0,
      totalArea: 0,
      estimatedWeight: 0,
      calculatedAt: DateTime.now(),
    );
  }

  GlassCalculation copyWith({
    String? id,
    double? width,
    double? height,
    String? glassType,
    int? glassThickness,
    int? numberOfPanels,
    double? totalArea,
    double? estimatedWeight,
    double? estimatedCost,
    DateTime? calculatedAt,
  }) {
    return GlassCalculation(
      id: id ?? this.id,
      width: width ?? this.width,
      height: height ?? this.height,
      glassType: glassType ?? this.glassType,
      glassThickness: glassThickness ?? this.glassThickness,
      numberOfPanels: numberOfPanels ?? this.numberOfPanels,
      totalArea: totalArea ?? this.totalArea,
      estimatedWeight: estimatedWeight ?? this.estimatedWeight,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        width,
        height,
        glassType,
        glassThickness,
        numberOfPanels,
        totalArea,
        estimatedWeight,
        estimatedCost,
        calculatedAt,
      ];
}
