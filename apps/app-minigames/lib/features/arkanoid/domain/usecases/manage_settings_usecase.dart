import '../entities/arkanoid_settings.dart';
import '../repositories/i_arkanoid_settings_repository.dart';

class ManageSettingsUseCase {
  final IArkanoidSettingsRepository _repository;

  ManageSettingsUseCase(this._repository);

  Future<ArkanoidSettings> getSettings() async {
    return _repository.getSettings();
  }

  Future<void> saveSettings(ArkanoidSettings settings) async {
    await _repository.saveSettings(settings);
  }

  Future<void> resetSettings() async {
    await _repository.resetSettings();
  }
}
