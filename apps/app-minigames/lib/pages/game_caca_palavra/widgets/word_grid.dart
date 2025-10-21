// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/constants/layout.dart';
import 'package:app_minigames/models/game_logic.dart';
import 'package:app_minigames/models/position.dart';
import 'grid_cell.dart';

class WordGridWidget extends StatelessWidget {
  final CacaPalavrasLogic gameLogic;
  final Function(int row, int col) onCellTap;

  const WordGridWidget({
    super.key,
    required this.gameLogic,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    // Pré-calcular as células que fazem parte de palavras encontradas
    // para evitar repetir essa verificação para cada célula
    final Map<Position, bool> foundCells = {};

    for (final word in gameLogic.words) {
      if (word.isFound) {
        for (final position in word.positions) {
          foundCells[position] = true;
        }
      }
    }

    return AspectRatio(
      aspectRatio: GameLayout.gridAspectRatio,
      child: Container(
        decoration: GameLayout.gridDecoration,
        child: Padding(
          padding: GameLayout.gridPadding,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gameLogic.gridSize,
              childAspectRatio: 1.0,
            ),
            itemCount: gameLogic.gridSize * gameLogic.gridSize,
            itemBuilder: (context, index) {
              final row = index ~/ gameLogic.gridSize;
              final col = index % gameLogic.gridSize;
              final letter = gameLogic.grid[row][col];
              final pos = Position(row, col);

              // Verifica se esta célula está selecionada
              final isSelected = gameLogic.selectedPositions.contains(pos);

              // Verifica se esta célula faz parte de uma palavra encontrada
              // usando o mapa pré-calculado
              final isFoundWord = foundCells[pos] ?? false;

              return GridCellWidget(
                letter: letter,
                row: row,
                col: col,
                isSelected: isSelected,
                isFoundWord: isFoundWord,
                onTap: () => onCellTap(row, col),
              );
            },
          ),
        ),
      ),
    );
  }
}
