import 'package:equatable/equatable.dart';
import 'ball_entity.dart';
import 'paddle_entity.dart';
import 'high_score_entity.dart';
import 'enums.dart';

class GameStateEntity extends Equatable {
  final BallEntity ball;
  final PaddleEntity playerPaddle;
  final PaddleEntity aiPaddle;
  final int playerScore;
  final int aiScore;
  final GameStatus status;
  final GameDifficulty difficulty;
  final HighScoreEntity? highScore;
  final DateTime? startTime;
  final int totalHits;
  final int currentRally;
  final int maxRally;

  const GameStateEntity({
    required this.ball,
    required this.playerPaddle,
    required this.aiPaddle,
    this.playerScore = 0,
    this.aiScore = 0,
    this.status = GameStatus.initial,
    this.difficulty = GameDifficulty.medium,
    this.highScore,
    this.startTime,
    this.totalHits = 0,
    this.currentRally = 0,
    this.maxRally = 0,
  });

  factory GameStateEntity.initial() => GameStateEntity(
        ball: BallEntity.initial(),
        playerPaddle: PaddleEntity.player(),
        aiPaddle: PaddleEntity.ai(),
        status: GameStatus.initial,
        difficulty: GameDifficulty.medium,
      );

  static const int winningScore = 5;

  bool get isGameOver => playerScore >= winningScore || aiScore >= winningScore;
  bool get playerWon => playerScore >= winningScore;
  bool get aiWon => aiScore >= winningScore;
  bool get canPlay => status == GameStatus.playing;

  Duration? get elapsedTime {
    if (startTime == null) return null;
    return DateTime.now().difference(startTime!);
  }

  int calculateFinalScore() {
    if (elapsedTime == null || !isGameOver || !playerWon) return 0;

    final baseScore = playerScore * 100;
    final timeFactor = 1000 / (elapsedTime!.inSeconds + 1);
    final hitsFactor = totalHits * 10;
    final rallyBonus = maxRally * 50;
    final difficultyMultiplier = switch (difficulty) {
      GameDifficulty.easy => 1.0,
      GameDifficulty.medium => 1.5,
      GameDifficulty.hard => 2.0,
    };

    return ((baseScore + timeFactor + hitsFactor + rallyBonus) *
            difficultyMultiplier)
        .round();
  }

  GameStateEntity copyWith({
    BallEntity? ball,
    PaddleEntity? playerPaddle,
    PaddleEntity? aiPaddle,
    int? playerScore,
    int? aiScore,
    GameStatus? status,
    GameDifficulty? difficulty,
    HighScoreEntity? highScore,
    DateTime? startTime,
    int? totalHits,
    int? currentRally,
    int? maxRally,
    bool clearHighScore = false,
  }) {
    return GameStateEntity(
      ball: ball ?? this.ball,
      playerPaddle: playerPaddle ?? this.playerPaddle,
      aiPaddle: aiPaddle ?? this.aiPaddle,
      playerScore: playerScore ?? this.playerScore,
      aiScore: aiScore ?? this.aiScore,
      status: status ?? this.status,
      difficulty: difficulty ?? this.difficulty,
      highScore: clearHighScore ? null : (highScore ?? this.highScore),
      startTime: startTime ?? this.startTime,
      totalHits: totalHits ?? this.totalHits,
      currentRally: currentRally ?? this.currentRally,
      maxRally: maxRally ?? this.maxRally,
    );
  }

  @override
  List<Object?> get props => [
        ball,
        playerPaddle,
        aiPaddle,
        playerScore,
        aiScore,
        status,
        difficulty,
        highScore,
        startTime,
        totalHits,
        currentRally,
        maxRally,
      ];

  @override
  String toString() =>
      'GameStateEntity(status: $status, score: $playerScore-$aiScore, rally: $currentRally)';
}
