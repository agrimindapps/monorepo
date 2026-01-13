import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/weather_measurement_entity.dart';

class WeatherChartWidget extends StatelessWidget {
  final List<WeatherMeasurementEntity> measurements;
  final String title;
  final bool isRainfall;

  const WeatherChartWidget({
    super.key,
    required this.measurements,
    required this.title,
    this.isRainfall = false,
  });

  @override
  Widget build(BuildContext context) {
    if (measurements.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'Sem dados para o gráfico',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }

    // Sort measurements by date
    final sortedMeasurements = List<WeatherMeasurementEntity>.from(measurements)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Limit to last 7-10 points to avoid overcrowding if needed, 
    // or use all if we want full history. For now, let's use all but ensure unique timestamps if needed.
    // Ideally we should aggregate data if there are too many points.

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            AspectRatio(
              aspectRatio: 1.7,
              child: isRainfall
                  ? _buildBarChart(context, sortedMeasurements)
                  : _buildLineChart(context, sortedMeasurements),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(BuildContext context, List<WeatherMeasurementEntity> data) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Calculate min/max for Y axis with some padding
    double minY = data.map((e) => e.temperature).reduce((a, b) => a < b ? a : b);
    double maxY = data.map((e) => e.temperature).reduce((a, b) => a > b ? a : b);
    minY = (minY - 5).roundToDouble();
    maxY = (maxY + 5).roundToDouble();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: colorScheme.outlineVariant,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: (data.length / 5).ceilToDouble(), // Show roughly 5 labels
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  final date = data[index].timestamp;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('dd/MM').format(date),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 5,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}°C',
                  style: Theme.of(context).textTheme.bodySmall,
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.temperature);
            }).toList(),
            isCurved: true,
            color: Colors.orange,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.orange.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(BuildContext context, List<WeatherMeasurementEntity> data) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Calculate max Y for rain
    double maxY = data.map((e) => e.rainfall).reduce((a, b) => a > b ? a : b);
    if (maxY == 0) maxY = 10; // Default max if no rain
    maxY = (maxY * 1.2).ceilToDouble(); // Add 20% padding

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            // tooltipBgColor: colorScheme.surfaceContainerHighest,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toStringAsFixed(1)} mm',
                TextStyle(color: colorScheme.onSurface),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  // Show fewer labels if many points
                  if (data.length > 7 && index % (data.length ~/ 7) != 0) {
                    return const SizedBox.shrink();
                  }
                  
                  final date = data[index].timestamp;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('dd/MM').format(date),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const Text('0');
                return Text('${value.toInt()} mm');
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 5,
          getDrawingHorizontalLine: (value) => FlLine(
            color: colorScheme.outlineVariant,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.rainfall,
                color: Colors.blue,
                width: 12, // Fixed width bars
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
