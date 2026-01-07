import 'package:equatable/equatable.dart';

/// Pure domain entity - Flooring/tile calculation result
///
/// Represents the calculation of flooring materials needed for a given area
class FlooringCalculation extends Equatable {
  /// Unique identifier for this calculation
  final String id;

  /// Room length in meters
  final double roomLength;

  /// Room width in meters
  final double roomWidth;

  /// Total room area in square meters
  final double roomArea;

  /// Tile/flooring length in centimeters
  final double tileLength;

  /// Tile/flooring width in centimeters
  final double tileWidth;

  /// Single tile area in square meters
  final double tileArea;

  /// Waste percentage (default 10%)
  final double wastePercentage;

  /// Number of tiles needed (without waste)
  final int tilesNeeded;

  /// Number of tiles needed (with waste)
  final int tilesWithWaste;

  /// Number of boxes needed (tiles per box)
  final int boxesNeeded;

  /// Tiles per box
  final int tilesPerBox;

  /// Grout needed in kg
  final double groutKg;

  /// Adhesive mortar needed in kg
  final double mortarKg;

  /// Flooring type (e.g., "Cerâmica", "Porcelanato", "Laminado")
  final String flooringType;

  /// Estimated cost (optional)
  final double? estimatedCost;

  /// Calculation timestamp
  final DateTime calculatedAt;

  const FlooringCalculation({
    required this.id,
    required this.roomLength,
    required this.roomWidth,
    required this.roomArea,
    required this.tileLength,
    required this.tileWidth,
    required this.tileArea,
    required this.wastePercentage,
    required this.tilesNeeded,
    required this.tilesWithWaste,
    required this.boxesNeeded,
    required this.tilesPerBox,
    required this.groutKg,
    required this.mortarKg,
    required this.flooringType,
    this.estimatedCost,
    required this.calculatedAt,
  });

  /// Create empty calculation
  factory FlooringCalculation.empty() {
    return FlooringCalculation(
      id: '',
      roomLength: 0,
      roomWidth: 0,
      roomArea: 0,
      tileLength: 60,
      tileWidth: 60,
      tileArea: 0,
      wastePercentage: 10,
      tilesNeeded: 0,
      tilesWithWaste: 0,
      boxesNeeded: 0,
      tilesPerBox: 6,
      groutKg: 0,
      mortarKg: 0,
      flooringType: 'Porcelanato',
      calculatedAt: DateTime.now(),
    );
  }

  FlooringCalculation copyWith({
    String? id,
    double? roomLength,
    double? roomWidth,
    double? roomArea,
    double? tileLength,
    double? tileWidth,
    double? tileArea,
    double? wastePercentage,
    int? tilesNeeded,
    int? tilesWithWaste,
    int? boxesNeeded,
    int? tilesPerBox,
    double? groutKg,
    double? mortarKg,
    String? flooringType,
    double? estimatedCost,
    DateTime? calculatedAt,
  }) {
    return FlooringCalculation(
      id: id ?? this.id,
      roomLength: roomLength ?? this.roomLength,
      roomWidth: roomWidth ?? this.roomWidth,
      roomArea: roomArea ?? this.roomArea,
      tileLength: tileLength ?? this.tileLength,
      tileWidth: tileWidth ?? this.tileWidth,
      tileArea: tileArea ?? this.tileArea,
      wastePercentage: wastePercentage ?? this.wastePercentage,
      tilesNeeded: tilesNeeded ?? this.tilesNeeded,
      tilesWithWaste: tilesWithWaste ?? this.tilesWithWaste,
      boxesNeeded: boxesNeeded ?? this.boxesNeeded,
      tilesPerBox: tilesPerBox ?? this.tilesPerBox,
      groutKg: groutKg ?? this.groutKg,
      mortarKg: mortarKg ?? this.mortarKg,
      flooringType: flooringType ?? this.flooringType,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        roomLength,
        roomWidth,
        roomArea,
        tileLength,
        tileWidth,
        tileArea,
        wastePercentage,
        tilesNeeded,
        tilesWithWaste,
        boxesNeeded,
        tilesPerBox,
        groutKg,
        mortarKg,
        flooringType,
        estimatedCost,
        calculatedAt,
      ];
}
