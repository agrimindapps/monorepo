// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controllers/meditacao_controller.dart';

class MeditacaoMoodWidget extends StatelessWidget {
  final MeditacaoController controller;

  const MeditacaoMoodWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Como você se sente hoje?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _moodButton('😊', 'Calmo'),
                _moodButton('😌', 'Relaxado'),
                _moodButton('😔', 'Ansioso'),
                _moodButton('😤', 'Estressado'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _moodButton(String emoji, String mood) {
    return Obx(() => InkWell(
          onTap: () => controller.selecionarHumor(mood),
          child: Column(
            children: [
              Text(
                emoji,
                style: TextStyle(
                  fontSize: 40,
                  color: controller.humorSelecionado.value == mood
                      ? Colors.blue
                      : null,
                ),
              ),
              Text(
                mood,
                style: TextStyle(
                  color: controller.humorSelecionado.value == mood
                      ? Colors.blue
                      : null,
                  fontWeight: controller.humorSelecionado.value == mood
                      ? FontWeight.bold
                      : null,
                ),
              ),
            ],
          ),
        ));
  }
}
