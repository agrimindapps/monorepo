import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_entity.freezed.dart';
part 'settings_entity.g.dart';

@freezed
class SettingsEntity with _$SettingsEntity {
  const factory SettingsEntity({
    @Default(true) bool notificationsEnabled,
    @Default(true) bool mealReminders,
    @Default(true) bool waterReminders,
    @Default(true) bool exerciseReminders,
    @Default(true) bool autoSync,
    @Default(false) bool offlineMode,
    @Default('metric') String unitSystem,
    @Default(2000.0) double dailyWaterGoalMl,
    DateTime? lastSyncDate,
  }) = _SettingsEntity;

  factory SettingsEntity.fromJson(Map<String, dynamic> json) =>
      _$SettingsEntityFromJson(json);
}
