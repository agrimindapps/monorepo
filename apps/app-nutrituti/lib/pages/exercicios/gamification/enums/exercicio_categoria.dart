import 'package:flutter/material.dart';

/// Categorias de exercícios para o sistema FitQuest
enum ExercicioCategoria {
  cardio('Cardio', '🏃', Colors.red),
  forca('Força', '💪', Colors.blue),
  flexibilidade('Flexibilidade', '🧘', Colors.purple),
  esporte('Esporte', '⚽', Colors.green),
  luta('Artes Marciais', '🥊', Colors.orange),
  danca('Dança', '💃', Colors.pink),
  funcional('Funcional', '🔥', Colors.amber),
  outro('Outro', '🎯', Colors.grey);

  const ExercicioCategoria(this.label, this.emoji, this.color);

  final String label;
  final String emoji;
  final Color color;

  /// Retorna categoria pelo nome (case insensitive)
  static ExercicioCategoria fromName(String name) {
    return ExercicioCategoria.values.firstWhere(
      (c) => c.name.toLowerCase() == name.toLowerCase() ||
          c.label.toLowerCase() == name.toLowerCase(),
      orElse: () => ExercicioCategoria.outro,
    );
  }

  /// Calorias estimadas por minuto para cada categoria
  double get caloriasPorMinuto {
    switch (this) {
      case ExercicioCategoria.cardio:
        return 10.0;
      case ExercicioCategoria.forca:
        return 6.0;
      case ExercicioCategoria.flexibilidade:
        return 3.0;
      case ExercicioCategoria.esporte:
        return 8.0;
      case ExercicioCategoria.luta:
        return 9.0;
      case ExercicioCategoria.danca:
        return 7.0;
      case ExercicioCategoria.funcional:
        return 8.0;
      case ExercicioCategoria.outro:
        return 5.0;
    }
  }
}
