enum FroggerDifficulty {
  easy(difficultyMultiplier: 0.7, label: 'Fácil'),
  normal(difficultyMultiplier: 1.0, label: 'Normal'),
  hard(difficultyMultiplier: 1.3, label: 'Difícil');

  final double difficultyMultiplier;
  final String label;

  const FroggerDifficulty({
    required this.difficultyMultiplier,
    required this.label,
  });
}

class FroggerSettings {
  final bool soundEnabled;
  final bool musicEnabled;
  final FroggerDifficulty difficulty;

  const FroggerSettings({
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.difficulty = FroggerDifficulty.normal,
  });

  FroggerSettings copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    FroggerDifficulty? difficulty,
  }) {
    return FroggerSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}
