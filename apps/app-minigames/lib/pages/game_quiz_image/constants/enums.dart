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

  // Tempo limite para responder às perguntas
  int get timeLimit {
    switch (this) {
      case GameDifficulty.easy:
        return 30;
      case GameDifficulty.medium:
        return 20;
      case GameDifficulty.hard:
        return 15;
    }
  }

  // Número de opções para cada pergunta
  int get optionsCount {
    switch (this) {
      case GameDifficulty.easy:
        return 3;
      case GameDifficulty.medium:
        return 4;
      case GameDifficulty.hard:
        return 5;
    }
  }
}

enum AnswerState {
  unanswered,
  correct,
  incorrect,
}

extension AnswerStateExtension on AnswerState {
  Color get color {
    switch (this) {
      case AnswerState.unanswered:
        return Colors.white;
      case AnswerState.correct:
        return Colors.green.shade100;
      case AnswerState.incorrect:
        return Colors.red.shade100;
    }
  }

  IconData? get icon {
    switch (this) {
      case AnswerState.unanswered:
        return null;
      case AnswerState.correct:
        return Icons.check_circle;
      case AnswerState.incorrect:
        return Icons.cancel;
    }
  }
}

class GameColors {
  static const Color questionBackground = Color(0xFFF5F5F5);
  static const Color correctAnswer = Color(0xFFD4EDDA);
  static const Color incorrectAnswer = Color(0xFFF8D7DA);
  static const Color selectedOption = Color(0xFFE2E3FC);
  static const Color timeBarBackground = Color(0xFFE0E0E0);
  static const Color timeBarForeground = Color(0xFF4CAF50);
}
