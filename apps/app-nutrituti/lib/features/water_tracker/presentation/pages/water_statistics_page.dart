import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/water_tracker_providers.dart';
import '../widgets/weekly_chart.dart';

/// Statistics page with detailed insights
class WaterStatisticsPage extends ConsumerWidget {
  const WaterStatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statisticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Estatísticas'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(statisticsProvider);
          ref.invalidate(weeklyChartDataProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: statsAsync.when(
            data: (stats) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview Cards
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Média Semanal',
                        value: '${(stats.weeklyAverageMl / 1000).toStringAsFixed(1)}L',
                        icon: Icons.calendar_today,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Média Mensal',
                        value: '${(stats.monthlyAverageMl / 1000).toStringAsFixed(1)}L',
                        icon: Icons.date_range,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Sequência Atual',
                        value: '${stats.currentStreak} dias',
                        icon: Icons.local_fire_department,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Melhor Sequência',
                        value: '${stats.bestStreak} dias',
                        icon: Icons.emoji_events,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Weekly Chart
                const WeeklyChart(),

                const SizedBox(height: 24),

                // Detailed Stats
                _DetailedStatsCard(stats: stats),

                const SizedBox(height: 24),

                // Insights
                _InsightsCard(stats: stats),

                const SizedBox(height: 24),

                // Trend Indicator
                _TrendCard(stats: stats),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erro: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(statisticsProvider),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailedStatsCard extends StatelessWidget {
  final dynamic stats;

  const _DetailedStatsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estatísticas Detalhadas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _StatRow(
              label: 'Total de registros',
              value: '${stats.totalRecordsCount}',
              icon: Icons.list,
            ),
            const Divider(),
            _StatRow(
              label: 'Dias monitorados',
              value: '${stats.totalDaysTracked}',
              icon: Icons.calendar_month,
            ),
            const Divider(),
            _StatRow(
              label: 'Dias com meta atingida',
              value: '${stats.daysGoalAchieved}',
              icon: Icons.check_circle,
            ),
            const Divider(),
            _StatRow(
              label: 'Taxa de sucesso',
              value: '${stats.achievementRate.toStringAsFixed(1)}%',
              icon: Icons.percent,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Text(label),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _InsightsCard extends StatelessWidget {
  final dynamic stats;

  const _InsightsCard({required this.stats});

  List<String> _generateInsights() {
    final insights = <String>[];

    if (stats.achievementRate >= 80) {
      insights.add('🌟 Excelente! Você está atingindo sua meta na maioria dos dias.');
    } else if (stats.achievementRate >= 50) {
      insights.add('💪 Bom progresso! Continue se esforçando para melhorar.');
    } else {
      insights.add('📈 Tente criar uma rotina para beber água regularmente.');
    }

    if (stats.currentStreak > 0) {
      insights.add('🔥 Mantenha sua sequência de ${stats.currentStreak} dias!');
    }

    if (stats.weeklyAverageMl < 1500) {
      insights.add('💧 Sua média semanal está baixa. Tente aumentar gradualmente.');
    } else if (stats.weeklyAverageMl >= 2000) {
      insights.add('💦 Ótima hidratação! Sua média semanal está excelente.');
    }

    if (stats.weekOverWeekChange > 10) {
      insights.add('📊 Seu consumo aumentou ${stats.weekOverWeekChange.toStringAsFixed(0)}% esta semana!');
    } else if (stats.weekOverWeekChange < -10) {
      insights.add('⚠️ Seu consumo diminuiu ${(stats.weekOverWeekChange * -1).toStringAsFixed(0)}% esta semana.');
    }

    return insights;
  }

  @override
  Widget build(BuildContext context) {
    final insights = _generateInsights();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  'Insights',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...insights.map((insight) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      insight,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  final dynamic stats;

  const _TrendCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final trend = stats.trend;
    final change = stats.weekOverWeekChange;

    IconData icon;
    Color color;
    String message;

    if (trend > 0) {
      icon = Icons.trending_up;
      color = Colors.green;
      message = 'Em alta! +${change.toStringAsFixed(1)}%';
    } else if (trend < 0) {
      icon = Icons.trending_down;
      color = Colors.red;
      message = 'Em queda ${change.toStringAsFixed(1)}%';
    } else {
      icon = Icons.trending_flat;
      color = Colors.grey;
      message = 'Estável';
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tendência Semanal',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Comparado à semana anterior',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
