import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/settings_local_datasource.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/entities/settings_entity.dart';
import '../../domain/repositories/i_settings_repository.dart';
import '../../domain/usecases/sync_settings_usecase.dart';

part 'settings_providers.g.dart';

/// Provider for SharedPreferences
@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(SharedPreferencesRef ref) async {
  return await SharedPreferences.getInstance();
}

/// Provider for SettingsLocalDataSource
@Riverpod(keepAlive: true)
SettingsLocalDataSource settingsLocalDataSource(
  SettingsLocalDataSourceRef ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider).requireValue;
  return SettingsLocalDataSource(prefs);
}

/// Provider for SettingsRepository
@Riverpod(keepAlive: true)
ISettingsRepository settingsRepository(SettingsRepositoryRef ref) {
  final dataSource = ref.watch(settingsLocalDataSourceProvider);
  return SettingsRepository(dataSource);
}

/// Provider for SyncSettingsUseCase
@riverpod
SyncSettingsUseCase syncSettingsUseCase(SyncSettingsUseCaseRef ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return SyncSettingsUseCase(repository);
}

/// Provider for Settings (AsyncValue)
@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  Future<SettingsEntity> build() async {
    final repository = ref.watch(settingsRepositoryProvider);
    return await repository.getSettings();
  }

  /// Update notifications enabled
  Future<void> setNotificationsEnabled(bool value) async {
    final repository = ref.read(settingsRepositoryProvider);
    final currentSettings = await future;
    final updated = currentSettings.copyWith(notificationsEnabled: value);
    await repository.saveSettings(updated);
    ref.invalidateSelf();
  }

  /// Update meal reminders
  Future<void> setMealReminders(bool value) async {
    final repository = ref.read(settingsRepositoryProvider);
    final currentSettings = await future;
    final updated = currentSettings.copyWith(mealReminders: value);
    await repository.saveSettings(updated);
    ref.invalidateSelf();
  }

  /// Update water reminders
  Future<void> setWaterReminders(bool value) async {
    final repository = ref.read(settingsRepositoryProvider);
    final currentSettings = await future;
    final updated = currentSettings.copyWith(waterReminders: value);
    await repository.saveSettings(updated);
    ref.invalidateSelf();
  }

  /// Update exercise reminders
  Future<void> setExerciseReminders(bool value) async {
    final repository = ref.read(settingsRepositoryProvider);
    final currentSettings = await future;
    final updated = currentSettings.copyWith(exerciseReminders: value);
    await repository.saveSettings(updated);
    ref.invalidateSelf();
  }

  /// Update auto sync
  Future<void> setAutoSync(bool value) async {
    final repository = ref.read(settingsRepositoryProvider);
    final currentSettings = await future;
    final updated = currentSettings.copyWith(autoSync: value);
    await repository.saveSettings(updated);
    ref.invalidateSelf();
  }

  /// Update offline mode
  Future<void> setOfflineMode(bool value) async {
    final repository = ref.read(settingsRepositoryProvider);
    final currentSettings = await future;
    final updated = currentSettings.copyWith(offlineMode: value);
    await repository.saveSettings(updated);
    ref.invalidateSelf();
  }

  /// Update unit system
  Future<void> setUnitSystem(String value) async {
    final repository = ref.read(settingsRepositoryProvider);
    final currentSettings = await future;
    final updated = currentSettings.copyWith(unitSystem: value);
    await repository.saveSettings(updated);
    ref.invalidateSelf();
  }

  /// Update daily water goal
  Future<void> setDailyWaterGoal(double value) async {
    final repository = ref.read(settingsRepositoryProvider);
    final currentSettings = await future;
    final updated = currentSettings.copyWith(dailyWaterGoalMl: value);
    await repository.saveSettings(updated);
    ref.invalidateSelf();
  }

  /// Reset settings to default
  Future<void> resetSettings() async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.resetSettings();
    ref.invalidateSelf();
  }

  /// Sync settings
  Future<void> syncSettings() async {
    final useCase = ref.read(syncSettingsUseCaseProvider);
    await useCase.execute();
    ref.invalidateSelf();
  }
}
