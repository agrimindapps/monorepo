import '../entities/simon_settings.dart';
import '../repositories/i_simon_settings_repository.dart';

class ManageSettingsUseCase {
  final ISimonSettingsRepository _repository;

  ManageSettingsUseCase(this._repository);

  Future<SimonSettings> getSettings() async {
    return _repository.getSettings();
  }

  Future<void> saveSettings(SimonSettings settings) async {
    await _repository.saveSettings(settings);
  }

  Future<void> resetSettings() async {
    await _repository.resetSettings();
  }
}
