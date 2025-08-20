class WeatherModel {
  final String location;
  final double latitude;
  final double longitude;
  final WeatherCurrent current;
  final List<WeatherForecast> forecast;
  final DateTime lastUpdate;

  WeatherModel({
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.current,
    required this.forecast,
    required this.lastUpdate,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      location: json['location'] ?? '',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      current: WeatherCurrent.fromJson(json['current'] ?? {}),
      forecast: (json['forecast'] as List?)
              ?.map((e) => WeatherForecast.fromJson(e))
              .toList() ??
          [],
      lastUpdate: DateTime.tryParse(json['lastUpdate'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'current': current.toJson(),
      'forecast': forecast.map((e) => e.toJson()).toList(),
      'lastUpdate': lastUpdate.toIso8601String(),
    };
  }
}

class WeatherCurrent {
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String windDirection;
  final int cloudCover;
  final double uvIndex;
  final String condition;
  final String icon;
  final double pressure;
  final double visibility;

  WeatherCurrent({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.cloudCover,
    required this.uvIndex,
    required this.condition,
    required this.icon,
    required this.pressure,
    required this.visibility,
  });

  factory WeatherCurrent.fromJson(Map<String, dynamic> json) {
    return WeatherCurrent(
      temperature: json['temperature']?.toDouble() ?? 0.0,
      feelsLike: json['feelsLike']?.toDouble() ?? 0.0,
      humidity: json['humidity'] ?? 0,
      windSpeed: json['windSpeed']?.toDouble() ?? 0.0,
      windDirection: json['windDirection'] ?? '',
      cloudCover: json['cloudCover'] ?? 0,
      uvIndex: json['uvIndex']?.toDouble() ?? 0.0,
      condition: json['condition'] ?? '',
      icon: json['icon'] ?? '',
      pressure: json['pressure']?.toDouble() ?? 0.0,
      visibility: json['visibility']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'feelsLike': feelsLike,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'cloudCover': cloudCover,
      'uvIndex': uvIndex,
      'condition': condition,
      'icon': icon,
      'pressure': pressure,
      'visibility': visibility,
    };
  }
}

class WeatherForecast {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final String condition;
  final String icon;
  final int humidity;
  final double windSpeed;
  final double rainChance;
  final double rainAmount;
  final String windDirection;

  WeatherForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.condition,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.rainChance,
    required this.rainAmount,
    required this.windDirection,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      maxTemp: json['maxTemp']?.toDouble() ?? 0.0,
      minTemp: json['minTemp']?.toDouble() ?? 0.0,
      condition: json['condition'] ?? '',
      icon: json['icon'] ?? '',
      humidity: json['humidity'] ?? 0,
      windSpeed: json['windSpeed']?.toDouble() ?? 0.0,
      rainChance: json['rainChance']?.toDouble() ?? 0.0,
      rainAmount: json['rainAmount']?.toDouble() ?? 0.0,
      windDirection: json['windDirection'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'maxTemp': maxTemp,
      'minTemp': minTemp,
      'condition': condition,
      'icon': icon,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'rainChance': rainChance,
      'rainAmount': rainAmount,
      'windDirection': windDirection,
    };
  }
}
