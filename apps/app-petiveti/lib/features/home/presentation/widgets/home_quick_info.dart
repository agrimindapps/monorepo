import 'package:flutter/material.dart';
import '../providers/home_providers.dart';

/// **Home Quick Info Section**
/// 
/// Displays quick access information like next appointment, vaccination,
/// and species breakdown for immediate user insights.
class HomeQuickInfo extends StatelessWidget {
  final HomeStatsState stats;

  const HomeQuickInfo({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    if (stats.totalAnimals == 0) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Próximas atividades',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _UpcomingActivities(stats: stats),
        if (stats.speciesBreakdown.isNotEmpty) ...[
          const SizedBox(height: 12),
          _SpeciesBreakdown(stats: stats),
        ],
      ],
    );
  }
}

class _UpcomingActivities extends StatelessWidget {
  final HomeStatsState stats;

  const _UpcomingActivities({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActivityCard(
            icon: Icons.calendar_today,
            color: Theme.of(context).colorScheme.primary,
            title: 'Próxima Consulta',
            content: stats.nextAppointment ?? 'Nenhuma agendada',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActivityCard(
            icon: Icons.vaccines,
            color: Theme.of(context).colorScheme.secondary,
            title: 'Próxima Vacina',
            content: stats.nextVaccination ?? 'Nenhuma pendente',
          ),
        ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String content;

  const _ActivityCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              content,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _SpeciesBreakdown extends StatelessWidget {
  final HomeStatsState stats;

  const _SpeciesBreakdown({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seus pets por espécie',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: stats.speciesBreakdown.entries
                  .map((entry) => Chip(
                        label: Text('${entry.key}: ${entry.value}'),
                        labelStyle: Theme.of(context).textTheme.bodySmall,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
