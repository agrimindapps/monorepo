// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import 'animations.dart';

class WeatherAnimatedWidget extends StatelessWidget {
  // Localidade fixa por enquanto
  final String location;

  // Construtor que aceita uma localidade opcional, com valor padrão
  const WeatherAnimatedWidget({super.key, this.location = 'São Paulo, SP'});

  @override
  Widget build(BuildContext context) {
    // Dados simulados para a previsão do tempo
    // Em uma implementação real, esses dados viriam de uma API
    final weather = {
      'temperature': '24°C',
      'condition': 'Parcialmente nublado',
      'humidity': '65%',
      'windSpeed': '10 km/h',
      'precipitation': '20%',
    };

    return AnimatedFadeIn(
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Previsão do Tempo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                  AnimatedScaleIn(
                    delay: const Duration(milliseconds: 200),
                    child: Icon(
                      FontAwesome.cloud_sun_solid,
                      size: 24,
                      color: Colors.green.shade800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AnimatedFadeIn(
                delay: const Duration(milliseconds: 100),
                child: Row(
                  children: [
                    Icon(FontAwesome.location_dot_solid,
                        size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AnimatedListBuilder(
                staggerDelay: const Duration(milliseconds: 150),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildWeatherItem(
                        icon: FontAwesome.temperature_half_solid,
                        iconColor: Colors.orange.shade700,
                        value: weather['temperature']!,
                        label: 'Temperatura',
                      ),
                      _buildWeatherItem(
                        icon: FontAwesome.droplet_solid,
                        iconColor: Colors.blue.shade700,
                        value: weather['humidity']!,
                        label: 'Umidade',
                      ),
                      _buildWeatherItem(
                        icon: FontAwesome.wind_solid,
                        iconColor: Colors.blueGrey.shade700,
                        value: weather['windSpeed']!,
                        label: 'Vento',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AnimatedFadeIn(
                delay: const Duration(milliseconds: 400),
                child: AnimatedContainer(
                  duration: AnimationDurations.normal,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        weather['condition']!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green.shade800,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            FontAwesome.cloud_rain_solid,
                            size: 16,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${weather['precipitation']} de chance de chuva',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AnimatedFadeIn(
                delay: const Duration(milliseconds: 500),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Futuramente poderá navegar para uma página detalhada de previsão
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Detalhes da previsão serão implementados em breve!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Text('Ver detalhes'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        AnimatedScaleIn(
          child: Icon(
            icon,
            size: 28,
            color: iconColor,
          ),
        ),
        const SizedBox(height: 4),
        AnimatedFadeIn(
          delay: const Duration(milliseconds: 100),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 2),
        AnimatedFadeIn(
          delay: const Duration(milliseconds: 200),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}