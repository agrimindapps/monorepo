// Global enums shared across all mini-games

/// Dificuldade global dos jogos
enum GameDifficulty {
  easy,
  medium,
  hard,
  expert,
}

/// Status do jogo
enum GameStatus {
  idle,
  playing,
  paused,
  gameOver,
  won,
}

/// Direções de movimento (para jogos que precisam)
enum Direction {
  up,
  down,
  left,
  right,
}

/// Tipo de controle
enum ControlType {
  touch,
  tilt,
  buttons,
}

/// Modo de jogo
enum GameMode {
  single,
  multiplayer,
  versus,
  coop,
}

/// Tema visual
enum GameTheme {
  light,
  dark,
  colorful,
  minimal,
}

// Extensions para facilitar uso

extension GameDifficultyExtension on GameDifficulty {
  String get displayName {
    switch (this) {
      case GameDifficulty.easy:
        return 'Fácil';
      case GameDifficulty.medium:
        return 'Médio';
      case GameDifficulty.hard:
        return 'Difícil';
      case GameDifficulty.expert:
        return 'Expert';
    }
  }

  int get multiplier {
    switch (this) {
      case GameDifficulty.easy:
        return 1;
      case GameDifficulty.medium:
        return 2;
      case GameDifficulty.hard:
        return 3;
      case GameDifficulty.expert:
        return 5;
    }
  }
}

extension GameStatusExtension on GameStatus {
  String get displayName {
    switch (this) {
      case GameStatus.idle:
        return 'Aguardando';
      case GameStatus.playing:
        return 'Jogando';
      case GameStatus.paused:
        return 'Pausado';
      case GameStatus.gameOver:
        return 'Game Over';
      case GameStatus.won:
        return 'Vitória!';
    }
  }

  bool get isPlaying => this == GameStatus.playing;
  bool get isActive => this == GameStatus.playing || this == GameStatus.paused;
  bool get isFinished => this == GameStatus.gameOver || this == GameStatus.won;
}

extension DirectionExtension on Direction {
  String get displayName {
    switch (this) {
      case Direction.up:
        return 'Cima';
      case Direction.down:
        return 'Baixo';
      case Direction.left:
        return 'Esquerda';
      case Direction.right:
        return 'Direita';
    }
  }

  Direction get opposite {
    switch (this) {
      case Direction.up:
        return Direction.down;
      case Direction.down:
        return Direction.up;
      case Direction.left:
        return Direction.right;
      case Direction.right:
        return Direction.left;
    }
  }
}
