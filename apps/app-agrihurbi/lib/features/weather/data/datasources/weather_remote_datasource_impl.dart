// ignore_for_file: only_throw_errors

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/dio_client.dart';
import '../../domain/failures/weather_failures.dart';
import '../models/rain_gauge_model.dart';
import '../models/weather_measurement_model.dart';
import '../models/weather_statistics_model.dart';
import 'weather_remote_datasource.dart';

/// Concrete implementation of WeatherRemoteDataSource using REST API
@LazySingleton(as: WeatherRemoteDataSource)
class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final DioClient _dioClient;
  static const String _baseEndpoint = '/weather';
  
  WeatherRemoteDataSourceImpl(this._dioClient);
  
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
    try {
      final queryParameters = <String, dynamic>{};
      
      if (locationId != null) queryParameters['locationId'] = locationId;
      if (startDate != null) queryParameters['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParameters['endDate'] = endDate.toIso8601String();
      if (limit != null) queryParameters['limit'] = limit.toString();
      
      final response = await _dioClient.get(
        '$_baseEndpoint/measurements',
        queryParameters: queryParameters,
      );
      
      final List<dynamic> data = (response.data['data'] ?? <dynamic>[]) as List<dynamic>;
      return data.map((json) => WeatherMeasurementModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw WeatherNetworkFailure('Failed to fetch measurements: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  @override
  Future<WeatherMeasurementModel> getMeasurementById(String id) async {
    try {
      final response = await _dioClient.get('$_baseEndpoint/measurements/$id');
      return WeatherMeasurementModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Measurement not found: $id');
      }
      throw WeatherNetworkFailure('Failed to fetch measurement: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
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
  Future<WeatherMeasurementModel> getLatestMeasurement([String? locationId]) async {
    try {
      final measurements = await getAllMeasurements(locationId: locationId, limit: 1);
      if (measurements.isEmpty) {
        throw Exception('No measurements found');
      }
      return measurements.first;
    } catch (e) {
      rethrow;
    }
  }
  
  @override
  Future<WeatherMeasurementModel> createMeasurement(WeatherMeasurementModel measurement) async {
    try {
      final response = await _dioClient.post(
        '$_baseEndpoint/measurements',
        data: measurement.toJson(),
      );
      
      return WeatherMeasurementModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw WeatherNetworkFailure('Failed to create measurement: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  @override
  Future<WeatherMeasurementModel> updateMeasurement(WeatherMeasurementModel measurement) async {
    try {
      final response = await _dioClient.put(
        '$_baseEndpoint/measurements/${measurement.id}',
        data: measurement.toJson(),
      );
      
      return WeatherMeasurementModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Measurement not found: ${measurement.id}');
      }
      throw WeatherNetworkFailure('Failed to update measurement: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  @override
  Future<void> deleteMeasurement(String id) async {
    try {
      await _dioClient.delete('$_baseEndpoint/measurements/$id');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Consider 404 as success for deletion
        return;
      }
      throw WeatherNetworkFailure('Failed to delete measurement: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  @override
  Future<List<WeatherMeasurementModel>> uploadMeasurements(List<WeatherMeasurementModel> measurements) async {
    try {
      final response = await _dioClient.post(
        '$_baseEndpoint/measurements/batch',
        data: {
          'measurements': measurements.map((m) => m.toJson()).toList(),
        },
      );
      
      final List<dynamic> data = (response.data['data'] ?? <dynamic>[]) as List<dynamic>;
      return data.map((json) => WeatherMeasurementModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw WeatherNetworkFailure('Failed to upload measurements: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // ============================================================================
  // RAIN GAUGES
  // ============================================================================
  
  @override
  Future<List<RainGaugeModel>> getAllRainGauges() async {
    try {
      final response = await _dioClient.get('$_baseEndpoint/rain-gauges');
      
      final List<dynamic> data = (response.data['data'] ?? <dynamic>[]) as List<dynamic>;
      return data.map((json) => RainGaugeModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw WeatherNetworkFailure('Failed to fetch rain gauges: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  @override
  Future<RainGaugeModel> getRainGaugeById(String id) async {
    try {
      final response = await _dioClient.get('$_baseEndpoint/rain-gauges/$id');
      return RainGaugeModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Rain gauge not found: $id');
      }
      throw WeatherNetworkFailure('Failed to fetch rain gauge: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  @override
  Future<List<RainGaugeModel>> getRainGaugesByLocation(String locationId) async {
    try {
      final response = await _dioClient.get(
        '$_baseEndpoint/rain-gauges',
        queryParameters: {'locationId': locationId},
      );
      
      final List<dynamic> data = (response.data['data'] ?? <dynamic>[]) as List<dynamic>;
      return data.map((json) => RainGaugeModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw WeatherNetworkFailure('Failed to fetch rain gauges by location: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  @override
  Future<List<RainGaugeModel>> getActiveRainGauges() async {
    try {
      final response = await _dioClient.get(
        '$_baseEndpoint/rain-gauges',
        queryParameters: {'status': 'active'},
      );
      
      final List<dynamic> data = (response.data['data'] ?? <dynamic>[]) as List<dynamic>;
      return data.map((json) => RainGaugeModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw WeatherNetworkFailure('Failed to fetch active rain gauges: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  @override
  Future<RainGaugeModel> createRainGauge(RainGaugeModel rainGauge) async {
    try {
      final response = await _dioClient.post(
        '$_baseEndpoint/rain-gauges',
        data: rainGauge.toJson(),
      );
      
      return RainGaugeModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw WeatherNetworkFailure('Failed to create rain gauge: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  @override
  Future<RainGaugeModel> updateRainGauge(RainGaugeModel rainGauge) async {
    try {
      final response = await _dioClient.put(
        '$_baseEndpoint/rain-gauges/${rainGauge.id}',
        data: rainGauge.toJson(),
      );
      
      return RainGaugeModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Rain gauge not found: ${rainGauge.id}');
      }
      throw WeatherNetworkFailure('Failed to update rain gauge: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  @override
  Future<void> deleteRainGauge(String id) async {
    try {
      await _dioClient.delete('$_baseEndpoint/rain-gauges/$id');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Consider 404 as success for deletion
        return;
      }
      throw WeatherNetworkFailure('Failed to delete rain gauge: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<RainGaugeModel>> syncRainGauges(List<RainGaugeModel> localGauges) async {
    try {
      final response = await _dioClient.post(
        '$_baseEndpoint/rain-gauges/sync',
        data: {
          'gauges': localGauges.map((g) => g.toJson()).toList(),
        },
      );
      
      final List<dynamic> data = (response.data['data'] ?? <dynamic>[]) as List<dynamic>;
      return data.map((json) => RainGaugeModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw WeatherNetworkFailure('Failed to sync rain gauges: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<RainGaugeModel> updateRainGaugeMeasurement(String gaugeId, double rainfall, DateTime timestamp) async {
    try {
      final response = await _dioClient.patch(
        '$_baseEndpoint/rain-gauges/$gaugeId/measurement',
        data: {
          'rainfall': rainfall,
          'timestamp': timestamp.toIso8601String(),
        },
      );
      
      return RainGaugeModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Rain gauge not found: $gaugeId');
      }
      throw WeatherNetworkFailure('Failed to update rain gauge measurement: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // ============================================================================
  // WEATHER STATISTICS
  // ============================================================================
  
  @override
  Future<List<WeatherStatisticsModel>> getStatistics({
    String? locationId,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};
      
      if (locationId != null) queryParameters['locationId'] = locationId;
      if (period != null) queryParameters['period'] = period;
      if (startDate != null) queryParameters['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParameters['endDate'] = endDate.toIso8601String();
      
      final response = await _dioClient.get(
        '$_baseEndpoint/statistics',
        queryParameters: queryParameters,
      );
      
      final List<dynamic> data = (response.data['data'] ?? <dynamic>[]) as List<dynamic>;
      return data.map((json) => WeatherStatisticsModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw WeatherNetworkFailure('Failed to fetch statistics: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<WeatherStatisticsModel> getStatisticsById(String id) async {
    try {
      final response = await _dioClient.get('$_baseEndpoint/statistics/$id');
      return WeatherStatisticsModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Statistics not found: $id');
      }
      throw WeatherNetworkFailure('Failed to fetch statistics: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  Future<List<WeatherStatisticsModel>> getStatisticsByLocation(String locationId) async {
    return getStatistics(locationId: locationId);
  }
  
  Future<List<WeatherStatisticsModel>> getStatisticsByPeriod(String period) async {
    return getStatistics(period: period);
  }

  Future<WeatherStatisticsModel> generateStatistics({
    required String locationId,
    required String period,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _dioClient.post(
        '$_baseEndpoint/statistics/generate',
        data: {
          'locationId': locationId,
          'period': period,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );
      
      return WeatherStatisticsModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw WeatherNetworkFailure('Failed to generate statistics: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<WeatherStatisticsModel> updateStatistics(WeatherStatisticsModel statistics) async {
    try {
      final response = await _dioClient.put(
        '$_baseEndpoint/statistics/${statistics.id}',
        data: statistics.toJson(),
      );
      
      return WeatherStatisticsModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Statistics not found: ${statistics.id}');
      }
      throw WeatherNetworkFailure('Failed to update statistics: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> deleteStatistics(String id) async {
    try {
      await _dioClient.delete('$_baseEndpoint/statistics/$id');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Consider 404 as success for deletion
        return;
      }
      throw WeatherNetworkFailure('Failed to delete statistics: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================
  
  @override
  Future<WeatherStatisticsModel> calculateStatistics({
    required String locationId,
    required String period,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _dioClient.post(
        '$_baseEndpoint/statistics/calculate',
        data: {
          'locationId': locationId,
          'period': period,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );
      
      return WeatherStatisticsModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw WeatherNetworkFailure('Failed to calculate statistics: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  @override
  Future<WeatherMeasurementModel> getCurrentWeatherFromAPI(
    double latitude,
    double longitude, {
    String provider = 'openweathermap',
  }) async {
    try {
      final response = await _dioClient.get(
        '$_baseEndpoint/current',
        queryParameters: {
          'lat': latitude.toString(),
          'lon': longitude.toString(),
          'provider': provider,
        },
      );
      
      return WeatherMeasurementModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw WeatherNetworkFailure('Failed to get current weather: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
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
      final response = await _dioClient.get(
        '$_baseEndpoint/forecast',
        queryParameters: {
          'lat': latitude.toString(),
          'lon': longitude.toString(),
          'days': days.toString(),
          'provider': provider,
        },
      );
      
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data.map((json) => WeatherMeasurementModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw WeatherNetworkFailure('Failed to get weather forecast: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  @override
  Future<List<WeatherMeasurementModel>> downloadMeasurements({
    String? locationId,
    DateTime? since,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (locationId != null) queryParams['locationId'] = locationId;
      if (since != null) queryParams['since'] = since.toIso8601String();
      
      final response = await _dioClient.get(
        '$_baseEndpoint/measurements/download',
        queryParameters: queryParams,
      );
      
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data.map((json) => WeatherMeasurementModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw WeatherNetworkFailure('Failed to download measurements: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  @override
  Future<List<RainGaugeModel>> downloadRainGauges({DateTime? since}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (since != null) queryParams['since'] = since.toIso8601String();
      
      final response = await _dioClient.get(
        '$_baseEndpoint/rain-gauges/download',
        queryParameters: queryParams,
      );
      
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data.map((json) => RainGaugeModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw WeatherNetworkFailure('Failed to download rain gauges: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  Future<void> uploadSyncData(Map<String, dynamic> syncData) async {
    try {
      await _dioClient.post(
        '$_baseEndpoint/sync/upload',
        data: syncData,
      );
    } on DioException catch (e) {
      throw WeatherNetworkFailure('Failed to upload sync data: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  @override
  Future<Map<String, dynamic>> getServerStatus() async {
    try {
      final response = await _dioClient.get('$_baseEndpoint/server-status');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw WeatherNetworkFailure('Failed to get server status: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}