import 'package:equatable/equatable.dart';

/// Immutable entity representing the high score for quiz game
class HighScore extends Equatable {
  final int score;

  const HighScore({required this.score});

  @override
  List<Object?> get props => [score];
}
