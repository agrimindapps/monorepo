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
  
  /// Obtém a versão atual do aplicativo
  @override
  String getCurrentVersion() {
    try {
      // Em ambiente de desenvolvimento, podemos usar uma versão fixa
      // Em produção, isso seria obtido do package_info_plus
      return '1.0.0'; // TODO: Implementar PackageInfo.fromPlatform()
    } catch (e) {
      developer.log('Erro ao obter versão atual: $e', name: 'VersionManagerService');
      return '1.0.0'; // Versão fallback
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
}