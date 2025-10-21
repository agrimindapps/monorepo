class TilePosition {
  final int value;
  final int row;
  final int col;
  final bool isNew;
  final bool isMerging;

  TilePosition(
    this.value,
    this.row,
    this.col, {
    this.isNew = false,
    this.isMerging = false,
  });

  TilePosition copyWith({
    int? value,
    int? row,
    int? col,
    bool? isNew,
    bool? isMerging,
  }) {
    return TilePosition(
      value ?? this.value,
      row ?? this.row,
      col ?? this.col,
      isNew: isNew ?? this.isNew,
      isMerging: isMerging ?? this.isMerging,
    );
  }
}
