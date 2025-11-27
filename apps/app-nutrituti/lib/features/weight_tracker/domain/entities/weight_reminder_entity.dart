import 'package:equatable/equatable.dart';

/// Weight Reminder settings entity
class WeightReminderEntity extends Equatable {
  final String id;
  final bool isEnabled;
  final String time; // HH:mm format
  final String message;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WeightReminderEntity({
    required this.id,
    this.isEnabled = true,
    this.time = '07:00',
    this.message = 'Hora de se pesar! 📊',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Parse time to DateTime
  DateTime get timeAsDateTime {
    final parts = time.split(':');
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  WeightReminderEntity copyWith({
    String? id,
    bool? isEnabled,
    String? time,
    String? message,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WeightReminderEntity(
      id: id ?? this.id,
      isEnabled: isEnabled ?? this.isEnabled,
      time: time ?? this.time,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory WeightReminderEntity.defaultSettings() {
    final now = DateTime.now();
    return WeightReminderEntity(
      id: 'default_reminder',
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  List<Object?> get props => [
        id,
        isEnabled,
        time,
        message,
        createdAt,
        updatedAt,
      ];
}
