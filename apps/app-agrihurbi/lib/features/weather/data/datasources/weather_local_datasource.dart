import 'package:hive/hive.dart';
import '../models/rain_gauge_model.dart';
import '../models/weather_measurement_model.dart';
import '../models/weather_statistics_model.dart';

/// Abstract interface for weather local data source operations
abstract class WeatherLocalDataSource {
  // ============================================================================
  // WEATHER MEASUREMENTS
  // ============================================================================
  
  Future<List<WeatherMeasurementModel>> getAllMeasurements({
    String? locationId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });
  
  Future<WeatherMeasurementModel?> getMeasurementById(String id);
  
  Future<List<WeatherMeasurementModel>> getMeasurementsByLocation(String locationId, {int? limit});
  
  Future<List<WeatherMeasurementModel>> getMeasurementsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? locationId,
  });
  
  Future<WeatherMeasurementModel?> getLatestMeasurement([String? locationId]);
  
  Future<void> saveMeasurement(WeatherMeasurementModel measurement);
  
  Future<void> saveMeasurements(List<WeatherMeasurementModel> measurements);
  
  Future<void> updateMeasurement(WeatherMeasurementModel measurement);
  
  Future<void> deleteMeasurement(String id);
  
  Future<void> deleteMeasurements(List<String> ids);
  
  Future<void> clearAllMeasurements();

  // ============================================================================
  // RAIN GAUGES
  // ============================================================================
  
  Future<List<RainGaugeModel>> getAllRainGauges();
  
  Future<RainGaugeModel?> getRainGaugeById(String id);
  
  Future<List<RainGaugeModel>> getRainGaugesByLocation(String locationId);
  
  Future<List<RainGaugeModel>> getActiveRainGauges();
  
  Future<void> saveRainGauge(RainGaugeModel rainGauge);
  
  Future<void> saveRainGauges(List<RainGaugeModel> rainGauges);
  
  Future<void> updateRainGauge(RainGaugeModel rainGauge);
  
  Future<void> deleteRainGauge(String id);
  
  Future<void> clearAllRainGauges();

  // ============================================================================
  // WEATHER STATISTICS
  // ============================================================================
  
  Future<List<WeatherStatisticsModel>> getAllStatistics();
  
  Future<WeatherStatisticsModel?> getStatisticsById(String id);
  
  Future<List<WeatherStatisticsModel>> getStatisticsByLocation(String locationId);
  
  Future<List<WeatherStatisticsModel>> getStatisticsByPeriod(String period);
  
  Future<void> saveStatistics(WeatherStatisticsModel statistics);
  
  Future<void> saveMultipleStatistics(List<WeatherStatisticsModel> statistics);
  
  Future<void> updateStatistics(WeatherStatisticsModel statistics);
  
  Future<void> deleteStatistics(String id);
  
  Future<void> clearAllStatistics();

  // ============================================================================
  // CACHE AND SYNC
  // ============================================================================
  
  Future<void> clearCache();
  
  Future<Map<String, int>> getCacheSize();
  
  Future<void> compactDatabase();
  
  Future<DateTime?> getLastSyncTime();
  
  Future<void> setLastSyncTime(DateTime timestamp);

  // Advanced search and sync methods
  Future<List<WeatherMeasurementModel>> searchMeasurements({
    String? locationId,
    DateTime? fromDate,
    DateTime? toDate,
    double? minTemperature,
    double? maxTemperature,
    String? weatherCondition,
    double? minRainfall,
    double? maxRainfall,
    int? limit,
  });

  Future<List<WeatherMeasurementModel>> getPendingMeasurements();

  Future<void> markMeasurementsAsSynced(List<String> ids);
}

/// Implementation of weather local data source using Hive
class WeatherLocalDataSourceImpl implements WeatherLocalDataSource {
  static const String _measurementsBoxName = 'weather_measurements';
  static const String _rainGaugesBoxName = 'rain_gauges';
  static const String _statisticsBoxName = 'weather_statistics';
  static const String _metadataBoxName = 'weather_metadata';

  Box<WeatherMeasurementModel>? _measurementsBox;
  Box<RainGaugeModel>? _rainGaugesBox;
  Box<WeatherStatisticsModel>? _statisticsBox;
  Box<dynamic>? _metadataBox;

