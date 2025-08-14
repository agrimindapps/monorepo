enum ViewMode { 
  list, 
  grid 
}

extension ViewModeExtension on ViewMode {
  bool get isList => this == ViewMode.list;
  bool get isGrid => this == ViewMode.grid;
}