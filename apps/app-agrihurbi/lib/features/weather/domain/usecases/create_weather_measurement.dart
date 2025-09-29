import 'package:dartz/dartz.dart';

import '../entities/weather_measurement_entity.dart';
import '../failures/weather_failures.dart';
import '../repositories/weather_repository.dart';

/// Use case for creating weather measurements
/// Validates data and ensures data integrity before saving
class CreateWeatherMeasurement {
  final WeatherRepository _repository;

  const CreateWeatherMeasurement(_repository);

  /// Create a new weather measurement
  Future<Either<WeatherFailure, WeatherMeasurementEntity>> call(
    WeatherMeasurementEntity measurement,
  ) async {
    try {
      // Validate the measurement data
      final validationResult = _validateMeasurement(measurement);
      if (validationResult.isLeft()) {
        return validationResult.fold(
          (failure) => Left(failure),
          (_) => throw Exception('Unexpected validation success'),
        );
      }

      // Check for duplicate measurements in same location and time
      final duplicateCheck = await _checkForDuplicates(measurement);
      if (duplicateCheck.isLeft()) {
        return duplicateCheck.fold(
          (failure) => Left(failure),
          (_) => throw Exception('Unexpected duplicate check success'),
        );
      }

      // Set creation metadata
      final now = DateTime.now();
      final measurementWithMetadata = measurement.copyWith(
        id: measurement.id.isEmpty ? _generateMeasurementId() : measurement.id,
        createdAt: now,
        updatedAt: now,
      );

      return await _repository.createMeasurement(measurementWithMetadata);
    } catch (e) {
      return Left(WeatherMeasurementSaveFailure(e.toString()));
    }
  }

