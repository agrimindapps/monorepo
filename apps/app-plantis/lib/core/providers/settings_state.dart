import 'package:freezed_annotation/freezed_annotation.dart';

import '../../features/settings/domain/entities/settings_entity.dart';

part 'settings_state.freezed.dart';

/// Estado imutável das configurações usando freezed
@freezed
class SettingsState with _$SettingsState {
  const SettingsState._();

  const factory SettingsState({
    required SettingsEntity settings,
    @Default(false) bool isLoading,
    @Default(false) bool isInitialized,
    String? errorMessage,
    String? successMessage,
  }) = _SettingsState;

  /// Estado inicial padrão
  factory SettingsState.initial() {
    return SettingsState(settings: SettingsEntity.defaults());
  }

  /// Remove mensagens
  SettingsState clearMessages() {
    return copyWith(
      errorMessage: null,
      successMessage: null,
    );
  }

  /// Define estado de erro
  SettingsState withError(String error) {
    return copyWith(
      errorMessage: error,
      successMessage: null,
    );
  }

  /// Define estado de sucesso
  SettingsState withSuccess(String success) {
    return copyWith(
      successMessage: success,
      errorMessage: null,
    );
  }
}
