import 'package:core/core.dart' show Provider;
import 'package:flutter/foundation.dart';

import 'package:core/core.dart';
import '../../domain/entities/rain_gauge_entity.dart';
import '../../domain/entities/weather_measurement_entity.dart';
import '../../domain/entities/weather_statistics_entity.dart';
import '../../domain/failures/weather_failures.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../domain/usecases/calculate_weather_statistics.dart';
import '../../domain/usecases/create_weather_measurement.dart';
import '../../domain/usecases/get_rain_gauges.dart';
import '../../domain/usecases/get_weather_measurements.dart';

/// Provider Riverpod para WeatherProvider
///
/// Integra GetIt com Riverpod para gerenciamento de estado
final weatherProviderProvider = Provider<WeatherProvider>((ref) {
  return getIt<WeatherProvider>();
});

/// Weather provider using ChangeNotifier for state management
/// Follows Provider pattern similar to existing app architecture
class WeatherProvider with ChangeNotifier {
  final GetWeatherMeasurements _getWeatherMeasurements;
  final CreateWeatherMeasurement _createWeatherMeasurement;
  final GetRainGauges _getRainGauges;
  final CalculateWeatherStatistics _calculateWeatherStatistics;
  final WeatherRepository _weatherRepository;

  WeatherProvider({
    required GetWeatherMeasurements getWeatherMeasurements,
    required CreateWeatherMeasurement createWeatherMeasurement,
    required GetRainGauges getRainGauges,
    required CalculateWeatherStatistics calculateWeatherStatistics,
    required WeatherRepository weatherRepository,
  }) : _getWeatherMeasurements = getWeatherMeasurements,
       _createWeatherMeasurement = createWeatherMeasurement,
       _getRainGauges = getRainGauges,
       _calculateWeatherStatistics = calculateWeatherStatistics,
       _weatherRepository = weatherRepository;
  bool _isLoading = false;
  bool _isMeasurementsLoading = false;
  bool _isRainGaugesLoading = false;
  bool _isStatisticsLoading = false;
  bool _isSyncing = false;
  List<WeatherMeasurementEntity> _measurements = [];
  List<RainGaugeEntity> _rainGauges = [];
  final List<WeatherStatisticsEntity> _statistics = [];
  WeatherMeasurementEntity? _currentWeather;
  WeatherMeasurementEntity? _latestMeasurement;
  String? _selectedLocationId;
  String _selectedPeriod = 'daily';
  DateTime? _startDate;
  DateTime? _endDate;
  int _measurementsLimit = 50;
  WeatherFailure? _lastError;
  String? _errorMessage;
  bool _hasMoreMeasurements = true;
  int _currentPage = 0;
  bool get isLoading => _isLoading;
  bool get isMeasurementsLoading => _isMeasurementsLoading;
  bool get isRainGaugesLoading => _isRainGaugesLoading;
  bool get isStatisticsLoading => _isStatisticsLoading;
  bool get isSyncing => _isSyncing;
  List<WeatherMeasurementEntity> get measurements =>
      List.unmodifiable(_measurements);
  List<RainGaugeEntity> get rainGauges => List.unmodifiable(_rainGauges);
  List<WeatherStatisticsEntity> get statistics =>
      List.unmodifiable(_statistics);
  WeatherMeasurementEntity? get currentWeather => _currentWeather;
  WeatherMeasurementEntity? get latestMeasurement => _latestMeasurement;
  String? get selectedLocationId => _selectedLocationId;
  String get selectedPeriod => _selectedPeriod;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  int get measurementsLimit => _measurementsLimit;
  WeatherFailure? get lastError => _lastError;
  String? get errorMessage => _errorMessage;
  bool get hasError => _lastError != null;
  bool get hasMeasurements => _measurements.isNotEmpty;
  bool get hasRainGauges => _rainGauges.isNotEmpty;
  bool get hasStatistics => _statistics.isNotEmpty;
  bool get hasMoreMeasurements => _hasMoreMeasurements;
  int get currentPage => _currentPage;
  List<RainGaugeEntity> get activeRainGauges =>
      _rainGauges.where((gauge) => gauge.isActive).toList();

