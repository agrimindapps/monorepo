import 'package:core/core.dart';

import '../../domain/entities/weather_statistics_entity.dart';


/// Weather statistics model
/// Converts between domain entity and data model
class WeatherStatisticsModel extends Equatable {
  final String id;

  final String locationId;

  final String locationName;

  final String period;

  final DateTime startDate;

  final DateTime endDate;

  final double avgTemperature;

  final double minTemperature;

  final double maxTemperature;

  final double temperatureVariance;

  final double avgHumidity;

  final double minHumidity;

  final double maxHumidity;

  final double humidityVariance;

  final double avgPressure;

  final double minPressure;

  final double maxPressure;

  final double pressureVariance;

  final double avgWindSpeed;

  final double maxWindSpeed;

  final double avgWindDirection;

  final String predominantWindDirection;

  final double totalRainfall;

  final double avgDailyRainfall;

  final double maxDailyRainfall;

  final int rainyDays;

  final int dryDays;

  final double avgUVIndex;

  final double maxUVIndex;

  final double avgVisibility;

  final double minVisibility;

  final Map<String, int> weatherConditionCounts;

  final String predominantCondition;

  final int favorableDays;

  final int unfavorableDays;

  final double avgHeatIndex;

  final double avgDewPoint;

  final int totalMeasurements;

  final int validMeasurements;

  final double dataCompleteness;

  final double avgDataQuality;

  final double temperatureTrend;

  final double humidityTrend;

  final double pressureTrend;

  final double rainfallTrend;

  final List<String> detectedAnomalies;

  final double anomalyScore;

  final bool isSeasonalDataAvailable;

  final double seasonalDeviationScore;

  final DateTime calculatedAt;

  final DateTime createdAt;

  final DateTime updatedAt;

