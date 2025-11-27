import 'dart:math';

import '../entities/enums.dart';

/// Service for game mode specific logic
class GameModeService {
  /// Calculate survival mode speed multiplier based on elapsed time
  /// Speed increases 5% every 5 seconds
  int calculateSurvivalSpeed({
    required int baseSpeed,
    required int secondsElapsed,
  }) {
    final speedIncreases = secondsElapsed ~/ 5;
    final multiplier = pow(0.95, speedIncreases);
    return (baseSpeed * multiplier).round().clamp(5, baseSpeed);
  }

  /// Handle endless mode collision
  /// Returns (newScore, segmentsToRemove, shouldGameOver)
  (int, int, bool) handleEndlessCollision({
    required int currentScore,
    required int snakeLength,
  }) {
    // Lose 5 points
    final newScore = (currentScore - 5).clamp(0, currentScore);
    
    // Lose 2 segments (minimum snake length is 1)
    final segmentsToRemove = (snakeLength > 2) ? 2 : snakeLength - 1;
    
    // Game over if score is 0 AND snake is minimum length
    final shouldGameOver = newScore <= 0 && snakeLength <= 1;
    
    return (newScore, segmentsToRemove, shouldGameOver);
  }

  /// Get power-up spawn rate multiplier for game mode
  double getPowerUpSpawnRateMultiplier(SnakeGameMode mode) {
    return switch (mode) {
      SnakeGameMode.classic => 1.0,
      SnakeGameMode.survival => 1.2, // Slightly more power-ups
      SnakeGameMode.timeAttack => 1.5, // More power-ups to increase scoring
      SnakeGameMode.endless => 2.0, // Much more power-ups
    };
  }

  /// Get score multiplier for game mode
  double getScoreMultiplier(SnakeGameMode mode) {
    return switch (mode) {
      SnakeGameMode.classic => 1.0,
      SnakeGameMode.survival => 1.5, // Higher scores for harder mode
      SnakeGameMode.timeAttack => 2.0, // Double points in time attack
      SnakeGameMode.endless => 0.5, // Lower scores since no game over
    };
  }

  /// Check if time attack mode is over
  bool isTimeAttackOver(int remainingSeconds) => remainingSeconds <= 0;

  /// Get base time for time attack mode in seconds
  int getTimeAttackDuration() => 120; // 2 minutes
}
