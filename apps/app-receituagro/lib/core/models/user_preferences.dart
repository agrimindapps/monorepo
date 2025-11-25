import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_preferences.freezed.dart';

/// Modelo de dados para preferências simples do usuário
///
/// Representa apenas as configurações básicas de notificações
/// que são gerenciadas pelo PreferencesNotifier
@freezed
sealed class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    /// Notificações de pragas detectadas habilitadas
    @Default(true) bool pragasDetectadasEnabled,

    /// Lembretes de aplicação habilitados
    @Default(true) bool lembretesAplicacaoEnabled,
  }) = _UserPreferences;

  const UserPreferences._();

  /// Cria instância com valores padrão
  factory UserPreferences.defaults() {
    return const UserPreferences(
      pragasDetectadasEnabled: true,
      lembretesAplicacaoEnabled: true,
    );
  }
}
