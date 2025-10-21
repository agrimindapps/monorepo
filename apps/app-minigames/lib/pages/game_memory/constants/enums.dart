// Flutter imports:
import 'package:flutter/material.dart';

/// Constantes para os diferentes níveis de dificuldade do jogo
enum GameDifficulty {
  easy,
  medium,
  hard;

  /// Tamanho da grade para cada nível de dificuldade
  int get gridSize {
    switch (this) {
      case GameDifficulty.easy:
        return 4; // 4x4 = 16 cartas (8 pares)
      case GameDifficulty.medium:
        return 6; // 6x6 = 36 cartas (18 pares)
      case GameDifficulty.hard:
        return 8; // 8x8 = 64 cartas (32 pares)
    }
  }

  /// Tempo em milissegundos para exibir o resultado do par
  int get matchTime {
    switch (this) {
      case GameDifficulty.easy:
        return 1000; // 1 segundo
      case GameDifficulty.medium:
        return 800; // 0.8 segundos
      case GameDifficulty.hard:
        return 600; // 0.6 segundos
    }
  }

  /// Rótulo para exibição
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
}

/// Estado das cartas
enum CardState {
  hidden, // Virada para baixo
  revealed, // Temporariamente virada para cima
  matched // Par encontrado (permanece virada para cima)
}

/// Temas para as cartas
class CardThemes {
  /// Conjunto de cores para as cartas
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
    // Adicionando mais cores para dificuldades maiores
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
  ];

  /// Conjunto de ícones para as cartas
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
    // Adicionando mais ícones para dificuldades maiores
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
