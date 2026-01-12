import 'package:equatable/equatable.dart';

/// Pure domain entity - Field capacity calculation result
///
/// Represents the complete calculation of field capacity for agricultural machinery operations
/// including theoretical and effective capacity, work hours, and daily productivity
class FieldCapacityCalculation extends Equatable {
  /// Unique identifier for this calculation
  final String id;

  /// Working width of the implement in meters
  final double workingWidth;

  /// Working speed in kilometers per hour
  final double workingSpeed;

  /// Field efficiency as percentage (0-100)
  final double fieldEfficiency;

  /// Type of operation (Preparo/Plantio/Pulverização/Colheita)
  final String operationType;

  /// Theoretical capacity in hectares per hour (ha/h)
  /// Formula: (width × speed) / 10
  final double theoreticalCapacity;

  /// Effective capacity in hectares per hour (ha/h)
  /// Formula: theoretical × (efficiency / 100)
  final double effectiveCapacity;

  /// Hours required to work 1 hectare
  final double hoursPerHectare;

  /// Hectares that can be worked in 8 hours
  final double hectaresPerDay8h;

  /// Hectares that can be worked in 10 hours
  final double hectaresPerDay10h;

  /// Calculation timestamp
  final DateTime calculatedAt;

  const FieldCapacityCalculation({
    required this.id,
    required this.workingWidth,
    required this.workingSpeed,
    required this.fieldEfficiency,
    required this.operationType,
    required this.theoreticalCapacity,
    required this.effectiveCapacity,
    required this.hoursPerHectare,
    required this.hectaresPerDay8h,
    required this.hectaresPerDay10h,
    required this.calculatedAt,
  });

  /// Create empty calculation
  factory FieldCapacityCalculation.empty() {
    return FieldCapacityCalculation(
      id: '',
      workingWidth: 0,
      workingSpeed: 0,
      fieldEfficiency: 0,
      operationType: 'Preparo',
      theoreticalCapacity: 0,
      effectiveCapacity: 0,
      hoursPerHectare: 0,
      hectaresPerDay8h: 0,
      hectaresPerDay10h: 0,
      calculatedAt: DateTime.now(),
    );
  }

  FieldCapacityCalculation copyWith({
    String? id,
    double? workingWidth,
    double? workingSpeed,
    double? fieldEfficiency,
    String? operationType,
    double? theoreticalCapacity,
    double? effectiveCapacity,
    double? hoursPerHectare,
    double? hectaresPerDay8h,
    double? hectaresPerDay10h,
    DateTime? calculatedAt,
  }) {
    return FieldCapacityCalculation(
      id: id ?? this.id,
      workingWidth: workingWidth ?? this.workingWidth,
      workingSpeed: workingSpeed ?? this.workingSpeed,
      fieldEfficiency: fieldEfficiency ?? this.fieldEfficiency,
      operationType: operationType ?? this.operationType,
      theoreticalCapacity: theoreticalCapacity ?? this.theoreticalCapacity,
      effectiveCapacity: effectiveCapacity ?? this.effectiveCapacity,
      hoursPerHectare: hoursPerHectare ?? this.hoursPerHectare,
      hectaresPerDay8h: hectaresPerDay8h ?? this.hectaresPerDay8h,
      hectaresPerDay10h: hectaresPerDay10h ?? this.hectaresPerDay10h,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        workingWidth,
        workingSpeed,
        fieldEfficiency,
        operationType,
        theoreticalCapacity,
        effectiveCapacity,
        hoursPerHectare,
        hectaresPerDay8h,
        hectaresPerDay10h,
        calculatedAt,
      ];
}
