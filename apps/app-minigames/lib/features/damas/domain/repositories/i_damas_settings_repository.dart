import '../entities/damas_settings.dart';

abstract class IDamasSettingsRepository {
  Future<DamasSettings> getSettings();
  Future<void> saveSettings(DamasSettings settings);
}
