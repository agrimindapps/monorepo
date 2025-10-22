import 'package:equatable/equatable.dart';
import 'enums.dart';
import 'high_score_entity.dart';
import 'position_entity.dart';
import 'sudoku_grid_entity.dart';

class GameStateEntity extends Equatable {
  final SudokuGridEntity grid;
  final GameDifficulty difficulty;
  final GameStatus status;
  final int moves;
  final int mistakes;
  final Duration elapsedTime;
  final bool notesMode;
  final PositionEntity? selectedCell;
  final HighScoreEntity? highScore;
  final String? errorMessage;

  const GameStateEntity({
    required this.grid,
    required this.difficulty,
    this.status = GameStatus.initial,
    this.moves = 0,
    this.mistakes = 0,
    this.elapsedTime = Duration.zero,
    this.notesMode = false,
    this.selectedCell,
    this.highScore,
    this.errorMessage,
  });

  /// Factory for initial state
  factory GameStateEntity.initial({
    GameDifficulty difficulty = GameDifficulty.medium,
  }) {
    return GameStateEntity(
      grid: SudokuGridEntity.empty(),
      difficulty: difficulty,
      status: GameStatus.initial,
      moves: 0,
      mistakes: 0,
      elapsedTime: Duration.zero,
      notesMode: false,
      selectedCell: null,
      highScore: null,
      errorMessage: null,
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

  /// Format elapsed time as MM:SS
  String get formattedTime {
    final minutes = elapsedTime.inMinutes;
    final seconds = elapsedTime.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Check if can use hint (not in notes mode, has empty cells)
  bool get canUseHint => !notesMode && emptyCells > 0 && canInteract;

  /// Calculate score (time-based, difficulty-adjusted)
  int calculateScore() {
    if (!isGameWon || elapsedTime.inSeconds == 0) return 0;

    final baseScore = 10000;
    final timePenalty = elapsedTime.inSeconds * 2;
    final mistakePenalty = mistakes * 100;
    final difficultyBonus = (difficulty.difficultyMultiplier * 1000).toInt();

    final score = baseScore - timePenalty - mistakePenalty + difficultyBonus;
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
  }) {
    return GameStateEntity(
      grid: grid ?? this.grid,
      difficulty: difficulty ?? this.difficulty,
      status: status ?? this.status,
      moves: moves ?? this.moves,
      mistakes: mistakes ?? this.mistakes,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      notesMode: notesMode ?? this.notesMode,
      selectedCell:
          clearSelectedCell ? null : (selectedCell ?? this.selectedCell),
      highScore: highScore ?? this.highScore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        grid,
        difficulty,
        status,
        moves,
        mistakes,
        elapsedTime,
        notesMode,
        selectedCell,
        highScore,
        errorMessage,
      ];

  @override
  String toString() =>
      'GameState(status: $status, moves: $moves, mistakes: $mistakes, time: $formattedTime, filled: $filledCells/81)';
}
