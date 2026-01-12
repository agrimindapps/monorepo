import '../entities/galaga_settings.dart';
import '../repositories/i_galaga_settings_repository.dart';

class ManageSettingsUseCase {
  final IGalagaSettingsRepository repository;

  ManageSettingsUseCase(this.repository);

  Future<GalagaSettings> getSettings() async {
    return await repository.getSettings();
  }

  Future<void> saveSettings(GalagaSettings settings) async {
    await repository.saveSettings(settings);
  }
}
