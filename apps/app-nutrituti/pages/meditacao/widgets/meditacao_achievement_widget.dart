// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controllers/meditacao_controller.dart';

class MeditacaoAchievementWidget extends StatelessWidget {
  final MeditacaoController controller;

  const MeditacaoAchievementWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
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
            Obx(() => Column(
                  children: controller.conquistas.map((conquista) {
                    return ListTile(
                      leading: Icon(
                        _getIconData(conquista.icone),
                        color:
                            conquista.conquistado ? Colors.amber : Colors.grey,
                      ),
                      title: Text(conquista.titulo),
                      subtitle: Text(conquista.descricao),
                      trailing: conquista.conquistado
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.lock, color: Colors.grey),
                    );
                  }).toList(),
                )),
          ],
        ),
      ),
    );
  }

  // Converter string de ícone para IconData
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
