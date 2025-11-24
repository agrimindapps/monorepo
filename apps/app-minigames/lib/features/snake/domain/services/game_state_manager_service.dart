
import '../entities/enums.dart';
import '../entities/game_state.dart';

/// Service responsible for game state management in snake game
///
/// Handles:
/// - Game state transitions (notStarted/running/paused/gameOver)
/// - State validation
/// - Score calculation and management
/// - Game statistics
class GameStateManagerService {
  GameStateManagerService();

  // ============================================================================
  // Game State Transitions
  // ============================================================================

  /// Checks if game can start
  bool canStartGame(SnakeGameStatus currentStatus) {
    return currentStatus == SnakeGameStatus.notStarted;
  }

  /// Starts the game
  GameStateTransitionResult startGame(SnakeGameStatus currentStatus) {
    if (!canStartGame(currentStatus)) {
      return GameStateTransitionResult(
        success: false,
        newStatus: currentStatus,
        errorMessage: 'Cannot start game from current state',
      );
    }

    return GameStateTransitionResult(
      success: true,
      newStatus: SnakeGameStatus.running,
      errorMessage: null,
    );
  }

  /// Checks if game can be paused
  bool canPauseGame(SnakeGameStatus currentStatus) {
    return currentStatus == SnakeGameStatus.running;
  }

  /// Checks if game can be resumed
  bool canResumeGame(SnakeGameStatus currentStatus) {
    return currentStatus == SnakeGameStatus.paused;
  }

  /// Toggles pause state
  GameStateTransitionResult togglePause(SnakeGameStatus currentStatus) {
    if (canPauseGame(currentStatus)) {
      return GameStateTransitionResult(
        success: true,
        newStatus: SnakeGameStatus.paused,
        errorMessage: null,
      );
    } else if (canResumeGame(currentStatus)) {
      return GameStateTransitionResult(
        success: true,
        newStatus: SnakeGameStatus.running,
        errorMessage: null,
      );
    }

    return GameStateTransitionResult(
      success: false,
      newStatus: currentStatus,
      errorMessage: 'Cannot toggle pause in current state',
    );
  }

  /// Ends the game
  GameStateTransitionResult endGame() {
    return GameStateTransitionResult(
      success: true,
      newStatus: SnakeGameStatus.gameOver,
      errorMessage: null,
    );
  }

  // ============================================================================
  // State Validation
  // ============================================================================

  /// Checks if game is running
  bool isRunning(SnakeGameStatus status) {
    return status == SnakeGameStatus.running;
  }

  /// Checks if game is paused
  bool isPaused(SnakeGameStatus status) {
    return status == SnakeGameStatus.paused;
  }

  /// Checks if game is over
  bool isGameOver(SnakeGameStatus status) {
    return status == SnakeGameStatus.gameOver;
  }

  /// Checks if game is not started
  bool isNotStarted(SnakeGameStatus status) {
    return status == SnakeGameStatus.notStarted;
  }

  /// Checks if game is playable (running)
  bool isPlayable(SnakeGameStatus status) {
    return status.isPlayable;
  }

  /// Validates if position update can be performed
  PositionUpdateValidation validatePositionUpdate(SnakeGameStatus status) {
    if (!isRunning(status)) {
      return PositionUpdateValidation(
        canUpdate: false,
        errorMessage: 'Game is not running',
      );
    }

    return const PositionUpdateValidation(
      canUpdate: true,
      errorMessage: null,
    );
  }

  /// Validates if direction can be changed
  DirectionChangeValidation validateDirectionChange(SnakeGameStatus status) {
    // Can change direction if running or paused
    if (isRunning(status) || isPaused(status)) {
      return const DirectionChangeValidation(
        canChange: true,
        errorMessage: null,
      );
    }

    return DirectionChangeValidation(
      canChange: false,
      errorMessage: 'Cannot change direction in current state',
    );
  }

  // ============================================================================
  // Score Management
  // ============================================================================

