
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/rain_gauge_entity.dart';
import '../../domain/entities/weather_measurement_entity.dart';
import '../../domain/entities/weather_statistics_entity.dart';
import '../../domain/failures/weather_failures.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../domain/usecases/calculate_weather_statistics.dart';
import '../../domain/usecases/create_weather_measurement.dart';
import '../../domain/usecases/get_rain_gauges.dart';
import '../../domain/usecases/get_weather_measurements.dart';
import 'weather_di_providers.dart';

part 'weather_provider.g.dart';

/// State class for Weather
class WeatherState {
  final bool isLoading;
  final bool isMeasurementsLoading;
  final bool isRainGaugesLoading;
  final bool isStatisticsLoading;
  final bool isSyncing;
  final List<WeatherMeasurementEntity> measurements;
  final List<RainGaugeEntity> rainGauges;
  final List<WeatherStatisticsEntity> statistics;
  final WeatherMeasurementEntity? currentWeather;
  final WeatherMeasurementEntity? latestMeasurement;
  final String? selectedLocationId;
  final String selectedPeriod;
  final DateTime? startDate;
  final DateTime? endDate;
  final int measurementsLimit;
  final WeatherFailure? lastError;
  final String? errorMessage;
  final bool hasMoreMeasurements;
  final int currentPage;

  const WeatherState({
    this.isLoading = false,
    this.isMeasurementsLoading = false,
    this.isRainGaugesLoading = false,
    this.isStatisticsLoading = false,
    this.isSyncing = false,
    this.measurements = const [],
    this.rainGauges = const [],
    this.statistics = const [],
    this.currentWeather,
    this.latestMeasurement,
    this.selectedLocationId,
    this.selectedPeriod = 'daily',
    this.startDate,
    this.endDate,
    this.measurementsLimit = 50,
    this.lastError,
    this.errorMessage,
    this.hasMoreMeasurements = true,
    this.currentPage = 0,
  });

