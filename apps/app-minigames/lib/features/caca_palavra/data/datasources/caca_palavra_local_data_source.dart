import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/enums.dart';
import '../models/high_score_model.dart';

/// Local data source for word search game using SharedPreferences
class CacaPalavraLocalDataSource {
  final SharedPreferences prefs;

  static const String _keyHighScore = 'caca_palavra_high_score';
  static const String _keyDifficulty = 'caca_palavra_difficulty';

  CacaPalavraLocalDataSource(this.prefs);

  /// Available words for the game
  static const List<String> availableWords = [
    'AMOR',
    'VIDA',
    'PAZ',
    'FELIZ',
    'SAUDE',
    'CASA',
    'SOL',
    'LUA',
    'TERRA',
    'CEU',
    'MAR',
    'FLOR',
    'ARTE',
    'LIVRO',
    'TEMPO',
    'FOGO',
    'AGUA',
    'VENTO',
    'FRUTA',
    'GATO',
    'CACHORRO',
    'AMIGO',
    'FAMILIA',
    'TRABALHO',
    'ESTUDO',
    'SONHO',
    'CHUVA',
    'ESTRELA',
    'NUVEM',
    'JARDIM',
    'ARVORE',
    'PEIXE',
    'PASSARO',
    'MONTANHA',
    'PRAIA',
    'CINEMA',
    'MUSICA',
    'DANCA',
    'PINTURA',
    'ESPORTE',
  ];

  /// Loads high score from storage
  Future<HighScoreModel> loadHighScore() async {
    try {
      final jsonString = prefs.getString(_keyHighScore);

      if (jsonString == null) {
        return const HighScoreModel.empty();
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return HighScoreModel.fromJson(json);
    } catch (e) {
      throw Exception('Failed to load high score: ${e.toString()}');
    }
  }

  /// Saves high score to storage
  Future<void> saveHighScore(HighScoreModel highScore) async {
    try {
      final jsonString = jsonEncode(highScore.toJson());
      await prefs.setString(_keyHighScore, jsonString);
    } catch (e) {
      throw Exception('Failed to save high score: ${e.toString()}');
    }
  }

  /// Gets list of available words
  Future<List<String>> getAvailableWords() async {
    return List<String>.from(availableWords);
  }

  /// Saves difficulty preference
  Future<void> saveDifficulty(GameDifficulty difficulty) async {
    try {
      await prefs.setString(_keyDifficulty, difficulty.name);
    } catch (e) {
      throw Exception('Failed to save difficulty: ${e.toString()}');
    }
  }

  /// Loads difficulty preference
  Future<GameDifficulty> loadDifficulty() async {
    try {
      final difficultyName = prefs.getString(_keyDifficulty);

      if (difficultyName == null) {
        return GameDifficulty.medium; // Default
      }

      return GameDifficulty.values.firstWhere(
        (d) => d.name == difficultyName,
        orElse: () => GameDifficulty.medium,
      );
    } catch (e) {
      throw Exception('Failed to load difficulty: ${e.toString()}');
    }
  }
}
