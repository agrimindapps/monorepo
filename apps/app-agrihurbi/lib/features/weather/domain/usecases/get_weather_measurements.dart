import 'package:dartz/dartz.dart';

import '../entities/weather_measurement_entity.dart';
import '../failures/weather_failures.dart';
import '../repositories/weather_repository.dart';

/// Use case for retrieving weather measurements
/// Supports various filtering options and location-based queries
class GetWeatherMeasurements {
  final WeatherRepository _repository;

  const GetWeatherMeasurements(this._repository);

  /// Get all weather measurements with optional filters
  Future<Either<WeatherFailure, List<WeatherMeasurementEntity>>> call({
    String? locationId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      return await _repository.getAllMeasurements(
        locationId: locationId,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );
    } catch (e) {
      return Left(WeatherMeasurementFetchFailure(e.toString()));
    }
  }

  /// Get weather measurements for a specific date range
  Future<Either<WeatherFailure, List<WeatherMeasurementEntity>>> byDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? locationId,
  }) async {
    try {
      if (startDate.isAfter(endDate)) {
        return Left(InvalidDateRangeFailure(
          startDate, 
          endDate, 
          'Start date must be before end date'
        ));
      }
      final daysDifference = endDate.difference(startDate).inDays;
      if (daysDifference > 365) {
        return Left(InvalidDateRangeFailure(
          startDate, 
          endDate, 
          'Date range cannot exceed 365 days'
        ));
      }

      return await _repository.getMeasurementsByDateRange(
        startDate,
        endDate,
        locationId: locationId,
      );
    } catch (e) {
      return Left(WeatherMeasurementFetchFailure(e.toString()));
    }
  }

  /// Get weather measurements by location
  Future<Either<WeatherFailure, List<WeatherMeasurementEntity>>> byLocation(
    String locationId, {
    int? limit,
  }) async {
    try {
      if (locationId.trim().isEmpty) {
        return const Left(WeatherDataFailure('Location ID cannot be empty'));
      }

      return await _repository.getMeasurementsByLocation(
        locationId,
        limit: limit,
      );
    } catch (e) {
      return Left(WeatherMeasurementFetchFailure(e.toString()));
    }
  }

  /// Get latest weather measurement
  Future<Either<WeatherFailure, WeatherMeasurementEntity>> latest([String? locationId]) async {
    try {
      return await _repository.getLatestMeasurement(locationId);
    } catch (e) {
      return Left(WeatherMeasurementFetchFailure(e.toString()));
    }
  }

  /// Get weather measurement by ID
  Future<Either<WeatherFailure, WeatherMeasurementEntity>> byId(String id) async {
    try {
      if (id.trim().isEmpty) {
        return const Left(WeatherDataFailure('Measurement ID cannot be empty'));
      }

      return await _repository.getMeasurementById(id);
    } catch (e) {
      return Left(WeatherMeasurementNotFoundFailure(id));
    }
  }

  /// Search weather measurements with advanced filters
  Future<Either<WeatherFailure, List<WeatherMeasurementEntity>>> search({
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
      if (minTemperature != null && maxTemperature != null) {
        if (minTemperature > maxTemperature) {
          return const Left(WeatherDataFailure('Minimum temperature cannot be greater than maximum temperature'));
        }
      }
      if (minRainfall != null && maxRainfall != null) {
        if (minRainfall > maxRainfall) {
          return const Left(WeatherDataFailure('Minimum rainfall cannot be greater than maximum rainfall'));
        }
      }
      if (fromDate != null && toDate != null) {
        if (fromDate.isAfter(toDate)) {
          return Left(InvalidDateRangeFailure(
            fromDate,
            toDate,
            'From date must be before to date'
          ));
        }
      }

      return await _repository.searchMeasurements(
        locationId: locationId,
        fromDate: fromDate,
        toDate: toDate,
        minTemperature: minTemperature,
        maxTemperature: maxTemperature,
        weatherCondition: weatherCondition,
        minRainfall: minRainfall,
        maxRainfall: maxRainfall,
        limit: limit,
      );
    } catch (e) {
      return Left(WeatherMeasurementFetchFailure(e.toString()));
    }
  }

  /// Get recent weather measurements (last N days)
  Future<Either<WeatherFailure, List<WeatherMeasurementEntity>>> recent(
    int days, {
    String? locationId,
  }) async {
    try {
      if (days <= 0) {
        return const Left(WeatherDataFailure('Days must be a positive number'));
      }

      if (days > 90) {
        return const Left(WeatherDataFailure('Cannot retrieve more than 90 days of recent data'));
      }

      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));

      return await byDateRange(startDate, endDate, locationId: locationId);
    } catch (e) {
      return Left(WeatherMeasurementFetchFailure(e.toString()));
    }
  }

  /// Get today's weather measurements
  Future<Either<WeatherFailure, List<WeatherMeasurementEntity>>> today([String? locationId]) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(microseconds: 1));

      return await byDateRange(startOfDay, endOfDay, locationId: locationId);
    } catch (e) {
      return Left(WeatherMeasurementFetchFailure(e.toString()));
    }
  }

  /// Get this week's weather measurements
  Future<Either<WeatherFailure, List<WeatherMeasurementEntity>>> thisWeek([String? locationId]) async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startOfWeekDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      final endOfWeek = startOfWeekDay.add(const Duration(days: 7));

      return await byDateRange(startOfWeekDay, endOfWeek, locationId: locationId);
    } catch (e) {
      return Left(WeatherMeasurementFetchFailure(e.toString()));
    }
  }

  /// Get this month's weather measurements
  Future<Either<WeatherFailure, List<WeatherMeasurementEntity>>> thisMonth([String? locationId]) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 1);

      return await byDateRange(startOfMonth, endOfMonth, locationId: locationId);
    } catch (e) {
      return Left(WeatherMeasurementFetchFailure(e.toString()));
    }
  }

  /// Get weather measurements for favorable agricultural conditions
  Future<Either<WeatherFailure, List<WeatherMeasurementEntity>>> favorableForAgriculture({
    String? locationId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      const double minTemp = 10.0;
      const double maxTemp = 35.0;
      const double maxWindSpeed = 50.0;

      final result = await search(
        locationId: locationId,
        fromDate: startDate,
        toDate: endDate,
        minTemperature: minTemp,
        maxTemperature: maxTemp,
        limit: limit,
      );

      return result.fold(
        (failure) => Left(failure),
        (measurements) {
          final favorable = measurements.where((measurement) {
            return measurement.isFavorableForAgriculture &&
                   measurement.windSpeed <= maxWindSpeed;
          }).toList();

          return Right(favorable);
        },
      );
    } catch (e) {
      return Left(WeatherMeasurementFetchFailure(e.toString()));
    }
  }
}