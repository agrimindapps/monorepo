import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/achievement.dart';
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
    final gameState = ref.watch(campoMinadoGameProvider);
    final statsAsync = ref.watch(
      campoMinadoStatsProvider(gameState.difficulty),
    );
    final newAchievements =
        ref.read(campoMinadoGameProvider.notifier).newlyUnlockedAchievements;

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
      content: SingleChildScrollView(
        child: Column(
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
            // Show newly unlocked achievements
            if (newAchievements.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildNewAchievements(context, newAchievements),
            ],
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
      ),
      actions: [
        TextButton(
          onPressed: () {
            ref.read(campoMinadoGameProvider.notifier).clearNewlyUnlockedAchievements();
            Navigator.of(context).pop();
            context.go('/'); // Return to home using go_router
          },
          child: const Text('Sair'),
        ),
        ElevatedButton(
          onPressed: () {
            ref.read(campoMinadoGameProvider.notifier).clearNewlyUnlockedAchievements();
            ref.read(campoMinadoGameProvider.notifier).restartGame();
            Navigator.of(context).pop();
          },
          child: const Text('Jogar Novamente'),
        ),
      ],
    );
  }

  Widget _buildNewAchievements(
    BuildContext context,
    List<CampoMinadoAchievementDefinition> achievements,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withOpacity(0.2),
            Colors.orange.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                achievements.length == 1
                    ? 'Nova Conquista!'
                    : '${achievements.length} Novas Conquistas!',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...achievements.map((achievement) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text(achievement.emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            achievement.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            achievement.description,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: achievement.rarity.color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '+${achievement.rarity.xpReward}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
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
