// Flutter imports:
// Package imports:
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_calculei/pages/calc/financeiro/independencia_financeira/widgets/controllers/independencia_financeira_controller.dart';

class GraficoEvolucaoWidget extends StatelessWidget {
  final IndependenciaFinanceiraController controller;

  const GraficoEvolucaoWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.modelo == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Evolução do Patrimônio',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 300,
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 16.0, bottom: 4.0),
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) {
                        if (value % 1000000 == 0 && value > 0) {
                          return Text('${(value / 1000000).toInt()}M');
                        } else if (value % 100000 == 0 && value > 0) {
                          return Text(
                              '${(value / 1000000).toStringAsFixed(1)}M');
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value % 5 == 0 ||
                            value ==
                                controller.modelo!.anosParaIndependencia
                                    .toDouble()) {
                          return Text(value.toInt().toString());
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: controller.modelo!.pontosGrafico,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withValues(alpha: 0.2),
                    ),
                  ),
                  if (controller.modelo!.patrimonioAlvo > 0)
                    LineChartBarData(
                      spots: [
                        FlSpot(0, controller.modelo!.patrimonioAlvo),
                        FlSpot(
                          controller.modelo!.anosParaIndependencia.toDouble() +
                              5,
                          controller.modelo!.patrimonioAlvo,
                        ),
                      ],
                      isCurved: false,
                      color: Colors.red,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      dashArray: [5, 5],
                    ),
                ],
                borderData: FlBorderData(show: true),
              ),
            ),
          ),
        ),
        const Center(
          child: Text(
            'Anos',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
