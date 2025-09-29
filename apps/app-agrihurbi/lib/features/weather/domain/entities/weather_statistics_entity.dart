import 'package:equatable/equatable.dart';

/// Weather statistics entity for aggregated weather data analysis
/// Provides historical analysis and trends for weather measurements
class WeatherStatisticsEntity extends Equatable {
  /// Unique identifier for the statistics record
  final String id;
  
  /// Location identifier
  final String locationId;
  
  /// Location name
  final String locationName;
  
  /// Statistical period (daily, weekly, monthly, yearly)
  final String period;
  
  /// Start date for the statistical period
  final DateTime startDate;
  
  /// End date for the statistical period
  final DateTime endDate;
  
  /// Temperature statistics
  final double avgTemperature;
  final double minTemperature;
  final double maxTemperature;
  final double temperatureVariance;
  
  /// Humidity statistics
  final double avgHumidity;
  final double minHumidity;
  final double maxHumidity;
  final double humidityVariance;
  
  /// Pressure statistics
  final double avgPressure;
  final double minPressure;
  final double maxPressure;
  final double pressureVariance;
  
  /// Wind statistics
  final double avgWindSpeed;
  final double maxWindSpeed;
  final double avgWindDirection;
  final String predominantWindDirection;
  
  /// Precipitation statistics
  final double totalRainfall;
  final double avgDailyRainfall;
  final double maxDailyRainfall;
  final int rainyDays;
  final int dryDays;
  
  /// UV and visibility statistics
  final double avgUVIndex;
  final double maxUVIndex;
  final double avgVisibility;
  final double minVisibility;
  
  /// Weather condition distribution
  final Map<String, int> weatherConditionCounts;
  final String predominantCondition;
  
  /// Agricultural relevance metrics
  final int favorableDays;
  final int unfavorableDays;
  final double avgHeatIndex;
  final double avgDewPoint;
  
  /// Data quality metrics
  final int totalMeasurements;
  final int validMeasurements;
  final double dataCompleteness;
  final double avgDataQuality;
  
  /// Trend analysis (compared to previous period)
  final double temperatureTrend;
  final double humidityTrend;
  final double pressureTrend;
  final double rainfallTrend;
  
  /// Anomaly detection
  final List<String> detectedAnomalies;
  final double anomalyScore;
  
  /// Seasonal patterns
  final bool isSeasonalDataAvailable;
  final double seasonalDeviationScore;
  
  /// Record timestamps
  final DateTime calculatedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WeatherStatisticsEntity({
    required id,
    required locationId,
    required locationName,
    required period,
    required startDate,
    required endDate,
    required avgTemperature,
    required minTemperature,
    required maxTemperature,
    required temperatureVariance,
    required avgHumidity,
    required minHumidity,
    required maxHumidity,
    required humidityVariance,
    required avgPressure,
    required minPressure,
    required maxPressure,
    required pressureVariance,
    required avgWindSpeed,
    required maxWindSpeed,
    required avgWindDirection,
    required predominantWindDirection,
    required totalRainfall,
    required avgDailyRainfall,
    required maxDailyRainfall,
    required rainyDays,
    required dryDays,
    required avgUVIndex,
    required maxUVIndex,
    required avgVisibility,
    required minVisibility,
    required weatherConditionCounts,
    required predominantCondition,
    required favorableDays,
    required unfavorableDays,
    required avgHeatIndex,
    required avgDewPoint,
    required totalMeasurements,
    required validMeasurements,
    required dataCompleteness,
    required avgDataQuality,
    required temperatureTrend,
    required humidityTrend,
    required pressureTrend,
    required rainfallTrend,
    required detectedAnomalies,
    required anomalyScore,
    required isSeasonalDataAvailable,
    required seasonalDeviationScore,
    required calculatedAt,
    required createdAt,
    required updatedAt,
  });

