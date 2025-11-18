import 'package:flutter/material.dart';

import '../../domain/constants/vaccine_constants.dart';

/// Configuration object for vaccine reminders
///
/// **SRP**: Encapsulates reminder settings
/// Reduces parameter list complexity in VaccineReminderManagement
class ReminderConfig {
  final bool enableSmartReminders;
  final bool enablePushNotifications;
  final bool enableEmailReminders;
  final bool enableSmsReminders;
  final int daysBeforeReminder;
  final int urgentReminderDays;
  final String reminderFrequency;
  final bool weekendReminders;
  final TimeOfDay preferredTime;

  const ReminderConfig({
    this.enableSmartReminders = VaccineConstants.defaultEnableSmartReminders,
    this.enablePushNotifications =
        VaccineConstants.defaultEnablePushNotifications,
    this.enableEmailReminders = VaccineConstants.defaultEnableEmailReminders,
    this.enableSmsReminders = VaccineConstants.defaultEnableSmsReminders,
    this.daysBeforeReminder = VaccineConstants.defaultDaysBeforeReminder,
    this.urgentReminderDays = VaccineConstants.urgentReminderDays,
    this.reminderFrequency = VaccineConstants.frequencyDaily,
    this.weekendReminders = VaccineConstants.defaultWeekendReminders,
    this.preferredTime = const TimeOfDay(
      hour: VaccineConstants.defaultReminderHour,
      minute: VaccineConstants.defaultReminderMinute,
    ),
  });

  /// Create default configuration
  factory ReminderConfig.defaultConfig() {
    return const ReminderConfig();
  }

  /// Copy with pattern for immutability
  ReminderConfig copyWith({
    bool? enableSmartReminders,
    bool? enablePushNotifications,
    bool? enableEmailReminders,
    bool? enableSmsReminders,
    int? daysBeforeReminder,
    int? urgentReminderDays,
    String? reminderFrequency,
    bool? weekendReminders,
    TimeOfDay? preferredTime,
  }) {
    return ReminderConfig(
      enableSmartReminders: enableSmartReminders ?? this.enableSmartReminders,
      enablePushNotifications:
          enablePushNotifications ?? this.enablePushNotifications,
      enableEmailReminders: enableEmailReminders ?? this.enableEmailReminders,
      enableSmsReminders: enableSmsReminders ?? this.enableSmsReminders,
      daysBeforeReminder: daysBeforeReminder ?? this.daysBeforeReminder,
      urgentReminderDays: urgentReminderDays ?? this.urgentReminderDays,
      reminderFrequency: reminderFrequency ?? this.reminderFrequency,
      weekendReminders: weekendReminders ?? this.weekendReminders,
      preferredTime: preferredTime ?? this.preferredTime,
    );
  }

  /// Convert to map for storage/serialization
  Map<String, dynamic> toMap() {
    return {
      'enableSmartReminders': enableSmartReminders,
      'enablePushNotifications': enablePushNotifications,
      'enableEmailReminders': enableEmailReminders,
      'enableSmsReminders': enableSmsReminders,
      'daysBeforeReminder': daysBeforeReminder,
      'urgentReminderDays': urgentReminderDays,
      'reminderFrequency': reminderFrequency,
      'weekendReminders': weekendReminders,
      'preferredTimeHour': preferredTime.hour,
      'preferredTimeMinute': preferredTime.minute,
    };
  }

  /// Create from map (deserialization)
  factory ReminderConfig.fromMap(Map<String, dynamic> map) {
    return ReminderConfig(
      enableSmartReminders: map['enableSmartReminders'] as bool? ?? true,
      enablePushNotifications: map['enablePushNotifications'] as bool? ?? true,
      enableEmailReminders: map['enableEmailReminders'] as bool? ?? false,
      enableSmsReminders: map['enableSmsReminders'] as bool? ?? false,
      daysBeforeReminder: map['daysBeforeReminder'] as int? ?? 7,
      urgentReminderDays: map['urgentReminderDays'] as int? ?? 3,
      reminderFrequency:
          map['reminderFrequency'] as String? ??
          VaccineConstants.frequencyDaily,
      weekendReminders: map['weekendReminders'] as bool? ?? true,
      preferredTime: TimeOfDay(
        hour: map['preferredTimeHour'] as int? ?? 9,
        minute: map['preferredTimeMinute'] as int? ?? 0,
      ),
    );
  }

  /// Check if any reminder channel is enabled
  bool get hasAnyChannelEnabled {
    return enablePushNotifications ||
        enableEmailReminders ||
        enableSmsReminders;
  }

  /// Get list of enabled channels
  List<String> get enabledChannels {
    final channels = <String>[];
    if (enablePushNotifications) channels.add('Push');
    if (enableEmailReminders) channels.add('Email');
    if (enableSmsReminders) channels.add('SMS');
    return channels;
  }

  @override
  String toString() {
    return 'ReminderConfig(smart: $enableSmartReminders, push: $enablePushNotifications, '
        'days: $daysBeforeReminder, frequency: $reminderFrequency)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ReminderConfig &&
        other.enableSmartReminders == enableSmartReminders &&
        other.enablePushNotifications == enablePushNotifications &&
        other.enableEmailReminders == enableEmailReminders &&
        other.enableSmsReminders == enableSmsReminders &&
        other.daysBeforeReminder == daysBeforeReminder &&
        other.urgentReminderDays == urgentReminderDays &&
        other.reminderFrequency == reminderFrequency &&
        other.weekendReminders == weekendReminders &&
        other.preferredTime == preferredTime;
  }

  @override
  int get hashCode {
    return Object.hash(
      enableSmartReminders,
      enablePushNotifications,
      enableEmailReminders,
      enableSmsReminders,
      daysBeforeReminder,
      urgentReminderDays,
      reminderFrequency,
      weekendReminders,
      preferredTime,
    );
  }
}