  WeatherState copyWith({
    bool? isLoading,
    bool? isMeasurementsLoading,
    bool? isRainGaugesLoading,
    bool? isStatisticsLoading,
    bool? isSyncing,
    List<WeatherMeasurementEntity>? measurements,
    List<RainGaugeEntity>? rainGauges,
    List<WeatherStatisticsEntity>? statistics,
    WeatherMeasurementEntity? currentWeather,
    WeatherMeasurementEntity? latestMeasurement,
    String? selectedLocationId,
    String? selectedPeriod,
    DateTime? startDate,
    DateTime? endDate,
    int? measurementsLimit,
    WeatherFailure? lastError,
    String? errorMessage,
    bool? hasMoreMeasurements,
    int? currentPage,
    bool clearCurrentWeather = false,
    bool clearLatestMeasurement = false,
    bool clearSelectedLocationId = false,
    bool clearStartDate = false,
    bool clearEndDate = false,
    bool clearError = false,
  }) {
    return WeatherState(
      isLoading: isLoading ?? this.isLoading,
      isMeasurementsLoading: isMeasurementsLoading ?? this.isMeasurementsLoading,
      isRainGaugesLoading: isRainGaugesLoading ?? this.isRainGaugesLoading,
      isStatisticsLoading: isStatisticsLoading ?? this.isStatisticsLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      measurements: measurements ?? this.measurements,
      rainGauges: rainGauges ?? this.rainGauges,
      statistics: statistics ?? this.statistics,
      currentWeather: clearCurrentWeather ? null : (currentWeather ?? this.currentWeather),
      latestMeasurement: clearLatestMeasurement ? null : (latestMeasurement ?? this.latestMeasurement),
      selectedLocationId: clearSelectedLocationId ? null : (selectedLocationId ?? this.selectedLocationId),
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      measurementsLimit: measurementsLimit ?? this.measurementsLimit,
      lastError: clearError ? null : (lastError ?? this.lastError),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      hasMoreMeasurements: hasMoreMeasurements ?? this.hasMoreMeasurements,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  bool get hasError => lastError != null;
  bool get hasMeasurements => measurements.isNotEmpty;
  bool get hasRainGauges => rainGauges.isNotEmpty;
  bool get hasStatistics => statistics.isNotEmpty;

  List<RainGaugeEntity> get activeRainGauges =>
      rainGauges.where((gauge) => gauge.isActive).toList();

  List<RainGaugeEntity> get operationalRainGauges =>
      rainGauges.where((gauge) => gauge.isOperational).toList();

  List<RainGaugeEntity> get rainGaugesNeedingMaintenance =>
      rainGauges.where((gauge) => gauge.needsMaintenance).toList();

  Map<String, dynamic> get weatherSummary {
    if (latestMeasurement == null) return {};

    return {
      'temperature': latestMeasurement!.temperature,
      'humidity': latestMeasurement!.humidity,
      'pressure': latestMeasurement!.pressure,
      'condition': latestMeasurement!.weatherCondition,
      'description': latestMeasurement!.description,
      'timestamp': latestMeasurement!.timestamp,
      'location': latestMeasurement!.locationName,
    };
  }
}

/// Weather Notifier using Riverpod code generation
@riverpod
class WeatherNotifier extends _$WeatherNotifier {
  GetWeatherMeasurements get _getWeatherMeasurements => ref.read(getWeatherMeasurementsProvider);
  CreateWeatherMeasurement get _createWeatherMeasurement => ref.read(createWeatherMeasurementProvider);
  GetRainGauges get _getRainGauges => ref.read(getRainGaugesProvider);
  CalculateWeatherStatistics get _calculateWeatherStatistics => ref.read(calculateWeatherStatisticsProvider);
  WeatherRepository get _weatherRepository => ref.read(weatherRepositoryProvider);

  @override
  WeatherState build() {
    return const WeatherState();
  }

  // Convenience getters for backward compatibility
  bool get isLoading => state.isLoading;
  bool get isMeasurementsLoading => state.isMeasurementsLoading;
  bool get isRainGaugesLoading => state.isRainGaugesLoading;
  bool get isStatisticsLoading => state.isStatisticsLoading;
  bool get isSyncing => state.isSyncing;
  List<WeatherMeasurementEntity> get measurements => state.measurements;
  List<RainGaugeEntity> get rainGauges => state.rainGauges;
  List<WeatherStatisticsEntity> get statistics => state.statistics;
  WeatherMeasurementEntity? get currentWeather => state.currentWeather;
  WeatherMeasurementEntity? get latestMeasurement => state.latestMeasurement;
  String? get selectedLocationId => state.selectedLocationId;
  String get selectedPeriod => state.selectedPeriod;
  DateTime? get startDate => state.startDate;
  DateTime? get endDate => state.endDate;
  int get measurementsLimit => state.measurementsLimit;
  WeatherFailure? get lastError => state.lastError;
  String? get errorMessage => state.errorMessage;
  bool get hasError => state.hasError;
  bool get hasMeasurements => state.hasMeasurements;
  bool get hasRainGauges => state.hasRainGauges;
  bool get hasStatistics => state.hasStatistics;
  bool get hasMoreMeasurements => state.hasMoreMeasurements;
  int get currentPage => state.currentPage;
  List<RainGaugeEntity> get activeRainGauges => state.activeRainGauges;
  List<RainGaugeEntity> get operationalRainGauges => state.operationalRainGauges;
  List<RainGaugeEntity> get rainGaugesNeedingMaintenance => state.rainGaugesNeedingMaintenance;
  Map<String, dynamic> get weatherSummary => state.weatherSummary;

  /// Initialize weather provider with default data
  Future<void> initialize({String? locationId}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      if (locationId != null) {
        state = state.copyWith(selectedLocationId: locationId);
      }
      await Future.wait([
        loadMeasurements(),
        loadRainGauges(),
        loadLatestMeasurement(),
      ]);

      if (state.measurements.isNotEmpty) {
        await loadStatistics();
      }
    } catch (e) {
      state = state.copyWith(
        lastError: WeatherDataFailure('Failed to initialize weather provider: $e'),
        errorMessage: 'Failed to initialize weather provider: $e',
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Load weather measurements with current filters
  Future<void> loadMeasurements({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        measurements: [],
        currentPage: 0,
        hasMoreMeasurements: true,
      );
    }

    state = state.copyWith(isMeasurementsLoading: true, clearError: true);

    try {
      final result = await _getWeatherMeasurements(
        locationId: state.selectedLocationId,
        startDate: state.startDate,
        endDate: state.endDate,
        limit: state.measurementsLimit,
      );

      result.fold((failure) {
        state = state.copyWith(
          lastError: failure,
          errorMessage: failure.toString(),
        );
      }, (newMeasurements) {
        final updatedMeasurements = refresh 
            ? newMeasurements 
            : [...state.measurements, ...newMeasurements];
        state = state.copyWith(
          measurements: updatedMeasurements,
          hasMoreMeasurements: newMeasurements.length == state.measurementsLimit,
        );
      });
    } catch (e) {
      state = state.copyWith(
        lastError: WeatherMeasurementFetchFailure(e.toString()),
        errorMessage: e.toString(),
      );
    } finally {
      state = state.copyWith(isMeasurementsLoading: false);
    }
  }

  /// Load more measurements (pagination)
  Future<void> loadMoreMeasurements() async {
    if (!state.hasMoreMeasurements || state.isMeasurementsLoading) return;

    state = state.copyWith(currentPage: state.currentPage + 1);
    await loadMeasurements();
  }

  /// Get latest weather measurement
  Future<void> loadLatestMeasurement() async {
    try {
      final result = await _getWeatherMeasurements.latest(state.selectedLocationId);

      result.fold((failure) {
        state = state.copyWith(
          lastError: failure,
          errorMessage: failure.toString(),
        );
      }, (measurement) {
        state = state.copyWith(latestMeasurement: measurement);
      });
    } catch (e) {
      state = state.copyWith(
        lastError: WeatherMeasurementFetchFailure(e.toString()),
        errorMessage: e.toString(),
      );
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
    state = state.copyWith(isMeasurementsLoading: true, clearError: true);

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
        limit: state.measurementsLimit,
      );

      result.fold((failure) {
        state = state.copyWith(
          lastError: failure,
          errorMessage: failure.toString(),
        );
      }, (measurements) {
        state = state.copyWith(measurements: measurements);
      });
    } catch (e) {
      state = state.copyWith(
        lastError: WeatherMeasurementFetchFailure(e.toString()),
        errorMessage: e.toString(),
      );
    } finally {
      state = state.copyWith(isMeasurementsLoading: false);
    }
  }

  /// Create new weather measurement
  Future<bool> createMeasurement(WeatherMeasurementEntity measurement) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _createWeatherMeasurement(measurement);

      return result.fold(
        (failure) {
          state = state.copyWith(
            lastError: failure,
            errorMessage: failure.toString(),
            isLoading: false,
          );
          return false;
        },
        (createdMeasurement) {
          state = state.copyWith(
            measurements: [createdMeasurement, ...state.measurements],
            latestMeasurement: createdMeasurement,
            isLoading: false,
          );
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        lastError: WeatherMeasurementSaveFailure(e.toString()),
        errorMessage: e.toString(),
        isLoading: false,
      );
      return false;
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
    state = state.copyWith(isLoading: true, clearError: true);

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
          state = state.copyWith(
            lastError: failure,
            errorMessage: failure.toString(),
            isLoading: false,
          );
          return false;
        },
        (measurement) {
          state = state.copyWith(
            measurements: [measurement, ...state.measurements],
            latestMeasurement: measurement,
            isLoading: false,
          );
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        lastError: WeatherMeasurementSaveFailure(e.toString()),
        errorMessage: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  /// Get current weather from external API
  Future<void> getCurrentWeatherFromAPI(
    double latitude,
    double longitude,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _weatherRepository.getCurrentWeatherFromAPI(
        latitude,
        longitude,
      );

      result.fold((failure) {
        state = state.copyWith(
          lastError: failure,
          errorMessage: failure.toString(),
        );
      }, (measurement) {
        final existingIndex = state.measurements.indexWhere(
          (m) => m.id == measurement.id,
        );
        final updatedMeasurements = List<WeatherMeasurementEntity>.from(state.measurements);
        if (existingIndex == -1) {
          updatedMeasurements.insert(0, measurement);
        }

        state = state.copyWith(
          currentWeather: measurement,
          latestMeasurement: measurement,
          measurements: updatedMeasurements,
        );
      });
    } catch (e) {
      state = state.copyWith(
        lastError: WeatherApiFailure('external_api', 500, e.toString()),
        errorMessage: e.toString(),
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Get weather forecast
  Future<void> getWeatherForecast(
    double latitude,
    double longitude, {
    int days = 7,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _weatherRepository.getWeatherForecast(
        latitude,
        longitude,
        days: days,
      );

      result.fold((failure) {
        state = state.copyWith(
          lastError: failure,
          errorMessage: failure.toString(),
        );
      }, (forecastMeasurements) {
        final updatedMeasurements = List<WeatherMeasurementEntity>.from(state.measurements);
        for (final measurement in forecastMeasurements) {
          final existingIndex = updatedMeasurements.indexWhere(
            (m) => m.id == measurement.id,
          );
          if (existingIndex == -1) {
            updatedMeasurements.add(measurement);
          }
        }
        updatedMeasurements.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        state = state.copyWith(measurements: updatedMeasurements);
      });
    } catch (e) {
      state = state.copyWith(
        lastError: WeatherApiFailure('external_api', 500, e.toString()),
        errorMessage: e.toString(),
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Load rain gauges
  Future<void> loadRainGauges({bool refresh = false}) async {
    state = state.copyWith(isRainGaugesLoading: true, clearError: true);

    try {
      final result = await _getRainGauges();

      result.fold((failure) {
        state = state.copyWith(
          lastError: failure,
          errorMessage: failure.toString(),
        );
      }, (rainGauges) {
        state = state.copyWith(rainGauges: rainGauges);
      });
    } catch (e) {
      state = state.copyWith(
        lastError: RainGaugeFetchFailure(e.toString()),
        errorMessage: e.toString(),
      );
    } finally {
      state = state.copyWith(isRainGaugesLoading: false);
    }
  }

  /// Get rain gauges by location
  Future<void> loadRainGaugesByLocation(String locationId) async {
    state = state.copyWith(isRainGaugesLoading: true, clearError: true);

    try {
      final result = await _getRainGauges.byLocation(locationId);

      result.fold((failure) {
        state = state.copyWith(
          lastError: failure,
          errorMessage: failure.toString(),
        );
      }, (rainGauges) {
        state = state.copyWith(rainGauges: rainGauges);
      });
    } catch (e) {
      state = state.copyWith(
        lastError: RainGaugeFetchFailure(e.toString()),
        errorMessage: e.toString(),
      );
    } finally {
      state = state.copyWith(isRainGaugesLoading: false);
    }
  }

  /// Get rain gauges health report
  Future<Map<String, dynamic>?> getRainGaugesHealthReport() async {
    try {
      final result = await _getRainGauges.getHealthReport();

      return result.fold((failure) {
        state = state.copyWith(
          lastError: failure,
          errorMessage: failure.toString(),
        );
        return null;
      }, (report) => report);
    } catch (e) {
      state = state.copyWith(
        lastError: RainGaugeFetchFailure(e.toString()),
        errorMessage: e.toString(),
      );
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
    state = state.copyWith(isStatisticsLoading: true, clearError: true);

    try {
      final result = await _calculateWeatherStatistics(
        locationId: locationId ?? state.selectedLocationId ?? 'default',
        period: period ?? state.selectedPeriod,
        startDate:
            startDate ??
            state.startDate ??
            DateTime.now().subtract(const Duration(days: 30)),
        endDate: endDate ?? state.endDate ?? DateTime.now(),
      );

      result.fold((failure) {
        state = state.copyWith(
          lastError: failure,
          errorMessage: failure.toString(),
        );
      }, (statistics) {
        final updatedStatistics = List<WeatherStatisticsEntity>.from(state.statistics);
        final existingIndex = updatedStatistics.indexWhere(
          (s) => s.id == statistics.id,
        );
        if (existingIndex != -1) {
          updatedStatistics[existingIndex] = statistics;
        } else {
          updatedStatistics.add(statistics);
        }
        state = state.copyWith(statistics: updatedStatistics);
      });
    } catch (e) {
      state = state.copyWith(
        lastError: WeatherStatisticsCalculationFailure(
          e.toString(),
          period ?? state.selectedPeriod,
        ),
        errorMessage: e.toString(),
      );
    } finally {
      state = state.copyWith(isStatisticsLoading: false);
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

      result.fold((failure) {
        state = state.copyWith(
          lastError: failure,
          errorMessage: failure.toString(),
        );
      }, (statistics) {
        _updateStatistics(statistics);
      });
    } catch (e) {
      state = state.copyWith(
        lastError: WeatherStatisticsCalculationFailure(e.toString(), 'daily'),
        errorMessage: e.toString(),
      );
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

      result.fold((failure) {
        state = state.copyWith(
          lastError: failure,
          errorMessage: failure.toString(),
        );
      }, (statistics) {
        _updateStatistics(statistics);
      });
    } catch (e) {
      state = state.copyWith(
        lastError: WeatherStatisticsCalculationFailure(e.toString(), 'monthly'),
        errorMessage: e.toString(),
      );
    }
  }

  /// Sync weather data
  Future<bool> syncWeatherData() async {
    state = state.copyWith(isSyncing: true, clearError: true);

    try {
      final result = await _weatherRepository.syncWeatherData();

      return result.fold(
        (failure) {
          state = state.copyWith(
            lastError: failure,
            errorMessage: failure.toString(),
            isSyncing: false,
          );
          return false;
        },
        (syncedCount) {
          Future.wait([
            loadMeasurements(refresh: true),
            loadRainGauges(refresh: true),
          ]);
          state = state.copyWith(isSyncing: false);
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        lastError: WeatherSyncFailure('Sync failed: $e'),
        errorMessage: 'Sync failed: $e',
        isSyncing: false,
      );
      return false;
    }
  }

  /// Set location filter
  void setLocationFilter(String? locationId) {
    if (state.selectedLocationId != locationId) {
      state = state.copyWith(
        selectedLocationId: locationId,
        clearSelectedLocationId: locationId == null,
      );
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
    if (state.startDate != startDate || state.endDate != endDate) {
      state = state.copyWith(
        startDate: startDate,
        endDate: endDate,
        clearStartDate: startDate == null,
        clearEndDate: endDate == null,
      );
      loadMeasurements(refresh: true);
    }
  }

  /// Set period filter
  void setPeriodFilter(String period) {
    if (state.selectedPeriod != period) {
      state = state.copyWith(selectedPeriod: period);
      loadStatistics();
    }
  }

  /// Set measurements limit
  void setMeasurementsLimit(int limit) {
    if (state.measurementsLimit != limit) {
      state = state.copyWith(measurementsLimit: limit);
    }
  }

  /// Clear all filters
  void clearFilters() {
    state = state.copyWith(
      clearSelectedLocationId: true,
      clearStartDate: true,
      clearEndDate: true,
      selectedPeriod: 'daily',
      measurementsLimit: 50,
    );
    loadMeasurements(refresh: true);
    loadRainGauges(refresh: true);
  }

  /// Get measurements for today
  Future<void> loadTodayMeasurements() async {
    try {
      final result = await _getWeatherMeasurements.today(state.selectedLocationId);

      result.fold((failure) {
        state = state.copyWith(
          lastError: failure,
          errorMessage: failure.toString(),
        );
      }, (measurements) {
        state = state.copyWith(measurements: measurements);
      });
    } catch (e) {
      state = state.copyWith(
        lastError: WeatherMeasurementFetchFailure(e.toString()),
        errorMessage: e.toString(),
      );
    }
  }

  /// Get favorable weather measurements for agriculture
  Future<void> loadFavorableMeasurements() async {
    try {
      final result = await _getWeatherMeasurements.favorableForAgriculture(
        locationId: state.selectedLocationId,
        startDate: state.startDate,
        endDate: state.endDate,
        limit: state.measurementsLimit,
      );

      result.fold((failure) {
        state = state.copyWith(
          lastError: failure,
          errorMessage: failure.toString(),
        );
      }, (measurements) {
        state = state.copyWith(measurements: measurements);
      });
    } catch (e) {
      state = state.copyWith(
        lastError: WeatherMeasurementFetchFailure(e.toString()),
        errorMessage: e.toString(),
      );
    }
  }

  /// Get measurements by weather condition
  List<WeatherMeasurementEntity> getMeasurementsByCondition(String condition) {
    return state.measurements.where((m) => m.weatherCondition == condition).toList();
  }

  /// Get average temperature for loaded measurements
  double get averageTemperature {
    if (state.measurements.isEmpty) return 0.0;
    final total = state.measurements
        .map((m) => m.temperature)
        .reduce((a, b) => a + b);
    return total / state.measurements.length;
  }

  /// Get total rainfall for loaded measurements
  double get totalRainfall {
    if (state.measurements.isEmpty) return 0.0;
    return state.measurements.map((m) => m.rainfall).reduce((a, b) => a + b);
  }

  void _updateStatistics(WeatherStatisticsEntity statistics) {
    final updatedStatistics = List<WeatherStatisticsEntity>.from(state.statistics);
    final existingIndex = updatedStatistics.indexWhere(
      (s) =>
          s.locationId == statistics.locationId &&
          s.period == statistics.period &&
          s.startDate.isAtSameMomentAs(statistics.startDate),
    );

    if (existingIndex != -1) {
      updatedStatistics[existingIndex] = statistics;
    } else {
      updatedStatistics.add(statistics);
    }

    state = state.copyWith(statistics: updatedStatistics);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
