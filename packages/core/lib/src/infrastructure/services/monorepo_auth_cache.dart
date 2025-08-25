import 'dart:convert';
import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/module_auth_config.dart';
import '../../domain/entities/user_entity.dart';

/// Serviço de cache de autenticação compartilhado entre módulos do monorepo
/// Permite persistir e recuperar informações de usuário por módulo
class MonorepoAuthCache {
  static const String _userPrefix = 'monorepo_auth_';
  static const String _sessionPrefix = 'monorepo_session_';
  static const String _lastModuleKey = 'last_active_module';
  static const String _moduleListKey = 'registered_modules';
  
  late final SharedPreferences _prefs;
  bool _initialized = false;

  /// Inicializa o cache
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
      
      developer.log('MonorepoAuthCache inicializado', name: 'AuthCache');
    } catch (e) {
      developer.log('Erro ao inicializar MonorepoAuthCache: $e', name: 'AuthCache');
      throw Exception('Falha na inicialização do cache de auth: $e');
    }
  }

  /// Verifica se o cache foi inicializado
  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('MonorepoAuthCache não foi inicializado. Chame initialize() primeiro.');
    }
  }

  /// Salva usuário para um módulo específico
  Future<bool> saveUserForModule(UserEntity user, String moduleName) async {
    _ensureInitialized();
    
    try {
      final userKey = '$_userPrefix${moduleName}_user';
      final loginTimeKey = '$_userPrefix${moduleName}_last_login';
      final sessionKey = '$_sessionPrefix$moduleName';
      
      // Salvar dados do usuário
      final userJson = jsonEncode(user.toJson());
      await _prefs.setString(userKey, userJson);
      
      // Salvar timestamp do login
      await _prefs.setString(loginTimeKey, DateTime.now().toIso8601String());
      
      // Criar sessão
      final sessionData = {
        'userId': user.id,
        'moduleName': moduleName,
        'loginTime': DateTime.now().toIso8601String(),
        'lastActivity': DateTime.now().toIso8601String(),
      };
      await _prefs.setString(sessionKey, jsonEncode(sessionData));
      
      // Atualizar último módulo ativo
      await _prefs.setString(_lastModuleKey, moduleName);
      
      // Registrar módulo na lista
      await _addModuleToList(moduleName);
      
      developer.log('Usuário ${user.email} salvo para módulo $moduleName', name: 'AuthCache');
      return true;
      
    } catch (e) {
      developer.log('Erro ao salvar usuário para módulo $moduleName: $e', name: 'AuthCache');
      return false;
    }
  }

  /// Recupera último usuário de um módulo específico
  Future<UserEntity?> getLastUserForModule(String moduleName) async {
    _ensureInitialized();
    
    try {
      final userKey = '$_userPrefix${moduleName}_user';
      final userJson = _prefs.getString(userKey);
      
      if (userJson == null) {
        return null;
      }
      
      final userData = jsonDecode(userJson) as Map<String, dynamic>;
      return UserEntity.fromJson(userData);
      
    } catch (e) {
      developer.log('Erro ao recuperar usuário do módulo $moduleName: $e', name: 'AuthCache');
      return null;
    }
  }

  /// Recupera tempo do último login de um módulo
  Future<DateTime?> getLastLoginTimeForModule(String moduleName) async {
    _ensureInitialized();
    
    try {
      final loginTimeKey = '$_userPrefix${moduleName}_last_login';
      final loginTimeStr = _prefs.getString(loginTimeKey);
      
      if (loginTimeStr == null) return null;
      
      return DateTime.parse(loginTimeStr);
      
    } catch (e) {
      developer.log('Erro ao recuperar tempo de login do módulo $moduleName: $e', name: 'AuthCache');
      return null;
    }
  }

  /// Lista todos os usuários salvos por módulo
  Future<Map<String, UserEntity>> getAllModuleUsers() async {
    _ensureInitialized();
    
    final result = <String, UserEntity>{};
    final modules = await getRegisteredModules();
    
    for (final moduleName in modules) {
      final user = await getLastUserForModule(moduleName);
      if (user != null) {
        result[moduleName] = user;
      }
    }
    
    return result;
  }

  /// Obtém informações de sessão de um módulo
  Future<Map<String, dynamic>?> getModuleSession(String moduleName) async {
    _ensureInitialized();
    
    try {
      final sessionKey = '$_sessionPrefix$moduleName';
      final sessionJson = _prefs.getString(sessionKey);
      
      if (sessionJson == null) return null;
      
      final sessionData = jsonDecode(sessionJson) as Map<String, dynamic>;
      
      // Verificar se sessão não expirou
      final config = ModuleAuthConfig.getConfig(moduleName);
      if (config != null) {
        final lastActivity = DateTime.parse(sessionData['lastActivity'] as String);
        final now = DateTime.now();
        final timeoutMinutes = config.sessionTimeoutMinutes;
        
        if (now.difference(lastActivity).inMinutes > timeoutMinutes) {
          // Sessão expirada
          await clearModuleSession(moduleName);
          return null;
        }
      }
      
      return sessionData;
      
    } catch (e) {
      developer.log('Erro ao recuperar sessão do módulo $moduleName: $e', name: 'AuthCache');
      return null;
    }
  }

  /// Atualiza último tempo de atividade da sessão
  Future<bool> updateLastActivity(String moduleName) async {
    _ensureInitialized();
    
    try {
      final sessionData = await getModuleSession(moduleName);
      if (sessionData == null) return false;
      
      sessionData['lastActivity'] = DateTime.now().toIso8601String();
      
      final sessionKey = '$_sessionPrefix$moduleName';
      await _prefs.setString(sessionKey, jsonEncode(sessionData));
      
      return true;
      
    } catch (e) {
      developer.log('Erro ao atualizar atividade do módulo $moduleName: $e', name: 'AuthCache');
      return false;
    }
  }

  /// Verifica se pode compartilhar sessão entre módulos
  Future<bool> canShareSessionBetween(String fromModule, String toModule) async {
    _ensureInitialized();
    
    // Verificar se ambos módulos têm configuração
    if (!ModuleAuthConfig.canShareSession(fromModule, toModule)) {
      return false;
    }
    
    // Verificar se usuário é o mesmo em ambos módulos
    final fromUser = await getLastUserForModule(fromModule);
    final toUser = await getLastUserForModule(toModule);
    
    if (fromUser == null) return false;
    
    // Se não há usuário no módulo destino, pode compartilhar
    if (toUser == null) return true;
    
    // Se há usuário no destino, deve ser o mesmo
    return fromUser.id == toUser.id;
  }

  /// Compartilha sessão entre módulos compatíveis
  Future<bool> shareSessionBetween(String fromModule, String toModule) async {
    _ensureInitialized();
    
    if (!await canShareSessionBetween(fromModule, toModule)) {
      return false;
    }
    
    try {
      final fromUser = await getLastUserForModule(fromModule);
      if (fromUser == null) return false;
      
      // Copiar usuário para o módulo destino
      await saveUserForModule(fromUser, toModule);
      
      developer.log('Sessão compartilhada de $fromModule para $toModule', name: 'AuthCache');
      return true;
      
    } catch (e) {
      developer.log('Erro ao compartilhar sessão de $fromModule para $toModule: $e', name: 'AuthCache');
      return false;
    }
  }

  /// Limpa dados de um módulo específico
  Future<bool> clearModuleData(String moduleName) async {
    _ensureInitialized();
    
    try {
      final userKey = '$_userPrefix${moduleName}_user';
      final loginTimeKey = '$_userPrefix${moduleName}_last_login';
      final sessionKey = '$_sessionPrefix$moduleName';
      
      await Future.wait([
        _prefs.remove(userKey),
        _prefs.remove(loginTimeKey),
        _prefs.remove(sessionKey),
      ]);
      
      developer.log('Dados do módulo $moduleName limpos', name: 'AuthCache');
      return true;
      
    } catch (e) {
      developer.log('Erro ao limpar dados do módulo $moduleName: $e', name: 'AuthCache');
      return false;
    }
  }

  /// Limpa sessão de um módulo específico
  Future<bool> clearModuleSession(String moduleName) async {
    _ensureInitialized();
    
    try {
      final sessionKey = '$_sessionPrefix$moduleName';
      await _prefs.remove(sessionKey);
      
      developer.log('Sessão do módulo $moduleName limpa', name: 'AuthCache');
      return true;
      
    } catch (e) {
      developer.log('Erro ao limpar sessão do módulo $moduleName: $e', name: 'AuthCache');
      return false;
    }
  }

  /// Limpa todos os dados de todos os módulos
  Future<bool> clearAllData() async {
    _ensureInitialized();
    
    try {
      final keys = _prefs.getKeys();
      final authKeys = keys.where((key) => 
        key.startsWith(_userPrefix) || 
        key.startsWith(_sessionPrefix) ||
        key == _lastModuleKey ||
        key == _moduleListKey
      );
      
      await Future.wait(authKeys.map((key) => _prefs.remove(key)));
      
      developer.log('Todos os dados de auth limpos', name: 'AuthCache');
      return true;
      
    } catch (e) {
      developer.log('Erro ao limpar todos os dados: $e', name: 'AuthCache');
      return false;
    }
  }

  /// Obtém último módulo ativo
  Future<String?> getLastActiveModule() async {
    _ensureInitialized();
    return _prefs.getString(_lastModuleKey);
  }

  /// Lista módulos registrados
  Future<List<String>> getRegisteredModules() async {
    _ensureInitialized();
    
    final modulesJson = _prefs.getString(_moduleListKey);
    if (modulesJson == null) return [];
    
    try {
      final modulesList = jsonDecode(modulesJson) as List<dynamic>;
      return modulesList.cast<String>();
    } catch (e) {
      return [];
    }
  }

  /// Adiciona módulo à lista de registrados
  Future<void> _addModuleToList(String moduleName) async {
    final modules = await getRegisteredModules();
    if (!modules.contains(moduleName)) {
      modules.add(moduleName);
      await _prefs.setString(_moduleListKey, jsonEncode(modules));
    }
  }

  /// Obtém estatísticas de uso por módulo
  Future<Map<String, Map<String, dynamic>>> getUsageStats() async {
    _ensureInitialized();
    
    final stats = <String, Map<String, dynamic>>{};
    final modules = await getRegisteredModules();
    
    for (final moduleName in modules) {
      final user = await getLastUserForModule(moduleName);
      final lastLogin = await getLastLoginTimeForModule(moduleName);
      final session = await getModuleSession(moduleName);
      
      stats[moduleName] = {
        'hasUser': user != null,
        'userEmail': user?.email,
        'lastLogin': lastLogin?.toIso8601String(),
        'hasActiveSession': session != null,
        'sessionLastActivity': session?['lastActivity'],
      };
    }
    
    return stats;
  }

  /// Obtém informações de debug
  Future<Map<String, dynamic>> getDebugInfo() async {
    _ensureInitialized();
    
    final stats = await getUsageStats();
    final lastModule = await getLastActiveModule();
    final registeredModules = await getRegisteredModules();
    
    return {
      'initialized': _initialized,
      'lastActiveModule': lastModule,
      'registeredModules': registeredModules,
      'moduleStats': stats,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}