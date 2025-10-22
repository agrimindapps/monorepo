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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Game Mode selector
            Text(
              'Modo de Jogo',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<GameMode>(
              segments: const [
                ButtonSegment(
                  value: GameMode.vsPlayer,
                  label: Text('2 Jogadores'),
                  icon: Icon(Icons.people),
                ),
                ButtonSegment(
                  value: GameMode.vsComputer,
                  label: Text('vs Computador'),
                  icon: Icon(Icons.computer),
                ),
              ],
              selected: {gameState.gameMode},
              onSelectionChanged: (Set<GameMode> newSelection) {
                onGameModeChanged(newSelection.first);
              },
            ),

            // Difficulty selector (only for vsComputer mode)
            if (gameState.gameMode == GameMode.vsComputer) ...[
              const SizedBox(height: 16),
              Text(
                'Dificuldade',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
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
              ),
            ],

            // Restart button
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onRestart,
                icon: const Icon(Icons.refresh),
                label: const Text('Reiniciar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
