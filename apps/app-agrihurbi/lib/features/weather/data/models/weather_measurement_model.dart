import 'package:core/core.dart';

import '../../domain/entities/weather_measurement_entity.dart';

part 'weather_measurement_model.g.dart';

/// Weather measurement model with Hive serialization
/// Converts between domain entity and data model for persistence
@HiveType(typeId: 50) // Unique typeId for weather measurements
class WeatherMeasurementModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String locationId;

  @HiveField(2)
  final String locationName;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final double temperature;

  @HiveField(5)
  final double humidity;

  @HiveField(6)
  final double pressure;

  @HiveField(7)
  final double windSpeed;

  @HiveField(8)
  final double windDirection;

  @HiveField(9)
  final double rainfall;

  @HiveField(10)
  final double uvIndex;

  @HiveField(11)
  final double visibility;

  @HiveField(12)
  final String weatherCondition;

  @HiveField(13)
  final String description;

  @HiveField(14)
  final double latitude;

  @HiveField(15)
  final double longitude;

  @HiveField(16)
  final String source;

  @HiveField(17)
  final double qualityScore;

  @HiveField(18)
  final bool isRealTime;

  @HiveField(19)
  final String? notes;

  @HiveField(20)
  final DateTime createdAt;

  @HiveField(21)
  final DateTime updatedAt;

  const WeatherMeasurementModel({
    required this.id,
    required this.locationId,
    required this.locationName,
    required this.timestamp,
    required this.temperature,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.windDirection,
    required this.rainfall,
    required this.uvIndex,
    required this.visibility,
    required this.weatherCondition,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.source,
    required this.qualityScore,
    required this.isRealTime,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create model from domain entity
  factory WeatherMeasurementModel.fromEntity(WeatherMeasurementEntity entity) {
    return WeatherMeasurementModel(
      id: entity.id,
      locationId: entity.locationId,
      locationName: entity.locationName,
      timestamp: entity.timestamp,
      temperature: entity.temperature,
      humidity: entity.humidity,
      pressure: entity.pressure,
      windSpeed: entity.windSpeed,
      windDirection: entity.windDirection,
      rainfall: entity.rainfall,
      uvIndex: entity.uvIndex,
      visibility: entity.visibility,
      weatherCondition: entity.weatherCondition,
      description: entity.description,
      latitude: entity.latitude,
      longitude: entity.longitude,
      source: entity.source,
      qualityScore: entity.qualityScore,
      isRealTime: entity.isRealTime,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert to domain entity
  WeatherMeasurementEntity toEntity() {
    return WeatherMeasurementEntity(
      id: id,
      locationId: locationId,
      locationName: locationName,
      timestamp: timestamp,
      temperature: temperature,
      humidity: humidity,
      pressure: pressure,
      windSpeed: windSpeed,
      windDirection: windDirection,
      rainfall: rainfall,
      uvIndex: uvIndex,
      visibility: visibility,
      weatherCondition: weatherCondition,
      description: description,
      latitude: latitude,
      longitude: longitude,
      source: source,
      qualityScore: qualityScore,
      isRealTime: isRealTime,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create model from JSON (for API integration)
  factory WeatherMeasurementModel.fromJson(Map<String, dynamic> json) {
    return WeatherMeasurementModel(
      id: json['id']?.toString() ?? '',
      locationId: json['location_id']?.toString() ?? '',
      locationName: json['location_name']?.toString() ?? '',
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      humidity: (json['humidity'] as num?)?.toDouble() ?? 0.0,
      pressure: (json['pressure'] as num?)?.toDouble() ?? 1013.25,
      windSpeed: (json['wind_speed'] as num?)?.toDouble() ?? 0.0,
      windDirection: (json['wind_direction'] as num?)?.toDouble() ?? 0.0,
      rainfall: (json['rainfall'] as num?)?.toDouble() ?? 0.0,
      uvIndex: (json['uv_index'] as num?)?.toDouble() ?? 0.0,
      visibility: (json['visibility'] as num?)?.toDouble() ?? 10.0,
      weatherCondition: json['weather_condition']?.toString() ?? 'unknown',
      description: json['description']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      source: json['source']?.toString() ?? 'unknown',
      qualityScore: (json['quality_score'] as num?)?.toDouble() ?? 1.0,
      isRealTime: json['is_real_time'] == true,
      notes: json['notes']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  /// Convert to JSON (for API integration)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location_id': locationId,
      'location_name': locationName,
      'timestamp': timestamp.toIso8601String(),
      'temperature': temperature,
      'humidity': humidity,
      'pressure': pressure,
      'wind_speed': windSpeed,
      'wind_direction': windDirection,
      'rainfall': rainfall,
      'uv_index': uvIndex,
      'visibility': visibility,
      'weather_condition': weatherCondition,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'source': source,
      'quality_score': qualityScore,
      'is_real_time': isRealTime,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create model from weather API response (OpenWeatherMap format)
  factory WeatherMeasurementModel.fromOpenWeatherMapApi(
    Map<String, dynamic> json,
    String locationId,
    String locationName,
  ) {
    final main = json['main'] ?? <String, dynamic>{};
    final weather = json['weather']?[0] ?? <String, dynamic>{};
    final wind = json['wind'] ?? <String, dynamic>{};
    final rain = json['rain'] ?? <String, dynamic>{};
    
    return WeatherMeasurementModel(
      id: 'owm_${DateTime.now().millisecondsSinceEpoch}',
      locationId: locationId,
      locationName: locationName,
      timestamp: DateTime.fromMillisecondsSinceEpoch((json['dt'] as int? ?? 0) * 1000),
      temperature: (main['temp'] as num?)?.toDouble() ?? 0.0,
      humidity: (main['humidity'] as num?)?.toDouble() ?? 0.0,
      pressure: (main['pressure'] as num?)?.toDouble() ?? 1013.25,
      windSpeed: ((wind['speed'] as num?)?.toDouble() ?? 0.0) * 3.6, // Convert m/s to km/h
      windDirection: (wind['deg'] as num?)?.toDouble() ?? 0.0,
      rainfall: (rain['1h'] as num?)?.toDouble() ?? 0.0,
      uvIndex: (json['uvi'] as num?)?.toDouble() ?? 0.0,
      visibility: ((json['visibility'] as num?)?.toDouble() ?? 10000.0) / 1000.0, // Convert m to km
      weatherCondition: _mapOpenWeatherCondition(weather['main']?.toString() ?? 'unknown'),
      description: weather['description']?.toString() ?? 'Weather data from OpenWeatherMap',
      latitude: (json['coord']?['lat'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['coord']?['lon'] as num?)?.toDouble() ?? 0.0,
      source: 'api_openweathermap',
      qualityScore: 0.95,
      isRealTime: true,
      notes: 'Imported from OpenWeatherMap API',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create model from weather API response (AccuWeather format)
  factory WeatherMeasurementModel.fromAccuWeatherApi(
    Map<String, dynamic> json,
    String locationId,
    String locationName,
  ) {
    final temperature = json['Temperature'] ?? <String, dynamic>{};
    final humidity = json['RelativeHumidity'] ?? 0;
    final pressure = json['Pressure'] ?? <String, dynamic>{};
    final wind = json['Wind'] ?? <String, dynamic>{};
    final precipitation = json['PrecipitationSummary'] ?? <String, dynamic>{};
    
    return WeatherMeasurementModel(
      id: 'aw_${DateTime.now().millisecondsSinceEpoch}',
      locationId: locationId,
      locationName: locationName,
      timestamp: DateTime.tryParse(json['DateTime']?.toString() ?? '') ?? DateTime.now(),
      temperature: ((temperature['Metric']?['Value']) as num?)?.toDouble() ?? 0.0,
      humidity: ((humidity as num?)?.toDouble()) ?? 0.0,
      pressure: ((pressure['Metric']?['Value']) as num?)?.toDouble() ?? 1013.25,
      windSpeed: ((wind['Speed']?['Metric']?['Value']) as num?)?.toDouble() ?? 0.0,
      windDirection: ((wind['Direction']?['Degrees']) as num?)?.toDouble() ?? 0.0,
      rainfall: ((precipitation['Past24Hours']?['Metric']?['Value']) as num?)?.toDouble() ?? 0.0,
      uvIndex: ((json['UVIndex'] as num?)?.toDouble()) ?? 0.0,
      visibility: ((json['Visibility']?['Metric']?['Value']) as num?)?.toDouble() ?? 10.0,
      weatherCondition: _mapAccuWeatherCondition(json['WeatherText']?.toString() ?? 'unknown'),
      description: json['WeatherText']?.toString() ?? 'Weather data from AccuWeather',
      latitude: 0.0, // Would need to be provided separately
      longitude: 0.0, // Would need to be provided separately
      source: 'api_accuweather',
      qualityScore: 0.95,
      isRealTime: true,
      notes: 'Imported from AccuWeather API',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create model from sensor data
  factory WeatherMeasurementModel.fromSensorData(
    Map<String, dynamic> sensorData,
    String locationId,
    String locationName,
    double latitude,
    double longitude,
  ) {
    return WeatherMeasurementModel(
      id: 'sensor_${DateTime.now().millisecondsSinceEpoch}',
      locationId: locationId,
      locationName: locationName,
      timestamp: DateTime.tryParse(sensorData['timestamp']?.toString() ?? '') ?? DateTime.now(),
      temperature: ((sensorData['temperature'] as num?)?.toDouble()) ?? 0.0,
      humidity: ((sensorData['humidity'] as num?)?.toDouble()) ?? 0.0,
      pressure: ((sensorData['pressure'] as num?)?.toDouble()) ?? 1013.25,
      windSpeed: ((sensorData['wind_speed'] as num?)?.toDouble()) ?? 0.0,
      windDirection: ((sensorData['wind_direction'] as num?)?.toDouble()) ?? 0.0,
      rainfall: ((sensorData['rainfall'] as num?)?.toDouble()) ?? 0.0,
      uvIndex: ((sensorData['uv_index'] as num?)?.toDouble()) ?? 0.0,
      visibility: ((sensorData['visibility'] as num?)?.toDouble()) ?? 10.0,
      weatherCondition: sensorData['condition']?.toString() ?? 'unknown',
      description: sensorData['description']?.toString() ?? 'Sensor measurement',
      latitude: latitude,
      longitude: longitude,
      source: 'sensor_${sensorData['device_id'] ?? 'unknown'}',
      qualityScore: _calculateSensorQualityScore(sensorData),
      isRealTime: true,
      notes: 'Device: ${sensorData['device_id'] ?? 'unknown'}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create copy with updated properties
  WeatherMeasurementModel copyWith({
    String? id,
    String? locationId,
    String? locationName,
    DateTime? timestamp,
    double? temperature,
    double? humidity,
    double? pressure,
    double? windSpeed,
    double? windDirection,
    double? rainfall,
    double? uvIndex,
    double? visibility,
    String? weatherCondition,
    String? description,
    double? latitude,
    double? longitude,
    String? source,
    double? qualityScore,
    bool? isRealTime,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WeatherMeasurementModel(
      id: id ?? this.id,
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      timestamp: timestamp ?? this.timestamp,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      pressure: pressure ?? this.pressure,
      windSpeed: windSpeed ?? this.windSpeed,
      windDirection: windDirection ?? this.windDirection,
      rainfall: rainfall ?? this.rainfall,
      uvIndex: uvIndex ?? this.uvIndex,
      visibility: visibility ?? this.visibility,
      weatherCondition: weatherCondition ?? this.weatherCondition,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      source: source ?? this.source,
      qualityScore: qualityScore ?? this.qualityScore,
      isRealTime: isRealTime ?? this.isRealTime,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        locationId,
        locationName,
        timestamp,
        temperature,
        humidity,
        pressure,
        windSpeed,
        windDirection,
        rainfall,
        uvIndex,
        visibility,
        weatherCondition,
        description,
        latitude,
        longitude,
        source,
        qualityScore,
        isRealTime,
        notes,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'WeatherMeasurementModel('
        'id: $id, '
        'location: $locationName, '
        'temp: $temperature°C, '
        'humidity: $humidity%, '
        'condition: $weatherCondition'
        ')';
  }

  /// Map OpenWeatherMap condition to internal format
  static String _mapOpenWeatherCondition(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return 'sunny';
      case 'clouds':
        return 'cloudy';
      case 'rain':
      case 'drizzle':
        return 'rain';
      case 'thunderstorm':
        return 'thunderstorm';
      case 'snow':
        return 'snow';
      case 'mist':
      case 'fog':
        return 'fog';
      default:
        return 'unknown';
    }
  }

  /// Map AccuWeather condition to internal format
  static String _mapAccuWeatherCondition(String condition) {
    final lowerCondition = condition.toLowerCase();
    if (lowerCondition.contains('sunny') || lowerCondition.contains('clear')) {
      return 'sunny';
    } else if (lowerCondition.contains('cloud')) {
      return 'cloudy';
    } else if (lowerCondition.contains('rain') || lowerCondition.contains('shower')) {
      return 'rain';
    } else if (lowerCondition.contains('storm')) {
      return 'thunderstorm';
    } else if (lowerCondition.contains('snow')) {
      return 'snow';
    } else if (lowerCondition.contains('fog') || lowerCondition.contains('mist')) {
      return 'fog';
    } else {
      return 'unknown';
    }
  }

  /// Calculate quality score for sensor data
  static double _calculateSensorQualityScore(Map<String, dynamic> sensorData) {
    double score = 1.0;
    final requiredFields = ['temperature', 'humidity', 'pressure'];
    for (final field in requiredFields) {
      if (sensorData[field] == null) {
        score -= 0.15;
      }
    }
    final temp = (sensorData['temperature'] as num?)?.toDouble();
    if (temp != null && ((temp < -50) || (temp > 60))) score -= 0.2;

    final humidity = (sensorData['humidity'] as num?)?.toDouble();
    if (humidity != null && ((humidity < 0) || (humidity > 100))) score -= 0.2;

    final pressure = (sensorData['pressure'] as num?)?.toDouble();
    if (pressure != null && ((pressure < 800) || (pressure > 1200))) score -= 0.15;
    final timestamp = DateTime.tryParse(sensorData['timestamp']?.toString() ?? '');
    if (timestamp != null) {
      final age = DateTime.now().difference(timestamp).inHours;
      if (age > 24) score -= 0.1;
      if (age > 72) score -= 0.2;
    }

    return score.clamp(0.0, 1.0);
  }
}