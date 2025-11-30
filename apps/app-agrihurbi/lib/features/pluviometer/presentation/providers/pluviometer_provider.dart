import 'package:core/core.dart';

import '../../../../database/database_provider.dart';
import '../../../../database/repositories/rain_gauge_repository.dart';
import '../../../../database/repositories/rainfall_measurement_repository.dart';
import '../../data/repositories/pluviometer_repository_impl.dart';
import '../../domain/entities/rain_gauge_entity.dart';
import '../../domain/entities/rainfall_measurement_entity.dart';
import '../../domain/repositories/pluviometer_repository.dart';
import '../../domain/usecases/create_measurement.dart';
import '../../domain/usecases/create_rain_gauge.dart';
import '../../domain/usecases/get_measurements.dart';
import '../../domain/usecases/get_rain_gauges.dart';
import '../../domain/usecases/get_statistics.dart';

part 'pluviometer_provider.g.dart';

// ==================== REPOSITORY PROVIDERS ====================

@riverpod
RainGaugeRepository rainGaugeDbRepository(Ref ref) {
  final db = ref.watch(agrihurbiDatabaseProvider);
  return RainGaugeRepository(db);
}

@riverpod
RainfallMeasurementRepository rainfallMeasurementDbRepository(Ref ref) {
  final db = ref.watch(agrihurbiDatabaseProvider);
  return RainfallMeasurementRepository(db);
}

@riverpod
PluviometerRepository pluviometerRepository(Ref ref) {
  return PluviometerRepositoryImpl(
    ref.watch(rainGaugeDbRepositoryProvider),
    ref.watch(rainfallMeasurementDbRepositoryProvider),
  );
}

// ==================== USE CASE PROVIDERS ====================

@riverpod
GetRainGaugesUseCase getRainGaugesUseCase(Ref ref) {
  return GetRainGaugesUseCase(ref.watch(pluviometerRepositoryProvider));
}

@riverpod
GetRainGaugeByIdUseCase getRainGaugeByIdUseCase(Ref ref) {
  return GetRainGaugeByIdUseCase(ref.watch(pluviometerRepositoryProvider));
}

@riverpod
CreateRainGaugeUseCase createRainGaugeUseCase(Ref ref) {
  return CreateRainGaugeUseCase(ref.watch(pluviometerRepositoryProvider));
}

@riverpod
UpdateRainGaugeUseCase updateRainGaugeUseCase(Ref ref) {
  return UpdateRainGaugeUseCase(ref.watch(pluviometerRepositoryProvider));
}

@riverpod
DeleteRainGaugeUseCase deleteRainGaugeUseCase(Ref ref) {
  return DeleteRainGaugeUseCase(ref.watch(pluviometerRepositoryProvider));
}

@riverpod
GetMeasurementsUseCase getMeasurementsUseCase(Ref ref) {
  return GetMeasurementsUseCase(ref.watch(pluviometerRepositoryProvider));
}

@riverpod
CreateMeasurementUseCase createMeasurementUseCase(Ref ref) {
  return CreateMeasurementUseCase(ref.watch(pluviometerRepositoryProvider));
}

@riverpod
UpdateMeasurementUseCase updateMeasurementUseCase(Ref ref) {
  return UpdateMeasurementUseCase(ref.watch(pluviometerRepositoryProvider));
}

@riverpod
DeleteMeasurementUseCase deleteMeasurementUseCase(Ref ref) {
  return DeleteMeasurementUseCase(ref.watch(pluviometerRepositoryProvider));
}

@riverpod
GetStatisticsUseCase getStatisticsUseCase(Ref ref) {
  return GetStatisticsUseCase(ref.watch(pluviometerRepositoryProvider));
}

@riverpod
GetMonthlyTotalsUseCase getMonthlyTotalsUseCase(Ref ref) {
  return GetMonthlyTotalsUseCase(ref.watch(pluviometerRepositoryProvider));
}

@riverpod
GetYearlyTotalsUseCase getYearlyTotalsUseCase(Ref ref) {
  return GetYearlyTotalsUseCase(ref.watch(pluviometerRepositoryProvider));
}

@riverpod
ExportToCsvUseCase exportToCsvUseCase(Ref ref) {
  return ExportToCsvUseCase(ref.watch(pluviometerRepositoryProvider));
}

// ==================== STATE NOTIFIERS ====================

