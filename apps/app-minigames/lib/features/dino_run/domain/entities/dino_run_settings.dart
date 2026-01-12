enum DinoRunDifficulty {
  easy(difficultyMultiplier: 0.7, label: 'Fácil'),
  normal(difficultyMultiplier: 1.0, label: 'Normal'),
  hard(difficultyMultiplier: 1.3, label: 'Difícil');

  final double difficultyMultiplier;
  final String label;

  const DinoRunDifficulty({
    required this.difficultyMultiplier,
    required this.label,
  });
}

class DinoRunSettings {
  final bool soundEnabled;
  final bool musicEnabled;
  final DinoRunDifficulty difficulty;

  const DinoRunSettings({
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.difficulty = DinoRunDifficulty.normal,
  });

  DinoRunSettings copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    DinoRunDifficulty? difficulty,
  }) {
    return DinoRunSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}
