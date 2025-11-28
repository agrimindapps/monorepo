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

/// Game mode for Sudoku
enum SudokuGameMode {
  classic('Clássico', '🎯', 'Modo tradicional sem limite de tempo'),
  timeAttack('Contra o Tempo', '⏱️', 'Complete antes do tempo acabar'),
  hardcore('Hardcore', '💀', '3 erros e você perde'),
  zen('Zen', '🧘', 'Relaxe sem timer ou penalidades'),
  speedRun('Speed Run', '🏃', 'Complete 5 puzzles o mais rápido possível');

  final String label;
  final String emoji;
  final String description;

  const SudokuGameMode(this.label, this.emoji, this.description);

  /// Time limit in seconds for TimeAttack mode by difficulty
  int? getTimeLimit(GameDifficulty difficulty) {
    if (this != SudokuGameMode.timeAttack) return null;
    switch (difficulty) {
      case GameDifficulty.easy:
        return 600; // 10 minutes
      case GameDifficulty.medium:
        return 900; // 15 minutes
      case GameDifficulty.hard:
        return 1500; // 25 minutes
    }
  }

  /// Maximum mistakes allowed for Hardcore mode
  int? get maxMistakes => this == SudokuGameMode.hardcore ? 3 : null;

  /// Whether to show the timer
  bool get showTimer => this != SudokuGameMode.zen;

  /// Whether to track mistakes as game-ending
  bool get trackMistakes => this != SudokuGameMode.zen;

  /// Whether to count errors towards game loss
  bool get mistakesEndGame => this == SudokuGameMode.hardcore;

  /// Whether this mode has a time limit
  bool get hasTimeLimit => this == SudokuGameMode.timeAttack;

  /// Number of puzzles to complete for SpeedRun
  int get speedRunPuzzleCount => this == SudokuGameMode.speedRun ? 5 : 1;

  /// Mode multiplier for score calculation
  double get modeMultiplier {
    switch (this) {
      case SudokuGameMode.classic:
        return 1.0;
      case SudokuGameMode.timeAttack:
        return 1.5;
      case SudokuGameMode.hardcore:
        return 2.0;
      case SudokuGameMode.zen:
        return 0.5;
      case SudokuGameMode.speedRun:
        return 1.8;
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
