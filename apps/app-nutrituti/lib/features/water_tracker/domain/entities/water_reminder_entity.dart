import 'package:equatable/equatable.dart';

/// Water Reminder settings entity
class WaterReminderEntity extends Equatable {
  final String id;
  final bool isEnabled;
  final int intervalMinutes;
  final String startTime; // HH:mm format
  final String endTime; // HH:mm format
  final bool adaptiveReminders;
  final int adaptiveThresholdMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WaterReminderEntity({
    required this.id,
    this.isEnabled = true,
    this.intervalMinutes = 60,
    this.startTime = '08:00',
    this.endTime = '22:00',
    this.adaptiveReminders = true,
    this.adaptiveThresholdMinutes = 120,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Parse start time to DateTime
  DateTime get startTimeAsDateTime {
    final parts = startTime.split(':');
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  /// Parse end time to DateTime
  DateTime get endTimeAsDateTime {
    final parts = endTime.split(':');
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  /// Check if current time is within reminder window
  bool get isWithinReminderWindow {
    final now = DateTime.now();
    final start = startTimeAsDateTime;
    final end = endTimeAsDateTime;
    return now.isAfter(start) && now.isBefore(end);
  }

  WaterReminderEntity copyWith({
    String? id,
    bool? isEnabled,
    int? intervalMinutes,
    String? startTime,
    String? endTime,
    bool? adaptiveReminders,
    int? adaptiveThresholdMinutes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WaterReminderEntity(
      id: id ?? this.id,
      isEnabled: isEnabled ?? this.isEnabled,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      adaptiveReminders: adaptiveReminders ?? this.adaptiveReminders,
      adaptiveThresholdMinutes:
          adaptiveThresholdMinutes ?? this.adaptiveThresholdMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory WaterReminderEntity.defaultSettings() {
    final now = DateTime.now();
    return WaterReminderEntity(
      id: 'default_reminder',
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  List<Object?> get props => [
        id,
        isEnabled,
        intervalMinutes,
        startTime,
        endTime,
        adaptiveReminders,
        adaptiveThresholdMinutes,
        createdAt,
        updatedAt,
      ];
}
