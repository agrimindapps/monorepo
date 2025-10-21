// Project imports:
import 'package:app_minigames/constants/enums.dart';

/// Immutable game state model
class GameStateModel {
  final GameState gameState;
  final GameDifficulty difficulty;
  final GameConfig config;
  final int timeSeconds;
  final int flaggedCells;
  final int revealedCells;
  final int remainingMines;
  final bool isInitialized;
  final bool isPaused;
  final bool isFirstClick;

  const GameStateModel({
    required this.gameState,
    required this.difficulty,
    required this.config,
    required this.timeSeconds,
    required this.flaggedCells,
    required this.revealedCells,
    required this.remainingMines,
    required this.isInitialized,
    this.isPaused = false,
    this.isFirstClick = true,
  });

  GameStateModel copyWith({
    GameState? gameState,
    GameDifficulty? difficulty,
    GameConfig? config,
    int? timeSeconds,
    int? flaggedCells,
    int? revealedCells,
    int? remainingMines,
    bool? isInitialized,
    bool? isPaused,
    bool? isFirstClick,
  }) {
    return GameStateModel(
      gameState: gameState ?? this.gameState,
      difficulty: difficulty ?? this.difficulty,
      config: config ?? this.config,
      timeSeconds: timeSeconds ?? this.timeSeconds,
      flaggedCells: flaggedCells ?? this.flaggedCells,
      revealedCells: revealedCells ?? this.revealedCells,
      remainingMines: remainingMines ?? this.remainingMines,
      isInitialized: isInitialized ?? this.isInitialized,
      isPaused: isPaused ?? this.isPaused,
      isFirstClick: isFirstClick ?? this.isFirstClick,
    );
  }

  static const GameStateModel initial = GameStateModel(
    gameState: GameState.ready,
    difficulty: GameDifficulty.beginner,
    config: GameConfig(rows: 9, cols: 9, mines: 10),
    timeSeconds: 0,
    flaggedCells: 0,
    revealedCells: 0,
    remainingMines: 10,
    isInitialized: false,
  );

  bool get isGameActive => gameState == GameState.playing && !isPaused;
  bool get isGameOver => gameState == GameState.won || gameState == GameState.lost;
  bool get canInteract => !isGameOver && !isPaused;

  /// Formats time as MM:SS
  String get formattedTime {
    final minutes = timeSeconds ~/ 60;
    final seconds = timeSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameStateModel &&
        other.gameState == gameState &&
        other.difficulty == difficulty &&
        other.config == config &&
        other.timeSeconds == timeSeconds &&
        other.flaggedCells == flaggedCells &&
        other.revealedCells == revealedCells &&
        other.remainingMines == remainingMines &&
        other.isInitialized == isInitialized &&
        other.isPaused == isPaused &&
        other.isFirstClick == isFirstClick;
  }

  @override
  int get hashCode {
    return Object.hash(
      gameState,
      difficulty,
      config,
      timeSeconds,
      flaggedCells,
      revealedCells,
      remainingMines,
      isInitialized,
      isPaused,
      isFirstClick,
    );
  }

  @override
  String toString() {
    return 'GameStateModel(state: $gameState, difficulty: $difficulty, time: $timeSeconds, flags: $flaggedCells, mines: $remainingMines)';
  }
}
