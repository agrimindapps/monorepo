// Flutter imports:
// Package imports:
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Project imports:
import '../controllers/meditacao_controller.dart';

class MeditacaoProgressChartWidget extends StatelessWidget {
  final MeditacaoController controller;

  const MeditacaoProgressChartWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Obter dados para o gráfico
      final dadosGrafico = controller.getDadosGrafico();

      // Se não houver dados suficientes, mostrar mensagem
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

      // Preparar dados para o gráfico de linha
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
    });
  }

  // Converter Map<DateTime, int> para List<FlSpot>
  List<FlSpot> _prepareDataForChart(Map<DateTime, int> dados) {
    // Ordenar as datas
    final datas = dados.keys.toList()..sort();

    // Se não houver datas, retornar lista vazia
    if (datas.isEmpty) return [];

    // Data de referência (primeira data)
    final primeiraData = datas.first;

    // Converter para FlSpot
    return datas.map((data) {
      // X = dias desde a primeira sessão
      final x = data.difference(primeiraData).inDays.toDouble();
      // Y = minutos de meditação
      final y = dados[data]!.toDouble();

      return FlSpot(x, y);
    }).toList();
  }

  // Construir o gráfico de linha
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
                // Mostrar apenas números inteiros
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
