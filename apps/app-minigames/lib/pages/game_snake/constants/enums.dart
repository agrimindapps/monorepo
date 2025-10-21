// Flutter imports:
import 'package:flutter/material.dart';

/**
 * TODO (prioridade: MÉDIA): Adicionar mais níveis de dificuldade (Expert, 
 * Insane)
 * 
 * TODO (prioridade: MÉDIA): Adicionar configurações personalizáveis de 
 * velocidade
 * 
 * TODO (prioridade: BAIXA): Criar enum para tipos de power-ups
 * 
 * TODO (prioridade: BAIXA): Adicionar enum para diferentes tipos de comida
 * 
 * REFACTOR (prioridade: BAIXA): Mover GameColors para arquivo separado de 
 * tema
 * 
 * REFACTOR (prioridade: BAIXA): Usar Color.fromARGB para melhor legibilidade
 * 
 * STYLE (prioridade: MÉDIA): Adicionar mais cores para diferentes elementos 
 * do jogo
 * 
 * STYLE (prioridade: BAIXA): Considerar usar Material Design 3 colors
 */

enum Direction { up, down, left, right }

enum GameState { 
  notStarted,
  running,
  paused,
  gameOver;
  
  String get label {
    switch (this) {
      case GameState.notStarted:
        return 'Não iniciado';
      case GameState.running:
        return 'Rodando';
      case GameState.paused:
        return 'Pausado';
      case GameState.gameOver:
        return 'Game Over';
    }
  }
  
  bool get isPlayable => this == GameState.running;
  bool get canPause => this == GameState.running;
  bool get canStart => this == GameState.notStarted || this == GameState.gameOver;
  bool get canResume => this == GameState.paused;
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
        return 'Normal';
      case GameDifficulty.hard:
        return 'Difícil';
    }
  }

  Duration get gameSpeed {
    switch (this) {
      case GameDifficulty.easy:
        return const Duration(milliseconds: 400);
      case GameDifficulty.medium:
        return const Duration(milliseconds: 300);
      case GameDifficulty.hard:
        return const Duration(milliseconds: 200);
    }
  }
}

enum FoodType {
  normal,
  golden,
  speed,
  shrink;

  String get label {
    switch (this) {
      case FoodType.normal:
        return 'Normal';
      case FoodType.golden:
        return 'Dourada';
      case FoodType.speed:
        return 'Velocidade';
      case FoodType.shrink:
        return 'Encolher';
    }
  }

  String get description {
    switch (this) {
      case FoodType.normal:
        return 'Comida padrão (+1 ponto)';
      case FoodType.golden:
        return 'Comida dourada (+2 pontos)';
      case FoodType.speed:
        return 'Acelera temporariamente';
      case FoodType.shrink:
        return 'Diminui o tamanho da cobra';
    }
  }

  Color get color {
    switch (this) {
      case FoodType.normal:
        return Colors.red;
      case FoodType.golden:
        return Colors.amber;
      case FoodType.speed:
        return Colors.blue;
      case FoodType.shrink:
        return Colors.purple;
    }
  }

  IconData get icon {
    switch (this) {
      case FoodType.normal:
        return Icons.circle;
      case FoodType.golden:
        return Icons.star;
      case FoodType.speed:
        return Icons.flash_on;
      case FoodType.shrink:
        return Icons.compress;
    }
  }

  double get spawnProbability {
    switch (this) {
      case FoodType.normal:
        return 0.65; // 65% chance
      case FoodType.golden:
        return 0.20; // 20% chance
      case FoodType.speed:
        return 0.10; // 10% chance
      case FoodType.shrink:
        return 0.05; // 5% chance
    }
  }

  int get points {
    switch (this) {
      case FoodType.normal:
        return 1;
      case FoodType.golden:
        return 2;
      case FoodType.speed:
        return 1;
      case FoodType.shrink:
        return 1;
    }
  }

  Duration get effectDuration {
    switch (this) {
      case FoodType.normal:
        return Duration.zero;
      case FoodType.golden:
        return Duration.zero;
      case FoodType.speed:
        return const Duration(seconds: 5);
      case FoodType.shrink:
        return Duration.zero; // Efeito instantâneo
    }
  }
}

class GameColors {
  static const Color snakeHead = Colors.green;
  static const Color snakeBody = Colors.lightGreen;
  static const Color food = Colors.red;
  static const Color background = Color(0xFFF5F5F5);
  static const Color gridLine = Color(0xFFE0E0E0);
}
