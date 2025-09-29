import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../domain/failures/weather_failures.dart';
import '../models/rain_gauge_model.dart';
import '../models/weather_measurement_model.dart';
import '../models/weather_statistics_model.dart';

/// Abstract interface for weather remote data source operations
abstract class WeatherRemoteDataSource {
  // ============================================================================
  // WEATHER MEASUREMENTS
  // ============================================================================
  
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

  // ============================================================================
  // RAIN GAUGES
  // ============================================================================
  
  Future<List<RainGaugeModel>> getAllRainGauges();
  
  Future<RainGaugeModel> getRainGaugeById(String id);
  
  Future<List<RainGaugeModel>> getRainGaugesByLocation(String locationId);
  
  Future<List<RainGaugeModel>> getActiveRainGauges();
  
  Future<RainGaugeModel> createRainGauge(RainGaugeModel rainGauge);
  
  Future<RainGaugeModel> updateRainGauge(RainGaugeModel rainGauge);
  
  Future<void> deleteRainGauge(String id);
  
  Future<RainGaugeModel> updateRainGaugeMeasurement(String gaugeId, double rainfall, DateTime timestamp);

  // ============================================================================
  // WEATHER STATISTICS
  // ============================================================================
  
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

  // ============================================================================
  // EXTERNAL APIs
  // ============================================================================
  
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

  // ============================================================================
  // SYNC OPERATIONS
  // ============================================================================
  
  Future<List<WeatherMeasurementModel>> downloadMeasurements({DateTime? since});
  
  Future<List<RainGaugeModel>> downloadRainGauges({DateTime? since});
  
  Future<Map<String, dynamic>> getServerStatus();
}