  const WeatherStatisticsModel({
    required this.id,
    required this.locationId,
    required this.locationName,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.avgTemperature,
    required this.minTemperature,
    required this.maxTemperature,
    required this.temperatureVariance,
    required this.avgHumidity,
    required this.minHumidity,
    required this.maxHumidity,
    required this.humidityVariance,
    required this.avgPressure,
    required this.minPressure,
    required this.maxPressure,
    required this.pressureVariance,
    required this.avgWindSpeed,
    required this.maxWindSpeed,
    required this.avgWindDirection,
    required this.predominantWindDirection,
    required this.totalRainfall,
    required this.avgDailyRainfall,
    required this.maxDailyRainfall,
    required this.rainyDays,
    required this.dryDays,
    required this.avgUVIndex,
    required this.maxUVIndex,
    required this.avgVisibility,
    required this.minVisibility,
    required this.weatherConditionCounts,
    required this.predominantCondition,
    required this.favorableDays,
    required this.unfavorableDays,
    required this.avgHeatIndex,
    required this.avgDewPoint,
    required this.totalMeasurements,
    required this.validMeasurements,
    required this.dataCompleteness,
    required this.avgDataQuality,
    required this.temperatureTrend,
    required this.humidityTrend,
    required this.pressureTrend,
    required this.rainfallTrend,
    required this.detectedAnomalies,
    required this.anomalyScore,
    required this.isSeasonalDataAvailable,
    required this.seasonalDeviationScore,
    required this.calculatedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create model from domain entity
  factory WeatherStatisticsModel.fromEntity(WeatherStatisticsEntity entity) {
    return WeatherStatisticsModel(
      id: entity.id,
      locationId: entity.locationId,
      locationName: entity.locationName,
      period: entity.period,
      startDate: entity.startDate,
      endDate: entity.endDate,
      avgTemperature: entity.avgTemperature,
      minTemperature: entity.minTemperature,
      maxTemperature: entity.maxTemperature,
      temperatureVariance: entity.temperatureVariance,
      avgHumidity: entity.avgHumidity,
      minHumidity: entity.minHumidity,
      maxHumidity: entity.maxHumidity,
      humidityVariance: entity.humidityVariance,
      avgPressure: entity.avgPressure,
      minPressure: entity.minPressure,
      maxPressure: entity.maxPressure,
      pressureVariance: entity.pressureVariance,
      avgWindSpeed: entity.avgWindSpeed,
      maxWindSpeed: entity.maxWindSpeed,
      avgWindDirection: entity.avgWindDirection,
      predominantWindDirection: entity.predominantWindDirection,
      totalRainfall: entity.totalRainfall,
      avgDailyRainfall: entity.avgDailyRainfall,
      maxDailyRainfall: entity.maxDailyRainfall,
      rainyDays: entity.rainyDays,
      dryDays: entity.dryDays,
      avgUVIndex: entity.avgUVIndex,
      maxUVIndex: entity.maxUVIndex,
      avgVisibility: entity.avgVisibility,
      minVisibility: entity.minVisibility,
      weatherConditionCounts: entity.weatherConditionCounts,
      predominantCondition: entity.predominantCondition,
      favorableDays: entity.favorableDays,
      unfavorableDays: entity.unfavorableDays,
      avgHeatIndex: entity.avgHeatIndex,
      avgDewPoint: entity.avgDewPoint,
      totalMeasurements: entity.totalMeasurements,
      validMeasurements: entity.validMeasurements,
      dataCompleteness: entity.dataCompleteness,
      avgDataQuality: entity.avgDataQuality,
      temperatureTrend: entity.temperatureTrend,
      humidityTrend: entity.humidityTrend,
      pressureTrend: entity.pressureTrend,
      rainfallTrend: entity.rainfallTrend,
      detectedAnomalies: entity.detectedAnomalies,
      anomalyScore: entity.anomalyScore,
      isSeasonalDataAvailable: entity.isSeasonalDataAvailable,
      seasonalDeviationScore: entity.seasonalDeviationScore,
      calculatedAt: entity.calculatedAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert to domain entity
  WeatherStatisticsEntity toEntity() {
    return WeatherStatisticsEntity(
      id: id,
      locationId: locationId,
      locationName: locationName,
      period: period,
      startDate: startDate,
      endDate: endDate,
      avgTemperature: avgTemperature,
      minTemperature: minTemperature,
      maxTemperature: maxTemperature,
      temperatureVariance: temperatureVariance,
      avgHumidity: avgHumidity,
      minHumidity: minHumidity,
      maxHumidity: maxHumidity,
      humidityVariance: humidityVariance,
      avgPressure: avgPressure,
      minPressure: minPressure,
      maxPressure: maxPressure,
      pressureVariance: pressureVariance,
      avgWindSpeed: avgWindSpeed,
      maxWindSpeed: maxWindSpeed,
      avgWindDirection: avgWindDirection,
      predominantWindDirection: predominantWindDirection,
      totalRainfall: totalRainfall,
      avgDailyRainfall: avgDailyRainfall,
      maxDailyRainfall: maxDailyRainfall,
      rainyDays: rainyDays,
      dryDays: dryDays,
      avgUVIndex: avgUVIndex,
      maxUVIndex: maxUVIndex,
      avgVisibility: avgVisibility,
      minVisibility: minVisibility,
      weatherConditionCounts: weatherConditionCounts,
      predominantCondition: predominantCondition,
      favorableDays: favorableDays,
      unfavorableDays: unfavorableDays,
      avgHeatIndex: avgHeatIndex,
      avgDewPoint: avgDewPoint,
      totalMeasurements: totalMeasurements,
      validMeasurements: validMeasurements,
      dataCompleteness: dataCompleteness,
      avgDataQuality: avgDataQuality,
      temperatureTrend: temperatureTrend,
      humidityTrend: humidityTrend,
      pressureTrend: pressureTrend,
      rainfallTrend: rainfallTrend,
      detectedAnomalies: detectedAnomalies,
      anomalyScore: anomalyScore,
      isSeasonalDataAvailable: isSeasonalDataAvailable,
      seasonalDeviationScore: seasonalDeviationScore,
      calculatedAt: calculatedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create model from JSON (for API integration)
  factory WeatherStatisticsModel.fromJson(Map<String, dynamic> json) {
    return WeatherStatisticsModel(
      id: json['id']?.toString() ?? '',
      locationId: json['location_id']?.toString() ?? '',
      locationName: json['location_name']?.toString() ?? '',
      period: json['period']?.toString() ?? '',
      startDate: DateTime.tryParse(json['start_date']?.toString() ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date']?.toString() ?? '') ?? DateTime.now(),
      avgTemperature: (json['avg_temperature'] as num?)?.toDouble() ?? 0.0,
      minTemperature: (json['min_temperature'] as num?)?.toDouble() ?? 0.0,
      maxTemperature: (json['max_temperature'] as num?)?.toDouble() ?? 0.0,
      temperatureVariance: (json['temperature_variance'] as num?)?.toDouble() ?? 0.0,
      avgHumidity: (json['avg_humidity'] as num?)?.toDouble() ?? 0.0,
      minHumidity: (json['min_humidity'] as num?)?.toDouble() ?? 0.0,
      maxHumidity: (json['max_humidity'] as num?)?.toDouble() ?? 0.0,
      humidityVariance: (json['humidity_variance'] as num?)?.toDouble() ?? 0.0,
      avgPressure: (json['avg_pressure'] as num?)?.toDouble() ?? 0.0,
      minPressure: (json['min_pressure'] as num?)?.toDouble() ?? 0.0,
      maxPressure: (json['max_pressure'] as num?)?.toDouble() ?? 0.0,
      pressureVariance: (json['pressure_variance'] as num?)?.toDouble() ?? 0.0,
      avgWindSpeed: (json['avg_wind_speed'] as num?)?.toDouble() ?? 0.0,
      maxWindSpeed: (json['max_wind_speed'] as num?)?.toDouble() ?? 0.0,
      avgWindDirection: (json['avg_wind_direction'] as num?)?.toDouble() ?? 0.0,
      predominantWindDirection: json['predominant_wind_direction']?.toString() ?? '',
      totalRainfall: (json['total_rainfall'] as num?)?.toDouble() ?? 0.0,
      avgDailyRainfall: (json['avg_daily_rainfall'] as num?)?.toDouble() ?? 0.0,
      maxDailyRainfall: (json['max_daily_rainfall'] as num?)?.toDouble() ?? 0.0,
      rainyDays: (json['rainy_days'] as num?)?.toInt() ?? 0,
      dryDays: (json['dry_days'] as num?)?.toInt() ?? 0,
      avgUVIndex: (json['avg_uv_index'] as num?)?.toDouble() ?? 0.0,
      maxUVIndex: (json['max_uv_index'] as num?)?.toDouble() ?? 0.0,
      avgVisibility: (json['avg_visibility'] as num?)?.toDouble() ?? 0.0,
      minVisibility: (json['min_visibility'] as num?)?.toDouble() ?? 0.0,
      weatherConditionCounts: _parseConditionCounts(json['weather_condition_counts']),
      predominantCondition: json['predominant_condition']?.toString() ?? '',
      favorableDays: (json['favorable_days'] as num?)?.toInt() ?? 0,
      unfavorableDays: (json['unfavorable_days'] as num?)?.toInt() ?? 0,
      avgHeatIndex: (json['avg_heat_index'] as num?)?.toDouble() ?? 0.0,
      avgDewPoint: (json['avg_dew_point'] as num?)?.toDouble() ?? 0.0,
      totalMeasurements: (json['total_measurements'] as num?)?.toInt() ?? 0,
      validMeasurements: (json['valid_measurements'] as num?)?.toInt() ?? 0,
      dataCompleteness: (json['data_completeness'] as num?)?.toDouble() ?? 0.0,
      avgDataQuality: (json['avg_data_quality'] as num?)?.toDouble() ?? 0.0,
      temperatureTrend: (json['temperature_trend'] as num?)?.toDouble() ?? 0.0,
      humidityTrend: (json['humidity_trend'] as num?)?.toDouble() ?? 0.0,
      pressureTrend: (json['pressure_trend'] as num?)?.toDouble() ?? 0.0,
      rainfallTrend: (json['rainfall_trend'] as num?)?.toDouble() ?? 0.0,
      detectedAnomalies: _parseAnomalies(json['detected_anomalies']),
      anomalyScore: (json['anomaly_score'] as num?)?.toDouble() ?? 0.0,
      isSeasonalDataAvailable: json['is_seasonal_data_available'] == true,
      seasonalDeviationScore: (json['seasonal_deviation_score'] as num?)?.toDouble() ?? 0.0,
      calculatedAt: DateTime.tryParse(json['calculated_at']?.toString() ?? '') ?? DateTime.now(),
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
      'period': period,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'avg_temperature': avgTemperature,
      'min_temperature': minTemperature,
      'max_temperature': maxTemperature,
      'temperature_variance': temperatureVariance,
      'avg_humidity': avgHumidity,
      'min_humidity': minHumidity,
      'max_humidity': maxHumidity,
      'humidity_variance': humidityVariance,
      'avg_pressure': avgPressure,
      'min_pressure': minPressure,
      'max_pressure': maxPressure,
      'pressure_variance': pressureVariance,
      'avg_wind_speed': avgWindSpeed,
      'max_wind_speed': maxWindSpeed,
      'avg_wind_direction': avgWindDirection,
      'predominant_wind_direction': predominantWindDirection,
      'total_rainfall': totalRainfall,
      'avg_daily_rainfall': avgDailyRainfall,
      'max_daily_rainfall': maxDailyRainfall,
      'rainy_days': rainyDays,
      'dry_days': dryDays,
      'avg_uv_index': avgUVIndex,
      'max_uv_index': maxUVIndex,
      'avg_visibility': avgVisibility,
      'min_visibility': minVisibility,
      'weather_condition_counts': weatherConditionCounts,
      'predominant_condition': predominantCondition,
      'favorable_days': favorableDays,
      'unfavorable_days': unfavorableDays,
      'avg_heat_index': avgHeatIndex,
      'avg_dew_point': avgDewPoint,
      'total_measurements': totalMeasurements,
      'valid_measurements': validMeasurements,
      'data_completeness': dataCompleteness,
      'avg_data_quality': avgDataQuality,
      'temperature_trend': temperatureTrend,
      'humidity_trend': humidityTrend,
      'pressure_trend': pressureTrend,
      'rainfall_trend': rainfallTrend,
      'detected_anomalies': detectedAnomalies,
      'anomaly_score': anomalyScore,
      'is_seasonal_data_available': isSeasonalDataAvailable,
      'seasonal_deviation_score': seasonalDeviationScore,
      'calculated_at': calculatedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create summary statistics model
  factory WeatherStatisticsModel.summary({
    required String locationId,
    required String locationName,
    required String period,
    required DateTime startDate,
    required DateTime endDate,
    required Map<String, dynamic> summaryData,
  }) {
    return WeatherStatisticsModel(
      id: 'summary_${locationId}_${period}_${startDate.millisecondsSinceEpoch}',
      locationId: locationId,
      locationName: locationName,
      period: period,
      startDate: startDate,
      endDate: endDate,
      avgTemperature: ((summaryData['avg_temperature'] as num?)?.toDouble()) ?? 0.0,
      minTemperature: ((summaryData['min_temperature'] as num?)?.toDouble()) ?? 0.0,
      maxTemperature: ((summaryData['max_temperature'] as num?)?.toDouble()) ?? 0.0,
      temperatureVariance: ((summaryData['temperature_variance'] as num?)?.toDouble()) ?? 0.0,
      avgHumidity: ((summaryData['avg_humidity'] as num?)?.toDouble()) ?? 0.0,
      minHumidity: ((summaryData['min_humidity'] as num?)?.toDouble()) ?? 0.0,
      maxHumidity: ((summaryData['max_humidity'] as num?)?.toDouble()) ?? 0.0,
      humidityVariance: ((summaryData['humidity_variance'] as num?)?.toDouble()) ?? 0.0,
      avgPressure: ((summaryData['avg_pressure'] as num?)?.toDouble()) ?? 1013.25,
      minPressure: ((summaryData['min_pressure'] as num?)?.toDouble()) ?? 1000.0,
      maxPressure: ((summaryData['max_pressure'] as num?)?.toDouble()) ?? 1030.0,
      pressureVariance: ((summaryData['pressure_variance'] as num?)?.toDouble()) ?? 0.0,
      avgWindSpeed: ((summaryData['avg_wind_speed'] as num?)?.toDouble()) ?? 0.0,
      maxWindSpeed: ((summaryData['max_wind_speed'] as num?)?.toDouble()) ?? 0.0,
      avgWindDirection: ((summaryData['avg_wind_direction'] as num?)?.toDouble()) ?? 0.0,
      predominantWindDirection: summaryData['predominant_wind_direction']?.toString() ?? 'N',
      totalRainfall: ((summaryData['total_rainfall'] as num?)?.toDouble()) ?? 0.0,
      avgDailyRainfall: ((summaryData['avg_daily_rainfall'] as num?)?.toDouble()) ?? 0.0,
      maxDailyRainfall: ((summaryData['max_daily_rainfall'] as num?)?.toDouble()) ?? 0.0,
      rainyDays: (summaryData['rainy_days'] as num?)?.toInt() ?? 0,
      dryDays: (summaryData['dry_days'] as num?)?.toInt() ?? 0,
      avgUVIndex: ((summaryData['avg_uv_index'] as num?)?.toDouble()) ?? 0.0,
      maxUVIndex: ((summaryData['max_uv_index'] as num?)?.toDouble()) ?? 0.0,
      avgVisibility: ((summaryData['avg_visibility'] as num?)?.toDouble()) ?? 10.0,
      minVisibility: ((summaryData['min_visibility'] as num?)?.toDouble()) ?? 0.0,
      weatherConditionCounts: _parseConditionCounts(summaryData['weather_condition_counts']),
      predominantCondition: summaryData['predominant_condition']?.toString() ?? 'unknown',
      favorableDays: (summaryData['favorable_days'] as num?)?.toInt() ?? 0,
      unfavorableDays: (summaryData['unfavorable_days'] as num?)?.toInt() ?? 0,
      avgHeatIndex: ((summaryData['avg_heat_index'] as num?)?.toDouble()) ?? 0.0,
      avgDewPoint: ((summaryData['avg_dew_point'] as num?)?.toDouble()) ?? 0.0,
      totalMeasurements: (summaryData['total_measurements'] as num?)?.toInt() ?? 0,
      validMeasurements: (summaryData['valid_measurements'] as num?)?.toInt() ?? 0,
      dataCompleteness: ((summaryData['data_completeness'] as num?)?.toDouble()) ?? 1.0,
      avgDataQuality: ((summaryData['avg_data_quality'] as num?)?.toDouble()) ?? 1.0,
      temperatureTrend: ((summaryData['temperature_trend'] as num?)?.toDouble()) ?? 0.0,
      humidityTrend: ((summaryData['humidity_trend'] as num?)?.toDouble()) ?? 0.0,
      pressureTrend: ((summaryData['pressure_trend'] as num?)?.toDouble()) ?? 0.0,
      rainfallTrend: ((summaryData['rainfall_trend'] as num?)?.toDouble()) ?? 0.0,
      detectedAnomalies: _parseAnomalies(summaryData['detected_anomalies']),
      anomalyScore: ((summaryData['anomaly_score'] as num?)?.toDouble()) ?? 0.0,
      isSeasonalDataAvailable: summaryData['is_seasonal_data_available'] == true,
      seasonalDeviationScore: ((summaryData['seasonal_deviation_score'] as num?)?.toDouble()) ?? 0.0,
      calculatedAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create copy with updated properties
  WeatherStatisticsModel copyWith({
    String? id,
    String? locationId,
    String? locationName,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
    double? avgTemperature,
    double? minTemperature,
    double? maxTemperature,
    double? temperatureVariance,
    double? avgHumidity,
    double? minHumidity,
    double? maxHumidity,
    double? humidityVariance,
    double? avgPressure,
    double? minPressure,
    double? maxPressure,
    double? pressureVariance,
    double? avgWindSpeed,
    double? maxWindSpeed,
    double? avgWindDirection,
    String? predominantWindDirection,
    double? totalRainfall,
    double? avgDailyRainfall,
    double? maxDailyRainfall,
    int? rainyDays,
    int? dryDays,
    double? avgUVIndex,
    double? maxUVIndex,
    double? avgVisibility,
    double? minVisibility,
    Map<String, int>? weatherConditionCounts,
    String? predominantCondition,
    int? favorableDays,
    int? unfavorableDays,
    double? avgHeatIndex,
    double? avgDewPoint,
    int? totalMeasurements,
    int? validMeasurements,
    double? dataCompleteness,
    double? avgDataQuality,
    double? temperatureTrend,
    double? humidityTrend,
    double? pressureTrend,
    double? rainfallTrend,
    List<String>? detectedAnomalies,
    double? anomalyScore,
    bool? isSeasonalDataAvailable,
    double? seasonalDeviationScore,
    DateTime? calculatedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WeatherStatisticsModel(
      id: id ?? this.id,
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      avgTemperature: avgTemperature ?? this.avgTemperature,
      minTemperature: minTemperature ?? this.minTemperature,
      maxTemperature: maxTemperature ?? this.maxTemperature,
      temperatureVariance: temperatureVariance ?? this.temperatureVariance,
      avgHumidity: avgHumidity ?? this.avgHumidity,
      minHumidity: minHumidity ?? this.minHumidity,
      maxHumidity: maxHumidity ?? this.maxHumidity,
      humidityVariance: humidityVariance ?? this.humidityVariance,
      avgPressure: avgPressure ?? this.avgPressure,
      minPressure: minPressure ?? this.minPressure,
      maxPressure: maxPressure ?? this.maxPressure,
      pressureVariance: pressureVariance ?? this.pressureVariance,
      avgWindSpeed: avgWindSpeed ?? this.avgWindSpeed,
      maxWindSpeed: maxWindSpeed ?? this.maxWindSpeed,
      avgWindDirection: avgWindDirection ?? this.avgWindDirection,
      predominantWindDirection: predominantWindDirection ?? this.predominantWindDirection,
      totalRainfall: totalRainfall ?? this.totalRainfall,
      avgDailyRainfall: avgDailyRainfall ?? this.avgDailyRainfall,
      maxDailyRainfall: maxDailyRainfall ?? this.maxDailyRainfall,
      rainyDays: rainyDays ?? this.rainyDays,
      dryDays: dryDays ?? this.dryDays,
      avgUVIndex: avgUVIndex ?? this.avgUVIndex,
      maxUVIndex: maxUVIndex ?? this.maxUVIndex,
      avgVisibility: avgVisibility ?? this.avgVisibility,
      minVisibility: minVisibility ?? this.minVisibility,
      weatherConditionCounts: weatherConditionCounts ?? this.weatherConditionCounts,
      predominantCondition: predominantCondition ?? this.predominantCondition,
      favorableDays: favorableDays ?? this.favorableDays,
      unfavorableDays: unfavorableDays ?? this.unfavorableDays,
      avgHeatIndex: avgHeatIndex ?? this.avgHeatIndex,
      avgDewPoint: avgDewPoint ?? this.avgDewPoint,
      totalMeasurements: totalMeasurements ?? this.totalMeasurements,
      validMeasurements: validMeasurements ?? this.validMeasurements,
      dataCompleteness: dataCompleteness ?? this.dataCompleteness,
      avgDataQuality: avgDataQuality ?? this.avgDataQuality,
      temperatureTrend: temperatureTrend ?? this.temperatureTrend,
      humidityTrend: humidityTrend ?? this.humidityTrend,
      pressureTrend: pressureTrend ?? this.pressureTrend,
      rainfallTrend: rainfallTrend ?? this.rainfallTrend,
      detectedAnomalies: detectedAnomalies ?? this.detectedAnomalies,
      anomalyScore: anomalyScore ?? this.anomalyScore,
      isSeasonalDataAvailable: isSeasonalDataAvailable ?? this.isSeasonalDataAvailable,
      seasonalDeviationScore: seasonalDeviationScore ?? this.seasonalDeviationScore,
      calculatedAt: calculatedAt ?? this.calculatedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        locationId,
        locationName,
        period,
        startDate,
        endDate,
        avgTemperature,
        minTemperature,
        maxTemperature,
        temperatureVariance,
        avgHumidity,
        minHumidity,
        maxHumidity,
        humidityVariance,
        avgPressure,
        minPressure,
        maxPressure,
        pressureVariance,
        avgWindSpeed,
        maxWindSpeed,
        avgWindDirection,
        predominantWindDirection,
        totalRainfall,
        avgDailyRainfall,
        maxDailyRainfall,
        rainyDays,
        dryDays,
        avgUVIndex,
        maxUVIndex,
        avgVisibility,
        minVisibility,
        weatherConditionCounts,
        predominantCondition,
        favorableDays,
        unfavorableDays,
        avgHeatIndex,
        avgDewPoint,
        totalMeasurements,
        validMeasurements,
        dataCompleteness,
        avgDataQuality,
        temperatureTrend,
        humidityTrend,
        pressureTrend,
        rainfallTrend,
        detectedAnomalies,
        anomalyScore,
        isSeasonalDataAvailable,
        seasonalDeviationScore,
        calculatedAt,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'WeatherStatisticsModel('
        'id: $id, '
        'location: $locationName, '
        'period: $period, '
        'temp: ${avgTemperature.toStringAsFixed(1)}°C, '
        'rain: ${totalRainfall.toStringAsFixed(1)}mm'
        ')';
  }

  /// Parse weather condition counts from various formats
  static Map<String, int> _parseConditionCounts(dynamic conditionCounts) {
    if (conditionCounts is Map<String, int>) {
      return conditionCounts;
    } else if (conditionCounts is Map) {
      return Map<String, int>.from(
        conditionCounts.map((key, value) => MapEntry(key.toString(), (value as num?)?.toInt() ?? 0))
      );
    } else {
      return <String, int>{};
    }
  }

  /// Parse anomalies from various formats
  static List<String> _parseAnomalies(dynamic anomalies) {
    if (anomalies is List<String>) {
      return anomalies;
    } else if (anomalies is List) {
      return anomalies.map((item) => item.toString()).toList();
    } else {
      return <String>[];
    }
  }
}
