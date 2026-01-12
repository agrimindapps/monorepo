import '../../domain/entities/asteroids_settings.dart';
import '../../domain/repositories/i_asteroids_settings_repository.dart';
import '../datasources/local/asteroids_local_datasource.dart';
import '../models/asteroids_settings_model.dart';

class AsteroidsSettingsRepositoryImpl implements IAsteroidsSettingsRepository {
  final AsteroidsLocalDatasource _datasource;

  AsteroidsSettingsRepositoryImpl(this._datasource);

  @override
  Future<AsteroidsSettings> getSettings() async {
    return await _datasource.getSettings();
  }

  @override
  Future<void> saveSettings(AsteroidsSettings settings) async {
    final model = AsteroidsSettingsModel.fromEntity(settings);
    await _datasource.saveSettings(model);
  }
}
