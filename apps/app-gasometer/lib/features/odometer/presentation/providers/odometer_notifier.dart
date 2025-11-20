import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../database/providers/database_providers.dart';
import '../../../../database/repositories/odometer_reading_repository.dart';
import '../../domain/entities/odometer_entity.dart';
import 'odometer_state.dart';

class OdometerNotifier extends StateNotifier<OdometerState> {
  OdometerNotifier(this._ref) : super(const OdometerState()) {
    _repository = _ref.read(odometerReadingRepositoryProvider);
  }

  final Ref _ref;
  late final OdometerReadingRepository _repository;

  /// Carrega leituras de odômetro por veículo
  Future<void> loadByVehicle(String vehicleId) async {
    try {
      final vehicleIdInt = int.tryParse(vehicleId);
      if (vehicleIdInt == null) {
        state = state.copyWith(readings: [], filteredReadings: []);
        return;
      }

      state = state.copyWith(isLoading: true, selectedVehicleId: vehicleId);

      final readings = await _repository.findByVehicleId(vehicleIdInt);
      final entities = readings.map((data) => _toEntity(data)).toList();

      state = state.copyWith(
        readings: entities,
        isLoading: false,
      );
      _applyFilters();
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
      final vehicleIdInt = int.tryParse(vehicleId);
      if (vehicleIdInt == null) return null;

      final data = await _repository.findLatestByVehicleId(vehicleIdInt);
      return data != null ? _toEntity(data) : null;
    } catch (e) {
      return null;
    }
  }

  /// Converte OdometerReadingData para OdometerEntity
  OdometerEntity _toEntity(OdometerReadingData data) {
    return OdometerEntity(
      id: data.id.toString(),
      vehicleId: data.vehicleId.toString(),
      value: data.reading,
      registrationDate: DateTime.fromMillisecondsSinceEpoch(data.date),
      description: data.notes ?? '',
      type: OdometerType.other, // Default type
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      lastSyncAt: data.lastSyncAt,
      isDirty: data.isDirty,
      isDeleted: data.isDeleted,
      version: data.version,
      userId: data.userId,
      moduleName: data.moduleName,
      metadata: const {},
    );
  }
}

/// Provider do notifier de odômetro
final odometerNotifierProvider =
    StateNotifierProvider<OdometerNotifier, OdometerState>(
  (ref) => OdometerNotifier(ref),
);
