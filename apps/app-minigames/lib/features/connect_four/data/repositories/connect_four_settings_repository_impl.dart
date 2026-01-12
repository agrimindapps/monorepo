import '../../domain/entities/connect_four_settings.dart';
import '../../domain/repositories/i_connect_four_settings_repository.dart';
import '../datasources/local/connect_four_local_datasource.dart';
import '../models/connect_four_settings_model.dart';

class ConnectFourSettingsRepositoryImpl implements IConnectFourSettingsRepository {
  final ConnectFourLocalDatasource _datasource;

  ConnectFourSettingsRepositoryImpl(this._datasource);

  @override
  Future<ConnectFourSettings> getSettings() async {
    return await _datasource.getSettings();
  }

  @override
  Future<void> saveSettings(ConnectFourSettings settings) async {
    final model = ConnectFourSettingsModel.fromEntity(settings);
    await _datasource.saveSettings(model);
  }
}
