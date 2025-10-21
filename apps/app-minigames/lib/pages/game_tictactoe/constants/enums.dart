// Flutter imports:
import 'package:flutter/material.dart';

enum Player {
  x,
  o,
  none;

  String get symbol {
    switch (this) {
      case Player.x:
        return 'X';
      case Player.o:
        return 'O';
      case Player.none:
        return '';
    }
  }

  Color get color {
    switch (this) {
      case Player.x:
        return Colors.blue;
      case Player.o:
        return Colors.red;
      case Player.none:
        return Colors.transparent;
    }
  }

  Player get opponent {
    switch (this) {
      case Player.x:
        return Player.o;
      case Player.o:
        return Player.x;
      case Player.none:
        return Player.none;
    }
  }
}

enum GameMode {
  vsPlayer,
  vsComputer;

  String get label {
    switch (this) {
      case GameMode.vsPlayer:
        return 'Dois Jogadores';
      case GameMode.vsComputer:
        return 'Versus Computador';
    }
  }
}

enum Difficulty {
  easy,
  medium,
  hard;

  String get label {
    switch (this) {
      case Difficulty.easy:
        return 'Fácil';
      case Difficulty.medium:
        return 'Médio';
      case Difficulty.hard:
        return 'Difícil';
    }
  }
}

enum GameResult {
  inProgress,
  xWins,
  oWins,
  draw;

  String get message {
    switch (this) {
      case GameResult.xWins:
        return 'X venceu!';
      case GameResult.oWins:
        return 'O venceu!';
      case GameResult.draw:
        return 'Empate!';
      case GameResult.inProgress:
        return '';
    }
  }
}
