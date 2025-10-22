import 'package:equatable/equatable.dart';
import 'enums.dart';

/// Immutable entity representing high score for each difficulty
class HighScore extends Equatable {
  final int easyFastest;
  final int mediumFastest;
  final int hardFastest;

  const HighScore({
    required this.easyFastest,
    required this.mediumFastest,
    required this.hardFastest,
  });

  const HighScore.empty()
      : easyFastest = 0,
        mediumFastest = 0,
        hardFastest = 0;

  int getFastest(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return easyFastest;
      case GameDifficulty.medium:
        return mediumFastest;
      case GameDifficulty.hard:
        return hardFastest;
    }
  }

  HighScore updateFastest(GameDifficulty difficulty, int time) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return copyWith(easyFastest: time);
      case GameDifficulty.medium:
        return copyWith(mediumFastest: time);
      case GameDifficulty.hard:
        return copyWith(hardFastest: time);
    }
  }

  HighScore copyWith({
    int? easyFastest,
    int? mediumFastest,
    int? hardFastest,
  }) {
    return HighScore(
      easyFastest: easyFastest ?? this.easyFastest,
      mediumFastest: mediumFastest ?? this.mediumFastest,
      hardFastest: hardFastest ?? this.hardFastest,
    );
  }

  @override
  List<Object?> get props => [easyFastest, mediumFastest, hardFastest];
}
