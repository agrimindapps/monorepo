import 'package:flutter/material.dart';
import '../providers/home_provider.dart';

/// **Home Stats Section Component**
/// 
/// Displays comprehensive statistics about pets, appointments, vaccines, and medications.
/// Includes health status overview and detailed metrics.
class HomeStatsSection extends StatelessWidget {
  final HomeStatsState stats;

  const HomeStatsSection({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HealthStatusCard(stats: stats),
        const SizedBox(height: 16),
        _StatsOverview(stats: stats),
      ],
    );
  }
}

class _HealthStatusCard extends StatelessWidget {
  final HomeStatsState stats;

  const _HealthStatusCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final statusColor = stats.hasUrgentTasks 
        ? Theme.of(context).colorScheme.error 
        : Theme.of(context).colorScheme.primary;
    final statusIcon = stats.hasUrgentTasks ? Icons.warning : Icons.check_circle;

    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              statusColor.withOpacity(0.1),
              statusColor.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(statusIcon, color: statusColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status da Saúde',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      stats.healthStatus,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (stats.hasUrgentTasks)
                      Text(
                        '${stats.overdueItems + stats.todayTasks} tarefas precisam de atenção',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsOverview extends StatelessWidget {
  final HomeStatsState stats;

  const _StatsOverview({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Resumo das informações dos seus pets',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resumo Geral',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    label: 'Pets',
                    count: stats.totalAnimals,
                    icon: Icons.pets,
                  ),
                  _StatItem(
                    label: 'Consultas',
                    count: stats.upcomingAppointments,
                    icon: Icons.calendar_today,
                  ),
                  _StatItem(
                    label: 'Vacinas',
                    count: stats.pendingVaccinations,
                    icon: Icons.vaccines,
                  ),
                  _StatItem(
                    label: 'Remédios',
                    count: stats.activeMedications,
                    icon: Icons.medication,
                  ),
                ],
              ),
              if (stats.totalReminders > 0) ...[
                const SizedBox(height: 16),
                Divider(
                  height: 1,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                      label: 'Lembretes',
                      count: stats.totalReminders,
                      icon: Icons.notifications,
                    ),
                    if (stats.averageAge > 0)
                      _StatItem(
                        label: 'Idade Média',
                        count: stats.averageAge.round(),
                        icon: Icons.cake,
                        suffix: stats.averageAge > 12 ? 'a' : 'm',
                      ),
                    _StatItem(
                      label: 'Hoje',
                      count: stats.todayTasks,
                      icon: Icons.today,
                    ),
                    _StatItem(
                      label: 'Atrasados',
                      count: stats.overdueItems,
                      icon: Icons.warning,
                      color: stats.overdueItems > 0 
                        ? Theme.of(context).colorScheme.error 
                        : null,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final String? suffix;
  final Color? color;

  const _StatItem({
    required this.label,
    required this.count,
    required this.icon,
    this.suffix,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final displayText = suffix != null ? '$count$suffix' : count.toString();
    final iconColor = color ?? Theme.of(context).primaryColor;
    
    return Semantics(
      label: '$count $label',
      child: Column(
        children: [
          Icon(icon, size: 24, color: iconColor),
          const SizedBox(height: 4),
          Text(
            displayText,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}