import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/local/settings_local_datasource.dart';
import '../models/app_settings_model.dart';

/// Implementation of SettingsRepository
@LazySingleton(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource _localDataSource;

  SettingsRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, AppSettings>> getSettings() async {
    try {
      final settings = await _localDataSource.getSettings();
      return Right(settings.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to get settings: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateTheme(bool isDarkMode) async {
    try {
      await _localDataSource.updateTheme(isDarkMode);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to update theme: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateTTSSettings({
    double? speed,
    double? pitch,
    double? volume,
    String? language,
  }) async {
    try {
      await _localDataSource.updateTTSSettings(
        speed: speed,
        pitch: pitch,
        volume: volume,
        language: language,
      );
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to update TTS settings: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveSettings(AppSettings settings) async {
    try {
      final model = AppSettingsModel.fromEntity(settings);
      await _localDataSource.saveSettings(model);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to save settings: ${e.toString()}'));
    }
  }
}
