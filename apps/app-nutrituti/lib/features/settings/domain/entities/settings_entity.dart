import 'package:equatable/equatable.dart';

/// Settings entity without freezed - manual implementation
class SettingsEntity extends Equatable {
  final bool notificationsEnabled;
  final bool mealReminders;
  final bool waterReminders;
  final bool exerciseReminders;
  final bool autoSync;
  final bool offlineMode;
  final String unitSystem;
  final double dailyWaterGoalMl;
  final DateTime? lastSyncDate;

  const SettingsEntity({
    this.notificationsEnabled = true,
    this.mealReminders = true,
    this.waterReminders = true,
    this.exerciseReminders = true,
    this.autoSync = true,
    this.offlineMode = false,
    this.unitSystem = 'metric',
    this.dailyWaterGoalMl = 2000.0,
    this.lastSyncDate,
  });

  SettingsEntity copyWith({
    bool? notificationsEnabled,
    bool? mealReminders,
    bool? waterReminders,
    bool? exerciseReminders,
    bool? autoSync,
    bool? offlineMode,
    String? unitSystem,
    double? dailyWaterGoalMl,
    DateTime? lastSyncDate,
  }) {
    return SettingsEntity(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      mealReminders: mealReminders ?? this.mealReminders,
      waterReminders: waterReminders ?? this.waterReminders,
      exerciseReminders: exerciseReminders ?? this.exerciseReminders,
      autoSync: autoSync ?? this.autoSync,
      offlineMode: offlineMode ?? this.offlineMode,
      unitSystem: unitSystem ?? this.unitSystem,
      dailyWaterGoalMl: dailyWaterGoalMl ?? this.dailyWaterGoalMl,
      lastSyncDate: lastSyncDate ?? this.lastSyncDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'mealReminders': mealReminders,
      'waterReminders': waterReminders,
      'exerciseReminders': exerciseReminders,
      'autoSync': autoSync,
      'offlineMode': offlineMode,
      'unitSystem': unitSystem,
      'dailyWaterGoalMl': dailyWaterGoalMl,
      'lastSyncDate': lastSyncDate?.toIso8601String(),
    };
  }

  factory SettingsEntity.fromJson(Map<String, dynamic> json) {
    return SettingsEntity(
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      mealReminders: json['mealReminders'] as bool? ?? true,
      waterReminders: json['waterReminders'] as bool? ?? true,
      exerciseReminders: json['exerciseReminders'] as bool? ?? true,
      autoSync: json['autoSync'] as bool? ?? true,
      offlineMode: json['offlineMode'] as bool? ?? false,
      unitSystem: json['unitSystem'] as String? ?? 'metric',
      dailyWaterGoalMl: (json['dailyWaterGoalMl'] as num?)?.toDouble() ?? 2000.0,
      lastSyncDate: json['lastSyncDate'] != null
          ? DateTime.parse(json['lastSyncDate'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        notificationsEnabled,
        mealReminders,
        waterReminders,
        exerciseReminders,
        autoSync,
        offlineMode,
        unitSystem,
        dailyWaterGoalMl,
        lastSyncDate,
      ];
}
