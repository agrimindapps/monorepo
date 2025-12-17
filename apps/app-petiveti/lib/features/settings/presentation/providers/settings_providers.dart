import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/settings_local_datasource.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/get_settings.dart';
import '../../domain/usecases/reset_settings.dart';
import '../../domain/usecases/update_settings.dart';

part 'settings_providers.g.dart';

// Data source provider
@riverpod
SettingsLocalDataSource settingsLocalDataSource(Ref ref) {
  return SettingsLocalDataSourceImpl();
}

// Repository provider
@riverpod
SettingsRepository settingsRepository(Ref ref) {
  return SettingsRepositoryImpl(ref.watch(settingsLocalDataSourceProvider));
}

// Use case providers
@riverpod
GetSettingsUseCase getSettingsUseCase(Ref ref) {
  return GetSettingsUseCase(ref.watch(settingsRepositoryProvider));
}

@riverpod
UpdateSettingsUseCase updateSettingsUseCase(Ref ref) {
  return UpdateSettingsUseCase(ref.watch(settingsRepositoryProvider));
}

@riverpod
ResetSettingsUseCase resetSettingsUseCase(Ref ref) {
  return ResetSettingsUseCase(ref.watch(settingsRepositoryProvider));
}

// Settings state notifier
@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  FutureOr<AppSettings> build() async {
    final result = await ref.read(getSettingsUseCaseProvider).call();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (settings) => settings,
    );
  }

  Future<void> updateDarkMode(bool value) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(updateSettingsUseCaseProvider).call(
            UpdateSettingsParams(darkMode: value),
          );
      return result.fold(
        (failure) => throw Exception(failure.message),
        (settings) => settings,
      );
    });
  }

  Future<void> updateNotificationsEnabled(bool value) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(updateSettingsUseCaseProvider).call(
            UpdateSettingsParams(notificationsEnabled: value),
          );
      return result.fold(
        (failure) => throw Exception(failure.message),
        (settings) => settings,
      );
    });
  }

  Future<void> updateLanguage(String value) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(updateSettingsUseCaseProvider).call(
            UpdateSettingsParams(language: value),
          );
      return result.fold(
        (failure) => throw Exception(failure.message),
        (settings) => settings,
      );
    });
  }

  Future<void> updateSoundsEnabled(bool value) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(updateSettingsUseCaseProvider).call(
            UpdateSettingsParams(soundsEnabled: value),
          );
      return result.fold(
        (failure) => throw Exception(failure.message),
        (settings) => settings,
      );
    });
  }

  Future<void> updateVibrationEnabled(bool value) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(updateSettingsUseCaseProvider).call(
            UpdateSettingsParams(vibrationEnabled: value),
          );
      return result.fold(
        (failure) => throw Exception(failure.message),
        (settings) => settings,
      );
    });
  }

  Future<void> updateReminderHoursBefore(int value) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(updateSettingsUseCaseProvider).call(
            UpdateSettingsParams(reminderHoursBefore: value),
          );
      return result.fold(
        (failure) => throw Exception(failure.message),
        (settings) => settings,
      );
    });
  }

  Future<void> updateAutoSync(bool value) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(updateSettingsUseCaseProvider).call(
            UpdateSettingsParams(autoSync: value),
          );
      return result.fold(
        (failure) => throw Exception(failure.message),
        (settings) => settings,
      );
    });
  }

  Future<void> resetToDefaults() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(resetSettingsUseCaseProvider).call();
      return result.fold(
        (failure) => throw Exception(failure.message),
        (settings) => settings,
      );
    });
  }
}
