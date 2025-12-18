import '../../domain/entities/settings_entity.dart';
import '../../domain/repositories/i_settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

/// Implementation of ISettingsRepository
/// Handles data persistence and retrieval
class SettingsRepository implements ISettingsRepository {
  final SettingsLocalDataSource _localDataSource;

  const SettingsRepository(this._localDataSource);

  @override
  Future<SettingsEntity> getSettings() async {
    return await _localDataSource.getSettings();
  }

  @override
  Future<void> saveSettings(SettingsEntity settings) async {
    await _localDataSource.saveSettings(settings);
  }

  @override
  Future<void> resetSettings() async {
    await _localDataSource.clearSettings();
  }

  @override
  Stream<SettingsEntity> watchSettings() {
    return _localDataSource.watchSettings();
  }
}