  /// Calculates new score after eating food
  int calculateScoreIncrease({
    required int currentScore,
    required int foodEaten,
  }) {
    return currentScore + foodEaten;
  }

  /// Updates score when food is eaten
  ScoreUpdateResult updateScore({
    required int currentScore,
    required bool ateFood,
  }) {
    if (!ateFood) {
      return ScoreUpdateResult(
        newScore: currentScore,
        scoreIncrease: 0,
        ateFood: false,
      );
    }

    return ScoreUpdateResult(
      newScore: currentScore + 1,
      scoreIncrease: 1,
      ateFood: true,
    );
  }

  /// Gets score classification based on points
  ScoreClassification getScoreClassification(int score) {
    if (score >= 100) {
      return ScoreClassification.legendary;
    } else if (score >= 50) {
      return ScoreClassification.master;
    } else if (score >= 25) {
      return ScoreClassification.expert;
    } else if (score >= 10) {
      return ScoreClassification.intermediate;
    } else {
      return ScoreClassification.beginner;
    }
  }

  // ============================================================================
  // Game Progress
  // ============================================================================

  /// Calculates grid occupancy percentage
  double calculateGridOccupancy({
    required int snakeLength,
    required int gridSize,
  }) {
    final totalCells = gridSize * gridSize;
    return (snakeLength / totalCells * 100).clamp(0.0, 100.0);
  }

  /// Gets game progress information
  GameProgress getProgress({
    required int snakeLength,
    required int gridSize,
    required int score,
  }) {
    final occupancy = calculateGridOccupancy(
      snakeLength: snakeLength,
      gridSize: gridSize,
    );

    final initialLength = 1;
    final growthFactor = snakeLength / initialLength;

    return GameProgress(
      snakeLength: snakeLength,
      gridOccupancy: occupancy,
      score: score,
      growthFactor: growthFactor,
    );
  }

  // ============================================================================
  // Game Difficulty Adjustment
  // ============================================================================

  /// Checks if should increase difficulty based on score
  bool shouldIncreaseDifficulty({
    required int score,
    required SnakeDifficulty currentDifficulty,
  }) {
    // Auto-increase at certain thresholds
    switch (currentDifficulty) {
      case SnakeDifficulty.easy:
        return score >= 20;
      case SnakeDifficulty.medium:
        return score >= 40;
      case SnakeDifficulty.hard:
        return false; // Already at max
    }
  }

  /// Gets suggested difficulty based on score
  SnakeDifficulty getSuggestedDifficulty(int score) {
    if (score >= 40) {
      return SnakeDifficulty.hard;
    } else if (score >= 20) {
      return SnakeDifficulty.medium;
    } else {
      return SnakeDifficulty.easy;
    }
  }

  // ============================================================================
  // Statistics
  // ============================================================================

  /// Gets comprehensive game statistics
  GameStatistics getStatistics({
    required SnakeGameState gameState,
    required int totalMoves,
  }) {
    final scoreClass = getScoreClassification(gameState.score);
    final progress = getProgress(
      snakeLength: gameState.length,
      gridSize: gameState.gridSize,
      score: gameState.score,
    );

    final efficiency = totalMoves > 0 ? (gameState.score / totalMoves) : 0.0;

    return GameStatistics(
      score: gameState.score,
      snakeLength: gameState.length,
      gridSize: gameState.gridSize,
      difficulty: gameState.difficulty,
      gameStatus: gameState.gameStatus,
      scoreClassification: scoreClass,
      gridOccupancy: progress.gridOccupancy,
      totalMoves: totalMoves,
      efficiency: efficiency,
    );
  }

  // ============================================================================
  // Win Condition
  // ============================================================================

  /// Checks if player won (filled entire grid)
  bool hasWon({
    required int snakeLength,
    required int gridSize,
  }) {
    final totalCells = gridSize * gridSize;
    return snakeLength >= totalCells;
  }

