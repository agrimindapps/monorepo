// Flutter imports:
import 'package:flutter/material.dart';

class TMBConstants {
  static const List<Map<String, dynamic>> generos = [
    {'id': 1, 'text': 'Masculino'},
    {'id': 2, 'text': 'Feminino'}
  ];

  static const List<Map<String, dynamic>> niveisAtividade = [
    {'id': 1, 'text': 'Sedentário (pouco ou nenhum exercício)', 'fator': 1.2},
    {
      'id': 2,
      'text': 'Levemente ativo (exercício leve 1-3 dias/semana)',
      'fator': 1.375
    },
    {
      'id': 3,
      'text': 'Moderadamente ativo (exercício moderado 3-5 dias/semana)',
      'fator': 1.55
    },
    {
      'id': 4,
      'text': 'Muito ativo (exercício intenso 6-7 dias/semana)',
      'fator': 1.725
    },
    {
      'id': 5,
      'text': 'Extra ativo (exercício muito intenso, trabalho físico)',
      'fator': 1.9
    },
  ];

  static IconData getNivelAtividadeIcon(int id) {
    switch (id) {
      case 1:
        return Icons.weekend_outlined;
      case 2:
        return Icons.directions_walk;
      case 3:
        return Icons.directions_run;
      case 4:
        return Icons.fitness_center;
      case 5:
        return Icons.sports_gymnastics;
      default:
        return Icons.directions_walk;
    }
  }
}
