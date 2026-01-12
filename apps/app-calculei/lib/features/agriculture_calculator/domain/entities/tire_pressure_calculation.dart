import 'package:equatable/equatable.dart';

/// Pure domain entity - Tire pressure calculation result
///
/// Represents the complete calculation of recommended tire pressure for agricultural machinery
/// including adjustments for operation type, tire type, and field conditions verification
class TirePressureCalculation extends Equatable {
  /// Unique identifier for this calculation
  final String id;

  /// Type of agricultural tire
  /// Options: 'Agrícola Diagonal', 'Agrícola Radial', 'Implemento'
  final String tireType;

  /// Axle load in kilograms
  final double axleLoad;

  /// Tire size (e.g., "18.4-34", "14.9-28", "12.4/11-28")
  final String tireSize;

  /// Type of operation
  /// Options: 'Campo', 'Estrada', 'Misto'
  final String operationType;

  /// Recommended pressure in PSI (pounds per square inch)
  final double recommendedPressurePsi;

  /// Recommended pressure in BAR
  final double recommendedPressureBar;

  /// Minimum safe pressure in PSI
  final double minPressurePsi;

  /// Minimum safe pressure in BAR
  final double minPressureBar;

  /// Maximum safe pressure in PSI
  final double maxPressurePsi;

  /// Maximum safe pressure in BAR
  final double maxPressureBar;

  /// Expected footprint length in centimeters for field verification
  /// This helps verify correct pressure in the field
  final double footprintLength;

  /// Base pressure before operation adjustments (PSI)
  final double basePressurePsi;

  /// Adjustment factor applied based on operation type
  final double operationAdjustment;

  /// Adjustment factor applied based on tire type
  final double tireTypeAdjustment;

  /// Calculation timestamp
  final DateTime calculatedAt;

  const TirePressureCalculation({
    required this.id,
    required this.tireType,
    required this.axleLoad,
    required this.tireSize,
    required this.operationType,
    required this.recommendedPressurePsi,
    required this.recommendedPressureBar,
    required this.minPressurePsi,
    required this.minPressureBar,
    required this.maxPressurePsi,
    required this.maxPressureBar,
    required this.footprintLength,
    required this.basePressurePsi,
    required this.operationAdjustment,
    required this.tireTypeAdjustment,
    required this.calculatedAt,
  });

  /// Create empty calculation
  factory TirePressureCalculation.empty() {
    return TirePressureCalculation(
      id: '',
      tireType: 'Agrícola Diagonal',
      axleLoad: 0,
      tireSize: '',
      operationType: 'Campo',
      recommendedPressurePsi: 0,
      recommendedPressureBar: 0,
      minPressurePsi: 0,
      minPressureBar: 0,
      maxPressurePsi: 0,
      maxPressureBar: 0,
      footprintLength: 0,
      basePressurePsi: 0,
      operationAdjustment: 0,
      tireTypeAdjustment: 0,
      calculatedAt: DateTime.now(),
    );
  }

  TirePressureCalculation copyWith({
    String? id,
    String? tireType,
    double? axleLoad,
    String? tireSize,
    String? operationType,
    double? recommendedPressurePsi,
    double? recommendedPressureBar,
    double? minPressurePsi,
    double? minPressureBar,
    double? maxPressurePsi,
    double? maxPressureBar,
    double? footprintLength,
    double? basePressurePsi,
    double? operationAdjustment,
    double? tireTypeAdjustment,
    DateTime? calculatedAt,
  }) {
    return TirePressureCalculation(
      id: id ?? this.id,
      tireType: tireType ?? this.tireType,
      axleLoad: axleLoad ?? this.axleLoad,
      tireSize: tireSize ?? this.tireSize,
      operationType: operationType ?? this.operationType,
      recommendedPressurePsi:
          recommendedPressurePsi ?? this.recommendedPressurePsi,
      recommendedPressureBar:
          recommendedPressureBar ?? this.recommendedPressureBar,
      minPressurePsi: minPressurePsi ?? this.minPressurePsi,
      minPressureBar: minPressureBar ?? this.minPressureBar,
      maxPressurePsi: maxPressurePsi ?? this.maxPressurePsi,
      maxPressureBar: maxPressureBar ?? this.maxPressureBar,
      footprintLength: footprintLength ?? this.footprintLength,
      basePressurePsi: basePressurePsi ?? this.basePressurePsi,
      operationAdjustment: operationAdjustment ?? this.operationAdjustment,
      tireTypeAdjustment: tireTypeAdjustment ?? this.tireTypeAdjustment,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        tireType,
        axleLoad,
        tireSize,
        operationType,
        recommendedPressurePsi,
        recommendedPressureBar,
        minPressurePsi,
        minPressureBar,
        maxPressurePsi,
        maxPressureBar,
        footprintLength,
        basePressurePsi,
        operationAdjustment,
        tireTypeAdjustment,
        calculatedAt,
      ];
}
