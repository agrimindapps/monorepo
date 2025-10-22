enum GameStatus {
  initial,
  playing,
  paused,
  gameOver;

  bool get canInteract => this == GameStatus.playing;
  bool get isGameOver => this == GameStatus.gameOver;
}

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

  double get aiSpeed {
    switch (this) {
      case GameDifficulty.easy:
        return 0.004;
      case GameDifficulty.medium:
        return 0.007;
      case GameDifficulty.hard:
        return 0.010;
    }
  }

  double get aiReactionDelay {
    switch (this) {
      case GameDifficulty.easy:
        return 0.05;
      case GameDifficulty.medium:
        return 0.02;
      case GameDifficulty.hard:
        return 0.01;
    }
  }
}

enum PaddleDirection {
  up,
  down,
  stop;
}
