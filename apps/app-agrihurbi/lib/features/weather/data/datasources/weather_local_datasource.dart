


import '../models/rain_gauge_model.dart';
import '../models/weather_measurement_model.dart';
import '../models/weather_statistics_model.dart';

/// Abstract interface for weather local data source operations
abstract class WeatherLocalDataSource {
  
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
  
  Future<List<RainGaugeModel>> getAllRainGauges();
  
  Future<RainGaugeModel?> getRainGaugeById(String id);
  
  Future<List<RainGaugeModel>> getRainGaugesByLocation(String locationId);
  
  Future<List<RainGaugeModel>> getActiveRainGauges();
  
  Future<void> saveRainGauge(RainGaugeModel rainGauge);
  
  Future<void> saveRainGauges(List<RainGaugeModel> rainGauges);
  
  Future<void> updateRainGauge(RainGaugeModel rainGauge);
  
  Future<void> deleteRainGauge(String id);
  
  Future<void> clearAllRainGauges();
  
  Future<List<WeatherStatisticsModel>> getAllStatistics();
  
  Future<WeatherStatisticsModel?> getStatisticsById(String id);
  
  Future<List<WeatherStatisticsModel>> getStatisticsByLocation(String locationId);
  
  Future<List<WeatherStatisticsModel>> getStatisticsByPeriod(String period);
  
  Future<void> saveStatistics(WeatherStatisticsModel statistics);
  
  Future<void> saveMultipleStatistics(List<WeatherStatisticsModel> statistics);
  
  Future<void> updateStatistics(WeatherStatisticsModel statistics);
  
  Future<void> deleteStatistics(String id);
  
  Future<void> clearAllStatistics();
  
  Future<void> clearCache();
  
  Future<Map<String, int>> getCacheSize();
  
  Future<void> compactDatabase();
  
  Future<DateTime?> getLastSyncTime();
  
  Future<void> setLastSyncTime(DateTime timestamp);
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

