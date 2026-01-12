import '../../domain/entities/batalha_naval_settings.dart';
import '../../domain/repositories/i_batalha_naval_settings_repository.dart';
import '../datasources/local/batalha_naval_local_datasource.dart';
import '../models/batalha_naval_settings_model.dart';

class BatalhaNavalSettingsRepositoryImpl
    implements IBatalhaNavalSettingsRepository {
  final BatalhaNavalLocalDatasource localDatasource;

  BatalhaNavalSettingsRepositoryImpl(this.localDatasource);

  @override
  Future<BatalhaNavalSettings> getSettings() async {
    return await localDatasource.getSettings();
  }

  @override
  Future<void> saveSettings(BatalhaNavalSettings settings) async {
    await localDatasource.saveSettings(
      BatalhaNavalSettingsModel.fromEntity(settings),
    );
  }
}
