import '../entities/connect_four_settings.dart';

abstract class IConnectFourSettingsRepository {
  Future<ConnectFourSettings> getSettings();
  Future<void> saveSettings(ConnectFourSettings settings);
}
