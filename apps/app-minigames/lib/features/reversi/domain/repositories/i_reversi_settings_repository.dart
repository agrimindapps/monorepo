import '../entities/reversi_settings.dart';

abstract class IReversiSettingsRepository {
  Future<ReversiSettings> getSettings();
  Future<void> saveSettings(ReversiSettings settings);
  Future<void> resetSettings();
}
