import '../entities/space_invaders_settings.dart';

abstract class ISpaceInvadersSettingsRepository {
  Future<SpaceInvadersSettings> getSettings();
  Future<void> saveSettings(SpaceInvadersSettings settings);
  Future<void> resetSettings();
}
