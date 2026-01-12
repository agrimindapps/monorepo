import '../entities/dino_run_settings.dart';
import '../repositories/i_dino_run_settings_repository.dart';

class ManageSettingsUseCase {
  final IDinoRunSettingsRepository repository;

  ManageSettingsUseCase(this.repository);

  Future<DinoRunSettings> getSettings() async {
    return await repository.getSettings();
  }

  Future<void> saveSettings(DinoRunSettings settings) async {
    await repository.saveSettings(settings);
  }
}
