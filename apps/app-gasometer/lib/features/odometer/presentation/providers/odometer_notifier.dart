import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/odometer_entity.dart';
import '../../domain/usecases/get_last_odometer_reading.dart';
import '../../domain/usecases/get_odometer_readings_by_vehicle.dart';
import 'odometer_providers.dart';
import 'odometer_state.dart';

part 'odometer_notifier.g.dart';

@Riverpod(keepAlive: true)
class OdometerNotifier extends _$OdometerNotifier {
  late final GetOdometerReadingsByVehicleUseCase _getReadingsUseCase;
  late final GetLastOdometerReadingUseCase _getLastReadingUseCase;

  @override
  OdometerState build() {
    _getReadingsUseCase = ref.watch(getOdometerReadingsByVehicleProvider);
    _getLastReadingUseCase = ref.watch(getLastOdometerReadingProvider);
    return const OdometerState();
  }

  /// Carrega leituras de odômetro por veículo
  Future<void> loadByVehicle(String vehicleId) async {
    try {
      if (vehicleId.trim().isEmpty) {
        state = state.copyWith(readings: [], filteredReadings: []);
        return;
      }

      state = state.copyWith(isLoading: true, selectedVehicleId: vehicleId);

      final result = await _getReadingsUseCase(vehicleId);

      result.fold(
        (failure) => state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        ),
        (readings) {
          state = state.copyWith(
            readings: readings,
            isLoading: false,
            errorMessage: null,
          );
          _applyFilters();
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Seleciona mês para filtro
  void selectMonth(DateTime month) {
    state = state.copyWith(selectedMonth: month);
    _applyFilters();
  }

  /// Limpa filtro de mês
  void clearMonthFilter() {
    state = state.copyWith(clearMonth: true);
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = state.readings;

    if (state.selectedMonth != null) {
      filtered = filtered.where((r) {
        return r.registrationDate.year == state.selectedMonth!.year &&
            r.registrationDate.month == state.selectedMonth!.month;
      }).toList();
    }

    state = state.copyWith(filteredReadings: filtered);
  }

  /// Obtém última leitura de odômetro
  Future<OdometerEntity?> getLatestReading(String vehicleId) async {
    try {
      if (vehicleId.trim().isEmpty) return null;

      final result = await _getLastReadingUseCase(vehicleId);
      
      return result.fold(
        (failure) => null,
        (reading) => reading,
      );
    } catch (e) {
      return null;
    }
  }
}
