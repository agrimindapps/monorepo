// Project imports:
import 'package:app_minigames/models/sudoku_board.dart';

class PuzzleValidator {
  bool isValidPlacement(SudokuBoard board, int row, int col, int num) {
    // Verificar linha
    for (int i = 0; i < SudokuBoard.boardSize; i++) {
      if (board.getCell(row, i) == num && i != col) return false;
    }

    // Verificar coluna
    for (int i = 0; i < SudokuBoard.boardSize; i++) {
      if (board.getCell(i, col) == num && i != row) return false;
    }

    // Verificar bloco 3x3
    int boxRow = (row ~/ 3) * 3;
    int boxCol = (col ~/ 3) * 3;

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board.getCell(boxRow + i, boxCol + j) == num &&
            (boxRow + i != row || boxCol + j != col)) {
          return false;
        }
      }
    }

    return true;
  }

  void updateConflicts(SudokuBoard board, [int? affectedRow, int? affectedCol]) {
    // Se ambos os parâmetros forem fornecidos, atualize apenas as células afetadas
    if (affectedRow != null && affectedCol != null) {
      _updateConflictsForCell(board, affectedRow, affectedCol);
      return;
    }

    // Caso contrário, atualize o tabuleiro inteiro
    for (int i = 0; i < SudokuBoard.boardSize; i++) {
      for (int j = 0; j < SudokuBoard.boardSize; j++) {
        board.setCellConflict(i, j, false);
      }
    }

    for (int i = 0; i < SudokuBoard.boardSize; i++) {
      for (int j = 0; j < SudokuBoard.boardSize; j++) {
        if (!board.isEmpty(i, j)) {
          _updateConflictsForCell(board, i, j);
        }
      }
    }
  }

  void _updateConflictsForCell(SudokuBoard board, int row, int col) {
    if (board.isEmpty(row, col)) return;

    int num = board.getCell(row, col);
    board.setCell(row, col, 0);
    bool hasConflict = !isValidPlacement(board, row, col, num);
    board.setCell(row, col, num);
    board.setCellConflict(row, col, hasConflict);

    // Verificar conflitos na mesma linha, coluna e bloco 3x3
    _checkRowConflicts(board, row, num);
    _checkColConflicts(board, col, num);
    _checkBoxConflicts(board, row, col, num);
  }

  void _checkRowConflicts(SudokuBoard board, int row, int placedNum) {
    for (int j = 0; j < SudokuBoard.boardSize; j++) {
      if (board.getCell(row, j) == placedNum) {
        // Verifica se há mais de uma ocorrência deste número na linha
        int count = 0;
        for (int k = 0; k < SudokuBoard.boardSize; k++) {
          if (board.getCell(row, k) == placedNum) count++;
        }
        if (count > 1) {
          for (int k = 0; k < SudokuBoard.boardSize; k++) {
            if (board.getCell(row, k) == placedNum) {
              board.setCellConflict(row, k, true);
            }
          }
        }
        break;
      }
    }
  }

  void _checkColConflicts(SudokuBoard board, int col, int placedNum) {
    for (int i = 0; i < SudokuBoard.boardSize; i++) {
      if (board.getCell(i, col) == placedNum) {
        // Verifica se há mais de uma ocorrência deste número na coluna
        int count = 0;
        for (int k = 0; k < SudokuBoard.boardSize; k++) {
          if (board.getCell(k, col) == placedNum) count++;
        }
        if (count > 1) {
          for (int k = 0; k < SudokuBoard.boardSize; k++) {
            if (board.getCell(k, col) == placedNum) {
              board.setCellConflict(k, col, true);
            }
          }
        }
        break;
      }
    }
  }

  void _checkBoxConflicts(SudokuBoard board, int row, int col, int placedNum) {
    int boxRow = (row ~/ 3) * 3;
    int boxCol = (col ~/ 3) * 3;

    // Contar ocorrências no bloco 3x3
    int count = 0;
    for (int i = boxRow; i < boxRow + 3; i++) {
      for (int j = boxCol; j < boxCol + 3; j++) {
        if (board.getCell(i, j) == placedNum) count++;
      }
    }

    // Se há mais de uma ocorrência, marcar todas como conflito
    if (count > 1) {
      for (int i = boxRow; i < boxRow + 3; i++) {
        for (int j = boxCol; j < boxCol + 3; j++) {
          if (board.getCell(i, j) == placedNum) {
            board.setCellConflict(i, j, true);
          }
        }
      }
    }
  }

  bool checkCompletion(SudokuBoard board) {
    // Verificar se o tabuleiro está completo
    for (int i = 0; i < SudokuBoard.boardSize; i++) {
      for (int j = 0; j < SudokuBoard.boardSize; j++) {
        if (board.isEmpty(i, j) || board.cellHasConflict(i, j)) {
          return false;
        }
      }
    }

    return true;
  }
}
