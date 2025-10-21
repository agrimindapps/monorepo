// Dart imports:
import 'dart:math';

// Project imports:
import 'package:app_minigames/models/sudoku_board.dart';
import 'puzzle_solver.dart';

class PuzzleGenerator {
  final PuzzleSolver _solver = PuzzleSolver();
  final Random _random = Random();

  void generateSolvedBoard(SudokuBoard board) {
    // Limpar o tabuleiro
    board.reset();

    // Preencher a diagonal principal (blocos 3x3)
    for (int i = 0; i < SudokuBoard.boardSize; i += 3) {
      _fillBox(board, i, i);
    }

    // Resolver o restante do tabuleiro
    _solver.solve(board);
  }

  void _fillBox(SudokuBoard board, int row, int col) {
    List<int> numbers = List.generate(9, (i) => i + 1);
    numbers.shuffle(_random);

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        board.setCell(row + i, col + j, numbers[i * 3 + j]);
      }
    }
  }

  void removeRandomCells(SudokuBoard board, int count) {
    // Criar uma lista de todas as células
    List<List<int>> allCells = [];
    for (int i = 0; i < SudokuBoard.boardSize; i++) {
      for (int j = 0; j < SudokuBoard.boardSize; j++) {
        allCells.add([i, j]);
      }
    }

    // Embaralhar a lista
    allCells.shuffle(_random);

    // Remover o número especificado de células
    for (int i = 0; i < count && i < allCells.length; i++) {
      int row = allCells[i][0];
      int col = allCells[i][1];

      board.setCell(row, col, 0);
      board.setCellEditable(row, col, true);
    }

    // Marcar as células preenchidas como não editáveis
    for (int i = 0; i < SudokuBoard.boardSize; i++) {
      for (int j = 0; j < SudokuBoard.boardSize; j++) {
        if (board.getCell(i, j) != 0) {
          board.setCellEditable(i, j, false);
        }
      }
    }
  }
}
