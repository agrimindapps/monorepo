// Project imports:
import 'package:app_minigames/constants/enums.dart';
import 'package:app_minigames/constants/game_constants.dart';

/// Represents a single cell in the minesweeper grid
class Cell {
  final int row;
  final int col;
  
  CellState _state;
  bool _isMine;
  int _neighborMines;
  bool _isRevealed;
  bool _isFlagged;
  bool _isQuestioned;
  bool _isExploded;

  Cell({
    required this.row,
    required this.col,
    CellState initialState = CellState.hidden,
    bool isMine = false,
  }) : _state = initialState,
       _isMine = isMine,
       _neighborMines = 0,
       _isRevealed = false,
       _isFlagged = false,
       _isQuestioned = false,
       _isExploded = false;

  // Getters
  CellState get state => _state;
  bool get isMine => _isMine;
  int get neighborMines => _neighborMines;
  bool get isRevealed => _isRevealed;
  bool get isFlagged => _isFlagged;
  bool get isQuestioned => _isQuestioned;
  bool get isExploded => _isExploded;
  bool get isHidden => _state == CellState.hidden;
  bool get isEmpty => !_isMine && _neighborMines == 0;
  bool get hasNumber => !_isMine && _neighborMines > 0;

  // Setters
  void setMine(bool value) {
    _isMine = value;
  }

  void setNeighborMines(int count) {
    _neighborMines = count.clamp(0, 8);
  }

  void incrementNeighborMines() {
    if (_neighborMines < 8) {
      _neighborMines++;
    }
  }

  /// Reveals the cell
  bool reveal() {
    if (_isFlagged || _isRevealed) {
      return false;
    }

    _isRevealed = true;
    _state = CellState.revealed;
    
    if (_isMine) {
      _isExploded = true;
    }
    
    return true;
  }

  /// Toggles flag state
  void toggleFlag() {
    if (_isRevealed) return;

    if (_isFlagged) {
      _isFlagged = false;
      _isQuestioned = true;
      _state = CellState.questioned;
    } else if (_isQuestioned) {
      _isQuestioned = false;
      _state = CellState.hidden;
    } else {
      _isFlagged = true;
      _state = CellState.flagged;
    }
  }

  /// Forces flag state (for auto-flagging at game end)
  void setFlag(bool flagged) {
    if (_isRevealed) return;
    
    _isFlagged = flagged;
    _isQuestioned = false;
    _state = flagged ? CellState.flagged : CellState.hidden;
  }

  /// Resets cell to initial state
  void reset() {
    _state = CellState.hidden;
    _isMine = false;
    _neighborMines = 0;
    _isRevealed = false;
    _isFlagged = false;
    _isQuestioned = false;
    _isExploded = false;
  }

  /// Gets display text for the cell
  String get displayText {
    if (_isFlagged) return GameIcons.flag;
    if (_isQuestioned) return GameIcons.question;
    if (!_isRevealed) return '';
    if (_isMine) return _isExploded ? GameIcons.explosion : GameIcons.mine;
    if (_neighborMines == 0) return '';
    return _neighborMines.toString();
  }

  /// Gets the appropriate color for the cell content
  int get colorIndex {
    if (!_isRevealed || _isMine) return 0;
    return _neighborMines;
  }

  /// Creates a copy of this cell
  Cell copy() {
    final cell = Cell(
      row: row,
      col: col,
      initialState: _state,
      isMine: _isMine,
    );
    
    cell._neighborMines = _neighborMines;
    cell._isRevealed = _isRevealed;
    cell._isFlagged = _isFlagged;
    cell._isQuestioned = _isQuestioned;
    cell._isExploded = _isExploded;
    
    return cell;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Cell && other.row == row && other.col == col;
  }

  @override
  int get hashCode => Object.hash(row, col);

  @override
  String toString() {
    return 'Cell(r:$row, c:$col, mine:$_isMine, neighbors:$_neighborMines, state:$_state)';
  }
}
