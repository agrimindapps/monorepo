import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/settings_entity.dart';
import '../../domain/usecases/get_settings_usecase.dart';
import '../../domain/usecases/update_settings_usecase.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../data/datasources/settings_local_datasource.dart';

part 'settings_providers.g.dart';

// DataSource Provider
@riverpod
SettingsLocalDataSource settingsLocalDataSource(Ref ref) {
  return SettingsLocalDataSource();
}

// Repository Provider
@riverpod
SettingsRepositoryImpl settingsRepository(Ref ref) {
  final dataSource = ref.watch(settingsLocalDataSourceProvider);
  return SettingsRepositoryImpl(dataSource);
}

// UseCase Providers
@riverpod
GetSettingsUseCase getSettingsUseCase(Ref ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return GetSettingsUseCase(repository);
}

@riverpod
UpdateSettingsUseCase updateSettingsUseCase(Ref ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return UpdateSettingsUseCase(repository);
}

// Settings State Provider
@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  Future<SettingsEntity> build() async {
    final getSettings = ref.read(getSettingsUseCaseProvider);
    final result = await getSettings();
    
    return result.fold(
      (failure) => SettingsEntity.defaultSettings(),
      (settings) => settings,
    );
  }

  Future<void> updateThemeMode(String themeMode) async {
    final updateSettings = ref.read(updateSettingsUseCaseProvider);
    final currentSettings = await future;
    
    final updatedSettings = currentSettings.copyWith(themeMode: themeMode);
    final result = await updateSettings(updatedSettings);
    
    result.fold(
      (failure) => null,
      (settings) => state = AsyncValue.data(settings),
    );
  }

  Future<void> updateLanguage(String language) async {
    final updateSettings = ref.read(updateSettingsUseCaseProvider);
    final currentSettings = await future;
    
    final updatedSettings = currentSettings.copyWith(language: language);
    final result = await updateSettings(updatedSettings);
    
    result.fold(
      (failure) => null,
      (settings) => state = AsyncValue.data(settings),
    );
  }

  Future<void> toggleNotifications(bool enabled) async {
    final updateSettings = ref.read(updateSettingsUseCaseProvider);
    final currentSettings = await future;
    
    final updatedSettings = currentSettings.copyWith(notificationsEnabled: enabled);
    final result = await updateSettings(updatedSettings);
    
    result.fold(
      (failure) => null,
      (settings) => state = AsyncValue.data(settings),
    );
  }

  Future<void> toggleSoundEffects(bool enabled) async {
    final updateSettings = ref.read(updateSettingsUseCaseProvider);
    final currentSettings = await future;
    
    final updatedSettings = currentSettings.copyWith(soundEffectsEnabled: enabled);
    final result = await updateSettings(updatedSettings);
    
    result.fold(
      (failure) => null,
      (settings) => state = AsyncValue.data(settings),
    );
  }

  Future<void> updateDefaultView(String view) async {
    final updateSettings = ref.read(updateSettingsUseCaseProvider);
    final currentSettings = await future;
    
    final updatedSettings = currentSettings.copyWith(defaultView: view);
    final result = await updateSettings(updatedSettings);
    
    result.fold(
      (failure) => null,
      (settings) => state = AsyncValue.data(settings),
    );
  }

  Future<void> toggleAutoSync(bool enabled) async {
    final updateSettings = ref.read(updateSettingsUseCaseProvider);
    final currentSettings = await future;
    
    final updatedSettings = currentSettings.copyWith(autoSyncEnabled: enabled);
    final result = await updateSettings(updatedSettings);
    
    result.fold(
      (failure) => null,
      (settings) => state = AsyncValue.data(settings),
    );
  }

  Future<void> toggleShowCompletedTasks(bool show) async {
    final updateSettings = ref.read(updateSettingsUseCaseProvider);
    final currentSettings = await future;
    
    final updatedSettings = currentSettings.copyWith(showCompletedTasks: show);
    final result = await updateSettings(updatedSettings);
    
    result.fold(
      (failure) => null,
      (settings) => state = AsyncValue.data(settings),
    );
  }
}
