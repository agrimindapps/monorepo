// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../providers/meditacao_provider.dart';

class MeditacaoProgressChartWidget extends ConsumerWidget {
  const MeditacaoProgressChartWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get chart data using notifier method
    final dadosGrafico = ref
        .read(meditacaoProvider.notifier)
        .getDadosGrafico();

    // If not enough data, show message
    if (dadosGrafico.length < 2) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Seu Progresso ao Longo do Tempo',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    'Complete mais sessões para visualizar seu progresso.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Prepare data for chart
    final spots = _prepareDataForChart(dadosGrafico);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seu Progresso ao Longo do Tempo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildLineChart(spots, context),
            ),
          ],
        ),
      ),
    );
  }

  // Convert Map<DateTime, int> to List<FlSpot>
  List<FlSpot> _prepareDataForChart(Map<DateTime, int> dados) {
    // Sort dates
    final datas = dados.keys.toList()..sort();

    // If no dates, return empty list
    if (datas.isEmpty) return [];

    // Reference date (first date)
    final primeiraData = datas.first;

    // Convert to FlSpot
    return datas.map((data) {
      // X = days since first session
      final x = data.difference(primeiraData).inDays.toDouble();
      // Y = meditation minutes
      final y = dados[data]!.toDouble();

      return FlSpot(x, y);
    }).toList();
  }

  // Build line chart
  Widget _buildLineChart(List<FlSpot> spots, BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(
          show: true,
          drawVerticalLine: true,
          drawHorizontalLine: true,
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: const Text('Dias'),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                // Show only integers
                if (value == value.toInt()) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(value.toInt().toString()),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: const Text('Minutos'),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(value.toInt().toString()),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Theme.of(context).primaryColor,
            barWidth: 3,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
            ),
            dotData: const FlDotData(
              show: true,
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((touchedSpot) {
                return LineTooltipItem(
                  '${touchedSpot.y.toInt()} min',
                  const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
