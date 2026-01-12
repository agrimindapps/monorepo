import '../../domain/entities/dino_run_settings.dart';
import '../../domain/repositories/i_dino_run_settings_repository.dart';
import '../datasources/local/dino_run_local_datasource.dart';
import '../models/dino_run_settings_model.dart';

class DinoRunSettingsRepositoryImpl implements IDinoRunSettingsRepository {
  final DinoRunLocalDatasource _datasource;

  DinoRunSettingsRepositoryImpl(this._datasource);

  @override
  Future<DinoRunSettings> getSettings() async {
    return await _datasource.getSettings();
  }

  @override
  Future<void> saveSettings(DinoRunSettings settings) async {
    final model = DinoRunSettingsModel.fromEntity(settings);
    await _datasource.saveSettings(model);
  }
}
