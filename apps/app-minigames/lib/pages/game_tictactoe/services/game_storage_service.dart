// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';

class GameStorageService {
  static const String _xWinsKey = 'tictactoe_x_wins';
  static const String _oWinsKey = 'tictactoe_o_wins';
  static const String _drawsKey = 'tictactoe_draws';
  static const String _gameModeKey = 'tictactoe_game_mode';
  static const String _difficultyKey = 'tictactoe_difficulty';
  
  // Salvar estatísticas
  static Future<void> saveStats(int xWins, int oWins, int draws) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_xWinsKey, xWins);
    await prefs.setInt(_oWinsKey, oWins);
    await prefs.setInt(_drawsKey, draws);
  }
  
  // Carregar estatísticas
  static Future<Map<String, int>> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'xWins': prefs.getInt(_xWinsKey) ?? 0,
      'oWins': prefs.getInt(_oWinsKey) ?? 0,
      'draws': prefs.getInt(_drawsKey) ?? 0,
    };
  }
  
  // Salvar configurações
  static Future<void> saveGameSettings(GameMode mode, Difficulty difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_gameModeKey, mode.name);
    await prefs.setString(_difficultyKey, difficulty.name);
  }
  
  // Carregar configurações
  static Future<Map<String, dynamic>> loadGameSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    final modeString = prefs.getString(_gameModeKey);
    final difficultyString = prefs.getString(_difficultyKey);
    
    return {
      'gameMode': modeString != null 
        ? GameMode.values.firstWhere((e) => e.name == modeString, orElse: () => GameMode.vsPlayer)
        : GameMode.vsPlayer,
      'difficulty': difficultyString != null
        ? Difficulty.values.firstWhere((e) => e.name == difficultyString, orElse: () => Difficulty.medium)
        : Difficulty.medium,
    };
  }
  
  // Resetar todas as estatísticas
  static Future<void> resetStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_xWinsKey);
    await prefs.remove(_oWinsKey);
    await prefs.remove(_drawsKey);
  }
}
