import 'package:equatable/equatable.dart';

/// Pure domain entity - Electrical calculation result
///
/// Represents the complete calculation of electrical installation
/// including current, wire gauge, breaker sizing, and cable length
class ElectricalCalculation extends Equatable {
  /// Unique identifier for this calculation
  final String id;

  /// Total power in watts (W)
  final double totalPower;

  /// Voltage in volts (127V or 220V)
  final double voltage;

  /// Circuit type (Monofásico, Bifásico, Trifásico)
  final String circuitType;

  /// Total current in amperes (A) - calculated
  final double totalCurrent;

  /// Recommended breaker size in amperes (A)
  final int recommendedBreakerSize;

  /// Wire gauge in mm²
  final double wireGauge;

  /// Estimated cable length in meters
  final double estimatedCableLength;

  /// Number of circuits
  final int numberOfCircuits;

  /// Voltage drop percentage (optional)
  final double? voltageDrop;

  /// Calculation timestamp
  final DateTime calculatedAt;

  const ElectricalCalculation({
    required this.id,
    required this.totalPower,
    required this.voltage,
    required this.circuitType,
    required this.totalCurrent,
    required this.recommendedBreakerSize,
    required this.wireGauge,
    required this.estimatedCableLength,
    required this.numberOfCircuits,
    this.voltageDrop,
    required this.calculatedAt,
  });

  /// Create empty calculation
  factory ElectricalCalculation.empty() {
    return ElectricalCalculation(
      id: '',
      totalPower: 0,
      voltage: 127,
      circuitType: 'Monofásico',
      totalCurrent: 0,
      recommendedBreakerSize: 0,
      wireGauge: 0,
      estimatedCableLength: 0,
      numberOfCircuits: 1,
      calculatedAt: DateTime.now(),
    );
  }

  ElectricalCalculation copyWith({
    String? id,
    double? totalPower,
    double? voltage,
    String? circuitType,
    double? totalCurrent,
    int? recommendedBreakerSize,
    double? wireGauge,
    double? estimatedCableLength,
    int? numberOfCircuits,
    double? voltageDrop,
    DateTime? calculatedAt,
  }) {
    return ElectricalCalculation(
      id: id ?? this.id,
      totalPower: totalPower ?? this.totalPower,
      voltage: voltage ?? this.voltage,
      circuitType: circuitType ?? this.circuitType,
      totalCurrent: totalCurrent ?? this.totalCurrent,
      recommendedBreakerSize:
          recommendedBreakerSize ?? this.recommendedBreakerSize,
      wireGauge: wireGauge ?? this.wireGauge,
      estimatedCableLength: estimatedCableLength ?? this.estimatedCableLength,
      numberOfCircuits: numberOfCircuits ?? this.numberOfCircuits,
      voltageDrop: voltageDrop ?? this.voltageDrop,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        totalPower,
        voltage,
        circuitType,
        totalCurrent,
        recommendedBreakerSize,
        wireGauge,
        estimatedCableLength,
        numberOfCircuits,
        voltageDrop,
        calculatedAt,
      ];
}
