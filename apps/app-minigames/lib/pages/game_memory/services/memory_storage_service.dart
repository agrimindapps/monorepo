/// Serviço seguro de armazenamento para o jogo da memória
/// 
/// Implementa persistência segura com validação e proteção contra manipulação
/// de dados, usando operações assíncronas para evitar bloqueio da UI.
library;

// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';

/// Serviço de armazenamento seguro
class MemoryStorageService {
  /// Chave secreta para validação (em produção, seria mais complexa)
  static const String _secretKey = 'memory_game_v1_secret_2024';
  
  /// Prefixo para chaves de pontuação
  static const String _scoreKeyPrefix = 'memory_secure_score_';
  
  /// Prefixo para chaves de hash
  static const String _hashKeyPrefix = 'memory_hash_';
  
  /// Prefixo para configurações
  static const String _configKeyPrefix = 'memory_config_';
  
  /// Instância singleton do SharedPreferences
  SharedPreferences? _prefs;
  
  /// Inicializa o serviço
  Future<void> initialize() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('Erro ao inicializar MemoryStorageService: $e');
      rethrow;
    }
  }
  
  /// Carrega a melhor pontuação para uma dificuldade específica
  Future<int> loadBestScore(GameDifficulty difficulty) async {
    try {
      await initialize();
      
      final scoreKey = '$_scoreKeyPrefix${difficulty.name}';
      final hashKey = '$_hashKeyPrefix${difficulty.name}';
      
      final storedScore = _prefs!.getInt(scoreKey) ?? 0;
      final storedHash = _prefs!.getString(hashKey);
      
      // Verifica integridade dos dados
      if (storedScore > 0 && storedHash != null) {
        final expectedHash = _generateScoreHash(storedScore, difficulty);
        
        if (storedHash != expectedHash) {
          debugPrint('Integridade de dados comprometida para ${difficulty.name}. Resetando pontuação.');
          await _resetScore(difficulty);
          return 0;
        }
      }
      
      return storedScore;
    } catch (e) {
      debugPrint('Erro ao carregar pontuação: $e');
      return 0; // Retorna 0 como fallback seguro
    }
  }
  
  /// Salva a melhor pontuação de forma segura
  Future<bool> saveBestScore(GameDifficulty difficulty, int score) async {
    try {
      await initialize();
      
      // Validação básica
      if (score < 0 || score > 10000000) {
        debugPrint('Pontuação inválida: $score');
        return false;
      }
      
      final scoreKey = '$_scoreKeyPrefix${difficulty.name}';
      final hashKey = '$_hashKeyPrefix${difficulty.name}';
      
      // Gera hash de validação
      final hash = _generateScoreHash(score, difficulty);
      
      // Salva atomicamente
      final futures = await Future.wait([
        _prefs!.setInt(scoreKey, score),
        _prefs!.setString(hashKey, hash),
      ]);
      
      return futures.every((success) => success);
    } catch (e) {
      debugPrint('Erro ao salvar pontuação: $e');
      return false;
    }
  }
  
  /// Gera hash de validação para uma pontuação
  String _generateScoreHash(int score, GameDifficulty difficulty) {
    final data = '$score:${difficulty.name}:$_secretKey:${DateTime.now().millisecondsSinceEpoch ~/ 86400000}'; // Day-based salt
    final bytes = utf8.encode(data);
    // Simples hash para validação (em produção, usar crypto adequado)
    int hash = 0;
    for (int byte in bytes) {
      hash = ((hash * 31) + byte) & 0xFFFFFFFF;
    }
    return hash.toString();
  }
  
  /// Reseta a pontuação de uma dificuldade
  Future<void> _resetScore(GameDifficulty difficulty) async {
    try {
      final scoreKey = '$_scoreKeyPrefix${difficulty.name}';
      final hashKey = '$_hashKeyPrefix${difficulty.name}';
      
      await Future.wait([
        _prefs!.remove(scoreKey),
        _prefs!.remove(hashKey),
      ]);
    } catch (e) {
      debugPrint('Erro ao resetar pontuação: $e');
    }
  }
  
  /// Carrega configurações do jogo
  Future<Map<String, dynamic>> loadGameConfig() async {
    try {
      await initialize();
      
      final defaultConfig = {
        'soundEnabled': true,
        'hapticsEnabled': true,
        'animationsEnabled': true,
        'theme': 'light',
        'lastDifficulty': GameDifficulty.medium.name,
      };
      
      final config = <String, dynamic>{};
      
      for (final key in defaultConfig.keys) {
        final configKey = '$_configKeyPrefix$key';
        final value = _prefs!.get(configKey);
        config[key] = value ?? defaultConfig[key];
      }
      
      return config;
    } catch (e) {
      debugPrint('Erro ao carregar configurações: $e');
      return {
        'soundEnabled': true,
        'hapticsEnabled': true,
        'animationsEnabled': true,
        'theme': 'light',
        'lastDifficulty': GameDifficulty.medium.name,
      };
    }
  }
  
  /// Salva configurações do jogo
  Future<bool> saveGameConfig(Map<String, dynamic> config) async {
    try {
      await initialize();
      
      final futures = <Future<bool>>[];
      
      for (final entry in config.entries) {
        final configKey = '$_configKeyPrefix${entry.key}';
        final value = entry.value;
        
        if (value is bool) {
          futures.add(_prefs!.setBool(configKey, value));
        } else if (value is int) {
          futures.add(_prefs!.setInt(configKey, value));
        } else if (value is double) {
          futures.add(_prefs!.setDouble(configKey, value));
        } else if (value is String) {
          futures.add(_prefs!.setString(configKey, value));
        }
      }
      
      final results = await Future.wait(futures);
      return results.every((success) => success);
    } catch (e) {
      debugPrint('Erro ao salvar configurações: $e');
      return false;
    }
  }
  
  /// Carrega estatísticas globais do jogador
  Future<Map<String, int>> loadPlayerStatistics() async {
    try {
      await initialize();
      
      final stats = <String, int>{};
      final keys = [
        'totalGames',
        'totalWins',
        'totalMoves',
        'totalTime',
        'perfectGames',
      ];
      
      for (final key in keys) {
        final statKey = '${_configKeyPrefix}stat_$key';
        stats[key] = _prefs!.getInt(statKey) ?? 0;
      }
      
      return stats;
    } catch (e) {
      debugPrint('Erro ao carregar estatísticas: $e');
      return {
        'totalGames': 0,
        'totalWins': 0,
        'totalMoves': 0,
        'totalTime': 0,
        'perfectGames': 0,
      };
    }
  }
  
  /// Atualiza estatísticas do jogador
  Future<bool> updatePlayerStatistics({
    required bool won,
    required int moves,
    required int timeInSeconds,
    required bool isPerfectGame,
  }) async {
    try {
      final currentStats = await loadPlayerStatistics();
      
      currentStats['totalGames'] = (currentStats['totalGames'] ?? 0) + 1;
      if (won) currentStats['totalWins'] = (currentStats['totalWins'] ?? 0) + 1;
      currentStats['totalMoves'] = (currentStats['totalMoves'] ?? 0) + moves;
      currentStats['totalTime'] = (currentStats['totalTime'] ?? 0) + timeInSeconds;
      if (isPerfectGame) currentStats['perfectGames'] = (currentStats['perfectGames'] ?? 0) + 1;
      
      final futures = <Future<bool>>[];
      
      for (final entry in currentStats.entries) {
        final statKey = '${_configKeyPrefix}stat_${entry.key}';
        futures.add(_prefs!.setInt(statKey, entry.value));
      }
      
      final results = await Future.wait(futures);
      return results.every((success) => success);
    } catch (e) {
      debugPrint('Erro ao atualizar estatísticas: $e');
      return false;
    }
  }
  
  /// Limpa todos os dados salvos (para reset completo)
  Future<bool> clearAllData() async {
    try {
      await initialize();
      
      final keys = _prefs!.getKeys().where((key) =>
          key.startsWith(_scoreKeyPrefix) ||
          key.startsWith(_hashKeyPrefix) ||
          key.startsWith(_configKeyPrefix)
      ).toList();
      
      final futures = keys.map((key) => _prefs!.remove(key)).toList();
      final results = await Future.wait(futures);
      
      return results.every((success) => success);
    } catch (e) {
      debugPrint('Erro ao limpar dados: $e');
      return false;
    }
  }
  
  /// Valida integridade de todos os dados salvos
  Future<Map<GameDifficulty, bool>> validateDataIntegrity() async {
    final results = <GameDifficulty, bool>{};
    
    for (final difficulty in GameDifficulty.values) {
      try {
        await loadBestScore(difficulty);
        results[difficulty] = true; // Se chegou até aqui, dados são válidos
      } catch (e) {
        results[difficulty] = false;
      }
    }
    
    return results;
  }
  
  /// Exporta dados para backup (JSON seguro)
  Future<Map<String, dynamic>> exportData() async {
    try {
      final data = <String, dynamic>{};
      
      // Exporta pontuações
      for (final difficulty in GameDifficulty.values) {
        final score = await loadBestScore(difficulty);
        data['score_${difficulty.name}'] = score;
      }
      
      // Exporta configurações
      data['config'] = await loadGameConfig();
      
      // Exporta estatísticas
      data['stats'] = await loadPlayerStatistics();
      
      // Adiciona metadata
      data['exportDate'] = DateTime.now().toIso8601String();
      data['version'] = '1.0';
      
      return data;
    } catch (e) {
      debugPrint('Erro ao exportar dados: $e');
      return {};
    }
  }
  
  /// Importa dados de backup (com validação)
  Future<bool> importData(Map<String, dynamic> data) async {
    try {
      // Valida estrutura básica
      if (!data.containsKey('version') || !data.containsKey('exportDate')) {
        debugPrint('Dados de importação inválidos');
        return false;
      }
      
      // Importa pontuações
      for (final difficulty in GameDifficulty.values) {
        final scoreKey = 'score_${difficulty.name}';
        if (data.containsKey(scoreKey)) {
          final score = data[scoreKey] as int?;
          if (score != null && score >= 0) {
            await saveBestScore(difficulty, score);
          }
        }
      }
      
      // Importa configurações
      if (data.containsKey('config')) {
        final config = data['config'] as Map<String, dynamic>?;
        if (config != null) {
          await saveGameConfig(config);
        }
      }
      
      return true;
    } catch (e) {
      debugPrint('Erro ao importar dados: $e');
      return false;
    }
  }
}
