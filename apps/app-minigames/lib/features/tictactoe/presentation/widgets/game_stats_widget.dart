import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tictactoe_game_notifier.dart';

/// Widget that displays game statistics
class GameStatsWidget extends ConsumerWidget {
  final VoidCallback? onResetStats;

  const GameStatsWidget({
    super.key,
    this.onResetStats,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(ticTacToeStatsNotifierProvider);

    return statsAsync.when(
      data: (stats) => Column(
        children: [
          _buildStatRow(
            context,
            'Vitórias de X',
            stats.xWins.toString(),
            Icons.close,
            Colors.blue,
          ),
          const Divider(),
          _buildStatRow(
            context,
            'Vitórias de O',
            stats.oWins.toString(),
            Icons.circle_outlined,
            Colors.red,
          ),
          const Divider(),
          _buildStatRow(
            context,
            'Empates',
            stats.draws.toString(),
            Icons.remove,
            Colors.orange,
          ),
          const Divider(),
          _buildStatRow(
            context,
            'Total de Jogos',
            stats.totalGames.toString(),
            Icons.sports_esports,
            Colors.purple,
          ),
          if (stats.totalGames > 0) ...[
            const SizedBox(height: 16),
            Text(
              'Taxa de Vitória (X): ${(stats.xWinRate * 100).toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Taxa de Vitória (O): ${(stats.oWinRate * 100).toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          if (onResetStats != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Resetar Estatísticas'),
                    content: const Text(
                      'Tem certeza que deseja resetar todas as estatísticas? '
                      'Esta ação não pode ser desfeita.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onResetStats?.call();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Resetar'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Resetar Estatísticas'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        ],
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text(
          'Erro ao carregar estatísticas',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}
