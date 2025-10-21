// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../providers/meditacao_provider.dart';

class MeditacaoTiposWidget extends ConsumerWidget {
  const MeditacaoTiposWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tipos de Meditação',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _MeditationTypesGrid(),
          ],
        ),
      ),
    );
  }
}

class _MeditationTypesGrid extends ConsumerWidget {
  const _MeditationTypesGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _MeditationTypeCard(
          title: 'Respiração',
          description: 'Foco na respiração para acalmar a mente',
          icon: Icons.air,
        ),
        _MeditationTypeCard(
          title: 'Corpo',
          description: 'Consciência corporal e relaxamento',
          icon: Icons.accessibility_new,
        ),
        _MeditationTypeCard(
          title: 'Gratidão',
          description: 'Cultive gratidão e positividade',
          icon: Icons.favorite,
        ),
        _MeditationTypeCard(
          title: 'Sono',
          description: 'Relaxe para um sono tranquilo',
          icon: Icons.bedtime,
        ),
      ],
    );
  }
}

class _MeditationTypeCard extends ConsumerWidget {
  final String title;
  final String description;
  final IconData icon;

  const _MeditationTypeCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tipoMeditacaoAtual = ref.watch(
      meditacaoNotifierProvider.select((state) => state.tipoMeditacaoAtual),
    );

    final isSelected = tipoMeditacaoAtual == title;

    return Card(
      color: isSelected ? Colors.blue.withValues(alpha: 0.1) : null,
      child: InkWell(
        onTap: () {
          ref.read(meditacaoNotifierProvider.notifier).iniciarTipoMeditacao(title);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                icon,
                size: 40,
                color: isSelected ? Colors.blue : null,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.blue : null,
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
    );
  }
}
