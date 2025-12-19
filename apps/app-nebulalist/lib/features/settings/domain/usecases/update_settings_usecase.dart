import 'package:dartz/dartz.dart';
import '../entities/settings_entity.dart';
import '../repositories/settings_repository.dart';

class UpdateSettingsUseCase {
  final SettingsRepository repository;

  const UpdateSettingsUseCase(this.repository);

  Future<Either<String, SettingsEntity>> call(SettingsEntity settings) {
    return repository.updateSettings(settings);
  }
}
