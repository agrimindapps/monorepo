import 'package:core/core.dart';

import '../../domain/entities/settings_entity.dart';
import '../../domain/repositories/i_settings_repository.dart';
import '../datasources/settings_local_datasource.dart';
import '../models/settings_model.dart';

/// Implementation of settings repository
///
/// Follows Repository Pattern and handles data layer operations
class SettingsRepositoryImpl implements ISettingsRepository {
  const SettingsRepositoryImpl(this._localDataSource);

  final SettingsLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, SettingsEntity>> getSettings() async {
    try {
      final model = await _localDataSource.getSettings();
      return Right(model.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to load settings: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveSettings(SettingsEntity settings) async {
    try {
      final model = SettingsModel.fromEntity(settings);
      await _localDataSource.saveSettings(model);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to save settings: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> resetToDefaults() async {
    try {
      await _localDataSource.clearSettings();
      final defaults = SettingsEntity.defaults();
      final model = SettingsModel.fromEntity(defaults);
      await _localDataSource.saveSettings(model);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to reset settings: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateSetting(
    String key,
    dynamic value,
  ) async {
    try {
      await _localDataSource.updateSetting(key, value);
      return const Right(unit);
    } catch (e) {
      return Left(
          CacheFailure('Failed to update setting $key: ${e.toString()}'));
    }
  }
}
