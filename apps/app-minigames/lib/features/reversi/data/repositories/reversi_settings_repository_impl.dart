import '../../domain/entities/reversi_settings.dart';
import '../../domain/repositories/i_reversi_settings_repository.dart';
import '../datasources/local/reversi_local_datasource.dart';
import '../models/reversi_settings_model.dart';

class ReversiSettingsRepositoryImpl implements IReversiSettingsRepository {
  final ReversiLocalDatasource _localDatasource;

  ReversiSettingsRepositoryImpl(this._localDatasource);

  @override
  Future<ReversiSettings> getSettings() async {
    return _localDatasource.getSettings();
  }

  @override
  Future<void> saveSettings(ReversiSettings settings) async {
    final model = ReversiSettingsModel.fromEntity(settings);
    await _localDatasource.saveSettings(model);
  }

  @override
  Future<void> resetSettings() async {
    await _localDatasource.resetSettings();
  }
}
