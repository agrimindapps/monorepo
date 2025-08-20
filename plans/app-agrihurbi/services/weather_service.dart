// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

// Project imports:
import '../models/weather_model.dart';
import 'log_service.dart';

class WeatherService extends GetxService {
  static WeatherService get instance => Get.find<WeatherService>();

  final RxBool _isLoading = false.obs;
  final Rx<WeatherModel?> _currentWeather = Rx<WeatherModel?>(null);
  final RxString _errorMessage = ''.obs;
  final RxBool _locationPermissionGranted = false.obs;

  bool get isLoading => _isLoading.value;
  WeatherModel? get currentWeather => _currentWeather.value;
  String get errorMessage => _errorMessage.value;
  bool get locationPermissionGranted => _locationPermissionGranted.value;

  String? _apiKey;
  String? _baseUrl;

  void initialize({String? apiKey, String? baseUrl}) {
    _apiKey = apiKey;
    _baseUrl = baseUrl;
  }

  Future<void> checkLocationPermission() async {
    try {
      _locationPermissionGranted.value = true;
      _errorMessage.value = '';
    } catch (e) {
      _errorMessage.value = 'Erro ao verificar permissão de localização: $e';
      _locationPermissionGranted.value = false;
    }
  }

  Future<Map<String, double>?> getCurrentLocation() async {
    try {
      if (!_locationPermissionGranted.value) {
        await checkLocationPermission();
      }

      if (!_locationPermissionGranted.value) {
        _errorMessage.value = 'Permissão de localização não concedida';
        return null;
      }

      return {
        'latitude': -23.5505,
        'longitude': -46.6333,
      };
    } catch (e) {
      _errorMessage.value = 'Erro ao obter localização: $e';
      return null;
    }
  }

  Future<void> fetchWeatherByLocation() async {
    if (_isLoading.value) return; // Evita múltiplas chamadas simultâneas

    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      Map<String, double>? location = await getCurrentLocation();

      if (location != null) {
        await fetchWeatherByCoordinates(
            location['latitude']!, location['longitude']!);
      } else {
        _errorMessage.value = 'Não foi possível obter localização';
      }
    } catch (e) {
      _errorMessage.value = 'Erro ao buscar previsão do tempo: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> fetchWeatherByCoordinates(double lat, double lon) async {
    if (_isLoading.value) return; // Evita múltiplas chamadas simultâneas

    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      if (_apiKey == null || _baseUrl == null) {
        // Simula delay de rede
        await Future.delayed(const Duration(milliseconds: 500));
        _currentWeather.value = _getMockWeatherData(lat, lon);
        return;
      }

      final response = await http.get(
        Uri.parse(
            '$_baseUrl?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=pt_br'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _currentWeather.value = _parseApiResponse(data, lat, lon);
      } else {
        _errorMessage.value = 'Erro ao buscar dados: ${response.statusCode}';
        _currentWeather.value = _getMockWeatherData(lat, lon);
      }
    } catch (e) {
      if (kDebugMode) {
        LogService.warning('Erro na API, usando dados simulados', tag: 'Weather', data: e);
      }
      _currentWeather.value = _getMockWeatherData(lat, lon);
    } finally {
      _isLoading.value = false;
    }
  }

  WeatherModel _parseApiResponse(
      Map<String, dynamic> data, double lat, double lon) {
    return WeatherModel(
      location: data['name'] ?? 'Localização Atual',
      latitude: lat,
      longitude: lon,
      current: WeatherCurrent(
        temperature: data['main']['temp']?.toDouble() ?? 25.0,
        feelsLike: data['main']['feels_like']?.toDouble() ?? 25.0,
        humidity: data['main']['humidity'] ?? 60,
        windSpeed: data['wind']['speed']?.toDouble() ?? 10.0,
        windDirection: _getWindDirection(data['wind']['deg'] ?? 0),
        cloudCover: data['clouds']['all'] ?? 50,
        uvIndex: 5.0,
        condition: data['weather'][0]['description'] ?? 'Ensolarado',
        icon: data['weather'][0]['icon'] ?? '01d',
        pressure: data['main']['pressure']?.toDouble() ?? 1013.0,
        visibility: 10.0,
      ),
      forecast: _generateForecast(),
      lastUpdate: DateTime.now(),
    );
  }

  WeatherModel _getMockWeatherData(double lat, double lon) {
    return WeatherModel(
      location: 'Sua Localização',
      latitude: lat,
      longitude: lon,
      current: WeatherCurrent(
        temperature: 28.0,
        feelsLike: 32.0,
        humidity: 65,
        windSpeed: 12.0,
        windDirection: 'NE',
        cloudCover: 40,
        uvIndex: 7.0,
        condition: 'Parcialmente nublado',
        icon: '02d',
        pressure: 1015.0,
        visibility: 15.0,
      ),
      forecast: _generateForecast(),
      lastUpdate: DateTime.now(),
    );
  }

  List<WeatherForecast> _generateForecast() {
    final now = DateTime.now();
    final List<Map<String, dynamic>> mockData = [
      {
        'condition': 'Ensolarado',
        'icon': '01d',
        'max': 32,
        'min': 18,
        'rain': 10
      },
      {
        'condition': 'Parcialmente nublado',
        'icon': '02d',
        'max': 29,
        'min': 16,
        'rain': 25
      },
      {'condition': 'Nublado', 'icon': '03d', 'max': 26, 'min': 14, 'rain': 45},
      {
        'condition': 'Chuva leve',
        'icon': '10d',
        'max': 24,
        'min': 12,
        'rain': 80
      },
      {
        'condition': 'Ensolarado',
        'icon': '01d',
        'max': 30,
        'min': 16,
        'rain': 5
      },
    ];

    return List.generate(5, (index) {
      final data = mockData[index];
      return WeatherForecast(
        date: now.add(Duration(days: index + 1)),
        maxTemp: data['max'].toDouble(),
        minTemp: data['min'].toDouble(),
        condition: data['condition'],
        icon: data['icon'],
        humidity: 60 + (index * 5),
        windSpeed: 8.0 + (index * 2),
        rainChance: data['rain'].toDouble(),
        rainAmount: data['rain'] > 50 ? 5.0 : 0.0,
        windDirection: ['N', 'NE', 'E', 'SE', 'S'][index],
      );
    });
  }

  String _getWindDirection(int degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    return directions[((degrees + 22.5) % 360 / 45).floor()];
  }

  String getWeatherIcon(String condition) {
    final Map<String, String> iconMap = {
      'ensolarado': '☀️',
      'parcialmente nublado': '⛅',
      'nublado': '☁️',
      'chuva': '🌧️',
      'chuva leve': '🌦️',
      'tempestade': '⛈️',
      'neve': '❄️',
      'neblina': '🌫️',
    };

    return iconMap[condition.toLowerCase()] ?? '☀️';
  }

  String getUVIndexDescription(double uvIndex) {
    if (uvIndex <= 2) return 'Baixo';
    if (uvIndex <= 5) return 'Moderado';
    if (uvIndex <= 7) return 'Alto';
    if (uvIndex <= 10) return 'Muito Alto';
    return 'Extremo';
  }

  String getWindSpeedDescription(double windSpeed) {
    if (windSpeed < 5) return 'Vento fraco';
    if (windSpeed < 15) return 'Vento moderado';
    if (windSpeed < 25) return 'Vento forte';
    return 'Vento muito forte';
  }
}
