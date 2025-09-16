import 'package:flutter/material.dart';
import '../../domain/entities/weather_measurement_entity.dart';

/// Widget to display a list of weather measurements
class WeatherMeasurementsList extends StatelessWidget {
  final List<WeatherMeasurementEntity> measurements;
  final bool isLoading;
  final bool hasMore;
  final VoidCallback? onLoadMore;
  final Future<void> Function()? onRefresh;

  const WeatherMeasurementsList({
    super.key,
    required this.measurements,
    this.isLoading = false,
    this.hasMore = false,
    this.onLoadMore,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (measurements.isEmpty && !isLoading) {
      return _buildEmptyState(context);
    }

    Widget listView = ListView.builder(
      itemCount: measurements.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= measurements.length) {
          // Load more indicator
          return _buildLoadMoreIndicator();
        }

        return _buildMeasurementItem(context, measurements[index], index);
      },
    );

    if (onRefresh != null) {
      listView = RefreshIndicator(
        onRefresh: onRefresh!,
        child: listView,
      );
    }

    return listView;
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma medição encontrada',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione medições ou ajuste os filtros',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: onLoadMore,
                child: const Text('Carregar mais'),
              ),
      ),
    );
  }

  Widget _buildMeasurementItem(
    BuildContext context,
    WeatherMeasurementEntity measurement,
    int index,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => _showMeasurementDetails(context, measurement),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with location and time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          measurement.locationName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDateTime(measurement.timestamp),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildWeatherIcon(measurement.weatherCondition),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Main weather data
              Row(
                children: [
                  // Temperature
                  Expanded(
                    flex: 2,
                    child: _buildMainMetric(
                      '${measurement.temperature.round()}°C',
                      'Temperatura',
                      _getTemperatureColor(measurement.temperature),
                    ),
                  ),
                  
                  // Humidity
                  Expanded(
                    child: _buildMetric(
                      '${measurement.humidity.round()}%',
                      'Umidade',
                      Icons.water_drop,
                      Colors.blue,
                    ),
                  ),
                  
                  // Rainfall
                  Expanded(
                    child: _buildMetric(
                      '${measurement.rainfall}mm',
                      'Chuva',
                      Icons.grain,
                      Colors.indigo,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Secondary metrics
              Row(
                children: [
                  Expanded(
                    child: _buildSmallMetric(
                      '${measurement.pressure.round()} hPa',
                      'Pressão',
                    ),
                  ),
                  Expanded(
                    child: _buildSmallMetric(
                      '${measurement.windSpeed.round()} km/h',
                      'Vento ${measurement.windDirectionCompass}',
                    ),
                  ),
                  if (measurement.uvIndex > 0)
                    Expanded(
                      child: _buildSmallMetric(
                        'UV ${measurement.uvIndex.round()}',
                        'Índice UV',
                      ),
                    ),
                ],
              ),
              
              // Data quality and source indicator
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQualityIndicator(measurement.qualityScore),
                  _buildSourceIndicator(measurement.source),
                ],
              ),
              
              // Agricultural suitability
              if (measurement.isFavorableForAgriculture)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.eco,
                          size: 14,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Favorável para agricultura',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherIcon(String condition) {
    IconData icon;
    Color color;

    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        icon = Icons.wb_sunny;
        color = Colors.orange;
        break;
      case 'cloudy':
        icon = Icons.cloud;
        color = Colors.grey;
        break;
      case 'partly_cloudy':
        icon = Icons.cloud;
        color = Colors.blue;
        break;
      case 'rain':
      case 'drizzle':
      case 'light_rain':
        icon = Icons.grain;
        color = Colors.blue;
        break;
      case 'heavy_rain':
        icon = Icons.water_drop;
        color = Colors.indigo;
        break;
      case 'thunderstorm':
        icon = Icons.thunderstorm;
        color = Colors.purple;
        break;
      case 'snow':
        icon = Icons.ac_unit;
        color = Colors.lightBlue;
        break;
      case 'fog':
        icon = Icons.foggy;
        color = Colors.grey;
        break;
      default:
        icon = Icons.wb_cloudy;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }

  Widget _buildMainMetric(String value, String label, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMetric(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSmallMetric(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildQualityIndicator(double qualityScore) {
    Color color;
    String label;

    if (qualityScore >= 0.9) {
      color = Colors.green;
      label = 'Excelente';
    } else if (qualityScore >= 0.8) {
      color = Colors.lightGreen;
      label = 'Boa';
    } else if (qualityScore >= 0.7) {
      color = Colors.orange;
      label = 'Regular';
    } else {
      color = Colors.red;
      label = 'Baixa';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        'Qualidade: $label',
        style: TextStyle(
          fontSize: 10,
          color: color.withValues(alpha: 0.8),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSourceIndicator(String source) {
    IconData icon;
    String label;
    Color color = Colors.grey.shade600;

    if (source.startsWith('manual')) {
      icon = Icons.edit;
      label = 'Manual';
    } else if (source.startsWith('sensor')) {
      icon = Icons.sensors;
      label = 'Sensor';
    } else if (source.startsWith('api')) {
      icon = Icons.cloud_download;
      label = 'API';
    } else {
      icon = Icons.help_outline;
      label = 'Desconhecido';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getTemperatureColor(double temperature) {
    if (temperature <= 0) return Colors.blue.shade700;
    if (temperature <= 10) return Colors.blue;
    if (temperature <= 20) return Colors.teal;
    if (temperature <= 30) return Colors.green;
    if (temperature <= 35) return Colors.orange;
    return Colors.red;
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Agora';
    } else if (difference.inMinutes < 60) {
      return 'Há ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Há ${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Ontem às ${_formatTime(dateTime)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${_formatTime(dateTime)}';
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showMeasurementDetails(BuildContext context, WeatherMeasurementEntity measurement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(measurement.locationName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Data/Hora', _formatFullDateTime(measurement.timestamp)),
              _buildDetailRow('Temperatura', '${measurement.temperature}°C'),
              _buildDetailRow('Umidade', '${measurement.humidity}%'),
              _buildDetailRow('Pressão', '${measurement.pressure} hPa'),
              _buildDetailRow('Vento', '${measurement.windSpeed} km/h ${measurement.windDirectionCompass}'),
              _buildDetailRow('Chuva', '${measurement.rainfall} mm'),
              _buildDetailRow('Visibilidade', '${measurement.visibility} km'),
              if (measurement.uvIndex > 0)
                _buildDetailRow('Índice UV', measurement.uvIndex.toString()),
              _buildDetailRow('Condição', measurement.weatherCondition),
              if (measurement.description.isNotEmpty)
                _buildDetailRow('Descrição', measurement.description),
              _buildDetailRow('Fonte', measurement.source),
              _buildDetailRow('Qualidade', '${(measurement.qualityScore * 100).round()}%'),
              if (measurement.notes?.isNotEmpty == true)
                _buildDetailRow('Observações', measurement.notes!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatFullDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
           '${dateTime.month.toString().padLeft(2, '0')}/'
           '${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}