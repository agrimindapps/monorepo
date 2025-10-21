// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';

/// Service responsável por gerenciar a lógica de pontuação, persistência e estatísticas do jogo 2048
class GameService {
  static const String _highScoreKey = 'game_2048_high_score';
  static const String _gamesPlayedKey = 'game_2048_games_played';
  static const String _gamesWonKey = 'game_2048_games_won';
  static const String _totalScoreKey = 'game_2048_total_score';
  static const String _gameHistoryKey = 'game_2048_game_history';
  static const String _settingsKey = 'game_2048_settings';

  late SharedPreferences _prefs;
  bool _initialized = false;

  /// Inicializa o serviço carregando as preferências
  Future<void> initialize() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  /// Garante que o serviço foi inicializado
  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('GameService must be initialized before use');
    }
  }

  // === PONTUAÇÃO ===

  /// Obtém a pontuação máxima
  int getHighScore() {
    _ensureInitialized();
    return _prefs.getInt(_highScoreKey) ?? 0;
  }

  /// Atualiza a pontuação máxima se necessário
  Future<bool> updateHighScore(int score) async {
    _ensureInitialized();
    final currentHigh = getHighScore();
    if (score > currentHigh) {
      await _prefs.setInt(_highScoreKey, score);
      return true; // Nova pontuação máxima
    }
    return false;
  }

  // === ESTATÍSTICAS ===

  /// Obtém o número total de jogos jogados
  int getGamesPlayed() {
    _ensureInitialized();
    return _prefs.getInt(_gamesPlayedKey) ?? 0;
  }

  /// Obtém o número total de jogos vencidos (atingiu 2048)
  int getGamesWon() {
    _ensureInitialized();
    return _prefs.getInt(_gamesWonKey) ?? 0;
  }

  /// Obtém a pontuação total acumulada
  int getTotalScore() {
    _ensureInitialized();
    return _prefs.getInt(_totalScoreKey) ?? 0;
  }

  /// Calcula a taxa de vitória em porcentagem
  double getWinRate() {
    final played = getGamesPlayed();
    if (played == 0) return 0.0;
    return (getGamesWon() / played) * 100;
  }

  /// Calcula a pontuação média
  double getAverageScore() {
    final played = getGamesPlayed();
    if (played == 0) return 0.0;
    return getTotalScore() / played;
  }

  /// Registra o fim de um jogo
  Future<void> recordGameEnd({
    required int finalScore,
    required bool hasWon,
    required BoardSize boardSize,
    required int moves,
    required Duration gameDuration,
  }) async {
    _ensureInitialized();

    // Atualizar estatísticas
    final gamesPlayed = getGamesPlayed() + 1;
    final gamesWon = getGamesWon() + (hasWon ? 1 : 0);
    final totalScore = getTotalScore() + finalScore;

    await Future.wait([
      _prefs.setInt(_gamesPlayedKey, gamesPlayed),
      _prefs.setInt(_gamesWonKey, gamesWon),
      _prefs.setInt(_totalScoreKey, totalScore),
    ]);

    // Atualizar pontuação máxima
    await updateHighScore(finalScore);

    // Adicionar ao histórico
    await _addToHistory(GameHistoryEntry(
      score: finalScore,
      hasWon: hasWon,
      boardSize: boardSize,
      moves: moves,
      duration: gameDuration,
      timestamp: DateTime.now(),
    ));
  }

  // === HISTÓRICO ===

  /// Obtém o histórico de jogos (últimos 50)
  List<GameHistoryEntry> getGameHistory() {
    _ensureInitialized();
    final historyJson = _prefs.getStringList(_gameHistoryKey) ?? [];
    return historyJson
        .map((json) => GameHistoryEntry.fromJson(jsonDecode(json)))
        .toList();
  }

  /// Adiciona uma entrada ao histórico
  Future<void> _addToHistory(GameHistoryEntry entry) async {
    final history = _prefs.getStringList(_gameHistoryKey) ?? [];
    history.insert(0, jsonEncode(entry.toJson()));

    // Manter apenas os últimos 50 jogos
    if (history.length > 50) {
      history.removeLast();
    }

    await _prefs.setStringList(_gameHistoryKey, history);
  }

  /// Limpa o histórico de jogos
  Future<void> clearHistory() async {
    _ensureInitialized();
    await _prefs.remove(_gameHistoryKey);
  }

  // === CONFIGURAÇÕES ===

  /// Obtém as configurações salvas do jogo
  GameSettings getSettings() {
    _ensureInitialized();
    final settingsJson = _prefs.getString(_settingsKey);
    if (settingsJson != null) {
      return GameSettings.fromJson(jsonDecode(settingsJson));
    }
    return GameSettings.defaults();
  }

  /// Salva as configurações do jogo
  Future<void> saveSettings(GameSettings settings) async {
    _ensureInitialized();
    await _prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  // === RESET ===

  /// Reseta todas as estatísticas e histórico
  Future<void> resetAllData() async {
    _ensureInitialized();
    await Future.wait([
      _prefs.remove(_highScoreKey),
      _prefs.remove(_gamesPlayedKey),
      _prefs.remove(_gamesWonKey),
      _prefs.remove(_totalScoreKey),
      _prefs.remove(_gameHistoryKey),
    ]);
  }
}

