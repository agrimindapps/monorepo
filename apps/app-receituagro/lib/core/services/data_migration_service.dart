import 'package:core/core.dart';
import '../../core/models/user_preferences.dart';
import '../../database/repositories/i_user_preferences_repository.dart';

/// Serviço para migrar dados do Hive para Drift
class DataMigrationService {
  final PreferencesService _hiveService;
  final IUserPreferencesRepository _driftRepository;

  DataMigrationService(this._hiveService, this._driftRepository);

  /// Migra as configurações do usuário do Hive para Drift
  Future<bool> migrateUserPreferences() async {
    try {
      // Inicializa o serviço Hive
      await _hiveService.initialize();

      // Obtém as configurações atuais do Hive
      final pragasEnabled = _hiveService.getPragasDetectadasEnabled();
      final lembretesEnabled = _hiveService.getLembretesAplicacaoEnabled();

      // Cria as preferências para o Drift
      final userPreferences = UserPreferences(
        pragasDetectadasEnabled: pragasEnabled,
        lembretesAplicacaoEnabled: lembretesEnabled,
      );

      // Salva no Drift
      await _driftRepository.saveUserPreferences(userPreferences);

      return true;
    } catch (e) {
      // Log do erro
      print('Erro na migração de preferências: $e');
      return false;
    }
  }

  /// Verifica se a migração já foi realizada
  Future<bool> isMigrationCompleted() async {
    try {
      // Tenta obter as preferências do Drift
      await _driftRepository.getUserPreferences();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Executa migração apenas se necessário
  Future<bool> migrateIfNeeded() async {
    final alreadyMigrated = await isMigrationCompleted();
    if (alreadyMigrated) {
      return true; // Já migrado
    }

    return await migrateUserPreferences();
  }
}
