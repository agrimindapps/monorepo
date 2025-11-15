import '../../domain/entities/water_record.dart';

/// Data model for water intake records with persistence support
/// Extends pure domain entity with serialization capabilities
class WaterRecordModel extends WaterRecord {
  @override
  final String id;

  @override
  final int amount;

  @override
  final DateTime timestamp;

  @override
  final String? note;

  const WaterRecordModel({
    required this.id,
    required this.amount,
    required this.timestamp,
    this.note,
  }) : super(id: id, amount: amount, timestamp: timestamp, note: note);

  /// Create model from domain entity
  factory WaterRecordModel.fromEntity(WaterRecord entity) {
    return WaterRecordModel(
      id: entity.id,
      amount: entity.amount,
      timestamp: entity.timestamp,
      note: entity.note,
    );
  }

  /// Convert model to domain entity
  WaterRecord toEntity() {
    return WaterRecord(
      id: id,
      amount: amount,
      timestamp: timestamp,
      note: note,
    );
  }

  /// Serialize to Firebase Firestore map
  Map<String, dynamic> toFirebaseMap() {
    return {
      'id': id,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
    };
  }

  /// Deserialize from Firebase Firestore map
  factory WaterRecordModel.fromFirebaseMap(Map<String, dynamic> map) {
    return WaterRecordModel(
      id: map['id'] as String,
      amount: (map['amount'] as num).toInt(),
      timestamp: DateTime.parse(map['timestamp'] as String),
      note: map['note'] as String?,
    );
  }

  /// Deserialize from map (for manual operations)
  factory WaterRecordModel.fromMap(Map<dynamic, dynamic> map) {
    return WaterRecordModel(
      id: map['id'] as String,
      amount: (map['amount'] as num).toInt(),
      timestamp: map['timestamp'] as DateTime,
      note: map['note'] as String?,
    );
  }

  @override
  WaterRecordModel copyWith({
    String? id,
    int? amount,
    DateTime? timestamp,
    String? note,
  }) {
    return WaterRecordModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
    );
  }
}
