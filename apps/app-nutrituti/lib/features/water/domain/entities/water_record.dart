import 'package:equatable/equatable.dart';

/// Pure Dart entity for water intake records
/// No dependencies on infrastructure (Hive, JSON, etc.)
class WaterRecord extends Equatable {
  final String id;
  final int amount; // ml
  final DateTime timestamp;
  final String? note;

  const WaterRecord({
    required this.id,
    required this.amount,
    required this.timestamp,
    this.note,
  });

  /// Copy with pattern for immutability
  WaterRecord copyWith({
    String? id,
    int? amount,
    DateTime? timestamp,
    String? note,
  }) {
    return WaterRecord(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [id, amount, timestamp, note];

  @override
  String toString() {
    return 'WaterRecord(id: $id, amount: $amount ml, timestamp: $timestamp, note: $note)';
  }
}
