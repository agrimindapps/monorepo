import 'package:flutter/material.dart';
import '../../domain/entities/weather_statistics_entity.dart';

/// Widget to display weather statistics card
class WeatherStatisticsCard extends StatelessWidget {
  final WeatherStatisticsEntity statistics;

  const WeatherStatisticsCard({
    super.key,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Estatísticas ${_getPeriodName()}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getQualityColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getQualityColor().withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'Qualidade: ${statistics.dataQualityGrade}',
                    style: TextStyle(
                      fontSize: 12,
                      color: _getQualityColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Main statistics grid
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Temp. Média',
                    '${statistics.avgTemperature.toStringAsFixed(1)}°C',
                    Icons.thermostat,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Chuva Total',
                    '${statistics.totalRainfall.toStringAsFixed(1)}mm',
                    Icons.water_drop,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Umidade Média',
                    '${statistics.avgHumidity.toStringAsFixed(1)}%',
                    Icons.opacity,
                    Colors.teal,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Vento Médio',
                    '${statistics.avgWindSpeed.toStringAsFixed(1)} km/h',
                    Icons.air,
                    Colors.grey,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Temperature range
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Variação de Temperatura',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Min: ${statistics.minTemperature.toStringAsFixed(1)}°C',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Máx: ${statistics.maxTemperature.toStringAsFixed(1)}°C',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Days summary
            Row(
              children: [
                Expanded(
                  child: _buildDaysSummary(
                    'Dias Favoráveis',
                    statistics.favorableDays,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDaysSummary(
                    'Dias de Chuva',
                    statistics.rainyDays,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            
            // Trends if available
            if (_hasTrends()) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Tendências',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _buildTrendChip('Temperatura', statistics.temperatureTrend),
                  _buildTrendChip('Chuva', statistics.rainfallTrend),
                ],
              ),
            ],
            
            // Period info
            const SizedBox(height: 12),
            Text(
              'Período: ${_formatDate(statistics.startDate)} - ${_formatDate(statistics.endDate)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              '${statistics.totalMeasurements} medições • ${(statistics.dataCompleteness * 100).toStringAsFixed(1)}% completude',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDaysSummary(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChip(String label, double trend) {
    IconData icon;
    Color color;
    String text;

    if (trend.abs() < 0.1) {
      icon = Icons.trending_flat;
      color = Colors.grey;
      text = '$label: Estável';
    } else if (trend > 0) {
      icon = Icons.trending_up;
      color = Colors.green;
      text = '$label: ↗ ${trend.toStringAsFixed(1)}';
    } else {
      icon = Icons.trending_down;
      color = Colors.red;
      text = '$label: ↘ ${trend.abs().toStringAsFixed(1)}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getPeriodName() {
    switch (statistics.period.toLowerCase()) {
      case 'daily':
        return 'Diárias';
      case 'weekly':
        return 'Semanais';
      case 'monthly':
        return 'Mensais';
      case 'yearly':
        return 'Anuais';
      default:
        return statistics.period;
    }
  }

  Color _getQualityColor() {
    if (statistics.avgDataQuality >= 0.9) return Colors.green;
    if (statistics.avgDataQuality >= 0.8) return Colors.lightGreen;
    if (statistics.avgDataQuality >= 0.7) return Colors.orange;
    return Colors.red;
  }

  bool _hasTrends() {
    return statistics.temperatureTrend.abs() > 0.1 || 
           statistics.rainfallTrend.abs() > 0.1;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year.toString().substring(2)}';
  }
}