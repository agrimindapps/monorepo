import '../entities/connect_four_settings.dart';
import '../repositories/i_connect_four_settings_repository.dart';

class ManageSettingsUseCase {
  final IConnectFourSettingsRepository repository;

  ManageSettingsUseCase(this.repository);

  Future<ConnectFourSettings> getSettings() async {
    return await repository.getSettings();
  }

  Future<void> saveSettings(ConnectFourSettings settings) async {
    await repository.saveSettings(settings);
  }
}
