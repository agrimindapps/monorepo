enum AsteroidsDifficulty {
  easy(speedMultiplier: 0.7, label: 'Fácil'),
  normal(speedMultiplier: 1.0, label: 'Normal'),
  hard(speedMultiplier: 1.3, label: 'Difícil');

  final double speedMultiplier;
  final String label;

  const AsteroidsDifficulty({
    required this.speedMultiplier,
    required this.label,
  });
}

class AsteroidsSettings {
  final bool soundEnabled;
  final bool musicEnabled;
  final AsteroidsDifficulty difficulty;

  const AsteroidsSettings({
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.difficulty = AsteroidsDifficulty.normal,
  });

  AsteroidsSettings copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    AsteroidsDifficulty? difficulty,
  }) {
    return AsteroidsSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}
