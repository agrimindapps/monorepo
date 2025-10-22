// Domain imports:
import 'package:flutter/material.dart';

/// Status do jogo de quiz
enum QuizGameStatus {
  loading,
  playing,
  gameOver;

  bool get isLoading => this == QuizGameStatus.loading;
  bool get isPlaying => this == QuizGameStatus.playing;
  bool get isGameOver => this == QuizGameStatus.gameOver;
}

/// Estado da resposta atual
enum AnswerState {
  none,
  correct,
  incorrect;

  bool get isNone => this == AnswerState.none;
  bool get isCorrect => this == AnswerState.correct;
  bool get isIncorrect => this == AnswerState.incorrect;
}

/// Dificuldade do quiz
enum QuizDifficulty {
  easy(
    label: 'Fácil',
    timePerQuestion: Duration(seconds: 30),
    color: Colors.green,
  ),
  medium(
    label: 'Médio',
    timePerQuestion: Duration(seconds: 20),
    color: Colors.orange,
  ),
  hard(
    label: 'Difícil',
    timePerQuestion: Duration(seconds: 15),
    color: Colors.red,
  );

  const QuizDifficulty({
    required this.label,
    required this.timePerQuestion,
    required this.color,
  });

  final String label;
  final Duration timePerQuestion;
  final Color color;

  int get timeInSeconds => timePerQuestion.inSeconds;
}
