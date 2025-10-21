// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../providers/meditacao_provider.dart';

class MeditacaoAchievementWidget extends ConsumerWidget {
  const MeditacaoAchievementWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conquistas = ref.watch(
      meditacaoNotifierProvider.select((state) => state.conquistas),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Conquistas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Column(
              children: conquistas.map((conquista) {
                return ListTile(
                  leading: Icon(
                    _getIconData(conquista.icone),
                    color: conquista.conquistado ? Colors.amber : Colors.grey,
                  ),
                  title: Text(conquista.titulo),
                  subtitle: Text(conquista.descricao),
                  trailing: conquista.conquistado
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.lock, color: Colors.grey),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Convert icon string to IconData
  IconData _getIconData(String icone) {
    switch (icone) {
      case 'self_improvement':
        return Icons.self_improvement;
      case 'date_range':
        return Icons.date_range;
      case 'hourglass_full':
        return Icons.hourglass_full;
      case 'explore':
        return Icons.explore;
      default:
        return Icons.emoji_events;
    }
  }
}
