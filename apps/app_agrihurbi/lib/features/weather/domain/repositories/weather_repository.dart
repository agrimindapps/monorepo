import 'package:dartz/dartz.dart';
import '../entities/weather_measurement_entity.dart';
import '../entities/rain_gauge_entity.dart';
import '../entities/weather_statistics_entity.dart';
import '../failures/weather_failures.dart';

/// Weather repository interface following Clean Architecture
/// Defines contracts for weather data operations
abstract class WeatherRepository {
  // ============================================================================
  // WEATHER MEASUREMENTS
  // ============================================================================
  
  /// Get all weather measurements for a location
  Future<Either<WeatherFailure, List<WeatherMeasurementEntity>>> getAllMeasurements({
    String? locationId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });
  
  /// Get weather measurement by ID
  Future<Either<WeatherFailure, WeatherMeasurementEntity>> getMeasurementById(String id);
  
  /// Get latest weather measurement for a location
  Future<Either<WeatherFailure, WeatherMeasurementEntity>> getLatestMeasurement([String? locationId]);
  
  /// Get weather measurements for a specific date range
  Future<Either<WeatherFailure, List<WeatherMeasurementEntity>>> getMeasurementsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? locationId,
  });
  
  /// Get weather measurements by location
  Future<Either<WeatherFailure, List<WeatherMeasurementEntity>>> getMeasurementsByLocation(
    String locationId, {
    int? limit,
  });
  
  /// Create new weather measurement
  Future<Either<WeatherFailure, WeatherMeasurementEntity>> createMeasurement(
    WeatherMeasurementEntity measurement,
  );
  
  /// Update existing weather measurement
  Future<Either<WeatherFailure, WeatherMeasurementEntity>> updateMeasurement(
    WeatherMeasurementEntity measurement,
  );
  
  /// Delete weather measurement
  Future<Either<WeatherFailure, void>> deleteMeasurement(String id);
  
  /// Search weather measurements with filters
  Future<Either<WeatherFailure, List<WeatherMeasurementEntity>>> searchMeasurements({
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

  // ============================================================================
  // RAIN GAUGES
  // ============================================================================
  
  /// Get all rain gauges
  Future<Either<WeatherFailure, List<RainGaugeEntity>>> getAllRainGauges();
  
  /// Get rain gauge by ID
  Future<Either<WeatherFailure, RainGaugeEntity>> getRainGaugeById(String id);
  
  /// Get rain gauges by location
  Future<Either<WeatherFailure, List<RainGaugeEntity>>> getRainGaugesByLocation(String locationId);
  
  /// Get active rain gauges
  Future<Either<WeatherFailure, List<RainGaugeEntity>>> getActiveRainGauges();
  
  /// Get rain gauges requiring maintenance
  Future<Either<WeatherFailure, List<RainGaugeEntity>>> getRainGaugesNeedingMaintenance();
  
  /// Create new rain gauge
  Future<Either<WeatherFailure, RainGaugeEntity>> createRainGauge(RainGaugeEntity rainGauge);
  
  /// Update existing rain gauge
  Future<Either<WeatherFailure, RainGaugeEntity>> updateRainGauge(RainGaugeEntity rainGauge);
  
  /// Delete rain gauge
  Future<Either<WeatherFailure, void>> deleteRainGauge(String id);
  
  /// Update rain gauge measurements
  Future<Either<WeatherFailure, RainGaugeEntity>> updateRainGaugeMeasurement(
    String gaugeId,
    double newRainfall,
    DateTime measurementTime,
  );
  
  /// Reset rain gauge accumulations
  Future<Either<WeatherFailure, RainGaugeEntity>> resetRainGaugeAccumulations(
    String gaugeId, {
    bool resetDaily = false,
    bool resetWeekly = false,
    bool resetMonthly = false,
    bool resetYearly = false,
  });
  
  /// Calibrate rain gauge
  Future<Either<WeatherFailure, RainGaugeEntity>> calibrateRainGauge(
    String gaugeId,
    double calibrationFactor,
  );

  // ============================================================================
  // WEATHER STATISTICS
  // ============================================================================
  
  /// Get weather statistics for a period
  Future<Either<WeatherFailure, WeatherStatisticsEntity>> getWeatherStatistics({
    required String locationId,
    required String period, // daily, weekly, monthly, yearly
    required DateTime startDate,
    required DateTime endDate,
  });
  
  /// Get historical weather statistics
  Future<Either<WeatherFailure, List<WeatherStatisticsEntity>>> getHistoricalStatistics({
    required String locationId,
    required String period,
    int? years,
  });
  
  /// Calculate and save weather statistics
  Future<Either<WeatherFailure, WeatherStatisticsEntity>> calculateStatistics({
    required String locationId,
    required String period,
    required DateTime startDate,
    required DateTime endDate,
    bool forceRecalculate = false,
  });
  
  /// Get weather trends comparison
  Future<Either<WeatherFailure, Map<String, dynamic>>> getWeatherTrends({
    required String locationId,
    required DateTime startDate,
    required DateTime endDate,
    String? comparisonPeriod,
  });
  
  /// Get weather anomalies
  Future<Either<WeatherFailure, List<String>>> detectWeatherAnomalies({
    required String locationId,
    required DateTime startDate,
    required DateTime endDate,
  });

  // ============================================================================
  // REAL-TIME DATA AND SYNC
  // ============================================================================
  
  /// Get real-time weather data from external APIs
  Future<Either<WeatherFailure, WeatherMeasurementEntity>> getCurrentWeatherFromAPI(
    double latitude,
    double longitude,
  );
  
  /// Get weather forecast from external APIs
  Future<Either<WeatherFailure, List<WeatherMeasurementEntity>>> getWeatherForecast(
    double latitude,
    double longitude, {
    int days = 7,
  });
  
  /// Sync local weather data with remote server
  Future<Either<WeatherFailure, int>> syncWeatherData();
  
  /// Upload pending weather measurements
  Future<Either<WeatherFailure, int>> uploadPendingMeasurements();
  
  /// Download weather updates from server
  Future<Either<WeatherFailure, int>> downloadWeatherUpdates({
    DateTime? since,
  });

  // ============================================================================
  // DATA QUALITY AND VALIDATION
  // ============================================================================
  
  /// Validate weather measurement data
  Future<Either<WeatherFailure, bool>> validateMeasurement(WeatherMeasurementEntity measurement);
  
  /// Check data quality for a period
  Future<Either<WeatherFailure, Map<String, dynamic>>> checkDataQuality({
    required String locationId,
    required DateTime startDate,
    required DateTime endDate,
  });
  
  /// Clean and correct weather data
  Future<Either<WeatherFailure, int>> cleanWeatherData({
    String? locationId,
    DateTime? startDate,
    DateTime? endDate,
  });
  
  /// Get data gaps in weather records
  Future<Either<WeatherFailure, List<Map<String, dynamic>>>> getDataGaps({
    required String locationId,
    required DateTime startDate,
    required DateTime endDate,
  });

  // ============================================================================
  // LOCATION AND DEVICE MANAGEMENT
  // ============================================================================
  
  /// Get weather locations
  Future<Either<WeatherFailure, List<Map<String, dynamic>>>> getWeatherLocations();
  
  /// Add weather location
  Future<Either<WeatherFailure, String>> addWeatherLocation({
    required String name,
    required double latitude,
    required double longitude,
    String? description,
  });
  
  /// Update weather location
  Future<Either<WeatherFailure, void>> updateWeatherLocation(
    String locationId,
    Map<String, dynamic> updates,
  );
  
  /// Delete weather location
  Future<Either<WeatherFailure, void>> deleteWeatherLocation(String locationId);
  
  /// Get weather devices status
  Future<Either<WeatherFailure, List<Map<String, dynamic>>>> getDevicesStatus();
  
  /// Update device status
  Future<Either<WeatherFailure, void>> updateDeviceStatus(
    String deviceId,
    String status, {
    Map<String, dynamic>? additionalData,
  });

  // ============================================================================
  // EXPORT AND IMPORT
  // ============================================================================
  
  /// Export weather data to various formats
  Future<Either<WeatherFailure, String>> exportWeatherData({
    required String locationId,
    required DateTime startDate,
    required DateTime endDate,
    String format = 'json', // json, csv, excel
  });
  
  /// Import weather data from file
  Future<Either<WeatherFailure, int>> importWeatherData(
    String filePath, {
    String format = 'json',
    bool validateData = true,
  });
  
  /// Backup weather data
  Future<Either<WeatherFailure, String>> backupWeatherData({
    List<String>? locationIds,
    DateTime? since,
  });
  
  /// Restore weather data from backup
  Future<Either<WeatherFailure, int>> restoreWeatherData(
    String backupPath, {
    bool replaceExisting = false,
  });

  // ============================================================================
  // SUBSCRIPTIONS AND NOTIFICATIONS
  // ============================================================================
  
  /// Subscribe to real-time weather updates
  Stream<WeatherMeasurementEntity> subscribeToWeatherUpdates(String? locationId);
  
  /// Subscribe to rain gauge updates
  Stream<RainGaugeEntity> subscribeToRainGaugeUpdates(String? gaugeId);
  
  /// Subscribe to weather alerts
  Stream<Map<String, dynamic>> subscribeToWeatherAlerts();
  
  /// Create weather alert rule
  Future<Either<WeatherFailure, String>> createWeatherAlert({
    required String locationId,
    required String alertType,
    required Map<String, dynamic> conditions,
    required String notificationMethod,
  });
  
  /// Delete weather alert rule
  Future<Either<WeatherFailure, void>> deleteWeatherAlert(String alertId);
  
  /// Get active weather alerts
  Future<Either<WeatherFailure, List<Map<String, dynamic>>>> getActiveWeatherAlerts({
    String? locationId,
  });
}