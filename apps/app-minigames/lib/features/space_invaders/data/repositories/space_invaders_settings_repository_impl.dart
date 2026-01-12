import '../../domain/entities/space_invaders_settings.dart';
import '../../domain/repositories/i_space_invaders_settings_repository.dart';
import '../datasources/local/space_invaders_local_datasource.dart';
import '../models/space_invaders_settings_model.dart';

class SpaceInvadersSettingsRepositoryImpl implements ISpaceInvadersSettingsRepository {
  final SpaceInvadersLocalDatasource _localDatasource;

  SpaceInvadersSettingsRepositoryImpl(this._localDatasource);

  @override
  Future<SpaceInvadersSettings> getSettings() async {
    return _localDatasource.getSettings();
  }

  @override
  Future<void> saveSettings(SpaceInvadersSettings settings) async {
    final model = SpaceInvadersSettingsModel.fromEntity(settings);
    await _localDatasource.saveSettings(model);
  }

  @override
  Future<void> resetSettings() async {
    await _localDatasource.resetSettings();
  }
}
