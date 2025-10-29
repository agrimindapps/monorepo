import 'package:equatable/equatable.dart';

/// Entity representing a flooring calculation
///
/// Follows Single Responsibility Principle (SRP):
/// - Only holds data for flooring calculation
/// - Immutable and comparable with Equatable
class FlooringCalculation extends Equatable {
  const FlooringCalculation({
    required this.area,
    required this.tileWidth,
    required this.tileLength,
    required this.tilesNeeded,
    required this.totalCost,
    required this.wastePercentage,
    required this.tilesWithWaste,
  });

  /// Area in square meters
  final double area;

  /// Tile width in centimeters
  final double tileWidth;

  /// Tile length in centimeters
  final double tileLength;

  /// Number of tiles needed (without waste)
  final int tilesNeeded;

  /// Total cost (if price per tile is provided)
  final double? totalCost;

  /// Waste percentage (default 10%)
  final double wastePercentage;

  /// Number of tiles needed including waste
  final int tilesWithWaste;

  /// Area per tile in square meters
  double get areaPerTile => (tileWidth * tileLength) / 10000;

  @override
  List<Object?> get props => [
        area,
        tileWidth,
        tileLength,
        tilesNeeded,
        totalCost,
        wastePercentage,
        tilesWithWaste,
      ];
}
