import 'package:flutter/material.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/enums.dart';

/// Widget for game controls (mode, difficulty, restart)
class GameControlsWidget extends StatelessWidget {
  final GameState gameState;
  final Function(GameMode) onGameModeChanged;
  final Function(Difficulty) onDifficultyChanged;
  final VoidCallback onRestart;

  const GameControlsWidget({
    super.key,
    required this.gameState,
    required this.onGameModeChanged,
    required this.onDifficultyChanged,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Game Mode selector
        SegmentedButton<GameMode>(
          segments: const [
            ButtonSegment(
              value: GameMode.vsPlayer,
              label: Text('2 Jogadores'),
              icon: Icon(Icons.people),
            ),
            ButtonSegment(
              value: GameMode.vsComputer,
              label: Text('vs CPU'),
              icon: Icon(Icons.computer),
            ),
          ],
          selected: {gameState.gameMode},
          onSelectionChanged: (Set<GameMode> newSelection) {
            onGameModeChanged(newSelection.first);
          },
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            side: WidgetStateProperty.all(
              BorderSide(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.2)),
            ),
          ),
        ),

        // Difficulty selector (only for vsComputer mode)
        if (gameState.gameMode == GameMode.vsComputer) ...[
          const SizedBox(height: 12),
          SegmentedButton<Difficulty>(
            segments: const [
              ButtonSegment(
                value: Difficulty.easy,
                label: Text('Fácil'),
              ),
              ButtonSegment(
                value: Difficulty.medium,
                label: Text('Médio'),
              ),
              ButtonSegment(
                value: Difficulty.hard,
                label: Text('Difícil'),
              ),
            ],
            selected: {gameState.difficulty},
            onSelectionChanged: (Set<Difficulty> newSelection) {
              onDifficultyChanged(newSelection.first);
            },
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: WidgetStateProperty.all(
                BorderSide(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.2)),
              ),
            ),
          ),
        ],

        // Restart button
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onRestart,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Reiniciar Jogo'),
          style: OutlinedButton.styleFrom(
            visualDensity: VisualDensity.compact,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }
}