/// State para rain gauges
class RainGaugesState {
  const RainGaugesState({
    this.gauges = const [],
    this.selectedGauge,
    this.isLoading = false,
    this.errorMessage,
  });

  final List<RainGaugeEntity> gauges;
  final RainGaugeEntity? selectedGauge;
  final bool isLoading;
  final String? errorMessage;

  RainGaugesState copyWith({
    List<RainGaugeEntity>? gauges,
    RainGaugeEntity? selectedGauge,
    bool? isLoading,
    String? errorMessage,
  }) {
    return RainGaugesState(
      gauges: gauges ?? this.gauges,
      selectedGauge: selectedGauge ?? this.selectedGauge,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

@riverpod
class RainGaugesNotifier extends _$RainGaugesNotifier {
  @override
  RainGaugesState build() {
    return const RainGaugesState();
  }

  Future<void> loadGauges() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final useCase = ref.read(getRainGaugesUseCaseProvider);
    final result = await useCase(const NoParams());

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (gauges) => state = state.copyWith(
        gauges: gauges,
        isLoading: false,
      ),
    );
  }

  void selectGauge(RainGaugeEntity? gauge) {
    state = state.copyWith(selectedGauge: gauge);
  }

  Future<bool> createGauge(RainGaugeEntity gauge) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final useCase = ref.read(createRainGaugeUseCaseProvider);
    final result = await useCase(CreateRainGaugeParams(rainGauge: gauge));

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (created) {
        state = state.copyWith(
          gauges: [...state.gauges, created],
          isLoading: false,
        );
        return true;
      },
    );
  }

  Future<bool> updateGauge(RainGaugeEntity gauge) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final useCase = ref.read(updateRainGaugeUseCaseProvider);
    final result = await useCase(UpdateRainGaugeParams(rainGauge: gauge));

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (updated) {
        final updatedList = state.gauges.map((g) {
          return g.id == updated.id ? updated : g;
        }).toList();
        state = state.copyWith(
          gauges: updatedList,
          selectedGauge: state.selectedGauge?.id == updated.id
              ? updated
              : state.selectedGauge,
          isLoading: false,
        );
        return true;
      },
    );
  }

  Future<bool> deleteGauge(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final useCase = ref.read(deleteRainGaugeUseCaseProvider);
    final result = await useCase(DeleteRainGaugeParams(id: id));

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (_) {
        final updatedList =
            state.gauges.where((g) => g.id != id).toList();
        state = state.copyWith(
          gauges: updatedList,
          selectedGauge:
              state.selectedGauge?.id == id ? null : state.selectedGauge,
          isLoading: false,
        );
        return true;
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// State para measurements
class MeasurementsState {
  const MeasurementsState({
    this.measurements = const [],
    this.selectedMeasurement,
    this.isLoading = false,
    this.errorMessage,
  });

  final List<RainfallMeasurementEntity> measurements;
  final RainfallMeasurementEntity? selectedMeasurement;
  final bool isLoading;
  final String? errorMessage;

  MeasurementsState copyWith({
    List<RainfallMeasurementEntity>? measurements,
    RainfallMeasurementEntity? selectedMeasurement,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MeasurementsState(
      measurements: measurements ?? this.measurements,
      selectedMeasurement: selectedMeasurement ?? this.selectedMeasurement,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

@riverpod
class MeasurementsNotifier extends _$MeasurementsNotifier {
  @override
  MeasurementsState build() {
    return const MeasurementsState();
  }

  Future<void> loadMeasurements({
    String? rainGaugeId,
    DateTime? start,
    DateTime? end,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final useCase = ref.read(getMeasurementsUseCaseProvider);
    final result = await useCase(GetMeasurementsParams(
      rainGaugeId: rainGaugeId,
      start: start,
      end: end,
    ));

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (measurements) => state = state.copyWith(
        measurements: measurements,
        isLoading: false,
      ),
    );
  }

  void selectMeasurement(RainfallMeasurementEntity? measurement) {
    state = state.copyWith(selectedMeasurement: measurement);
  }

  Future<bool> createMeasurement(RainfallMeasurementEntity measurement) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final useCase = ref.read(createMeasurementUseCaseProvider);
    final result =
        await useCase(CreateMeasurementParams(measurement: measurement));

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (created) {
        state = state.copyWith(
          measurements: [created, ...state.measurements],
          isLoading: false,
        );
        return true;
      },
    );
  }

  Future<bool> updateMeasurement(RainfallMeasurementEntity measurement) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final useCase = ref.read(updateMeasurementUseCaseProvider);
    final result =
        await useCase(UpdateMeasurementParams(measurement: measurement));

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (updated) {
        final updatedList = state.measurements.map((m) {
          return m.id == updated.id ? updated : m;
        }).toList();
        state = state.copyWith(
          measurements: updatedList,
          selectedMeasurement: state.selectedMeasurement?.id == updated.id
              ? updated
              : state.selectedMeasurement,
          isLoading: false,
        );
        return true;
      },
    );
  }

  Future<bool> deleteMeasurement(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final useCase = ref.read(deleteMeasurementUseCaseProvider);
    final result = await useCase(DeleteMeasurementParams(id: id));

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (_) {
        final updatedList =
            state.measurements.where((m) => m.id != id).toList();
        state = state.copyWith(
          measurements: updatedList,
          selectedMeasurement: state.selectedMeasurement?.id == id
              ? null
              : state.selectedMeasurement,
          isLoading: false,
        );
        return true;
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// State para statistics
class StatisticsState {
  const StatisticsState({
    this.statistics,
    this.monthlyTotals = const {},
    this.yearlyTotals = const {},
    this.selectedYear,
    this.isLoading = false,
    this.errorMessage,
  });

  final RainfallStatistics? statistics;
  final Map<int, double> monthlyTotals;
  final Map<int, double> yearlyTotals;
  final int? selectedYear;
  final bool isLoading;
  final String? errorMessage;

  StatisticsState copyWith({
    RainfallStatistics? statistics,
    Map<int, double>? monthlyTotals,
    Map<int, double>? yearlyTotals,
    int? selectedYear,
    bool? isLoading,
    String? errorMessage,
  }) {
    return StatisticsState(
      statistics: statistics ?? this.statistics,
      monthlyTotals: monthlyTotals ?? this.monthlyTotals,
      yearlyTotals: yearlyTotals ?? this.yearlyTotals,
      selectedYear: selectedYear ?? this.selectedYear,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

@riverpod
class StatisticsNotifier extends _$StatisticsNotifier {
  @override
  StatisticsState build() {
    return StatisticsState(selectedYear: DateTime.now().year);
  }

  Future<void> loadStatistics({
    DateTime? start,
    DateTime? end,
    String? rainGaugeId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final useCase = ref.read(getStatisticsUseCaseProvider);
    final result = await useCase(GetStatisticsParams(
      start: start,
      end: end,
      rainGaugeId: rainGaugeId,
    ));

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (stats) => state = state.copyWith(
        statistics: stats,
        isLoading: false,
      ),
    );
  }

  Future<void> loadMonthlyTotals(int year) async {
    state = state.copyWith(isLoading: true, errorMessage: null, selectedYear: year);

    final useCase = ref.read(getMonthlyTotalsUseCaseProvider);
    final result = await useCase(GetMonthlyTotalsParams(year: year));

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (totals) => state = state.copyWith(
        monthlyTotals: totals,
        isLoading: false,
      ),
    );
  }

  Future<void> loadYearlyTotals({int? startYear, int? endYear}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final useCase = ref.read(getYearlyTotalsUseCaseProvider);
    final result = await useCase(GetYearlyTotalsParams(
      startYear: startYear,
      endYear: endYear,
    ));

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (totals) => state = state.copyWith(
        yearlyTotals: totals,
        isLoading: false,
      ),
    );
  }

  void selectYear(int year) {
    state = state.copyWith(selectedYear: year);
    loadMonthlyTotals(year);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Provider para exportação CSV
@riverpod
class CsvExporter extends _$CsvExporter {
  @override
  AsyncValue<String?> build() => const AsyncValue.data(null);

  Future<String?> exportToCsv({
    DateTime? start,
    DateTime? end,
    String? rainGaugeId,
  }) async {
    state = const AsyncValue.loading();

    final useCase = ref.read(exportToCsvUseCaseProvider);
    final result = await useCase(ExportToCsvParams(
      start: start,
      end: end,
      rainGaugeId: rainGaugeId,
    ));

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return null;
      },
      (csv) {
        state = AsyncValue.data(csv);
        return csv;
      },
    );
  }
}
