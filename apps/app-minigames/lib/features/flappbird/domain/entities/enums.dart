/// Game status enumeration
enum FlappyGameStatus {
  notStarted,
  ready,
  playing,
  paused,
  gameOver;

  /// Check if game is in a running state
  bool get isRunning => this == FlappyGameStatus.playing;

  /// Check if game is playing (alias for isRunning)
  bool get isPlaying => this == FlappyGameStatus.playing;

  /// Check if game is over
  bool get isGameOver => this == FlappyGameStatus.gameOver;

  /// Check if game is ready to start
  bool get isReady => this == FlappyGameStatus.ready;

  /// Check if game is paused
  bool get isPaused => this == FlappyGameStatus.paused;

  /// Check if game is not started
  bool get isNotStarted => this == FlappyGameStatus.notStarted;
}

/// Game difficulty enumeration
enum FlappyDifficulty {
  easy(gapSize: 0.35, gameSpeed: 2.5),
  medium(gapSize: 0.25, gameSpeed: 3.5),
  hard(gapSize: 0.20, gameSpeed: 4.5);

  const FlappyDifficulty({
    required this.gapSize,
    required this.gameSpeed,
  });

  /// Gap size as percentage of screen height (0.0 - 1.0)
  final double gapSize;

  /// Game speed (obstacle movement speed in pixels per frame)
  final double gameSpeed;
}
