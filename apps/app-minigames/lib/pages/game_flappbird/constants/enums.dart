// Flutter imports:
import 'package:flutter/material.dart';

enum GameState {
  ready,
  playing,
  gameOver,
}

extension GameStateExtension on GameState {
  String get message {
    switch (this) {
      case GameState.ready:
        return 'Toque para iniciar!';
      case GameState.playing:
        return '';
      case GameState.gameOver:
        return 'Game Over!';
    }
  }
}

enum GameDifficulty {
  easy,
  medium,
  hard,
}

extension GameDifficultyExtension on GameDifficulty {
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

  // Velocidade do jogo
  double get gameSpeed {
    switch (this) {
      case GameDifficulty.easy:
        return 2.0;
      case GameDifficulty.medium:
        return 3.0;
      case GameDifficulty.hard:
        return 4.0;
    }
  }

  // Tamanho dos espaços entre obstáculos
  double get gapSize {
    switch (this) {
      case GameDifficulty.easy:
        return 0.45; // 45% da altura da tela
      case GameDifficulty.medium:
        return 0.40; // 40% da altura da tela
      case GameDifficulty.hard:
        return 0.35; // 35% da altura da tela
    }
  }
}

class GameColors {
  static const Color background = Color(0xFF87CEEB); // Sky blue
  static const Color bird = Colors.amber;
  static const Color obstacle = Colors.green;
  static const Color ground = Color(0xFF8B4513); // Brown
  static const Color textColor = Colors.white;
  static const Color scoreColor = Colors.white;
}

class GameSizes {
  static const double birdSize = 50.0;
  static const double obstacleWidth = 80.0;
}
