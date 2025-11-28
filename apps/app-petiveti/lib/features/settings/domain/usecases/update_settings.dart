import 'package:core/core.dart';

import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

/// Parameters for updating settings
class UpdateSettingsParams {
  const UpdateSettingsParams({
    this.darkMode,
    this.notificationsEnabled,
    this.language,
    this.soundsEnabled,
    this.vibrationEnabled,
    this.reminderHoursBefore,
    this.autoSync,
  });

  final bool? darkMode;
  final bool? notificationsEnabled;
  final String? language;
  final bool? soundsEnabled;
  final bool? vibrationEnabled;
  final int? reminderHoursBefore;
  final bool? autoSync;
}

/// Use case for updating application settings
class UpdateSettingsUseCase {
  const UpdateSettingsUseCase(this._repository);

  final SettingsRepository _repository;

  Future<Either<Failure, AppSettings>> call(UpdateSettingsParams params) async {
    // Validate reminder hours
    if (params.reminderHoursBefore != null &&
        (params.reminderHoursBefore! < 1 || params.reminderHoursBefore! > 168)) {
      return const Left(
        ValidationFailure('Horas de lembrete deve ser entre 1 e 168'),
      );
    }

    // Get current settings
    final currentResult = await _repository.getSettings();
    
    return currentResult.fold(
      (failure) => Left(failure),
      (current) {
        // Apply updates
        final updated = current.copyWith(
          darkMode: params.darkMode,
          notificationsEnabled: params.notificationsEnabled,
          language: params.language,
          soundsEnabled: params.soundsEnabled,
          vibrationEnabled: params.vibrationEnabled,
          reminderHoursBefore: params.reminderHoursBefore,
          autoSync: params.autoSync,
        );
        
        return _repository.updateSettings(updated);
      },
    );
  }
}
