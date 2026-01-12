import '../entities/arkanoid_settings.dart';

abstract class IArkanoidSettingsRepository {
  Future<ArkanoidSettings> getSettings();
  Future<void> saveSettings(ArkanoidSettings settings);
  Future<void> resetSettings();
}
