enum ReversiDifficulty {
  easy,
  medium,
  hard;

  String get label {
    switch (this) {
      case ReversiDifficulty.easy:
        return 'Fácil';
      case ReversiDifficulty.medium:
        return 'Médio';
      case ReversiDifficulty.hard:
        return 'Difícil';
    }
  }
}

class ReversiSettings {
  final bool soundEnabled;
  final bool showValidMoves;
  final bool showMoveCount;
  final ReversiDifficulty difficulty;

  const ReversiSettings({
    this.soundEnabled = true,
    this.showValidMoves = true,
    this.showMoveCount = true,
    this.difficulty = ReversiDifficulty.medium,
  });

  ReversiSettings copyWith({
    bool? soundEnabled,
    bool? showValidMoves,
    bool? showMoveCount,
    ReversiDifficulty? difficulty,
  }) {
    return ReversiSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      showValidMoves: showValidMoves ?? this.showValidMoves,
      showMoveCount: showMoveCount ?? this.showMoveCount,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}
