import 'dart:math' as math;

import 'package:core/core.dart' show Equatable;

/// Weather measurement entity following Clean Architecture
/// Represents weather data measurements in the domain layer
class WeatherMeasurementEntity extends Equatable {
  /// Unique identifier for the measurement
  final String id;

  /// Location identifier where measurement was taken
  final String locationId;

  /// Location name for display
  final String locationName;

  /// Date and time when measurement was recorded
  final DateTime timestamp;

  /// Temperature in Celsius
  final double temperature;

  /// Relative humidity percentage (0-100)
  final double humidity;

  /// Atmospheric pressure in hPa (hectopascals)
  final double pressure;

  /// Wind speed in km/h
  final double windSpeed;

  /// Wind direction in degrees (0-360)
  final double windDirection;

  /// Rainfall amount in mm
  final double rainfall;

  /// UV index (0-11+)
  final double uvIndex;

  /// Visibility in kilometers
  final double visibility;

  /// Weather condition code (sunny, cloudy, rainy, etc.)
  final String weatherCondition;

  /// Human-readable weather description
  final String description;

  /// Coordinates
  final double latitude;
  final double longitude;

  /// Data source (manual, automatic_station, api, etc.)
  final String source;

  /// Quality score of the measurement (0.0-1.0)
  final double qualityScore;

  /// Whether this is a real-time measurement
  final bool isRealTime;

  /// Additional notes or observations
  final String? notes;

  /// When this record was created locally
  final DateTime createdAt;

  /// When this record was last updated
  final DateTime updatedAt;

  const WeatherMeasurementEntity({
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

  /// Creates empty weather measurement for initialization
  static final WeatherMeasurementEntity empty = WeatherMeasurementEntity(
    id: '',
    locationId: '',
    locationName: '',
    timestamp: DateTime(1970),
    temperature: 0.0,
    humidity: 0.0,
    pressure: 0.0,
    windSpeed: 0.0,
    windDirection: 0.0,
    rainfall: 0.0,
    uvIndex: 0.0,
    visibility: 0.0,
    weatherCondition: '',
    description: '',
    latitude: 0.0,
    longitude: 0.0,
    source: '',
    qualityScore: 0.0,
    isRealTime: false,
    notes: null,
    createdAt: DateTime(1970),
    updatedAt: DateTime(1970),
  );

  /// Calculate heat index based on temperature and humidity
  double get heatIndex {
    if (temperature < 27) {
      return temperature; // Heat index only relevant for high temps
    }

    final T = temperature;
    final relativeHumidity = humidity;

    // Simplified heat index formula (Rothfusz regression)
    final heatIndex =
        -8.78469475556 +
        1.61139411 * T +
        2.33854883889 * relativeHumidity +
        -0.14611605 * T * relativeHumidity +
        -0.012308094 * T * T +
        -0.0164248277778 * relativeHumidity * relativeHumidity +
        0.002211732 * T * T * relativeHumidity +
        0.00072546 * T * relativeHumidity * relativeHumidity +
        -0.000003582 * T * T * relativeHumidity * relativeHumidity;

    return double.parse(heatIndex.toStringAsFixed(1));
  }

  /// Calculate dew point based on temperature and humidity
  double get dewPoint {
    final T = temperature;
    final relativeHumidity = humidity;

    // Magnus formula approximation
    const a = 17.27;
    const b = 237.7;

    final alpha = ((a * T) / (b + T)) + math.log(relativeHumidity / 100.0);
    final dewPoint = (b * alpha) / (a - alpha);

    return double.parse(dewPoint.toStringAsFixed(1));
  }

  /// Get wind direction as compass direction
  String get windDirectionCompass {
    const directions = [
      'N',
      'NNE',
      'NE',
      'ENE',
      'E',
      'ESE',
      'SE',
      'SSE',
      'S',
      'SSW',
      'SW',
      'WSW',
      'W',
      'WNW',
      'NW',
      'NNW',
    ];

    final index = ((windDirection + 11.25) / 22.5).floor() % 16;
    return directions[index];
  }

  /// Get weather condition severity (0-5 scale)
  int get weatherSeverity {
    switch (weatherCondition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return 0;
      case 'partly_cloudy':
      case 'cloudy':
        return 1;
      case 'overcast':
        return 2;
      case 'light_rain':
      case 'drizzle':
        return 2;
      case 'rain':
        return 3;
      case 'heavy_rain':
        return 4;
      case 'thunderstorm':
      case 'severe_weather':
        return 5;
      default:
        return 1;
    }
  }

  /// Check if conditions are favorable for agricultural activities
  bool get isFavorableForAgriculture {
    return temperature >= 10 &&
        temperature <= 35 &&
        humidity >= 30 &&
        humidity <= 85 &&
        windSpeed < 50 &&
        weatherSeverity <= 2;
  }

  /// Create copy with modified properties
  WeatherMeasurementEntity copyWith({
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
    return WeatherMeasurementEntity(
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
    return 'WeatherMeasurementEntity('
        'id: $id, '
        'location: $locationName, '
        'timestamp: $timestamp, '
        'temp: $temperature°C, '
        'humidity: $humidity%, '
        'condition: $weatherCondition'
        ')';
  }
}
