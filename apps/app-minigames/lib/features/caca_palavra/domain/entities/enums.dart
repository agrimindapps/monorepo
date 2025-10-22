/// Game enums for word search (Caça-Palavras)
enum GameDifficulty {
  easy,
  medium,
  hard;

  String get label {
    switch (this) {
      case GameDifficulty.easy:
        return 'Fácil';
      case GameDifficulty.medium:
        return 'Médio';
      case GameDifficulty.hard:
        return 'Difícil';
    }
  }

  int get gridSize {
    switch (this) {
      case GameDifficulty.easy:
        return 8;
      case GameDifficulty.medium:
        return 10;
      case GameDifficulty.hard:
        return 12;
    }
  }

  int get wordCount {
    switch (this) {
      case GameDifficulty.easy:
        return 5;
      case GameDifficulty.medium:
        return 8;
      case GameDifficulty.hard:
        return 12;
    }
  }
}

/// Word placement direction in the grid
enum WordDirection {
  horizontal,
  vertical,
  diagonalDown,
  diagonalUp;

  String get label {
    switch (this) {
      case WordDirection.horizontal:
        return 'Horizontal';
      case WordDirection.vertical:
        return 'Vertical';
      case WordDirection.diagonalDown:
        return 'Diagonal (↘)';
      case WordDirection.diagonalUp:
        return 'Diagonal (↗)';
    }
  }
}

/// Game status
enum GameStatus {
  playing,
  completed;

  bool get isPlaying => this == GameStatus.playing;
  bool get isCompleted => this == GameStatus.completed;
}
