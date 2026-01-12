import '../entities/dino_run_settings.dart';

abstract class IDinoRunSettingsRepository {
  Future<DinoRunSettings> getSettings();
  Future<void> saveSettings(DinoRunSettings settings);
}
