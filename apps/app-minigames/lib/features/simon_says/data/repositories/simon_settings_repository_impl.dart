import '../../domain/entities/simon_settings.dart';
import '../../domain/repositories/i_simon_settings_repository.dart';
import '../datasources/local/simon_local_datasource.dart';
import '../models/simon_settings_model.dart';

class SimonSettingsRepositoryImpl implements ISimonSettingsRepository {
  final SimonLocalDatasource _localDatasource;

  SimonSettingsRepositoryImpl(this._localDatasource);

  @override
  Future<SimonSettings> getSettings() async {
    return _localDatasource.getSettings();
  }

  @override
  Future<void> saveSettings(SimonSettings settings) async {
    final model = SimonSettingsModel.fromEntity(settings);
    await _localDatasource.saveSettings(model);
  }

  @override
  Future<void> resetSettings() async {
    await _localDatasource.resetSettings();
  }
}
