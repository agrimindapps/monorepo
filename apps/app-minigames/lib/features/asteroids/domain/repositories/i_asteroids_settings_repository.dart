import '../entities/asteroids_settings.dart';

abstract class IAsteroidsSettingsRepository {
  Future<AsteroidsSettings> getSettings();
  Future<void> saveSettings(AsteroidsSettings settings);
}
