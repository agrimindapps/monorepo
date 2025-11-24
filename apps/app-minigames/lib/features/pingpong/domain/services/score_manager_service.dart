
import '../entities/ball_entity.dart';

/// Service responsible for score tracking and game over conditions
///
/// Handles:
/// - Score updates when ball goes out of bounds
/// - Win condition checking
/// - Rally tracking
/// - Score statistics
class ScoreManagerService {
  // ============================================================================
  // Constants
  // ============================================================================

  /// Score needed to win the game
  static const int winningScore = 11;

  /// Left boundary (player miss)
  static const double leftBoundary = 0.0;

  /// Right boundary (AI miss)
  static const double rightBoundary = 1.0;

  // ============================================================================
  // Core Methods
  // ============================================================================

  /// Checks if ball went out of bounds and returns score update
  ScoreUpdate checkBoundaries({
    required BallEntity ball,
    required int playerScore,
    required int aiScore,
  }) {
    // Check if ball went past left boundary (player missed)
    if (ball.x <= leftBoundary) {
      return ScoreUpdate(
        shouldUpdate: true,
        scorer: Scorer.ai,
        newPlayerScore: playerScore,
        newAiScore: aiScore + 1,
        resetBallToLeft: false, // Ball goes to player (who lost point)
      );
    }

    // Check if ball went past right boundary (AI missed)
    if (ball.x >= rightBoundary) {
      return ScoreUpdate(
        shouldUpdate: true,
        scorer: Scorer.player,
        newPlayerScore: playerScore + 1,
        newAiScore: aiScore,
        resetBallToLeft: true, // Ball goes to AI (who lost point)
      );
    }

    // Ball still in play
    return ScoreUpdate(
      shouldUpdate: false,
      newPlayerScore: playerScore,
      newAiScore: aiScore,
    );
  }

  /// Checks if game is over (someone reached winning score)
  GameOverResult checkGameOver({
    required int playerScore,
    required int aiScore,
  }) {
    if (playerScore >= winningScore) {
      return GameOverResult(
        isGameOver: true,
        winner: Winner.player,
        finalPlayerScore: playerScore,
        finalAiScore: aiScore,
      );
    }

    if (aiScore >= winningScore) {
      return GameOverResult(
        isGameOver: true,
        winner: Winner.ai,
        finalPlayerScore: playerScore,
        finalAiScore: aiScore,
      );
    }

    return GameOverResult(
      isGameOver: false,
      finalPlayerScore: playerScore,
      finalAiScore: aiScore,
    );
  }

  // ============================================================================
  // Score Calculations
  // ============================================================================

  /// Calculates score differential
  int getScoreDifferential({
    required int playerScore,
    required int aiScore,
  }) {
    return playerScore - aiScore;
  }

  /// Checks if game is close (differential <= 2)
  bool isCloseGame({
    required int playerScore,
    required int aiScore,
  }) {
    return getScoreDifferential(
          playerScore: playerScore,
          aiScore: aiScore,
        ).abs() <=
        2;
  }

  /// Checks if someone is dominating (differential >= 5)
  bool isDominatingGame({
    required int playerScore,
    required int aiScore,
  }) {
    return getScoreDifferential(
          playerScore: playerScore,
          aiScore: aiScore,
        ).abs() >=
        5;
  }

  /// Gets points remaining to win for each side
  PointsToWin getPointsToWin({
    required int playerScore,
    required int aiScore,
  }) {
    return PointsToWin(
      playerPointsToWin: (winningScore - playerScore).clamp(0, winningScore),
      aiPointsToWin: (winningScore - aiScore).clamp(0, winningScore),
    );
  }

  // ============================================================================
  // Rally Management
  // ============================================================================

  /// Resets rally counter after point is scored
  RallyReset resetRally({
    required int currentRally,
    required int longestRally,
  }) {
    final isNewLongest = currentRally > longestRally;

    return RallyReset(
      newCurrentRally: 0,
      newLongestRally: isNewLongest ? currentRally : longestRally,
      wasRecord: isNewLongest,
    );
  }

  /// Updates rally after successful hit
  int incrementRally(int currentRally) {
    return currentRally + 1;
  }

  // ============================================================================
  // Game Progress
  // ============================================================================

  /// Gets game progress information
  GameProgress getProgress({
    required int playerScore,
    required int aiScore,
  }) {
    final totalScore = playerScore + aiScore;
    final progressPercentage =
        (totalScore / (winningScore * 2) * 100).clamp(0.0, 100.0);

    return GameProgress(
      totalScore: totalScore,
      progressPercentage: progressPercentage,
      isEarlyGame: totalScore < 4,
      isMidGame: totalScore >= 4 && totalScore < 8,
      isLateGame: totalScore >= 8,
    );
  }

  /// Checks if game is in decisive moment (next point could win)
  bool isDecisiveMoment({
    required int playerScore,
    required int aiScore,
  }) {
    return playerScore == winningScore - 1 || aiScore == winningScore - 1;
  }

  // ============================================================================
  // Statistics Methods
  // ============================================================================

