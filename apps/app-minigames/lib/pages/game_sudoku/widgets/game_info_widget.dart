// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';
import 'package:app_minigames/models/game_logic.dart';

class GameInfoWidget extends StatelessWidget {
  final SudokuGameLogic gameLogic;
  final VoidCallback onDifficultyChanged;

  const GameInfoWidget({
    super.key,
    required this.gameLogic,
    required this.onDifficultyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildDifficultyInfo(),
          _buildTimer(),
          _buildHintsInfo(),
        ],
      ),
    );
  }

  Widget _buildDifficultyInfo() {
    return Row(
      children: [
        const Text(
          'Dificuldade: ',
          style: TextStyle(fontSize: 16),
        ),
        DropdownButton<DifficultyLevel>(
          value: gameLogic.difficulty,
          items: DifficultyLevel.values.map((level) {
            return DropdownMenuItem(
              value: level,
              child: Text(level.label),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null && !gameLogic.isGameStarted) {
              gameLogic.difficulty = newValue;
              onDifficultyChanged();
            }
          },
        ),
      ],
    );
  }

  Widget _buildTimer() {
    return Text(
      gameLogic.getFormattedTime(),
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildHintsInfo() {
    return Row(
      children: [
        const Icon(Icons.lightbulb_outline, size: 16),
        const SizedBox(width: 4),
        Text(
          '${gameLogic.hintsRemaining}',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
