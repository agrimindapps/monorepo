import '../entities/reversi_settings.dart';
import '../repositories/i_reversi_settings_repository.dart';

class ManageSettingsUseCase {
  final IReversiSettingsRepository _repository;

  ManageSettingsUseCase(this._repository);

  Future<ReversiSettings> getSettings() async {
    return _repository.getSettings();
  }

  Future<void> saveSettings(ReversiSettings settings) async {
    await _repository.saveSettings(settings);
  }

  Future<void> resetSettings() async {
    await _repository.resetSettings();
  }
}
