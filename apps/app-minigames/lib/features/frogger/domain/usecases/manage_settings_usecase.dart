import '../entities/frogger_settings.dart';
import '../repositories/i_frogger_settings_repository.dart';

class ManageSettingsUseCase {
  final IFroggerSettingsRepository repository;

  ManageSettingsUseCase(this.repository);

  Future<FroggerSettings> getSettings() async {
    return await repository.getSettings();
  }

  Future<void> saveSettings(FroggerSettings settings) async {
    await repository.saveSettings(settings);
  }
}
