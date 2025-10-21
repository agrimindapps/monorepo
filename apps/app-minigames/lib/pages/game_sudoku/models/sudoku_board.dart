class SudokuBoard {
  static const int boardSize = 9;

  List<List<int>> _board = List.generate(boardSize, (_) => List.filled(boardSize, 0));
  List<List<int>> _solution = List.generate(boardSize, (_) => List.filled(boardSize, 0));
  List<List<bool>> _isEditable = List.generate(boardSize, (_) => List.filled(boardSize, true));
  List<List<bool>> _hasConflict = List.generate(boardSize, (_) => List.filled(boardSize, false));
  List<List<Set<int>>> _notes = List.generate(boardSize, (_) => List.generate(boardSize, (_) => <int>{}));

  List<List<int>> get board => _board;
  List<List<int>> get solution => _solution;
  List<List<bool>> get isEditable => _isEditable;
  List<List<bool>> get hasConflict => _hasConflict;
  List<List<Set<int>>> get notes => _notes;

  void reset() {
    _board = List.generate(boardSize, (_) => List.filled(boardSize, 0));
    _solution = List.generate(boardSize, (_) => List.filled(boardSize, 0));
    _isEditable = List.generate(boardSize, (_) => List.filled(boardSize, true));
    _hasConflict = List.generate(boardSize, (_) => List.filled(boardSize, false));
    _notes = List.generate(boardSize, (_) => List.generate(boardSize, (_) => <int>{}));
  }

  void saveSolution() {
    _solution = List.generate(boardSize, (i) => List.from(_board[i]));
  }

  void setCell(int row, int col, int value) {
    if (row >= 0 && row < boardSize && col >= 0 && col < boardSize) {
      _board[row][col] = value;
    }
  }

  int getCell(int row, int col) {
    if (row >= 0 && row < boardSize && col >= 0 && col < boardSize) {
      return _board[row][col];
    }
    return 0;
  }

  void setCellEditable(int row, int col, bool editable) {
    if (row >= 0 && row < boardSize && col >= 0 && col < boardSize) {
      _isEditable[row][col] = editable;
    }
  }

  bool isCellEditable(int row, int col) {
    if (row >= 0 && row < boardSize && col >= 0 && col < boardSize) {
      return _isEditable[row][col];
    }
    return false;
  }

  void setCellConflict(int row, int col, bool hasConflict) {
    if (row >= 0 && row < boardSize && col >= 0 && col < boardSize) {
      _hasConflict[row][col] = hasConflict;
    }
  }

  bool cellHasConflict(int row, int col) {
    if (row >= 0 && row < boardSize && col >= 0 && col < boardSize) {
      return _hasConflict[row][col];
    }
    return false;
  }

  void addNote(int row, int col, int note) {
    if (row >= 0 && row < boardSize && col >= 0 && col < boardSize) {
      _notes[row][col].add(note);
    }
  }

  void removeNote(int row, int col, int note) {
    if (row >= 0 && row < boardSize && col >= 0 && col < boardSize) {
      _notes[row][col].remove(note);
    }
  }

  void clearNotes(int row, int col) {
    if (row >= 0 && row < boardSize && col >= 0 && col < boardSize) {
      _notes[row][col].clear();
    }
  }

  Set<int> getCellNotes(int row, int col) {
    if (row >= 0 && row < boardSize && col >= 0 && col < boardSize) {
      return Set.from(_notes[row][col]);
    }
    return <int>{};
  }

  bool isEmpty(int row, int col) {
    return getCell(row, col) == 0;
  }

  bool isComplete() {
    for (int i = 0; i < boardSize; i++) {
      for (int j = 0; j < boardSize; j++) {
        if (_board[i][j] == 0) {
          return false;
        }
      }
    }
    return true;
  }

  void copyFrom(SudokuBoard other) {
    _board = List.generate(boardSize, (i) => List.from(other._board[i]));
    _solution = List.generate(boardSize, (i) => List.from(other._solution[i]));
    _isEditable = List.generate(boardSize, (i) => List.from(other._isEditable[i]));
    _hasConflict = List.generate(boardSize, (i) => List.from(other._hasConflict[i]));
    _notes = List.generate(boardSize, (i) => 
      List.generate(boardSize, (j) => Set<int>.from(other._notes[i][j])));
  }
}