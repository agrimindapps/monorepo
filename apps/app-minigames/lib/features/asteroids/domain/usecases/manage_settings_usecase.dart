import '../entities/asteroids_settings.dart';
import '../repositories/i_asteroids_settings_repository.dart';

class ManageSettingsUseCase {
  final IAsteroidsSettingsRepository repository;

  ManageSettingsUseCase(this.repository);

  Future<AsteroidsSettings> getSettings() async {
    return await repository.getSettings();
  }

  Future<void> saveSettings(AsteroidsSettings settings) async {
    await repository.saveSettings(settings);
  }
}
