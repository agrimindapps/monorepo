import 'package:equatable/equatable.dart';

/// Water Record entity - individual water intake records
class WaterRecordEntity extends Equatable {
  final String id;
  final int amountMl;
  final DateTime timestamp;
  final String? note;
  final String? cupType;

  const WaterRecordEntity({
    required this.id,
    required this.amountMl,
    required this.timestamp,
    this.note,
    this.cupType,
  });

  WaterRecordEntity copyWith({
    String? id,
    int? amountMl,
    DateTime? timestamp,
    String? note,
    String? cupType,
  }) {
    return WaterRecordEntity(
      id: id ?? this.id,
      amountMl: amountMl ?? this.amountMl,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
      cupType: cupType ?? this.cupType,
    );
  }

  @override
  List<Object?> get props => [id, amountMl, timestamp, note, cupType];
}
