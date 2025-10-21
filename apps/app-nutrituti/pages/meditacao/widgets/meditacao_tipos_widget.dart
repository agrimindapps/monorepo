// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controllers/meditacao_controller.dart';

class MeditacaoTiposWidget extends StatelessWidget {
  final MeditacaoController controller;

  const MeditacaoTiposWidget({
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
              'Tipos de Meditação',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _meditationTypeCard(
                  'Respiração',
                  'Foco na respiração para acalmar a mente',
                  Icons.air,
                  context,
                ),
                _meditationTypeCard(
                  'Corpo',
                  'Consciência corporal e relaxamento',
                  Icons.accessibility_new,
                  context,
                ),
                _meditationTypeCard(
                  'Gratidão',
                  'Cultive gratidão e positividade',
                  Icons.favorite,
                  context,
                ),
                _meditationTypeCard(
                  'Sono',
                  'Relaxe para um sono tranquilo',
                  Icons.bedtime,
                  context,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _meditationTypeCard(
    String title,
    String description,
    IconData icon,
    BuildContext context,
  ) {
    return Obx(() => Card(
          color: controller.tipoMeditacaoAtual.value == title
              ? Colors.blue.withValues(alpha: 0.1)
              : null,
          child: InkWell(
            onTap: () => controller.iniciarTipoMeditacao(title),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    icon,
                    size: 40,
                    color: controller.tipoMeditacaoAtual.value == title
                        ? Colors.blue
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: controller.tipoMeditacaoAtual.value == title
                          ? Colors.blue
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
