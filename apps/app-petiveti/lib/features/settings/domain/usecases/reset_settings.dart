import 'package:core/core.dart';

import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

/// Use case for resetting settings to defaults
class ResetSettingsUseCase {
  const ResetSettingsUseCase(this._repository);

  final SettingsRepository _repository;

  Future<Either<Failure, AppSettings>> call() {
    return _repository.resetSettings();
  }
}
