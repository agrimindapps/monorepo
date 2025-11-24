
import '../../core/models/user_preferences.dart';
import 'app_settings_repository.dart';
import 'i_user_preferences_repository.dart';


class UserPreferencesRepository implements IUserPreferencesRepository {
  final AppSettingsRepository _appSettingsRepository;

  UserPreferencesRepository(this._appSettingsRepository);

  @override
  Future<UserPreferences> getUserPreferences() async {
    // Por enquanto, usa um userId fixo. Em produção, isso viria do auth
    const userId = 'current_user';

    final appSettings = await _appSettingsRepository.getAppSettings(userId);

    if (appSettings == null) {
      // Se não existe, retorna padrão e cria no banco
      final defaultPrefs = UserPreferences.defaults();
      await saveUserPreferences(defaultPrefs);
      return defaultPrefs;
    }

    return UserPreferences(
      pragasDetectadasEnabled: appSettings.enableNotifications,
      lembretesAplicacaoEnabled: appSettings.enableSync,
    );
  }

  @override
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    const userId = 'current_user';

    final currentSettings = await _appSettingsRepository.getAppSettings(userId);

    if (currentSettings == null) {
      // Cria novas configurações
      await _appSettingsRepository.createDefaultSettings(userId);
      final newSettings = await _appSettingsRepository.updateSettings(
        userId,
        enableNotifications: preferences.pragasDetectadasEnabled,
        enableSync: preferences.lembretesAplicacaoEnabled,
      );
      if (newSettings == null) {
        throw Exception('Falha ao criar configurações do usuário');
      }
    } else {
      // Atualiza configurações existentes
      await _appSettingsRepository.updateSettings(
        userId,
        enableNotifications: preferences.pragasDetectadasEnabled,
        enableSync: preferences.lembretesAplicacaoEnabled,
      );
    }
  }

  @override
  Future<void> updatePreferences({
    bool? pragasDetectadasEnabled,
    bool? lembretesAplicacaoEnabled,
  }) async {
    const userId = 'current_user';

    await _appSettingsRepository.updateSettings(
      userId,
      enableNotifications: pragasDetectadasEnabled,
      enableSync: lembretesAplicacaoEnabled,
    );
  }

  @override
  Future<void> resetToDefaults() async {
    const userId = 'current_user';

    await _appSettingsRepository.updateSettings(
      userId,
      enableNotifications: true,
      enableSync: true,
    );
  }
}
