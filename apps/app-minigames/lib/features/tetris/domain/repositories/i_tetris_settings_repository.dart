import '../entities/tetris_settings.dart';

/// Interface do repositório de configurações do Tetris
abstract class ITetrisSettingsRepository {
  /// Obtém as configurações atuais
  Future<TetrisSettings> getSettings();
  
  /// Salva as configurações
  Future<void> saveSettings(TetrisSettings settings);
  
  /// Reseta para configurações padrão
  Future<void> resetSettings();
}
