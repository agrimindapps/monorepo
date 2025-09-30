import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/fuel/domain/entities/fuel_record_entity.dart';
import '../../features/fuel/domain/usecases/add_fuel_record.dart';
import '../../features/fuel/domain/usecases/delete_fuel_record.dart';
import '../../features/fuel/domain/usecases/get_all_fuel_records.dart';
import '../../features/fuel/domain/usecases/get_fuel_records_by_vehicle.dart';
import '../../features/fuel/domain/usecases/update_fuel_record.dart';
import 'dependency_providers.dart';

// Fuel Statistics for analytics
class FuelStatistics {
  const FuelStatistics({
    required this.totalLiters,
    required this.totalCost,
    required this.averagePrice,
    required this.averageConsumption,
    required this.totalRecords,
    required this.lastUpdated,
  });

  final double totalLiters;
  final double totalCost;
  final double averagePrice;
  final double averageConsumption;
  final int totalRecords;
  final DateTime lastUpdated;

  bool get needsRecalculation {
    final now = DateTime.now();
    const maxCacheTime = Duration(minutes: 5);
    return now.difference(lastUpdated) > maxCacheTime;
  }
}

// Fuel State class
class FuelState {
  const FuelState({
    this.fuelRecords = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isInitialized = false,
    this.statistics,
    this.selectedVehicleId,
  });

  final List<FuelRecordEntity> fuelRecords;
  final bool isLoading;
  final String? errorMessage;
  final bool isInitialized;
  final FuelStatistics? statistics;
  final String? selectedVehicleId;

  List<FuelRecordEntity> get recordsForSelectedVehicle {
    if (selectedVehicleId == null) return fuelRecords;
    return fuelRecords.where((r) => r.vehicleId == selectedVehicleId).toList();
  }

  bool get hasRecords => fuelRecords.isNotEmpty;
  int get recordCount => fuelRecords.length;

  FuelState copyWith({
    List<FuelRecordEntity>? fuelRecords,
    bool? isLoading,
    String? errorMessage,
    bool? isInitialized,
    FuelStatistics? statistics,
    String? selectedVehicleId,
  }) {
    return FuelState(
      fuelRecords: fuelRecords ?? this.fuelRecords,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isInitialized: isInitialized ?? this.isInitialized,
      statistics: statistics ?? this.statistics,
      selectedVehicleId: selectedVehicleId ?? this.selectedVehicleId,
    );
  }
}

// Fuel State Notifier
class FuelNotifier extends StateNotifier<FuelState> {
  FuelNotifier(
    this._getAllFuelRecords,
    this._getFuelRecordsByVehicle,
    this._addFuelRecord,
    this._updateFuelRecord,
    this._deleteFuelRecord,
  ) : super(const FuelState()) {
    _initialize();
  }

  final GetAllFuelRecords _getAllFuelRecords;
  final GetFuelRecordsByVehicle _getFuelRecordsByVehicle;
  final AddFuelRecord _addFuelRecord;
  final UpdateFuelRecord _updateFuelRecord;
  final DeleteFuelRecord _deleteFuelRecord;

