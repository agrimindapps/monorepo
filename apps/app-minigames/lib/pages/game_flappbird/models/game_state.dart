// Project imports:
import 'package:app_minigames/constants/enums.dart';

class GameStateModel {
  final GameState gameState;
  final GameDifficulty difficulty;
  final int score;
  final int highScore;
  final bool isInitialized;
  final bool isPaused;

  const GameStateModel({
    required this.gameState,
    required this.difficulty,
    required this.score,
    required this.highScore,
    required this.isInitialized,
    this.isPaused = false,
  });

  GameStateModel copyWith({
    GameState? gameState,
    GameDifficulty? difficulty,
    int? score,
    int? highScore,
    bool? isInitialized,
    bool? isPaused,
  }) {
    return GameStateModel(
      gameState: gameState ?? this.gameState,
      difficulty: difficulty ?? this.difficulty,
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      isInitialized: isInitialized ?? this.isInitialized,
      isPaused: isPaused ?? this.isPaused,
    );
  }

  static const GameStateModel initial = GameStateModel(
    gameState: GameState.ready,
    difficulty: GameDifficulty.medium,
    score: 0,
    highScore: 0,
    isInitialized: false,
  );
}
