import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/vehicles/domain/entities/vehicle_entity.dart';
import '../../features/vehicles/domain/usecases/add_vehicle.dart';
import '../../features/vehicles/domain/usecases/delete_vehicle.dart';
import '../../features/vehicles/domain/usecases/get_all_vehicles.dart';
import '../../features/vehicles/domain/usecases/update_vehicle.dart';
import 'dependency_providers.dart';

// Vehicle State class
class VehiclesState {
  const VehiclesState({
    this.vehicles = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isInitialized = false,
  });

  final List<VehicleEntity> vehicles;
  final bool isLoading;
  final String? errorMessage;
  final bool isInitialized;

  List<VehicleEntity> get activeVehicles => vehicles.where((v) => v.isActive).toList();
  bool get hasVehicles => vehicles.isNotEmpty;
  int get vehicleCount => vehicles.length;
  int get activeVehicleCount => activeVehicles.length;

  VehiclesState copyWith({
    List<VehicleEntity>? vehicles,
    bool? isLoading,
    String? errorMessage,
    bool? isInitialized,
  }) {
    return VehiclesState(
      vehicles: vehicles ?? this.vehicles,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

// Vehicles State Notifier
class VehiclesNotifier extends StateNotifier<VehiclesState> {
  VehiclesNotifier(
    this._getAllVehicles,
    this._addVehicle,
    this._updateVehicle,
    this._deleteVehicle,
  ) : super(const VehiclesState()) {
    _initialize();
  }

  final GetAllVehicles _getAllVehicles;
  final AddVehicle _addVehicle;
  final UpdateVehicle _updateVehicle;
  final DeleteVehicle _deleteVehicle;

  Future<void> _initialize() async {
    try {
      await loadVehicles();
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao inicializar: $e',
        isInitialized: true,
      );
    }
  }

  Future<void> loadVehicles() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _getAllVehicles();
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
          isInitialized: true,
        );
      },
      (vehicles) {
        state = state.copyWith(
          vehicles: vehicles,
          isLoading: false,
          isInitialized: true,
        );
      },
    );
  }

  Future<bool> addVehicle(VehicleEntity vehicle) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _addVehicle(AddVehicleParams(vehicle: vehicle))
          .timeout(const Duration(seconds: 30));

      return result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: _mapFailureToMessage(failure),
          );
          return false;
        },
        (addedVehicle) {
          final updatedVehicles = [...state.vehicles, addedVehicle];
          state = state.copyWith(
            vehicles: updatedVehicles,
            isLoading: false,
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

  Future<bool> updateVehicle(VehicleEntity vehicle) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _updateVehicle(UpdateVehicleParams(vehicle: vehicle));

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
        );
        return false;
      },
      (updatedVehicle) {
        final updatedVehicles = state.vehicles.map((v) {
          return v.id == vehicle.id ? updatedVehicle : v;
        }).toList();

        state = state.copyWith(
          vehicles: updatedVehicles,
          isLoading: false,
        );
        return true;
      },
    );
  }

  Future<bool> deleteVehicle(String vehicleId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _deleteVehicle(DeleteVehicleParams(vehicleId: vehicleId));

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
        );
        return false;
      },
      (_) {
        final updatedVehicles = state.vehicles.where((v) => v.id != vehicleId).toList();
        state = state.copyWith(
          vehicles: updatedVehicles,
          isLoading: false,
        );
        return true;
      },
    );
  }

  List<VehicleEntity> getVehiclesByType(VehicleType type) {
    return state.vehicles.where((v) => v.type == type && v.isActive).toList();
  }

  List<VehicleEntity> getVehiclesByFuelType(FuelType fuelType) {
    return state.vehicles
        .where((v) => v.supportedFuels.contains(fuelType) && v.isActive)
        .toList();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
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

// Main Vehicles Provider
final vehiclesProvider = StateNotifierProvider<VehiclesNotifier, VehiclesState>((ref) {
  final getAllVehicles = ref.watch(getAllVehiclesProvider);
  final addVehicle = ref.watch(addVehicleProvider);
  final updateVehicle = ref.watch(updateVehicleProvider);
  final deleteVehicle = ref.watch(deleteVehicleProvider);

  return VehiclesNotifier(
    getAllVehicles,
    addVehicle,
    updateVehicle,
    deleteVehicle,
  );
});