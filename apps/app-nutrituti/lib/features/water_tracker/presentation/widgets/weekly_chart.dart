import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/water_tracker_providers.dart';

/// Weekly bar chart showing water intake history
class WeeklyChart extends ConsumerWidget {
  const WeeklyChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartDataAsync = ref.watch(weeklyChartDataProvider);
    final goalAsync = ref.watch(waterGoalProvider);

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
                Icon(Icons.bar_chart, size: 20),
                SizedBox(width: 8),
                Text(
                  'Últimos 7 dias',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: chartDataAsync.when(
                data: (data) => goalAsync.when(
                  data: (goal) => _buildChart(context, data, goal.effectiveGoalMl),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => _buildChart(context, data, 2000),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(child: Text('Erro ao carregar dados')),
              ),
            ),
            const SizedBox(height: 12),
            _buildLegend(context),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(
    BuildContext context,
    List<MapEntry<DateTime, int>> data,
    int goalMl,
  ) {
    final maxY = data.isEmpty
        ? goalMl * 1.2
        : [data.map((e) => e.value.toDouble()).reduce((a, b) => a > b ? a : b), goalMl.toDouble()]
            .reduce((a, b) => a > b ? a : b) * 1.2;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => Colors.blueGrey[800]!,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final value = rod.toY.toInt();
              final date = data[groupIndex].key;
              return BarTooltipItem(
                '${DateFormat('dd/MM').format(date)}\n$value ml',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value < 0 || value >= data.length) return const SizedBox.shrink();
                final date = data[value.toInt()].key;
                final dayName = DateFormat('E', 'pt_BR').format(date).substring(0, 3);
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    dayName,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    '${(value / 1000).toStringAsFixed(1)}L',
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: goalMl.toDouble(),
              color: Colors.red.withValues(alpha: 0.5),
              strokeWidth: 2,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                labelResolver: (_) => 'Meta',
                style: TextStyle(
                  color: Colors.red.withValues(alpha: 0.7),
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey[200]!,
            strokeWidth: 1,
          ),
        ),
        barGroups: data.asMap().entries.map((entry) {
          final index = entry.key;
          final value = entry.value.value;
          final reachedGoal = value >= goalMl;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: value.toDouble(),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: reachedGoal
                      ? [
                          const Color(0xFF4FC3F7),
                          const Color(0xFF29B6F6),
                        ]
                      : [
                          Colors.grey[300]!,
                          Colors.grey[400]!,
                        ],
                ),
                width: 24,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(
          color: const Color(0xFF29B6F6),
          label: 'Meta atingida',
        ),
        const SizedBox(width: 24),
        _LegendItem(
          color: Colors.grey[400]!,
          label: 'Meta não atingida',
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
