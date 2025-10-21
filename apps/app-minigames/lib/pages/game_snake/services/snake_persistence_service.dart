// Dart imports:
import 'dart:async';
import 'dart:convert';

// Package imports:
import 'package:crypto/crypto.dart';
// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';
import 'package:app_minigames/models/game_statistics.dart';

/// Interface abstrata para serviços de persistência do Snake Game
/// Permite diferentes implementações (SharedPreferences, file, cloud, etc.)
abstract class SnakePersistenceService {
  Future<int> getHighScore();
  Future<void> saveHighScore(int score);
  Future<GameDifficulty> getPreferredDifficulty();
  Future<void> savePreferredDifficulty(GameDifficulty difficulty);
  Future<Map<String, dynamic>> getGameStatistics();
  Future<void> saveGameStatistics(Map<String, dynamic> stats);
  Future<GameStatistics> getDetailedGameStatistics();
  Future<void> saveDetailedGameStatistics(GameStatistics statistics);
  Future<Map<String, dynamic>> getSettings();
  Future<void> saveSettings(Map<String, dynamic> settings);
  Future<void> clearAllData();
}

/// Implementação usando SharedPreferences com validação de integridade
class SharedPreferencesSnakePersistenceService implements SnakePersistenceService {
  static const String _highScoreKey = 'snake_high_score';
  static const String _difficultyKey = 'snake_preferred_difficulty';
  static const String _statisticsKey = 'snake_game_statistics';
  static const String _detailedStatisticsKey = 'snake_detailed_statistics';
  static const String _settingsKey = 'snake_game_settings';
  static const String _integrityPrefix = 'snake_integrity_';
  
  // Cache para evitar múltiplas chamadas ao SharedPreferences
  SharedPreferences? _prefsCache;
  final Map<String, dynamic> _memoryCache = {};
  
  /// Obtém instância do SharedPreferences (com cache)
  Future<SharedPreferences> get _prefs async {
    return _prefsCache ??= await SharedPreferences.getInstance();
  }
  
  /// Calcula hash SHA-256 para verificação de integridade com timestamp
  String _calculateHash(String data) {
    // Adiciona salt único e timestamp para maior segurança
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final saltedData = '$data${_getSalt()}$timestamp';
    final bytes = utf8.encode(saltedData);
    final digest = sha256.convert(bytes);
    return '$digest:$timestamp'; // Inclui timestamp no hash
  }
  
  /// Valida hash considerando timestamp e detecta manipulação temporal
  bool _validateHash(String data, String storedHash) {
    try {
      final parts = storedHash.split(':');
      if (parts.length != 2) return false;
      
      final expectedHash = parts[0];
      final timestampStr = parts[1];
      final timestamp = int.tryParse(timestampStr);
      
      if (timestamp == null) return false;
      
      // Detecta manipulação temporal: timestamps muito antigos ou futuros são suspeitos
      final now = DateTime.now().millisecondsSinceEpoch;
      final age = now - timestamp;
      const maxAge = 365 * 24 * 60 * 60 * 1000; // 1 ano em ms
      const futureThreshold = 60 * 60 * 1000; // 1 hora no futuro
      
      if (age > maxAge || age < -futureThreshold) {
        _logSecurityEvent('Suspicious timestamp detected', 'validation', age);
        return false;
      }
      
      // Reconstrói o hash usando o timestamp original
      final saltedData = '$data${_getSalt()}$timestampStr';
      final bytes = utf8.encode(saltedData);
      final calculatedDigest = sha256.convert(bytes);
      
      return calculatedDigest.toString() == expectedHash;
    } catch (e) {
      return false;
    }
  }
  
  /// Obtém salt consistente para validação
  String _getSalt() => 'snake_game_salt_2024';
  
  /// Salva dados com verificação de integridade
  Future<void> _saveSecureData(String key, String data) async {
    final prefs = await _prefs;
    final hash = _calculateHash(data);
    
    await Future.wait([
      prefs.setString(key, data),
      prefs.setString('$_integrityPrefix$key', hash),
    ]);
    
    // Atualiza cache em memória
    _memoryCache[key] = data;
  }
  
  /// Carrega dados com verificação de integridade
  Future<String?> _loadSecureData(String key) async {
    // Verifica cache em memória primeiro
    if (_memoryCache.containsKey(key)) {
      return _memoryCache[key] as String?;
    }
    
    final prefs = await _prefs;
    final data = prefs.getString(key);
    if (data == null) return null;
    
    // Verifica integridade dos dados
    final storedHash = prefs.getString('$_integrityPrefix$key');
    if (storedHash == null) {
      // Dados sem hash, considera inválido por segurança
      await _removeSecureData(key);
      return null;
    }
    
    if (!_validateHash(data, storedHash)) {
      // Dados corrompidos ou modificados, remove e retorna null
      await _removeSecureData(key);
      _logSecurityEvent('Data integrity violation detected', key, data.length);
      return null;
    }
    
    // Dados válidos, adiciona ao cache
    _memoryCache[key] = data;
    return data;
  }
  
