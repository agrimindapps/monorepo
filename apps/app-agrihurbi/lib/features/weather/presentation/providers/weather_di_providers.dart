import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/weather_local_datasource.dart';
import '../../data/datasources/weather_local_datasource_impl.dart';
import '../../data/datasources/weather_remote_datasource.dart';
import '../../data/datasources/weather_remote_datasource_impl.dart';
import '../../data/repositories/weather_repository_impl.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../domain/usecases/calculate_weather_statistics.dart';
import '../../domain/usecases/create_weather_measurement.dart';
import '../../domain/usecases/get_rain_gauges.dart';
import '../../domain/usecases/get_weather_measurements.dart';

// Dio Provider
final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

// Data Sources
final weatherLocalDataSourceProvider = Provider<WeatherLocalDataSource>((ref) {
  return WeatherLocalDataSourceImpl();
});

final weatherRemoteDataSourceProvider = Provider<WeatherRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return WeatherRemoteDataSourceImpl(dio);
});

// Repository
final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  final localDataSource = ref.watch(weatherLocalDataSourceProvider);
  final remoteDataSource = ref.watch(weatherRemoteDataSourceProvider);
  return WeatherRepositoryImpl(localDataSource, remoteDataSource);
});

// Use Cases
final getWeatherMeasurementsProvider = Provider<GetWeatherMeasurements>((ref) {
  final repository = ref.watch(weatherRepositoryProvider);
  return GetWeatherMeasurements(repository);
});

final createWeatherMeasurementProvider = Provider<CreateWeatherMeasurement>((ref) {
  final repository = ref.watch(weatherRepositoryProvider);
  return CreateWeatherMeasurement(repository);
});

final getRainGaugesProvider = Provider<GetRainGauges>((ref) {
  final repository = ref.watch(weatherRepositoryProvider);
  return GetRainGauges(repository);
});

final calculateWeatherStatisticsProvider = Provider<CalculateWeatherStatistics>((ref) {
  final repository = ref.watch(weatherRepositoryProvider);
  return CalculateWeatherStatistics(repository);
});
