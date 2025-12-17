import 'package:flutter/material.dart';

/// Cores predefinidas para listas de tarefas
/// Inspiradas no Microsoft To Do
class TaskListColors {
  TaskListColors._();

  static const List<TaskListColorOption> options = [
    TaskListColorOption(
      name: 'Azul',
      value: '#2196F3',
      color: Color(0xFF2196F3),
    ),
    TaskListColorOption(
      name: 'Verde',
      value: '#4CAF50',
      color: Color(0xFF4CAF50),
    ),
    TaskListColorOption(
      name: 'Vermelho',
      value: '#F44336',
      color: Color(0xFFF44336),
    ),
    TaskListColorOption(
      name: 'Roxo',
      value: '#9C27B0',
      color: Color(0xFF9C27B0),
    ),
    TaskListColorOption(
      name: 'Laranja',
      value: '#FF9800',
      color: Color(0xFFFF9800),
    ),
    TaskListColorOption(
      name: 'Rosa',
      value: '#E91E63',
      color: Color(0xFFE91E63),
    ),
    TaskListColorOption(
      name: 'Ciano',
      value: '#00BCD4',
      color: Color(0xFF00BCD4),
    ),
    TaskListColorOption(
      name: 'Índigo',
      value: '#3F51B5',
      color: Color(0xFF3F51B5),
    ),
    TaskListColorOption(
      name: 'Lima',
      value: '#CDDC39',
      color: Color(0xFFCDDC39),
    ),
    TaskListColorOption(
      name: 'Âmbar',
      value: '#FFC107',
      color: Color(0xFFFFC107),
    ),
    TaskListColorOption(
      name: 'Marrom',
      value: '#795548',
      color: Color(0xFF795548),
    ),
    TaskListColorOption(
      name: 'Cinza',
      value: '#9E9E9E',
      color: Color(0xFF9E9E9E),
    ),
  ];

  /// Converte string hex para Color
  static Color fromHex(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  /// Obtém a opção de cor pelo valor hex
  static TaskListColorOption? getOptionByValue(String hexValue) {
    try {
      return options.firstWhere((opt) => opt.value == hexValue);
    } catch (_) {
      return null;
    }
  }

  /// Cor padrão (azul)
  static const String defaultColor = '#2196F3';
}

class TaskListColorOption {
  final String name;
  final String value; // Hex string
  final Color color;

  const TaskListColorOption({
    required this.name,
    required this.value,
    required this.color,
  });
}
