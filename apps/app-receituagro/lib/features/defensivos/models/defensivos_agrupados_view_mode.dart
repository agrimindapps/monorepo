import 'package:flutter/material.dart';

enum DefensivosAgrupadosViewMode {
  list,
  grid,
}

extension DefensivosAgrupadosViewModeExtension on DefensivosAgrupadosViewMode {
  String get value {
    switch (this) {
      case DefensivosAgrupadosViewMode.list:
        return 'list';
      case DefensivosAgrupadosViewMode.grid:
        return 'grid';
    }
  }

  IconData get icon {
    switch (this) {
      case DefensivosAgrupadosViewMode.list:
        return Icons.view_list_rounded;
      case DefensivosAgrupadosViewMode.grid:
        return Icons.grid_view_rounded;
    }
  }

  bool get isList => this == DefensivosAgrupadosViewMode.list;
  bool get isGrid => this == DefensivosAgrupadosViewMode.grid;

  static DefensivosAgrupadosViewMode fromString(String value) {
    switch (value) {
      case 'grid':
        return DefensivosAgrupadosViewMode.grid;
      case 'list':
      default:
        return DefensivosAgrupadosViewMode.list;
    }
  }
}