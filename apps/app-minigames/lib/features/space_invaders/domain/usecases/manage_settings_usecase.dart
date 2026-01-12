import '../entities/space_invaders_settings.dart';
import '../repositories/i_space_invaders_settings_repository.dart';

class ManageSettingsUseCase {
  final ISpaceInvadersSettingsRepository _repository;

  ManageSettingsUseCase(this._repository);

  Future<SpaceInvadersSettings> getSettings() async {
    return _repository.getSettings();
  }

  Future<void> saveSettings(SpaceInvadersSettings settings) async {
    await _repository.saveSettings(settings);
  }

  Future<void> resetSettings() async {
    await _repository.resetSettings();
  }
}
