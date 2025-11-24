import 'package:core/core.dart' hide Column;

import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

/// Use case for getting current app settings
class GetSettings {
  final SettingsRepository _repository;

  GetSettings(this._repository);

  Future<Either<Failure, AppSettings>> call() async {
    try {
      return await _repository.getSettings();
    } catch (e) {
      return Left(CacheFailure('Failed to get settings: ${e.toString()}'));
    }
  }
}
