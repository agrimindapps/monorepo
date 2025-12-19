import 'package:dartz/dartz.dart';
import '../entities/settings_entity.dart';
import '../repositories/settings_repository.dart';

class GetSettingsUseCase {
  final SettingsRepository repository;

  const GetSettingsUseCase(this.repository);

  Future<Either<String, SettingsEntity>> call() {
    return repository.getSettings();
  }
}
