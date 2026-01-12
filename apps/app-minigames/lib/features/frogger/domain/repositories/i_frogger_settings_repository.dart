import '../entities/frogger_settings.dart';

abstract class IFroggerSettingsRepository {
  Future<FroggerSettings> getSettings();
  Future<void> saveSettings(FroggerSettings settings);
}
