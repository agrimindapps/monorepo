// Flutter imports:
// Package imports:
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../../core/style/shadcn_style.dart';
import 'pluviometria_models.dart';

class GraficoMensalWidget extends StatelessWidget {
  final List<DadoPluviometrico> dados;

  const GraficoMensalWidget({
    super.key,
    required this.dados,
  });

  @override
  Widget build(BuildContext context) {
    final maxY = dados.isNotEmpty
        ? dados.map((e) => e.valor).reduce((a, b) => a > b ? a : b) * 1.2
        : 100.0;

    return Column(
      children: [
        Container(
          height: 280,
          decoration: BoxDecoration(
            color: ShadcnStyle.surfaceColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: ShadcnStyle.borderColor),
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey[300],
                    strokeWidth: 1,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: Colors.grey[200],
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() % 5 == 0 ||
                          value.toInt() == dados.length - 1) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            dados[value.toInt()].label,
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                    reservedSize: 40,
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(color: Colors.grey[400]!, width: 1),
                  left: BorderSide(color: Colors.grey[400]!, width: 1),
                ),
              ),
              minX: 0,
              maxX: dados.length - 1.0,
              minY: 0,
              maxY: maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: dados.asMap().entries.map((entry) {
                    return FlSpot(entry.key.toDouble(), entry.value.valor);
                  }).toList(),
                  isCurved: false,
                  color: ShadcnStyle.chartLineColor,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: ShadcnStyle.chartLineColor,
                        strokeWidth: 1,
                        strokeColor: ShadcnStyle.backgroundColor,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: ShadcnStyle.chartAreaColor,
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                    return touchedBarSpots.map((barSpot) {
                      final index = barSpot.x.toInt();
                      return LineTooltipItem(
                        'Dia ${dados[index].label}: ${dados[index].valor.toStringAsFixed(1)} mm',
                        const TextStyle(color: Colors.white),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Precipitação diária (mm)',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