  /// Creates empty statistics for initialization
  WeatherStatisticsEntity.empty()
      : id = '',
        locationId = '',
        locationName = '',
        period = '',
        startDate = DateTime.fromMillisecondsSinceEpoch(0),
        endDate = DateTime.fromMillisecondsSinceEpoch(0),
        avgTemperature = 0.0,
        minTemperature = 0.0,
        maxTemperature = 0.0,
        temperatureVariance = 0.0,
        avgHumidity = 0.0,
        minHumidity = 0.0,
        maxHumidity = 0.0,
        humidityVariance = 0.0,
        avgPressure = 0.0,
        minPressure = 0.0,
        maxPressure = 0.0,
        pressureVariance = 0.0,
        avgWindSpeed = 0.0,
        maxWindSpeed = 0.0,
        avgWindDirection = 0.0,
        predominantWindDirection = '',
        totalRainfall = 0.0,
        avgDailyRainfall = 0.0,
        maxDailyRainfall = 0.0,
        rainyDays = 0,
        dryDays = 0,
        avgUVIndex = 0.0,
        maxUVIndex = 0.0,
        avgVisibility = 0.0,
        minVisibility = 0.0,
        weatherConditionCounts = const {},
        predominantCondition = '',
        favorableDays = 0,
        unfavorableDays = 0,
        avgHeatIndex = 0.0,
        avgDewPoint = 0.0,
        totalMeasurements = 0,
        validMeasurements = 0,
        dataCompleteness = 0.0,
        avgDataQuality = 0.0,
        temperatureTrend = 0.0,
        humidityTrend = 0.0,
        pressureTrend = 0.0,
        rainfallTrend = 0.0,
        detectedAnomalies = const [],
        anomalyScore = 0.0,
        isSeasonalDataAvailable = false,
        seasonalDeviationScore = 0.0,
        calculatedAt = DateTime.fromMillisecondsSinceEpoch(0),
        createdAt = DateTime.fromMillisecondsSinceEpoch(0),
        updatedAt = DateTime.fromMillisecondsSinceEpoch(0);

  /// Get temperature range
  double get temperatureRange => maxTemperature - minTemperature;
  
  /// Get humidity range
  double get humidityRange => maxHumidity - minHumidity;
  
  /// Get pressure range  
  double get pressureRange => maxPressure - minPressure;

  /// Calculate period length in days
  int get periodLengthDays => endDate.difference(startDate).inDays + 1;

  /// Get rainy day percentage
  double get rainyDayPercentage {
    final totalDays = rainyDays + dryDays;
    return totalDays > 0 ? (rainyDays / totalDays) * 100 : 0.0;
  }

  /// Get favorable day percentage for agriculture
  double get favorableDayPercentage {
    final totalDays = favorableDays + unfavorableDays;
    return totalDays > 0 ? (favorableDays / totalDays) * 100 : 0.0;
  }

  /// Get data quality grade
  String get dataQualityGrade {
    if (avgDataQuality >= 0.95) return 'A';
    if (avgDataQuality >= 0.90) return 'B';
    if (avgDataQuality >= 0.80) return 'C';
    if (avgDataQuality >= 0.70) return 'D';
    return 'F';
  }

  /// Check if data is reliable for decision making
  bool get isDataReliable {
    return dataCompleteness >= 0.80 && 
           avgDataQuality >= 0.70 && 
           validMeasurements >= (periodLengthDays * 0.5);
  }

  /// Get most common weather condition
  String get mostCommonCondition => predominantCondition;

  /// Calculate weather variability score (0-1, higher = more variable)
  double get weatherVariabilityScore {
    final tempVar = temperatureVariance / (temperatureRange + 1);
    final humVar = humidityVariance / (humidityRange + 1);
    final pressVar = pressureVariance / (pressureRange + 1);
    
    return (tempVar + humVar + pressVar) / 3;
  }

  /// Get trend description for temperature
  String get temperatureTrendDescription {
    if (temperatureTrend.abs() < 0.5) return 'stable';
    if (temperatureTrend > 0) return 'warming';
    return 'cooling';
  }

  /// Get trend description for rainfall
  String get rainfallTrendDescription {
    if (rainfallTrend.abs() < 5) return 'stable';
    if (rainfallTrend > 0) return 'increasing';
    return 'decreasing';
  }

  /// Check if period had extreme weather
  bool get hasExtremeWeather {
    return detectedAnomalies.isNotEmpty || 
           anomalyScore > 0.7 ||
           maxWindSpeed > 80 ||
           maxDailyRainfall > 100 ||
           maxTemperature > 45 ||
           minTemperature < -10;
  }

  /// Get seasonal alignment score
  String get seasonalAlignment {
    if (!isSeasonalDataAvailable) return 'no_data';
    if (seasonalDeviationScore < 0.2) return 'typical';
    if (seasonalDeviationScore < 0.5) return 'somewhat_atypical';
    return 'highly_atypical';
  }

