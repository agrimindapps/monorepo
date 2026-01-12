enum GalagaDifficulty {
  easy(difficultyMultiplier: 0.7, label: 'Fácil'),
  normal(difficultyMultiplier: 1.0, label: 'Normal'),
  hard(difficultyMultiplier: 1.3, label: 'Difícil');

  final double difficultyMultiplier;
  final String label;

  const GalagaDifficulty({
    required this.difficultyMultiplier,
    required this.label,
  });
}

class GalagaSettings {
  final bool soundEnabled;
  final bool musicEnabled;
  final GalagaDifficulty difficulty;

  const GalagaSettings({
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.difficulty = GalagaDifficulty.normal,
  });

  GalagaSettings copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    GalagaDifficulty? difficulty,
  }) {
    return GalagaSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}