  /// Remove dados com verificação de integridade
  Future<void> _removeSecureData(String key) async {
    final prefs = await _prefs;
    await Future.wait([
      prefs.remove(key),
      prefs.remove('$_integrityPrefix$key'),
    ]);
    
    // Remove do cache
    _memoryCache.remove(key);
  }
  
  @override
  Future<int> getHighScore() async {
    try {
      final data = await _loadSecureData(_highScoreKey);
      if (data == null) return 0;
      
      final score = int.tryParse(data) ?? 0;
      
      // Validação adicional: score não pode ser negativo ou excessivamente alto
      if (score < 0 || score > 999999) {
        await _removeSecureData(_highScoreKey);
        return 0;
      }
      
      return score;
    } catch (e) {
      // Em caso de erro, retorna 0 e limpa dados corrompidos
      await _removeSecureData(_highScoreKey);
      return 0;
    }
  }
  
  @override
  Future<void> saveHighScore(int score) async {
    if (score < 0) return; // Não salva scores inválidos
    
    // Verifica se é realmente um novo high score
    final currentHighScore = await getHighScore();
    if (score <= currentHighScore) return;
    
    await _saveSecureData(_highScoreKey, score.toString());
  }
  
  @override
  Future<GameDifficulty> getPreferredDifficulty() async {
    try {
      final data = await _loadSecureData(_difficultyKey);
      if (data == null) return GameDifficulty.medium; // Padrão
      
      // Busca enum por nome
      for (final difficulty in GameDifficulty.values) {
        if (difficulty.name == data) {
          return difficulty;
        }
      }
      
      // Se não encontrou, retorna padrão e limpa dado inválido
      await _removeSecureData(_difficultyKey);
      return GameDifficulty.medium;
    } catch (e) {
      await _removeSecureData(_difficultyKey);
      return GameDifficulty.medium;
    }
  }
  
  @override
  Future<void> savePreferredDifficulty(GameDifficulty difficulty) async {
    await _saveSecureData(_difficultyKey, difficulty.name);
  }
  
  @override
  Future<Map<String, dynamic>> getGameStatistics() async {
    try {
      final data = await _loadSecureData(_statisticsKey);
      if (data == null) return _getDefaultStatistics();
      
      final Map<String, dynamic> stats = jsonDecode(data);
      
      // Validação básica da estrutura
      if (!_validateStatisticsStructure(stats)) {
        await _removeSecureData(_statisticsKey);
        return _getDefaultStatistics();
      }
      
      return stats;
    } catch (e) {
      await _removeSecureData(_statisticsKey);
      return _getDefaultStatistics();
    }
  }
  
  @override
  Future<void> saveGameStatistics(Map<String, dynamic> stats) async {
    if (!_validateStatisticsStructure(stats)) return;
    
    // Adiciona timestamp da última atualização
    final enrichedStats = Map<String, dynamic>.from(stats);
    enrichedStats['lastUpdated'] = DateTime.now().toIso8601String();
    
    await _saveSecureData(_statisticsKey, jsonEncode(enrichedStats));
  }
  
  @override
  Future<Map<String, dynamic>> getSettings() async {
    try {
      final data = await _loadSecureData(_settingsKey);
      if (data == null) return _getDefaultSettings();
      
      final Map<String, dynamic> settings = jsonDecode(data);
      return settings;
    } catch (e) {
      await _removeSecureData(_settingsKey);
      return _getDefaultSettings();
    }
  }
  
