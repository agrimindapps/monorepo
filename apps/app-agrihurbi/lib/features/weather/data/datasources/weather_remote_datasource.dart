



import '../models/rain_gauge_model.dart';
import '../models/weather_measurement_model.dart';
import '../models/weather_statistics_model.dart';

/// Abstract interface for weather remote data source operations
abstract class WeatherRemoteDataSource {
  
  Future<List<WeatherMeasurementModel>> getAllMeasurements({
    String? locationId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });
  
  Future<WeatherMeasurementModel> getMeasurementById(String id);
  
  Future<List<WeatherMeasurementModel>> getMeasurementsByLocation(String locationId, {int? limit});
  
  Future<List<WeatherMeasurementModel>> getMeasurementsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? locationId,
  });
  
  Future<WeatherMeasurementModel> getLatestMeasurement([String? locationId]);
  
  Future<WeatherMeasurementModel> createMeasurement(WeatherMeasurementModel measurement);
  
  Future<WeatherMeasurementModel> updateMeasurement(WeatherMeasurementModel measurement);
  
  Future<void> deleteMeasurement(String id);
  
  Future<List<WeatherMeasurementModel>> uploadMeasurements(List<WeatherMeasurementModel> measurements);
  
  Future<List<RainGaugeModel>> getAllRainGauges();
  
  Future<RainGaugeModel> getRainGaugeById(String id);
  
  Future<List<RainGaugeModel>> getRainGaugesByLocation(String locationId);
  
  Future<List<RainGaugeModel>> getActiveRainGauges();
  
  Future<RainGaugeModel> createRainGauge(RainGaugeModel rainGauge);
  
  Future<RainGaugeModel> updateRainGauge(RainGaugeModel rainGauge);
  
  Future<void> deleteRainGauge(String id);
  
  Future<RainGaugeModel> updateRainGaugeMeasurement(String gaugeId, double rainfall, DateTime timestamp);
  
  Future<List<WeatherStatisticsModel>> getStatistics({
    String? locationId,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
  });
  
  Future<WeatherStatisticsModel> calculateStatistics({
    required String locationId,
    required String period,
    required DateTime startDate,
    required DateTime endDate,
  });
  
  Future<WeatherMeasurementModel> getCurrentWeatherFromAPI(
    double latitude,
    double longitude, {
    String provider = 'openweathermap',
  });
  
  Future<List<WeatherMeasurementModel>> getWeatherForecast(
    double latitude,
    double longitude, {
    int days = 7,
    String provider = 'openweathermap',
  });
  
  Future<List<WeatherMeasurementModel>> downloadMeasurements({DateTime? since});
  
  Future<List<RainGaugeModel>> downloadRainGauges({DateTime? since});
  
  Future<Map<String, dynamic>> getServerStatus();
}