  /// Gets score statistics
  ScoreStatistics getStatistics({
    required int playerScore,
    required int aiScore,
    required int totalHits,
    required int currentRally,
    required int longestRally,
  }) {
    final totalScore = playerScore + aiScore;
    final differential = getScoreDifferential(
      playerScore: playerScore,
      aiScore: aiScore,
    );

    final playerWinPercentage =
        totalScore > 0 ? (playerScore / totalScore * 100) : 0.0;
    final aiWinPercentage = totalScore > 0 ? (aiScore / totalScore * 100) : 0.0;

    return ScoreStatistics(
      playerScore: playerScore,
      aiScore: aiScore,
      totalScore: totalScore,
      differential: differential,
      playerWinPercentage: playerWinPercentage,
      aiWinPercentage: aiWinPercentage,
      isPlayerLeading: differential > 0,
      isAiLeading: differential < 0,
      isTied: differential == 0,
      totalHits: totalHits,
      currentRally: currentRally,
      longestRally: longestRally,
      averageRallyLength: totalScore > 0 ? totalHits / totalScore : 0.0,
    );
  }

  // ============================================================================
  // Validation Methods
  // ============================================================================

  /// Validates score state
  ScoreValidation validateScores({
    required int playerScore,
    required int aiScore,
  }) {
    final errors = <String>[];

    if (playerScore < 0) {
      errors.add('Player score cannot be negative: $playerScore');
    }

    if (aiScore < 0) {
      errors.add('AI score cannot be negative: $aiScore');
    }

    if (playerScore > winningScore + 10) {
      errors.add('Player score unreasonably high: $playerScore');
    }

    if (aiScore > winningScore + 10) {
      errors.add('AI score unreasonably high: $aiScore');
    }

    return ScoreValidation(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  /// Checks if player is winning
  bool isPlayerWinning({
    required int playerScore,
    required int aiScore,
  }) {
    return playerScore > aiScore;
  }

  /// Checks if AI is winning
  bool isAiWinning({
    required int playerScore,
    required int aiScore,
  }) {
    return aiScore > playerScore;
  }

  /// Checks if scores are tied
  bool isScoreTied({
    required int playerScore,
    required int aiScore,
  }) {
    return playerScore == aiScore;
  }

  /// Gets current leader
  Leader? getCurrentLeader({
    required int playerScore,
    required int aiScore,
  }) {
    if (playerScore > aiScore) return Leader.player;
    if (aiScore > playerScore) return Leader.ai;
    return null; // Tied
  }
}

// ==============================================================================
// Models
// ==============================================================================

/// Result of score update check
class ScoreUpdate {
  final bool shouldUpdate;
  final Scorer? scorer;
  final int newPlayerScore;
  final int newAiScore;
  final bool resetBallToLeft;

  const ScoreUpdate({
    required this.shouldUpdate,
    this.scorer,
    required this.newPlayerScore,
    required this.newAiScore,
    this.resetBallToLeft = false,
  });
}

/// Who scored the point
enum Scorer {
  player,
  ai;

  bool get isPlayer => this == Scorer.player;
  bool get isAi => this == Scorer.ai;
}

/// Result of game over check
class GameOverResult {
  final bool isGameOver;
  final Winner? winner;
  final int finalPlayerScore;
  final int finalAiScore;

  const GameOverResult({
    required this.isGameOver,
    this.winner,
    required this.finalPlayerScore,
    required this.finalAiScore,
  });

  /// Gets winner name
  String? get winnerName => winner?.label;
}

/// Who won the game
enum Winner {
  player,
  ai;

  bool get isPlayer => this == Winner.player;
  bool get isAi => this == Winner.ai;

  String get label => this == Winner.player ? 'Player' : 'AI';
}

/// Points remaining to win
class PointsToWin {
  final int playerPointsToWin;
  final int aiPointsToWin;

  const PointsToWin({
    required this.playerPointsToWin,
    required this.aiPointsToWin,
  });
}

/// Rally reset information
class RallyReset {
  final int newCurrentRally;
  final int newLongestRally;
  final bool wasRecord;

  const RallyReset({
    required this.newCurrentRally,
    required this.newLongestRally,
    required this.wasRecord,
  });
}

/// Game progress information
class GameProgress {
  final int totalScore;
  final double progressPercentage;
  final bool isEarlyGame;
  final bool isMidGame;
  final bool isLateGame;

  const GameProgress({
    required this.totalScore,
    required this.progressPercentage,
    required this.isEarlyGame,
    required this.isMidGame,
    required this.isLateGame,
  });
}

/// Current game leader
enum Leader {
  player,
  ai;

  String get label => this == Leader.player ? 'Player' : 'AI';
}

/// Score statistics
class ScoreStatistics {
  final int playerScore;
  final int aiScore;
  final int totalScore;
  final int differential;
  final double playerWinPercentage;
  final double aiWinPercentage;
  final bool isPlayerLeading;
  final bool isAiLeading;
  final bool isTied;
  final int totalHits;
  final int currentRally;
  final int longestRally;
  final double averageRallyLength;

  const ScoreStatistics({
    required this.playerScore,
    required this.aiScore,
    required this.totalScore,
    required this.differential,
    required this.playerWinPercentage,
    required this.aiWinPercentage,
    required this.isPlayerLeading,
    required this.isAiLeading,
    required this.isTied,
    required this.totalHits,
    required this.currentRally,
    required this.longestRally,
    required this.averageRallyLength,
  });
}

/// Validation result for scores
class ScoreValidation {
  final bool isValid;
  final List<String> errors;

  const ScoreValidation({
    required this.isValid,
    required this.errors,
  });

  String? get errorMessage => errors.isEmpty ? null : errors.join('; ');
}
