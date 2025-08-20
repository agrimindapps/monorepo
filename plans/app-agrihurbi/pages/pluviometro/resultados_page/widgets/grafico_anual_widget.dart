// Flutter imports:
// Package imports:
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../../core/style/shadcn_style.dart';
import 'pluviometria_models.dart';

class GraficoAnualWidget extends StatelessWidget {
  final List<DadoPluviometrico> dados;

  const GraficoAnualWidget({
    super.key,
    required this.dados,
  });

  @override
  Widget build(BuildContext context) {
    final maxY = dados.isNotEmpty
        ? dados.map((e) => e.valor).reduce((a, b) => a > b ? a : b) * 1.2
        : 100.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 280,
          decoration: BoxDecoration(
            color: ShadcnStyle.surfaceColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: ShadcnStyle.borderColor),
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${dados[groupIndex].label}: ${dados[groupIndex].valor.toStringAsFixed(1)} mm',
                      const TextStyle(color: Colors.white),
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
                      if (value >= 0 && value < dados.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            dados[value.toInt()].label,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
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
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey[300],
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(color: ShadcnStyle.borderColor),
                  left: BorderSide(color: ShadcnStyle.borderColor),
                ),
              ),
              barGroups: dados.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: data.valor,
                      color: ShadcnStyle.chartBarColor,
                      width: 16,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Precipitação mensal (mm)',
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
