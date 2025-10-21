// Project imports:
import 'package:app_minigames/models/sudoku_board.dart';
import 'puzzle_validator.dart';

class PuzzleSolver {
  final PuzzleValidator _validator = PuzzleValidator();

  bool solve(SudokuBoard board) {
    return _solveBoard(board);
  }

  bool _solveBoard(SudokuBoard board) {
    // Encontrar uma célula vazia
    int row = -1;
    int col = -1;

    for (int i = 0; i < SudokuBoard.boardSize; i++) {
      for (int j = 0; j < SudokuBoard.boardSize; j++) {
        if (board.isEmpty(i, j)) {
          row = i;
          col = j;
          break;
        }
      }
      if (row != -1) break;
    }

    // Se não encontrar célula vazia, o tabuleiro está resolvido
    if (row == -1) return true;

    // Tentar cada número de 1 a 9
    for (int num = 1; num <= 9; num++) {
      if (_validator.isValidPlacement(board, row, col, num)) {
        // Colocar o número
        board.setCell(row, col, num);

        // Tentar resolver o resto do tabuleiro
        if (_solveBoard(board)) {
          return true;
        }

        // Se não funcionar, voltar atrás
        board.setCell(row, col, 0);
      }
    }

    // Nenhuma solução encontrada
    return false;
  }
}
