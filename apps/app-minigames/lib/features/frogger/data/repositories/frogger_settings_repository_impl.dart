import '../../domain/entities/frogger_settings.dart';
import '../../domain/repositories/i_frogger_settings_repository.dart';
import '../datasources/local/frogger_local_datasource.dart';
import '../models/frogger_settings_model.dart';

class FroggerSettingsRepositoryImpl implements IFroggerSettingsRepository {
  final FroggerLocalDatasource _datasource;

  FroggerSettingsRepositoryImpl(this._datasource);

  @override
  Future<FroggerSettings> getSettings() async {
    return await _datasource.getSettings();
  }

  @override
  Future<void> saveSettings(FroggerSettings settings) async {
    final model = FroggerSettingsModel.fromEntity(settings);
    await _datasource.saveSettings(model);
  }
}
