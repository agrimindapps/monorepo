import 'dart:math' as math;

import 'package:dartz/dartz.dart';

import '../entities/weather_measurement_entity.dart';
import '../entities/weather_statistics_entity.dart';
import '../failures/weather_failures.dart';
import '../repositories/weather_repository.dart';

/// Use case for calculating comprehensive weather statistics
/// Provides various statistical analysis and trend calculations
class CalculateWeatherStatistics {
  final WeatherRepository _repository;

  const CalculateWeatherStatistics(this._repository);

  /// Calculate weather statistics for a specific period
  Future<Either<WeatherFailure, WeatherStatisticsEntity>> call({
    required String locationId,
    required String period,
    required DateTime startDate,
    required DateTime endDate,
    bool forceRecalculate = false,
  }) async {
    try {
      // Validate inputs
      final validationResult = _validateInputs(locationId, period, startDate, endDate);
      if (validationResult.isLeft()) {
        return validationResult.fold(
          (failure) => Left(failure),
          (_) => throw Exception('Unexpected validation success'),
        );
      }

      // Get weather measurements for the period
      final measurementsResult = await _repository.getMeasurementsByDateRange(
        startDate,
        endDate,
        locationId: locationId,
      );

      return measurementsResult.fold(
        (failure) => Left(failure),
        (measurements) async {
          if (measurements.isEmpty) {
            return Left(InsufficientWeatherDataFailure(
              period,
              0,
              _getMinimumRequiredMeasurements(period),
            ));
          }

          // Check if we have enough data for reliable statistics
          final minRequired = _getMinimumRequiredMeasurements(period);
          if (measurements.length < minRequired) {
            return Left(InsufficientWeatherDataFailure(
              period,
              measurements.length,
              minRequired,
            ));
          }

          // Calculate statistics
          final statistics = await _calculateStatistics(
            locationId,
            period,
            startDate,
            endDate,
            measurements,
          );

          // Save calculated statistics
          final saveResult = await _repository.calculateStatistics(
            locationId: locationId,
            period: period,
            startDate: startDate,
            endDate: endDate,
            forceRecalculate: forceRecalculate,
          );

          return saveResult.fold(
            (failure) => Right(statistics), // Return calculated stats even if save fails
            (saved) => Right(statistics),
          );
        },
      );
    } catch (e) {
      return Left(WeatherStatisticsCalculationFailure(e.toString(), period));
    }
  }

