// Package imports:
import 'package:equatable/equatable.dart';

// Entity imports:
import 'bird_entity.dart';
import 'pipe_entity.dart';
import 'high_score_entity.dart';
import 'enums.dart';

/// Entity representing the complete game state
class FlappyGameState extends Equatable {
  final BirdEntity bird;
  final List<PipeEntity> pipes;
  final int score;
  final FlappyGameStatus status;
  final FlappyDifficulty difficulty;
  final HighScoreEntity? highScore;
  final double screenWidth;
  final double screenHeight;
  final double groundHeight;

  const FlappyGameState({
    required this.bird,
    required this.pipes,
    required this.score,
    required this.status,
    required this.difficulty,
    this.highScore,
    required this.screenWidth,
    required this.screenHeight,
    required this.groundHeight,
  });

  /// Initial game state (not started)
  factory FlappyGameState.initial({
    double screenWidth = 400.0,
    double screenHeight = 800.0,
    FlappyDifficulty difficulty = FlappyDifficulty.medium,
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
      highScore: null,
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      groundHeight: groundHeight,
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

  /// Create a copy with modified fields
  FlappyGameState copyWith({
    BirdEntity? bird,
    List<PipeEntity>? pipes,
    int? score,
    FlappyGameStatus? status,
    FlappyDifficulty? difficulty,
    HighScoreEntity? highScore,
    double? screenWidth,
    double? screenHeight,
    double? groundHeight,
  }) {
    return FlappyGameState(
      bird: bird ?? this.bird,
      pipes: pipes ?? this.pipes,
      score: score ?? this.score,
      status: status ?? this.status,
      difficulty: difficulty ?? this.difficulty,
      highScore: highScore ?? this.highScore,
      screenWidth: screenWidth ?? this.screenWidth,
      screenHeight: screenHeight ?? this.screenHeight,
      groundHeight: groundHeight ?? this.groundHeight,
    );
  }

  @override
  List<Object?> get props => [
        bird,
        pipes,
        score,
        status,
        difficulty,
        highScore,
        screenWidth,
        screenHeight,
        groundHeight,
      ];
}
