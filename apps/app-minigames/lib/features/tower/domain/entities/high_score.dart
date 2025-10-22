import 'package:equatable/equatable.dart';

/// Immutable entity representing high score
class HighScore extends Equatable {
  final int score;

  const HighScore({required this.score});

  @override
  List<Object?> get props => [score];
}
