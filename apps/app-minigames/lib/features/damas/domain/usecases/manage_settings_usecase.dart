import '../entities/damas_settings.dart';
import '../repositories/i_damas_settings_repository.dart';

class ManageSettingsUseCase {
  final IDamasSettingsRepository repository;

  ManageSettingsUseCase(this.repository);

  Future<DamasSettings> getSettings() async {
    return repository.getSettings();
  }

  Future<void> saveSettings(DamasSettings settings) async {
    await repository.saveSettings(settings);
  }
}
