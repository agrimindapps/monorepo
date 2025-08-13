enum ViewMode {
  grid,
  list;

  static const String gridValue = 'grid';
  static const String listValue = 'list';

  String get value {
    switch (this) {
      case ViewMode.grid:
        return gridValue;
      case ViewMode.list:
        return listValue;
    }
  }

  static ViewMode fromString(String value) {
    switch (value) {
      case gridValue:
        return ViewMode.grid;
      case listValue:
        return ViewMode.list;
      default:
        return ViewMode.grid;
    }
  }

  bool get isGrid => this == ViewMode.grid;
  bool get isList => this == ViewMode.list;
}