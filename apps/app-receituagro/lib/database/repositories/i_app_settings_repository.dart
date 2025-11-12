import '../../core/models/app_settings.dart';

/// Interface para repositório de configurações do app
abstract class IAppSettingsRepository {
  /// Obtém as configurações do app
  Future<AppSettings?> getAppSettings();

  /// Salva as configurações do app
  Future<void> saveAppSettings(AppSettings settings);

  /// Atualiza configurações específicas
  Future<void> updateSettings({
    bool? pragasDetectadasEnabled,
    bool? lembretesAplicacaoEnabled,
  });

  /// Reset para configurações padrão
  Future<void> resetToDefaults();
}
