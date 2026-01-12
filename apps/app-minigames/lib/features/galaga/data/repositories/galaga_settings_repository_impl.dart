import '../../domain/entities/galaga_settings.dart';
import '../../domain/repositories/i_galaga_settings_repository.dart';
import '../datasources/local/galaga_local_datasource.dart';
import '../models/galaga_settings_model.dart';

class GalagaSettingsRepositoryImpl implements IGalagaSettingsRepository {
  final GalagaLocalDatasource _datasource;

  GalagaSettingsRepositoryImpl(this._datasource);

  @override
  Future<GalagaSettings> getSettings() async {
    return await _datasource.getSettings();
  }

  @override
  Future<void> saveSettings(GalagaSettings settings) async {
    final model = GalagaSettingsModel.fromEntity(settings);
    await _datasource.saveSettings(model);
  }
}
