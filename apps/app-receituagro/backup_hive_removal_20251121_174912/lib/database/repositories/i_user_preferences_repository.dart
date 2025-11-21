import '../../core/models/user_preferences.dart';

/// Interface para repositório de preferências do usuário
abstract class IUserPreferencesRepository {
  /// Obtém as preferências do usuário
  Future<UserPreferences> getUserPreferences();

  /// Salva as preferências do usuário
  Future<void> saveUserPreferences(UserPreferences preferences);

  /// Atualiza configurações específicas
  Future<void> updatePreferences({
    bool? pragasDetectadasEnabled,
    bool? lembretesAplicacaoEnabled,
  });

  /// Reset para configurações padrão
  Future<void> resetToDefaults();
}