  /// Initialize Hive boxes
  Future<void> init() async {
    try {
      _measurementsBox = await Hive.openBox<WeatherMeasurementModel>(_measurementsBoxName);
      _rainGaugesBox = await Hive.openBox<RainGaugeModel>(_rainGaugesBoxName);
      _statisticsBox = await Hive.openBox<WeatherStatisticsModel>(_statisticsBoxName);
      _metadataBox = await Hive.openBox(_metadataBoxName);
    } catch (e) {
      throw Exception('Failed to initialize Hive boxes: $e');
    }
  }

  /// Ensure boxes are initialized
  Future<void> _ensureInitialized() async {
    if (_measurementsBox == null || 
        _rainGaugesBox == null || 
        _statisticsBox == null ||
        _metadataBox == null) {
      await init();
    }
  }

  // ============================================================================
  // WEATHER MEASUREMENTS IMPLEMENTATION
  // ============================================================================

  @override
  Future<List<WeatherMeasurementModel>> getAllMeasurements({
    String? locationId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      await _ensureInitialized();
      
      var measurements = _measurementsBox!.values.toList();
      
      // Apply location filter
      if (locationId != null && locationId.isNotEmpty) {
        measurements = measurements.where((m) => m.locationId == locationId).toList();
      }
      
      // Apply date range filter
      if (startDate != null || endDate != null) {
        measurements = measurements.where((m) {
          if (startDate != null && m.timestamp.isBefore(startDate)) return false;
          if (endDate != null && m.timestamp.isAfter(endDate)) return false;
          return true;
        }).toList();
      }
      
      // Sort by timestamp (newest first)
      measurements.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      // Apply limit
      if (limit != null && limit > 0) {
        measurements = measurements.take(limit).toList();
      }
      
      return measurements;
    } catch (e) {
      throw Exception('getAllMeasurements failed: ${e.toString()}');
    }
  }

  @override
  Future<WeatherMeasurementModel?> getMeasurementById(String id) async {
    try {
      await _ensureInitialized();
      return _measurementsBox!.get(id);
    } catch (e) {
      throw Exception('getMeasurementById failed: ${e.toString()}');
    }
  }

  @override
  Future<List<WeatherMeasurementModel>> getMeasurementsByLocation(
    String locationId, {
    int? limit,
  }) async {
    return await getAllMeasurements(locationId: locationId, limit: limit);
  }

