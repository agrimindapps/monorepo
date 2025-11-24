import 'package:core/core.dart';



import '../../data/datasources/settings_local_datasource.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/manage_settings.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Core Services
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

// Data Sources
final settingsLocalDataSourceProvider = Provider<SettingsLocalDataSource>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider).asData?.value;
  if (sharedPreferences == null) {
    throw UnimplementedError('SharedPreferences not initialized');
  }
  return SettingsLocalDataSourceImpl(sharedPreferences);
});

// Repository
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final localDataSource = ref.watch(settingsLocalDataSourceProvider);
  final authProvider = ref.watch(authProviderProvider);
  return SettingsRepositoryImpl(localDataSource, authProvider);
});

// Use Cases
final manageSettingsProvider = Provider<ManageSettings>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return ManageSettings(repository);
});

final manageThemeSettingsProvider = Provider<ManageThemeSettings>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return ManageThemeSettings(repository);
});

final manageLanguageSettingsProvider = Provider<ManageLanguageSettings>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return ManageLanguageSettings(repository);
});

final manageNotificationSettingsProvider = Provider<ManageNotificationSettings>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return ManageNotificationSettings(repository);
});

final manageSecuritySettingsProvider = Provider<ManageSecuritySettings>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return ManageSecuritySettings(repository);
});

final manageBackupSettingsProvider = Provider<ManageBackupSettings>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return ManageBackupSettings(repository);
});

final exportDataProvider = Provider<ExportData>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return ExportData(repository);
});

final manageCacheProvider = Provider<ManageCache>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return ManageCache(repository);
});

final getAppInfoProvider = Provider<GetAppInfo>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return GetAppInfo(repository);
});

final validateSettingsProvider = Provider<ValidateSettings>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return ValidateSettings(repository);
});
