// Flutter imports:
// Package imports:
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// Project imports:
import '../../controllers/dashboard_controller.dart';
import '../../services/chart_data_service.dart';
import '../../utils/dashboard_constants.dart';
import '../../utils/dashboard_helpers.dart';

class WeightChartWidget extends StatelessWidget {
  final DashboardController controller;

  const WeightChartWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (!controller.hasSelectedPet || controller.historicoPeso.isEmpty) {
      return _buildEmptyState();
    }

    final historicoPeso = controller.historicoPeso;
    final minPeso = ChartDataService.calculateMinWeight(historicoPeso);
    final maxPeso = ChartDataService.calculateMaxWeight(historicoPeso);

    return Card(
      elevation: DashboardConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: DashboardHelpers.getCardBorderRadius(),
      ),
      child: Padding(
        padding: DashboardHelpers.getCardPadding(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            SizedBox(
              height: DashboardConstants.weightChartHeight,
              child: LineChart(
                _buildLineChartData(historicoPeso, minPeso, maxPeso),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Histórico de Peso',
              style: DashboardHelpers.getCardTitleStyle(context),
            ),
            Text(
              'Últimos 6 meses',
              style: DashboardHelpers.getCardSubtitleStyle(context),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Peso Atual: ${controller.selectedPet?.peso} kg',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
        ),
      ],
    );
  }

  LineChartData _buildLineChartData(
    List<dynamic> historicoPeso,
    double minPeso,
    double maxPeso,
  ) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey[300],
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
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              final label = ChartDataService.formatWeightChartLabel(
                value,
                controller.historicoPeso,
              );
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: 1,
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toInt()} kg',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
          left: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      minX: 0,
      maxX: historicoPeso.length - 1.0,
      minY: minPeso,
      maxY: maxPeso,
      lineBarsData: [
        LineChartBarData(
          spots: ChartDataService.prepareWeightChartData(controller.historicoPeso),
          isCurved: true,
          barWidth: 3,
          color: Colors.blue,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.blue.withValues(alpha: 0.15),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: DashboardConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: DashboardHelpers.getCardBorderRadius(),
      ),
      child: SizedBox(
        height: DashboardConstants.weightChartHeight + 100,
        child: DashboardHelpers.buildEmptyState(
          icon: Icons.monitor_weight,
          title: 'Nenhum registro de peso',
          subtitle: 'Adicione registros de peso para visualizar o gráfico',
        ),
      ),
    );
  }
}