  @override
  Future<List<WeatherMeasurementModel>> getMeasurementsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? locationId,
  }) async {
    return await getAllMeasurements(
      locationId: locationId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<WeatherMeasurementModel?> getLatestMeasurement([String? locationId]) async {
    try {
      final measurements = await getAllMeasurements(locationId: locationId, limit: 1);
      return measurements.isNotEmpty ? measurements.first : null;
    } catch (e) {
      throw Exception('getLatestMeasurement failed: ${e.toString()}');
    }
  }

  @override
  Future<void> saveMeasurement(WeatherMeasurementModel measurement) async {
    try {
      await _ensureInitialized();
      await _measurementsBox!.put(measurement.id, measurement);
    } catch (e) {
      throw Exception('saveMeasurement failed: ${e.toString()}');
    }
  }

  @override
  Future<void> saveMeasurements(List<WeatherMeasurementModel> measurements) async {
    try {
      await _ensureInitialized();
      final Map<String, WeatherMeasurementModel> measurementsMap = {
        for (final measurement in measurements) measurement.id: measurement
      };
      await _measurementsBox!.putAll(measurementsMap);
    } catch (e) {
      throw Exception('saveMeasurements failed: ${e.toString()}');
    }
  }

  @override
  Future<void> updateMeasurement(WeatherMeasurementModel measurement) async {
    try {
      await _ensureInitialized();
      if (_measurementsBox!.containsKey(measurement.id)) {
        await _measurementsBox!.put(measurement.id, measurement);
      } else {
        throw Exception('Measurement not found: ${measurement.id}');
      }
    } catch (e) {
      throw Exception('updateMeasurement failed: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteMeasurement(String id) async {
    try {
      await _ensureInitialized();
      await _measurementsBox!.delete(id);
    } catch (e) {
      throw Exception('deleteMeasurement failed: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteMeasurements(List<String> ids) async {
    try {
      await _ensureInitialized();
      await _measurementsBox!.deleteAll(ids);
    } catch (e) {
      throw Exception('deleteMeasurements failed: ${e.toString()}');
    }
  }

  @override
  Future<void> clearAllMeasurements() async {
    try {
      await _ensureInitialized();
      await _measurementsBox!.clear();
    } catch (e) {
      throw Exception('clearAllMeasurements failed: ${e.toString()}');
    }
  }

  // ============================================================================
  // RAIN GAUGES IMPLEMENTATION
  // ============================================================================

  @override
  Future<List<RainGaugeModel>> getAllRainGauges() async {
    try {
      await _ensureInitialized();
      return _rainGaugesBox!.values.toList();
    } catch (e) {
      throw Exception('getAllRainGauges failed: ${e.toString()}');
    }
  }

  @override
  Future<RainGaugeModel?> getRainGaugeById(String id) async {
    try {
      await _ensureInitialized();
      return _rainGaugesBox!.get(id);
    } catch (e) {
      throw Exception('getRainGaugeById failed: ${e.toString()}');
    }
  }

  @override
  Future<List<RainGaugeModel>> getRainGaugesByLocation(String locationId) async {
    try {
      await _ensureInitialized();
      return _rainGaugesBox!.values
          .where((gauge) => gauge.locationId == locationId)
          .toList();
    } catch (e) {
      throw Exception('getRainGaugesByLocation failed: ${e.toString()}');
    }
  }

  @override
  Future<List<RainGaugeModel>> getActiveRainGauges() async {
    try {
      await _ensureInitialized();
      return _rainGaugesBox!.values
          .where((gauge) => gauge.isActive)
          .toList();
    } catch (e) {
      throw Exception('getActiveRainGauges failed: ${e.toString()}');
    }
  }

  @override
  Future<void> saveRainGauge(RainGaugeModel rainGauge) async {
    try {
      await _ensureInitialized();
      await _rainGaugesBox!.put(rainGauge.id, rainGauge);
    } catch (e) {
      throw Exception('saveRainGauge failed: ${e.toString()}');
    }
  }

  @override
  Future<void> saveRainGauges(List<RainGaugeModel> rainGauges) async {
    try {
      await _ensureInitialized();
      final Map<String, RainGaugeModel> rainGaugesMap = {
        for (final gauge in rainGauges) gauge.id: gauge
      };
      await _rainGaugesBox!.putAll(rainGaugesMap);
    } catch (e) {
      throw Exception('saveRainGauges failed: ${e.toString()}');
    }
  }

  @override
  Future<void> updateRainGauge(RainGaugeModel rainGauge) async {
    try {
      await _ensureInitialized();
      if (_rainGaugesBox!.containsKey(rainGauge.id)) {
        await _rainGaugesBox!.put(rainGauge.id, rainGauge);
      } else {
        throw Exception('Rain gauge not found: ${rainGauge.id}');
      }
    } catch (e) {
      throw Exception('updateRainGauge failed: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteRainGauge(String id) async {
    try {
      await _ensureInitialized();
      await _rainGaugesBox!.delete(id);
    } catch (e) {
      throw Exception('deleteRainGauge failed: ${e.toString()}');
    }
  }

  @override
  Future<void> clearAllRainGauges() async {
    try {
      await _ensureInitialized();
      await _rainGaugesBox!.clear();
    } catch (e) {
      throw Exception('clearAllRainGauges failed: ${e.toString()}');
    }
  }

  // ============================================================================
  // WEATHER STATISTICS IMPLEMENTATION
  // ============================================================================

  @override
  Future<List<WeatherStatisticsModel>> getAllStatistics() async {
    try {
      await _ensureInitialized();
      return _statisticsBox!.values.toList();
    } catch (e) {
      throw Exception('getAllStatistics failed: ${e.toString()}');
    }
  }

  @override
  Future<WeatherStatisticsModel?> getStatisticsById(String id) async {
    try {
      await _ensureInitialized();
      return _statisticsBox!.get(id);
    } catch (e) {
      throw Exception('getStatisticsById failed: ${e.toString()}');
    }
  }

  @override
  Future<List<WeatherStatisticsModel>> getStatisticsByLocation(String locationId) async {
    try {
      await _ensureInitialized();
      return _statisticsBox!.values
          .where((stats) => stats.locationId == locationId)
          .toList();
    } catch (e) {
      throw Exception('getStatisticsByLocation failed: ${e.toString()}');
    }
  }

  @override
  Future<List<WeatherStatisticsModel>> getStatisticsByPeriod(String period) async {
    try {
      await _ensureInitialized();
      return _statisticsBox!.values
          .where((stats) => stats.period == period)
          .toList();
    } catch (e) {
      throw Exception('getStatisticsByPeriod failed: ${e.toString()}');
    }
  }

  @override
  Future<void> saveStatistics(WeatherStatisticsModel statistics) async {
    try {
      await _ensureInitialized();
      await _statisticsBox!.put(statistics.id, statistics);
    } catch (e) {
      throw Exception('saveStatistics failed: ${e.toString()}');
    }
  }

  @override
  Future<void> saveMultipleStatistics(List<WeatherStatisticsModel> statistics) async {
    try {
      await _ensureInitialized();
      final Map<String, WeatherStatisticsModel> statisticsMap = {
        for (final stat in statistics) stat.id: stat
      };
      await _statisticsBox!.putAll(statisticsMap);
    } catch (e) {
      throw Exception('saveMultipleStatistics failed: ${e.toString()}');
    }
  }

  @override
  Future<void> updateStatistics(WeatherStatisticsModel statistics) async {
    try {
      await _ensureInitialized();
      if (_statisticsBox!.containsKey(statistics.id)) {
        await _statisticsBox!.put(statistics.id, statistics);
      } else {
        throw Exception('Statistics not found: ${statistics.id}');
      }
    } catch (e) {
      throw Exception('updateStatistics failed: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteStatistics(String id) async {
    try {
      await _ensureInitialized();
      await _statisticsBox!.delete(id);
    } catch (e) {
      throw Exception('deleteStatistics failed: ${e.toString()}');
    }
  }

  @override
  Future<void> clearAllStatistics() async {
    try {
      await _ensureInitialized();
      await _statisticsBox!.clear();
    } catch (e) {
      throw Exception('clearAllStatistics failed: ${e.toString()}');
    }
  }

  // ============================================================================
  // CACHE AND SYNC IMPLEMENTATION
  // ============================================================================

  @override
  Future<void> clearCache() async {
    try {
      await clearAllMeasurements();
      await clearAllRainGauges();
      await clearAllStatistics();
    } catch (e) {
      throw Exception('Failed to clear cache: $e');
    }
  }

  @override
  Future<Map<String, int>> getCacheSize() async {
    try {
      await _ensureInitialized();
      return {
        'measurements': _measurementsBox!.length,
        'rain_gauges': _rainGaugesBox!.length,
        'statistics': _statisticsBox!.length,
        'total': _measurementsBox!.length + _rainGaugesBox!.length + _statisticsBox!.length,
      };
    } catch (e) {
      throw Exception('Failed to get cache size: $e');
    }
  }

  @override
  Future<void> compactDatabase() async {
    try {
      await _ensureInitialized();
      await _measurementsBox!.compact();
      await _rainGaugesBox!.compact();
      await _statisticsBox!.compact();
      await _metadataBox!.compact();
    } catch (e) {
      throw Exception('compactDatabase failed: ${e.toString()}');
    }
  }

  @override
  Future<DateTime?> getLastSyncTime() async {
    try {
      await _ensureInitialized();
      final timestamp = _metadataBox!.get('last_sync_time');
      return timestamp != null ? DateTime.parse(timestamp as String) : null;
    } catch (e) {
      return null; // Return null if unable to parse or retrieve
    }
  }

  @override
  Future<void> setLastSyncTime(DateTime timestamp) async {
    try {
      await _ensureInitialized();
      await _metadataBox!.put('last_sync_time', timestamp.toIso8601String());
    } catch (e) {
      throw Exception('setLastSyncTime failed: ${e.toString()}');
    }
  }

  /// Search measurements with advanced filtering
  @override
  Future<List<WeatherMeasurementModel>> searchMeasurements({
    String? locationId,
    DateTime? fromDate,
    DateTime? toDate,
    double? minTemperature,
    double? maxTemperature,
    String? weatherCondition,
    double? minRainfall,
    double? maxRainfall,
    int? limit,
  }) async {
    try {
      await _ensureInitialized();
      
      var measurements = _measurementsBox!.values.where((m) {
        // Location filter
        if (locationId != null && m.locationId != locationId) return false;
        
        // Date range filter
        if (fromDate != null && m.timestamp.isBefore(fromDate)) return false;
        if (toDate != null && m.timestamp.isAfter(toDate)) return false;
        
        // Temperature filter
        if (minTemperature != null && m.temperature < minTemperature) return false;
        if (maxTemperature != null && m.temperature > maxTemperature) return false;
        
        // Weather condition filter
        if (weatherCondition != null && m.weatherCondition != weatherCondition) return false;
        
        // Rainfall filter
        if (minRainfall != null && m.rainfall < minRainfall) return false;
        if (maxRainfall != null && m.rainfall > maxRainfall) return false;
        
        return true;
      }).toList();
      
      // Sort by timestamp (newest first)
      measurements.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      // Apply limit
      if (limit != null && limit > 0) {
        measurements = measurements.take(limit).toList();
      }
      
      return measurements;
    } catch (e) {
      throw Exception('searchMeasurements failed: ${e.toString()}');
    }
  }

  /// Get measurements that need to be synced (pending upload)
  @override
  Future<List<WeatherMeasurementModel>> getPendingMeasurements() async {
    try {
      await _ensureInitialized();
      
      // Return measurements created locally that haven't been synced
      return _measurementsBox!.values
          .where((m) => m.source.startsWith('manual') || m.source.startsWith('sensor'))
          .toList();
    } catch (e) {
      throw Exception('getPendingMeasurements failed: ${e.toString()}');
    }
  }

  /// Mark measurements as synced
  @override
  Future<void> markMeasurementsAsSynced(List<String> ids) async {
    try {
      await _ensureInitialized();
      
      for (final id in ids) {
        final measurement = _measurementsBox!.get(id);
        if (measurement != null) {
          final updated = measurement.copyWith(
            source: '${measurement.source}_synced',
            updatedAt: DateTime.now(),
          );
          await _measurementsBox!.put(id, updated);
        }
      }
    } catch (e) {
      throw Exception('markMeasurementsAsSynced failed: ${e.toString()}');
    }
  }

  /// Clean old measurements (keep only recent data)
  Future<int> cleanOldMeasurements({int keepDays = 365}) async {
    try {
      await _ensureInitialized();
      
      final cutoffDate = DateTime.now().subtract(Duration(days: keepDays));
      final oldMeasurements = _measurementsBox!.values
          .where((m) => m.timestamp.isBefore(cutoffDate))
          .map((m) => m.id)
          .toList();
      
      await _measurementsBox!.deleteAll(oldMeasurements);
      return oldMeasurements.length;
    } catch (e) {
      throw Exception('cleanOldMeasurements failed: ${e.toString()}');
    }
  }

  /// Get database health information
  Future<Map<String, dynamic>> getDatabaseHealth() async {
    try {
      await _ensureInitialized();
      
      final cacheSize = await getCacheSize();
      final lastSync = await getLastSyncTime();
      final pendingCount = (await getPendingMeasurements()).length;
      
      return {
        'cache_size': cacheSize,
        'last_sync': lastSync?.toIso8601String(),
        'pending_measurements': pendingCount,
        'database_healthy': true,
        'checked_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'database_healthy': false,
        'error': e.toString(),
        'checked_at': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Close all boxes (cleanup)
  Future<void> dispose() async {
    try {
      await _measurementsBox?.close();
      await _rainGaugesBox?.close();
      await _statisticsBox?.close();
      await _metadataBox?.close();
    } catch (e) {
      // Log error but don't throw
      print('Warning: Error disposing weather local data source: $e');
    }
  }
}