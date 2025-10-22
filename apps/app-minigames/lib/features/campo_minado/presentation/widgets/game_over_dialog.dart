import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/enums.dart';
import '../providers/campo_minado_game_notifier.dart';

/// Dialog shown when game is over (won or lost)
class GameOverDialog extends ConsumerWidget {
  final GameStatus status;

  const GameOverDialog({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(campoMinadoGameNotifierProvider);
    final statsAsync = ref.watch(
      campoMinadoStatsProvider(gameState.difficulty),
    );

    final isWon = status == GameStatus.won;

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isWon ? Icons.emoji_events : Icons.sentiment_dissatisfied,
            color: isWon ? Colors.amber : Colors.red,
            size: 32,
          ),
          const SizedBox(width: 8),
          Text(
            isWon ? 'Vitória!' : 'Game Over!',
            style: TextStyle(
              color: isWon ? Colors.amber : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isWon
                ? 'Parabéns! Você encontrou todas as minas!'
                : 'Você acertou uma mina!',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _StatRow(
                  label: 'Tempo:',
                  value: gameState.formattedTime,
                ),
                const SizedBox(height: 8),
                _StatRow(
                  label: 'Dificuldade:',
                  value: gameState.difficulty.label,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          statsAsync.when(
            data: (stats) => Column(
              children: [
                const Text(
                  'Estatísticas',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                _StatRow(
                  label: 'Vitórias:',
                  value: '${stats.totalWins}/${stats.totalGames}',
                ),
                const SizedBox(height: 4),
                _StatRow(
                  label: 'Taxa de vitória:',
                  value: stats.winRatePercentage,
                ),
                const SizedBox(height: 4),
                _StatRow(
                  label: 'Melhor tempo:',
                  value: stats.formattedBestTime,
                ),
                const SizedBox(height: 4),
                _StatRow(
                  label: 'Sequência atual:',
                  value: '${stats.currentStreak}',
                ),
              ],
            ),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop(); // Return to home
          },
          child: const Text('Sair'),
        ),
        ElevatedButton(
          onPressed: () {
            ref.read(campoMinadoGameNotifierProvider.notifier).restartGame();
            Navigator.of(context).pop();
          },
          child: const Text('Jogar Novamente'),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
