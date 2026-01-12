import '../../domain/entities/tetris_settings.dart';
import '../../domain/repositories/i_tetris_settings_repository.dart';
import '../datasources/local/tetris_local_datasource.dart';
import '../models/tetris_settings_model.dart';

/// Implementação do repositório de configurações
class TetrisSettingsRepositoryImpl implements ITetrisSettingsRepository {
  final TetrisLocalDatasource _localDatasource;

  TetrisSettingsRepositoryImpl(this._localDatasource);

  @override
  Future<TetrisSettings> getSettings() async {
    final model = await _localDatasource.getSettings();
    return model.toEntity();
  }

  @override
  Future<void> saveSettings(TetrisSettings settings) async {
    final model = TetrisSettingsModel.fromEntity(settings);
    await _localDatasource.saveSettings(model);
  }

  @override
  Future<void> resetSettings() async {
    await _localDatasource.resetSettings();
  }
}
