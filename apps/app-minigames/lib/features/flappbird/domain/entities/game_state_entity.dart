// Package imports:
import 'package:equatable/equatable.dart';

// Entity imports:
import 'bird_entity.dart';
import 'pipe_entity.dart';
import 'high_score_entity.dart';
import 'power_up_entity.dart';
import 'flappy_statistics.dart';
import 'enums.dart';

/// Entity representing the complete game state
class FlappyGameState extends Equatable {
  final BirdEntity bird;
  final List<PipeEntity> pipes;
  final int score;
  final FlappyGameStatus status;
  final FlappyDifficulty difficulty;
  final FlappyGameMode gameMode;
  final HighScoreEntity? highScore;
  final double screenWidth;
  final double screenHeight;
  final double groundHeight;
  
  // Power-ups
  final List<PowerUpEntity> powerUps;
  final List<ActivePowerUp> activePowerUps;
  final int pipesSinceLastPowerUp;
  
  // Time Attack mode
  final int? remainingTimeSeconds;
  
  // Session stats
  final FlappySessionStats sessionStats;

  const FlappyGameState({
    required this.bird,
    required this.pipes,
    required this.score,
    required this.status,
    required this.difficulty,
    this.gameMode = FlappyGameMode.classic,
    this.highScore,
    required this.screenWidth,
    required this.screenHeight,
    required this.groundHeight,
    this.powerUps = const [],
    this.activePowerUps = const [],
    this.pipesSinceLastPowerUp = 0,
    this.remainingTimeSeconds,
    this.sessionStats = const FlappySessionStats(),
  });

  /// Initial game state (not started)
  factory FlappyGameState.initial({
    double screenWidth = 400.0,
    double screenHeight = 800.0,
    FlappyDifficulty difficulty = FlappyDifficulty.medium,
    FlappyGameMode gameMode = FlappyGameMode.classic,
  }) {
    final groundHeight = screenHeight * 0.15;

    return FlappyGameState(
      bird: BirdEntity.initial(
        screenHeight: screenHeight,
        size: 50.0,
      ),
      pipes: [],
      score: 0,
      status: FlappyGameStatus.notStarted,
      difficulty: difficulty,
      gameMode: gameMode,
      highScore: null,
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      groundHeight: groundHeight,
      powerUps: [],
      activePowerUps: [],
      pipesSinceLastPowerUp: 0,
      remainingTimeSeconds: gameMode.getTimeLimit(difficulty),
      sessionStats: const FlappySessionStats(),
    );
  }

  /// Game play area height (excluding ground)
  double get playAreaHeight => screenHeight - groundHeight;

  /// Bird's horizontal position (fixed at 25% from left)
  double get birdX => screenWidth * 0.25;

  /// Check if game is active (playing or paused)
  bool get isActive => status.isRunning || status.isPaused;

  /// Check if game is over
  bool get isGameOver => status.isGameOver;

  /// Check if game is playing
  bool get isPlaying => status.isPlaying;

  /// Check if game is ready to start
  bool get isReady => status.isReady;

  /// Current effective game speed (with mode multipliers)
  double get effectiveGameSpeed {
    double speed = difficulty.gameSpeed;
    
    // Apply game mode multipliers
    speed *= gameMode.speedMultiplier;
    
    // Apply Speed Run progressive speed
    if (gameMode == FlappyGameMode.speedRun) {
      speed *= gameMode.getSpeedMultiplier(score);
    }
    
    // Apply power-up slow motion
    for (final powerUp in activePowerUps) {
      if (!powerUp.isExpired && powerUp.type == PowerUpType.slowMotion) {
        speed *= powerUp.type.speedMultiplier;
      }
    }
    
    return speed;
  }

  /// Current effective gap size (with mode multipliers)
  double get effectiveGapSize {
    double gap = difficulty.gapSize;
    gap *= gameMode.gapMultiplier;
    return gap;
  }

  /// Current effective bird size (with power-up effects)
  double get effectiveBirdSize {
    double size = bird.size;
    
    for (final powerUp in activePowerUps) {
      if (!powerUp.isExpired && powerUp.type == PowerUpType.shrink) {
        size *= powerUp.type.sizeMultiplier;
      }
    }
    
    return size;
  }

  /// Current points multiplier (with power-up effects)
  int get pointsMultiplier {
    for (final powerUp in activePowerUps) {
      if (!powerUp.isExpired && powerUp.type == PowerUpType.doublePoints) {
        return powerUp.type.pointsMultiplier;
      }
    }
    return 1;
  }

  /// Check if shield is active
  bool get hasShield {
    return activePowerUps.any(
      (p) => p.type == PowerUpType.shield && !p.isExpired,
    );
  }

  /// Check if ghost is active
  bool get hasGhost {
    return activePowerUps.any(
      (p) => p.type == PowerUpType.ghost && !p.isExpired,
    );
  }

  /// Check if magnet is active
  bool get hasMagnet {
    return activePowerUps.any(
      (p) => p.type == PowerUpType.magnet && !p.isExpired,
    );
  }

  /// Is night mode active
  bool get isNightMode => gameMode == FlappyGameMode.nightMode;

  /// Visibility radius for night mode
  double? get visibilityRadius => gameMode.visibilityRadius;

  /// Create a copy with modified fields
  FlappyGameState copyWith({
    BirdEntity? bird,
    List<PipeEntity>? pipes,
    int? score,
    FlappyGameStatus? status,
    FlappyDifficulty? difficulty,
    FlappyGameMode? gameMode,
    HighScoreEntity? highScore,
    double? screenWidth,
    double? screenHeight,
    double? groundHeight,
    List<PowerUpEntity>? powerUps,
    List<ActivePowerUp>? activePowerUps,
    int? pipesSinceLastPowerUp,
    int? remainingTimeSeconds,
    FlappySessionStats? sessionStats,
  }) {
    return FlappyGameState(
      bird: bird ?? this.bird,
      pipes: pipes ?? this.pipes,
      score: score ?? this.score,
      status: status ?? this.status,
      difficulty: difficulty ?? this.difficulty,
      gameMode: gameMode ?? this.gameMode,
      highScore: highScore ?? this.highScore,
      screenWidth: screenWidth ?? this.screenWidth,
      screenHeight: screenHeight ?? this.screenHeight,
      groundHeight: groundHeight ?? this.groundHeight,
      powerUps: powerUps ?? this.powerUps,
      activePowerUps: activePowerUps ?? this.activePowerUps,
      pipesSinceLastPowerUp: pipesSinceLastPowerUp ?? this.pipesSinceLastPowerUp,
      remainingTimeSeconds: remainingTimeSeconds ?? this.remainingTimeSeconds,
      sessionStats: sessionStats ?? this.sessionStats,
    );
  }

  @override
  List<Object?> get props => [
        bird,
        pipes,
        score,
        status,
        difficulty,
        gameMode,
        highScore,
        screenWidth,
        screenHeight,
        groundHeight,
        powerUps,
        activePowerUps,
        pipesSinceLastPowerUp,
        remainingTimeSeconds,
        sessionStats,
      ];
}
