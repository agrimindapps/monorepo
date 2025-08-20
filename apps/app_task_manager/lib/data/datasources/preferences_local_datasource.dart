import '../../core/theme/theme_mode_enum.dart';

abstract class PreferencesLocalDataSource {
  Future<AppThemeMode> getThemeMode();
  Future<void> setThemeMode(AppThemeMode themeMode);
  Future<bool> getFirstLaunch();
  Future<void> setFirstLaunch(bool isFirstLaunch);
}