  List<RainGaugeEntity> get operationalRainGauges =>
      _rainGauges.where((gauge) => gauge.isOperational).toList();

  List<RainGaugeEntity> get rainGaugesNeedingMaintenance =>
      _rainGauges.where((gauge) => gauge.needsMaintenance).toList();
  Map<String, dynamic> get weatherSummary {
    if (_latestMeasurement == null) return {};

    return {
      'temperature': _latestMeasurement!.temperature,
      'humidity': _latestMeasurement!.humidity,
      'pressure': _latestMeasurement!.pressure,
      'condition': _latestMeasurement!.weatherCondition,
      'description': _latestMeasurement!.description,
      'timestamp': _latestMeasurement!.timestamp,
      'location': _latestMeasurement!.locationName,
    };
  }

  /// Initialize weather provider with default data
  Future<void> initialize({String? locationId}) async {
    _setLoading(true);
    _clearError();

    try {
      if (locationId != null) {
        _selectedLocationId = locationId;
      }
      await Future.wait([
        loadMeasurements(),
        loadRainGauges(),
        loadLatestMeasurement(),
      ]);

      if (_measurements.isNotEmpty) {
        await loadStatistics();
      }
    } catch (e) {
      _setError(
        WeatherDataFailure('Failed to initialize weather provider: $e'),
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Load weather measurements with current filters
  Future<void> loadMeasurements({bool refresh = false}) async {
    if (refresh) {
      _measurements.clear();
      _currentPage = 0;
      _hasMoreMeasurements = true;
    }

    _setMeasurementsLoading(true);
    _clearError();

    try {
      final result = await _getWeatherMeasurements(
        locationId: _selectedLocationId,
        startDate: _startDate,
        endDate: _endDate,
        limit: _measurementsLimit,
      );

      result.fold((failure) => _setError(failure), (newMeasurements) {
        if (refresh) {
          _measurements = newMeasurements;
        } else {
          _measurements.addAll(newMeasurements);
        }

        _hasMoreMeasurements = newMeasurements.length == _measurementsLimit;
        notifyListeners();
      });
    } catch (e) {
      _setError(WeatherMeasurementFetchFailure(e.toString()));
    } finally {
      _setMeasurementsLoading(false);
    }
  }

  /// Load more measurements (pagination)
  Future<void> loadMoreMeasurements() async {
    if (!_hasMoreMeasurements || _isMeasurementsLoading) return;

    _currentPage++;
    await loadMeasurements();
  }

  /// Get latest weather measurement
  Future<void> loadLatestMeasurement() async {
    try {
      final result = await _getWeatherMeasurements.latest(_selectedLocationId);

      result.fold((failure) => _setError(failure), (measurement) {
        _latestMeasurement = measurement;
        notifyListeners();
      });
    } catch (e) {
      _setError(WeatherMeasurementFetchFailure(e.toString()));
    }
  }

  /// Search measurements with filters
  Future<void> searchMeasurements({
    String? locationId,
    DateTime? fromDate,
    DateTime? toDate,
    double? minTemperature,
    double? maxTemperature,
    String? weatherCondition,
    double? minRainfall,
    double? maxRainfall,
  }) async {
    _setMeasurementsLoading(true);
    _clearError();

    try {
      final result = await _getWeatherMeasurements.search(
        locationId: locationId,
        fromDate: fromDate,
        toDate: toDate,
        minTemperature: minTemperature,
        maxTemperature: maxTemperature,
        weatherCondition: weatherCondition,
        minRainfall: minRainfall,
        maxRainfall: maxRainfall,
        limit: _measurementsLimit,
      );

      result.fold((failure) => _setError(failure), (measurements) {
        _measurements = measurements;
        notifyListeners();
      });
    } catch (e) {
      _setError(WeatherMeasurementFetchFailure(e.toString()));
    } finally {
      _setMeasurementsLoading(false);
    }
  }

  /// Create new weather measurement
  Future<bool> createMeasurement(WeatherMeasurementEntity measurement) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _createWeatherMeasurement(measurement);

      return result.fold(
        (failure) {
          _setError(failure);
          return false;
        },
        (createdMeasurement) {
          _measurements.insert(0, createdMeasurement);
          _latestMeasurement = createdMeasurement;
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _setError(WeatherMeasurementSaveFailure(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Create measurement from manual input
  Future<bool> createManualMeasurement({
    required String locationId,
    required String locationName,
    required double temperature,
    required double humidity,
    required double pressure,
    required double windSpeed,
    required double windDirection,
    required double rainfall,
    required double latitude,
    required double longitude,
    double uvIndex = 0.0,
    double visibility = 10.0,
    String weatherCondition = 'unknown',
    String? notes,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _createWeatherMeasurement.fromManualInput(
        locationId: locationId,
        locationName: locationName,
        timestamp: DateTime.now(),
        temperature: temperature,
        humidity: humidity,
        pressure: pressure,
        windSpeed: windSpeed,
        windDirection: windDirection,
        rainfall: rainfall,
        uvIndex: uvIndex,
        visibility: visibility,
        weatherCondition: weatherCondition,
        latitude: latitude,
        longitude: longitude,
        notes: notes,
      );

      return result.fold(
        (failure) {
          _setError(failure);
          return false;
        },
        (measurement) {
          _measurements.insert(0, measurement);
          _latestMeasurement = measurement;
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _setError(WeatherMeasurementSaveFailure(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get current weather from external API
  Future<void> getCurrentWeatherFromAPI(
    double latitude,
    double longitude,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _weatherRepository.getCurrentWeatherFromAPI(
        latitude,
        longitude,
      );

      result.fold((failure) => _setError(failure), (measurement) {
        _currentWeather = measurement;
        _latestMeasurement = measurement;
        final existingIndex = _measurements.indexWhere(
          (m) => m.id == measurement.id,
        );
        if (existingIndex == -1) {
          _measurements.insert(0, measurement);
        }

        notifyListeners();
      });
    } catch (e) {
      _setError(WeatherApiFailure('external_api', 500, e.toString()));
    } finally {
      _setLoading(false);
    }
  }

  /// Get weather forecast
  Future<void> getWeatherForecast(
    double latitude,
    double longitude, {
    int days = 7,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _weatherRepository.getWeatherForecast(
        latitude,
        longitude,
        days: days,
      );

      result.fold((failure) => _setError(failure), (forecastMeasurements) {
        for (final measurement in forecastMeasurements) {
          final existingIndex = _measurements.indexWhere(
            (m) => m.id == measurement.id,
          );
          if (existingIndex == -1) {
            _measurements.add(measurement);
          }
        }
        _measurements.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        notifyListeners();
      });
    } catch (e) {
      _setError(WeatherApiFailure('external_api', 500, e.toString()));
    } finally {
      _setLoading(false);
    }
  }

  /// Load rain gauges
  Future<void> loadRainGauges({bool refresh = false}) async {
    _setRainGaugesLoading(true);
    _clearError();

    try {
      final result = await _getRainGauges();

      result.fold((failure) => _setError(failure), (rainGauges) {
        _rainGauges = rainGauges;
        notifyListeners();
      });
    } catch (e) {
      _setError(RainGaugeFetchFailure(e.toString()));
    } finally {
      _setRainGaugesLoading(false);
    }
  }

  /// Get rain gauges by location
  Future<void> loadRainGaugesByLocation(String locationId) async {
    _setRainGaugesLoading(true);
    _clearError();

    try {
      final result = await _getRainGauges.byLocation(locationId);

      result.fold((failure) => _setError(failure), (rainGauges) {
        _rainGauges = rainGauges;
        notifyListeners();
      });
    } catch (e) {
      _setError(RainGaugeFetchFailure(e.toString()));
    } finally {
      _setRainGaugesLoading(false);
    }
  }

  /// Get rain gauges health report
  Future<Map<String, dynamic>?> getRainGaugesHealthReport() async {
    try {
      final result = await _getRainGauges.getHealthReport();

      return result.fold((failure) {
        _setError(failure);
        return null;
      }, (report) => report);
    } catch (e) {
      _setError(RainGaugeFetchFailure(e.toString()));
      return null;
    }
  }

  /// Load weather statistics
  Future<void> loadStatistics({
    String? locationId,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _setStatisticsLoading(true);
    _clearError();

    try {
      final result = await _calculateWeatherStatistics(
        locationId: locationId ?? _selectedLocationId ?? 'default',
        period: period ?? _selectedPeriod,
        startDate:
            startDate ??
            _startDate ??
            DateTime.now().subtract(const Duration(days: 30)),
        endDate: endDate ?? _endDate ?? DateTime.now(),
      );

      result.fold((failure) => _setError(failure), (statistics) {
        final existingIndex = _statistics.indexWhere(
          (s) => s.id == statistics.id,
        );
        if (existingIndex != -1) {
          _statistics[existingIndex] = statistics;
        } else {
          _statistics.add(statistics);
        }
        notifyListeners();
      });
    } catch (e) {
      _setError(
        WeatherStatisticsCalculationFailure(
          e.toString(),
          period ?? _selectedPeriod,
        ),
      );
    } finally {
      _setStatisticsLoading(false);
    }
  }

  /// Calculate daily statistics
  Future<void> calculateDailyStatistics({
    required String locationId,
    DateTime? date,
  }) async {
    final targetDate = date ?? DateTime.now();

    try {
      final result = await _calculateWeatherStatistics.daily(
        locationId: locationId,
        date: targetDate,
      );

      result.fold((failure) => _setError(failure), (statistics) {
        _updateStatistics(statistics);
      });
    } catch (e) {
      _setError(WeatherStatisticsCalculationFailure(e.toString(), 'daily'));
    }
  }

  /// Calculate monthly statistics
  Future<void> calculateMonthlyStatistics({
    required String locationId,
    DateTime? monthDate,
  }) async {
    final targetDate = monthDate ?? DateTime.now();

    try {
      final result = await _calculateWeatherStatistics.monthly(
        locationId: locationId,
        monthDate: targetDate,
      );

      result.fold((failure) => _setError(failure), (statistics) {
        _updateStatistics(statistics);
      });
    } catch (e) {
      _setError(WeatherStatisticsCalculationFailure(e.toString(), 'monthly'));
    }
  }

  /// Sync weather data
  Future<bool> syncWeatherData() async {
    _setSyncing(true);
    _clearError();

    try {
      final result = await _weatherRepository.syncWeatherData();

      return result.fold(
        (failure) {
          _setError(failure);
          return false;
        },
        (syncedCount) {
          Future.wait([
            loadMeasurements(refresh: true),
            loadRainGauges(refresh: true),
          ]);

          return true;
        },
      );
    } catch (e) {
      _setError(WeatherSyncFailure('Sync failed: $e'));
      return false;
    } finally {
      _setSyncing(false);
    }
  }

  /// Set location filter
  void setLocationFilter(String? locationId) {
    if (_selectedLocationId != locationId) {
      _selectedLocationId = locationId;
      notifyListeners();
      loadMeasurements(refresh: true);
      if (locationId != null) {
        loadRainGaugesByLocation(locationId);
      } else {
        loadRainGauges(refresh: true);
      }
    }
  }

  /// Set date range filter
  void setDateRangeFilter(DateTime? startDate, DateTime? endDate) {
    if (_startDate != startDate || _endDate != endDate) {
      _startDate = startDate;
      _endDate = endDate;
      notifyListeners();
      loadMeasurements(refresh: true);
    }
  }

  /// Set period filter
  void setPeriodFilter(String period) {
    if (_selectedPeriod != period) {
      _selectedPeriod = period;
      notifyListeners();
      loadStatistics();
    }
  }

  /// Set measurements limit
  void setMeasurementsLimit(int limit) {
    if (_measurementsLimit != limit) {
      _measurementsLimit = limit;
      notifyListeners();
    }
  }

  /// Clear all filters
  void clearFilters() {
    _selectedLocationId = null;
    _startDate = null;
    _endDate = null;
    _selectedPeriod = 'daily';
    _measurementsLimit = 50;
    notifyListeners();
    loadMeasurements(refresh: true);
    loadRainGauges(refresh: true);
  }

  /// Get measurements for today
  Future<void> loadTodayMeasurements() async {
    try {
      final result = await _getWeatherMeasurements.today(_selectedLocationId);

      result.fold((failure) => _setError(failure), (measurements) {
        _measurements = measurements;
        notifyListeners();
      });
    } catch (e) {
      _setError(WeatherMeasurementFetchFailure(e.toString()));
    }
  }

  /// Get favorable weather measurements for agriculture
  Future<void> loadFavorableMeasurements() async {
    try {
      final result = await _getWeatherMeasurements.favorableForAgriculture(
        locationId: _selectedLocationId,
        startDate: _startDate,
        endDate: _endDate,
        limit: _measurementsLimit,
      );

      result.fold((failure) => _setError(failure), (measurements) {
        _measurements = measurements;
        notifyListeners();
      });
    } catch (e) {
      _setError(WeatherMeasurementFetchFailure(e.toString()));
    }
  }

  /// Get measurements by weather condition
  List<WeatherMeasurementEntity> getMeasurementsByCondition(String condition) {
    return _measurements.where((m) => m.weatherCondition == condition).toList();
  }

  /// Get average temperature for loaded measurements
  double get averageTemperature {
    if (_measurements.isEmpty) return 0.0;
    final total = _measurements
        .map((m) => m.temperature)
        .reduce((a, b) => a + b);
    return total / _measurements.length;
  }

  /// Get total rainfall for loaded measurements
  double get totalRainfall {
    if (_measurements.isEmpty) return 0.0;
    return _measurements.map((m) => m.rainfall).reduce((a, b) => a + b);
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setMeasurementsLoading(bool loading) {
    if (_isMeasurementsLoading != loading) {
      _isMeasurementsLoading = loading;
      notifyListeners();
    }
  }

  void _setRainGaugesLoading(bool loading) {
    if (_isRainGaugesLoading != loading) {
      _isRainGaugesLoading = loading;
      notifyListeners();
    }
  }

  void _setStatisticsLoading(bool loading) {
    if (_isStatisticsLoading != loading) {
      _isStatisticsLoading = loading;
      notifyListeners();
    }
  }

  void _setSyncing(bool syncing) {
    if (_isSyncing != syncing) {
      _isSyncing = syncing;
      notifyListeners();
    }
  }

  void _setError(WeatherFailure? error) {
    _lastError = error;
    _errorMessage = error?.toString();
    notifyListeners();
  }

  void _clearError() {
    if (_lastError != null) {
      _lastError = null;
      _errorMessage = null;
      notifyListeners();
    }
  }

  void _updateStatistics(WeatherStatisticsEntity statistics) {
    final existingIndex = _statistics.indexWhere(
      (s) =>
          s.locationId == statistics.locationId &&
          s.period == statistics.period &&
          s.startDate.isAtSameMomentAs(statistics.startDate),
    );

    if (existingIndex != -1) {
      _statistics[existingIndex] = statistics;
    } else {
      _statistics.add(statistics);
    }

    notifyListeners();
  }

  /// Dispose method for cleanup
  @override
  void dispose() {
    super.dispose();
  }
}
