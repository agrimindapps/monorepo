import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/settings_entity.dart';

part 'settings_state.freezed.dart';

@freezed
sealed class SettingsState with _$SettingsState {
  const factory SettingsState.initial() = _Initial;
  const factory SettingsState.loading() = _Loading;
  const factory SettingsState.loaded(SettingsEntity settings) = _Loaded;
  const factory SettingsState.error(String message) = _Error;
}
