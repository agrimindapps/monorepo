enum GameDifficulty {
  easy(cellsToRemove: 30, label: 'Fácil'),
  medium(cellsToRemove: 45, label: 'Médio'),
  hard(cellsToRemove: 55, label: 'Difícil');

  final int cellsToRemove;
  final String label;

  const GameDifficulty({
    required this.cellsToRemove,
    required this.label,
  });

  int get cluesCount => 81 - cellsToRemove;

  double get difficultyMultiplier {
    switch (this) {
      case GameDifficulty.easy:
        return 1.0;
      case GameDifficulty.medium:
        return 1.5;
      case GameDifficulty.hard:
        return 2.0;
    }
  }
}

enum GameStatus {
  initial,
  playing,
  paused,
  completed,
  failed;

  bool get canInteract => this == GameStatus.playing;
  bool get isActive => this == GameStatus.playing || this == GameStatus.paused;
  bool get isFinished => this == GameStatus.completed || this == GameStatus.failed;
}

enum CellState {
  normal,
  selected,
  highlighted,
  error,
  sameNumber;

  bool get isHighlighted => this != CellState.normal;
}
