import 'package:equatable/equatable.dart';

/// Pure domain entity - Drywall calculation result
///
/// Represents the complete calculation of drywall materials
/// needed for wall construction projects
class DrywallCalculation extends Equatable {
  /// Unique identifier for this calculation
  final String id;

  /// Wall length in meters
  final double length;

  /// Wall height in meters
  final double height;

  /// Total wall area in square meters (m²)
  final double wallArea;

  /// Wall type (Simples, Dupla, Acústica)
  final String wallType;

  /// Number of drywall panels (1.20m × 2.40m standard = 2.88m²)
  final int numberOfPanels;

  /// Montantes (vertical profiles) in meters
  final double montantesMeters;

  /// Guias (horizontal profiles - top + bottom) in meters
  final double guiasMeters;

  /// Total profiles in meters (montantes + guias)
  final double profilesMeters;

  /// Number of screws needed
  final int screwsCount;

  /// Joint tape in meters
  final double jointTapeMeters;

  /// Joint compound in kilograms
  final double jointCompoundKg;

  /// Estimated cost (optional)
  final double? estimatedCost;

  /// Calculation timestamp
  final DateTime calculatedAt;

  const DrywallCalculation({
    required this.id,
    required this.length,
    required this.height,
    required this.wallArea,
    required this.wallType,
    required this.numberOfPanels,
    required this.montantesMeters,
    required this.guiasMeters,
    required this.profilesMeters,
    required this.screwsCount,
    required this.jointTapeMeters,
    required this.jointCompoundKg,
    this.estimatedCost,
    required this.calculatedAt,
  });

  /// Create empty calculation
  factory DrywallCalculation.empty() {
    return DrywallCalculation(
      id: '',
      length: 0,
      height: 0,
      wallArea: 0,
      wallType: 'Simples',
      numberOfPanels: 0,
      montantesMeters: 0,
      guiasMeters: 0,
      profilesMeters: 0,
      screwsCount: 0,
      jointTapeMeters: 0,
      jointCompoundKg: 0,
      calculatedAt: DateTime.now(),
    );
  }

  DrywallCalculation copyWith({
    String? id,
    double? length,
    double? height,
    double? wallArea,
    String? wallType,
    int? numberOfPanels,
    double? montantesMeters,
    double? guiasMeters,
    double? profilesMeters,
    int? screwsCount,
    double? jointTapeMeters,
    double? jointCompoundKg,
    double? estimatedCost,
    DateTime? calculatedAt,
  }) {
    return DrywallCalculation(
      id: id ?? this.id,
      length: length ?? this.length,
      height: height ?? this.height,
      wallArea: wallArea ?? this.wallArea,
      wallType: wallType ?? this.wallType,
      numberOfPanels: numberOfPanels ?? this.numberOfPanels,
      montantesMeters: montantesMeters ?? this.montantesMeters,
      guiasMeters: guiasMeters ?? this.guiasMeters,
      profilesMeters: profilesMeters ?? this.profilesMeters,
      screwsCount: screwsCount ?? this.screwsCount,
      jointTapeMeters: jointTapeMeters ?? this.jointTapeMeters,
      jointCompoundKg: jointCompoundKg ?? this.jointCompoundKg,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        length,
        height,
        wallArea,
        wallType,
        numberOfPanels,
        montantesMeters,
        guiasMeters,
        profilesMeters,
        screwsCount,
        jointTapeMeters,
        jointCompoundKg,
        estimatedCost,
        calculatedAt,
      ];
}
