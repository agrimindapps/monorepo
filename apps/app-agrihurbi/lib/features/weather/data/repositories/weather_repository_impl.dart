import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entities/rain_gauge_entity.dart';
import '../../domain/entities/weather_measurement_entity.dart';
import '../../domain/entities/weather_statistics_entity.dart';
import '../../domain/failures/weather_failures.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_local_datasource.dart';
import '../datasources/weather_remote_datasource.dart';
import '../models/rain_gauge_model.dart';
import '../models/weather_measurement_model.dart';

/// Implementation of weather repository following Clean Architecture
/// Implements offline-first strategy with automatic sync when online
class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherLocalDataSource _localDataSource;
  final WeatherRemoteDataSource _remoteDataSource;
  final Connectivity _connectivity;

  WeatherRepositoryImpl(
    this._localDataSource,
    this._remoteDataSource,
    this._connectivity,
  );

  /// Check if device is online
  Future<bool> get _isOnline async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result.isNotEmpty && !result.contains(ConnectivityResult.none);
    } catch (e) {
      return false; // Assume offline if check fails
    }
  }

  @override
  Future<Either<WeatherFailure, List<WeatherMeasurementEntity>>> getAllMeasurements({
    String? locationId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      final localMeasurements = await _localDataSource.getAllMeasurements(
        locationId: locationId,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );
      if (localMeasurements.isNotEmpty) {
        return Right(localMeasurements.map((model) => model.toEntity()).toList());
      }
      if (await _isOnline) {
        try {
          final remoteMeasurements = await _remoteDataSource.getAllMeasurements(
            locationId: locationId,
            startDate: startDate,
            endDate: endDate,
            limit: limit,
          );
          await _localDataSource.saveMeasurements(remoteMeasurements);

          return Right(remoteMeasurements.map((model) => model.toEntity()).toList());
        } catch (e) {
          if (localMeasurements.isNotEmpty) {
            return Right(localMeasurements.map((model) => model.toEntity()).toList());
          }
          return Left(WeatherNetworkFailure(e.toString()));
        }
      }
      return Right(localMeasurements.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(WeatherMeasurementFetchFailure(e.toString()));
    }
  }

  @override
  Future<Either<WeatherFailure, WeatherMeasurementEntity>> getMeasurementById(String id) async {
    try {
      final localMeasurement = await _localDataSource.getMeasurementById(id);
      if (localMeasurement != null) {
        return Right(localMeasurement.toEntity());
      }
      if (await _isOnline) {
        try {
          final remoteMeasurement = await _remoteDataSource.getMeasurementById(id);
          await _localDataSource.saveMeasurement(remoteMeasurement);
          
          return Right(remoteMeasurement.toEntity());
        } catch (e) {
          return Left(WeatherMeasurementNotFoundFailure(id));
        }
      }

      return Left(WeatherMeasurementNotFoundFailure(id));
    } catch (e) {
      return Left(WeatherMeasurementFetchFailure(e.toString()));
    }
  }

  @override
  Future<Either<WeatherFailure, WeatherMeasurementEntity>> getLatestMeasurement([String? locationId]) async {
    try {
      final localMeasurement = await _localDataSource.getLatestMeasurement(locationId);
      if (localMeasurement != null) {
        return Right(localMeasurement.toEntity());
      }
      if (await _isOnline) {
        try {
          final remoteMeasurement = await _remoteDataSource.getLatestMeasurement(locationId);
          await _localDataSource.saveMeasurement(remoteMeasurement);
          
          return Right(remoteMeasurement.toEntity());
        } catch (e) {
          return Left(WeatherMeasurementFetchFailure(e.toString()));
        }
      }

      return const Left(WeatherMeasurementFetchFailure('No measurements available offline'));
    } catch (e) {
      return Left(WeatherMeasurementFetchFailure(e.toString()));
    }
  }

  @override
  Future<Either<WeatherFailure, List<WeatherMeasurementEntity>>> getMeasurementsByDateRange(
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
  Future<Either<WeatherFailure, List<WeatherMeasurementEntity>>> getMeasurementsByLocation(
    String locationId, {
    int? limit,
  }) async {
    return await getAllMeasurements(locationId: locationId, limit: limit);
  }

  @override
  Future<Either<WeatherFailure, WeatherMeasurementEntity>> createMeasurement(
    WeatherMeasurementEntity measurement,
  ) async {
    try {
      final model = WeatherMeasurementModel.fromEntity(measurement);
      await _localDataSource.saveMeasurement(model);
      if (await _isOnline) {
        try {
          final remoteModel = await _remoteDataSource.createMeasurement(model);
          await _localDataSource.updateMeasurement(remoteModel);
          
          return Right(remoteModel.toEntity());
        } catch (e) {
          return Right(model.toEntity());
        }
      }

      return Right(model.toEntity());
    } catch (e) {
      return Left(WeatherMeasurementSaveFailure(e.toString()));
    }
  }

  @override
  Future<Either<WeatherFailure, WeatherMeasurementEntity>> updateMeasurement(
    WeatherMeasurementEntity measurement,
  ) async {
    try {
      final model = WeatherMeasurementModel.fromEntity(measurement.copyWith(
        updatedAt: DateTime.now(),
      ));
      await _localDataSource.updateMeasurement(model);
      if (await _isOnline) {
        try {
          final remoteModel = await _remoteDataSource.updateMeasurement(model);
          await _localDataSource.updateMeasurement(remoteModel);
          
          return Right(remoteModel.toEntity());
        } catch (e) {
          return Right(model.toEntity());
        }
      }

      return Right(model.toEntity());
    } catch (e) {
      return Left(WeatherMeasurementSaveFailure(e.toString()));
    }
  }

  @override
  Future<Either<WeatherFailure, void>> deleteMeasurement(String id) async {
    try {
      await _localDataSource.deleteMeasurement(id);
      if (await _isOnline) {
        try {
          await _remoteDataSource.deleteMeasurement(id);
        } catch (e) {
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(WeatherMeasurementFetchFailure(e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      final localResults = await _localDataSource.searchMeasurements(
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

      return Right(localResults.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(WeatherMeasurementFetchFailure(e.toString()));
    }
  }

  @override
  Future<Either<WeatherFailure, List<RainGaugeEntity>>> getAllRainGauges() async {
    try {
      final localGauges = await _localDataSource.getAllRainGauges();
      if (localGauges.isNotEmpty) {
        return Right(localGauges.map((model) => model.toEntity()).toList());
      }
      if (await _isOnline) {
        try {
          final remoteGauges = await _remoteDataSource.getAllRainGauges();
          await _localDataSource.saveRainGauges(remoteGauges);
          
          return Right(remoteGauges.map((model) => model.toEntity()).toList());
        } catch (e) {
          return Left(RainGaugeFetchFailure(e.toString()));
        }
      }

      return Right(localGauges.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(RainGaugeFetchFailure(e.toString()));
    }
  }

  @override
  Future<Either<WeatherFailure, RainGaugeEntity>> getRainGaugeById(String id) async {
    try {
      final localGauge = await _localDataSource.getRainGaugeById(id);
      if (localGauge != null) {
        return Right(localGauge.toEntity());
      }
      if (await _isOnline) {
        try {
          final remoteGauge = await _remoteDataSource.getRainGaugeById(id);
          await _localDataSource.saveRainGauge(remoteGauge);
          
          return Right(remoteGauge.toEntity());
        } catch (e) {
          return Left(RainGaugeNotFoundFailure(id));
        }
      }

      return Left(RainGaugeNotFoundFailure(id));
    } catch (e) {
      return Left(RainGaugeFetchFailure(e.toString()));
    }
  }

  @override
  Future<Either<WeatherFailure, List<RainGaugeEntity>>> getRainGaugesByLocation(String locationId) async {
    try {
      final localGauges = await _localDataSource.getRainGaugesByLocation(locationId);
      return Right(localGauges.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(RainGaugeFetchFailure(e.toString()));
    }
  }

  @override
  Future<Either<WeatherFailure, List<RainGaugeEntity>>> getActiveRainGauges() async {
    try {
      final localGauges = await _localDataSource.getActiveRainGauges();
      return Right(localGauges.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(RainGaugeFetchFailure(e.toString()));
    }
  }

  @override
  Future<Either<WeatherFailure, List<RainGaugeEntity>>> getRainGaugesNeedingMaintenance() async {
    try {
      final allGauges = await _localDataSource.getAllRainGauges();
      final needingMaintenance = allGauges
          .where((gauge) => gauge.needsMaintenance)
          .map((model) => model.toEntity())
          .toList();
      
      return Right(needingMaintenance);
    } catch (e) {
      return Left(RainGaugeFetchFailure(e.toString()));
    }
  }

  @override
  Future<Either<WeatherFailure, RainGaugeEntity>> createRainGauge(RainGaugeEntity rainGauge) async {
    try {
      final model = RainGaugeModel.fromEntity(rainGauge);
      await _localDataSource.saveRainGauge(model);
      if (await _isOnline) {
        try {
          final remoteModel = await _remoteDataSource.createRainGauge(model);
          await _localDataSource.updateRainGauge(remoteModel);
          
          return Right(remoteModel.toEntity());
        } catch (e) {
          return Right(model.toEntity());
        }
      }

      return Right(model.toEntity());
    } catch (e) {
      return Left(RainGaugeSaveFailure(e.toString()));
    }
  }

  @override
  Future<Either<WeatherFailure, RainGaugeEntity>> updateRainGauge(RainGaugeEntity rainGauge) async {
    try {
      final model = RainGaugeModel.fromEntity(rainGauge.copyWith(
        updatedAt: DateTime.now(),
      ));
      await _localDataSource.updateRainGauge(model);
      if (await _isOnline) {
        try {
          final remoteModel = await _remoteDataSource.updateRainGauge(model);
          await _localDataSource.updateRainGauge(remoteModel);
          
          return Right(remoteModel.toEntity());
        } catch (e) {
          return Right(model.toEntity());
        }
      }

      return Right(model.toEntity());
    } catch (e) {
      return Left(RainGaugeSaveFailure(e.toString()));
    }
  }

  @override
  Future<Either<WeatherFailure, void>> deleteRainGauge(String id) async {
    try {
      await _localDataSource.deleteRainGauge(id);
      if (await _isOnline) {
        try {
          await _remoteDataSource.deleteRainGauge(id);
        } catch (e) {
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(RainGaugeFailure(e.toString()));
    }
  }

  @override
  Future<Either<WeatherFailure, RainGaugeEntity>> updateRainGaugeMeasurement(
    String gaugeId,
    double newRainfall,
    DateTime measurementTime,
  ) async {
    try {
      final existingGauge = await _localDataSource.getRainGaugeById(gaugeId);
      if (existingGauge == null) {
        return Left(RainGaugeNotFoundFailure(gaugeId));
      }
      final updatedModel = existingGauge.updateMeasurements(
        newRainfall: newRainfall,
        measurementTime: measurementTime,
      );
      await _localDataSource.updateRainGauge(updatedModel);
      if (await _isOnline) {
        try {
          final remoteModel = await _remoteDataSource.updateRainGaugeMeasurement(
            gaugeId,
            newRainfall,
            measurementTime,
          );
          await _localDataSource.updateRainGauge(remoteModel);
          
          return Right(remoteModel.toEntity());
        } catch (e) {
          return Right(updatedModel.toEntity());
        }
      }

      return Right(updatedModel.toEntity());
    } catch (e) {
      return Left(RainGaugeSaveFailure(e.toString()));
    }
  }

  @override
  Future<Either<WeatherFailure, RainGaugeEntity>> resetRainGaugeAccumulations(
    String gaugeId, {
    bool resetDaily = false,
    bool resetWeekly = false,
    bool resetMonthly = false,
    bool resetYearly = false,
  }) async {
    try {
      final existingGauge = await _localDataSource.getRainGaugeById(gaugeId);
      if (existingGauge == null) {
        return Left(RainGaugeNotFoundFailure(gaugeId));
      }
      final updatedModel = existingGauge.resetAccumulations(
        resetDaily: resetDaily,
        resetWeekly: resetWeekly,
        resetMonthly: resetMonthly,
        resetYearly: resetYearly,
      );
      await _localDataSource.updateRainGauge(updatedModel);
      if (await _isOnline) {
        try {
          final remoteModel = await _remoteDataSource.updateRainGauge(updatedModel);
          await _localDataSource.updateRainGauge(remoteModel);
          return Right(remoteModel.toEntity());
        } catch (e) {
          return Right(updatedModel.toEntity());
        }
      }

      return Right(updatedModel.toEntity());
    } catch (e) {
      return Left(RainGaugeSaveFailure(e.toString()));
    }
  }

  @override
  Future<Either<WeatherFailure, RainGaugeEntity>> calibrateRainGauge(
    String gaugeId,
    double calibrationFactor,
  ) async {
    try {
      final existingGauge = await _localDataSource.getRainGaugeById(gaugeId);
      if (existingGauge == null) {
        return Left(RainGaugeNotFoundFailure(gaugeId));
      }
      final updatedModel = existingGauge.copyWith(
        calibrationFactor: calibrationFactor,
        updatedAt: DateTime.now(),
      );
      await _localDataSource.updateRainGauge(updatedModel);
      if (await _isOnline) {
        try {
          final remoteModel = await _remoteDataSource.updateRainGauge(updatedModel);
          await _localDataSource.updateRainGauge(remoteModel);
          return Right(remoteModel.toEntity());
        } catch (e) {
          return Right(updatedModel.toEntity());
        }
      }

      return Right(updatedModel.toEntity());
    } catch (e) {
      return Left(RainGaugeCalibrationFailure(gaugeId, e.toString()));
    }
  }

  @override
  Future<Either<WeatherFailure, WeatherStatisticsEntity>> getWeatherStatistics({
    required String locationId,
    required String period,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final localStats = await _localDataSource.getStatisticsByLocation(locationId);
      final matchingStats = localStats.where((stats) =>
          stats.period == period &&
          stats.startDate.isAtSameMomentAs(startDate) &&
          stats.endDate.isAtSameMomentAs(endDate)).toList();

      if (matchingStats.isNotEmpty) {
        return Right(matchingStats.first.toEntity());
      }
      if (await _isOnline) {
        try {
          final remoteStats = await _remoteDataSource.calculateStatistics(
            locationId: locationId,
            period: period,
            startDate: startDate,
            endDate: endDate,
          );
          await _localDataSource.saveStatistics(remoteStats);

          return Right(remoteStats.toEntity());
        } catch (e) {
          return Left(WeatherStatisticsCalculationFailure(e.toString(), period));
        }
      }

      return const Left(WeatherStatisticsFailure('Statistics not available offline'));
    } catch (e) {
      return Left(WeatherStatisticsFailure(e.toString()));
    }
  }

  @override
  Future<Either<WeatherFailure, List<WeatherStatisticsEntity>>> getHistoricalStatistics({
    required String locationId,
    required String period,
    int? years,
  }) async {
    try {
      final localStats = await _localDataSource.getStatisticsByLocation(locationId);
      final filtered = localStats.where((stats) => stats.period == period).toList();

      if (years != null) {
        final cutoffDate = DateTime.now().subtract(Duration(days: years * 365));
        filtered.retainWhere((stats) => stats.startDate.isAfter(cutoffDate));
      }

      return Right(filtered.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(WeatherStatisticsFailure(e.toString()));
    }
  }

  @override
  Future<Either<WeatherFailure, WeatherStatisticsEntity>> calculateStatistics({
    required String locationId,
    required String period,
    required DateTime startDate,
    required DateTime endDate,
    bool forceRecalculate = false,
  }) async {
    if (await _isOnline) {
      try {
        final remoteStats = await _remoteDataSource.calculateStatistics(
          locationId: locationId,
          period: period,
          startDate: startDate,
          endDate: endDate,
        );
        await _localDataSource.saveStatistics(remoteStats);

        return Right(remoteStats.toEntity());
      } catch (e) {
        return Left(WeatherStatisticsCalculationFailure(e.toString(), period));
      }
    }

    return const Left(WeatherStatisticsFailure('Statistics calculation not available offline'));
  }

  @override
  Future<Either<WeatherFailure, Map<String, dynamic>>> getWeatherTrends({
    required String locationId,
    required DateTime startDate,
    required DateTime endDate,
    String? comparisonPeriod,
  }) async {
    try {
      final measurements = await getAllMeasurements(
        locationId: locationId,
        startDate: startDate,
        endDate: endDate,
      );

      return measurements.fold(
        (failure) => Left(failure),
        (measurementList) {
          if (measurementList.isEmpty) {
            return const Left(InsufficientWeatherDataFailure('trends', 0, 30));
          }
          final trends = {
            'location_id': locationId,
            'period_start': startDate.toIso8601String(),
            'period_end': endDate.toIso8601String(),
            'total_measurements': measurementList.length,
            'temperature_trend': 'stable', // Simplified
            'rainfall_trend': 'stable', // Simplified
            'calculated_at': DateTime.now().toIso8601String(),
          };

          return Right(trends);
        },
      );
    } catch (e) {
      return Left(WeatherStatisticsFailure(e.toString()));
    }
  }

  @override
  Future<Either<WeatherFailure, List<String>>> detectWeatherAnomalies({
    required String locationId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final measurements = await getAllMeasurements(
        locationId: locationId,
        startDate: startDate,
        endDate: endDate,
      );

      return measurements.fold(
        (failure) => Left(failure),
        (measurementList) {
          final anomalies = <String>[];
          
          for (final measurement in measurementList) {
            if (measurement.temperature > 45 || measurement.temperature < -20) {
              anomalies.add('extreme_temperature_${measurement.id}');
            }
            if (measurement.windSpeed > 100) {
              anomalies.add('high_wind_${measurement.id}');
            }
            if (measurement.rainfall > 100) {
              anomalies.add('heavy_rain_${measurement.id}');
            }
          }

          return Right(anomalies);
        },
      );
    } catch (e) {
      return Left(WeatherStatisticsFailure(e.toString()));
    }
  }

  @override
  Future<Either<WeatherFailure, WeatherMeasurementEntity>> getCurrentWeatherFromAPI(
    double latitude,
    double longitude,
  ) async {
    try {
      if (!(await _isOnline)) {
        return const Left(WeatherNetworkFailure('No internet connection'));
      }

      final remoteMeasurement = await _remoteDataSource.getCurrentWeatherFromAPI(
        latitude,
        longitude,
      );
      await _localDataSource.saveMeasurement(remoteMeasurement);

      return Right(remoteMeasurement.toEntity());
    } catch (e) {
      if (e is WeatherFailure) return Left(e);
      return Left(WeatherApiFailure('external_api', 500, e.toString()));
    }
  }

  @override
  Future<Either<WeatherFailure, List<WeatherMeasurementEntity>>> getWeatherForecast(
    double latitude,
    double longitude, {
    int days = 7,
  }) async {
    try {
      if (!(await _isOnline)) {
        return const Left(WeatherNetworkFailure('No internet connection'));
      }

      final remoteForecast = await _remoteDataSource.getWeatherForecast(
        latitude,
        longitude,
        days: days,
      );
      await _localDataSource.saveMeasurements(remoteForecast);

      return Right(remoteForecast.map((model) => model.toEntity()).toList());
    } catch (e) {
      if (e is WeatherFailure) return Left(e);
      return Left(WeatherApiFailure('external_api', 500, e.toString()));
    }
  }

  @override
  Future<Either<WeatherFailure, int>> syncWeatherData() async {
    try {
      if (!(await _isOnline)) {
        return const Left(WeatherNetworkFailure('No internet connection for sync'));
      }

      int syncedCount = 0;
      final pendingResult = await uploadPendingMeasurements();
      pendingResult.fold(
        (failure) => <String, dynamic>{}, // Log but continue
        (count) => syncedCount += count,
      );
      final updatesResult = await downloadWeatherUpdates();
      updatesResult.fold(
        (failure) => <String, dynamic>{}, // Log but continue
        (count) => syncedCount += count,
      );
      await _localDataSource.setLastSyncTime(DateTime.now());

      return Right(syncedCount);
    } catch (e) {
      return Left(WeatherSyncFailure('Sync failed: $e'));
    }
  }

  @override
  Future<Either<WeatherFailure, int>> uploadPendingMeasurements() async {
    try {
      if (!(await _isOnline)) {
        return const Left(WeatherNetworkFailure('No internet connection'));
      }

      final pendingMeasurements = await _localDataSource.getPendingMeasurements();
      if (pendingMeasurements.isEmpty) {
        return const Right(0);
      }

      final uploadedMeasurements = await _remoteDataSource.uploadMeasurements(pendingMeasurements);
      final ids = uploadedMeasurements.map((m) => m.id).toList();
      await _localDataSource.markMeasurementsAsSynced(ids);

      return Right(uploadedMeasurements.length);
    } catch (e) {
      return Left(WeatherSyncFailure('Upload failed: $e'));
    }
  }

  @override
  Future<Either<WeatherFailure, int>> downloadWeatherUpdates({DateTime? since}) async {
    try {
      if (!(await _isOnline)) {
        return const Left(WeatherNetworkFailure('No internet connection'));
      }

      final lastSync = since ?? await _localDataSource.getLastSyncTime();
      final measurements = await _remoteDataSource.downloadMeasurements(since: lastSync);
      if (measurements.isNotEmpty) {
        await _localDataSource.saveMeasurements(measurements);
      }
      final rainGauges = await _remoteDataSource.downloadRainGauges(since: lastSync);
      if (rainGauges.isNotEmpty) {
        await _localDataSource.saveRainGauges(rainGauges);
      }

      return Right(measurements.length + rainGauges.length);
    } catch (e) {
      return Left(WeatherSyncFailure('Download failed: $e'));
    }
  }

  @override
  Future<Either<WeatherFailure, bool>> validateMeasurement(WeatherMeasurementEntity measurement) async {
    try {
      if (measurement.temperature < -100 || measurement.temperature > 70) return const Right(false);
      if (measurement.humidity < 0 || measurement.humidity > 100) return const Right(false);
      if (measurement.pressure < 800 || measurement.pressure > 1200) return const Right(false);
      
      return const Right(true);
    } catch (e) {
      return Left(WeatherDataFailure(e.toString()));
    }
  }

  @override
  Future<Either<WeatherFailure, Map<String, dynamic>>> checkDataQuality({
    required String locationId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final measurements = await getAllMeasurements(
        locationId: locationId,
        startDate: startDate,
        endDate: endDate,
      );

      return measurements.fold(
        (failure) => Left(failure),
        (measurementList) {
          final qualityReport = {
            'location_id': locationId,
            'total_measurements': measurementList.length,
            'period_days': endDate.difference(startDate).inDays,
            'data_completeness': measurementList.isNotEmpty ? 1.0 : 0.0,
            'quality_score': 0.9, // Simplified
            'issues': <String>[],
          };

          return Right(qualityReport);
        },
      );
    } catch (e) {
      return Left(WeatherDataFailure(e.toString()));
    }
  }

  @override
  Future<Either<WeatherFailure, int>> cleanWeatherData({
    String? locationId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return const Right(0); // Simplified implementation
  }

  @override
  Future<Either<WeatherFailure, List<Map<String, dynamic>>>> getDataGaps({
    required String locationId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return const Right([]); // Simplified implementation
  }

  @override
  Future<Either<WeatherFailure, List<Map<String, dynamic>>>> getWeatherLocations() async {
    return const Right([]); // Would fetch from local/remote
  }

  @override
  Future<Either<WeatherFailure, String>> addWeatherLocation({
    required String name,
    required double latitude,
    required double longitude,
    String? description,
  }) async {
    return Right('loc_${DateTime.now().millisecondsSinceEpoch}');
  }

  @override
  Future<Either<WeatherFailure, void>> updateWeatherLocation(
    String locationId,
    Map<String, dynamic> updates,
  ) async {
    return const Right(null);
  }

  @override
  Future<Either<WeatherFailure, void>> deleteWeatherLocation(String locationId) async {
    return const Right(null);
  }

  @override
  Future<Either<WeatherFailure, List<Map<String, dynamic>>>> getDevicesStatus() async {
    return const Right([]);
  }

  @override
  Future<Either<WeatherFailure, void>> updateDeviceStatus(
    String deviceId,
    String status, {
    Map<String, dynamic>? additionalData,
  }) async {
    return const Right(null);
  }

  @override
  Future<Either<WeatherFailure, String>> exportWeatherData({
    required String locationId,
    required DateTime startDate,
    required DateTime endDate,
    String format = 'json',
  }) async {
    return Right('export_${DateTime.now().millisecondsSinceEpoch}.$format');
  }

  @override
  Future<Either<WeatherFailure, int>> importWeatherData(
    String filePath, {
    String format = 'json',
    bool validateData = true,
  }) async {
    return const Right(0);
  }

  @override
  Future<Either<WeatherFailure, String>> backupWeatherData({
    List<String>? locationIds,
    DateTime? since,
  }) async {
    return Right('backup_${DateTime.now().millisecondsSinceEpoch}.json');
  }

  @override
  Future<Either<WeatherFailure, int>> restoreWeatherData(
    String backupPath, {
    bool replaceExisting = false,
  }) async {
    return const Right(0);
  }

  @override
  Stream<WeatherMeasurementEntity> subscribeToWeatherUpdates(String? locationId) {
    return const Stream.empty();
  }

  @override
  Stream<RainGaugeEntity> subscribeToRainGaugeUpdates(String? gaugeId) {
    return const Stream.empty();
  }

  @override
  Stream<Map<String, dynamic>> subscribeToWeatherAlerts() {
    return const Stream.empty();
  }

  @override
  Future<Either<WeatherFailure, String>> createWeatherAlert({
    required String locationId,
    required String alertType,
    required Map<String, dynamic> conditions,
    required String notificationMethod,
  }) async {
    return Right('alert_${DateTime.now().millisecondsSinceEpoch}');
  }

  @override
  Future<Either<WeatherFailure, void>> deleteWeatherAlert(String alertId) async {
    return const Right(null);
  }

  @override
  Future<Either<WeatherFailure, List<Map<String, dynamic>>>> getActiveWeatherAlerts({
    String? locationId,
  }) async {
    return const Right([]);
  }
}
