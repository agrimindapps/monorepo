import 'package:equatable/equatable.dart';

/// Pure domain entity - Roof calculation result
///
/// Represents the complete calculation of roof area, tiles, and materials
/// needed for roofing projects (colonial, romana, portuguesa, etc.)
class RoofCalculation extends Equatable {
  /// Unique identifier for this calculation
  final String id;

  /// Length in meters
  final double length;

  /// Width in meters
  final double width;

  /// Roof slope percentage (%)
  final double roofSlope;

  /// Type of roof (Colonial, Romana, Portuguesa, Fibrocimento, Metálica)
  final String roofType;

  /// Total roof area in square meters (m²) - considering slope
  final double roofArea;

  /// Number of tiles needed
  final int numberOfTiles;

  /// Number of ridge tiles needed
  final int ridgeTilesCount;

  /// Ripas (battens) in linear meters
  final double ripasMeters;

  /// Caibros (rafters) in linear meters
  final double caibrosMeters;

  /// Terças (purlins) in linear meters
  final double tercasMeters;

  /// Total wood frame in linear meters
  final double woodFrameMeters;

  /// Estimated cost (optional)
  final double? estimatedCost;

  /// Calculation timestamp
  final DateTime calculatedAt;

  const RoofCalculation({
    required this.id,
    required this.length,
    required this.width,
    required this.roofSlope,
    required this.roofType,
    required this.roofArea,
    required this.numberOfTiles,
    required this.ridgeTilesCount,
    required this.ripasMeters,
    required this.caibrosMeters,
    required this.tercasMeters,
    required this.woodFrameMeters,
    this.estimatedCost,
    required this.calculatedAt,
  });

  /// Create empty calculation
  factory RoofCalculation.empty() {
    return RoofCalculation(
      id: '',
      length: 0,
      width: 0,
      roofSlope: 30,
      roofType: 'Colonial',
      roofArea: 0,
      numberOfTiles: 0,
      ridgeTilesCount: 0,
      ripasMeters: 0,
      caibrosMeters: 0,
      tercasMeters: 0,
      woodFrameMeters: 0,
      calculatedAt: DateTime.now(),
    );
  }

  RoofCalculation copyWith({
    String? id,
    double? length,
    double? width,
    double? roofSlope,
    String? roofType,
    double? roofArea,
    int? numberOfTiles,
    int? ridgeTilesCount,
    double? ripasMeters,
    double? caibrosMeters,
    double? tercasMeters,
    double? woodFrameMeters,
    double? estimatedCost,
    DateTime? calculatedAt,
  }) {
    return RoofCalculation(
      id: id ?? this.id,
      length: length ?? this.length,
      width: width ?? this.width,
      roofSlope: roofSlope ?? this.roofSlope,
      roofType: roofType ?? this.roofType,
      roofArea: roofArea ?? this.roofArea,
      numberOfTiles: numberOfTiles ?? this.numberOfTiles,
      ridgeTilesCount: ridgeTilesCount ?? this.ridgeTilesCount,
      ripasMeters: ripasMeters ?? this.ripasMeters,
      caibrosMeters: caibrosMeters ?? this.caibrosMeters,
      tercasMeters: tercasMeters ?? this.tercasMeters,
      woodFrameMeters: woodFrameMeters ?? this.woodFrameMeters,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        length,
        width,
        roofSlope,
        roofType,
        roofArea,
        numberOfTiles,
        ridgeTilesCount,
        ripasMeters,
        caibrosMeters,
        tercasMeters,
        woodFrameMeters,
        estimatedCost,
        calculatedAt,
      ];
}
