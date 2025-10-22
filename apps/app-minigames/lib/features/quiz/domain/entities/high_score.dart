// Package imports:
import 'package:equatable/equatable.dart';

/// Entity representing the high score
class HighScore extends Equatable {
  final int score;

  const HighScore({required this.score});

  /// Empty high score
  factory HighScore.empty() => const HighScore(score: 0);

  /// Create a copy with modified fields
  HighScore copyWith({int? score}) {
    return HighScore(score: score ?? this.score);
  }

  @override
  List<Object?> get props => [score];
}
