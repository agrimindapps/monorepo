// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:math';

// Package imports:
import 'package:crypto/crypto.dart';
// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço seguro para persistência de dados do jogo Soletrando
/// Implementa criptografia, verificação de integridade e validação
class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();
  
  StorageService._();
  
  late SharedPreferences _prefs;
  bool _initialized = false;
  
  // Chaves para diferentes tipos de dados
  static const String _gameStateKey = 'soletrando_game_state';
  static const String _playerProfilesKey = 'soletrando_player_profiles';
  static const String _statisticsKey = 'soletrando_statistics';
  static const String _settingsKey = 'soletrando_settings';
  static const String _integrityPrefix = 'integrity_';
  
  // Salt para hash de integridade (gerado dinamicamente)
  late String _integritySalt;
  
  /// Inicializa o serviço de storage
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      _prefs = await SharedPreferences.getInstance();
      _integritySalt = await _getOrCreateIntegritySalt();
      _initialized = true;
      
      // Valida integridade dos dados existentes
      await _validateAllStoredData();
      
      debugPrint('StorageService inicializado com sucesso');
    } catch (e) {
      debugPrint('Erro ao inicializar StorageService: $e');
      throw StorageException('Falha na inicialização do storage: $e');
    }
  }
  
  /// Obtém ou cria um salt para verificação de integridade
  Future<String> _getOrCreateIntegritySalt() async {
    const saltKey = 'integrity_salt';
    String? salt = _prefs.getString(saltKey);
    
    if (salt == null) {
      // Gera um novo salt aleatório
      salt = _generateSecureToken(32);
      await _prefs.setString(saltKey, salt);
    }
    
    return salt;
  }
  
  /// Gera um token seguro aleatório
  String _generateSecureToken(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length)))
    );
  }
  
  /// Calcula hash de integridade para um valor
  String _calculateIntegrity(String data) {
    final combined = '$data$_integritySalt';
    final bytes = utf8.encode(combined);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  /// Salva dados com verificação de integridade
  Future<bool> _saveSecureData(String key, String data) async {
    _ensureInitialized();
    
    try {
      // Calcula hash de integridade
      final integrity = _calculateIntegrity(data);
      final integrityKey = '$_integrityPrefix$key';
      
      // Salva dados e hash separadamente
      await _prefs.setString(key, data);
      await _prefs.setString(integrityKey, integrity);
      
      return true;
    } catch (e) {
      debugPrint('Erro ao salvar dados seguros ($key): $e');
      return false;
    }
  }
  
  /// Carrega dados com verificação de integridade
  Future<String?> _loadSecureData(String key) async {
    _ensureInitialized();
    
    try {
      final data = _prefs.getString(key);
      if (data == null) return null;
      
      // Verifica integridade
      final integrityKey = '$_integrityPrefix$key';
      final storedIntegrity = _prefs.getString(integrityKey);
      
      if (storedIntegrity == null) {
        debugPrint('Hash de integridade não encontrado para $key');
        return null;
      }
      
      final calculatedIntegrity = _calculateIntegrity(data);
      if (storedIntegrity != calculatedIntegrity) {
        debugPrint('Falha na verificação de integridade para $key');
        // Remove dados corrompidos
        await _removeSecureData(key);
        return null;
      }
      
      return data;
    } catch (e) {
      debugPrint('Erro ao carregar dados seguros ($key): $e');
      return null;
    }
  }
  
  /// Remove dados com verificação de integridade
  Future<bool> _removeSecureData(String key) async {
    _ensureInitialized();
    
    try {
      final integrityKey = '$_integrityPrefix$key';
      await _prefs.remove(key);
      await _prefs.remove(integrityKey);
      return true;
    } catch (e) {
      debugPrint('Erro ao remover dados seguros ($key): $e');
      return false;
    }
  }
  
  /// Valida integridade de todos os dados armazenados
  Future<void> _validateAllStoredData() async {
    final keys = _prefs.getKeys()
        .where((key) => !key.startsWith(_integrityPrefix) && key != 'integrity_salt')
        .toList();
    
    for (final key in keys) {
      final data = await _loadSecureData(key);
      if (data == null) {
        debugPrint('Dados corrompidos removidos: $key');
      }
    }
  }
  
  /// Salva estado do jogo
  Future<bool> saveGameState(Map<String, dynamic> gameState) async {
    try {
      // Adiciona timestamp e validações
      final enrichedState = {
        ...gameState,
        'savedAt': DateTime.now().toIso8601String(),
        'version': '1.0.0',
        'checksum': _calculateDataChecksum(gameState),
      };
      
      final jsonData = jsonEncode(enrichedState);
      return await _saveSecureData(_gameStateKey, jsonData);
    } catch (e) {
      debugPrint('Erro ao salvar estado do jogo: $e');
      return false;
    }
  }
  
  /// Carrega estado do jogo
  Future<Map<String, dynamic>?> loadGameState() async {
    try {
      final jsonData = await _loadSecureData(_gameStateKey);
      if (jsonData == null) return null;
      
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      
      // Valida versão e checksum
      if (!_validateGameStateData(data)) {
        debugPrint('Estado do jogo inválido, removendo...');
        await _removeSecureData(_gameStateKey);
        return null;
      }
      
      return data;
    } catch (e) {
      debugPrint('Erro ao carregar estado do jogo: $e');
      return null;
    }
  }
  
  /// Salva perfil de jogador
  Future<bool> savePlayerProfile(String profileId, Map<String, dynamic> profile) async {
    try {
      final profiles = await loadPlayerProfiles();
      profiles[profileId] = {
        ...profile,
        'lastModified': DateTime.now().toIso8601String(),
        'profileId': profileId,
      };
      
      final jsonData = jsonEncode(profiles);
      return await _saveSecureData(_playerProfilesKey, jsonData);
    } catch (e) {
      debugPrint('Erro ao salvar perfil do jogador: $e');
      return false;
    }
  }
  
  /// Carrega todos os perfis de jogadores
  Future<Map<String, dynamic>> loadPlayerProfiles() async {
    try {
      final jsonData = await _loadSecureData(_playerProfilesKey);
      if (jsonData == null) return {};
      
      return jsonDecode(jsonData) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Erro ao carregar perfis de jogadores: $e');
      return {};
    }
  }
  
  /// Salva estatísticas do jogo
  Future<bool> saveStatistics(Map<String, dynamic> statistics) async {
    try {
      final enrichedStats = {
        ...statistics,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      
      final jsonData = jsonEncode(enrichedStats);
      return await _saveSecureData(_statisticsKey, jsonData);
    } catch (e) {
      debugPrint('Erro ao salvar estatísticas: $e');
      return false;
    }
  }
  
  /// Carrega estatísticas do jogo
  Future<Map<String, dynamic>?> loadStatistics() async {
    try {
      final jsonData = await _loadSecureData(_statisticsKey);
      if (jsonData == null) return null;
      
      return jsonDecode(jsonData) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Erro ao carregar estatísticas: $e');
      return null;
    }
  }
  
  /// Salva configurações do jogo
  Future<bool> saveSettings(Map<String, dynamic> settings) async {
    try {
      final jsonData = jsonEncode(settings);
      return await _saveSecureData(_settingsKey, jsonData);
    } catch (e) {
      debugPrint('Erro ao salvar configurações: $e');
      return false;
    }
  }
  
  /// Carrega configurações do jogo
  Future<Map<String, dynamic>?> loadSettings() async {
    try {
      final jsonData = await _loadSecureData(_settingsKey);
      if (jsonData == null) return null;
      
      return jsonDecode(jsonData) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Erro ao carregar configurações: $e');
      return null;
    }
  }
  
  /// Calcula checksum dos dados
  String _calculateDataChecksum(Map<String, dynamic> data) {
    final sortedKeys = data.keys.toList()..sort();
    final sortedData = {for (final key in sortedKeys) key: data[key]};
    final jsonStr = jsonEncode(sortedData);
    return sha256.convert(utf8.encode(jsonStr)).toString().substring(0, 16);
  }
  
  /// Valida dados do estado do jogo
  bool _validateGameStateData(Map<String, dynamic> data) {
    try {
      // Verifica campos obrigatórios
      if (!data.containsKey('savedAt') || !data.containsKey('version')) {
        return false;
      }
      
      // Verifica se foi salvo nas últimas 24 horas (evita dados muito antigos)
      final savedAt = DateTime.parse(data['savedAt']);
      final now = DateTime.now();
      if (now.difference(savedAt).inDays > 30) {
        debugPrint('Estado do jogo muito antigo, ignorando');
        return false;
      }
      
      // Valida checksum se presente
      if (data.containsKey('checksum')) {
        final dataWithoutChecksum = Map<String, dynamic>.from(data);
        dataWithoutChecksum.remove('checksum');
        dataWithoutChecksum.remove('savedAt');
        
        final calculatedChecksum = _calculateDataChecksum(dataWithoutChecksum);
        if (calculatedChecksum != data['checksum']) {
          debugPrint('Checksum inválido nos dados do jogo');
          return false;
        }
      }
      
      return true;
    } catch (e) {
      debugPrint('Erro na validação dos dados: $e');
      return false;
    }
  }
  
  /// Exporta dados para backup
  Future<Map<String, dynamic>?> exportData() async {
    try {
      final export = <String, dynamic>{};
      
      final gameState = await loadGameState();
      if (gameState != null) export['gameState'] = gameState;
      
      final profiles = await loadPlayerProfiles();
      if (profiles.isNotEmpty) export['playerProfiles'] = profiles;
      
      final statistics = await loadStatistics();
      if (statistics != null) export['statistics'] = statistics;
      
      final settings = await loadSettings();
      if (settings != null) export['settings'] = settings;
      
      export['exportedAt'] = DateTime.now().toIso8601String();
      export['version'] = '1.0.0';
      
      return export;
    } catch (e) {
      debugPrint('Erro ao exportar dados: $e');
      return null;
    }
  }
  
  /// Importa dados de backup
  Future<bool> importData(Map<String, dynamic> backupData) async {
    try {
      // Valida versão do backup
      if (backupData['version'] != '1.0.0') {
        debugPrint('Versão do backup incompatível');
        return false;
      }
      
      bool success = true;
      
      if (backupData.containsKey('gameState')) {
        success &= await saveGameState(backupData['gameState']);
      }
      
      if (backupData.containsKey('playerProfiles')) {
        final profiles = backupData['playerProfiles'] as Map<String, dynamic>;
        for (final entry in profiles.entries) {
          success &= await savePlayerProfile(entry.key, entry.value);
        }
      }
      
      if (backupData.containsKey('statistics')) {
        success &= await saveStatistics(backupData['statistics']);
      }
      
      if (backupData.containsKey('settings')) {
        success &= await saveSettings(backupData['settings']);
      }
      
      return success;
    } catch (e) {
      debugPrint('Erro ao importar dados: $e');
      return false;
    }
  }
  
  /// Limpa todos os dados
  Future<bool> clearAllData() async {
    try {
      await _removeSecureData(_gameStateKey);
      await _removeSecureData(_playerProfilesKey);
      await _removeSecureData(_statisticsKey);
      await _removeSecureData(_settingsKey);
      return true;
    } catch (e) {
      debugPrint('Erro ao limpar dados: $e');
      return false;
    }
  }
  
  /// Verifica se o serviço foi inicializado
  void _ensureInitialized() {
    if (!_initialized) {
      throw const StorageException('StorageService não foi inicializado. Chame initialize() primeiro.');
    }
  }
  
  /// Obtém informações de diagnóstico
  Map<String, dynamic> getDiagnosticInfo() {
    return {
      'initialized': _initialized,
      'saltGenerated': _integritySalt.isNotEmpty,
      'keysStored': _initialized ? _prefs.getKeys().length : 0,
      'dataKeys': _initialized ? _prefs.getKeys()
          .where((key) => !key.startsWith(_integrityPrefix) && key != 'integrity_salt')
          .toList() : [],
    };
  }
}

/// Exceção personalizada para erros de storage
class StorageException implements Exception {
  final String message;
  
  const StorageException(this.message);
  
  @override
  String toString() => 'StorageException: $message';
}
