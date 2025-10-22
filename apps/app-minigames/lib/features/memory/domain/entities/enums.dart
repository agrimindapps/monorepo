import 'package:flutter/material.dart';

enum GameDifficulty {
  easy,
  medium,
  hard;

  int get gridSize {
    switch (this) {
      case GameDifficulty.easy:
        return 4;
      case GameDifficulty.medium:
        return 6;
      case GameDifficulty.hard:
        return 8;
    }
  }

  int get totalCards => gridSize * gridSize;

  int get totalPairs => totalCards ~/ 2;

  int get matchTime {
    switch (this) {
      case GameDifficulty.easy:
        return 1000;
      case GameDifficulty.medium:
        return 800;
      case GameDifficulty.hard:
        return 600;
    }
  }

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

  int get difficultyMultiplier {
    switch (this) {
      case GameDifficulty.easy:
        return 1;
      case GameDifficulty.medium:
        return 2;
      case GameDifficulty.hard:
        return 3;
    }
  }
}

enum CardState {
  hidden,
  revealed,
  matched;

  bool get isFlipped => this == CardState.revealed || this == CardState.matched;
  bool get isMatched => this == CardState.matched;
}

enum GameStatus {
  initial,
  playing,
  paused,
  completed,
  error;

  bool get isPlaying => this == GameStatus.playing;
  bool get isPaused => this == GameStatus.paused;
  bool get isCompleted => this == GameStatus.completed;
  bool get canInteract => this == GameStatus.playing;
}

class CardThemes {
  static const List<Color> cardColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.amber,
    Colors.indigo,
    Colors.cyan,
    Colors.brown,
    Colors.lime,
    Colors.deepOrange,
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.deepPurple,
    Colors.blueGrey,
    Colors.yellow,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.amber,
    Colors.indigo,
    Colors.cyan,
    Colors.brown,
    Colors.lime,
    Colors.deepOrange,
    Colors.lightBlue,
  ];

  static const List<IconData> cardIcons = [
    Icons.home,
    Icons.star,
    Icons.favorite,
    Icons.music_note,
    Icons.pets,
    Icons.local_pizza,
    Icons.flight,
    Icons.car_rental,
    Icons.beach_access,
    Icons.camera,
    Icons.sports_soccer,
    Icons.games,
    Icons.restaurant,
    Icons.shopping_cart,
    Icons.phone,
    Icons.email,
    Icons.wb_sunny,
    Icons.lightbulb,
    Icons.watch,
    Icons.account_circle,
    Icons.celebration,
    Icons.emoji_emotions,
    Icons.forest,
    Icons.cake,
    Icons.school,
    Icons.umbrella,
    Icons.coffee,
    Icons.sports_basketball,
    Icons.headphones,
    Icons.movie,
    Icons.book,
    Icons.palette,
    Icons.spa,
    Icons.fitness_center,
  ];
}
