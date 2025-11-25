// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../controllers/agua_controller.dart';

class AguaAchievementCard extends ConsumerWidget {
  const AguaAchievementCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aguaAsync = ref.watch(aguaProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Conquistas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            aguaAsync.when(
              data: (state) {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: state.achievements
                      .map((achievement) => Tooltip(
                            message: achievement.description,
                            child: Chip(
                              avatar: Text(achievement.title.split(' ')[0]),
                              label: Text(achievement.title.split(' ')[1]),
                              backgroundColor: achievement.isUnlocked
                                  ? Colors.blue[100]
                                  : Colors.grey[300],
                            ),
                          ))
                      .toList(),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Erro ao carregar conquistas'),
            ),
          ],
        ),
      ),
    );
  }
}
