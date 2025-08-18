import 'dart:developer' as developer;
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../contracts/i_static_data_repository.dart';

/// Gerenciador de versões para controle de dados estáticos
/// Implementa a interface IVersionManager
class VersionManagerService implements IVersionManager {
  static const String _versionBoxName = 'receituagro_versions';
  static const String _currentVersionKey = 'current_app_version';
  static const String _lastDataVersionKey = 'last_data_version';
  
  /// Obtém a versão atual do aplicativo (versão síncrona para compatibilidade)
  @override
  String getCurrentVersion() {
    try {
      // Retorna versão padrão para compatibilidade com interface
      // Use getCurrentVersionAsync() para obter a versão real
      return '1.0.0+1'; // Versão fallback baseada no pubspec.yaml
    } catch (e) {
      developer.log('Erro ao obter versão atual: $e', name: 'VersionManagerService');
      return '1.0.0+1'; // Versão fallback
    }
  }

  /// Obtém a versão atual do aplicativo usando PackageInfo
  Future<String> getCurrentVersionAsync() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      developer.log('Erro ao obter versão via PackageInfo: $e', name: 'VersionManagerService');
      return getCurrentVersion(); // Fallback para versão síncrona
    }
  }

  /// Verifica se é necessário atualizar os dados
  @override
  bool needsUpdate(String storedVersion, String currentVersion) {
    if (storedVersion.isEmpty) {
      developer.log('Primeira execução - dados precisam ser carregados', name: 'VersionManagerService');
      return true;
    }
    
    final needsUpdate = storedVersion != currentVersion;
    developer.log(
      'Versão armazenada: $storedVersion, Versão atual: $currentVersion, Precisa atualizar: $needsUpdate',
      name: 'VersionManagerService'
    );
    
    return needsUpdate;
  }

  /// Marca os dados como atualizados para uma versão específica
  @override
  Future<void> markAsUpdated(String version, String boxName) async {
    try {
      final versionBox = await _getVersionBox();
      await versionBox.put('${boxName}_version', version);
      await versionBox.put(_currentVersionKey, version);
      await versionBox.put(_lastDataVersionKey, version);
      
      developer.log('Versão $version marcada como atualizada para $boxName', name: 'VersionManagerService');
    } catch (e) {
      developer.log('Erro ao marcar versão como atualizada: $e', name: 'VersionManagerService');
    }
  }

  /// Obtém a versão armazenada para uma box específica
  Future<String> getStoredVersion(String boxName) async {
    try {
      final versionBox = await _getVersionBox();
      return versionBox.get('${boxName}_version', defaultValue: '') ?? '';
    } catch (e) {
      developer.log('Erro ao obter versão armazenada para $boxName: $e', name: 'VersionManagerService');
      return '';
    }
  }

  /// Obtém a última versão de dados processada
  Future<String> getLastDataVersion() async {
    try {
      final versionBox = await _getVersionBox();
      return versionBox.get(_lastDataVersionKey, defaultValue: '') ?? '';
    } catch (e) {
      developer.log('Erro ao obter última versão de dados: $e', name: 'VersionManagerService');
      return '';
    }
  }

  /// Verifica se é necessário recarregar dados para uma box específica
  Future<bool> needsDataReload(String boxName) async {
    final currentVersion = await getCurrentVersionAsync();
    final storedVersion = await getStoredVersion(boxName);
    
    return needsUpdate(storedVersion, currentVersion);
  }

  /// Limpa todas as informações de versão (útil para reset completo)
  Future<void> clearVersionInfo() async {
    try {
      final versionBox = await _getVersionBox();
      await versionBox.clear();
      developer.log('Informações de versão limpas', name: 'VersionManagerService');
    } catch (e) {
      developer.log('Erro ao limpar informações de versão: $e', name: 'VersionManagerService');
    }
  }

  /// Obtém estatísticas de versão para debug
  Future<Map<String, String>> getVersionStats() async {
    try {
      final versionBox = await _getVersionBox();
      final stats = <String, String>{};
      
      // Adiciona todas as chaves da box de versões
      for (final key in versionBox.keys) {
        final value = versionBox.get(key);
        stats[key.toString()] = value?.toString() ?? '';
      }
      
      // Adiciona versão atual
      stats['current_app_version'] = await getCurrentVersionAsync();
      
      return stats;
    } catch (e) {
      developer.log('Erro ao obter estatísticas de versão: $e', name: 'VersionManagerService');
      return {};
    }
  }

  /// Obtém ou abre a box de versões
  Future<Box<String>> _getVersionBox() async {
    try {
      if (Hive.isBoxOpen(_versionBoxName)) {
        return Hive.box<String>(_versionBoxName);
      }
      return await Hive.openBox<String>(_versionBoxName);
    } catch (e) {
      developer.log('Erro ao abrir box de versões: $e', name: 'VersionManagerService');
      rethrow;
    }
  }

  /// Força atualização de dados (útil para desenvolvimento)
  Future<void> forceDataUpdate() async {
    await clearVersionInfo();
    developer.log('Forçada atualização de dados', name: 'VersionManagerService');
  }

  /// Detecta automaticamente se houve mudança de versão desde a última execução
  /// Retorna true se versão mudou ou se é primeira execução
  Future<bool> detectVersionChange() async {
    try {
      final currentVersion = await getCurrentVersionAsync();
      final lastSavedVersion = await getLastSavedAppVersion();
      
      final hasChanged = needsUpdate(lastSavedVersion, currentVersion);
      
      if (hasChanged) {
        developer.log(
          'Mudança de versão detectada! Última: $lastSavedVersion, Atual: $currentVersion',
          name: 'VersionManagerService'
        );
      } else {
        developer.log(
          'Nenhuma mudança de versão detectada. Versão atual: $currentVersion',
          name: 'VersionManagerService'
        );
      }
      
      return hasChanged;
      
    } catch (e) {
      developer.log('Erro ao detectar mudança de versão: $e', name: 'VersionManagerService');
      return true; // Em caso de erro, assume que precisa atualizar
    }
  }

  /// Obtém a última versão da aplicação salva no sistema
  Future<String> getLastSavedAppVersion() async {
    try {
      final versionBox = await _getVersionBox();
      return versionBox.get(_currentVersionKey, defaultValue: '') ?? '';
    } catch (e) {
      developer.log('Erro ao obter última versão salva: $e', name: 'VersionManagerService');
      return '';
    }
  }

  /// Salva a versão atual da aplicação como referência
  Future<void> saveCurrentAppVersion() async {
    try {
      final currentVersion = await getCurrentVersionAsync();
      final versionBox = await _getVersionBox();
      
      await versionBox.put(_currentVersionKey, currentVersion);
      await versionBox.put(_lastDataVersionKey, currentVersion);
      
      developer.log('Versão atual salva: $currentVersion', name: 'VersionManagerService');
      
    } catch (e) {
      developer.log('Erro ao salvar versão atual: $e', name: 'VersionManagerService');
    }
  }

  /// Executa verificação completa de versão e retorna resultado detalhado
  Future<VersionCheckResult> performVersionCheck() async {
    try {
      final currentVersion = await getCurrentVersionAsync();
      final lastSavedVersion = await getLastSavedAppVersion();
      final lastDataVersion = await getLastDataVersion();
      
      final needsDataUpdate = needsUpdate(lastSavedVersion, currentVersion);
      final isFirstRun = lastSavedVersion.isEmpty;
      
      final result = VersionCheckResult(
        currentVersion: currentVersion,
        lastSavedVersion: lastSavedVersion,
        lastDataVersion: lastDataVersion,
        needsUpdate: needsDataUpdate,
        isFirstRun: isFirstRun,
        versionChanged: needsDataUpdate && !isFirstRun,
      );
      
      developer.log(
        'Verificação de versão: ${result.toString()}',
        name: 'VersionManagerService'
      );
      
      return result;
      
    } catch (e) {
      developer.log('Erro durante verificação de versão: $e', name: 'VersionManagerService');
      
      // Retorna resultado de erro que força atualização
      return VersionCheckResult(
        currentVersion: await getCurrentVersionAsync(),
        lastSavedVersion: '',
        lastDataVersion: '',
        needsUpdate: true,
        isFirstRun: true,
        versionChanged: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  /// Executa ações pós-atualização após importação bem-sucedida
  Future<void> completeVersionUpdate() async {
    try {
      await saveCurrentAppVersion();
      
      final stats = await getVersionStats();
      developer.log('Atualização de versão concluída. Stats: $stats', 
        name: 'VersionManagerService');
        
    } catch (e) {
      developer.log('Erro ao completar atualização de versão: $e', 
        name: 'VersionManagerService');
    }
  }

  /// Verifica integridade das informações de versão
  Future<bool> verifyVersionIntegrity() async {
    try {
      final versionBox = await _getVersionBox();
      final currentVersion = await getCurrentVersionAsync();
      
      // Verifica se versões são consistentes
      final lastSaved = versionBox.get(_currentVersionKey, defaultValue: '') ?? '';
      final lastData = versionBox.get(_lastDataVersionKey, defaultValue: '') ?? '';
      
      final isConsistent = lastSaved == lastData || lastSaved.isEmpty;
      
      developer.log(
        'Verificação de integridade: Consistente=$isConsistent, '
        'Salva=$lastSaved, Dados=$lastData, Atual=$currentVersion',
        name: 'VersionManagerService'
      );
      
      return isConsistent;
      
    } catch (e) {
      developer.log('Erro na verificação de integridade: $e', name: 'VersionManagerService');
      return false;
    }
  }
}

/// Resultado detalhado da verificação de versão
class VersionCheckResult {
  final String currentVersion;
  final String lastSavedVersion;
  final String lastDataVersion;
  final bool needsUpdate;
  final bool isFirstRun;
  final bool versionChanged;
  final bool hasError;
  final String? errorMessage;

  VersionCheckResult({
    required this.currentVersion,
    required this.lastSavedVersion,
    required this.lastDataVersion,
    required this.needsUpdate,
    required this.isFirstRun,
    required this.versionChanged,
    this.hasError = false,
    this.errorMessage,
  });

  @override
  String toString() {
    return 'VersionCheck(current: $currentVersion, '
           'lastSaved: $lastSavedVersion, '
           'needsUpdate: $needsUpdate, '
           'isFirstRun: $isFirstRun, '
           'versionChanged: $versionChanged'
           '${hasError ? ', ERROR: $errorMessage' : ''})';
  }
}