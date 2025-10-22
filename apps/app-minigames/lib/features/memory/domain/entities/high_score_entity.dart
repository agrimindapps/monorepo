import 'package:equatable/equatable.dart';
import 'enums.dart';

class HighScoreEntity extends Equatable {
  final GameDifficulty difficulty;
  final int score;
  final int moves;
  final Duration time;
  final DateTime achievedAt;

  const HighScoreEntity({
    required this.difficulty,
    required this.score,
    required this.moves,
    required this.time,
    required this.achievedAt,
  });

  const HighScoreEntity.empty({
    this.difficulty = GameDifficulty.medium,
    this.score = 0,
    this.moves = 0,
    this.time = Duration.zero,
    DateTime? achievedAt,
  }) : achievedAt = achievedAt ?? const Duration(seconds: 0) as DateTime;

  bool get hasScore => score > 0;

  String get formattedTime {
    final minutes = time.inMinutes;
    final seconds = time.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [difficulty, score, moves, time, achievedAt];

  @override
  String toString() =>
      'HighScoreEntity(difficulty: ${difficulty.label}, score: $score, moves: $moves, time: $formattedTime)';
}
