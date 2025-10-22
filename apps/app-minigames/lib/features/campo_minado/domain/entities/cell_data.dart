import 'package:equatable/equatable.dart';
import 'enums.dart';

/// Immutable entity representing a single cell in the minefield
class CellData extends Equatable {
  final int row;
  final int col;
  final bool isMine;
  final int neighborMines;
  final CellStatus status;
  final bool isExploded;

  const CellData({
    required this.row,
    required this.col,
    required this.isMine,
    required this.neighborMines,
    required this.status,
    required this.isExploded,
  });

  /// Factory constructor for initial cell
  factory CellData.initial({
    required int row,
    required int col,
  }) {
    return CellData(
      row: row,
      col: col,
      isMine: false,
      neighborMines: 0,
      status: CellStatus.hidden,
      isExploded: false,
    );
  }

  // Helper computed properties
  bool get isRevealed => status.isRevealed;
  bool get isFlagged => status.isFlagged;
  bool get isHidden => status.isHidden;
  bool get isQuestioned => status.isQuestioned;
  bool get isEmpty => !isMine && neighborMines == 0;
  bool get hasNumber => !isMine && neighborMines > 0;
  bool get canReveal => !isFlagged && !isRevealed;

  /// Gets display text for the cell
  String get displayText {
    if (isFlagged) return '🚩';
    if (isQuestioned) return '?';
    if (!isRevealed) return '';
    if (isMine) return isExploded ? '💥' : '💣';
    if (neighborMines == 0) return '';
    return neighborMines.toString();
  }

  /// Gets the color index for the cell number
  int get colorIndex {
    if (!isRevealed || isMine) return 0;
    return neighborMines;
  }

  /// Creates a copy with updated fields
  CellData copyWith({
    int? row,
    int? col,
    bool? isMine,
    int? neighborMines,
    CellStatus? status,
    bool? isExploded,
  }) {
    return CellData(
      row: row ?? this.row,
      col: col ?? this.col,
      isMine: isMine ?? this.isMine,
      neighborMines: neighborMines ?? this.neighborMines,
      status: status ?? this.status,
      isExploded: isExploded ?? this.isExploded,
    );
  }

  @override
  List<Object?> get props => [
        row,
        col,
        isMine,
        neighborMines,
        status,
        isExploded,
      ];

  @override
  String toString() {
    return 'CellData(r:$row, c:$col, mine:$isMine, neighbors:$neighborMines, status:$status)';
  }
}
