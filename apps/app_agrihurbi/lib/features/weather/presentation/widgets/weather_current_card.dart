import 'package:flutter/material.dart';
import '../../domain/entities/weather_measurement_entity.dart';

/// Widget to display current weather information
class WeatherCurrentCard extends StatelessWidget {
  final WeatherMeasurementEntity? measurement;
  final bool isLoading;

  const WeatherCurrentCard({
    super.key,
    this.measurement,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: _getWeatherGradient(),
        ),
        child: isLoading
            ? _buildLoadingState(context)
            : measurement != null
                ? _buildWeatherInfo(context)
                : _buildEmptyState(context),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return const Column(
      children: [
        CircularProgressIndicator(color: Colors.white),
        SizedBox(height: 16),
        Text(
          'Carregando dados meteorológicos...',
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildWeatherInfo(BuildContext context) {
    return Column(
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
                    measurement!.locationName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _formatDateTime(measurement!.timestamp),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              _getWeatherIcon(),
              color: Colors.white,
              size: 32,
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Main temperature display
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${measurement!.temperature.round()}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 64,
                fontWeight: FontWeight.w300,
              ),
            ),
            const Text(
              '°C',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
        
        // Weather condition
        Center(
          child: Text(
            _getWeatherDescription(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Weather details grid
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      'Umidade',
                      '${measurement!.humidity.round()}%',
                      Icons.water_drop,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      'Pressão',
                      '${measurement!.pressure.round()} hPa',
                      Icons.compress,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      'Vento',
                      '${measurement!.windSpeed.round()} km/h',
                      Icons.air,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      'Chuva',
                      '${measurement!.rainfall} mm',
                      Icons.grain,
                    ),
                  ),
                ],
              ),
              if (measurement!.uvIndex > 0) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        'UV Index',
                        measurement!.uvIndex.round().toString(),
                        Icons.wb_sunny,
                      ),
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        'Visibilidade',
                        '${measurement!.visibility} km',
                        Icons.visibility,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        
        // Additional calculated values
        if (_shouldShowCalculatedValues()) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCalculatedValue(
                  'Sensação Térmica',
                  '${measurement!.heatIndex.round()}°C',
                ),
                _buildCalculatedValue(
                  'Ponto de Orvalho',
                  '${measurement!.dewPoint.round()}°C',
                ),
              ],
            ),
          ),
        ],
        
        // Agricultural suitability indicator
        const SizedBox(height: 16),
        _buildAgriculturalIndicator(),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.cloud_off,
          size: 64,
          color: Colors.white.withValues(alpha: 0.7),
        ),
        const SizedBox(height: 16),
        const Text(
          'Nenhum dado meteorológico disponível',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Toque no botão + para adicionar uma medição',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCalculatedValue(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAgriculturalIndicator() {
    if (measurement == null) return const SizedBox.shrink();
    
    final isFavorable = measurement!.isFavorableForAgriculture;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: (isFavorable ? Colors.green : Colors.orange).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFavorable ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFavorable ? Icons.check_circle : Icons.warning,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            isFavorable
                ? 'Condições favoráveis para agricultura'
                : 'Condições não ideais para agricultura',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getWeatherGradient() {
    if (measurement == null) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.grey.shade600, Colors.grey.shade800],
      );
    }

    switch (measurement!.weatherCondition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.orange, Colors.deepOrange],
        );
      case 'cloudy':
      case 'partly_cloudy':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade400, Colors.blue.shade600],
        );
      case 'rain':
      case 'drizzle':
      case 'light_rain':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade700, Colors.blue.shade900],
        );
      case 'thunderstorm':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple.shade700, Colors.purple.shade900],
        );
      case 'snow':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade200, Colors.blue.shade400],
        );
      default:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade500, Colors.blue.shade700],
        );
    }
  }

  IconData _getWeatherIcon() {
    if (measurement == null) return Icons.help_outline;

    switch (measurement!.weatherCondition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return Icons.wb_sunny;
      case 'cloudy':
        return Icons.cloud;
      case 'partly_cloudy':
        return Icons.cloud;
      case 'rain':
      case 'drizzle':
      case 'light_rain':
        return Icons.grain;
      case 'heavy_rain':
        return Icons.water_drop;
      case 'thunderstorm':
        return Icons.thunderstorm;
      case 'snow':
        return Icons.ac_unit;
      case 'fog':
        return Icons.foggy;
      default:
        return Icons.wb_cloudy;
    }
  }

  String _getWeatherDescription() {
    if (measurement == null) return 'Sem dados';

    switch (measurement!.weatherCondition.toLowerCase()) {
      case 'sunny':
        return 'Ensolarado';
      case 'clear':
        return 'Céu limpo';
      case 'cloudy':
        return 'Nublado';
      case 'partly_cloudy':
        return 'Parcialmente nublado';
      case 'rain':
        return 'Chuva';
      case 'drizzle':
        return 'Garoa';
      case 'light_rain':
        return 'Chuva fraca';
      case 'heavy_rain':
        return 'Chuva forte';
      case 'thunderstorm':
        return 'Tempestade';
      case 'snow':
        return 'Neve';
      case 'fog':
        return 'Neblina';
      case 'overcast':
        return 'Encoberto';
      default:
        return measurement!.description.isNotEmpty
            ? measurement!.description
            : 'Condição desconhecida';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return 'Há ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Há ${difference.inHours} h';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return 'Há ${difference.inDays} dias';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  bool _shouldShowCalculatedValues() {
    if (measurement == null) return false;
    return measurement!.temperature > 20 && measurement!.humidity > 30;
  }
}