import 'package:flutter/material.dart';

enum ViewMode {
  list,
  grid,
}

extension ViewModeExtension on ViewMode {
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
}