  /// Calculate daily statistics
  Future<Either<WeatherFailure, WeatherStatisticsEntity>> daily({
    required String locationId,
    required DateTime date,
  }) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(microseconds: 1));

    return await call(
      locationId: locationId,
      period: 'daily',
      startDate: startOfDay,
      endDate: endOfDay,
    );
  }

  /// Calculate weekly statistics
  Future<Either<WeatherFailure, WeatherStatisticsEntity>> weekly({
    required String locationId,
    required DateTime weekDate,
  }) async {
    final startOfWeek = weekDate.subtract(Duration(days: weekDate.weekday - 1));
    final startOfWeekDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endOfWeek = startOfWeekDay.add(const Duration(days: 7));

    return await call(
      locationId: locationId,
      period: 'weekly',
      startDate: startOfWeekDay,
      endDate: endOfWeek,
    );
  }

  /// Calculate monthly statistics
  Future<Either<WeatherFailure, WeatherStatisticsEntity>> monthly({
    required String locationId,
    required DateTime monthDate,
  }) async {
    final startOfMonth = DateTime(monthDate.year, monthDate.month, 1);
    final endOfMonth = DateTime(monthDate.year, monthDate.month + 1, 1);

    return await call(
      locationId: locationId,
      period: 'monthly',
      startDate: startOfMonth,
      endDate: endOfMonth,
    );
  }

  /// Calculate yearly statistics
  Future<Either<WeatherFailure, WeatherStatisticsEntity>> yearly({
    required String locationId,
    required int year,
  }) async {
    final startOfYear = DateTime(year, 1, 1);
    final endOfYear = DateTime(year + 1, 1, 1);

    return await call(
      locationId: locationId,
      period: 'yearly',
      startDate: startOfYear,
      endDate: endOfYear,
    );
  }

  /// Calculate statistics for multiple periods in batch
  Future<Either<WeatherFailure, List<WeatherStatisticsEntity>>> batch({
    required String locationId,
    required String period,
    required List<DateRange> dateRanges,
  }) async {
    try {
      final List<WeatherStatisticsEntity> results = [];
      final List<String> errors = [];

      for (final range in dateRanges) {
        final result = await call(
          locationId: locationId,
          period: period,
          startDate: range.start,
          endDate: range.end,
        );

        result.fold(
          (failure) => errors.add(failure.toString()),
          (stats) => results.add(stats),
        );
      }

      if (errors.isNotEmpty && results.isEmpty) {
        return Left(WeatherStatisticsCalculationFailure(
          'Failed to calculate any statistics: ${errors.join(', ')}'
        ));
      }

      return Right(results);
    } catch (e) {
      return Left(WeatherStatisticsCalculationFailure(e.toString(), period));
    }
  }

  /// Compare statistics between two periods
  Future<Either<WeatherFailure, Map<String, dynamic>>> compare({
    required String locationId,
    required String period,
    required DateTime period1Start,
    required DateTime period1End,
    required DateTime period2Start,
    required DateTime period2End,
  }) async {
    try {
      final stats1Result = await call(
        locationId: locationId,
        period: period,
        startDate: period1Start,
        endDate: period1End,
      );

      final stats2Result = await call(
        locationId: locationId,
        period: period,
        startDate: period2Start,
        endDate: period2End,
      );

      return stats1Result.fold(
        (failure) => Left(failure),
        (stats1) => stats2Result.fold(
          (failure) => Left(failure),
          (stats2) => Right(_compareStatistics(stats1, stats2)),
        ),
      );
    } catch (e) {
      return Left(WeatherStatisticsCalculationFailure(e.toString(), period));
    }
  }

  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================

  /// Validate calculation inputs
  Either<WeatherFailure, void> _validateInputs(
    String locationId,
    String period,
    DateTime startDate,
    DateTime endDate,
  ) {
    if (locationId.trim().isEmpty) {
      return const Left(WeatherStatisticsFailure('Location ID cannot be empty'));
    }

    final validPeriods = ['daily', 'weekly', 'monthly', 'yearly'];
    if (!validPeriods.contains(period.toLowerCase())) {
      return Left(WeatherStatisticsFailure(
        'Invalid period. Must be one of: ${validPeriods.join(', ')}'
      ));
    }

    if (startDate.isAfter(endDate)) {
      return Left(InvalidDateRangeFailure(
        startDate,
        endDate,
        'Start date must be before end date'
      ));
    }

    // Check if date range is reasonable for the period
    final daysDifference = endDate.difference(startDate).inDays;
    switch (period.toLowerCase()) {
      case 'daily':
        if (daysDifference > 1) {
          return Left(InvalidDateRangeFailure(
            startDate,
            endDate,
            'Daily period should not exceed 1 day'
          ));
        }
        break;
      case 'weekly':
        if (daysDifference > 8) {
          return Left(InvalidDateRangeFailure(
            startDate,
            endDate,
            'Weekly period should not exceed 8 days'
          ));
        }
        break;
      case 'monthly':
        if (daysDifference > 32) {
          return Left(InvalidDateRangeFailure(
            startDate,
            endDate,
            'Monthly period should not exceed 32 days'
          ));
        }
        break;
      case 'yearly':
        if (daysDifference > 366) {
          return Left(InvalidDateRangeFailure(
            startDate,
            endDate,
            'Yearly period should not exceed 366 days'
          ));
        }
        break;
    }

    return const Right(null);
  }

  /// Get minimum required measurements for reliable statistics
  int _getMinimumRequiredMeasurements(String period) {
    switch (period.toLowerCase()) {
      case 'daily':
        return 4; // At least 4 measurements per day (every 6 hours)
      case 'weekly':
        return 14; // At least 2 measurements per day
      case 'monthly':
        return 30; // At least 1 measurement per day
      case 'yearly':
        return 365; // At least 1 measurement per day
      default:
        return 10; // Default minimum
    }
  }

  /// Calculate comprehensive weather statistics
  Future<WeatherStatisticsEntity> _calculateStatistics(
    String locationId,
    String period,
    DateTime startDate,
    DateTime endDate,
    List<WeatherMeasurementEntity> measurements,
  ) async {
    final locationName = measurements.first.locationName;
    
    // Basic temperature statistics
    final temperatures = measurements.map((m) => m.temperature).toList();
    final avgTemperature = _calculateMean(temperatures);
    final minTemperature = temperatures.reduce(math.min);
    final maxTemperature = temperatures.reduce(math.max);
    final temperatureVariance = _calculateVariance(temperatures, avgTemperature);

    // Humidity statistics
    final humidities = measurements.map((m) => m.humidity).toList();
    final avgHumidity = _calculateMean(humidities);
    final minHumidity = humidities.reduce(math.min);
    final maxHumidity = humidities.reduce(math.max);
    final humidityVariance = _calculateVariance(humidities, avgHumidity);

    // Pressure statistics
    final pressures = measurements.map((m) => m.pressure).toList();
    final avgPressure = _calculateMean(pressures);
    final minPressure = pressures.reduce(math.min);
    final maxPressure = pressures.reduce(math.max);
    final pressureVariance = _calculateVariance(pressures, avgPressure);

    // Wind statistics
    final windSpeeds = measurements.map((m) => m.windSpeed).toList();
    final avgWindSpeed = _calculateMean(windSpeeds);
    final maxWindSpeed = windSpeeds.reduce(math.max);
    final windDirections = measurements.map((m) => m.windDirection).toList();
    final avgWindDirection = _calculateCircularMean(windDirections);
    final predominantWindDirection = _calculatePredominantWindDirection(windDirections);

    // Precipitation statistics
    final rainfalls = measurements.map((m) => m.rainfall).toList();
    final totalRainfall = rainfalls.reduce((a, b) => a + b);
    final nonZeroRainfalls = rainfalls.where((r) => r > 0).toList();
    final avgDailyRainfall = totalRainfall / endDate.difference(startDate).inDays;
    final maxDailyRainfall = rainfalls.reduce(math.max);
    final rainyDays = nonZeroRainfalls.length;
    final dryDays = measurements.length - rainyDays;

    // UV and visibility statistics
    final uvIndices = measurements.map((m) => m.uvIndex).toList();
    final avgUVIndex = _calculateMean(uvIndices);
    final maxUVIndex = uvIndices.reduce(math.max);
    final visibilities = measurements.map((m) => m.visibility).toList();
    final avgVisibility = _calculateMean(visibilities);
    final minVisibility = visibilities.reduce(math.min);

    // Weather condition analysis
    final conditionCounts = _calculateWeatherConditionCounts(measurements);
    final predominantCondition = _findPredominantCondition(conditionCounts);

    // Agricultural metrics
    final favorableConditions = measurements.where((m) => m.isFavorableForAgriculture).toList();
    final favorableDays = favorableConditions.length;
    final unfavorableDays = measurements.length - favorableDays;
    final heatIndices = measurements.map((m) => m.heatIndex).toList();
    final avgHeatIndex = _calculateMean(heatIndices);
    final dewPoints = measurements.map((m) => m.dewPoint).toList();
    final avgDewPoint = _calculateMean(dewPoints);

    // Data quality metrics
    final totalMeasurements = measurements.length;
    final validMeasurements = measurements.where((m) => m.qualityScore > 0.5).length;
    final dataCompleteness = validMeasurements / totalMeasurements;
    final qualityScores = measurements.map((m) => m.qualityScore).toList();
    final avgDataQuality = _calculateMean(qualityScores);

    // Trend analysis (simplified - would need previous period data for accurate trends)
    final temperatureTrend = _calculateSimpleTrend(temperatures);
    final humidityTrend = _calculateSimpleTrend(humidities);
    final pressureTrend = _calculateSimpleTrend(pressures);
    final rainfallTrend = _calculateSimpleTrend(rainfalls);

    // Anomaly detection
    final anomalies = _detectAnomalies(measurements);
    final anomalyScore = anomalies.length / measurements.length;

    return WeatherStatisticsEntity(
      id: _generateStatisticsId(locationId, period, startDate),
      locationId: locationId,
      locationName: locationName,
      period: period,
      startDate: startDate,
      endDate: endDate,
      avgTemperature: double.parse(avgTemperature.toStringAsFixed(1)),
      minTemperature: double.parse(minTemperature.toStringAsFixed(1)),
      maxTemperature: double.parse(maxTemperature.toStringAsFixed(1)),
      temperatureVariance: double.parse(temperatureVariance.toStringAsFixed(2)),
      avgHumidity: double.parse(avgHumidity.toStringAsFixed(1)),
      minHumidity: double.parse(minHumidity.toStringAsFixed(1)),
      maxHumidity: double.parse(maxHumidity.toStringAsFixed(1)),
      humidityVariance: double.parse(humidityVariance.toStringAsFixed(2)),
      avgPressure: double.parse(avgPressure.toStringAsFixed(1)),
      minPressure: double.parse(minPressure.toStringAsFixed(1)),
      maxPressure: double.parse(maxPressure.toStringAsFixed(1)),
      pressureVariance: double.parse(pressureVariance.toStringAsFixed(2)),
      avgWindSpeed: double.parse(avgWindSpeed.toStringAsFixed(1)),
      maxWindSpeed: double.parse(maxWindSpeed.toStringAsFixed(1)),
      avgWindDirection: double.parse(avgWindDirection.toStringAsFixed(1)),
      predominantWindDirection: predominantWindDirection,
      totalRainfall: double.parse(totalRainfall.toStringAsFixed(1)),
      avgDailyRainfall: double.parse(avgDailyRainfall.toStringAsFixed(1)),
      maxDailyRainfall: double.parse(maxDailyRainfall.toStringAsFixed(1)),
      rainyDays: rainyDays,
      dryDays: dryDays,
      avgUVIndex: double.parse(avgUVIndex.toStringAsFixed(1)),
      maxUVIndex: double.parse(maxUVIndex.toStringAsFixed(1)),
      avgVisibility: double.parse(avgVisibility.toStringAsFixed(1)),
      minVisibility: double.parse(minVisibility.toStringAsFixed(1)),
      weatherConditionCounts: conditionCounts,
      predominantCondition: predominantCondition,
      favorableDays: favorableDays,
      unfavorableDays: unfavorableDays,
      avgHeatIndex: double.parse(avgHeatIndex.toStringAsFixed(1)),
      avgDewPoint: double.parse(avgDewPoint.toStringAsFixed(1)),
      totalMeasurements: totalMeasurements,
      validMeasurements: validMeasurements,
      dataCompleteness: double.parse(dataCompleteness.toStringAsFixed(3)),
      avgDataQuality: double.parse(avgDataQuality.toStringAsFixed(3)),
      temperatureTrend: double.parse(temperatureTrend.toStringAsFixed(2)),
      humidityTrend: double.parse(humidityTrend.toStringAsFixed(2)),
      pressureTrend: double.parse(pressureTrend.toStringAsFixed(2)),
      rainfallTrend: double.parse(rainfallTrend.toStringAsFixed(2)),
      detectedAnomalies: anomalies,
      anomalyScore: double.parse(anomalyScore.toStringAsFixed(3)),
      isSeasonalDataAvailable: false, // Would need historical data
      seasonalDeviationScore: 0.0, // Would need seasonal baseline
      calculatedAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Calculate mean of a list of numbers
  double _calculateMean(List<double> values) {
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  /// Calculate variance of a list of numbers
  double _calculateVariance(List<double> values, double mean) {
    if (values.length < 2) return 0.0;
    final sumSquaredDiff = values.map((v) => math.pow(v - mean, 2)).reduce((a, b) => a + b);
    return sumSquaredDiff / (values.length - 1);
  }

  /// Calculate circular mean for wind direction
  double _calculateCircularMean(List<double> angles) {
    if (angles.isEmpty) return 0.0;
    
    double sinSum = 0.0;
    double cosSum = 0.0;
    
    for (final angle in angles) {
      final radians = angle * math.pi / 180;
      sinSum += math.sin(radians);
      cosSum += math.cos(radians);
    }
    
    final meanRadians = math.atan2(sinSum / angles.length, cosSum / angles.length);
    var meanDegrees = meanRadians * 180 / math.pi;
    
    if (meanDegrees < 0) {
      meanDegrees += 360;
    }
    
    return meanDegrees;
  }

  /// Calculate predominant wind direction
  String _calculatePredominantWindDirection(List<double> directions) {
    if (directions.isEmpty) return 'N';
    
    // Group directions into compass sectors
    final sectorCounts = <String, int>{};
    const sectors = ['N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
                     'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'];
    
    for (final direction in directions) {
      final sectorIndex = ((direction + 11.25) / 22.5).floor() % 16;
      final sector = sectors[sectorIndex];
      sectorCounts[sector] = (sectorCounts[sector] ?? 0) + 1;
    }
    
    return sectorCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Calculate weather condition counts
  Map<String, int> _calculateWeatherConditionCounts(List<WeatherMeasurementEntity> measurements) {
    final counts = <String, int>{};
    
    for (final measurement in measurements) {
      final condition = measurement.weatherCondition;
      counts[condition] = (counts[condition] ?? 0) + 1;
    }
    
    return counts;
  }

  /// Find predominant weather condition
  String _findPredominantCondition(Map<String, int> conditionCounts) {
    if (conditionCounts.isEmpty) return 'unknown';
    return conditionCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Calculate simple trend (slope of linear regression)
  double _calculateSimpleTrend(List<double> values) {
    if (values.length < 2) return 0.0;
    
    final n = values.length;
    final xMean = (n - 1) / 2.0; // Assuming equal time intervals
    final yMean = _calculateMean(values);
    
    double numerator = 0.0;
    double denominator = 0.0;
    
    for (int i = 0; i < n; i++) {
      final xDiff = i - xMean;
      final yDiff = values[i] - yMean;
      numerator += xDiff * yDiff;
      denominator += xDiff * xDiff;
    }
    
    return denominator == 0 ? 0.0 : numerator / denominator;
  }

  /// Detect weather anomalies
  List<String> _detectAnomalies(List<WeatherMeasurementEntity> measurements) {
    final anomalies = <String>[];
    
    // Calculate thresholds (simplified approach)
    final temperatures = measurements.map((m) => m.temperature).toList();
    final tempMean = _calculateMean(temperatures);
    final tempStdDev = math.sqrt(_calculateVariance(temperatures, tempMean));
    
    final humidities = measurements.map((m) => m.humidity).toList();
    final humidityMean = _calculateMean(humidities);
    final humidityStdDev = math.sqrt(_calculateVariance(humidities, humidityMean));
    
    for (final measurement in measurements) {
      // Temperature anomalies (beyond 2 standard deviations)
      if ((measurement.temperature - tempMean).abs() > 2 * tempStdDev) {
        anomalies.add('extreme_temperature_${measurement.id}');
      }
      
      // Humidity anomalies
      if ((measurement.humidity - humidityMean).abs() > 2 * humidityStdDev) {
        anomalies.add('extreme_humidity_${measurement.id}');
      }
      
      // High wind speed
      if (measurement.windSpeed > 80) {
        anomalies.add('high_wind_speed_${measurement.id}');
      }
      
      // Heavy rainfall
      if (measurement.rainfall > 100) {
        anomalies.add('heavy_rainfall_${measurement.id}');
      }
    }
    
    return anomalies;
  }

  /// Generate unique statistics ID
  String _generateStatisticsId(String locationId, String period, DateTime startDate) {
    final timestamp = startDate.millisecondsSinceEpoch;
    return 'stats_${locationId}_${period}_$timestamp';
  }

  /// Compare two statistics entities
  Map<String, dynamic> _compareStatistics(
    WeatherStatisticsEntity stats1,
    WeatherStatisticsEntity stats2,
  ) {
    return {
      'temperature_difference': stats1.avgTemperature - stats2.avgTemperature,
      'humidity_difference': stats1.avgHumidity - stats2.avgHumidity,
      'pressure_difference': stats1.avgPressure - stats2.avgPressure,
      'rainfall_difference': stats1.totalRainfall - stats2.totalRainfall,
      'wind_speed_difference': stats1.avgWindSpeed - stats2.avgWindSpeed,
      'data_quality_difference': stats1.avgDataQuality - stats2.avgDataQuality,
      'period1_summary': stats1.weatherSummary,
      'period2_summary': stats2.weatherSummary,
      'comparison_type': '${stats1.period} vs ${stats2.period}',
      'compared_at': DateTime.now().toIso8601String(),
    };
  }
}

/// Helper class for date ranges
class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({required this.start, required this.end});
}