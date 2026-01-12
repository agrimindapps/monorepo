import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/game_page_layout.dart';
import '../providers/reversi_data_providers.dart';

class ReversiHighScoresPage extends ConsumerWidget {
  const ReversiHighScoresPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoresAsync = ref.watch(reversiHighScoresProvider);
    final statsAsync = ref.watch(reversiStatsProvider);

    return GamePageLayout(
      title: 'High Scores - Reversi',
      accentColor: const Color(0xFF2E7D32),
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
                  child: Column(
                    children: [
                      Text(
                        'Estatísticas',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(label: 'Jogos', value: '${stats.totalGames}'),
                          _StatItem(label: '⚫ Vitórias', value: '${stats.blackWins}'),
                          _StatItem(label: '⚪ Vitórias', value: '${stats.whiteWins}'),
                          _StatItem(label: 'Empates', value: '${stats.draws}'),
                        ],
                      ),
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.emoji_events_outlined,
                            size: 64,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum score ainda',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: scores.length,
                    itemBuilder: (context, index) {
                      final score = scores[index];
                      final rank = index + 1;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: Colors.black.withValues(alpha: 0.3),
                        child: ListTile(
                          leading: _RankBadge(rank: rank),
                          title: Row(
                            children: [
                              Text(
                                '${score.winnerName} venceu',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '+${score.scoreDifference}',
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            '${score.blackCount}-${score.whiteCount} • ${score.moves} jogadas • ${score.formattedDuration} • ${score.formattedDate}',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete_outline, color: Colors.white.withValues(alpha: 0.5)),
                            onPressed: () => _confirmDelete(context, ref, score.id),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32))),
                error: (error, _) => Center(child: Text('Erro: $error', style: const TextStyle(color: Colors.red))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, String scoreId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Score'),
        content: const Text('Deseja realmente excluir este score?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final deleter = ref.read(reversiScoreDeleterProvider.notifier);
      await deleter.deleteScore(scoreId);
    }
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
        Text(value, style: const TextStyle(color: Color(0xFF2E7D32), fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
      ],
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;

  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    if (rank == 1) {
      color = const Color(0xFFFFD700);
      icon = Icons.looks_one;
    } else if (rank == 2) {
      color = const Color(0xFFC0C0C0);
      icon = Icons.looks_two;
    } else if (rank == 3) {
      color = const Color(0xFFCD7F32);
      icon = Icons.looks_3;
    } else {
      return CircleAvatar(
        backgroundColor: Colors.white.withValues(alpha: 0.2),
        child: Text('$rank', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontWeight: FontWeight.bold)),
      );
    }

    return CircleAvatar(backgroundColor: color.withValues(alpha: 0.3), child: Icon(icon, color: color));
  }
}
