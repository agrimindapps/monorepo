import 'package:flutter/material.dart';

enum CulturaViewMode {
  list,
  grid,
}

extension CulturaViewModeExtension on CulturaViewMode {
  String get value {
    switch (this) {
      case CulturaViewMode.list:
        return 'list';
      case CulturaViewMode.grid:
        return 'grid';
    }
  }

  IconData get icon {
    switch (this) {
      case CulturaViewMode.list:
        return Icons.view_list_rounded;
      case CulturaViewMode.grid:
        return Icons.grid_view_rounded;
    }
  }

  bool get isList => this == CulturaViewMode.list;
  bool get isGrid => this == CulturaViewMode.grid;

  static CulturaViewMode fromString(String value) {
    switch (value) {
      case 'grid':
        return CulturaViewMode.grid;
      case 'list':
      default:
        return CulturaViewMode.list;
    }
  }
}