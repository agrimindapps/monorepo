import '../entities/batalha_naval_settings.dart';

abstract class IBatalhaNavalSettingsRepository {
  Future<BatalhaNavalSettings> getSettings();
  Future<void> saveSettings(BatalhaNavalSettings settings);
}
