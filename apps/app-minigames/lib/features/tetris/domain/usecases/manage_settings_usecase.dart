import '../entities/tetris_settings.dart';
import '../repositories/i_tetris_settings_repository.dart';

/// Use case para gerenciar configurações
class ManageSettingsUseCase {
  final ITetrisSettingsRepository _repository;

  ManageSettingsUseCase(this._repository);

  /// Obtém as configurações atuais
  Future<TetrisSettings> getSettings() async {
    return _repository.getSettings();
  }

  /// Salva as configurações
  Future<void> saveSettings(TetrisSettings settings) async {
    return _repository.saveSettings(settings);
  }

  /// Reseta para configurações padrão
  Future<void> resetSettings() async {
    return _repository.resetSettings();
  }
}
