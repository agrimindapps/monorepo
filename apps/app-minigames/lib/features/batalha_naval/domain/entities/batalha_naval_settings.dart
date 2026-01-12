enum BatalhaNavalDifficulty {
  easy('Fácil'),
  medium('Médio'),
  hard('Difícil');

  final String label;
  const BatalhaNavalDifficulty(this.label);
}

class BatalhaNavalSettings {
  final bool soundEnabled;
  final bool musicEnabled;
  final BatalhaNavalDifficulty difficulty;

  const BatalhaNavalSettings({
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.difficulty = BatalhaNavalDifficulty.medium,
  });

  BatalhaNavalSettings copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    BatalhaNavalDifficulty? difficulty,
  }) {
    return BatalhaNavalSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}
