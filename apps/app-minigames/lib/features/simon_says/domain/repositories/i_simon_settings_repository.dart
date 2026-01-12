import '../entities/simon_settings.dart';

abstract class ISimonSettingsRepository {
  Future<SimonSettings> getSettings();
  Future<void> saveSettings(SimonSettings settings);
  Future<void> resetSettings();
}
