// Flutter imports:
import 'package:flutter/material.dart';

enum ViewMode {
  list,
  grid;

  String get value {
    switch (this) {
      case ViewMode.list:
        return 'list';
      case ViewMode.grid:
        return 'grid';
    }
  }

  IconData get icon {
    switch (this) {
      case ViewMode.list:
        return Icons.view_list_rounded;
      case ViewMode.grid:
        return Icons.grid_view_rounded;
    }
  }

  static ViewMode fromString(String value) {
    switch (value) {
      case 'grid':
        return ViewMode.grid;
      case 'list':
      default:
        return ViewMode.list;
    }
  }

  bool get isList => this == ViewMode.list;
  bool get isGrid => this == ViewMode.grid;
}

// Legacy support for existing string-based code
class ViewModeConstants {
  static const String grid = 'grid';
  static const String list = 'list';
}
