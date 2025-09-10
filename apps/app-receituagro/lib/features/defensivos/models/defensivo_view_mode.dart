import 'package:flutter/material.dart';

enum DefensivoViewMode {
  list,
  grid,
}

extension DefensivoViewModeExtension on DefensivoViewMode {
  String get value {
    switch (this) {
      case DefensivoViewMode.list:
        return 'list';
      case DefensivoViewMode.grid:
        return 'grid';
    }
  }

  IconData get icon {
    switch (this) {
      case DefensivoViewMode.list:
        return Icons.view_list_rounded;
      case DefensivoViewMode.grid:
        return Icons.grid_view_rounded;
    }
  }

  bool get isList => this == DefensivoViewMode.list;
  bool get isGrid => this == DefensivoViewMode.grid;

  static DefensivoViewMode fromString(String value) {
    switch (value) {
      case 'grid':
        return DefensivoViewMode.grid;
      case 'list':
      default:
        return DefensivoViewMode.list;
    }
  }
}