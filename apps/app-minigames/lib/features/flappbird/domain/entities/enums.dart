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

/// Game mode enumeration
enum FlappyGameMode {
  classic('Clássico', '🎯', 'Modo tradicional'),
  timeAttack('Time Attack', '⏱️', 'Sobreviva até o tempo acabar'),
  speedRun('Speed Run', '🏃', 'Velocidade aumenta progressivamente'),
  nightMode('Night Mode', '🌙', 'Visibilidade reduzida'),
  hardcore('Hardcore', '💀', 'Gap menor, velocidade maior');

  final String label;
  final String emoji;
  final String description;

  const FlappyGameMode(this.label, this.emoji, this.description);

  /// Time limit in seconds for Time Attack mode
  int? getTimeLimit(FlappyDifficulty difficulty) {
    if (this != FlappyGameMode.timeAttack) return null;
    switch (difficulty) {
      case FlappyDifficulty.easy:
        return 60; // 1 minute
      case FlappyDifficulty.medium:
        return 45; // 45 seconds
      case FlappyDifficulty.hard:
        return 30; // 30 seconds
    }
  }

  /// Speed multiplier progression for Speed Run mode
  double getSpeedMultiplier(int pipesPassed) {
    if (this != FlappyGameMode.speedRun) return 1.0;
    // Increases by 5% every 5 pipes, up to 2x speed
    return (1.0 + (pipesPassed ~/ 5) * 0.05).clamp(1.0, 2.0);
  }

  /// Gap multiplier for Hardcore mode (smaller gap)
  double get gapMultiplier {
    if (this == FlappyGameMode.hardcore) return 0.8; // 20% smaller gap
    return 1.0;
  }

  /// Speed multiplier for Hardcore mode
  double get speedMultiplier {
    if (this == FlappyGameMode.hardcore) return 1.3; // 30% faster
    return 1.0;
  }

  /// Visibility radius for Night Mode (as percentage of screen width)
  double? get visibilityRadius {
    if (this != FlappyGameMode.nightMode) return null;
    return 0.25; // 25% of screen width visible around bird
  }
}

/// Power-up type enumeration
enum PowerUpType {
  shield('🛡️', 'Escudo', 'Protege de 1 colisão', 1),
  slowMotion('⏳', 'Câmera Lenta', 'Reduz velocidade 50%', 5),
  doublePoints('⭐', 'Pontos Duplos', 'Cada pipe vale 2x', 10),
  shrink('📏', 'Encolher', 'Bird 50% menor', 8),
  ghost('👻', 'Fantasma', 'Atravessa próximo pipe', 1),
  magnet('🧲', 'Ímã', 'Atrai power-ups', 15);

  final String emoji;
  final String name;
  final String description;
  final int durationSeconds; // Duration or uses depending on type

  const PowerUpType(this.emoji, this.name, this.description, this.durationSeconds);

  /// Whether this power-up is use-based (vs time-based)
  bool get isUseBased => this == PowerUpType.shield || this == PowerUpType.ghost;

  /// Get duration for time-based power-ups
  Duration get duration => Duration(seconds: durationSeconds);

  /// Get speed multiplier (for slow motion)
  double get speedMultiplier {
    if (this == PowerUpType.slowMotion) return 0.5;
    return 1.0;
  }

  /// Get size multiplier (for shrink)
  double get sizeMultiplier {
    if (this == PowerUpType.shrink) return 0.5;
    return 1.0;
  }

  /// Get points multiplier (for double points)
  int get pointsMultiplier {
    if (this == PowerUpType.doublePoints) return 2;
    return 1;
  }

  /// Spawn weight (higher = more common)
  int get spawnWeight {
    switch (this) {
      case PowerUpType.shield:
        return 25;
      case PowerUpType.slowMotion:
        return 20;
      case PowerUpType.doublePoints:
        return 20;
      case PowerUpType.shrink:
        return 15;
      case PowerUpType.ghost:
        return 10;
      case PowerUpType.magnet:
        return 10;
    }
  }
}