  /// Get comprehensive weather summary
  Map<String, dynamic> get weatherSummary {
    return {
      'period': period,
      'days': periodLengthDays,
      'temperature': {
        'avg': avgTemperature.toStringAsFixed(1),
        'range': '${minTemperature.toStringAsFixed(1)} - ${maxTemperature.toStringAsFixed(1)}°C',
        'trend': temperatureTrendDescription,
      },
      'precipitation': {
        'total': '${totalRainfall.toStringAsFixed(1)}mm',
        'rainy_days': rainyDays,
        'dry_days': dryDays,
        'trend': rainfallTrendDescription,
      },
      'conditions': {
        'predominant': predominantCondition,
        'favorable_days': favorableDays,
        'variability': weatherVariabilityScore.toStringAsFixed(2),
      },
      'quality': {
        'grade': dataQualityGrade,
        'completeness': '${(dataCompleteness * 100).toStringAsFixed(1)}%',
        'reliable': isDataReliable,
      },
      'anomalies': detectedAnomalies.length,
      'extreme_weather': hasExtremeWeather,
    };
  }

  /// Create copy with modified properties
  WeatherStatisticsEntity copyWith({
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
    return WeatherStatisticsEntity(
      id: id ?? id,
      locationId: locationId ?? locationId,
      locationName: locationName ?? locationName,
      period: period ?? period,
      startDate: startDate ?? startDate,
      endDate: endDate ?? endDate,
      avgTemperature: avgTemperature ?? avgTemperature,
      minTemperature: minTemperature ?? minTemperature,
      maxTemperature: maxTemperature ?? maxTemperature,
      temperatureVariance: temperatureVariance ?? temperatureVariance,
      avgHumidity: avgHumidity ?? avgHumidity,
      minHumidity: minHumidity ?? minHumidity,
      maxHumidity: maxHumidity ?? maxHumidity,
      humidityVariance: humidityVariance ?? humidityVariance,
      avgPressure: avgPressure ?? avgPressure,
      minPressure: minPressure ?? minPressure,
      maxPressure: maxPressure ?? maxPressure,
      pressureVariance: pressureVariance ?? pressureVariance,
      avgWindSpeed: avgWindSpeed ?? avgWindSpeed,
      maxWindSpeed: maxWindSpeed ?? maxWindSpeed,
      avgWindDirection: avgWindDirection ?? avgWindDirection,
      predominantWindDirection: predominantWindDirection ?? predominantWindDirection,
      totalRainfall: totalRainfall ?? totalRainfall,
      avgDailyRainfall: avgDailyRainfall ?? avgDailyRainfall,
      maxDailyRainfall: maxDailyRainfall ?? maxDailyRainfall,
      rainyDays: rainyDays ?? rainyDays,
      dryDays: dryDays ?? dryDays,
      avgUVIndex: avgUVIndex ?? avgUVIndex,
      maxUVIndex: maxUVIndex ?? maxUVIndex,
      avgVisibility: avgVisibility ?? avgVisibility,
      minVisibility: minVisibility ?? minVisibility,
      weatherConditionCounts: weatherConditionCounts ?? weatherConditionCounts,
      predominantCondition: predominantCondition ?? predominantCondition,
      favorableDays: favorableDays ?? favorableDays,
      unfavorableDays: unfavorableDays ?? unfavorableDays,
      avgHeatIndex: avgHeatIndex ?? avgHeatIndex,
      avgDewPoint: avgDewPoint ?? avgDewPoint,
      totalMeasurements: totalMeasurements ?? totalMeasurements,
      validMeasurements: validMeasurements ?? validMeasurements,
      dataCompleteness: dataCompleteness ?? dataCompleteness,
      avgDataQuality: avgDataQuality ?? avgDataQuality,
      temperatureTrend: temperatureTrend ?? temperatureTrend,
      humidityTrend: humidityTrend ?? humidityTrend,
      pressureTrend: pressureTrend ?? pressureTrend,
      rainfallTrend: rainfallTrend ?? rainfallTrend,
      detectedAnomalies: detectedAnomalies ?? detectedAnomalies,
      anomalyScore: anomalyScore ?? anomalyScore,
      isSeasonalDataAvailable: isSeasonalDataAvailable ?? isSeasonalDataAvailable,
      seasonalDeviationScore: seasonalDeviationScore ?? seasonalDeviationScore,
      calculatedAt: calculatedAt ?? calculatedAt,
      createdAt: createdAt ?? createdAt,
      updatedAt: updatedAt ?? updatedAt,
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
    return 'WeatherStatisticsEntity('
        'id: $id, '
        'location: $locationName, '
        'period: $period, '
        'temp: ${avgTemperature.toStringAsFixed(1)}°C, '
        'rain: ${totalRainfall.toStringAsFixed(1)}mm'
        ')';
  }
}