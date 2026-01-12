import '../../domain/entities/damas_settings.dart';
import '../../domain/repositories/i_damas_settings_repository.dart';
import '../datasources/local/damas_local_datasource.dart';
import '../models/damas_settings_model.dart';

class DamasSettingsRepositoryImpl implements IDamasSettingsRepository {
  final DamasLocalDatasource localDatasource;

  DamasSettingsRepositoryImpl(this.localDatasource);

  @override
  Future<DamasSettings> getSettings() async {
    return localDatasource.getSettings();
  }

  @override
  Future<void> saveSettings(DamasSettings settings) async {
    await localDatasource.saveSettings(DamasSettingsModel.fromEntity(settings));
  }
}