  /// Gets win/loss information
  GameResult getGameResult({
    required SnakeGameState gameState,
    required bool collided,
  }) {
    final won = hasWon(
      snakeLength: gameState.length,
      gridSize: gameState.gridSize,
    );

    if (won) {
      return GameResult(
        won: true,
        lost: false,
        reason: GameEndReason.victory,
        score: gameState.score,
      );
    } else if (collided) {
      return GameResult(
        won: false,
        lost: true,
        reason: GameEndReason.collision,
        score: gameState.score,
      );
    }

    return GameResult(
      won: false,
      lost: false,
      reason: GameEndReason.none,
      score: gameState.score,
    );
  }
}

// ==============================================================================
// Models
// ==============================================================================

/// Game state transition result
class GameStateTransitionResult {
  final bool success;
  final SnakeGameStatus newStatus;
  final String? errorMessage;

  const GameStateTransitionResult({
    required this.success,
    required this.newStatus,
    required this.errorMessage,
  });
}

/// Position update validation
class PositionUpdateValidation {
  final bool canUpdate;
  final String? errorMessage;

  const PositionUpdateValidation({
    required this.canUpdate,
    required this.errorMessage,
  });
}

/// Direction change validation
class DirectionChangeValidation {
  final bool canChange;
  final String? errorMessage;

  const DirectionChangeValidation({
    required this.canChange,
    required this.errorMessage,
  });
}

/// Score update result
class ScoreUpdateResult {
  final int newScore;
  final int scoreIncrease;
  final bool ateFood;

  const ScoreUpdateResult({
    required this.newScore,
    required this.scoreIncrease,
    required this.ateFood,
  });
}

/// Score classification
enum ScoreClassification {
  beginner,
  intermediate,
  expert,
  master,
  legendary;

  String get label {
    switch (this) {
      case ScoreClassification.beginner:
        return 'Beginner (0-9)';
      case ScoreClassification.intermediate:
        return 'Intermediate (10-24)';
      case ScoreClassification.expert:
        return 'Expert (25-49)';
      case ScoreClassification.master:
        return 'Master (50-99)';
      case ScoreClassification.legendary:
        return 'Legendary (100+)';
    }
  }
}

/// Game progress information
class GameProgress {
  final int snakeLength;
  final double gridOccupancy;
  final int score;
  final double growthFactor;

  const GameProgress({
    required this.snakeLength,
    required this.gridOccupancy,
    required this.score,
    required this.growthFactor,
  });

  /// Checks if grid is mostly full (>75%)
  bool get isNearlyFull => gridOccupancy > 75;

  /// Checks if grid is half full
  bool get isHalfFull => gridOccupancy >= 50;
}

/// Game end reason
enum GameEndReason {
  none,
  collision,
  victory;

  String get label {
    switch (this) {
      case GameEndReason.none:
        return 'In Progress';
      case GameEndReason.collision:
        return 'Collision!';
      case GameEndReason.victory:
        return 'Victory!';
    }
  }
}

/// Game result
class GameResult {
  final bool won;
  final bool lost;
  final GameEndReason reason;
  final int score;

  const GameResult({
    required this.won,
    required this.lost,
    required this.reason,
    required this.score,
  });

  bool get isOngoing => !won && !lost;

  String get message {
    if (won) {
      return 'You Won! Score: $score';
    } else if (lost) {
      return 'Game Over! Score: $score';
    }
    return 'Playing...';
  }
}

/// Comprehensive game statistics
class GameStatistics {
  final int score;
  final int snakeLength;
  final int gridSize;
  final SnakeDifficulty difficulty;
  final SnakeGameStatus gameStatus;
  final ScoreClassification scoreClassification;
  final double gridOccupancy;
  final int totalMoves;
  final double efficiency;

  const GameStatistics({
    required this.score,
    required this.snakeLength,
    required this.gridSize,
    required this.difficulty,
    required this.gameStatus,
    required this.scoreClassification,
    required this.gridOccupancy,
    required this.totalMoves,
    required this.efficiency,
  });

  /// Gets efficiency percentage (0-100)
  double get efficiencyPercentage => (efficiency * 100).clamp(0.0, 100.0);
}
