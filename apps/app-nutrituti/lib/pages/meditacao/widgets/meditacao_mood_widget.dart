// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../providers/meditacao_provider.dart';

class MeditacaoMoodWidget extends ConsumerWidget {
  const MeditacaoMoodWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Como você se sente hoje?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _MoodButtonsRow(),
          ],
        ),
      ),
    );
  }
}

class _MoodButtonsRow extends ConsumerWidget {
  const _MoodButtonsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _MoodButton(emoji: '😊', mood: 'Calmo'),
        _MoodButton(emoji: '😌', mood: 'Relaxado'),
        _MoodButton(emoji: '😔', mood: 'Ansioso'),
        _MoodButton(emoji: '😤', mood: 'Estressado'),
      ],
    );
  }
}

class _MoodButton extends ConsumerWidget {
  final String emoji;
  final String mood;

  const _MoodButton({
    required this.emoji,
    required this.mood,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final humorSelecionado = ref.watch(
      meditacaoProvider.select((state) => state.humorSelecionado),
    );

    final isSelected = humorSelecionado == mood;

    return InkWell(
      onTap: () {
        ref.read(meditacaoProvider.notifier).selecionarHumor(mood);
      },
      child: Column(
        children: [
          Text(
            emoji,
            style: TextStyle(
              fontSize: 40,
              color: isSelected ? Colors.blue : null,
            ),
          ),
          Text(
            mood,
            style: TextStyle(
              color: isSelected ? Colors.blue : null,
              fontWeight: isSelected ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }
}
