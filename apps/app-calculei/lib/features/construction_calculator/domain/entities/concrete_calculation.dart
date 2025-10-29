import 'package:equatable/equatable.dart';

/// Entity representing a concrete calculation
///
/// Follows Single Responsibility Principle (SRP):
/// - Only holds data for concrete calculation
/// - Immutable and comparable with Equatable
class ConcreteCalculation extends Equatable {
  const ConcreteCalculation({
    required this.length,
    required this.width,
    required this.height,
    required this.volume,
    required this.cementBags,
    required this.sandVolume,
    required this.gravelVolume,
    required this.waterVolume,
    required this.totalCost,
    required this.concreteType,
  });

  /// Length in meters
  final double length;

  /// Width in meters
  final double width;

  /// Height in meters
  final double height;

  /// Total volume in cubic meters
  final double volume;

  /// Number of cement bags needed (50kg bags)
  final double cementBags;

  /// Sand volume in cubic meters
  final double sandVolume;

  /// Gravel volume in cubic meters
  final double gravelVolume;

  /// Water volume in liters
  final double waterVolume;

  /// Total cost (if prices are provided)
  final double? totalCost;

  /// Type of concrete (e.g., "fck 15", "fck 20", etc.)
  final String concreteType;

  /// Volume per cement bag ratio (m³ per 50kg bag)
  double get volumePerBag => volume / cementBags;

  @override
  List<Object?> get props => [
        length,
        width,
        height,
        volume,
        cementBags,
        sandVolume,
        gravelVolume,
        waterVolume,
        totalCost,
        concreteType,
      ];
}
