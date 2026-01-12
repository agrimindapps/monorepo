import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/game_page_layout.dart';
import '../providers/space_invaders_data_providers.dart';

class SpaceInvadersHighScoresPage extends ConsumerWidget {
  const SpaceInvadersHighScoresPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoresAsync = ref.watch(spaceInvadersHighScoresProvider);
    final statsAsync = ref.watch(spaceInvadersStatsProvider);

    return GamePageLayout(
      title: 'High Scores - Space Invaders',
      accentColor: const Color(0xFF4CAF50),
      maxGameWidth: 600,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            statsAsync.when(
              data: (stats) => Card(
                color: Colors.black.withValues(alpha: 0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(label: 'Jogos', value: '${stats.totalGames}'),
                      _StatItem(label: 'Melhor Score', value: '${stats.highestScore}'),
                      _StatItem(label: 'Invasores', value: '${stats.totalInvadersKilled}'),
                      _StatItem(label: 'Wave Máximo', value: '${stats.highestWave}'),
                    ],
                  ),
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: scoresAsync.when(
                data: (scores) {
                  if (scores.isEmpty) {
                    return Center(
                      child: Text(
                        'Nenhum score ainda',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 18),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: scores.length,
                    itemBuilder: (context, index) {
                      final score = scores[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: Colors.black.withValues(alpha: 0.3),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                            child: Text('#${index + 1}', style: const TextStyle(color: Colors.white)),
                          ),
                          title: Text(
                            'Score: ${score.score}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Wave ${score.wave} • ${score.invadersKilled} invasores • ${score.formattedDuration}',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete_outline, color: Colors.white.withValues(alpha: 0.5)),
                            onPressed: () async {
                              final deleter = ref.read(spaceInvadersScoreDeleterProvider.notifier);
                              await deleter.deleteScore(score.id);
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50))),
                error: (error, _) => Center(child: Text('Erro: $error', style: const TextStyle(color: Colors.red))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Color(0xFF4CAF50), fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
      ],
    );
  }
}
