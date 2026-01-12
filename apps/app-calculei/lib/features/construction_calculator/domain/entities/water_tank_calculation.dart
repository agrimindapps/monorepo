import 'package:equatable/equatable.dart';

/// Pure domain entity - Water tank calculation result
///
/// Represents the complete calculation of water tank capacity
/// based on number of people, daily consumption, and reserve days
class WaterTankCalculation extends Equatable {
  /// Unique identifier for this calculation
  final String id;

  /// Number of people
  final int numberOfPeople;

  /// Daily consumption per person in liters (default: 150L)
  final double dailyConsumption;

  /// Reserve days (typically 1-3 days)
  final int reserveDays;

  /// Total capacity needed in liters
  final double totalCapacity;

  /// Recommended tank size in liters (from standard sizes)
  final int recommendedTankSize;

  /// Tank type (Polietileno, Fibra, Aço Inox)
  final String tankType;

  /// Estimated cost (optional)
  final double? estimatedCost;

  /// Calculation timestamp
  final DateTime calculatedAt;

  const WaterTankCalculation({
    required this.id,
    required this.numberOfPeople,
    required this.dailyConsumption,
    required this.reserveDays,
    required this.totalCapacity,
    required this.recommendedTankSize,
    required this.tankType,
    this.estimatedCost,
    required this.calculatedAt,
  });

  /// Create empty calculation
  factory WaterTankCalculation.empty() {
    return WaterTankCalculation(
      id: '',
      numberOfPeople: 0,
      dailyConsumption: 150.0,
      reserveDays: 2,
      totalCapacity: 0,
      recommendedTankSize: 0,
      tankType: 'Polietileno',
      calculatedAt: DateTime.now(),
    );
  }

  WaterTankCalculation copyWith({
    String? id,
    int? numberOfPeople,
    double? dailyConsumption,
    int? reserveDays,
    double? totalCapacity,
    int? recommendedTankSize,
    String? tankType,
    double? estimatedCost,
    DateTime? calculatedAt,
  }) {
    return WaterTankCalculation(
      id: id ?? this.id,
      numberOfPeople: numberOfPeople ?? this.numberOfPeople,
      dailyConsumption: dailyConsumption ?? this.dailyConsumption,
      reserveDays: reserveDays ?? this.reserveDays,
      totalCapacity: totalCapacity ?? this.totalCapacity,
      recommendedTankSize: recommendedTankSize ?? this.recommendedTankSize,
      tankType: tankType ?? this.tankType,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        numberOfPeople,
        dailyConsumption,
        reserveDays,
        totalCapacity,
        recommendedTankSize,
        tankType,
        estimatedCost,
        calculatedAt,
      ];
}
