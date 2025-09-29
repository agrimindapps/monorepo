import 'package:injectable/injectable.dart';

import '../models/rain_gauge_model.dart';
import '../models/weather_measurement_model.dart';
import '../models/weather_statistics_model.dart';
import 'weather_local_datasource.dart';

/// Concrete implementation of WeatherLocalDataSource using Hive
@LazySingleton(as: WeatherLocalDataSource)
class WeatherLocalDataSourceImpl implements WeatherLocalDataSource {
  static const String _weatherMeasurementsBox = 'weather_measurements';
  static const String _rainGaugesBox = 'rain_gauges';
  static const String _weatherStatisticsBox = 'weather_statistics';
  
  // ============================================================================
  // WEATHER MEASUREMENTS
  // ============================================================================
  
  @override
  Future<List<WeatherMeasurementModel>> getAllMeasurements({
    String? locationId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    final box = await Hive.openBox<WeatherMeasurementModel>(_weatherMeasurementsBox);
    
    var measurements = box.values.toList();
    
    // Filter by locationId if provided
    if (locationId != null) {
      measurements = measurements.where((m) => m.locationId == locationId).toList();
    }
    
    // Filter by date range if provided
    if (startDate != null) {
      measurements = measurements.where((m) => 
        m.timestamp.isAfter(startDate) || m.timestamp.isAtSameMomentAs(startDate)
      ).toList();
    }
    
    if (endDate != null) {
      measurements = measurements.where((m) => 
        m.timestamp.isBefore(endDate) || m.timestamp.isAtSameMomentAs(endDate)
      ).toList();
    }
    
    // Sort by measurement time (newest first)
    measurements.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    // Apply limit if provided
    if (limit != null && limit > 0) {
      measurements = measurements.take(limit).toList();
    }
    
    return measurements;
  }
  
  @override
  Future<WeatherMeasurementModel?> getMeasurementById(String id) async {
    final box = await Hive.openBox<WeatherMeasurementModel>(_weatherMeasurementsBox);
    return box.get(id);
  }
  
  @override
  Future<List<WeatherMeasurementModel>> getMeasurementsByLocation(
    String locationId, {
    int? limit,
  }) async {
    return getAllMeasurements(locationId: locationId, limit: limit);
  }
  
  @override
  Future<List<WeatherMeasurementModel>> getMeasurementsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? locationId,
  }) async {
    return getAllMeasurements(
      locationId: locationId,
      startDate: startDate,
      endDate: endDate,
    );
  }
  
  @override
  Future<WeatherMeasurementModel?> getLatestMeasurement([String? locationId]) async {
    final measurements = await getAllMeasurements(locationId: locationId, limit: 1);
    return measurements.isEmpty ? null : measurements.first;
  }
  
  @override
  Future<void> saveMeasurement(WeatherMeasurementModel measurement) async {
    final box = await Hive.openBox<WeatherMeasurementModel>(_weatherMeasurementsBox);
    await box.put(measurement.id, measurement);
  }
  
  @override
  Future<void> saveMeasurements(List<WeatherMeasurementModel> measurements) async {
    final box = await Hive.openBox<WeatherMeasurementModel>(_weatherMeasurementsBox);
    
    final Map<String, WeatherMeasurementModel> measurementsMap = {
      for (var measurement in measurements) measurement.id: measurement
    };
    
    await box.putAll(measurementsMap);
  }
  
  @override
  Future<void> updateMeasurement(WeatherMeasurementModel measurement) async {
    await saveMeasurement(measurement);
  }
  
  @override
  Future<void> deleteMeasurement(String id) async {
    final box = await Hive.openBox<WeatherMeasurementModel>(_weatherMeasurementsBox);
    await box.delete(id);
  }
  
  @override
  Future<void> deleteMeasurements(List<String> ids) async {
    final box = await Hive.openBox<WeatherMeasurementModel>(_weatherMeasurementsBox);
    await box.deleteAll(ids);
  }
  
  @override
  Future<void> clearAllMeasurements() async {
    final box = await Hive.openBox<WeatherMeasurementModel>(_weatherMeasurementsBox);
    await box.clear();
  }

  // ============================================================================
  // RAIN GAUGES
  // ============================================================================
  
  @override
  Future<List<RainGaugeModel>> getAllRainGauges() async {
    final box = await Hive.openBox<RainGaugeModel>(_rainGaugesBox);
    return box.values.toList();
  }
  
  @override
  Future<RainGaugeModel?> getRainGaugeById(String id) async {
    final box = await Hive.openBox<RainGaugeModel>(_rainGaugesBox);
    return box.get(id);
  }
  
  @override
  Future<List<RainGaugeModel>> getRainGaugesByLocation(String locationId) async {
    final box = await Hive.openBox<RainGaugeModel>(_rainGaugesBox);
    return box.values.where((gauge) => gauge.locationId == locationId).toList();
  }
  
  @override
  Future<List<RainGaugeModel>> getActiveRainGauges() async {
    final box = await Hive.openBox<RainGaugeModel>(_rainGaugesBox);
    return box.values.where((gauge) => gauge.isActive).toList();
  }
  
  @override
  Future<void> saveRainGauge(RainGaugeModel rainGauge) async {
    final box = await Hive.openBox<RainGaugeModel>(_rainGaugesBox);
    await box.put(rainGauge.id, rainGauge);
  }
  
  @override
  Future<void> saveRainGauges(List<RainGaugeModel> rainGauges) async {
    final box = await Hive.openBox<RainGaugeModel>(_rainGaugesBox);
    
    final Map<String, RainGaugeModel> rainGaugesMap = {
      for (var gauge in rainGauges) gauge.id: gauge
    };
    
    await box.putAll(rainGaugesMap);
  }
  
  @override
  Future<void> updateRainGauge(RainGaugeModel rainGauge) async {
    await saveRainGauge(rainGauge);
  }
  
  @override
  Future<void> deleteRainGauge(String id) async {
    final box = await Hive.openBox<RainGaugeModel>(_rainGaugesBox);
    await box.delete(id);
  }
  
  Future<void> deleteRainGauges(List<String> ids) async {
    final box = await Hive.openBox<RainGaugeModel>(_rainGaugesBox);
    await box.deleteAll(ids);
  }
  
  @override
  Future<void> clearAllRainGauges() async {
    final box = await Hive.openBox<RainGaugeModel>(_rainGaugesBox);
    await box.clear();
  }

  // ============================================================================
  // WEATHER STATISTICS
  // ============================================================================
  
  @override
  Future<List<WeatherStatisticsModel>> getAllStatistics() async {
    final box = await Hive.openBox<WeatherStatisticsModel>(_weatherStatisticsBox);
    return box.values.toList();
  }
  
  Future<List<WeatherStatisticsModel>> getAllStatisticsWithFilters({
    String? locationId,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final box = await Hive.openBox<WeatherStatisticsModel>(_weatherStatisticsBox);
    
    var statistics = box.values.toList();
    
    // Filter by locationId if provided
    if (locationId != null) {
      statistics = statistics.where((s) => s.locationId == locationId).toList();
    }
    
    // Filter by period if provided
    if (period != null) {
      statistics = statistics.where((s) => s.period == period).toList();
    }
    
    // Filter by date range if provided
    if (startDate != null) {
      statistics = statistics.where((s) => 
        s.startDate.isAfter(startDate) || s.startDate.isAtSameMomentAs(startDate)
      ).toList();
    }
    
    if (endDate != null) {
      statistics = statistics.where((s) => 
        s.endDate.isBefore(endDate) || s.endDate.isAtSameMomentAs(endDate)
      ).toList();
    }
    
    // Sort by start date (newest first)
    statistics.sort((a, b) => b.startDate.compareTo(a.startDate));
    
    return statistics;
  }
  
  @override
  Future<WeatherStatisticsModel?> getStatisticsById(String id) async {
    final box = await Hive.openBox<WeatherStatisticsModel>(_weatherStatisticsBox);
    return box.get(id);
  }
  
  @override
  Future<List<WeatherStatisticsModel>> getStatisticsByLocation(String locationId) async {
    return getAllStatisticsWithFilters(locationId: locationId);
  }
  
  @override
  Future<List<WeatherStatisticsModel>> getStatisticsByPeriod(String period) async {
    return getAllStatisticsWithFilters(period: period);
  }
  
  Future<WeatherStatisticsModel?> getLatestStatistics(String locationId, String period) async {
    final statistics = await getAllStatisticsWithFilters(locationId: locationId, period: period);
    return statistics.isEmpty ? null : statistics.first;
  }
  
  @override
  Future<void> saveStatistics(WeatherStatisticsModel statistics) async {
    final box = await Hive.openBox<WeatherStatisticsModel>(_weatherStatisticsBox);
    await box.put(statistics.id, statistics);
  }
  
  @override
  Future<void> saveMultipleStatistics(List<WeatherStatisticsModel> statisticsList) async {
    final box = await Hive.openBox<WeatherStatisticsModel>(_weatherStatisticsBox);
    
    final Map<String, WeatherStatisticsModel> statisticsMap = {
      for (var stats in statisticsList) stats.id: stats
    };
    
    await box.putAll(statisticsMap);
  }
  
  @override
  Future<void> updateStatistics(WeatherStatisticsModel statistics) async {
    await saveStatistics(statistics);
  }
  
  @override
  Future<void> deleteStatistics(String id) async {
    final box = await Hive.openBox<WeatherStatisticsModel>(_weatherStatisticsBox);
    await box.delete(id);
  }
  
  Future<void> deleteMultipleStatistics(List<String> ids) async {
    final box = await Hive.openBox<WeatherStatisticsModel>(_weatherStatisticsBox);
    await box.deleteAll(ids);
  }
  
  @override
  Future<void> clearAllStatistics() async {
    final box = await Hive.openBox<WeatherStatisticsModel>(_weatherStatisticsBox);
    await box.clear();
  }

  // ============================================================================
  // CACHE AND SYNC METHODS (to match interface)
  // ============================================================================
  
  @override
  Future<void> clearCache() async {
    await clearAllMeasurements();
    await clearAllRainGauges();
    await clearAllStatistics();
  }
  
  @override
  Future<Map<String, int>> getCacheSize() async {
    final measurementsBox = await Hive.openBox<WeatherMeasurementModel>(_weatherMeasurementsBox);
    final rainGaugesBox = await Hive.openBox<RainGaugeModel>(_rainGaugesBox);
    final statisticsBox = await Hive.openBox<WeatherStatisticsModel>(_weatherStatisticsBox);
    
    return {
      'measurements': measurementsBox.length,
      'rainGauges': rainGaugesBox.length,
      'statistics': statisticsBox.length,
    };
  }
  
  @override
  Future<DateTime?> getLastSyncTime() async {
    final box = await Hive.openBox<String>('weather_sync_metadata');
    final lastSyncStr = box.get('last_sync_weather');
    
    if (lastSyncStr != null) {
      return DateTime.tryParse(lastSyncStr);
    }
    
    return null;
  }
  
  @override
  Future<void> setLastSyncTime(DateTime time) async {
    final box = await Hive.openBox<String>('weather_sync_metadata');
    await box.put('last_sync_weather', time.toIso8601String());
  }
  
  @override
  Future<void> compactDatabase() async {
    final measurementsBox = await Hive.openBox<WeatherMeasurementModel>(_weatherMeasurementsBox);
    final rainGaugesBox = await Hive.openBox<RainGaugeModel>(_rainGaugesBox);
    final statisticsBox = await Hive.openBox<WeatherStatisticsModel>(_weatherStatisticsBox);
    
    await measurementsBox.compact();
    await rainGaugesBox.compact();
    await statisticsBox.compact();
  }
  
  @override
  Future<List<WeatherMeasurementModel>> getPendingMeasurements() async {
    final box = await Hive.openBox<WeatherMeasurementModel>(_weatherMeasurementsBox);
    // Return all measurements as pending (simplified implementation)
    return box.values.toList();
  }
  
  @override
  Future<void> markMeasurementsAsSynced(List<String> measurementIds) async {
    // Simplified implementation - could be extended to track sync status
    final box = await Hive.openBox<String>('weather_sync_metadata');
    final syncedIds = measurementIds.join(',');
    await box.put('synced_measurements', syncedIds);
  }
  
  @override
  Future<List<WeatherMeasurementModel>> searchMeasurements({
    String? locationId,
    DateTime? fromDate,
    DateTime? toDate,
    double? minTemperature,
    double? maxTemperature,
    double? minRainfall,
    double? maxRainfall,
    String? weatherCondition,
    int? limit,
  }) async {
    final box = await Hive.openBox<WeatherMeasurementModel>(_weatherMeasurementsBox);
    var results = box.values.toList();
    
    if (locationId != null) {
      results = results.where((m) => m.locationId == locationId).toList();
    }
    
    if (fromDate != null) {
      results = results.where((m) => m.timestamp.isAfter(fromDate) || m.timestamp.isAtSameMomentAs(fromDate)).toList();
    }
    
    if (toDate != null) {
      results = results.where((m) => m.timestamp.isBefore(toDate) || m.timestamp.isAtSameMomentAs(toDate)).toList();
    }
    
    if (minTemperature != null) {
      results = results.where((m) => m.temperature >= minTemperature).toList();
    }
    
    if (maxTemperature != null) {
      results = results.where((m) => m.temperature <= maxTemperature).toList();
    }
    
    if (minRainfall != null) {
      results = results.where((m) => m.rainfall >= minRainfall).toList();
    }
    
    if (maxRainfall != null) {
      results = results.where((m) => m.rainfall <= maxRainfall).toList();
    }
    
    if (weatherCondition != null) {
      // Weather condition filtering - simplified implementation
      // Could be extended based on actual weather measurement model properties
      results = results.where((m) => m.locationName.toLowerCase().contains(weatherCondition.toLowerCase())).toList();
    }
    
    if (limit != null && limit > 0) {
      results = results.take(limit).toList();
    }
    
    return results;
  }
}