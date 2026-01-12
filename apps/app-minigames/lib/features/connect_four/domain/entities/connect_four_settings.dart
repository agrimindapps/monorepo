enum ConnectFourDifficulty {
  easy(label: 'Fácil - IA Fraca'),
  normal(label: 'Normal - IA Média'),
  hard(label: 'Difícil - IA Forte');

  final String label;

  const ConnectFourDifficulty({required this.label});
}

class ConnectFourSettings {
  final bool soundEnabled;
  final bool musicEnabled;
  final bool playAgainstAI;
  final ConnectFourDifficulty difficulty;

  const ConnectFourSettings({
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.playAgainstAI = false,
    this.difficulty = ConnectFourDifficulty.normal,
  });

  ConnectFourSettings copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    bool? playAgainstAI,
    ConnectFourDifficulty? difficulty,
  }) {
    return ConnectFourSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      playAgainstAI: playAgainstAI ?? this.playAgainstAI,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}