/// Representa uma entrada no histórico de jogos
class GameHistoryEntry {
  final int score;
  final bool hasWon;
  final BoardSize boardSize;
  final int moves;
  final Duration duration;
  final DateTime timestamp;

  GameHistoryEntry({
    required this.score,
    required this.hasWon,
    required this.boardSize,
    required this.moves,
    required this.duration,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'score': score,
        'hasWon': hasWon,
        'boardSize': boardSize.name,
        'moves': moves,
        'duration': duration.inMilliseconds,
        'timestamp': timestamp.toIso8601String(),
      };

  factory GameHistoryEntry.fromJson(Map<String, dynamic> json) {
    return GameHistoryEntry(
      score: json['score'],
      hasWon: json['hasWon'],
      boardSize: BoardSize.values.firstWhere(
        (e) => e.name == json['boardSize'],
        orElse: () => BoardSize.size4x4,
      ),
      moves: json['moves'],
      duration: Duration(milliseconds: json['duration']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

/// Configurações do jogo
class GameSettings {
  final TileColorScheme colorScheme;
  final BoardSize defaultBoardSize;
  final bool soundEnabled;
  final bool vibrationEnabled;

  GameSettings({
    required this.colorScheme,
    required this.defaultBoardSize,
    required this.soundEnabled,
    required this.vibrationEnabled,
  });

  factory GameSettings.defaults() => GameSettings(
        colorScheme: TileColorScheme.blue,
        defaultBoardSize: BoardSize.size4x4,
        soundEnabled: true,
        vibrationEnabled: true,
      );

  Map<String, dynamic> toJson() => {
        'colorScheme': colorScheme.name,
        'defaultBoardSize': defaultBoardSize.name,
        'soundEnabled': soundEnabled,
        'vibrationEnabled': vibrationEnabled,
      };

  factory GameSettings.fromJson(Map<String, dynamic> json) {
    return GameSettings(
      colorScheme: TileColorScheme.values.firstWhere(
        (e) => e.name == json['colorScheme'],
        orElse: () => TileColorScheme.blue,
      ),
      defaultBoardSize: BoardSize.values.firstWhere(
        (e) => e.name == json['defaultBoardSize'],
        orElse: () => BoardSize.size4x4,
      ),
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
    );
  }

  GameSettings copyWith({
    TileColorScheme? colorScheme,
    BoardSize? defaultBoardSize,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return GameSettings(
      colorScheme: colorScheme ?? this.colorScheme,
      defaultBoardSize: defaultBoardSize ?? this.defaultBoardSize,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }
}