  Future<void> _initialize() async {
    try {
      await loadFuelRecords();
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao inicializar: $e',
        isInitialized: true,
      );
    }
  }

  Future<void> loadFuelRecords() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _getAllFuelRecords();
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
          isInitialized: true,
        );
      },
      (records) {
        state = state.copyWith(
          fuelRecords: records,
          isLoading: false,
          isInitialized: true,
          statistics: _calculateStatistics(records),
        );
      },
    );
  }

  Future<void> loadFuelRecordsByVehicle(String vehicleId) async {
    state = state.copyWith(isLoading: true, errorMessage: null, selectedVehicleId: vehicleId);

    final result = await _getFuelRecordsByVehicle(GetFuelRecordsByVehicleParams(vehicleId: vehicleId));
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
        );
      },
      (records) {
        state = state.copyWith(
          fuelRecords: records,
          isLoading: false,
          statistics: _calculateStatistics(records),
        );
      },
    );
  }

  Future<bool> addFuelRecord(FuelRecordEntity record) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _addFuelRecord(AddFuelRecordParams(fuelRecord: record))
          .timeout(const Duration(seconds: 30));

      return result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: _mapFailureToMessage(failure),
          );
          return false;
        },
        (addedRecord) {
          final updatedRecords = [...state.fuelRecords, addedRecord];
          state = state.copyWith(
            fuelRecords: updatedRecords,
            isLoading: false,
            statistics: _calculateStatistics(updatedRecords),
          );
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro inesperado: $e',
      );
      return false;
    }
  }

  Future<bool> updateFuelRecord(FuelRecordEntity record) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _updateFuelRecord(UpdateFuelRecordParams(fuelRecord: record));

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
        );
        return false;
      },
      (updatedRecord) {
        final updatedRecords = state.fuelRecords.map((r) {
          return r.id == record.id ? updatedRecord : r;
        }).toList();

        state = state.copyWith(
          fuelRecords: updatedRecords,
          isLoading: false,
          statistics: _calculateStatistics(updatedRecords),
        );
        return true;
      },
    );
  }

  Future<bool> deleteFuelRecord(String recordId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _deleteFuelRecord(DeleteFuelRecordParams(id: recordId));

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
        );
        return false;
      },
      (_) {
        final updatedRecords = state.fuelRecords.where((r) => r.id != recordId).toList();
        state = state.copyWith(
          fuelRecords: updatedRecords,
          isLoading: false,
          statistics: _calculateStatistics(updatedRecords),
        );
        return true;
      },
    );
  }

  void clearSelectedVehicle() {
    state = state.copyWith(selectedVehicleId: null);
    loadFuelRecords(); // Reload all records
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  FuelStatistics _calculateStatistics(List<FuelRecordEntity> records) {
    if (records.isEmpty) {
      return FuelStatistics(
        totalLiters: 0,
        totalCost: 0,
        averagePrice: 0,
        averageConsumption: 0,
        totalRecords: 0,
        lastUpdated: DateTime.now(),
      );
    }

    final totalLiters = records.fold<double>(0, (sum, record) => sum + record.liters);
    final totalCost = records.fold<double>(0, (sum, record) => sum + (record.pricePerLiter * record.liters));
    final averagePrice = totalCost / totalLiters;

    // Calculate average consumption (simplified)
    double averageConsumption = 0;
    int consumptionRecords = 0;
    for (final record in records) {
      if (record.consumption != null && record.consumption! > 0) {
        averageConsumption += record.consumption!;
        consumptionRecords++;
      }
    }
    if (consumptionRecords > 0) {
      averageConsumption = averageConsumption / consumptionRecords;
    }

    return FuelStatistics(
      totalLiters: totalLiters,
      totalCost: totalCost,
      averagePrice: averagePrice,
      averageConsumption: averageConsumption,
      totalRecords: records.length,
      lastUpdated: DateTime.now(),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return 'Erro do servidor. Tente novamente mais tarde.';
    } else if (failure is NetworkFailure) {
      return 'Erro de conexão. Verifique sua internet.';
    } else if (failure is CacheFailure) {
      return 'Erro de cache local.';
    } else {
      return 'Erro inesperado. Tente novamente.';
    }
  }
}

// Providers are imported from dependency_providers.dart

// Main Fuel Provider
final fuelProvider = StateNotifierProvider<FuelNotifier, FuelState>((ref) {
  final getAllFuelRecords = ref.watch(getAllFuelRecordsProvider);
  final getFuelRecordsByVehicle = ref.watch(getFuelRecordsByVehicleProvider);
  final addFuelRecord = ref.watch(addFuelRecordProvider);
  final updateFuelRecord = ref.watch(updateFuelRecordProvider);
  final deleteFuelRecord = ref.watch(deleteFuelRecordProvider);

  return FuelNotifier(
    getAllFuelRecords,
    getFuelRecordsByVehicle,
    addFuelRecord,
    updateFuelRecord,
    deleteFuelRecord,
  );
});