  @override
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _saveSecureData(_settingsKey, jsonEncode(settings));
  }
  
  @override
  Future<void> clearAllData() async {
    await Future.wait([
      _removeSecureData(_highScoreKey),
      _removeSecureData(_difficultyKey),
      _removeSecureData(_statisticsKey),
      _removeSecureData(_settingsKey),
    ]);
    
    // Limpa cache
    _memoryCache.clear();
  }
  
  /// Retorna estatísticas padrão
  Map<String, dynamic> _getDefaultStatistics() {
    return {
      'totalGamesPlayed': 0,
      'totalTimePlayedSeconds': 0,
      'totalFoodEaten': 0,
      'averageScore': 0.0,
      'bestScore': 0,
      'gamesWon': 0, // Caso implemente condição de vitória
      'lastPlayed': null,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
  
  /// Retorna configurações padrão
  Map<String, dynamic> _getDefaultSettings() {
    return {
      'soundEnabled': true,
      'vibrationsEnabled': true,
      'showGrid': true,
      'animationsEnabled': true,
      'preferredTheme': 'system', // light, dark, system
    };
  }
  
  /// Valida estrutura básica das estatísticas
  bool _validateStatisticsStructure(Map<String, dynamic> stats) {
    final requiredKeys = [
      'totalGamesPlayed',
      'totalTimePlayedSeconds', 
      'totalFoodEaten',
      'averageScore',
      'bestScore'
    ];
    
    for (final key in requiredKeys) {
      if (!stats.containsKey(key)) return false;
      
      // Validação de tipos
      if (key == 'averageScore' && stats[key] is! num) return false;
      if (key != 'averageScore' && stats[key] is! int) return false;
      
      // Validação de valores (não podem ser negativos)
      if ((stats[key] as num) < 0) return false;
    }
    
    return true;
  }
  
  /// Incrementa uma estatística específica
  Future<void> incrementStatistic(String key, {int amount = 1}) async {
    final stats = await getGameStatistics();
    if (stats.containsKey(key) && stats[key] is int) {
      stats[key] = (stats[key] as int) + amount;
      await saveGameStatistics(stats);
    }
  }
  
  /// Atualiza tempo total jogado
  Future<void> addPlayTime(Duration duration) async {
    final stats = await getGameStatistics();
    stats['totalTimePlayedSeconds'] = 
        (stats['totalTimePlayedSeconds'] as int) + duration.inSeconds;
    stats['lastPlayed'] = DateTime.now().toIso8601String();
    await saveGameStatistics(stats);
  }
  
  /// Obtém informações de diagnóstico
  Map<String, dynamic> getDiagnosticInfo() {
    return {
      'cacheSize': _memoryCache.length,
      'cachedKeys': _memoryCache.keys.toList(),
      'hasPrefsCache': _prefsCache != null,
      'securityEvents': _securityEvents.length,
      'lastSecurityCheck': _lastSecurityCheck?.toIso8601String(),
    };
  }
  
  // Log de eventos de segurança
  final List<Map<String, dynamic>> _securityEvents = [];
  DateTime? _lastSecurityCheck;
  
  /// Registra eventos de segurança para auditoria
  void _logSecurityEvent(String event, String key, int dataSize) {
    final timestamp = DateTime.now();
    _lastSecurityCheck = timestamp;
    
    final securityEvent = {
      'timestamp': timestamp.toIso8601String(),
      'event': event,
      'key': key,
      'dataSize': dataSize,
      'severity': 'HIGH',
    };
    
    _securityEvents.add(securityEvent);
    
    // Mantém apenas os últimos 50 eventos para não consumir muita memória
    if (_securityEvents.length > 50) {
      _securityEvents.removeAt(0);
    }
    
    // Em um app real, aqui seria enviado para um serviço de analytics/logging
    debugPrint('🔒 SECURITY EVENT: $event - Key: $key - Size: $dataSize bytes');
  }
  
  /// Obtém histórico de eventos de segurança
  List<Map<String, dynamic>> getSecurityEvents() {
    return List.unmodifiable(_securityEvents);
  }
  
  /// Limpa eventos de segurança (para testes ou manutenção)
  void clearSecurityEvents() {
    _securityEvents.clear();
    _lastSecurityCheck = null;
  }

  /// Carrega estatísticas detalhadas do jogo
  @override
  Future<GameStatistics> getDetailedGameStatistics() async {
    try {
      final prefs = await _prefs;
      final data = prefs.getString(_detailedStatisticsKey);
      
      if (data == null) {
        return GameStatistics.empty();
      }

      // Valida integridade dos dados
      final storedHash = prefs.getString('$_integrityPrefix$_detailedStatisticsKey');
      if (storedHash != null && !_validateHash(data, storedHash)) {
        _logSecurityEvent('DATA_TAMPERING', _detailedStatisticsKey, data.length);
        return GameStatistics.empty();
      }

      return GameStatistics.fromJsonString(data);
    } catch (e) {
      _logSecurityEvent('DESERIALIZATION_ERROR', _detailedStatisticsKey, 0);
      return GameStatistics.empty();
    }
  }

  /// Salva estatísticas detalhadas do jogo
  @override
  Future<void> saveDetailedGameStatistics(GameStatistics statistics) async {
    try {
      final prefs = await _prefs;
      final jsonString = statistics.toJsonString();
      
      // Salva os dados
      await prefs.setString(_detailedStatisticsKey, jsonString);
      
      // Salva hash para verificação de integridade
      final hash = _calculateHash(jsonString);
      await prefs.setString('$_integrityPrefix$_detailedStatisticsKey', hash);
      
      // Atualiza cache em memória
      _memoryCache[_detailedStatisticsKey] = statistics;
      
    } catch (e) {
      _logSecurityEvent('SAVE_ERROR', _detailedStatisticsKey, 0);
      rethrow;
    }
  }
}
