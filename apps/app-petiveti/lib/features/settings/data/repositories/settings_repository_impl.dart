import 'package:core/core.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';
import '../models/settings_model.dart';

/// Implementation of SettingsRepository using local storage
class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._localDataSource);

  final SettingsLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, AppSettings>> getSettings() async {
    final result = await _localDataSource.getSettings();
    return result.map((model) => model.toEntity());
  }

  @override
  Future<Either<Failure, AppSettings>> updateSettings(
    AppSettings settings,
  ) async {
    final model = SettingsModel.fromEntity(settings);
    final result = await _localDataSource.saveSettings(model);
    return result.map((savedModel) => savedModel.toEntity());
  }

  @override
  Future<Either<Failure, AppSettings>> resetSettings() async {
    // Clear existing settings
    final clearResult = await _localDataSource.clearSettings();
    
    return clearResult.fold(
      (failure) => Left(failure),
      (_) async {
        // Return default settings
        final defaultSettings = AppSettings.defaults();
        return updateSettings(defaultSettings);
      },
    );
  }
}
