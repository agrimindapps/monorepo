import 'package:dartz/dartz.dart';
import '../../domain/entities/settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';
import '../models/settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl(this.localDataSource);

  @override
  Future<Either<String, SettingsEntity>> getSettings() async {
    try {
      final settings = await localDataSource.getSettings();
      return Right(settings);
    } catch (e) {
      return Left('Erro ao carregar configurações: $e');
    }
  }

  @override
  Future<Either<String, SettingsEntity>> updateSettings(
      SettingsEntity settings) async {
    try {
      final model = SettingsModel.fromEntity(settings);
      await localDataSource.saveSettings(model);
      return Right(settings);
    } catch (e) {
      return Left('Erro ao salvar configurações: $e');
    }
  }
}
