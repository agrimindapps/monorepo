enum ViewMode {
  grid('grid'),
  list('list');

  const ViewMode(this.value);
  final String value;

  static ViewMode fromString(String value) {
    return ViewMode.values.firstWhere(
      (mode) => mode.value == value,
      orElse: () => ViewMode.list,
    );
  }
}