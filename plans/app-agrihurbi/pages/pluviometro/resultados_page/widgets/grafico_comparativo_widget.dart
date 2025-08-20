// Dart imports:
import 'dart:math' as math;

// Package imports:
import 'package:fl_chart/fl_chart.dart';
// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../../core/style/shadcn_style.dart';
import 'pluviometria_models.dart';

class GraficoComparativoWidget extends StatelessWidget {
  final List<DadoComparativo> dados;
  final int anoSelecionado;

  const GraficoComparativoWidget({
    super.key,
    required this.dados,
    required this.anoSelecionado,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 16),
        const Text(
          'Comparativo com o Ano Anterior',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 280,
          decoration: BoxDecoration(
            color: ShadcnStyle.surfaceColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: ShadcnStyle.borderColor),
          ),
          padding: const EdgeInsets.all(16),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: dados.fold(
                      0.0,
                      (max, item) => math.max(
                            max,
                            math.max(item.valorAtual, item.valorAnterior),
                          )) *
                  1.2,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final item = dados[groupIndex];
                    final ano = anoSelecionado - (rodIndex == 0 ? 0 : 1);
                    return BarTooltipItem(
                      '${item.label} $ano: ${rodIndex == 0 ? item.valorAtual : item.valorAnterior} mm',
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
                            style: const TextStyle(fontSize: 11),
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
                show: false,
              ),
              barGroups: dados.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: data.valorAtual,
                      color: ShadcnStyle.chartBarColor,
                      width: 10,
                    ),
                    BarChartRodData(
                      toY: data.valorAnterior,
                      color: ShadcnStyle.labelColor,
                      width: 10,
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
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendaItem(ShadcnStyle.chartBarColor, '$anoSelecionado'),
            const SizedBox(width: 24),
            _buildLegendaItem(
                ShadcnStyle.labelColor ?? Colors.grey, '${anoSelecionado - 1}'),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendaItem(Color cor, String texto) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: cor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(texto),
      ],
    );
  }
}
