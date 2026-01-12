import '../../domain/entities/arkanoid_settings.dart';
import '../../domain/repositories/i_arkanoid_settings_repository.dart';
import '../datasources/local/arkanoid_local_datasource.dart';
import '../models/arkanoid_settings_model.dart';

class ArkanoidSettingsRepositoryImpl implements IArkanoidSettingsRepository {
  final ArkanoidLocalDatasource _localDatasource;

  ArkanoidSettingsRepositoryImpl(this._localDatasource);

  @override
  Future<ArkanoidSettings> getSettings() async {
    return _localDatasource.getSettings();
  }

  @override
  Future<void> saveSettings(ArkanoidSettings settings) async {
    final model = ArkanoidSettingsModel.fromEntity(settings);
    await _localDatasource.saveSettings(model);
  }

  @override
  Future<void> resetSettings() async {
    await _localDatasource.resetSettings();
  }
}
