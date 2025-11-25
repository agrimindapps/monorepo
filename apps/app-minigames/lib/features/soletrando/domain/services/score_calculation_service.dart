import '../entities/enums.dart';

/// Service responsible for score calculation and management
///
/// Handles:
/// - Base score calculation
/// - Time bonus calculation
/// - Mistake penalty calculation
/// - Difficulty multiplier application
/// - Skip penalty calculation
/// - Score statistics
class ScoreCalculationService {
  ScoreCalculationService();

  // Base score constants
  static const int baseScore = 100;
  static const int timeBonusMultiplier = 2;
  static const int mistakePenaltyPerError = 5;
  static const int skipPenaltyBase = 50;

  // ============================================================================
  // Word Completion Score
  // ============================================================================

  /// Calculates score for completing a word
  int calculateWordCompletionScore({
    required int timeRemaining,
    required int mistakes,
    required GameDifficulty difficulty,
  }) {
    final timeBonus = calculateTimeBonus(timeRemaining);
    final mistakePenalty = calculateMistakePenalty(mistakes);
    final rawScore = baseScore + timeBonus - mistakePenalty;

    return applyDifficultyMultiplier(
      score: rawScore,
      difficulty: difficulty,
    );
  }

  /// Calculates time bonus based on remaining time
  int calculateTimeBonus(int timeRemaining) {
    return timeRemaining * timeBonusMultiplier;
  }

  /// Calculates penalty based on mistakes
  int calculateMistakePenalty(int mistakes) {
    return mistakes * mistakePenaltyPerError;
  }

  /// Applies difficulty multiplier to score
  int applyDifficultyMultiplier({
    required int score,
    required GameDifficulty difficulty,
  }) {
    return score * difficulty.scoreMultiplier;
  }

  /// Gets detailed score breakdown
  ScoreBreakdown getScoreBreakdown({
    required int timeRemaining,
    required int mistakes,
    required GameDifficulty difficulty,
  }) {
    final timeBonus = calculateTimeBonus(timeRemaining);
    final mistakePenalty = calculateMistakePenalty(mistakes);
    final rawScore = baseScore + timeBonus - mistakePenalty;
    final multipliedScore = applyDifficultyMultiplier(
      score: rawScore,
      difficulty: difficulty,
    );

    return ScoreBreakdown(
      baseScore: baseScore,
      timeBonus: timeBonus,
      mistakePenalty: mistakePenalty,
      rawScore: rawScore,
      difficultyMultiplier: difficulty.scoreMultiplier,
      finalScore: multipliedScore,
    );
  }

  // ============================================================================
  // Skip Penalty
  // ============================================================================

  /// Calculates penalty for skipping a word
  int calculateSkipPenalty(GameDifficulty difficulty) {
    return skipPenaltyBase * difficulty.scoreMultiplier;
  }

  /// Applies skip penalty to current score
  int applySkipPenalty({
    required int currentScore,
    required GameDifficulty difficulty,
  }) {
    final penalty = calculateSkipPenalty(difficulty);
    return (currentScore - penalty).clamp(0, double.infinity).toInt();
  }

  /// Gets skip penalty result
  SkipPenaltyResult getSkipPenaltyResult({
    required int currentScore,
    required GameDifficulty difficulty,
  }) {
    final penalty = calculateSkipPenalty(difficulty);
    final newScore = applySkipPenalty(
      currentScore: currentScore,
      difficulty: difficulty,
    );

    return SkipPenaltyResult(
      oldScore: currentScore,
      penalty: penalty,
      newScore: newScore,
      wasReducedToZero: newScore == 0 && currentScore > 0,
    );
  }

  // ============================================================================
  // Score Classification
  // ============================================================================

  /// Gets score classification based on points
  ScoreClass getScoreClassification(int score) {
    if (score >= 5000) {
      return ScoreClass.legendary;
    } else if (score >= 2000) {
      return ScoreClass.master;
    } else if (score >= 1000) {
      return ScoreClass.expert;
    } else if (score >= 500) {
      return ScoreClass.intermediate;
    } else {
      return ScoreClass.beginner;
    }
  }

  /// Gets score rank based on classification
  ScoreRank getScoreRank(int score) {
    final classification = getScoreClassification(score);
    final percentage = (score % 1000) / 1000 * 100;

    return ScoreRank(
      score: score,
      classification: classification,
      percentageToNextRank: percentage,
    );
  }

  // ============================================================================
  // Score Validation
  // ============================================================================

  /// Validates score is within reasonable bounds
  bool isValidScore(int score) {
    return score >= 0 && score <= 999999;
  }

  /// Clamps score to valid range
  int clampScore(int score) {
    return score.clamp(0, 999999);
  }

  // ============================================================================
  // Efficiency Metrics
  // ============================================================================

  /// Calculates efficiency (score per word)
  double calculateEfficiency({
    required int totalScore,
    required int wordsCompleted,
  }) {
    if (wordsCompleted == 0) return 0.0;
    return totalScore / wordsCompleted;
  }

  /// Calculates accuracy (correct vs total guesses)
  double calculateAccuracy({
    required int correctGuesses,
    required int totalGuesses,
  }) {
    if (totalGuesses == 0) return 0.0;
    return (correctGuesses / totalGuesses).clamp(0.0, 1.0);
  }

  /// Calculates mistake rate
  double calculateMistakeRate({
    required int mistakes,
    required int totalGuesses,
  }) {
    if (totalGuesses == 0) return 0.0;
    return (mistakes / totalGuesses).clamp(0.0, 1.0);
  }