  /// Create weather measurement from manual input
  Future<Either<WeatherFailure, WeatherMeasurementEntity>> fromManualInput({
    required String locationId,
    required String locationName,
    required DateTime timestamp,
    required double temperature,
    required double humidity,
    required double pressure,
    required double windSpeed,
    required double windDirection,
    required double rainfall,
    double uvIndex = 0.0,
    double visibility = 10.0,
    String weatherCondition = 'unknown',
    String description = '',
    required double latitude,
    required double longitude,
    String? notes,
  }) async {
    try {
      final measurement = WeatherMeasurementEntity(
        id: _generateMeasurementId(),
        locationId: locationId,
        locationName: locationName,
        timestamp: timestamp,
        temperature: temperature,
        humidity: humidity,
        pressure: pressure,
        windSpeed: windSpeed,
        windDirection: windDirection,
        rainfall: rainfall,
        uvIndex: uvIndex,
        visibility: visibility,
        weatherCondition: weatherCondition,
        description: description.isNotEmpty ? description : _generateDescription(weatherCondition, temperature),
        latitude: latitude,
        longitude: longitude,
        source: 'manual',
        qualityScore: 0.9, // Manual input generally has high quality
        isRealTime: false,
        notes: notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return await call(measurement);
    } catch (e) {
      return Left(WeatherMeasurementSaveFailure(e.toString()));
    }
  }

  /// Create weather measurement from sensor data
  Future<Either<WeatherFailure, WeatherMeasurementEntity>> fromSensorData({
    required String deviceId,
    required String locationId,
    required String locationName,
    required Map<String, dynamic> sensorData,
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Parse sensor data
      final parsedData = _parseSensorData(sensorData);
      if (parsedData == null) {
        return Left(InvalidWeatherMeasurementFailure(
          'Invalid sensor data format',
          ['Unable to parse sensor data: $sensorData'],
        ));
      }

      final measurement = WeatherMeasurementEntity(
        id: _generateMeasurementId(),
        locationId: locationId,
        locationName: locationName,
        timestamp: (parsedData['timestamp'] as DateTime?) ?? DateTime.now(),
        temperature: (parsedData['temperature'] as double?) ?? 0.0,
        humidity: (parsedData['humidity'] as double?) ?? 0.0,
        pressure: (parsedData['pressure'] as double?) ?? 1013.25,
        windSpeed: (parsedData['windSpeed'] as double?) ?? 0.0,
        windDirection: (parsedData['windDirection'] as double?) ?? 0.0,
        rainfall: (parsedData['rainfall'] as double?) ?? 0.0,
        uvIndex: (parsedData['uvIndex'] as double?) ?? 0.0,
        visibility: (parsedData['visibility'] as double?) ?? 10.0,
        weatherCondition: (parsedData['weatherCondition'] as String?) ?? 'unknown',
        description: (parsedData['description'] as String?) ?? 'Sensor measurement',
        latitude: latitude,
        longitude: longitude,
        source: 'sensor_$deviceId',
        qualityScore: _calculateSensorQualityScore(sensorData),
        isRealTime: true,
        notes: 'Device: $deviceId',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return await call(measurement);
    } catch (e) {
      return Left(WeatherMeasurementSaveFailure(e.toString()));
    }
  }

  /// Create weather measurement from API data
  Future<Either<WeatherFailure, WeatherMeasurementEntity>> fromApiData({
    required String locationId,
    required String locationName,
    required Map<String, dynamic> apiData,
    required double latitude,
    required double longitude,
    required String apiSource,
  }) async {
    try {
      // Parse API data based on source
      final parsedData = _parseApiData(apiData, apiSource);
      if (parsedData == null) {
        return Left(InvalidWeatherMeasurementFailure(
          'Invalid API data format',
          ['Unable to parse API data from $apiSource'],
        ));
      }

      final measurement = WeatherMeasurementEntity(
        id: _generateMeasurementId(),
        locationId: locationId,
        locationName: locationName,
        timestamp: (parsedData['timestamp'] as DateTime?) ?? DateTime.now(),
        temperature: (parsedData['temperature'] as double?) ?? 0.0,
        humidity: (parsedData['humidity'] as double?) ?? 0.0,
        pressure: (parsedData['pressure'] as double?) ?? 1013.25,
        windSpeed: (parsedData['windSpeed'] as double?) ?? 0.0,
        windDirection: (parsedData['windDirection'] as double?) ?? 0.0,
        rainfall: (parsedData['rainfall'] as double?) ?? 0.0,
        uvIndex: (parsedData['uvIndex'] as double?) ?? 0.0,
        visibility: (parsedData['visibility'] as double?) ?? 10.0,
        weatherCondition: (parsedData['weatherCondition'] as String?) ?? 'unknown',
        description: (parsedData['description'] as String?) ?? 'API measurement',
        latitude: latitude,
        longitude: longitude,
        source: 'api_$apiSource',
        qualityScore: 0.95, // API data generally has high quality
        isRealTime: true,
        notes: 'Source: $apiSource',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return await call(measurement);
    } catch (e) {
      return Left(WeatherMeasurementSaveFailure(e.toString()));
    }
  }

  /// Batch create multiple weather measurements
  Future<Either<WeatherFailure, List<WeatherMeasurementEntity>>> batch(
    List<WeatherMeasurementEntity> measurements,
  ) async {
    try {
      final List<WeatherMeasurementEntity> createdMeasurements = [];
      final List<String> errors = [];

      for (final measurement in measurements) {
        final result = await call(measurement);
        result.fold(
          (failure) => errors.add(failure.toString()),
          (created) => createdMeasurements.add(created),
        );
      }

      if (errors.isNotEmpty && createdMeasurements.isEmpty) {
        return Left(WeatherMeasurementSaveFailure(
          'Failed to create any measurements: ${errors.join(', ')}'
        ));
      }

      if (errors.isNotEmpty) {
        // Partial success - some measurements failed
        return Left(WeatherMeasurementSaveFailure(
          'Some measurements failed to save: ${errors.length} failures out of ${measurements.length} total'
        ));
      }

      return Right(createdMeasurements);
    } catch (e) {
      return Left(WeatherMeasurementSaveFailure(e.toString()));
    }
  }

  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================

  /// Validate weather measurement data
  Either<WeatherFailure, void> _validateMeasurement(WeatherMeasurementEntity measurement) {
    final List<String> errors = [];

    // Required fields validation
    if (measurement.locationId.trim().isEmpty) {
      errors.add('Location ID is required');
    }

    if (measurement.locationName.trim().isEmpty) {
      errors.add('Location name is required');
    }

    // Temperature validation
    if (measurement.temperature < -100 || measurement.temperature > 70) {
      errors.add('Temperature must be between -100°C and 70°C');
    }

    // Humidity validation
    if (measurement.humidity < 0 || measurement.humidity > 100) {
      errors.add('Humidity must be between 0% and 100%');
    }

    // Pressure validation (typical range: 950-1050 hPa)
    if (measurement.pressure < 800 || measurement.pressure > 1200) {
      errors.add('Atmospheric pressure must be between 800 hPa and 1200 hPa');
    }

    // Wind speed validation
    if (measurement.windSpeed < 0 || measurement.windSpeed > 300) {
      errors.add('Wind speed must be between 0 km/h and 300 km/h');
    }

    // Wind direction validation
    if (measurement.windDirection < 0 || measurement.windDirection >= 360) {
      errors.add('Wind direction must be between 0° and 359°');
    }

    // Rainfall validation
    if (measurement.rainfall < 0 || measurement.rainfall > 500) {
      errors.add('Rainfall must be between 0 mm and 500 mm');
    }

    // UV index validation
    if (measurement.uvIndex < 0 || measurement.uvIndex > 15) {
      errors.add('UV index must be between 0 and 15');
    }

    // Visibility validation
    if (measurement.visibility < 0 || measurement.visibility > 50) {
      errors.add('Visibility must be between 0 km and 50 km');
    }

    // Coordinates validation
    if (measurement.latitude < -90 || measurement.latitude > 90) {
      errors.add('Latitude must be between -90° and 90°');
    }

    if (measurement.longitude < -180 || measurement.longitude > 180) {
      errors.add('Longitude must be between -180° and 180°');
    }

    // Quality score validation
    if (measurement.qualityScore < 0 || measurement.qualityScore > 1) {
      errors.add('Quality score must be between 0.0 and 1.0');
    }

    if (errors.isNotEmpty) {
      return Left(InvalidWeatherMeasurementFailure(
        'Weather measurement validation failed',
        errors,
      ));
    }

    return const Right(null);
  }

  /// Check for duplicate measurements
  Future<Either<WeatherFailure, void>> _checkForDuplicates(
    WeatherMeasurementEntity measurement,
  ) async {
    try {
      // Check for measurements at same location within 1 hour
      final startTime = measurement.timestamp.subtract(const Duration(hours: 1));
      final endTime = measurement.timestamp.add(const Duration(hours: 1));

      final existingResult = await _repository.getMeasurementsByDateRange(
        startTime,
        endTime,
        locationId: measurement.locationId,
      );

      return existingResult.fold(
        (failure) => Left(failure),
        (existing) {
          final duplicates = existing.where((existing) {
            final timeDiff = existing.timestamp.difference(measurement.timestamp).abs();
            return timeDiff.inMinutes < 30; // Allow duplicates if more than 30 minutes apart
          }).toList();

          if (duplicates.isNotEmpty) {
            return const Left(WeatherMeasurementSaveFailure(
              'Duplicate measurement found within 30 minutes at same location'
            ));
          }

          return const Right(null);
        },
      );
    } catch (e) {
      // If duplicate check fails, allow creation but log the error
      return const Right(null);
    }
  }

  /// Generate unique measurement ID
  String _generateMeasurementId() {
    return 'weather_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  /// Generate description based on weather condition and temperature
  String _generateDescription(String condition, double temperature) {
    final tempDesc = temperature < 0 ? 'muito frio' : 
                    temperature < 10 ? 'frio' :
                    temperature < 25 ? 'ameno' :
                    temperature < 35 ? 'quente' : 'muito quente';

    return '${condition.replaceAll('_', ' ')} e $tempDesc';
  }

  /// Parse sensor data into standardized format
  Map<String, dynamic>? _parseSensorData(Map<String, dynamic> sensorData) {
    try {
      return {
        'timestamp': sensorData['timestamp'] != null
            ? DateTime.parse(sensorData['timestamp'].toString())
            : DateTime.now(),
        'temperature': double.tryParse(sensorData['temperature']?.toString() ?? '0') ?? 0.0,
        'humidity': double.tryParse(sensorData['humidity']?.toString() ?? '0') ?? 0.0,
        'pressure': double.tryParse(sensorData['pressure']?.toString() ?? '1013.25') ?? 1013.25,
        'windSpeed': double.tryParse(sensorData['wind_speed']?.toString() ?? '0') ?? 0.0,
        'windDirection': double.tryParse(sensorData['wind_direction']?.toString() ?? '0') ?? 0.0,
        'rainfall': double.tryParse(sensorData['rainfall']?.toString() ?? '0') ?? 0.0,
        'uvIndex': double.tryParse(sensorData['uv_index']?.toString() ?? '0') ?? 0.0,
        'visibility': double.tryParse(sensorData['visibility']?.toString() ?? '10') ?? 10.0,
        'weatherCondition': sensorData['condition']?.toString() ?? 'unknown',
        'description': sensorData['description']?.toString() ?? 'Sensor measurement',
      };
    } catch (e) {
      return null;
    }
  }

  /// Parse API data based on source
  Map<String, dynamic>? _parseApiData(Map<String, dynamic> apiData, String source) {
    try {
      // This would be implemented based on specific API formats
      // For now, return a generic parser
      return {
        'timestamp': apiData['timestamp'] != null
            ? DateTime.parse(apiData['timestamp'].toString())
            : DateTime.now(),
        'temperature': double.tryParse(apiData['temp']?.toString() ?? '0') ?? 0.0,
        'humidity': double.tryParse(apiData['humidity']?.toString() ?? '0') ?? 0.0,
        'pressure': double.tryParse(apiData['pressure']?.toString() ?? '1013.25') ?? 1013.25,
        'windSpeed': double.tryParse(apiData['wind_speed']?.toString() ?? '0') ?? 0.0,
        'windDirection': double.tryParse(apiData['wind_dir']?.toString() ?? '0') ?? 0.0,
        'rainfall': double.tryParse(apiData['rain']?.toString() ?? '0') ?? 0.0,
        'uvIndex': double.tryParse(apiData['uv']?.toString() ?? '0') ?? 0.0,
        'visibility': double.tryParse(apiData['vis']?.toString() ?? '10') ?? 10.0,
        'weatherCondition': apiData['condition']?.toString() ?? 'unknown',
        'description': apiData['description']?.toString() ?? 'API measurement',
      };
    } catch (e) {
      return null;
    }
  }

  /// Calculate quality score for sensor data
  double _calculateSensorQualityScore(Map<String, dynamic> sensorData) {
    double score = 1.0;

    // Reduce score for missing data
    final requiredFields = ['temperature', 'humidity', 'pressure'];
    for (final field in requiredFields) {
      if (sensorData[field] == null) {
        score -= 0.1;
      }
    }

    // Reduce score for out-of-range values
    final temp = double.tryParse(sensorData['temperature']?.toString() ?? '0') ?? 0;
    if (temp < -50 || temp > 60) score -= 0.2;

    final humidity = double.tryParse(sensorData['humidity']?.toString() ?? '0') ?? 0;
    if (humidity < 0 || humidity > 100) score -= 0.2;

    return score.clamp(0.0, 1.0);
  }
}