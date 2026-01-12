import '../entities/batalha_naval_settings.dart';
import '../repositories/i_batalha_naval_settings_repository.dart';

class ManageSettingsUseCase {
  final IBatalhaNavalSettingsRepository repository;

  ManageSettingsUseCase(this.repository);

  Future<BatalhaNavalSettings> getSettings() {
    return repository.getSettings();
  }

  Future<void> saveSettings(BatalhaNavalSettings settings) {
    return repository.saveSettings(settings);
  }
}