  // ============================================================================
  // Bonus Calculations
  // ============================================================================

  /// Calculates perfect word bonus (no mistakes)
  int calculatePerfectWordBonus({
    required GameDifficulty difficulty,
    required bool hadMistakes,
  }) {
    if (hadMistakes) return 0;
    return 50 * difficulty.scoreMultiplier;
  }

  /// Calculates speed bonus (completed quickly)
  int calculateSpeedBonus({
    required int timeRemaining,
    required int totalTime,
    required GameDifficulty difficulty,
  }) {
    final percentage = timeRemaining / totalTime;

    if (percentage >= 0.8) {
      return 100 * difficulty.scoreMultiplier;
    } else if (percentage >= 0.6) {
      return 50 * difficulty.scoreMultiplier;
    } else if (percentage >= 0.4) {
      return 25 * difficulty.scoreMultiplier;
    }

    return 0;
  }

  // ============================================================================
  // Statistics
  // ============================================================================

  /// Gets comprehensive score statistics
  ScoreStatistics getStatistics({
    required int currentScore,
    required int wordsCompleted,
    required int totalMistakes,
    required int totalGuesses,
    required GameDifficulty difficulty,
  }) {
    final classification = getScoreClassification(currentScore);
    final efficiency = calculateEfficiency(
      totalScore: currentScore,
      wordsCompleted: wordsCompleted,
    );
    final mistakeRate = calculateMistakeRate(
      mistakes: totalMistakes,
      totalGuesses: totalGuesses,
    );

    return ScoreStatistics(
      currentScore: currentScore,
      classification: classification,
      wordsCompleted: wordsCompleted,
      efficiency: efficiency,
      totalMistakes: totalMistakes,
      mistakeRate: mistakeRate,
      difficulty: difficulty,
    );
  }
}

// ==============================================================================
// Models
// ==============================================================================

/// Score breakdown showing all components
class ScoreBreakdown {
  final int baseScore;
  final int timeBonus;
  final int mistakePenalty;
  final int rawScore;
  final int difficultyMultiplier;
  final int finalScore;

  const ScoreBreakdown({
    required this.baseScore,
    required this.timeBonus,
    required this.mistakePenalty,
    required this.rawScore,
    required this.difficultyMultiplier,
    required this.finalScore,
  });

  /// Gets formatted breakdown text
  String get breakdownText {
    return '''
Base: $baseScore
Time Bonus: +$timeBonus
Mistake Penalty: -$mistakePenalty
Raw Score: $rawScore
Multiplier: x$difficultyMultiplier
Final Score: $finalScore
''';
  }
}

/// Skip penalty result
class SkipPenaltyResult {
  final int oldScore;
  final int penalty;
  final int newScore;
  final bool wasReducedToZero;

  const SkipPenaltyResult({
    required this.oldScore,
    required this.penalty,
    required this.newScore,
    required this.wasReducedToZero,
  });

  /// Gets score change
  int get scoreChange => newScore - oldScore;

  /// Gets message about penalty
  String get message {
    if (wasReducedToZero) {
      return 'Pontuação reduzida a zero (-$penalty pontos)';
    }
    return 'Penalidade de $penalty pontos aplicada';
  }
}

/// Score classification levels
enum ScoreClass {
  beginner,
  intermediate,
  expert,
  master,
  legendary;

  String get label {
    switch (this) {
      case ScoreClass.beginner:
        return 'Iniciante (0-499)';
      case ScoreClass.intermediate:
        return 'Intermediário (500-999)';
      case ScoreClass.expert:
        return 'Expert (1000-1999)';
      case ScoreClass.master:
        return 'Mestre (2000-4999)';
      case ScoreClass.legendary:
        return 'Lendário (5000+)';
    }
  }

  String get emoji {
    switch (this) {
      case ScoreClass.beginner:
        return '🌱';
      case ScoreClass.intermediate:
        return '⭐';
      case ScoreClass.expert:
        return '💎';
      case ScoreClass.master:
        return '👑';
      case ScoreClass.legendary:
        return '🏆';
    }
  }
}

/// Score rank information
class ScoreRank {
  final int score;
  final ScoreClass classification;
  final double percentageToNextRank;

  const ScoreRank({
    required this.score,
    required this.classification,
    required this.percentageToNextRank,
  });

  /// Gets next rank
  ScoreClass? get nextRank {
    switch (classification) {
      case ScoreClass.beginner:
        return ScoreClass.intermediate;
      case ScoreClass.intermediate:
        return ScoreClass.expert;
      case ScoreClass.expert:
        return ScoreClass.master;
      case ScoreClass.master:
        return ScoreClass.legendary;
      case ScoreClass.legendary:
        return null;
    }
  }

  /// Checks if at max rank
  bool get isMaxRank => classification == ScoreClass.legendary;
}

/// Comprehensive score statistics
class ScoreStatistics {
  final int currentScore;
  final ScoreClass classification;
  final int wordsCompleted;
  final double efficiency;
  final int totalMistakes;
  final double mistakeRate;
  final GameDifficulty difficulty;

  const ScoreStatistics({
    required this.currentScore,
    required this.classification,
    required this.wordsCompleted,
    required this.efficiency,
    required this.totalMistakes,
    required this.mistakeRate,
    required this.difficulty,
  });

  /// Gets mistake rate as percentage
  double get mistakeRatePercentage => mistakeRate * 100;

  /// Checks if performance is good (< 20% mistakes)
  bool get isGoodPerformance => mistakeRate < 0.2;
}
