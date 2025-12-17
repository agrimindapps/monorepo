import 'package:flutter/material.dart';

class ListColors {
  static const Map<String, Color> colors = {
    'blue': Color(0xFF2196F3),
    'red': Color(0xFFE53935),
    'green': Color(0xFF43A047),
    'orange': Color(0xFFFF9800),
    'purple': Color(0xFF9C27B0),
    'pink': Color(0xFFE91E63),
    'teal': Color(0xFF009688),
    'indigo': Color(0xFF3F51B5),
    'yellow': Color(0xFFFFC107),
    'brown': Color(0xFF795548),
    'grey': Color(0xFF9E9E9E),
    'cyan': Color(0xFF00BCD4),
  };

  static const String defaultColorKey = 'blue';

  static Color getColor(String colorKey) {
    return colors[colorKey] ?? colors[defaultColorKey]!;
  }

  static String getColorKey(Color color) {
    for (var entry in colors.entries) {
      if (entry.value == color) return entry.key;
    }
    return defaultColorKey;
  }

  static List<MapEntry<String, Color>> get availableColors => colors.entries.toList();
}
