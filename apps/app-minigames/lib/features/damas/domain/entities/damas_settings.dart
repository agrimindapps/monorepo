enum DamasDifficulty {
  easy(label: 'Fácil - IA Fraca'),
  normal(label: 'Normal - IA Média'),
  hard(label: 'Difícil - IA Forte');

  final String label;

  const DamasDifficulty({required this.label});
}

class DamasSettings {
  final bool soundEnabled;
  final bool musicEnabled;
  final bool playAgainstAI;
  final DamasDifficulty difficulty;

  const DamasSettings({
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.playAgainstAI = false,
    this.difficulty = DamasDifficulty.normal,
  });

  DamasSettings copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    bool? playAgainstAI,
    DamasDifficulty? difficulty,
  }) {
    return DamasSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      playAgainstAI: playAgainstAI ?? this.playAgainstAI,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}
