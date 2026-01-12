import '../entities/galaga_settings.dart';

abstract class IGalagaSettingsRepository {
  Future<GalagaSettings> getSettings();
  Future<void> saveSettings(GalagaSettings settings);
}
