import 'package:equatable/equatable.dart';
import 'enums.dart';
import 'high_score_entity.dart';
import 'move_history.dart';
import 'position_entity.dart';
import 'sudoku_grid_entity.dart';

class GameStateEntity extends Equatable {
  final SudokuGridEntity grid;
  final GameDifficulty difficulty;
  final SudokuGameMode gameMode;
  final GameStatus status;
  final int moves;
  final int mistakes;
  final Duration elapsedTime;
  final bool notesMode;
  final PositionEntity? selectedCell;
  final HighScoreEntity? highScore;
  final String? errorMessage;
  final MoveHistory moveHistory;

  // Game mode specific fields
  final int? remainingTime; // For TimeAttack (countdown in seconds)
  final int livesRemaining; // For Hardcore (starts at 3)
  final int speedRunPuzzlesCompleted; // For SpeedRun (0-5)
  final Duration speedRunTotalTime; // For SpeedRun (total time across all puzzles)

  const GameStateEntity({
    required this.grid,
    required this.difficulty,
    this.gameMode = SudokuGameMode.classic,
    this.status = GameStatus.initial,
    this.moves = 0,
    this.mistakes = 0,
    this.elapsedTime = Duration.zero,
    this.notesMode = false,
    this.selectedCell,
    this.highScore,
    this.errorMessage,
    this.moveHistory = const MoveHistory(),
    this.remainingTime,
    this.livesRemaining = 3,
    this.speedRunPuzzlesCompleted = 0,
    this.speedRunTotalTime = Duration.zero,
  });

  /// Factory for initial state
  factory GameStateEntity.initial({
    GameDifficulty difficulty = GameDifficulty.medium,
    SudokuGameMode gameMode = SudokuGameMode.classic,
  }) {
    final timeLimit = gameMode.getTimeLimit(difficulty);
    return GameStateEntity(
      grid: SudokuGridEntity.empty(),
      difficulty: difficulty,
      gameMode: gameMode,
      status: GameStatus.initial,
      moves: 0,
      mistakes: 0,
      elapsedTime: Duration.zero,
      notesMode: false,
      selectedCell: null,
      highScore: null,
      errorMessage: null,
      moveHistory: const MoveHistory(),
      remainingTime: timeLimit,
      livesRemaining: gameMode.maxMistakes ?? 3,
      speedRunPuzzlesCompleted: 0,
      speedRunTotalTime: Duration.zero,
    );
  }

  /// Computed properties
  bool get isGameWon => status == GameStatus.completed && grid.isSolved;
  bool get isGameLost => status == GameStatus.failed;
  bool get isPlaying => status == GameStatus.playing;
  bool get isPaused => status == GameStatus.paused;
  bool get canInteract => status.canInteract;

  int get filledCells => grid.filledCount;
  int get emptyCells => grid.emptyCount;
  double get progress => filledCells / 81.0;

  /// Undo/Redo availability
  bool get canUndo => moveHistory.canUndo;
  bool get canRedo => moveHistory.canRedo;

  /// Game mode specific computed properties
  bool get isTimeUp =>
      gameMode == SudokuGameMode.timeAttack &&
      remainingTime != null &&
      remainingTime! <= 0;

  bool get isOutOfLives =>
      gameMode == SudokuGameMode.hardcore && livesRemaining <= 0;

  bool get isSpeedRunComplete =>
      gameMode == SudokuGameMode.speedRun &&
      speedRunPuzzlesCompleted >= gameMode.speedRunPuzzleCount;

  /// Format remaining time as MM:SS (for TimeAttack)
  String get formattedRemainingTime {
    if (remainingTime == null) return '--:--';
    final minutes = remainingTime! ~/ 60;
    final seconds = remainingTime! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Format elapsed time as MM:SS
  String get formattedTime {
    final minutes = elapsedTime.inMinutes;
    final seconds = elapsedTime.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Format speed run total time
  String get formattedSpeedRunTime {
    final totalSeconds = speedRunTotalTime.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Check if can use hint (not in notes mode, has empty cells)
  bool get canUseHint => !notesMode && emptyCells > 0 && canInteract;

  /// Calculate score (time-based, difficulty-adjusted, mode-adjusted)
  int calculateScore() {
    if (!isGameWon || elapsedTime.inSeconds == 0) return 0;

    final baseScore = 10000;
    final timePenalty = elapsedTime.inSeconds * 2;
    final mistakePenalty = mistakes * 100;
    final difficultyBonus = (difficulty.difficultyMultiplier * 1000).toInt();
    final modeBonus = (gameMode.modeMultiplier * 500).toInt();

    final score =
        baseScore - timePenalty - mistakePenalty + difficultyBonus + modeBonus;
    return score.clamp(0, 999999);
  }

  /// Check if this is a new high score
  bool get isNewHighScore {
    if (!isGameWon || highScore == null) return false;
    return highScore!.isNewRecord(elapsedTime.inSeconds, mistakes);
  }

  GameStateEntity copyWith({
    SudokuGridEntity? grid,
    GameDifficulty? difficulty,
    SudokuGameMode? gameMode,
    GameStatus? status,
    int? moves,
    int? mistakes,
    Duration? elapsedTime,
    bool? notesMode,
    PositionEntity? selectedCell,
    bool clearSelectedCell = false,
    HighScoreEntity? highScore,
    String? errorMessage,
    bool clearError = false,
    MoveHistory? moveHistory,
    int? remainingTime,
    bool clearRemainingTime = false,
    int? livesRemaining,
    int? speedRunPuzzlesCompleted,
    Duration? speedRunTotalTime,
  }) {
    return GameStateEntity(
      grid: grid ?? this.grid,
      difficulty: difficulty ?? this.difficulty,
      gameMode: gameMode ?? this.gameMode,
      status: status ?? this.status,
      moves: moves ?? this.moves,
      mistakes: mistakes ?? this.mistakes,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      notesMode: notesMode ?? this.notesMode,
      selectedCell:
          clearSelectedCell ? null : (selectedCell ?? this.selectedCell),
      highScore: highScore ?? this.highScore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      moveHistory: moveHistory ?? this.moveHistory,
      remainingTime:
          clearRemainingTime ? null : (remainingTime ?? this.remainingTime),
      livesRemaining: livesRemaining ?? this.livesRemaining,
      speedRunPuzzlesCompleted:
          speedRunPuzzlesCompleted ?? this.speedRunPuzzlesCompleted,
      speedRunTotalTime: speedRunTotalTime ?? this.speedRunTotalTime,
    );
  }

  @override
  List<Object?> get props => [
        grid,
        difficulty,
        gameMode,
        status,
        moves,
        mistakes,
        elapsedTime,
        notesMode,
        selectedCell,
        highScore,
        errorMessage,
        moveHistory,
        remainingTime,
        livesRemaining,
        speedRunPuzzlesCompleted,
        speedRunTotalTime,
      ];

  @override
  String toString() =>
      'GameState(mode: $gameMode, status: $status, moves: $moves, mistakes: $mistakes, time: $formattedTime, filled: $filledCells/81)';
}
