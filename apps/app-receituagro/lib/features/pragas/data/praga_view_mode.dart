import 'package:flutter/material.dart';

enum PragaViewMode {
  list,
  grid,
}

extension PragaViewModeExtension on PragaViewMode {
  String get value {
    switch (this) {
      case PragaViewMode.list:
        return 'list';
      case PragaViewMode.grid:
        return 'grid';
    }
  }

  IconData get icon {
    switch (this) {
      case PragaViewMode.list:
        return Icons.view_list_rounded;
      case PragaViewMode.grid:
        return Icons.grid_view_rounded;
    }
  }

  bool get isList => this == PragaViewMode.list;
  bool get isGrid => this == PragaViewMode.grid;

  static PragaViewMode fromString(String value) {
    switch (value) {
      case 'grid':
        return PragaViewMode.grid;
      case 'list':
      default:
        return PragaViewMode.list;
    }
  }
}