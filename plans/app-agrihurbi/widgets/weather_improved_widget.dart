// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherImprovedWidget extends StatefulWidget {
  const WeatherImprovedWidget({super.key});

  @override
  State<WeatherImprovedWidget> createState() => _WeatherImprovedWidgetState();
}

class _WeatherImprovedWidgetState extends State<WeatherImprovedWidget> {
  late final WeatherService weatherService;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  void _initializeService() {
    try {
      weatherService = Get.find<WeatherService>();
    } catch (e) {
      weatherService = Get.put(WeatherService());
    }
  }

  void _fetchWeather() {
    // Use Future.microtask para evitar setState durante build
    Future.microtask(() {
      weatherService.fetchWeatherByLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Previsão do Tempo',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Obx(() {
          if (weatherService.isLoading) {
            return const SizedBox(
              height: 200,
              child: Card(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }

          if (weatherService.currentWeather == null) {
            return SizedBox(
              height: 140,
              child: Card(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_off,
                          size: 42, color: Colors.grey),
                      const SizedBox(height: 6),
                      const Text('Toque para obter previsão do tempo'),
                      const SizedBox(height: 6),
                      ElevatedButton(
                        onPressed: _fetchWeather,
                        child: const Text('Obter Localização'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final weather = weatherService.currentWeather!;
          return Column(
            children: [
              _buildCurrentWeatherCard(weather.current, weather.location),
              const SizedBox(height: 8),
              _buildForecastCard(weather.forecast),
              if (weatherService.errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    weatherService.errorMessage,
                    style: const TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildCurrentWeatherCard(WeatherCurrent current, String location) {
    return SizedBox(
      height: 140,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      location,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Text(
                          '${current.temperature.round()}°C',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          WeatherService.instance
                              .getWeatherIcon(current.condition),
                          style: const TextStyle(fontSize: 24),
                        ),
                      ],
                    ),
                    Text(
                      current.condition,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      'Sensação: ${current.feelsLike.round()}°C',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildWeatherDetail(
                      Icons.water_drop,
                      '${current.humidity}%',
                      'Umidade',
                    ),
                    _buildWeatherDetail(
                      Icons.air,
                      '${current.windSpeed.round()} km/h',
                      'Vento',
                    ),
                    _buildWeatherDetail(
                      Icons.wb_sunny,
                      'UV ${current.uvIndex.round()}',
                      WeatherService.instance
                          .getUVIndexDescription(current.uvIndex),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildForecastCard(List<WeatherForecast> forecast) {
    return SizedBox(
      height: 120,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: forecast.length,
            itemBuilder: (context, index) {
              final day = forecast[index];
              final isToday = index == 0;

              return Container(
                width: 85,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      isToday
                          ? 'Amanhã'
                          : DateFormat('E', 'pt_BR').format(day.date),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      WeatherService.instance.getWeatherIcon(day.condition),
                      style: const TextStyle(fontSize: 28),
                    ),
                    Column(
                      children: [
                        Text(
                          '${day.maxTemp.round()}°',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${day.minTemp.round()}°',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    if (day.rainChance > 20)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.water_drop,
                            size: 10,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${day.rainChance.round()}%',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class WeatherDetailPage extends StatelessWidget {
  const WeatherDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final weatherService = Get.find<WeatherService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Tempo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => weatherService.fetchWeatherByLocation(),
          ),
        ],
      ),
      body: Obx(() {
        if (weatherService.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (weatherService.currentWeather == null) {
          return const Center(
            child: Text('Nenhum dado de previsão disponível'),
          );
        }

        final weather = weatherService.currentWeather!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailedCurrentWeather(weather.current, weather.location),
              const SizedBox(height: 16),
              _buildDetailedForecast(weather.forecast),
              const SizedBox(height: 16),
              _buildWeatherTips(weather.current),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDetailedCurrentWeather(WeatherCurrent current, String location) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Condições Atuais - $location',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  '${current.temperature.round()}°C',
                  style: const TextStyle(
                      fontSize: 48, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      current.condition,
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Sensação: ${current.feelsLike.round()}°C',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailGrid(current),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailGrid(WeatherCurrent current) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 3,
      children: [
        _buildDetailTile('Umidade', '${current.humidity}%', Icons.water_drop),
        _buildDetailTile(
            'Vento',
            '${current.windSpeed.round()} km/h ${current.windDirection}',
            Icons.air),
        _buildDetailTile(
            'Pressão', '${current.pressure.round()} hPa', Icons.speed),
        _buildDetailTile('Visibilidade', '${current.visibility.round()} km',
            Icons.visibility),
        _buildDetailTile('Nuvens', '${current.cloudCover}%', Icons.cloud),
        _buildDetailTile(
            'Índice UV',
            '${current.uvIndex.round()} - ${WeatherService.instance.getUVIndexDescription(current.uvIndex)}',
            Icons.wb_sunny),
      ],
    );
  }

  Widget _buildDetailTile(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedForecast(List<WeatherForecast> forecast) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Previsão para os Próximos Dias',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...forecast.map((day) => _buildForecastItem(day)),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastItem(WeatherForecast day) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              DateFormat('E dd/MM', 'pt_BR').format(day.date),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            WeatherService.instance.getWeatherIcon(day.condition),
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              day.condition,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${day.maxTemp.round()}°/${day.minTemp.round()}°',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              if (day.rainChance > 10)
                Text(
                  '🌧️ ${day.rainChance.round()}%',
                  style: const TextStyle(fontSize: 12, color: Colors.blue),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherTips(WeatherCurrent current) {
    List<String> tips = [];

    if (current.uvIndex > 7) {
      tips.add('☀️ Índice UV alto - use protetor solar');
    }
    if (current.humidity > 80) {
      tips.add('💧 Alta umidade - mantenha-se hidratado');
    }
    if (current.windSpeed > 20) {
      tips.add('💨 Vento forte - cuidado com atividades ao ar livre');
    }
    if (current.temperature > 30) {
      tips.add(
          '🌡️ Temperatura alta - evite exposição ao sol nas horas mais quentes');
    }

    if (tips.isEmpty) {
      tips.add('✅ Condições favoráveis para atividades ao ar livre');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dicas para Agricultura',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...tips.map((tip) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(tip, style: const TextStyle(fontSize: 14)),
                )),
          ],
        ),
      ),
    );
  }
}