/// Implementation of weather remote data source using HTTP APIs
class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final DioClient _dioClient;
  
  // API Configuration
  static const String _baseUrl = 'https://api.weather-service.com/v1';
  static const String _openWeatherApiKey = 'YOUR_OPENWEATHERMAP_API_KEY';
  static const String _accuWeatherApiKey = 'YOUR_ACCUWEATHER_API_KEY';
  
  WeatherRemoteDataSourceImpl(_dioClient);

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
      final queryParams = <String, dynamic>{};
      
      if (locationId != null) queryParams['location_id'] = locationId;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
      if (limit != null) queryParams['limit'] = limit;

      final response = await _dioClient.get(
        '$_baseUrl/measurements',
        queryParameters: queryParams,
      );

      final List<dynamic> data = (response.data['measurements'] as List?) ?? [];
      return data.map((json) => WeatherMeasurementModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e, 'getAllMeasurements');
    } catch (e) {
      throw Exception('Weather service error: ${e.toString()}');
    }
  }

  @override
  Future<WeatherMeasurementModel> getMeasurementById(String id) async {
    try {
      final response = await _dioClient.get('$_baseUrl/measurements/$id');
      return WeatherMeasurementModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Measurement not found with id: $id');
      }
      throw _handleDioError(e, 'getMeasurementById');
    } catch (e) {
      throw Exception('Weather service error: ${e.toString()}');
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
  Future<WeatherMeasurementModel> getLatestMeasurement([String? locationId]) async {
    try {
      final measurements = await getAllMeasurements(locationId: locationId, limit: 1);
      if (measurements.isEmpty) {
        throw const WeatherMeasurementFetchFailure('No measurements found');
      }
      return measurements.first;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<WeatherMeasurementModel> createMeasurement(WeatherMeasurementModel measurement) async {
    try {
      final response = await _dioClient.post(
        '$_baseUrl/measurements',
        data: measurement.toJson(),
      );
      return WeatherMeasurementModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e, 'createMeasurement');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<WeatherMeasurementModel> updateMeasurement(WeatherMeasurementModel measurement) async {
    try {
      final response = await _dioClient.put(
        '$_baseUrl/measurements/${measurement.id}',
        data: measurement.toJson(),
      );
      return WeatherMeasurementModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Measurement not found with id: ${measurement.id}');
      }
      throw _handleDioError(e, 'updateMeasurement');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> deleteMeasurement(String id) async {
    try {
      await _dioClient.delete('$_baseUrl/measurements/$id');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Measurement not found with id: $id');
      }
      throw _handleDioError(e, 'deleteMeasurement');
    } catch (e) {
      throw Exception('Weather service error: ${e.toString()}');
    }
  }

  @override
  Future<List<WeatherMeasurementModel>> uploadMeasurements(
    List<WeatherMeasurementModel> measurements,
  ) async {
    try {
      final response = await _dioClient.post(
        '$_baseUrl/measurements/batch',
        data: {
          'measurements': measurements.map((m) => m.toJson()).toList(),
        },
      );

      final List<dynamic> data = (response.data['measurements'] as List?) ?? [];
      return data.map((json) => WeatherMeasurementModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e, 'uploadMeasurements');
    } catch (e) {
      throw Exception('Failed to upload measurements: $e (${measurements.length} measurements)');
    }
  }

  // ============================================================================
  // RAIN GAUGES IMPLEMENTATION
  // ============================================================================

  @override
  Future<List<RainGaugeModel>> getAllRainGauges() async {
    try {
      final response = await _dioClient.get('$_baseUrl/rain-gauges');
      final List<dynamic> data = (response.data['rain_gauges'] as List?) ?? [];
      return data.map((json) => RainGaugeModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e, 'getAllRainGauges');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<RainGaugeModel> getRainGaugeById(String id) async {
    try {
      final response = await _dioClient.get('$_baseUrl/rain-gauges/$id');
      return RainGaugeModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Rain gauge not found with id: $id');
      }
      throw _handleDioError(e, 'getRainGaugeById');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<RainGaugeModel>> getRainGaugesByLocation(String locationId) async {
    try {
      final response = await _dioClient.get(
        '$_baseUrl/rain-gauges',
        queryParameters: {'location_id': locationId},
      );
      final List<dynamic> data = (response.data['rain_gauges'] as List?) ?? [];
      return data.map((json) => RainGaugeModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e, 'getRainGaugesByLocation');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<RainGaugeModel>> getActiveRainGauges() async {
    try {
      final response = await _dioClient.get(
        '$_baseUrl/rain-gauges',
        queryParameters: {'status': 'active'},
      );
      final List<dynamic> data = (response.data['rain_gauges'] as List?) ?? [];
      return data.map((json) => RainGaugeModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e, 'getActiveRainGauges');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<RainGaugeModel> createRainGauge(RainGaugeModel rainGauge) async {
    try {
      final response = await _dioClient.post(
        '$_baseUrl/rain-gauges',
        data: rainGauge.toJson(),
      );
      return RainGaugeModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e, 'createRainGauge');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<RainGaugeModel> updateRainGauge(RainGaugeModel rainGauge) async {
    try {
      final response = await _dioClient.put(
        '$_baseUrl/rain-gauges/${rainGauge.id}',
        data: rainGauge.toJson(),
      );
      return RainGaugeModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Rain gauge not found with id: ${rainGauge.id}');
      }
      throw _handleDioError(e, 'updateRainGauge');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> deleteRainGauge(String id) async {
    try {
      await _dioClient.delete('$_baseUrl/rain-gauges/$id');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Rain gauge not found with id: $id');
      }
      throw _handleDioError(e, 'deleteRainGauge');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<RainGaugeModel> updateRainGaugeMeasurement(
    String gaugeId,
    double rainfall,
    DateTime timestamp,
  ) async {
    try {
      final response = await _dioClient.patch(
        '$_baseUrl/rain-gauges/$gaugeId/measurements',
        data: {
          'rainfall': rainfall,
          'timestamp': timestamp.toIso8601String(),
        },
      );
      return RainGaugeModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Rain gauge not found with id: $gaugeId');
      }
      throw _handleDioError(e, 'updateRainGaugeMeasurement');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ============================================================================
  // WEATHER STATISTICS IMPLEMENTATION
  // ============================================================================

  @override
  Future<List<WeatherStatisticsModel>> getStatistics({
    String? locationId,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (locationId != null) queryParams['location_id'] = locationId;
      if (period != null) queryParams['period'] = period;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

      final response = await _dioClient.get(
        '$_baseUrl/statistics',
        queryParameters: queryParams,
      );

      final List<dynamic> data = (response.data['statistics'] as List?) ?? [];
      return data.map((json) => WeatherStatisticsModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e, 'getStatistics');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<WeatherStatisticsModel> calculateStatistics({
    required String locationId,
    required String period,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _dioClient.post(
        '$_baseUrl/statistics/calculate',
        data: {
          'location_id': locationId,
          'period': period,
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      );
      return WeatherStatisticsModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e, 'calculateStatistics');
    } catch (e) {
      throw Exception('Failed to calculate statistics for period $period: ${e.toString()}');
    }
  }

  // ============================================================================
  // EXTERNAL APIs IMPLEMENTATION
  // ============================================================================

  @override
  Future<WeatherMeasurementModel> getCurrentWeatherFromAPI(
    double latitude,
    double longitude, {
    String provider = 'openweathermap',
  }) async {
    try {
      switch (provider.toLowerCase()) {
        case 'openweathermap':
          return await _getCurrentWeatherFromOpenWeatherMap(latitude, longitude);
        case 'accuweather':
          return await _getCurrentWeatherFromAccuWeather(latitude, longitude);
        default:
          throw Exception('Unsupported weather provider: $provider (status: 400)');
      }
    } catch (e) {
      if (e is WeatherFailure) rethrow;
      throw Exception('Weather API error for provider $provider (status: 500): ${e.toString()}');
    }
  }

  @override
  Future<List<WeatherMeasurementModel>> getWeatherForecast(
    double latitude,
    double longitude, {
    int days = 7,
    String provider = 'openweathermap',
  }) async {
    try {
      switch (provider.toLowerCase()) {
        case 'openweathermap':
          return await _getForecastFromOpenWeatherMap(latitude, longitude, days);
        case 'accuweather':
          return await _getForecastFromAccuWeather(latitude, longitude, days);
        default:
          throw Exception('Unsupported weather provider: $provider (status: 400)');
      }
    } catch (e) {
      if (e is WeatherFailure) rethrow;
      throw Exception('Weather forecast API error for provider $provider (status: 500): ${e.toString()}');
    }
  }

  // ============================================================================
  // SYNC OPERATIONS IMPLEMENTATION
  // ============================================================================

  @override
  Future<List<WeatherMeasurementModel>> downloadMeasurements({DateTime? since}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (since != null) queryParams['since'] = since.toIso8601String();

      final response = await _dioClient.get(
        '$_baseUrl/sync/measurements',
        queryParameters: queryParams,
      );

      final List<dynamic> data = (response.data['measurements'] as List?) ?? [];
      return data.map((json) => WeatherMeasurementModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e, 'downloadMeasurements');
    } catch (e) {
      throw Exception('Failed to download measurements: $e');
    }
  }

  @override
  Future<List<RainGaugeModel>> downloadRainGauges({DateTime? since}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (since != null) queryParams['since'] = since.toIso8601String();

      final response = await _dioClient.get(
        '$_baseUrl/sync/rain-gauges',
        queryParameters: queryParams,
      );

      final List<dynamic> data = (response.data['rain_gauges'] as List?) ?? [];
      return data.map((json) => RainGaugeModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e, 'downloadRainGauges');
    } catch (e) {
      throw Exception('Failed to download rain gauges: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getServerStatus() async {
    try {
      final response = await _dioClient.get('$_baseUrl/status');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e, 'getServerStatus');
    } catch (e) {
      throw Exception('Weather service error: ${e.toString()}');
    }
  }

  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================

  /// Get current weather from OpenWeatherMap API
  Future<WeatherMeasurementModel> _getCurrentWeatherFromOpenWeatherMap(
    double latitude,
    double longitude,
  ) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://api.openweathermap.org/data/2.5/weather',
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
          'appid': _openWeatherApiKey,
          'units': 'metric',
        },
      );

      return WeatherMeasurementModel.fromOpenWeatherMapApi(
        response.data as Map<String, dynamic>,
        'external_${latitude}_$longitude',
        (response.data['name'] as String?) ?? 'Unknown Location',
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const WeatherApiAuthFailure('openweathermap');
      } else if (e.response?.statusCode == 429) {
        throw Exception('Rate limit exceeded for OpenWeatherMap, retry after: ${DateTime.now().add(const Duration(minutes: 60))}');
      }
      throw Exception('OpenWeatherMap API error (status: ${e.response?.statusCode ?? 500}): ${e.message ?? 'Unknown error'}');
    }
  }

  /// Get current weather from AccuWeather API
  Future<WeatherMeasurementModel> _getCurrentWeatherFromAccuWeather(
    double latitude,
    double longitude,
  ) async {
    try {
      // First, get location key
      final locationDio = Dio();
      final locationResponse = await locationDio.get(
        'https://dataservice.accuweather.com/locations/v1/cities/geoposition/search',
        queryParameters: {
          'apikey': _accuWeatherApiKey,
          'q': '$latitude,$longitude',
        },
      );

      final locationKey = locationResponse.data['Key'];

      // Then get current conditions
      final weatherDio = Dio();
      final weatherResponse = await weatherDio.get(
        'https://dataservice.accuweather.com/currentconditions/v1/$locationKey',
        queryParameters: {
          'apikey': _accuWeatherApiKey,
          'details': true,
        },
      );

      final weatherData = weatherResponse.data[0];
      
      return WeatherMeasurementModel.fromAccuWeatherApi(
        weatherData as Map<String, dynamic>,
        'external_${latitude}_$longitude',
        (locationResponse.data['LocalizedName'] as String?) ?? 'Unknown Location',
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const WeatherApiAuthFailure('accuweather');
      } else if (e.response?.statusCode == 503) {
        throw Exception('Service unavailable for AccuWeather, retry after: ${DateTime.now().add(const Duration(hours: 1))}');
      }
      throw Exception('AccuWeather API error (status: ${e.response?.statusCode ?? 500}): ${e.message ?? 'Unknown error'}');
    }
  }

  /// Get weather forecast from OpenWeatherMap API
  Future<List<WeatherMeasurementModel>> _getForecastFromOpenWeatherMap(
    double latitude,
    double longitude,
    int days,
  ) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://api.openweathermap.org/data/2.5/forecast',
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
          'appid': _openWeatherApiKey,
          'units': 'metric',
          'cnt': days * 8, // 8 forecasts per day (every 3 hours)
        },
      );

      final List<dynamic> forecastList = (response.data['list'] as List?) ?? [];
      final cityName = response.data['city']?['name'] ?? 'Unknown Location';
      
      return forecastList
          .map((forecast) => WeatherMeasurementModel.fromOpenWeatherMapApi(
                forecast as Map<String, dynamic>,
                'external_${latitude}_$longitude',
                (cityName as String?) ?? 'Unknown Location',
              ))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const WeatherApiAuthFailure('openweathermap');
      } else if (e.response?.statusCode == 429) {
        throw Exception('Rate limit exceeded for OpenWeatherMap forecast, retry after: ${DateTime.now().add(const Duration(minutes: 60))}');
      }
      throw Exception('OpenWeatherMap forecast API error (status: ${e.response?.statusCode ?? 500}): ${e.message ?? 'Unknown error'}');
    }
  }

  /// Get weather forecast from AccuWeather API (simplified implementation)
  Future<List<WeatherMeasurementModel>> _getForecastFromAccuWeather(
    double latitude,
    double longitude,
    int days,
  ) async {
    // For brevity, returning current weather as a single-item forecast
    // In a real implementation, you would call the appropriate forecast endpoints
    final current = await _getCurrentWeatherFromAccuWeather(latitude, longitude);
    return [current];
  }

  /// Handle Dio exceptions and convert to weather failures
  WeatherFailure _handleDioError(DioException error, String operation) {
    final statusCode = error.response?.statusCode ?? 500;
    final message = (error.response?.data?['message'] as String?) ?? error.message ?? 'Unknown error';

    switch (statusCode) {
      case 400:
        return WeatherDataFailure('Bad request: $message');
      case 401:
        return WeatherApiAuthFailure('weather-service', message);
      case 403:
        return const WeatherApiAuthFailure('weather-service', 'Access forbidden');
      case 404:
        return const WeatherDataFailure('Resource not found');
      case 429:
        return WeatherApiRateLimitFailure('weather-service', DateTime.now().add(const Duration(minutes: 15)));
      case 500:
      case 502:
      case 503:
        return WeatherApiFailure('weather-service', statusCode, 'Server error: $message');
      default:
        return WeatherNetworkFailure('Network error during $operation: $message');
    }
  }
}